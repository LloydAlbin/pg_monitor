# tiemscaledb
PostgreSQL TimescaleDB server for creating our Reports database.

* [TimescaelDB](https://www.timescale.com/products) - Timescale Database
* init_timescaledb.sql - Script to create a fresh Reports timescale database
* upgrade.sql - Script to upgrade your Reports timescale database with new features

You may either use a standard PostgreSQL database with the TiemscaleDB extension installed or use the TiemscaleDB docker image. In my case, I needed to rebuild the TimescaleDB dcoker image to include LDAP support.

The instructions for [installing your TimescaleDB](https://docs.timescale.com/latest/getting-started/installation/docker/installation-docker).
