#!/bin/bash

# Input parameters
while [[ $# > 0 ]]
do
	key="$1"

	case $key in
    	--stage-schema)
			STAGE_SCHEMA="$2"
		    shift
		    ;;
    	--target-schema)
			TARGET_SCHEMA="$2"
		    shift
		    ;;
	    *)
    		echo "Usage: `basename $0` --stage-schema [stage schema] --target-schema [target schema]"
			exit 1
		    ;;
	esac
	shift
done

if [ "a$STAGE_SCHEMA" == "a" ]
then
	echo "Stage schema is not set."
	exit 1
fi

if [ "a$TARGET_SCHEMA" == "a" ]
then
	echo "Target schema is not set."
	exit 2
fi
# /Input parameters

cat <<END | psql
	BEGIN;

	TRUNCATE ${TARGET_SCHEMA}.region CASCADE;
	TRUNCATE ${TARGET_SCHEMA}.county CASCADE;

	INSERT INTO ${TARGET_SCHEMA}.region (
		code,
		name,
		geom
	)
	SELECT
		kod,
		nazev,
		wkb_geometry
	FROM ${STAGE_SCHEMA}.vusc;

	INSERT INTO ${TARGET_SCHEMA}.county (
		code,
		name,
		geom,
		region_code
	)
	SELECT
		kod,
		nazev,
		wkb_geometry,
		vusckod
	FROM ${STAGE_SCHEMA}.okresy;

	COMMIT;
END
