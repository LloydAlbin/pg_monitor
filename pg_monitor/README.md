# pg_monitor

pg_monitor gets the live stats from your PostgreSQL database and stores them in your TimescaleDB database.

* pg_monitor.py - Monitoring script
* pg_monitor.service - Monoring service file

NOTE: THIS CODE IS FOR THE ORGINAL PRIVATE DATABASE STRUCTURE AND NEEDS TO BE REFACTORED FOR THE NEW PUBLIC DATABASE STRUCTURE.
I have done a quick refactor but have not yet tested this code.

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
