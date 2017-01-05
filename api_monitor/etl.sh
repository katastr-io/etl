#!/bin/bash

BASEDIR=$(dirname "$0")
FILE=$(date +'%Y%m01')
LOG_FILE=${BASEDIR}/../logs/api_monitor/etl.log

source ${BASEDIR}/../etc/gdal.env
source ${BASEDIR}/../etc/pgsql.env

> $LOG_FILE

${BASEDIR}/extract.sh --file $FILE >> $LOG_FILE 2>&1 && \
${BASEDIR}/transform.sh --file ${FILE}.csv >> $LOG_FILE 2>&1 && \
${BASEDIR}/load.sh --file ${FILE}.csv >> $LOG_FILE 2>&1

rm -f ./${FILE}.csv
