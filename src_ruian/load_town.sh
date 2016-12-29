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

	TRUNCATE ${TARGET_SCHEMA}.municipality CASCADE;
	TRUNCATE ${TARGET_SCHEMA}.area CASCADE;
	TRUNCATE ${TARGET_SCHEMA}.parcel CASCADE;

	INSERT INTO ${TARGET_SCHEMA}.municipality (
		code,
		name,
		geom,
		county_code
	)
	SELECT
		kod,
		nazev,
		ST_Multi(wkb_geometry),
		okreskod
	FROM ${STAGE_SCHEMA}.obce;

	INSERT INTO ${TARGET_SCHEMA}.area (
		code,
		name,
		geom,
		municipality_code
	)
	SELECT
		kod,
		nazev,
		ST_Multi(wkb_geometry),
		obeckod
	FROM ${STAGE_SCHEMA}.katastralniuzemi;

	INSERT INTO ${TARGET_SCHEMA}.parcel (
		id,
		root_number,
		part_number,
		area,
		geom,
		area_code
	)
	SELECT
		id,
		kmenovecislo,
		pododdelenicisla,
		vymeraparcely,
		ST_Multi(wkb_geometry),
		katastralniuzemikod
	FROM ${STAGE_SCHEMA}.parcely;

	COMMIT;
END