#!/bin/bash
#
# Run every day to update src_ruian.parcel.
#

BASEDIR=$(dirname "$0")
LOG_FILE=${BASEDIR}/../logs/src_ruian/etl_daily.log

source ${BASEDIR}/../etc/gdal.env
source ${BASEDIR}/../etc/pgsql.env

> $LOG_FILE
rm -rf /mnt/data/ruian.parcel

echo "src_ruian daily update started at $(date)" > $LOG_FILE

${BASEDIR}/extract_parcel.sh --work-dir /mnt/data/ruian.parcel >> $LOG_FILE 2>&1
${BASEDIR}/transform_parcel.sh --work-dir /mnt/data/ruian.parcel --stage-schema stg_ruian >> $LOG_FILE 2>&1 && \
${BASEDIR}/load_parcel.sh --stage-schema stg_ruian --target-schema src_ruian >> $LOG_FILE 2>&1

rm -rf /mnt/data/ruian.parcel

echo "src_ruian daily updated finished at $(date)" >> $LOG_FILE
