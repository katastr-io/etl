#!/bin/bash
#
# Run every second day each month to update the whole src_ruian schema.
#

BASEDIR=$(dirname "$0")
LOG_FILE=${BASEDIR}/../logs/src_ruian/etl_monthly.log

source ${BASEDIR}/../etc/gdal.env
source ${BASEDIR}/../etc/pgsql.env

rm -rf /mnt/data/ruian.state
rm -rf /mnt/data/ruian.town
rm -rf /mnt/data/ruian.parcel

> $LOG_FILE
echo "src_ruian monthly update started at $(date)" > $LOG_FILE

${BASEDIR}/extract_state.sh --work-dir /mnt/data/ruian.state >> $LOG_FILE 2>&1
${BASEDIR}/extract_town.sh --work-dir /mnt/data/ruian.town >> $LOG_FILE 2>&1
${BASEDIR}/extract_parcel.sh --work-dir /mnt/data/ruian.parcel >> $LOG_FILE 2>&1

${BASEDIR}/transform_state.sh --work-dir /mnt/data/ruian.state --stage-schema stg_ruian >> $LOG_FILE 2>&1 && \
${BASEDIR}/transform_town.sh --work-dir /mnt/data/ruian.town --stage-schema stg_ruian >> $LOG_FILE 2>&1 && \
${BASEDIR}/transform_parcel.sh --work-dir /mnt/data/ruian.parcel --stage-schema stg_ruian >> $LOG_FILE 2>&1

${BASEDIR}/load_state.sh --stage-schema stg_ruian --target-schema src_ruian >> $LOG_FILE 2>&1 && \
${BASEDIR}/load_town.sh --stage-schema stg_ruian --target-schema src_ruian >> $LOG_FILE 2>&1 && \
${BASEDIR}/load_parcel.sh --stage-schema stg_ruian --target-schema src_ruian >> $LOG_FILE 2>&1

rm -rf /mnt/data/ruian.state
rm -rf /mnt/data/ruian.town
rm -rf /mnt/data/ruian.parcel

echo "src_ruian monthly updated finished at $(date)" >> $LOG_FILE
