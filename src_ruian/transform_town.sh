#!/bin/bash

# Environment
export PG_USE_COPY=YES

# Input parameters
while [[ $# > 0 ]]
do
	key="$1"

	case $key in
    	-w|--work-dir)
			WORK_DIR="$2"
		    shift
		    ;;
    	--stage-schema)
			STAGE_SCHEMA="$2"
		    shift
		    ;;
	    *)
    		echo "Usage: `basename $0` --work-dir|-w [working_directory] --stage-schema [schema to load the data in]"
			exit 1
		    ;;
	esac
	shift
done

if [ "a$WORK_DIR" == "a" ]
then
	echo "Working directory is not set."
	exit 1
fi

if [ "a$STAGE_SCHEMA" == "a" ]
then
	echo "Stage schema is not set."
	exit 1
fi

if ! test -n "$(find ${WORK_DIR} -maxdepth 1 -name *_OB_*_UKSH.xml.gz -print -quit)"
then
	echo 'There were no files to import.'
	exit 3
fi
# /Input parameters

cat <<END | psql
	BEGIN;
	CREATE SCHEMA IF NOT EXISTS ${STAGE_SCHEMA};
	DROP TABLE IF EXISTS ${STAGE_SCHEMA}.obce;
	DROP TABLE IF EXISTS ${STAGE_SCHEMA}.katastralniuzemi;
	COMMIT;
END

BASEDIR=`dirname $0`

if [ $? -eq 0 ]
then
	LAST_DAY=`date -d "-$(date +%d) day" +%Y%m%d`

	for f in ${WORK_DIR}/*.xml.gz; do
		ogr2ogr -lco UNLOGGED=ON -lco SPATIAL_INDEX=NO -nlt CONVERT_TO_LINEAR -a_srs EPSG:5514 -sql "SELECT Kod, Nazev, OriginalniHranice, OkresKod FROM Obce" -append -gt 65000 -f "PostgreSQL" PG:"dbname=${PGDATABASE} user=${PGUSER} active_schema=${STAGE_SCHEMA}" $f
		ogr2ogr -lco UNLOGGED=ON -lco SPATIAL_INDEX=NO -nlt CONVERT_TO_LINEAR -a_srs EPSG:5514 -sql "SELECT Kod, Nazev, OriginalniHranice, ObecKod FROM KatastralniUzemi" -append -gt 65000 -f "PostgreSQL" PG:"dbname=${PGDATABASE} user=${PGUSER} active_schema=${STAGE_SCHEMA}" $f
	done
else
	echo 'Cannot import data, there were errors during the temporary schema creation.'
	exit 5
fi
