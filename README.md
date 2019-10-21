# pg_monitor
pg_monitor is a tech stack to monitor Hardware, PostgreSQL Live and PostgreSQL Logs

This tech stack includes the following:
* collectd - Collecting Hardware Stats
* graphite - Viewing Hardware Stats (Intermeadite View)
* [timescaledb](https://github.com/LloydAlbin/pg_monitor/tree/master/timescaledb) - PostgreSQL TimescaleDB database for storing PostgreSQL Live stats and Log Stats.
* [pg_readlog](https://github.com/LloydAlbin/pg_monitor/tree/master/pg_readlog) - Collecting PostgreSQL Log Stats
* [pg_monitor](https://github.com/LloydAlbin/pg_monitor/tree/master/pg_monitor) - Collecting PostgreSQL Live Stats
* grafana - Viewing All Stats (Final View)
