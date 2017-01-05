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

	TRUNCATE ${TARGET_SCHEMA}.parcel CASCADE;

	DROP INDEX IF EXISTS ${TARGET_SCHEMA}.parcel_geom_idx;
	ALTER TABLE ${TARGET_SCHEMA}.parcel DROP CONSTRAINT parcel_pkey;

	INSERT INTO ${TARGET_SCHEMA}.parcel (
		id,
		label,
		area,
		geom,
		area_code
	)
	SELECT
		replace(cp.gml_id, 'CP.', '')::bigint,
		cp.label,
		cp.areavalue::integer,
		ST_Multi(cp.wkb_geometry),
        substring(cp.nationalcadastralreference from 0 for 7)::integer
	FROM ${STAGE_SCHEMA}.cadastralparcel cp
    JOIN ${TARGET_SCHEMA}.area a ON (substring(cp.nationalcadastralreference from 0 for 7)::integer = a.code);

	CREATE INDEX ON ${TARGET_SCHEMA}.parcel USING gist (geom);
	ALTER TABLE ${TARGET_SCHEMA}.parcel ADD PRIMARY KEY (id);

	COMMIT;
END