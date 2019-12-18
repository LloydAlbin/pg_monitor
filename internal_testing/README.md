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
* * * * Remote - WSL v0.41.6
* * * * systemd-unit-file v1.0.6
* * * * LDIF syntax v0.2.0
* * * Add WSL Extensions
* * * * Docker v0.9.0
* * * * Kubernetes v1.0.9
* * * * mardownlint v0.33.0
* * * * PostgreSQL v0.2.0
* * * * pgFormatter v1.10.0
* * * * C/C++ v0.26.2
* * * * C++ Intellisense v0.2.2
* * * * Cloud Code v1.0.1
* * * * YAML v0.6.1

[Windows Setup Directions](WINDOWS_SETUP.md)

## Testing

```bash
###### DELETE  ######
# Clean from previous builds
~/pg_monitor/timescaledb/custom/build_timescaledb.sh --clean

###### BUILD DOCKER IMAGES ######
# Build Postgres and TimescaleDB
~/pg_monitor/timescaledb/custom/build_timescaledb.sh -v -v -v -V --add pgtap
docker images

###### CLEANUP IN KUBERNETES ######
kubectl delete -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-service.yaml
kubectl delete -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-secret.yaml
kubectl delete -f ~/pg_monitor/timescaledb/custom/kubernetes/pg-monitor-timescaledb-deployment.yaml

###### INSTALL IN KUBERNETES ######
kubectl apply -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-service.yaml
kubectl apply -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-secret.yaml
kubectl apply -f ~/pg_monitor/timescaledb/custom/kubernetes/pg-monitor-timescaledb-deployment.yaml

###### TIMESCALEDB CLEANUP ######
# Cleanup from previous Timescale DB Testing
psql -h localhost -p 30002 -U postgres -d postgres -c "DROP DATABASE pgmonitor_db;"
psql -h localhost -p 30002 -U postgres -d postgres -c "DROP ROLE grafana;"

###### TIMESCALEDB SETUP ######
# Init TimescaleDB
psql -h localhost -p 30002 -U postgres -d postgres -f ~/pg_monitor/timescaledb/init_timescaledb.sql
# Setup account with password
psql -h localhost -p 30002 -U postgres -d postgres -c "ALTER ROLE grafana WITH PASSWORD 'pgpass';"

###### PGTAP ######
# Must change directories to tune the pgtap tests.
cd ~/pg_monitor/pgtap_tests/
# Run the all the pgtap tests in the pgtap_tests directory
pg_prove -v -h localhost -p 30002 -U postgres -d postgres .
```
