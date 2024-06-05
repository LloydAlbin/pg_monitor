#!/bin/bash

# Variables from Starter Script
server=$1
pg_hostname=$2
pg_database=$3
pg_port=$4
pg_log_directory=$5
pg_temp_log_directory=$6
postgres_bin_directory=$7
pg_temp_logfile=$8
pg_sleep=$9 # This variable while not used for pg_reprocess = true, is still a required variable due to the code style used
pg_reprocess=${10} # {} needed for multi digit variables # This variable is optional

pg_version=$($postgres_bin_directory/psql -h localhost -d sandbox --no-align --tuples-only --quiet -c "SELECT split_part(setting, '.', 1) FROM pg_settings WHERE name = 'server_version';")

# Do not perform this check if running manually and there is already a background process running.
# The 3 instances of pg_readlog: 1) start_pg_readlog.sh 2) pg_readlog.sh 3) grep "pg_readlog.sh"
if [ "$pg_reprocess" = "" ]; then
        # Check to see if pg_readlog.sh is already running and if so, exit.
        if [[ $(ps aux | grep "pg_readlog.sh" | wc -l) -ne 3 ]]; then
                echo "Exiting pg_readlog.sh due to duplicate process";
                ps aux | grep "pg_readlog.sh";
                exit 2;
        fi
fi

#Loop until shutdown
while true; do
        # Checks to see if we can contact the postgres server. This keeps us from spooling up the logtail.csv until the server runs out of space.
        # If the server is down for more than 2 hours, then there will be a gap in the log files that will need to be taken care of manually, unless this file is updated to take care of that issue.
        # This adds several log lines per 10 seconds, so I have disabled this until I can make this less chatty.
        if [ "$pg_reprocess" = "" ]; then
                # Grab any data from the last hours logfile
                LOGFILE=`date -d '1 hour ago' "+$pg_log_directory/postgresql-%F_%H.csv"`;
                if [ -f $LOGFILE ]; then
                        logtail $LOGFILE >> $pg_temp_log_directory/$pg_temp_logfile;
                fi

                # Grab any data from the current logfile
                LOGFILE=`date +"$pg_log_directory/postgresql-%F_%H.csv"`;
                if [ -f $LOGFILE ]; then
                        logtail $LOGFILE >> $pg_temp_log_directory/$pg_temp_logfile;
                fi
        fi

        #Updload the data to the PostgreSQL TimescaleDB Reports database
        if [ $pg_version -ge 14 ]; then
                # PG 14
                if cat $pg_temp_log_directory/$pg_temp_logfile | $postgres_bin_directory/psql -h $pg_hostname -d $pg_database -p $pg_port -q -c "CREATE TEMP TABLE upload_logs (LIKE logs.postgres_log);ALTER TABLE upload_logs ALTER COLUMN cluster_name SET DEFAULT '$server';COPY upload_logs (log_time,user_name,database_name,process_id,connection_from,session_id,session_line_num,command_tag,session_start_time,virtual_transaction_id,transaction_id,error_severity,sql_state_code,message,detail,hint,internal_query,internal_query_pos,context,query,query_pos,location,application_name,backend_type,leader_pid,query_id) FROM STDIN (FORMAT CSV);INSERT INTO logs.postgres_log SELECT * FROM upload_logs;"; then
                        # If the upload was successful then delete the temporary logtail.csv
                        # If the upload failed, then we will append the new data to it until the upload is successfu
                        rm $pg_temp_log_directory/$pg_temp_logfile;
                fi
        elif [ $pg_version == "13"  ]; then
                # PG 13
                if cat $pg_temp_log_directory/$pg_temp_logfile | $postgres_bin_directory/psql -h $pg_hostname -d $pg_database -p $pg_port -q -c "CREATE TEMP TABLE upload_logs (LIKE logs.postgres_log);ALTER TABLE upload_logs ALTER COLUMN cluster_name SET DEFAULT '$server';COPY upload_logs (log_time,user_name,database_name,process_id,connection_from,session_id,session_line_num,command_tag,session_start_time,virtual_transaction_id,transaction_id,error_severity,sql_state_code,message,detail,hint,internal_query,internal_query_pos,context,query,query_pos,location,application_name,backend_type) FROM STDIN (FORMAT CSV);INSERT INTO logs.postgres_log SELECT * FROM upload_logs;"; then
                        # If the upload was successful then delete the temporary logtail.csv
                        # If the upload failed, then we will append the new data to it until the upload is successfu
                        rm $pg_temp_log_directory/$pg_temp_logfile;
                fi
        else
                # PG 12 and less
                if cat $pg_temp_log_directory/$pg_temp_logfile | $postgres_bin_directory/psql -h $pg_hostname -d $pg_database -p $pg_port -q -c "CREATE TEMP TABLE upload_logs (LIKE logs.postgres_log);ALTER TABLE upload_logs ALTER COLUMN cluster_name SET DEFAULT '$server';COPY upload_logs (log_time,user_name,database_name,process_id,connection_from,session_id,session_line_num,command_tag,session_start_time,virtual_transaction_id,transaction_id,error_severity,sql_state_code,message,detail,hint,internal_query,internal_query_pos,context,query,query_pos,location,application_name,backend_type,leader_pid) FROM STDIN (FORMAT CSV);INSERT INTO logs.postgres_log SELECT * FROM upload_logs;"; then
                        # If the upload was successful then delete the temporary logtail.csv
                        # If the upload failed, then we will append the new data to it until the upload is successful
                        rm $pg_temp_log_directory/$pg_temp_logfile;
                fi
        fi

        if [ "$pg_reprocess" = "" ]; then
                sleep $pg_sleep;
        else
                exit;
        fi
done
