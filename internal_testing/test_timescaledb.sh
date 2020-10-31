#!/bin/bash

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
ORG="lloydalbin"
TS_NAME="timescaledb"
TS_VER="2.0.0-rc2"
PG_VER="pg12"
verbose=0
version=0
PG_PORT=30002
PG_SERVER=localhost
clean=0
build_location=~

# Usage info
show_help()
{
	cat << EOF
Usage: ${0##*/} [-hv] [-o ORGANIZATION]
    -h/--help                   display this help and exit
    -o/--org ORGANIZATION       insert the organization name into the docker name ORGANIZATION/NAME:VERSION - Default: $ORG
    -tn/--ts_name NAME          insert the TimescaleDB name into the docker name ORGANIZATION/NAME:VERSION - Default: $TS_NAME
    -v                          verbose mode. Can be used multiple times for increased verbosity
	--location					root repository location - Default: $build_location
    -V/--version                show version information
    -pgv/--pgversion VERSION    Overrides the default PostgreSQL version. - Default: $PG_VER
    -tsv/--tsversion VERSION    Overrides the default TimescaleDB version. - Default: $TS_VER
    --clean                     Remove Kubernetes items

EOF
}

# Version Info
version_info()
{
	cat << EOF
test_timescaledb.sh 0.01
Copyright (C) 2019-2020 Fred Hutchinson Cancer Research Center
License Apache-2.0: Apache version 2 or later.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Lloyd Albin

EOF
}

die() 
{
	printf '%s\n' "$1" >&2
	exit 1
}

print_verbose()
{
	if [ $verbose -ge $1 ]; then
		echo "$2"
	fi
}

prep_kubernetes()
{
	###### MAKE COPIES OF KUBERNETES FILE AND TWEEK BASED ON OPTIONAL ARGS ######
	# Copy and modify Service, Secret and Deployment in Kubernetes

	print_verbose 2 "Prep Kubernetes Files"

	mkdir -p $build_location/pg_monitor/build_test

	# TimescaleDB
	cp $build_location/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-service.yaml $build_location/pg_monitor/build_test/pg-monitor-timescaledb-service.yaml
	cp $build_location/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-secret.yaml  $build_location/pg_monitor/build_test/pg-monitor-timescaledb-secret.yaml
	cp $build_location/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-deployment.yaml $build_location/pg_monitor/build_test/pg-monitor-timescaledb-deployment.yaml
	sed -r -i "s/[a-zA-Z]+\/[a-zA-Z]+:[0-9a-z.\-]+-pg[0-9.]{2}$/${ORG}\/${TS_NAME}:${TS_VER}-${PG_VER}/g" $build_location/pg_monitor/build_test/pg-monitor-timescaledb-deployment.yaml
	local image_name=$( grep "image:" $build_location/pg_monitor/build_test/pg-monitor-timescaledb-deployment.yaml )
	print_verbose 3 "Image to Load: $image_name"

	# Grafana
	cp $build_location/pg_monitor/grafana/kubernetes/pg-monitor-grafana-service.yaml $build_location/pg_monitor/build_test/pg-monitor-grafana-service.yaml
	cp $build_location/pg_monitor/grafana/kubernetes/pg-monitor-grafana-deployment.yaml $build_location/pg_monitor/build_test/pg-monitor-grafana-deployment.yaml

	# Graphite
	cp $build_location/pg_monitor/graphite/kubernetes/pg-monitor-graphite-service.yaml $build_location/pg_monitor/build_test/pg-monitor-graphite-service.yaml
	cp $build_location/pg_monitor/graphite/kubernetes/pg-monitor-graphite-deployment.yaml $build_location/pg_monitor/build_test/pg-monitor-graphite-deployment.yaml
}

remove_kubernetes()
{
	###### CLEANUP IN KUBERNETES ######
	# Delete Service, Secret and Deployment in Kubernetes

	print_verbose 2 "Remove any existing Kubernetes instance"

	# TimescaleDB
	print_verbose 3 "Removing TimescaleDB"
	kubectl delete --wait=true -f $build_location/pg_monitor/build_test/pg-monitor-timescaledb-service.yaml
	kubectl delete --wait=true -f $build_location/pg_monitor/build_test/pg-monitor-timescaledb-secret.yaml
	kubectl delete --wait=true -f $build_location/pg_monitor/build_test/pg-monitor-timescaledb-deployment.yaml
	# Need to test that pod is gone
	until kubectl -n default get pods -lapp=pg-monitor-timescaledb 2>&1 | grep -c pg-monitor-timescaledb | grep -q -m 1 "0"; do sleep 1; done

	# Grafana
	print_verbose 3 "Removing Grafana"
	kubectl delete --wait=true -f $build_location/pg_monitor/build_test/pg-monitor-grafana-service.yaml
	kubectl delete --wait=true -f $build_location/pg_monitor/build_test/pg-monitor-grafana-deployment.yaml
	# Need to test that pod is gone
	until kubectl -n default get pods -lapp=pg-monitor-grafana 2>&1 | grep -c pg-monitor-grafana | grep -q -m 1 "0"; do sleep 1; done

	# Graphite
	print_verbose 3 "Removing Graphite"
	kubectl delete --wait=true -f $build_location/pg_monitor/build_test/pg-monitor-graphite-service.yaml
	kubectl delete --wait=true -f $build_location/pg_monitor/build_test/pg-monitor-graphite-deployment.yaml
	# Need to test that pod is gone
	until kubectl -n default get pods -lapp=pg-monitor-graphite 2>&1 | grep -c pg-monitor-graphite | grep -q -m 1 "0"; do sleep 1; done
}

add_kubernetes()
{
	###### INSTALL IN KUBERNETES ######
	# Add Service, Secret and Deployment in Kubernetes

	print_verbose 2 "Create Kubernetes Instance"

	# TimescaleDB
	print_verbose 3 "Applying TimescaleDB"
	kubectl apply -f $build_location/pg_monitor/build_test/pg-monitor-timescaledb-service.yaml
	kubectl apply -f $build_location/pg_monitor/build_test/pg-monitor-timescaledb-secret.yaml
	kubectl apply -f $build_location/pg_monitor/build_test/pg-monitor-timescaledb-deployment.yaml
	# Make sure TimescaleDB pod is scheduled and running.
	JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl -n default get pods -lapp=pg-monitor-timescaledb -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for pg-monitor-timescaledb deployment to be available"; kubectl get pods -n default; done

	# Grafana
	print_verbose 3 "Applying Grafana"
	kubectl apply -f $build_location/pg_monitor/build_test/pg-monitor-grafana-service.yaml
	kubectl apply -f $build_location/pg_monitor/build_test/pg-monitor-grafana-deployment.yaml
	# Make sure Grafana pod is scheduled and running.
	JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl -n default get pods -lapp=pg-monitor-grafana -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for pg-monitor-grafana deployment to be available"; kubectl get pods -n default; done

	# Graphite
	print_verbose 3 "Applying Graphite"
	kubectl apply -f $build_location/pg_monitor/build_test/pg-monitor-graphite-service.yaml
	kubectl apply -f $build_location/pg_monitor/build_test/pg-monitor-graphite-deployment.yaml
	# Make sure Graphite pod is scheduled and running.
	JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl -n default get pods -lapp=pg-monitor-graphite -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for pg-monitor-graphite deployment to be available"; kubectl get pods -n default; done
}

check_pg_version()
{
	print_verbose 2 "Check Postgres Version"

	kubectl get all
	local pg_version=$( psql -d postgres -p $PG_PORT -U postgres -h $PG_SERVER -c 'SELECT version();' -t )
	print_verbose 2 "PG Version $pg_version"
}

install_sql()
{
	# Install pg_monitor sql
	print_verbose 2 "Install pg_monitor SQL"

	psql -v ON_ERROR_STOP=1 -p $PG_PORT -U postgres -h $PG_SERVER -f $build_location/pg_monitor/timescaledb/init_timescaledb.sql || die;
	psql -v ON_ERROR_STOP=1 -p $PG_PORT -U postgres -h $PG_SERVER -c "ALTER ROLE grafana WITH PASSWORD 'pgpass';" || die;
	psql -v ON_ERROR_STOP=1 -p $PG_PORT -U postgres -h $PG_SERVER -d pgmonitor_db -f $build_location/pg_monitor/pgtap_tests/common/make_aggregates_fast.sql || die;
	cat $build_location/pg_monitor/pgtap_tests/logs/pglog_db1.csv | psql -p $PG_PORT -U postgres -h $PG_SERVER -v ON_ERROR_STOP=1 -d pgmonitor_db -q -c "CREATE TEMP TABLE upload_logs (LIKE logs.postgres_log);ALTER TABLE upload_logs ALTER COLUMN cluster_name SET DEFAULT 'db1';COPY upload_logs (log_time,user_name,database_name,process_id,connection_from,session_id,session_line_num,command_tag,session_start_time,virtual_transaction_id,transaction_id,error_severity,sql_state_code,message,detail,hint,internal_query,internal_query_pos,context,query,query_pos,location,application_name) FROM STDIN (FORMAT CSV);INSERT INTO logs.postgres_log SELECT * FROM upload_logs;" || die;
	cat $build_location/pg_monitor/pgtap_tests/logs/pglog_db2.csv | psql -p $PG_PORT -U postgres -h $PG_SERVER -v ON_ERROR_STOP=1 -d pgmonitor_db -q -c "CREATE TEMP TABLE upload_logs (LIKE logs.postgres_log);ALTER TABLE upload_logs ALTER COLUMN cluster_name SET DEFAULT 'db2';COPY upload_logs (log_time,user_name,database_name,process_id,connection_from,session_id,session_line_num,command_tag,session_start_time,virtual_transaction_id,transaction_id,error_severity,sql_state_code,message,detail,hint,internal_query,internal_query_pos,context,query,query_pos,location,application_name) FROM STDIN (FORMAT CSV);INSERT INTO logs.postgres_log SELECT * FROM upload_logs;" || die;
	if [ $( psql -v ON_ERROR_STOP=1 -p $PG_PORT -U postgres -h $PG_SERVER -d pgmonitor_db -c "SELECT tools.check_timescaledb_version('2.0.0-beta1') AS check;" -t ) == "t" ]; then
		psql -v ON_ERROR_STOP=1 -p $PG_PORT -U postgres -h $PG_SERVER -d pgmonitor_db -f $build_location/pg_monitor/pgtap_tests/common/refresh_aggregates_2.sql || die;
	else
		psql -v ON_ERROR_STOP=1 -p $PG_PORT -U postgres -h $PG_SERVER -d pgmonitor_db -f $build_location/pg_monitor/pgtap_tests/common/refresh_aggregates.sql || die;
	fi
}

start_pg_monitor()
{
	python3 $build_location/pg_monitor/pg_monitor/pg_monitor.py -h $PG_SERVER -p $PG_PORT -U grafana -W pgpass -vvv
}

run_pgtap()
{
	#Run pg_tap tests
	print_verbose 2 "Run pg_tap tests"

	# Must change directories to tune the pgtap tests.
	cd $build_location/pg_monitor/pgtap_tests/
	# Run the all the pgtap tests in the pgtap_tests directory
	# - travis_wait pg_prove -v -d postgres 03_data_tests.pg
	pg_prove -v -h localhost -p 30002 -d postgres -U postgres . || die
}

# Example from http://mywiki.wooledge.org/BashFAQ/035
while :; do
    case $1 in
		-h|-\?|--help)
			show_help    # Display a usage synopsis.
			exit
			;;
        -o|--org)       # Takes an option argument; ensure it has been specified.
			if [ "$2" ]; then
				ORG=$2
				shift
			else
				die 'ERROR: "-o or --org" requires a non-empty option argument.'
			fi
			;;
		-o=?*|--org=?*)
			ORG=${1#*=} # Delete everything up to "=" and assign the remainder.
			;;
		-o=|--org=)         # Handle the case of an empty --org=
			die 'ERROR: "-o or --org" requires a non-empty option argument.'
			;;
        -tn|--ts_name)       # Takes an option argument; ensure it has been specified.
			if [ "$2" ]; then
				TS_NAME=$2
				shift
			else
				die 'ERROR: "-tn or --tg_name" requires a non-empty option argument.'
			fi
			;;
		-tn=?*|--ts_name=?*)
			TS_NAME=${1#*=} # Delete everything up to "=" and assign the remainder.
			;;
		-tn=|--ts_name=)         # Handle the case of an empty --ts_name=
			die 'ERROR: "-tn or --tg_name" requires a non-empty option argument.'
			;;
        -pgv|--pgversion)       # Takes an option argument; ensure it has been specified.
			if [ "$2" ]; then
				PG_VER=$2
				PG_VER_NUMBER=$( echo $PG_VER | cut -c3-)
				shift
			else
				die 'ERROR: "-pgv or --pgversion" requires a non-empty option argument.'
			fi
			;;
		-pgv=?*|--pgversion=?*)
			PG_VER=${1#*=} # Delete everything up to "=" and assign the remainder.
			PG_VER_NUMBER=$( echo $PG_VER | cut -c3-)
			;;
		-pgv=|--pgversion=)         # Handle the case of an empty --pgversion=
			die 'ERROR: "-pgv or --pgversion" requires a non-empty option argument.'
			;;
        -tsv|--tsversion)       # Takes an option argument; ensure it has been specified.
			if [ "$2" ]; then
				TS_VER=$2
				shift
			else
				die 'ERROR: "-tsv or --tsversion" requires a non-empty option argument.'
			fi
			;;
		-tsv=?*|--tsversion=?*)
			TS_VER=${1#*=} # Delete everything up to "=" and assign the remainder.
			;;
		-tsv=|--tsversion=)         # Handle the case of an empty --pgversion=
			die 'ERROR: "-tsv or --tsversion" requires a non-empty option argument.'
			;;
        --location)       # Takes an option argument; ensure it has been specified.
			if [ "$2" ]; then
				build_location=$2
				shift
			else
				die 'ERROR: "--location" requires a non-empty option argument.'
			fi
			;;
		--location=?*)
			build_location=${1#*=} # Delete everything up to "=" and assign the remainder.
			;;
		--location=)         # Handle the case of an empty --location=
			die 'ERROR: "--location" requires a non-empty option argument.'
			;;
        --clean)
			clean=1
        	;;
        -v|--verbose)
			verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
        	;;
        -V|--version)
			version=1
        	;;
		--)              # End of all options.
			shift
			break
			;;
		-?*)
			printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
			;;
        *) # Default case: No more options, so break out of the loop.
			break
    esac
    shift
done

if [ $version -eq "1" ]; then
	version_info
fi

print_verbose 3 "Verbose level: $verbose"
print_verbose 3 "Organization Name: $ORG"
print_verbose 3 "TimescaleDB Name: $TS_NAME"
print_verbose 3 "TimescaleDB Version: $TS_VER"
print_verbose 3 "Postgres Version: $PG_VER"
print_verbose 3 "Show Version Information: $version"
print_verbose 3 "Cleanup Kubernetes: $clean"
print_verbose 3 "Build Location: $build_location"
print_verbose 3 ""

if [ $clean -eq 1 ]; then
	remove_kubernetes
	exit 0
fi

prep_kubernetes
remove_kubernetes
add_kubernetes
check_pg_version
install_sql
start_pg_monitor
run_pgtap
