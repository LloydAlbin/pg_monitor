# pg_readlog

This script monitors the log files every 10 seconds and to shove them into the PostgreSQL TimescaleDB database. If the database can't be contacted, it will hold the records until the database can be contacted. This allows you to perform database maintaince on the TimescaleDB database without having to shutdown the pg_readlog on all your servers.

## Setup

You need to edit one of the following three files depending on how you are going to start this script.

* start_pg_readlog.sh (Manually start and stop service):
* start_pg_readlog (Automatically start and stop init.d script):
* pg_readlog.service (Automatically start and stop service):

Edits that you need to make:

* Replace the (ClusterName) with the hostname of the logfiles that you are monitoring.
* Replace the (ReportsServer) with the hostname of the PostgreSQL TimescaleDB.
* Replace the pgmonitor_db with the database on the PostgreSQL TimescaleDB.
* Replace the 30002 with the port of the PostgreSQL TimescaleDB.
* Replace the /pgdata_local/pg_log with the location of the PostgreSQL log files.
* Replace the /pgdata_local with the location of the temporay location of the logtail csv file.
* Replace the /usr/local/postgres-current/bin with the location of the PostgreSQL binary file location.

### Start as Shell Script

```bash
cp ~/pg_monitor/pg_readlog/start_pg_readlog.sh /pgdata_local/
cp ~/pg_monitor/pg_readlog/pg_readlog.sh /pgdata_local/
chmod 755 /pgdata_local/start_pg_readlog.sh
chmod 755 /pgdata_local/pg_readlog.sh
cd /pgdata_local/
./start_pg_readlog.sh
```

### Start as Init

```bash
# TODO: Write start_pg_readlog
cp ~/pg_monitor/pg_readlog/start_pg_readlog /etc/init.d/start_pg_readlog
cp ~/pg_monitor/pg_readlog/pg_readlog.sh /pgdata_local/
chmod 755 /pgdata_local/pg_readlog.sh
chmod 755 /etc/init.d/start_pg_readlog
/etc/init.d/start_pg_readlog start
/etc/init.d/start_pg_readlog stop
/etc/init.d/start_pg_readlog status
# TODO: Add command to auto starting and stopping
```

### Start as Service

```bash
cp ~/pg_monitor/pg_readlog/pg_readlog.service /etc/systemd/system/pg_readlog.service
cp ~/pg_monitor/pg_readlog/pg_readlog.sh /pgdata_local/
chmod 755 /pgdata_local/pg_readlog.sh
sudo systemctl enable pg_readlog
sudo systemctl start pg_readlog
# TODO: Add command to auto starting and stopping
```

## Notes

If you stop pg_readlog for more than two hours, you will have missing information. Just remember to exclude the current hours log file and the previous hours log file as they will be processed automatically. The following commands will load the unprocessed log files into the queue to be processed.  

```bash
# If you have postgresql-2019-10-23_00.csv.offset:
logtail postgresql-2019-10-23_00.csv >> /pgdata_local/logtail.csv

# If there is no .offset file:
zcat postgresql-2019-10-23_00.csv.gz postgresql-2019-10-23_01.csv.gz >> /pgdata_local/logtail.csv
cat  postgresql-2019-10-23_00.csv postgresql-2019-10-23_01.csv >> /pgdata_local/logtail.csv
cat  postgresql-2019-10-22_*.csv postgresql-2019-10-23_0*.csv postgresql-2019-10-23_10.csv >> /pgdata_local/logtail.csv
```

## Postgres Password

This script relies on you either having the [PGPASSWORD environment variable](https://www.postgresql.org/docs/11/libpq-envars.html) set or having a [.pgpass file](https://www.postgresql.org/docs/11/libpq-pgpass.html) in the postgres home directory.
