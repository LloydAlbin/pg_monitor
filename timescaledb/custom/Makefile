TSNAME=?timescaledb
PGNAME=?postgres
ORG?=lloydalbin
PG_VER=pg11
PG_VER_NUMBER=$(shell echo $(PG_VER) | cut -c3-)
#VERSION=$(shell awk '/^ENV TIMESCALEDB_VERSION/ {print $$3}' Dockerfile)

default: image

.build_$(VERSION)_$(PG_VER)_oss: Dockerfile
	docker build --build-arg PREV_EXTRA="-oss" --build-arg OSS_ONLY=" -DAPACHE_ONLY=1" --build-arg PG_VERSION=$(PG_VER_NUMBER) -t $(ORG)/$(TSNAME):latest-$(PG_VER)-oss .
	docker tag $(ORG)/$(TSNAME):latest-$(PG_VER)-oss $(ORG)/$(TSNAME):$(VERSION)-$(PG_VER)-oss
	touch .build_$(VERSION)_$(PG_VER)_oss

.build_$(VERSION)_$(PG_VER): Dockerfile
	docker build --build-arg PG_VERSION=$(PG_VER_NUMBER) -t $(ORG)/$(TSNAME):latest-$(PG_VER) .
	docker tag $(ORG)/$(TSNAME):latest-$(PG_VER) $(ORG)/$(TSNAME):$(VERSION)-$(PG_VER)
	touch .build_$(VERSION)_$(PG_VER)

image: .build_$(VERSION)_$(PG_VER)

oss: .build_$(VERSION)_$(PG_VER)_oss

push: image
	docker push $(ORG)/$(TSNAME):$(VERSION)-$(PG_VER)
	docker push $(ORG)/$(TSNAME):latest-$(PG_VER)

push-oss: oss
	docker push $(ORG)/$(TSNAME):$(VERSION)-$(PG_VER)-oss
	docker push $(ORG)/$(TSNAME):latest-$(PG_VER)-oss

clean:
	rm -f *~ .build_*

.PHONY: default image push push-oss oss clean


.check-postgres:
	cd ~/postgres
 
	UPSTREAM=${1:-'@{u}'}
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse "$UPSTREAM")
	BASE=$(git merge-base @ "$UPSTREAM")
 
	if [ $LOCAL = $REMOTE ]; then
		echo "Up-to-date"
	elif [ $LOCAL = $BASE ]; then
		git pull
		echo "Need to pull"
	elif [ $REMOTE = $BASE ]; then
		echo "Need to push"
	else
		echo "Diverged"
	fi

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

postgres-update: .update-postgres

postgres-force: .update-postgres .build-postgres

postgres-build: .build-postgres

postgres-new: .new-postgres .update-postgres .build-postgres 

postgres-clean:
	rm -rf ~/postgres

.new-timescaledb:
	cd ~
	git clone https://github.com/timescale/timescaledb-docker.git ~/timescaledb-docker

timescaledb: .check-postgres

timescaledb-new: .new-timescaledb

timescaledb-clean:
	rm -rf ~/timescaledb-docker

docker-cleanup:
	# Remove the docker iamges with REPOSITORY = <none> and TAG = <none>
	docker images | awk '/^<none>/{print $$3}' | xargs docker rmi

all: postgres timescaledb
.PHONY: all
