#!/bin/bash

HOMEDIR="/opt/katastr.io"
COMMIT=$(git log --oneline | head -n 1 | cut -d ' ' -f 1)
PREV_COMMIT=$(git log --oneline | head -n 2 | cut -d ' ' -f 1 | tail -n 1)

cd ~/clone
rsync -aqz ./* codeship@193.85.199.37:${HOMEDIR}/etl-new && \
ssh codeship@193.85.199.37 "rm -rf ${HOMEDIR}/etl-${PREV_COMMIT}"
