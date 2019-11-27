# TimescaleDB

TimescaleDB uses the PostgreSQL Alpine version by default without LDAP support. We need the LDAP support, so this directory contains the code to build both the PostgreSQL Alpine with LDAP support and then to build the TimescaleDB using this new PostgreSQL image.

* [TimescaelDB](https://www.timescale.com/products) - Timescale Database

Download the pg_monitor repository. The make file will also put the postgres and timescaledb-docker repositories into your home directory by default unless you use the location argument.

```bash
cd ~
# Get the pg_monitor repositories
git clone https://github.com/LloydAlbin/pg_monitor.git
```

To run the make command, you need to be inside this directory (~/pg_monitor/timescaledb/custom/).

The make command takes some optional options:
* org
* ts_name
* pg_name
* location
* push
* clean
* postgres
* timescaledb

These options help define the docker image names in this format:

* org/pg_name:VERSION aka lloydalbin/postgres:11-alpine
* org/ts_name:VERSION aka lloydalbin/timescaledb:1.5.1-pg11
* location aka ~ meaning ~/postgres and ~/timescaledb-docker for the two repositories needed to be downloaded
* --push aka push docker image(s) to the repsoitory
* --clean aka delete the two repositories
* --postgres aka build only postgres
* --timescaledb aka build only timescaledb

If you have your own inhouse docker registery, then the ORG name should be the name of your inhouse docker registry.

The build script will download the postgres and timescaledb-docker repositories.

```bash
# For the first time use the "-new" to download the repositories needed.
~/pg_monitor/timescaledb/custom/build_timescaledb.sh
# Using the optional arguments
~/pg_monitor/timescaledb/custom/build_timescaledb.sh --org=lloydalbin --ts_name=timescaledb --pg_name=postgres
```

If you wish to delete the repositories, you may do so manually or you can use the make command to clean up the postgres & timescaledb-docker repositories.

```bash
# Delete repositories
~/pg_monitor/timescaledb/custom/build_timescaledb.sh --clean
# Optional: Just Postgres
~/pg_monitor/timescaledb/custom/build_timescaledb.sh --clean --postgres
# Optional: Just TimescaleDB
~/pg_monitor/timescaledb/custom/build_timescaledb.sh --clean --timescaledb
```

You can also have these auto-created via a cronjob on an hourly basis.

```cron
# With default arguments
* 0 * * * $HOME/pg_monitor/timescaledb/custom/build_timescaledb.sh
# With optional arguments
* 0 * * * $HOME/pg_monitor/timescaledb/custom/build_timescaledb.sh --org=lloydalbin --ts_name=timescaledb --pg_name=postgres
```
