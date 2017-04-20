#!/bin/bash

# User constants
URL=http://services.cuzk.cz/sestavy/UHDP/UHDP-

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -f|--file)
        FILE="$2"
        shift # past argument
        ;;
    *)
        echo "Usage: `basename $0` --file|-f [file YYYYMMDD name]"
        exit 1
        ;;
esac
shift # past argument or value
done

ZIPFILE=${FILE}.zip
CSVFILE=UHDP-${FILE}.csv

echo "downloading ${URL}${ZIPFILE}"
wget -q ${URL}${ZIPFILE} -O $ZIPFILE

if [[ $? != 0 ]]; then
    echo "downloading ${URL}${ZIPFILE}"
    wget -q ${URL}/${CSVFILE} -O ${CSVFILE}
fi

if [[ -e ${ZIPFILE} ]]; then
    unzip -j $ZIPFILE
fi

if [[ $? != 0 ]]; then
    rm -f $ZIPFILE
    echo "download failed"
    exit 1
fi

mv $CSVFILE ${CSVFILE##UHDP-}

rm -f $ZIPFILE
