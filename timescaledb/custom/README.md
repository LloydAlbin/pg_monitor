# tiemscaledb

TimescaleDB uses the PostgreSQL Alpine version by default without LDAP support. We need the LDAP support, so this directory contains the code to build both the PostgreSQL Alpine with LDAP support and then to build the TimescaleDB using this new PostgreSQL image.

* [TimescaelDB](https://www.timescale.com/products) - Timescale Database

Download the pg_monitor into your home directory. The make file will also put the postgres and timescaledb-docker repositories into your home directory.

```bash
cd ~
# Get the pg_monitor repositories
git clone https://github.com/LloydAlbin/pg_monitor.git
```

To run the make command, you need to be inside this directory (~/pg_monitor/timescaledb/custom/).

The make command takes three optional options:
* ORG
* TSNAME
* PGNAME

These options help define the docker image names in this format:

* ORG/PGNAME:VERSION aka lloydalbin/postgres:11-alpine
* ORG/TSNAME:VERSION aka lloydalbin/timescaledb:1.5.1-pg11

If you have your own inhouse docker registery, then the ORG name should be the name of your inhouse docker registry.

The first time, you need to run special "new" commands so that the repositories can be downloaded.

```bash
cd ~/pg_monitor/timescaledb/custom/

# For the first time use the "-new" to download the repositories needed.
make new
# Using the optional arguments
make new ORG=lloydalbin TSNAME=timescaledb PGNAME=postgres
# Optional: Just Postgres
make postgres-new
# Optional: Just TimescaleDB
make timescale-new
```

To check for updates you can use use make.

```bash
cd ~/pg_monitor/timescaledb/custom/
# Update, edit and build postgres repository and then the timescale repository
make
# Optional: Just Postgres
make postgres
# Optional: Just TimescaleDB
make timescaledb
```

If you wish to delete the repositories, you may do so manually or you can use the make command to clean up the postgres & timescaledb-docker repositories.

```bash
cd ~/pg_monitor/timescaledb/custom/
# Delete repositories
make clean
# Optional: Just Postgres
make postgres-clean
# Optional: Just TimescaleDB
make timescale-clean
```

You can also have these auto-created via a cronjob on an hourly basis.

```cron
# With default arguments
* 0 * * * $HOME/pg_monitor/timescaledb/custom/make
# With optional arguments
* 0 * * * $HOME/pg_monitor/timescaledb/custom/make ORG=lloydalbin TSNAME=timescaledb PGNAME=postgres
```
