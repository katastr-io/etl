#!/bin/bash

BASEDIR=$(dirname "$0")

source ${BASEDIR}/../etc/gdal.env
source ${BASEDIR}/../etc/pgsql.env

rm -rf /mnt/data/ruian.state
rm -rf /mnt/data/ruian.town

${BASEDIR}/extract_state.sh --work-dir /mnt/data/ruian.state
${BASEDIR}/extract_town.sh --work-dir /mnt/data/ruian.town
${BASEDIR}/transform_state.sh --work-dir /mnt/data/ruian.state --stage-schema stg_ruian
${BASEDIR}/load_state.sh --stage-schema stg_ruian --target-schema src_ruian
${BASEDIR}/transform_town.sh --work-dir /mnt/data/ruian.town --stage-schema stg_ruian
${BASEDIR}/load_town.sh --stage-schema stg_ruian --target-schema src_ruian
