TSNAME?=timescaledb
PGNAME?=postgres
ORG?=lloydalbin
PG_VER=pg11
PG_VER_NUMBER=$(shell echo $(PG_VER) | cut -c3-)
VERSION=$(shell awk '/^ENV TIMESCALEDB_VERSION/ {print $$3}' ~/timescaledb-docker/Dockerfile)
PGFULLVERSION=$(shell awk '/^ENV PG_VERSION/ {print $$3}' ~/postgres/$(PG_VER_NUMBER)/alpine/Dockerfile)

default: postgres timescaledb

.timescaledb-build_$(VERSION)_$(PG_VER): ~/timescaledb-docker/Dockerfile
	docker build --build-arg PG_VERSION=$(PG_VER_NUMBER) -t $(ORG)/$(TSNAME):latest-$(PG_VER) ~/timescaledb-docker
	docker tag $(ORG)/$(TSNAME):latest-$(PG_VER) $(ORG)/$(TSNAME):$(VERSION)-$(PG_VER)
	touch ~/timescaledb-docker/.build_$(VERSION)_$(PG_VER)

timescaledb-image: .timescaledb-build_$(VERSION)_$(PG_VER)

timescaledb-push: timescaledb-image
	docker push $(ORG)/$(TSNAME):$(VERSION)-$(PG_VER)
	docker push $(ORG)/$(TSNAME):latest-$(PG_VER)

timescaledb-clean2:
	rm -f *~ .build_*

.PHONY: default timescaledb-image timescaledb-push timescaledb-clean2


.check-postgres: SHELL:=/bin/bash
.check-postgres: 
	./git_check.sh ~/postgres

.update-postgres:
	sed -i 's/#\t\topenldap-dev/\t\topenldap-dev/g' ~/postgres/$(PG_VER_NUMBER)/alpine/Dockerfile
	sed -i 's/#\t\t--with-ldap/\t\t--with-ldap/g' ~/postgres/$(PG_VER_NUMBER)/alpine/Dockerfile
	sed -i "/FROM alpine/a RUN echo 'nvm.overcommit_memory = 2' >> \/etc\/sysctl.conf" ~/postgres/$(PG_VER_NUMBER)/alpine/Dockerfile
	sed -i "/FROM alpine/a RUN echo 'vm.overcommit_ratio = 100' >> \/etc\/sysctl.conf" ~/postgres/$(PG_VER_NUMBER)/alpine/Dockerfile

.build-postgres: 
	PGFULLVERSION=$(shell awk '/^ENV PG_VERSION/ {print $$3}' ~/postgres/$(PG_VER_NUMBER)/alpine/Dockerfile)
ifeq ($(PG_VER_NUMBER),12)
	docker build -t $(ORG)/$(PGNAME):$(PG_VER_NUMBER)-alpine -t $(ORG)/$(PGNAME):$(PGFULLVERSION)-alpine -t $(ORG)/$(PGNAME):latest-alpine ~/postgres/$(PG_VER_NUMBER)/alpine
else
	docker build -t $(ORG)/$(PGNAME):$(PG_VER_NUMBER)-alpine -t $(ORG)/$(PGNAME):$(PGFULLVERSION)-alpine ~/$(PGNAME)/$(PG_VER_NUMBER)/alpine
endif

.new-postgres:
	cd ~
	git clone https://github.com/docker-library/postgres.git ~/postgres

postgres: .check-postgres .update-postgres .build-postgres

postgres-check: .check-postgres

postgres-update: .update-postgres

postgres-force: .update-postgres .build-postgres

postgres-build: .build-postgres

postgres-new: .new-postgres .update-postgres .build-postgres 

postgres-clean:
	rm -rf ~/postgres

.check-timescaledb: SHELL:=/bin/bash
.check-timescaledb:
	./git_check.sh ~/timescaledb-docker

.update-timescaledb:
	sed -i 's#FROM postgres:#FROM $(ORG)/$(PGNAME):#g' ~/timescaledb-docker/Dockerfile
	#sed -i 's#ORG=timescale#ORG=$(ORG)#g' ~/timescaledb-docker/Makefile

.new-timescaledb:
	cd ~
	git clone https://github.com/timescale/timescaledb-docker.git ~/timescaledb-docker

timescaledb: .timescaledb-build_$(VERSION)_$(PG_VER)

timescaledb-new: .new-timescaledb .update-timescaledb .timescaledb-build_$(VERSION)_$(PG_VER)

timescaledb-check: .check-timescaledb

timescaledb-clean:
	rm -rf ~/timescaledb-docker

docker-cleanup:
	# Remove the docker iamges with REPOSITORY = <none> and TAG = <none>
	docker images | awk '/^<none>/{print $$3}' | xargs docker rmi

all: postgres timescaledb
.PHONY: all timescaledb-check timescaledb-new timescaledb
