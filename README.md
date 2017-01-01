# ETL

`ogr2ogr` version 2 or higher is expected to be available in `/usr/cadastre/bin/gdal` folder.

Source the `.env` files in `etc` folder before running any binaries.

## Cron jobs

Install crontab with `crontab etc/crontab.txt`.

- update RUIAN data on the second day of every month
- update RUIAN parcel data every day
- update landuse data on the second day of January, April, July and November

## Logging

Logging is done with [Papertrail](https://papertrailapp.com). Follow [the instructions](http://help.papertrailapp.com/kb/configuration/configuring-centralized-logging-from-text-log-files-in-unix/#remote_syslog) to install `remote_syslog` and [setup the service properly](https://github.com/papertrail/remote_syslog2/tree/master/examples).

Copy `logs/etc/log_files.yml` to `/etc/log_files.yml` before running `remote_syslog`.
