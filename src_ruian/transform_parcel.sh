#!/bin/bash

# Environment
export PG_USE_COPY=YES
BASEDIR=`dirname $0`

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

if ! test -n "$(find ${WORK_DIR} -maxdepth 1 -name *.zip -print -quit)"
then
	echo 'There were no files to import.'
	exit 3
fi
# /Input parameters

cat <<END | psql -qAt --no-psqlrc
	BEGIN;
	CREATE SCHEMA IF NOT EXISTS ${STAGE_SCHEMA};
	DROP TABLE IF EXISTS ${STAGE_SCHEMA}.cadastralparcel;
	COMMIT;
END

if [ $? -eq 0 ]
then
    for f in ${WORK_DIR}/*.zip
    do
        unzip $f -d ${WORK_DIR}
        cp ${BASEDIR}/share/cadastralparcel.gfs ${f%%.zip}.gfs
        ogr2ogr -lco UNLOGGED=ON -lco SPATIAL_INDEX=NO -nlt CONVERT_TO_LINEAR -a_srs EPSG:5514 -sql "SELECT gml_id, label, areaValue, nationalCadastralReference FROM CadastralParcel" -append -gt 65000 -f "PostgreSQL" PG:"dbname=${PGDATABASE} user=${PGUSER} active_schema=${STAGE_SCHEMA}" ${f%%.zip}.xml
		rm -f $f ${f%%.zip}.xml ${f%%.zip}.gfs
    done
fi