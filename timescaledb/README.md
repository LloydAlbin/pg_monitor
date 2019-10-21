# tiemscaledb
PostgreSQL TimescaleDB server for creating our Reports database.

* [TimescaelDB](https://www.timescale.com/products) - Timescale Database
* init_timescaledb.sql - Script to create a fresh Reports timescale database
* upgrade.sql - Script to upgrade your Reports timescale database with new features

You may either use a standard PostgreSQL database with the TimescaleDB extension installed, use the TiemscaleDB docker image, or even use the TimescaleDB Cloud edition. 

In my case, I needed to rebuild the TimescaleDB docker image to include LDAP support. This was more complex as the TimescaleDB docker is based on the PostgreSQL alpine linux. First I needed to rebuild the PostgreSQL alpine linux to have LDAP support and then rebuild the TimescaleDB using this new PostgreSQL alpine linux with LDAP support.

The instructions for [installing your TimescaleDB](https://docs.timescale.com/latest/getting-started/installation/docker/installation-docker).
