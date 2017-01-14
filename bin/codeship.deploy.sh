#!/bin/bash

HOMEDIR="/opt/katastr.io"

cd ~/clone
rsync -aqz ./* codeship@193.85.199.37:${HOMEDIR}/etl-new && \
ssh codeship@193.85.199.37 "rm -rf ${HOMEDIR}/etl/* && mv ${HOMEDIR}/etl-new/* ${HOMEDIR}/etl && rm -rf ${HOMEDIR}/etl-new"
