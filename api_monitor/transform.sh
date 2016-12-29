#!/bin/bash

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -f|--file)
        FILE="$2"
        shift # past argument
        ;;
    *)
        echo "Usage: `basename $0` --file|-f [filename]"
        exit 1
        ;;
esac
shift # past argument or value
done

sed -i 's/^M$//' $FILE && \
sed -i 's/\r$//' $FILE && \
sed -i 's/;*$//g' $FILE && \
sed -i '1d' $FILE