# Local Development and Testing

## Setup Local Development Environment

This is the testing that I have done inhouse before publishing to github/travis-ci.

In this build/testing environment I am using the following:

* Windows 10
  * Windows Docker
    * Windows Kubernetes
  * Windows Subsystem Linux
    * WSL Ubuntu 18
  * Visual Studio Code
    * Add Local Extensions
      * Remote - WSL v0.41.6
      * systemd-unit-file v1.0.6
      * LDIF syntax v0.2.0
    * Add WSL Extensions
      * Docker v0.9.0
      * Kubernetes v1.0.9
      * mardownlint v0.33.0
      * PostgreSQL v0.2.0
      * pgFormatter v1.10.0
      * C/C++ v0.26.2 *(Not needed for this project)*
      * C++ Intellisense v0.2.2 *(Not needed for this project)*
      * Cloud Code v1.0.1 *(Not needed for this project)*
      * YAML v0.6.1

[Windows Setup Directions](WINDOWS_SETUP.md)

## Testing Clean Install

```bash
###### CLONE REPOSITORIES ######
git clone https://github.com/LloydAlbin/postgres-docker.git ~/postgres-docker
git clone https://github.com/LloydAlbin/timescaledb-docker.git ~/lloydalbin-timescaledb-docker
git clone https://github.com/LloydAlbin/pg_monitor.git ~/pg_monitor

###### DELETE GITHUB DATA ######
# Clean from previous builds before building, otherwise patching issues
~/postgres-docker/build_postgres.sh -v -v -v -V --clean
~/lloydalbin-timescaledb-docker/build_timescaledb.sh -v -v -v -V --clean

###### BUILD DOCKER IMAGES ######
# tsv - pgv
#1.5.0-1.5.1 - pg11, pg10, pg9.6
#1.6.0-1.6.1 - pg11, pg10, pg9.6
#1.7.0-1.7.4 - pg12, pg11, pg10, pg9.6
#2.0.0-rc1-2.0.x - pg12, pg11
# Build Postgres and TimescaleDB Docker Images
~/postgres-docker/build_postgres.sh -v -v -v -V --add all --clean --override_exit  -pgv $PGVERSION --org $DOCKER_ORG --pg_name $DOCKER_IMAGE_NAME
# Build Postgres and TimescaleDB Docker Images
~/lloydalbin-timescaledb-docker/build_timescaledb.sh -v -v -v -V --clean --override_exit -pgv $PGVERSION --org $DOCKER_ORG --pg_name $DOCKER_IMAGE_NAME_POSTGRES --ts_name $DOCKER_IMAGE_NAME_TIMESCALE

# Show your docker images
docker images
# Optional: cleanup dangling images, etc.
# You can do this by specifying a second --clean when using build_postgres.sh or build_timescaledb.sh
docker system prune -f

###### TEST PG_MONITOR IN KUBERNETES ######
~/pg_monitor/internal_testing/test_timescaledb.sh -V -v -v -v -tsv 1.5.1 -pgv pg9.6
# Example for using in Travis
# ~/pg_monitor/internal_testing/test_timescaledb.sh -V -v -v -v --location ~/build/LloydAlbin -tsv 1.5.1 -pgv pg9.6

###### TIMESCALEDB CLEANUP ######
~/pg_monitor/internal_testing/test_timescaledb.sh -V -v -v -v --clean

###### TIMESCALEDB SETUP ######
# After make_aggregates_fast.sql
# Remove Compresses Chunks Policy
# for TimescaleDB 1.7.4 and older
psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d pgmonitor_db -c "SELECT public.remove_compress_chunks_policy((schema_name || '.' || table_name)::regclass) FROM tools.hypertables;"
# Make the Continous Aggregate capture everything right away for testing.
#psql -h localhost -p 30002 -U postgres -d pgmonitor_db -f ~/pg_monitor/pgtap_tests/common/continous_aggregate_refresh_interval_now.sql

###### TIMESCALEDB SETUP ######
# Load Test Data
# Add Compresses Chunks Policy - This is not done in the Travis tests
# for TimescaleDB 1.7.4 and older
psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d pgmonitor_db -c "SELECT public.add_compress_chunks_policy((schema_name || '.' || table_name)::regclass, compress_chunk_policy) FROM tools.hypertables;"
# for TimescaleDB 1.7.4 and older
psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d pgmonitor_db -c "SELECT pg_sleep(5);SELECT alter_job_schedule(job_id, next_start=>now()) FROM _timescaledb_config.bgw_policy_compress_chunks p INNER JOIN _timescaledb_catalog.hypertable h ON (h.id = p.hypertable_id);"
```

## Testing Upgrade Install

```bash
###### TIMESCALEDB CLEANUP ######
# Cleanup from previous Timescale DB Testing
psql -h localhost -p 30002 -U postgres -d postgres -c "DROP DATABASE pgmonitor_db;"
psql -h localhost -p 30002 -U postgres -d postgres -c "DROP DATABASE reports;"

###### TIMESCALEDB SETUP ######
# Init TimescaleDB
createdb  -h localhost -p 30002 -U postgres -E UTF8 reports
psql -h localhost -p 30002 -U postgres -d reports -f ~/pg_monitor/timescaledb/init_timescaledb_v1.sql
psql -h localhost -p 30002 -U postgres -d postgres -f ~/pg_monitor/timescaledb/upgrade_timescaledb.sql

###### PGTAP ######
# Must change directories to tune the pgtap tests.
cd ~/pg_monitor/pgtap_tests/
# Run the all the pgtap tests in the pgtap_tests directory
pg_prove -v -h localhost -p 30002 -U postgres -d postgres .
```
