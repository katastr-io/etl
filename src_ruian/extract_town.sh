#!/bin/bash

# User defined constants
URL_SRC="http://vdp.cuzk.cz/vdp/ruian/vymennyformat/seznamlinku?vf.pu=S&vf.cr=U&vf.up=OB&vf.ds=K&vf.uo=A&search=Vyhledat"

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

# Include libs
BASEDIR=`dirname $0`
LIBDIR="${BASEDIR}/../lib"
GLIBDIR="${BASEDIR}/../../lib"

. $GLIBDIR/functions
# /Include libs

# Script begining
LAST_DAY=`date -d "-$(date +%d) day" +%Y%m%d`

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

FILE_LINKS="$WORK_DIR/src_links.txt"

wget -O - $URL_SRC | grep $LAST_DAY > $FILE_LINKS
dos2unix $FILE_LINKS

if [ -f $FILE_LINKS -a -s $FILE_LINKS ]
then
	# Download the source files
	cd ${WORK_DIR}
	cat $FILE_LINKS | parallel --no-notice -j8 "wget -q {}"
	cd -
else
	echo "There were no files to download for date '${LAST_DAY}'. Try it again later."
	exit 2
fi
