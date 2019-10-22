# pg_monitor
pg_monitor is a tech stack to monitor Hardware, PostgreSQL Live and PostgreSQL Logs

PLEASE NOTE: This is not even alpha code at this time. Right now I am copying the files I use at work into this repository and writing direction for doing the install. Once I have a base working copy here, I will remove this note.

This tech stack includes the following:
* [graphite](https://github.com/LloydAlbin/pg_monitor/tree/master/graphite) - Viewing Hardware Stats (Intermeadite View)
* [collectd](https://github.com/LloydAlbin/pg_monitor/tree/master/collectd) - Collecting Hardware Stats
* [timescaledb](https://github.com/LloydAlbin/pg_monitor/tree/master/timescaledb) - PostgreSQL TimescaleDB database for storing PostgreSQL Live stats and Log Stats.
* [pg_readlog](https://github.com/LloydAlbin/pg_monitor/tree/master/pg_readlog) - Collecting PostgreSQL Log Stats
* [pg_monitor](https://github.com/LloydAlbin/pg_monitor/tree/master/pg_monitor) - Collecting PostgreSQL Live Stats
* [grafana](https://github.com/LloydAlbin/pg_monitor/tree/master/grafana) - Viewing All Stats (Final View)
