# Local Development and Testing

## Setup Local Development Environment

This is the testing that I have done inhouse before publishing to github/travis-ci.

In this build/testing environment I am using the following:

* Windows 10
* * Windows Docker
* * * Windows Kubernetes
* * Windows Subsystem Linux
* * * WSL Ubuntu 18
* * Visual Studio Code
* * * Add Local Extensions
* * * * Remote - WSL
* * * * systemd-unit-file
* * * Add WSL Extensions
* * * * Docker
* * * * mardownlint
* * * * PostgreSQL

[Windows Setup Directions](WINDOWS_SETUP.md)

## Testing

```bash
# Verify Postgres Version and Connection
psql -h localhost -U postgres -d postgres -p 30002 -c 'SELECT version();'
# Reset from previous Test
psql -h localhost -U postgres -d postgres -p 30002 -c "DROP DATABASE pgmonitor_db; DROP ROLE grafana;"
# Install pg_monitor sql
psql -h localhost -U postgres -d postgres -p 30002 -f ~/pg_monitor/timescaledb/init_timescaledb.sql
psql -h localhost -U postgres -d postgres -p 30002 -c "ALTER ROLE grafana WITH PASSWORD 'pgpass';"
#- psql -h localhost -p 30002 -d postgres -U postgres -f ~/build/LloydAlbin/pg_monitor/grafana/pg_monitor_timescaledb_init.sql
# Must change directories to tune the pgtap tests.
cd ~/pg_monitor/pgtap_tests/
# Run the all the pgtap tests in the pgtap_tests directory
pg_prove -v -d postgres -h localhost -U postgres -p 30002 .
```
