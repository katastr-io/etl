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

if [[ $FILE == "20150401" ]]
then
    FILE="20150104"
fi

CSVFILE=$FILE.csv

echo "downloading ${URL}${FILE}"
wget -q ${URL}${CSVFILE} -O $CSVFILE

if [[ $? != 0 ]]; then
    rm -f $CSVFILE
    echo "download failed"
    exit
fi

if [[ $FILE == "20150104" ]]
then
    mv $CSVFILE "20150401.csv"
fi