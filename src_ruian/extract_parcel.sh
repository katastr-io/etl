#!/bin/bash


BASEDIR=`dirname $0`
URL_SRC="http://services.cuzk.cz/gml/inspire/cp/epsg-5514/"

source ${BASEDIR}/../etc/pgsql.env

# Input parameters
while [[ $# > 0 ]]
do
	key="$1"

	case $key in
    	-w|--work-dir)
			WORK_DIR="$2"
		    shift
		    ;;
	    *)
    		echo "Usage: `basename $0` --work-dir|-w [working_directory]"
			exit 1
		    ;;
	esac
	shift
done
# /Input parameters

FILE_LINKS="$WORK_DIR/src_links.txt"

if [ "a$WORK_DIR" == "a" ]
then
	echo "Working directory is not set."
	exit 1
fi

if [ -d $WORK_DIR ]
then
	echo "Working directory '$WORK_DIR' already exists, please remove it first."
	exit 1
fi

# Create working directory
mkdir $WORK_DIR
if [ $? -ne 0 ]
then
	echo "Cannot create the working directory, exiting."
	exit 6
fi

rm -f $FILE_LINKS
psql --no-psqlrc -qAt -c "SELECT '${URL_SRC}' || code || '.zip' FROM src_ruian.area" > $FILE_LINKS

if [ -f $FILE_LINKS -a -s $FILE_LINKS ]
then
    cd $WORK_DIR
    cat $FILE_LINKS | parallel --no-notice -j8 "wget -q {}"
    cd -
else
    "There were no files to download."
    exit 1
fi
