# ETL

`ogr2ogr` version 2 or higher is expected to be available in `/usr/cadastre/bin/gdal` folder.

Source the `.env` files in `etc` folder before running any binaries.

## Cron jobs

Install crontab with `crontab etc/crontab.txt`.

- update RUIAN data on the second day of every month
- update RUIAN parcel data every day
- update landuse data on the second day of January, April, July and November
