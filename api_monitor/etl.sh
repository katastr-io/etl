#!/bin/bash

BASEDIR=$(dirname "$0")
FILE=$(date +'%Y%m01')

source ${BASEDIR}/../etc/gdal.env
source ${BASEDIR}/../etc/pgsql.env

${BASEDIR}/extract.sh --file $FILE && \
${BASEDIR}/transform.sh --file ${FILE}.csv && \
${BASEDIR}/load.sh --file ${FILE}.csv

rm -f ./${FILE}.csv
