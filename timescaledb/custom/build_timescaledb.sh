#!/bin/bash
# POSIX

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
ORG="lloydalbin"
PG_NAME="postgres"
TS_NAME="timescaledb"
PG_VER="pg11"
PG_VER_NUMBER=$( echo $PG_VER | cut -c3-)
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

# Usage info
show_help()
{
	cat << EOF
Usage: ${0##*/} [-hv] [-o ORGANIZATION]
	-h/--help					display this help and exit
	-o/--org ORGANIZATION		insert the organization name into the docker name ORGANIZATION/NAME:VERSION - Default: lloydalbin
	--pn/--pg_name NAME			insert the Poistgres name into the docker name ORGANIZATION/NAME:VERSION - Default: postgres
	--tn/--ts_name NAME			insert the TimescaleDB name into the docker name ORGANIZATION/NAME:VERSION - Default: timescaledb
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
}

postgres_patch()
{
	# postgres_patch $build_location $PG_VER_NUMBER
	print_verbose 1 "Patching Postgres Repository: $1/postgres/$2/alpine/Dockerfile"
	sed -i 's/#\t\topenldap-dev/\t\topenldap-dev/g' $1/postgres/$2/alpine/Dockerfile
	sed -i 's/#\t\t--with-ldap/\t\t--with-ldap/g' $1/postgres/$2/alpine/Dockerfile
	sed -i "/FROM alpine/a RUN echo 'nvm.overcommit_memory = 2' >> \/etc\/sysctl.conf" $1/postgres/$2/alpine/Dockerfile
	sed -i "/FROM alpine/a RUN echo 'vm.overcommit_ratio = 100' >> \/etc\/sysctl.conf" $1/postgres/$2/alpine/Dockerfile
}

timescaledb_patch()
{
	# timescaledb_patch $build_location $ORG $PG_NAME
	print_verbose 1 "Patching TimescaleDB Repository: $1/timescaledb-docker/Dockerfile"
	sed -i "s#FROM postgres:#FROM $2/$3:#g" $1/timescaledb-docker/Dockerfile
}

postgres_build()
{
	# postgres_build $build_location $ORG $PG_NAME $PG_VER_NUMBER
	print_verbose 1 "Building Postgres Docker Image: $1/postgres/$4/alpine"
	PG_FULL_VERSION=$( awk '/^ENV PG_VERSION/ {print $3}' $1/postgres/$4/alpine/Dockerfile )
	print_verbose 3 "Postgres Full Version Number: $PG_FULL_VERSION"

	# Build exact Postgres Version
	print_verbose 2 "Building Docker Image: $2/$3:$PG_FULL_VERSION-alpine in $1/postgres/$4/alpine"
	docker build -t $2/$3:$PG_FULL_VERSION-alpine $1/postgres/$4/alpine

	# Tag Major Postgres Version
	print_verbose 2 "Tagging Docker Image: $2/$3:$4-alpine from $2/$3:$PG_FULL_VERSION-alpine"
	docker tag $2/$3:$PG_FULL_VERSION-alpine $2/$3:$4-alpine

	if [ $4 -eq "12" ]; then
		# Tag Latest Postgres Version
		print_verbose 2 "Tagging Docker Image: $2/$3:latest-alpine from $2/$3:$PG_FULL_VERSION-alpine"
		docker tag $2/$3:$PG_FULL_VERSION-alpine $2/$3:latest-alpine
	fi
}

timescaledb_build()
{
	# timescaledb_build $build_location $ORG $TS_NAME $PG_VER_NUMBER $PG_VER
	print_verbose 1 "Building TimescaleDB Docker Image: $1/timescaledb-docker"
	VERSION=$( awk '/^ENV TIMESCALEDB_VERSION/ {print $3}' $1/timescaledb-docker/Dockerfile )
	print_verbose 3 "Timescale Version: $VERSION"
	
	# Build Latest TimescaleDB Version
	print_verbose 2 "Building Docker Image: $2/$3:latest-$5 in $1/timescaledb-docker"
	docker build --build-arg PG_VERSION=$4 -t $2/$3:latest-$5 $1/timescaledb-docker

	# Tag exact TimescaleDB Version
	print_verbose 2 "Tagging Docker Image: $2/$3:$VERSION-$5 from $2/$3:latest-$5"
	docker tag $2/$3:latest-$5 $2/$3:$VERSION-$5

	touch $1/timescaledb-docker/.build_$VERSION_$5
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
		-o=|--org=)         # Handle the case of an empty --file=
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
		-pn=|--pg_name=)         # Handle the case of an empty --file=
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
		-tn=|--ts_name=)         # Handle the case of an empty --file=
			die 'ERROR: "-tn or --tg_name" requires a non-empty option argument.'
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
		--location=)         # Handle the case of an empty --file=
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
		-c=|--clean=)         # Handle the case of an empty --file=
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
	clean_git $clean_location
	if [ $override_exit -eq 0 ]; then
		exit
	fi
fi

if [ $postgres -eq 1 ]; then
	# Get/Update Repository
	git_update $build_location/postgres https://github.com/docker-library/postgres.git
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
	git_update $build_location/timescaledb-docker https://github.com/timescale/timescaledb-docker.git
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

