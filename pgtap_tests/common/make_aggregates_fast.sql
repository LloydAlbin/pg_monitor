DO $$
DECLARE
	r RECORD;
    sql TEXT;
    done BOOLEAN;
BEGIN
    FOR r IN SELECT 
        schema_name, 
        table_name, 
        time_column_name, 
        continous_agg_additional_fields, 
        unnest(continous_agg_bucket_width) AS continous_agg_bucket_width, 
        unnest(continous_agg_refresh_lag) AS continous_agg_refresh_lag,
        unnest(continous_agg_refresh_interval) AS continous_agg_refresh_interval, 
        unnest(continous_agg_max_interval_per_job) AS continous_agg_max_interval_per_job,
        continous_agg_aggregate,
        continous_agg_view_aggregate 
      FROM tools.hypertables WHERE continous_agg_bucket_width IS NOT NULL LOOP
      IF r.continous_agg_bucket_width = '1mon' OR r.continous_agg_bucket_width = '1y' THEN
      ELSE
		sql := 'ALTER VIEW ' || quote_ident(r.schema_name) || '.' || quote_ident(r.table_name || '_' || r.continous_agg_bucket_width)  || E' SET (timescaledb.refresh_interval=''' || r.continous_agg_bucket_width  || E''', timescaledb.refresh_lag=''-' || r.continous_agg_bucket_width::interval || E''', timescaledb.max_interval_per_job=''365 days'')';  
        done := FALSE;
        WHILE NOT done LOOP
            BEGIN
		        EXECUTE sql;
                done := TRUE;
            EXCEPTION WHEN OTHERS THEN
                PERFORM pg_sleep(5);
            END;
        END LOOP;
      END IF;

    END LOOP;
END $$;
