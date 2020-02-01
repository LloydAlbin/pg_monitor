# pgtap Unit Testing

## Running pgtap on the loaded database

When updating the pgmonitor_db, it is wise to make sure you have not broken anything and unit testing will help keep that from happening.

The unit testing allows us to insert data and make sure that the function we write, come back with the results we expect.

When someone reports a problem, a new test should be written to test cause the problem with the test failing. Then update the code in the database and if it work, then the unit test should now pass. When adding new tests, just use the next number in the series.

You first need to load the database, see [Loading the starting database](../timescaledb/README.md)

```bash
cd ~/pg_monitor/pgtap_tests
pg_prove -h localhost -p 30002 -d pgmonitor_db -U postgres *.pg
```

## Updating the 02_generated_pgtap.pg file

While I recommend adding the new tests as you write the new tables/views/functions in the pgmonitor_db. But for the first time after the database was already build, I created this script to generate the first pass for the basic tests without data.

```bash
cd ~/pg_monitor/pgtap_tests
psql -h localhost -p 30002 -d pgmonitor_db -U postgres -c 'CREATE EXTENSION IF NOT EXISTS pgtap;'
psql -h localhost -p 30002 -d pgmonitor_db -U postgres -f common/update_pgtap.sql
psql -h localhost -p 30002 -d pgmonitor_db -U postgres -f generation/generate_pgtap.sql
psql -h localhost -p 30002 -d pgmonitor_db -U postgres -qAtX -c 'SELECT * FROM tools.generate_pgtap();' -o 02_generated_pgtap.pg
psql -h localhost -p 30002 -d pgmonitor_db -U postgres -c 'DROP EXTENSION IF EXISTS pgtap;'
```

## Testing Upgrade of Database

In this test we will load V1 of the database and then run the upgrade script. Finally we will unit test the final database to make sure it matches a fresh load of the current database configuration.

```bash
# If re-testing, get rid of our test databases
dropdb -h localhost -p 30002 -U postgres reports
dropdb -h localhost -p 30002 -U postgres pgmonitor_db

# Create the grafana user, first time only
psql -h localhost -d postgres -p 30002 -U postgres -c "CREATE ROLE grafana WITH PASSWORD 'pgpass' IN ROLE pg_monitor;"

# Create database, Install V1 and then run the Upgrade
createdb -h localhost -p 30002 -U postgres -E UTF8 -O grafana reports
psql -h localhost -p 30002 -d reports -U postgres -f ~/pg_monitor/timescaledb/init_timescaledb_v1.sql
psql -h localhost -p 30002 -d postgres -U postgres -f ~/pg_monitor/timescaledb/upgrade_timescaledb.sql

# Install pgtap and our custom modifications
psql -h localhost -p 30002 -d pgmonitor_db -U postgres -c 'CREATE EXTENSION IF NOT EXISTS pgtap;'
psql -h localhost -p 30002 -d pgmonitor_db -U postgres -f ~/pg_monitor/pgtap_tests/common/update_pgtap.sql

# Run the pgtap tests and then fix anything that has not been upgraded properly.
cd ~/pg_monitor/pgtap_tests
pg_prove -h localhost -p 30002 -d pgmonitor_db -U postgres *.pg
```
