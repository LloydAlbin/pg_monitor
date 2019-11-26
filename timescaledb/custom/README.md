# tiemscaledb

TimescaleDB uses the PostgreSQL Alpine version by default without LDAP support. We need the LDAP support, so this directory contains the code to build both the PostgreSQL Alpine with LDAP support and then to build the TimescaleDB using this new PostgreSQL image.

* [TimescaelDB](https://www.timescale.com/products) - Timescale Database

Follow these instruction in your home directory:

```bash
cd ~

# Get the pg_monitor repositories
git clone https://github.com/LloydAlbin/pg_monitor.git

cd ~/pg_monitor/timescaledb/custom/

# Download, edit and build postgres repository
make postgres-new

# Delete postgres repository
make postgres-clean

# Update, edit and build postgres repository
make postgres

# Update, edit and build postgres repository, sending customer names to be used.
# ORG/PGNAME:VERSION # Postgres
# ORG/TSNAME:VERSION # TimescaleDB
make postgres ORG=xxx TSNAME=xxx PGNAME=xxx

```

You can also have these auto-created via a cronjob

```cron
0 0 0 Write Sample Here
```
