#!/bin/bash

HOMEDIR="/opt/katastr.io"
COMMIT=$(git log --oneline | head -n 1 | cut -d ' ' -f 1)

cd ~/clone
sed -i "s/COMMIT/${COMMIT}/g" etc/crontab.txt

rsync -aqz ./* codeship@193.85.199.37:${HOMEDIR}/etl-${COMMIT} && \
ssh codeship@193.85.199.37 "find ${HOMEDIR} -maxdepth 1 -type d ! -name etl-${COMMIT} -name 'etl-*' -exec rm -rf '{}' \;" && \
ssh codeship@193.85.199.37 "crontab ${HOMEDIR}/etl-${COMMIT}/etc/crontab.txt"
