DO $$
DECLARE
  r RECORD;
BEGIN
    FOR r IN SELECT 
        schema_name, 
        table_name, 
        unnest(continous_agg_bucket_width) AS continous_agg_bucket_width
      FROM tools.hypertables WHERE continous_agg_bucket_width IS NOT NULL LOOP
        EXECUTE 'DROP VIEW IF EXISTS ' || quote_ident(r.schema_name) || '.' || quote_ident(r.table_name || '_' || r.continous_agg_bucket_width) || ' CASCADE;';
    END LOOP;
END $$;
