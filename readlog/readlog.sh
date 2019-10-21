#!/bin/bash
server=$1
while true; do
LOGFILE=`date -d '1 hour ago' "+/pgdata_local/pg_log/postgresql-%F_%H.csv"`;
logtail $LOGFILE >> /pgdata_local/logtail.csv;
LOGFILE=`date +"/pgdata_local/pg_log/postgresql-%F_%H.csv"`;
logtail $LOGFILE >> /pgdata_local/logtail.csv;
if cat /pgdata_local/logtail.csv | /usr/local/postgres-current/bin/psql -h kw-alpha-m03.pc.scharp.org -d reports -p 30002 -q -c "CREATE TEMP TABLE upload_logs (LIKE reports.postgres_log);ALTER TABLE upload_logs ALTER COLUMN cluster_name SET DEFAULT '$server';COPY upload_logs (log_time,user_name,database_name,process_id,connection_from,session_id,session_line_num,command_tag,session_start_time,virtual_transaction_id,transaction_id,error_severity,sql_state_code,message,detail,hint,internal_query,internal_query_pos,context,query,query_pos,location,application_name) FROM STDIN (FORMAT CSV);INSERT INTO reports.postgres_log SELECT * FROM upload_logs;"; then
        rm /pgdata_local/logtail.csv;
fi
sleep 10;
done
