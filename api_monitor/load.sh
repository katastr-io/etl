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

DATE=$(date -d "${FILE%%.csv}" '+%Y-%m-%d')

cat <<END | psql --no-psqlrc -qAt
    DROP TABLE IF EXISTS "stg_data";
    CREATE TABLE "stg_data" (
        code integer,
        name text,
        total_count integer,
        total_area numeric,
        arable_land_count integer,
        arable_land_area integer,
        hop_garden_count integer,
        hop_garden_area integer,
        vineyard_count integer,
        vineyard_area integer,
        garden_count integer,
        garden_area integer,
        orchard_count integer,
        orchard_area integer,
        grassland_count integer,
        grassland_area integer,
        forest_count integer,
        forest_area integer,
        waterbody_count integer,
        waterbody_area integer,
        builtup_area_count integer,
        builtup_area_area integer,
        other_area_count integer,
        other_area_area integer
    );
END

psql --no-psqlrc -qAt -c "COPY stg_data FROM STDIN WITH (FORMAT CSV, DELIMITER ';', ENCODING 'WINDOWS-1250')" < $FILE
psql --no-psqlrc -qAt -c "ALTER TABLE stg_data ADD COLUMN valid_at date DEFAULT '${DATE}'"

cat <<END | psql --no-psqlrc -qAt
    DELETE FROM area_statistics WHERE valid_at = '${DATE}';
    INSERT INTO api_monitor.area_statistics (
        code,
        name,
        valid_at,
        total_count,
        total_area,
        arable_land_count,
        arable_land_area,
        hop_garden_count,
        hop_garden_area,
        vineyard_count,
        vineyard_area,
        garden_count,
        garden_area,
        orchard_count,
        orchard_area,
        grassland_count,
        grassland_area,
        forest_count,
        forest_area,
        waterbody_count,
        waterbody_area,
        builtup_area_count,
        builtup_area_area,
        other_area_count,
        other_area_area
    )
    SELECT
        code,
        name,
        valid_at,
        total_count,
        total_area,
        arable_land_count,
        arable_land_area,
        hop_garden_count,
        hop_garden_area,
        vineyard_count,
        vineyard_area,
        garden_count,
        garden_area,
        orchard_count,
        orchard_area,
        grassland_count,
        grassland_area,
        forest_count,
        forest_area,
        waterbody_count,
        waterbody_area,
        builtup_area_count,
        builtup_area_area,
        other_area_count,
        other_area_area
    FROM stg_data;
END