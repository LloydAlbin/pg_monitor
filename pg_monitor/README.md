# pg_monitor

pg_monitor gets the live stats from your PostgreSQL database and stores them in your TimescaleDB database.

* pg_monitor.py - Monitoring script
* pg_monitor.service - Monoring service file

## Requirements

* python3
* psycopg2
* daemon

## Install Requirements

```bash
sudo apt install python3
sudo apt install python3-psycopg2
sudo apt install python3-daemon
```

## NEED TO DO

* Create Service file
* Check to see if licensed or not and if not then drop chunks manually
* Update tools.cretae_stats() to create the tables, chunk properties, aggregates, etc like the init_timescaledb.sql does.
