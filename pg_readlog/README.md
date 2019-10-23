# pg_readlog
This is the scripts required to monitor the log files every 10 seconds and to shove them into the PostgreSQL TimescaleDB database.

Edits that you need to make:
* start_pg_readlog.sh (Manually start and stop service):
* * Replace the db-delphi with the hostname of the logfiles that you are monitoring.
* * Replace the kw-alpha-m03.pc.scharp.org with the hostname of the PostgreSQL TimescaleDB.
* * Replace the reports with the database on the PostgreSQL TimescaleDB.
* * Replace the 30002 with the port of the PostgreSQL TimescaleDB.
* * Replace the /pgdata_local/pg_log with the location of the PostgreSQL log files.
* * Replace the /pgdata_local with the location of the temporay location of the logtail csv file.
* * Replace the /usr/local/postgres-current/bin with the location of the PostgreSQL binary file location.
* pg_readlog.service (Automatically start and stop service):
* * Replace the db-delphi with the hostname of the logfiles that you are monitoring.
* * Replace the kw-alpha-m03.pc.scharp.org with the hostname of the PostgreSQL TimescaleDB.
* * Replace the reports with the database on the PostgreSQL TimescaleDB.
* * Replace the 30002 with the port of the PostgreSQL TimescaleDB.
* * Replace the /pgdata_local/pg_log with the location of the PostgreSQL log files.
* * Replace the /pgdata_local with the location of the temporay location of the logtail csv file.
* * Replace the /usr/local/postgres-current/bin with the location of the PostgreSQL binary file location.

If you stop pg_readlog for more than two hours, you will have missing information. Just remember to exclude the current hours log file and the previous hours log file as they will be processed automatically. The following commands will lod the unprocessed log files into the queue to be processed.  

```bash
# If you have postgresql-2019-10-23_00.csv.offset:
logtail postgresql-2019-10-23_00.csv >> /pgdata_local/logtail.csv

# If there is no .offset file:
zcat postgresql-2019-10-23_00.csv.gz postgresql-2019-10-23_01.csv.gz >> /pgdata_local/logtail.csv
cat  postgresql-2019-10-23_00.csv postgresql-2019-10-23_01.csv >> /pgdata_local/logtail.csv
cat  postgresql-2019-10-22_*.csv postgresql-2019-10-23_0*.csv postgresql-2019-10-23_10.csv >> /pgdata_local/logtail.csv
```
