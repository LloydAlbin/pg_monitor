# readlog
This is the scripts required to monitor the log files every 10 seconds and to shove them into the PostgreSQL TimescaleDB database.

Edits that you need to make:
* start_readlog.sh:
* * Replace the db-delphi with the hostname of the logfiles that youa re monitoring.
* pg_readlog.sh:
* * You need to update the Postgres Settings for the connection to the PostgreSQL TimescaleDB.
* * * -h hostname
* * * -d database
* * * -p port
* * Update the logfile location /pgdata_local/pg_log/
* * Update the logtail.srv logfile location /pgdata_local/
* * Update the pgsql location /usr/local/postgres-current/bin/psql
