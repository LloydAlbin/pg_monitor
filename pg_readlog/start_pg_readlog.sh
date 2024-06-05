hostname=$(hostname -s)
nohup pg_readlog.sh $hostname <timescaledb_server> pgmonitor_db 30002 /pgdata_local/pg_log /pgdata_local /usr/local/postgres-current/bin logtail.csv 5 &
