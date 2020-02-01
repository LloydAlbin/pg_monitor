SET ROLE grafana;

DO $$
DECLARE
  r RECORD;
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
        EXECUTE 'CREATE VIEW ' || quote_ident(r.schema_name) || '.' || quote_ident(r.table_name || '_' || r.continous_agg_bucket_width) || '
AS
SELECT tools.time_bucket(''' || r.continous_agg_bucket_width || '''::interval, ' || quote_ident(r.time_column_name) || ') AS ' || quote_ident(r.time_column_name) || ', ' || r.continous_agg_additional_fields || ', ' || r.continous_agg_view_aggregate || ' AS "value"
FROM ' || quote_ident(r.schema_name) || '.' || quote_ident(r.table_name || '_1d') || '
GROUP BY tools.time_bucket(''' || r.continous_agg_bucket_width || '''::interval, ' || quote_ident(r.time_column_name) || '), ' || r.continous_agg_additional_fields || '
ORDER BY tools.time_bucket(''' || r.continous_agg_bucket_width || '''::interval, ' || quote_ident(r.time_column_name) || '), ' || r.continous_agg_additional_fields || ';
ALTER TABLE ' || quote_ident(r.schema_name) || '.' || quote_ident(r.table_name) || '_' || r.continous_agg_bucket_width || ' OWNER TO grafana;';
      ELSE
        EXECUTE 'CREATE VIEW ' || quote_ident(r.schema_name) || '.' || quote_ident(r.table_name || '_' || r.continous_agg_bucket_width)  || '
WITH (timescaledb.continuous, timescaledb.max_interval_per_job = ''' || r.continous_agg_max_interval_per_job || ''', timescaledb.refresh_lag = ''' || r.continous_agg_refresh_lag || ''', timescaledb.refresh_interval = ''' || r.continous_agg_refresh_interval || ''')
AS
SELECT public.time_bucket(''' || r.continous_agg_bucket_width || '''::interval, ' || quote_ident(r.time_column_name) || ') AS ' || quote_ident(r.time_column_name) || ', ' || r.continous_agg_additional_fields || ', ' || r.continous_agg_aggregate || ' AS "value"
FROM ' || quote_ident(r.schema_name) || '.' || quote_ident(r.table_name) || '
GROUP BY public.time_bucket(''' || r.continous_agg_bucket_width || '''::interval, ' || quote_ident(r.time_column_name) || '), ' || r.continous_agg_additional_fields || ';
ALTER TABLE ' || quote_ident(r.schema_name) || '.' || quote_ident(r.table_name) || '_' || r.continous_agg_bucket_width || ' OWNER TO grafana;';
      END IF;


    END LOOP;
END $$;
