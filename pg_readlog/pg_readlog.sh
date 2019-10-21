#!/bin/bash

# Variables from Starter Script
server=$1
pg_hostname=$2
pg_database=$3
pg_port=$4
pg_log_directory=$5
pg_temp_log_directory=$6
postgres_bin_directory=$7

#Loop until shutdown
while true; do
        # Grab any data from the last hours logfile
        LOGFILE=`date -d '1 hour ago' "+/pgdata_local/pg_log/postgresql-%F_%H.csv"`;
        logtail $LOGFILE >> $pg_temp_log_directory/logtail.csv;

        # Grab any data from the current logfile
        LOGFILE=`date +"/pgdata_local/pg_log/postgresql-%F_%H.csv"`;
        logtail $LOGFILE >> $pg_temp_log_directory/logtail.csv;

        #Updload the data to the PostgreSQL TimescaleDB Reports database
        if cat $pg_temp_log_directory/logtail.csv | $postgres_bin_directory/psql -h $pg_hostname -d $pg_database -p $pg_port -q -c "CREATE TEMP TABLE upload_logs (LIKE reports.postgres_log);ALTER TABLE upload_logs ALTER COLUMN cluster_name SET DEFAULT '$server';COPY upload_logs (log_time,user_name,database_name,process_id,connection_from,session_id,session_line_num,command_tag,session_start_time,virtual_transaction_id,transaction_id,error_severity,sql_state_code,message,detail,hint,internal_query,internal_query_pos,context,query,query_pos,location,application_name) FROM STDIN (FORMAT CSV);INSERT INTO reports.postgres_log SELECT * FROM upload_logs;"; then
                # If the upload was successful then delete the temporary logtail.csv
                # If the upload failed, then we will append the new data to it until the upload is successful
                rm $pg_temp_log_directory/logtail.csv;
        fi
        sleep 10;
done
