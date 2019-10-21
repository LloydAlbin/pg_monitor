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
