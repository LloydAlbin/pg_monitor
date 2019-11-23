NAME=timescaledb
ORG=timescale
PG_VER=pg11
PG_VER_NUMBER=$(shell echo $(PG_VER) | cut -c3-)
#VERSION=$(shell awk '/^ENV TIMESCALEDB_VERSION/ {print $$3}' Dockerfile)

default: image

.build_$(VERSION)_$(PG_VER)_oss: Dockerfile
	docker build --build-arg PREV_EXTRA="-oss" --build-arg OSS_ONLY=" -DAPACHE_ONLY=1" --build-arg PG_VERSION=$(PG_VER_NUMBER) -t $(ORG)/$(NAME):latest-$(PG_VER)-oss .
	docker tag $(ORG)/$(NAME):latest-$(PG_VER)-oss $(ORG)/$(NAME):$(VERSION)-$(PG_VER)-oss
	touch .build_$(VERSION)_$(PG_VER)_oss

.build_$(VERSION)_$(PG_VER): Dockerfile
	docker build --build-arg PG_VERSION=$(PG_VER_NUMBER) -t $(ORG)/$(NAME):latest-$(PG_VER) .
	docker tag $(ORG)/$(NAME):latest-$(PG_VER) $(ORG)/$(NAME):$(VERSION)-$(PG_VER)
	touch .build_$(VERSION)_$(PG_VER)

image: .build_$(VERSION)_$(PG_VER)

oss: .build_$(VERSION)_$(PG_VER)_oss

push: image
	docker push $(ORG)/$(NAME):$(VERSION)-$(PG_VER)
	docker push $(ORG)/$(NAME):latest-$(PG_VER)

push-oss: oss
	docker push $(ORG)/$(NAME):$(VERSION)-$(PG_VER)-oss
	docker push $(ORG)/$(NAME):latest-$(PG_VER)-oss

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
	sed -i 's/#\t\topenldap-dev/\t\topenldap-dev/g' ~/postgres/9.4/alpine/Dockerfile
	sed -i 's/#\t\t--with-ldap/\t\t--with-ldap/g' ~/postgres/9.4/alpine/Dockerfile
	sed -i 's/#\t\topenldap-dev/\t\topenldap-dev/g' ~/postgres/9.5/alpine/Dockerfile
	sed -i 's/#\t\t--with-ldap/\t\t--with-ldap/g' ~/postgres/9.5/alpine/Dockerfile
	sed -i 's/#\t\topenldap-dev/\t\topenldap-dev/g' ~/postgres/9.6/alpine/Dockerfile
	sed -i 's/#\t\t--with-ldap/\t\t--with-ldap/g' ~/postgres/9.6/alpine/Dockerfile
	sed -i 's/#\t\topenldap-dev/\t\topenldap-dev/g' ~/postgres/10/alpine/Dockerfile
	sed -i 's/#\t\t--with-ldap/\t\t--with-ldap/g' ~/postgres/10/alpine/Dockerfile
	sed -i 's/#\t\topenldap-dev/\t\topenldap-dev/g' ~/postgres/11/alpine/Dockerfile
	sed -i 's/#\t\t--with-ldap/\t\t--with-ldap/g' ~/postgres/11/alpine/Dockerfile
	sed -i 's/#\t\topenldap-dev/\t\topenldap-dev/g' ~/postgres/12/alpine/Dockerfile
	sed -i 's/#\t\t--with-ldap/\t\t--with-ldap/g' ~/postgres/12/alpine/Dockerfile

.build-postgres: 
	docker build -t lloydalbin/postgres:9.4-alpine -t lloydalbin/postgres:9.4.25-alpine ~/postgres/9.4/alpine
	docker build -t lloydalbin/postgres:9.5-alpine -t lloydalbin/postgres:9.5.20-alpine ~/postgres/9.5/alpine
	docker build -t lloydalbin/postgres:9.6-alpine -t lloydalbin/postgres:9.6.16-alpine ~/postgres/9.6/alpine
	docker build -t lloydalbin/postgres:10-alpine -t lloydalbin/postgres:10.11-alpine ~/postgres/10/alpine
	docker build -t lloydalbin/postgres:11-alpine -t lloydalbin/postgres:11.6-alpine ~/postgres/11/alpine
	docker build -t lloydalbin/postgres:12-alpine -t lloydalbin/postgres:12.1-alpine -t lloydalbin/postgres:latest ~/postgres/12/alpine

.new-postgres:
	cd ~
	git clone https://github.com/docker-library/postgres.git ~/postgres

postgres: .check-postgres .update-postgres .build-postgres

postgres-force: .update-postgres .build-postgres

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

all: postgres timescaledb
.PHONY: all
