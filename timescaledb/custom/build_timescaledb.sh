#!/bin/bash
# POSIX

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
ORG="lloydalbin"
PG_NAME="postgres"
TS_NAME="timescaledb"
TS_VER=
PG_VER="pg12"
PG_VER_NUMBER=$( echo $PG_VER | cut -c3-)
PGTAP_VER="1.1.0"
TDS_VER="2.0.2"
verbose=0
postgres=0
timescaledb=0
version=0
build_location=~
git=0
patch=0
build=0
push=0
clean=0
clean_location=
override_exit=0
pgtap=0
tds=0
pgaudit=0
pgnodemx=0

# Usage info
show_help()
{
	cat << EOF
Usage: ${0##*/} [-hv] [-o ORGANIZATION]
	-h/--help					display this help and exit
	-o/--org ORGANIZATION		insert the organization name into the docker name ORGANIZATION/NAME:VERSION - Default: lloydalbin
	-pn/--pg_name NAME			insert the Poistgres name into the docker name ORGANIZATION/NAME:VERSION - Default: postgres
	-tn/--ts_name NAME			insert the TimescaleDB name into the docker name ORGANIZATION/NAME:VERSION - Default: timescaledb
	-v							verbose mode. Can be used multiple times for increased verbosity
								MUST precede the -c command
	-c/--clean					remove both repositories and exit
	--override_exit				override exit after removing repository
	-c/--clean REPOSITORY		remove specific repository and exit
	--postgres					build postgres only - Default: --postgres --timescaledb
	--timescaledb				build timescaledb only - Default: --postgres --timescaledb
	--location					root repository location - Default: ~
	-V/--version				show version information
	--git						get from repository - Default: --git --patch --build
	--patch						patch the repository - Default: --git --patch --build
	--build						build the repository - Default: --git --patch --build
	--push						push to repository
	--add (item)				add item to the Postgres docker image
								Items:
									all - Include all the items listed below
									pgtap - pgTAP is a suite of database functions that make it easy to write 
										TAP-emitting unit tests in psql scripts or xUnit-style test functions.
										http://pgtap.org/
									tds - TDS_FDW is a PostgreSQL foreign data wrapper that can connect to 
										databases that use the Tabular Data Stream (TDS) protocol, such as 
										Sybase databases and Microsoft SQL server.
									pgaudit - The PostgreSQL Audit Extension (or pgaudit) provides detailed 
										session and/or object audit logging via the standard logging facility 
										provided by PostgreSQL. The goal of PostgreSQL Audit to provide the 
										tools needed to produce audit logs required to pass certain government, 
										financial, or ISO certification audits.
									pgnodemx - SQL functions that allow capture of node OS metrics from PostgreSQL
	-pgv/--pgversion VERSION	Overrides the default PostgreSQL version. - Default: $PG_VER
	-tsv/--tsversion VERSION	Overrides the default TimescaleDB version. - Default: $TS_VER

EOF
}

# Version Info
version_info()
{
	cat << EOF
build_timescaledb 0.01
Copyright (C) 2019 Fred Hutchinson Cancer Research Center
License Apache-2.0: Apache version 2 or later .
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

git_push()
{
	# git_push postgres timescaledb ORG NAME $build_location PG_VER
	print_verbose 1 "Push Postgres Docker Image"

	# Postgres
	if [ $1 -eq 1 ]; then
		PG_FULL_VERSION=$( awk '/^ENV PG_VERSION/ {print $3}' $5/postgres/$6/alpine/Dockerfile )
		print_verbose 3 "Postgres Full Version Number: $PG_FULL_VERSION from $5/postgres/$6/alpine/Dockerfile"

		print_verbose 2 "Pushing Docker Image: $3/$4:$6-alpine"
		#docker push $3/$4:$6-alpine

		print_verbose 2 "Pushing Docker Image: $3/$4:$PG_FULL_VERSION-alpine"
		#docker push $3/$4:$PG_FULL_VERSION-alpine

		if [ $4 -eq "12" ]; then
			print_verbose 2 "Pushing Docker Image: $3/$4:latest-alpine"
			#docker push $3/$4:latest-alpine
		fi
	fi

	# TimescaleDB
	if [ $2 -eq 1 ]; then
		VERSION=$( awk '/^ENV TIMESCALEDB_VERSION/ {print $3}' $5/timescaledb-docker/Dockerfile )
		print_verbose 3 "Timescale Version: $VERSION from $5/timescaledb-docker/Dockerfile"

		print_verbose 2 "Pushing Docker Image: $3/$4:$VERSION-$6"
		#docker push $3/$4:$VERSION-$6

		print_verbose 2 "Pushing Docker Image: $3/$4:latest-$6"
		#docker push $3/$4:latest-$6
	fi
}

git_update()
{
	# This code was tweaked from the example at 
	# https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git

	GIT_PATH=$1
	GIT_REPOSITORY=$2
	GIT_QUIET="--quiet"
	GIT_VER=$3
	if [ $verbose -ge 2 ]; then
		GIT_QUIET=
	fi

	# If GIT_PATH does not exist then clone from repository
	if [ ! -d ${GIT_PATH} ]; then
		print_verbose 1 "Cloning from repository: ${GIT_REPOSITORY} to ${GIT_PATH}"
		git clone ${GIT_REPOSITORY} ${GIT_PATH} ${GIT_QUIET}
	fi

	UPSTREAM="HEAD"
	LOCAL=$(git -C ${GIT_PATH} rev-parse ${UPSTREAM})
	REMOTE=$(git -C ${GIT_PATH} rev-parse "${UPSTREAM}")
	BASE=$(git -C ${GIT_PATH} merge-base HEAD "${UPSTREAM}")

	if [ $LOCAL = $REMOTE ]; then
		print_verbose 1 "Repository Up-to-date: ${GIT_PATH}"
	elif [ $LOCAL = $BASE ]; then
		print_verbose 1 "Need to pull repository: ${GIT_PATH}"
		git -C ${GIT_PATH} pull ${GIT_QUIET}
	elif [ $REMOTE = $BASE ]; then
		print_verbose 1 "Need to push repository: ${GIT_PATH}"
	else
		print_verbose 1 "Repository has Diverged: ${GIT_PATH}"
	fi
}

clean_git()
{
	# clean REPOSITORY_LOCATION
	print_verbose 1 "Removing Repository $1"
	rm -rf $1
}

clean_docker()
{
	# Remove the docker images with REPOSITORY = <none> and TAG = <none>
	print_verbose 1 "Removing Docker Images with REPOSITORY = <none> and TAG = <none>"
	docker images | awk '/^<none>/{print $3}' | xargs docker rmi
	docker system prune -f
}

postgres_patch()
{
	# postgres_patch $build_location $PG_VER_NUMBER
	print_verbose 1 "Patching Postgres Repository: $1/postgres/$2/alpine/Dockerfile"
	sed -i 's/#\t\topenldap-dev/\t\topenldap-dev/g' $1/postgres/$2/alpine/Dockerfile
	sed -i 's/#\t\t--with-ldap/\t\t--with-ldap/g' $1/postgres/$2/alpine/Dockerfile
	sed -i "/FROM alpine/a RUN echo 'nvm.overcommit_memory = 2' >> \/etc\/sysctl.conf" $1/postgres/$2/alpine/Dockerfile
	sed -i "/FROM alpine/a RUN echo 'vm.overcommit_ratio = 100' >> \/etc\/sysctl.conf" $1/postgres/$2/alpine/Dockerfile

	# The build order of these items, if using the "/VOLUME/a" will be in reverse order of the order listed here.
	# aka tds, pgtap in this code become pgtap, tds in the Dockerfile
	if [ $tds = "1" ]; then
		# Add TDS_FDW and it's dependency freeTDS
		# TDS_FDW is a PostgreSQL foreign data wrapper that can connect to databases that use the Tabular Data Stream (TDS) protocol, such as Sybase databases and Microsoft SQL server.
		# https://github.com/tds-fdw/tds_fdw
		print_verbose 2 "Patching Postgres Repository: $1/postgres/$2/alpine/Dockerfile - Adding tds_fdw "

		if (( $(echo "$PG_VER_NUMBER >= 9.2" |bc -l) )); then
			sed -i "/ENV PG_SHA256/a ADD https://github.com/tds-fdw/tds_fdw/archive/v$TDS_VER.zip \/." $1/postgres/$2/alpine/Dockerfile

			# Note these will be in reverse order after being inserted into the Dockerfile
			sed -i "/VOLUME/a 	&& rm -f \/v$TDS_VER.zip " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& rm -rf \/tds_fdw-$TDS_VER \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& make -C \/tds_fdw-$TDS_VER USE_PGXS=1 install \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& make -C \/tds_fdw-$TDS_VER USE_PGXS=1 \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& chown -R postgres:postgres \/tds_fdw-$TDS_VER \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& unzip v$TDS_VER.zip -d \/ \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a RUN apk add --virtual build-dependencies su-exec make gcc freetds-dev libc-dev clang llvm10-dev \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a RUN apk add freetds " $1/postgres/$2/alpine/Dockerfile
		else
			print_verbose 2 "Patching Postgres Repository: $1/postgres/$2/alpine/Dockerfile - Adding tds_fdw - Does not support this version of PostgreSQL"
		fi
	fi

	if [ $pgtap = "1" ]; then
		# Add pgtap
		# pgTAP is a suite of database functions that make it easy to write TAP-emitting unit tests in psql scripts or xUnit-style test functions.
		# http://pgtap.org/
		print_verbose 2 "Patching Postgres Repository: $1/postgres/$2/alpine/Dockerfile - Adding pgtap "

		if (( $(echo "$PG_VER_NUMBER >= 8.1" |bc -l) )); then
			sed -i "/ENV PG_SHA256/a ADD http:\/\/api.pgxn.org\/dist\/pgtap\/$PGTAP_VER\/pgtap-$PGTAP_VER.zip \/." $1/postgres/$2/alpine/Dockerfile

			# Note these will be in reverse order after being inserted into the Dockerfile
			sed -i "/VOLUME/a 	&& rm -f \/pgtap-$PGTAP_VER.zip " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& rm -rf \/pgtap-$PGTAP_VER \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& make -C \/pgtap-$PGTAP_VER install \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& su-exec postgres make -C \/pgtap-$PGTAP_VER \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& cpan TAP::Harness \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& cpan Module::Build \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& chown -R postgres:postgres \/pgtap-$PGTAP_VER \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& unzip pgtap-$PGTAP_VER.zip -d \/ \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a RUN apk add --virtual build-dependencies su-exec perl perl-dev patch make \\\\ " $1/postgres/$2/alpine/Dockerfile	
		else
			print_verbose 2 "Patching Postgres Repository: $1/postgres/$2/alpine/Dockerfile - Adding pgtap - Does not support this version of PostgreSQL"
		fi
	fi

	if [ $pgaudit = "1" ]; then
		# Add pgAudit
		# pgAudit v1.5.X is intended to support PostgreSQL 13.
		# pgAudit v1.4.X is intended to support PostgreSQL 12.
		# pgAudit v1.3.X is intended to support PostgreSQL 11.
		# pgAudit v1.2.X is intended to support PostgreSQL 10.
		# pgAudit v1.1.X is intended to support PostgreSQL 9.6.
		# pgAudit v1.0.X is intended to support PostgreSQL 9.5.
		# https://github.com/pgaudit/pgaudit

		print_verbose 2 "Patching Postgres Repository: $1/postgres/$2/alpine/Dockerfile - Adding pgaudit "
		
		if (( $(echo "$PG_VER_NUMBER >= 9.5" |bc -l) )); then
			# Note these will be in reverse order after being inserted into the Dockerfile
			# shared_preload_libraries = 'pgaudit,pg_stat_statements' #pgaudit <<<<<< NEED TO ADD
			sed -i "/VOLUME/a 	&& rm -rf \/pgaudit " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a   && sed -i \"s/shared_preload_libraries = '/shared_preload_libraries = 'pgaudit,/g\" /usr/local/share/postgresql/postgresql.conf.sample \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& make install USE_PGXS=1 \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& make USE_PGXS=1 \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& git checkout REL_${PG_VER_NUMBER}_STABLE \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& cd \/pgaudit \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& git clone https://github.com/pgaudit/pgaudit.git \/pgaudit \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& apk add openssl \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a RUN apk add --virtual build-dependencies su-exec patch make git gcc libc-dev clang llvm10-dev openssl-dev \\\\ " $1/postgres/$2/alpine/Dockerfile	
		else
			print_verbose 2 "Patching Postgres Repository: $1/postgres/$2/alpine/Dockerfile - Adding pgaudit - Does not support this version of PostgreSQL"
		fi
	fi

	if [ $pgnodemx = "1" ]; then
		# pgnodemx - SQL functions that allow capture of node OS metrics from PostgreSQL
	    # PostgreSQL version 9.5 or newer is required.
    	# On PostgreSQL version 9.6 or earlier, a role called pgmonitor must be created, and the user calling these functions must be granted that role.
		# https://github.com/CrunchyData/pgnodemx/

		print_verbose 2 "Patching Postgres Repository: $1/postgres/$2/alpine/Dockerfile - Adding pgnodemx"
		
		if (( $(echo "$PG_VER_NUMBER == 9.5" |bc -l) )); then
			# Needs to create a role called pgmonitor
			# Note these will be in reverse order after being inserted into the Dockerfile
			sed -i "/VOLUME/a psql -h localhost -d postgres -c 'CREATE ROLE pgmonitor;'" $1/postgres/$2/alpine/Dockerfile	
		fi			

		if (( $(echo "$PG_VER_NUMBER >= 9.5" |bc -l) )); then
			# Note these will be in reverse order after being inserted into the Dockerfile
			# shared_preload_libraries = 'pgnodemx,pg_stat_statements' #pgnodemx <<<<<< NEED TO ADD
			sed -i "/VOLUME/a 	&& rm -rf \/pgnodemx " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a   && sed -i \"s/shared_preload_libraries = '/shared_preload_libraries = 'pgnodemx,/g\" /usr/local/share/postgresql/postgresql.conf.sample \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& make install USE_PGXS=1 \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& make USE_PGXS=1 \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& cd \/pgnodemx  \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& git clone https://github.com/crunchydata/pgnodemx \/pgnodemx \\\\ " $1/postgres/$2/alpine/Dockerfile	
			# sed -i "/VOLUME/a 	&& cd contrib \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a 	&& apk add libmagic \\\\ " $1/postgres/$2/alpine/Dockerfile	
			sed -i "/VOLUME/a RUN apk add --virtual build-dependencies su-exec patch make git gcc libc-dev clang llvm10-dev file-dev linux-headers \\\\ " $1/postgres/$2/alpine/Dockerfile	
		else
			print_verbose 2 "Patching Postgres Repository: $1/postgres/$2/alpine/Dockerfile - Adding pgnodemx - Does not support this version of PostgreSQL"
		fi
	fi
}

timescaledb_patch()
{
	#print_verbose 1 "Checking out TimescaleDB version: $TS_VER"
	#git checkout $TS_VER

	# timescaledb_patch $build_location $ORG $PG_NAME
	print_verbose 1 "Patching TimescaleDB Repository: $1/timescaledb-docker/Dockerfile"
	sed -i "s#FROM postgres:#FROM $2/$3:#g" $1/timescaledb-docker/Dockerfile

	# Use a specific version of timescaledb
	if [ ! -z "$GIT_VER" ]; then
		sed -i "s/ENV TIMESCALEDB_VERSION .*$/ENV TIMESCALEDB_VERSION ${GIT_VER}/g" $1/timescaledb-docker/Dockerfile
	fi
}

postgres_build()
{
	if [[ -f $1/postgres/$4/alpine/.build_$PG_FULL_VERSION ]]; then
		print_verbose 1 "Skipping Building Postgres Docker Image: $1/postgres/$4/alpine"
	else
		# postgres_build $build_location $ORG $PG_NAME $PG_VER_NUMBER
		print_verbose 1 "Building Postgres Docker Image: $1/postgres/$4/alpine"
		PG_FULL_VERSION=$( awk '/^ENV PG_VERSION/ {print $3}' $1/postgres/$4/alpine/Dockerfile )
		print_verbose 3 "Postgres Full Version Number: $PG_FULL_VERSION"

		# Build exact Postgres Version
		print_verbose 2 "Building Docker Image: $2/$3:$PG_FULL_VERSION-alpine in $1/postgres/$4/alpine"
		docker build --no-cache=true -t $2/$3:$PG_FULL_VERSION-alpine $1/postgres/$4/alpine

		# Tag Major Postgres Version
		print_verbose 2 "Tagging Docker Image: $2/$3:$4-alpine from $2/$3:$PG_FULL_VERSION-alpine"
		docker tag $2/$3:$PG_FULL_VERSION-alpine $2/$3:$4-alpine

		if [ $4 -eq "12" ]; then
			# Tag Latest Postgres Version
			print_verbose 2 "Tagging Docker Image: $2/$3:latest-alpine from $2/$3:$PG_FULL_VERSION-alpine"
			docker tag $2/$3:$PG_FULL_VERSION-alpine $2/$3:latest-alpine
		fi

		touch $1/postgres/$4/alpine/.build_$PG_FULL_VERSION
	fi
}

timescaledb_build()
{
	if [[ -f $1/timescaledb-docker/.build_$VERSION_$5 ]]; then
		print_verbose 1 "Skipping Building Postgres Docker Image: $1/postgres/$4/alpine"
	else
		# timescaledb_build $build_location $ORG $TS_NAME $PG_VER_NUMBER $PG_VER
		print_verbose 1 "Building TimescaleDB Docker Image: $1/timescaledb-docker"
		VERSION=$( awk '/^ENV TIMESCALEDB_VERSION/ {print $3}' $1/timescaledb-docker/Dockerfile )
		print_verbose 3 "Timescale Version: $VERSION"
		
		# Build Latest TimescaleDB Version
		print_verbose 2 "Building Docker Image: $2/$3:latest-$5 in $1/timescaledb-docker"
		docker build --no-cache=true --build-arg PG_VERSION=$4 -t $2/$3:latest-$5 $1/timescaledb-docker

		# Build Latest TimescaleDB Version for Specific Postgres Version
		print_verbose 2 "Tagging Docker Image: $2/$3:latest from $2/$3:latest-$5"
		docker tag $2/$3:latest-$5 $2/$3:latest

		# Tag exact TimescaleDB Version
		print_verbose 2 "Tagging Docker Image: $2/$3:$VERSION-$5 from $2/$3:latest-$5"
		docker tag $2/$3:latest-$5 $2/$3:$VERSION-$5

		touch $1/timescaledb-docker/.build_$VERSION_$5
	fi
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
        -pn|--pg_name)       # Takes an option argument; ensure it has been specified.
			if [ "$2" ]; then
				PG_NAME=$2
				shift
			else
				die 'ERROR: "-pn or --pg_name" requires a non-empty option argument.'
			fi
			;;
		-pn=?*|--pg_name=?*)
			PG_NAME=${1#*=} # Delete everything up to "=" and assign the remainder.
			;;
		-pn=|--pg_name=)         # Handle the case of an empty --pg_name=
			die 'ERROR: "-pn or --pg_name" requires a non-empty option argument.'
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
        -c|--clean)       # Takes an option argument; ensure it has been specified.
			if [ "$2" ]; then
				if [[ "-${2:0:1}" == "--" ]]; then
					clean=$((clean + 1))  # Each -v adds 1 to verbosity.
				else
					clean_location=$2
					shift
				fi
			else
				clean=$((verbose + 1))  # Each -v adds 1 to verbosity.
			fi
			;;
		-c=?*|--clean=?*)
			clean_location=${1#*=} # Delete everything up to "=" and assign the remainder.
			;;
		-c=|--clean=)         # Handle the case of an empty --clean=
			die 'ERROR: "-c or --clean" requires a non-empty option argument.'
			;;
		--override_exit)
			override_exit=1
			;;
        -v|--verbose)
			verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
        	;;
        -V|--version)
			version=1
        	;;
        --postgres)
			postgres=1
        	;;
        --timescaledb)
			timescaledb=1
        	;;
        --push)
			push=1
        	;;
        --add)       # Takes an option argument; ensure it has been specified.
			if [ "$2" ]; then
				if [ $2 = "pgtap" ]; then
					pgtap=1
				elif [ $2 = "tds" ]; then
					tds=1
				elif [ $2 = "pgaudit" ]; then
					pgaudit=1
				elif [ $2 = "pgnodemx" ]; then
					pgnodemx=1
				elif [ $2 = "all" ]; then
					pgtap=1
					tds=1
					pgaudit=1
					pgnodemx=1
				else
					die 'ERROR: "--add" unknown argument: $2.'
				fi
				shift
			else
				die 'ERROR: "--add" requires a non-empty option argument.'
			fi
			;;
		--add=?*)
			add_variable=${1#*=} # Delete everything up to "=" and assign the remainder.
			if [ $add_variable = "pgtap" ]; then
				pgtap=1
			elif [ $add_variable = "tds" ]; then
				tds=1
			elif [ $add_variable = "pgaudit" ]; then
				pgaudit=1
			elif [ $add_variable = "pgnodemx" ]; then
				pgnodemx=1
			elif [ $add_variable = "all" ]; then
				pgtap=1
				tds=1
				pgaudit=1
				pgnodemx=1
			else
				die 'ERROR: "--add" unknown argument: $2.'
			fi
			shift
			;;
		--add=)         # Handle the case of an empty --add=
			die 'ERROR: "--add" requires a non-empty option argument.'
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

if [ $timescaledb -eq "0" -a $postgres -eq "0" ]; then
	# If neither was set, then set them both
	postgres=1
	timescaledb=1
fi

if [ $version -eq "1" ]; then
	version_info
fi

print_verbose 3 "Verbose level: $verbose"
print_verbose 3 "Organization Name: $ORG"
print_verbose 3 "Postgres Name: $PG_NAME"
print_verbose 3 "TimescaleDB Name: $TS_NAME"
print_verbose 3 "TimescaleDB Version: $TS_VER"
print_verbose 3 "Postgres Version: $PG_VER"
print_verbose 3 "Postgres Version Number: $PG_VER_NUMBER"
print_verbose 3 "Clone/Pull Repositories: $git"
print_verbose 3 "Patch Repositories: $patch"
print_verbose 3 "Build Docker Images: $build"
print_verbose 3 "Push Docker Images: $push"
print_verbose 3 "Cleaning Level: $clean"
print_verbose 3 "Cleaning Location: $clean_location"
print_verbose 3 "Show Version Information: $version"
print_verbose 3 "Override Exit: $override_exit"
print_verbose 3 "Build Location: $build_location"
print_verbose 3 "Add pgtap: $pgtap"
print_verbose 3 "Add tds_fdw: $tds"
print_verbose 3 "Add pgaudit: $pgaudit"
print_verbose 3 "Add pgnodemx: $pgnodemx"
print_verbose 3 "Process Postgres: $postgres"
print_verbose 3 "Process TimescaleDB: $timescaledb"
print_verbose 3 ""

if [ $clean -ge 1 ]; then
	clean_git ~/postgres
	clean_git ~/timescaledb-docker
	if [ $clean -ge 2 ]; then
		clean_docker
	fi
	if [ $override_exit -eq 0 ]; then
		exit
	fi
fi

if [[ ! -z $clean_location ]]; then
	clean_git "$build_location/$clean_location"
	if [ $override_exit -eq 0 ]; then
		exit
	fi
fi

if [ $postgres -eq 1 ]; then
	# Get/Update Repository
	git_update $build_location/postgres https://github.com/docker-library/postgres.git ""
	# Patch Makefile
	postgres_patch $build_location $PG_VER_NUMBER
	# Build Docker Image
	postgres_build $build_location $ORG $PG_NAME $PG_VER_NUMBER
	if [ $push -eq 1 ]; then
		git_push $push 0 $ORG $PG_NAME $build_location $PG_VER_NUMBER
	fi
fi

if [ $postgres -eq 1 -a $timescaledb -eq 1 ]; then
	print_verbose 1 ""
fi

if [ $timescaledb -eq 1 ]; then
	# Get/Update Repository
	git_update $build_location/timescaledb-docker https://github.com/timescale/timescaledb-docker.git $TS_VER
	# Patch Makefile
	timescaledb_patch $build_location $ORG $PG_NAME
	# Build Docker Image
	timescaledb_build $build_location $ORG $TS_NAME $PG_VER_NUMBER $PG_VER
	if [ $push -eq 1 ]; then
		git_push 0 $push $ORG $TS_NAME $build_location $PG_VER
	fi
fi

if [ $clean -ge 2 ]; then
	clean_docker
fi

