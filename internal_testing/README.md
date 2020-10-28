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
###### DELETE GITHUB DATA ######
# Clean from previous builds before building, otherwise patching issues
~/pg_monitor/timescaledb/custom/build_timescaledb.sh --clean

###### BUILD DOCKER IMAGES ######
# Build Postgres and TimescaleDB Docker Images
~/pg_monitor/timescaledb/custom/build_timescaledb.sh -v -v -v -V --add pgtap --add tds
# Build for secific Postgres version and current TimescaleDB Docker Images
# You will also need to update the pg-monitor-timescaledb-deployment.yaml to specify this same Postgres version
~/pg_monitor/timescaledb/custom/build_timescaledb.sh -v -v -v -V --add pgtap --add tds --pgv pg11
~/pg_monitor/timescaledb/custom/build_timescaledb.sh -v -v -v -V --add pgtap --add tds --pgv pg12
# Build for current Postgres and secific TimescaleDB version
# You will also need to update the pg-monitor-timescaledb-deployment.yaml to specify this same TimescaleDB version
~/pg_monitor/timescaledb/custom/build_timescaledb.sh -v -v -v -V --add pgtap --add tds --tsv HEAD
~/pg_monitor/timescaledb/custom/build_timescaledb.sh -v -v -v -V --add pgtap --add tds --tsv 1.6.0
# Rebuild TimescaleDB Docker Images
~/pg_monitor/timescaledb/custom/build_timescaledb.sh -v -v -v -V --timescaledb
docker images
# Optional: cleanup dangling images, etc.
docker system prune -f

###### CLEANUP IN KUBERNETES ######
# Delete Service, Secret and Deployment in Kubernetes
kubectl delete -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-service.yaml
kubectl delete -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-secret.yaml
kubectl delete -f ~/pg_monitor/timescaledb/custom/kubernetes/pg-monitor-timescaledb-deployment.yaml

###### INSTALL IN KUBERNETES ######
# Add Service, Secret and Deployment in Kubernetes
kubectl apply -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-service.yaml
kubectl apply -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-secret.yaml
kubectl apply -f ~/pg_monitor/timescaledb/custom/kubernetes/pg-monitor-timescaledb-deployment.yaml

###### TIMESCALEDB CLEANUP ######
# Cleanup from previous Timescale DB Testing
psql -h localhost -p 30002 -U postgres -d postgres -c "DROP DATABASE pgmonitor_db;"
psql -h localhost -p 30002 -U postgres -d postgres -c "DROP ROLE grafana;"

###### TIMESCALEDB SETUP ######
# Init TimescaleDB
psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d postgres -f ~/pg_monitor/timescaledb/init_timescaledb.sql
# Setup account with password
psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d postgres -c "ALTER ROLE grafana WITH PASSWORD 'pgpass';"
# Make the COntinous Aggregates very aggressive
# Skip if TimescaleDB 2.0.0 or later
psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d pgmonitor_db -f ~/pg_monitor/pgtap_tests/common/make_aggregates_fast.sql
# Remove Compresses Chunks Policy
# for TimescaleDB 1.7.4 and older
psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d pgmonitor_db -c "SELECT public.remove_compress_chunks_policy((schema_name || '.' || table_name)::regclass) FROM tools.hypertables;"
# Make the Continous Aggregate capture everything right away for testing.
#psql -h localhost -p 30002 -U postgres -d pgmonitor_db -f ~/pg_monitor/pgtap_tests/common/continous_aggregate_refresh_interval_now.sql
# Load Test Data
cat ~/pg_monitor/pgtap_tests/logs/pglog_db1.csv | psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d pgmonitor_db -q -c "CREATE TEMP TABLE upload_logs (LIKE logs.postgres_log);ALTER TABLE upload_logs ALTER COLUMN cluster_name SET DEFAULT 'db1';COPY upload_logs (log_time,user_name,database_name,process_id,connection_from,session_id,session_line_num,command_tag,session_start_time,virtual_transaction_id,transaction_id,error_severity,sql_state_code,message,detail,hint,internal_query,internal_query_pos,context,query,query_pos,location,application_name) FROM STDIN (FORMAT CSV);INSERT INTO logs.postgres_log SELECT * FROM upload_logs;"
cat ~/pg_monitor/pgtap_tests/logs/pglog_db2.csv | psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d pgmonitor_db -q -c "CREATE TEMP TABLE upload_logs (LIKE logs.postgres_log);ALTER TABLE upload_logs ALTER COLUMN cluster_name SET DEFAULT 'db2';COPY upload_logs (log_time,user_name,database_name,process_id,connection_from,session_id,session_line_num,command_tag,session_start_time,virtual_transaction_id,transaction_id,error_severity,sql_state_code,message,detail,hint,internal_query,internal_query_pos,context,query,query_pos,location,application_name) FROM STDIN (FORMAT CSV);INSERT INTO logs.postgres_log SELECT * FROM upload_logs;"
# Add Compresses Chunks Policy - This is not done in the Travis tests
# for TimescaleDB 1.7.4 and older
psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d pgmonitor_db -c "SELECT public.add_compress_chunks_policy((schema_name || '.' || table_name)::regclass, compress_chunk_policy) FROM tools.hypertables;"
# for TimescaleDB 1.7.4 and older
psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d pgmonitor_db -c "SELECT pg_sleep(5);SELECT alter_job_schedule(job_id, next_start=>now()) FROM _timescaledb_config.bgw_policy_compress_chunks p INNER JOIN _timescaledb_catalog.hypertable h ON (h.id = p.hypertable_id);"
# Refresh the Continous Aggregate so they have the latest data
# for TimescaleDb 1.7.4 and older
psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d pgmonitor_db -f ~/pg_monitor/pgtap_tests/common/refresh_aggregates.sql
# for TimescaleDB 2.0.0 and newer
psql -v ON_ERROR_STOP=1 -h localhost -p 30002 -U postgres -d pgmonitor_db -f ~/pg_monitor/pgtap_tests/common/refresh_aggregates_2.sql

###### pg_monitor ######
python3 ~/pg_monitor/pg_monitor/pg_monitor.py -h localhost -p 30002 -U grafana -W pgpass -vvv

###### PGTAP ######
# Must change directories to tune the pgtap tests.
cd ~/pg_monitor/pgtap_tests/
# Run the all the pgtap tests in the pgtap_tests directory
pg_prove -v -h localhost -p 30002 -U postgres -d postgres .
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
