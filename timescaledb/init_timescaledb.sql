\set pgmonitor_version 2
\set hash_partitions 20
SET client_encoding = 'UTF8';
SELECT pg_catalog.set_config('search_path', '', false);

-- Create grafana user
CREATE USER grafana LOGIN IN ROLE pg_monitor;

\set ON_ERROR_STOP true

-- Create pgmonitor_db database
CREATE DATABASE pgmonitor_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US' LC_CTYPE = 'en_US';
ALTER DATABASE pgmonitor_db OWNER TO grafana;
--GRANT CREATE ON DATABASE pgmonitor_db TO grafana;

-- Connect to pgmonitor_db database
\connect pgmonitor_db
\set ON_ERROR_STOP true

SET client_encoding = 'UTF8';
SELECT pg_catalog.set_config('search_path', '', false);

-- Install TimescaleDB Extension
CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;
COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data';

-- Create logs schema
CREATE SCHEMA logs;
ALTER SCHEMA logs OWNER TO grafana;

-- Create logs schema
CREATE SCHEMA stats;
ALTER SCHEMA stats OWNER TO grafana;

-- Create tools schema
CREATE SCHEMA tools;
ALTER SCHEMA tools OWNER TO grafana;

CREATE TABLE tools.version (
  db_version TEXT
);
ALTER TABLE tools.version OWNER TO grafana;
INSERT INTO tools.version VALUES (:pgmonitor_version);

-- TABLES: logs
CREATE TABLE stats.pg_settings (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    name text,
    setting text,
    unit text,
    category text,
    short_desc text,
    extra_desc text,
    context text,
    vartype text,
    source text,
    min_val text,
    max_val text,
    enumvals text[],
    boot_val text,
    reset_val text,
    sourcefile text,
    sourceline integer,
    pending_restart boolean
);
ALTER TABLE stats.pg_settings OWNER TO grafana;
CREATE INDEX pg_settings_cluster_name_log_time_idx ON stats.pg_settings USING btree (cluster_name, log_time DESC);
CREATE INDEX pg_settings_log_time_idx ON stats.pg_settings USING btree (log_time DESC);

CREATE TABLE stats.pg_stat_activity (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name,
    pid integer,
    state text,
    application_name text,
    backend_type text,
    wait_event_type text,
    wait_event text,
    backend_start timestamp with time zone,
    xact_start timestamp with time zone,
    query_start timestamp with time zone,
    state_change timestamp with time zone,
    backend_xmin xid
);
ALTER TABLE stats.pg_stat_activity OWNER TO grafana;
CREATE INDEX pg_stat_activity_cluster_name_log_time_idx ON stats.pg_stat_activity USING btree (cluster_name, log_time DESC);
CREATE INDEX pg_stat_activity_log_time_idx ON stats.pg_stat_activity USING btree (log_time DESC);

CREATE TABLE stats.autovacuum_count (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name,
    count bigint
);
ALTER TABLE stats.autovacuum_count OWNER TO grafana;
CREATE INDEX auto_vacuumcount_cluster_name_log_time_idx ON stats.autovacuum_count USING btree (cluster_name, log_time DESC);
CREATE INDEX auto_vacuumcount_log_time_idx ON stats.autovacuum_count USING btree (log_time DESC);

CREATE TABLE stats.replication_status (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    status text
);
ALTER TABLE stats.replication_status OWNER TO grafana;
CREATE INDEX replication_status_cluster_name_log_time_idx ON stats.replication_status USING btree (cluster_name, log_time DESC);
CREATE INDEX replication_status_log_time_idx ON stats.replication_status USING btree (log_time DESC);

CREATE TABLE stats.autovacuum (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name,
    schema_name text,
    table_name text,
    name text,
    vacuum boolean,
    "analyze" boolean,
    running_time integer,
    phase text,
    heap_blks_total bigint,
    heap_blks_total_size bigint,
    heap_blks_scanned bigint,
    heap_blks_scanned_pct numeric,
    heap_blks_vacuumed bigint,
    heap_blks_vacuumed_pct numeric,
    index_vacuum_count bigint,
    max_dead_tuples bigint,
    num_dead_tuples bigint,
    backend_start timestamp with time zone,
    wait_event_type text,
    wait_event text,
    state text,
    backend_xmin xid
);
ALTER TABLE stats.autovacuum OWNER TO grafana;
CREATE INDEX autovacuum_cluster_name_log_time_idx ON stats.autovacuum USING btree (cluster_name, log_time DESC);
CREATE INDEX autovacuum_log_time_idx ON stats.autovacuum USING btree (log_time DESC);

CREATE TABLE stats.pg_database (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name
);
ALTER TABLE stats.pg_database OWNER TO grafana;
CREATE INDEX pg_database_cluster_name_log_time_idx ON stats.pg_database USING btree (cluster_name, log_time DESC);
CREATE INDEX pg_database_log_time_idx ON stats.pg_database USING btree (log_time DESC);

CREATE TABLE stats.granted_locks (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name,
    "Time" double precision,
    "PG Process ID" integer,
    "Application Name" text,
    "Transaction Start" timestamp with time zone,
    "Locks" text,
    "AutoVacuum" text
);
ALTER TABLE stats.granted_locks OWNER TO grafana;
CREATE INDEX granted_locks_cluster_name_log_time_idx ON stats.granted_locks USING btree (cluster_name, log_time DESC);
CREATE INDEX granted_locks_log_time_idx ON stats.granted_locks USING btree (log_time DESC);

CREATE TABLE stats.table_stats (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name,
    schema_name name,
    table_name name,
    name text,
    last_vacuum timestamp with time zone,
    last_analyze timestamp with time zone,
    last_autovacuum timestamp with time zone,
    last_autoanalyze timestamp with time zone,
    "time" timestamp with time zone
);
ALTER TABLE stats.table_stats OWNER TO grafana;
CREATE INDEX table_stats_cluster_name_log_time_idx ON stats.table_stats USING btree (cluster_name, log_time DESC);
CREATE INDEX table_stats_log_time_idx ON stats.table_stats USING btree (log_time DESC);

CREATE TABLE stats.custom_table_settings (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name,
    schema_name name,
    table_name name,
    "Table Name" text,
    "Table Setting" text
);
ALTER TABLE stats.custom_table_settings OWNER TO grafana;
CREATE INDEX custom_table_settings_cluster_name_log_time_idx ON stats.custom_table_settings USING btree (cluster_name, log_time DESC);
CREATE INDEX custom_table_settings_log_time_idx ON stats.custom_table_settings USING btree (log_time DESC);

CREATE TABLE stats.autovacuum_thresholds (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name,
    schema_name name,
    table_name name,
    name text,
    n_tup_ins bigint,
    n_tup_upd bigint,
    n_tup_del bigint,
    n_live_tup bigint,
    n_dead_tup bigint,
    reltuples real,
    av_threshold double precision,
    last_vacuum timestamp with time zone,
    last_analyze timestamp with time zone,
    av_neaded boolean,
    pct_dead numeric
);
ALTER TABLE stats.autovacuum_thresholds OWNER TO grafana;
CREATE INDEX autovacuum_thresholds_cluster_name_log_time_idx ON stats.autovacuum_thresholds USING btree (cluster_name, log_time DESC);
CREATE INDEX autovacuum_thresholds_log_time_idx ON stats.autovacuum_thresholds USING btree (log_time DESC);

CREATE TABLE logs.autoanalyze_logs (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name text,
    schema_name text,
    table_name text,
    cpu_system numeric,
    cpu_user numeric,
    elasped_seconds numeric
);
ALTER TABLE logs.autoanalyze_logs OWNER TO grafana;
CREATE INDEX autoanalyze_logs_cluster_name_time_idx ON logs.autoanalyze_logs USING btree (cluster_name, log_time DESC);
CREATE INDEX autoanalyze_logs_time_idx ON logs.autoanalyze_logs USING btree (log_time DESC);

CREATE TABLE logs.autovacuum_logs (
    log_time timestamp(3) with time zone NOT NULL,
    cluster_name text,
    database_name text,
    schema_name text,
    table_name text,
    index_scans bigint,
    pages_removed bigint,
    removed_size bigint,
    pages_remain bigint,
    pages_remain_size bigint,
    skipped_due_to_pins bigint,
    skipped_frozen bigint,
    tuples_removed bigint,
    tuples_remain bigint,
    tuples_dead bigint,
    oldest_xmin bigint,
    buffer_hits bigint,
    buffer_misses bigint,
    buffer_dirtied bigint,
    buffer_dirtied_size bigint,
    avg_read_rate numeric,
    avg_write_rate numeric,
    cpu_system numeric,
    cpu_user numeric,
    elasped_seconds numeric
);
ALTER TABLE logs.autovacuum_logs OWNER TO grafana;
CREATE INDEX autovacuum_logs_cluster_name_time_idx ON logs.autovacuum_logs USING btree (cluster_name, log_time DESC);
CREATE INDEX autovacuum_logs_time_idx ON logs.autovacuum_logs USING btree (log_time DESC);

CREATE TABLE logs.lock_logs (
    lock_type text,
    object_type text,
    relation_id text,
    transaction_id2 xid,
    class_id oid,
    relation_tuple tid,
    database_id oid,
    wait_time numeric,
    cluster_name text,
    log_time timestamp(3) with time zone NOT NULL,
    user_name text,
    database_name text,
    process_id integer,
    connection_from text,
    session_id text,
    session_line_num bigint,
    command_tag text,
    session_start_time timestamp with time zone,
    virtual_transaction_id text,
    transaction_id bigint,
    message text,
    internal_query text,
    internal_query_pos integer,
    context text,
    query text,
    query_pos integer,
    location text,
    application_name text
);
ALTER TABLE logs.lock_logs OWNER TO grafana;
CREATE INDEX lock_logs_cluster_name_time_idx ON logs.lock_logs USING btree (cluster_name, log_time DESC);
CREATE INDEX lock_logs_time_idx ON logs.lock_logs USING btree (log_time DESC);

CREATE TABLE logs.checkpoint_warning_logs (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    seconds integer,
    hint text
);
ALTER TABLE logs.checkpoint_warning_logs OWNER TO grafana;
CREATE INDEX checkpoint_warning_logs_cluster_name_time_idx ON logs.checkpoint_warning_logs USING btree (cluster_name, log_time DESC);
CREATE INDEX checkpoint_warning_logs_time_idx ON logs.checkpoint_warning_logs USING btree (log_time DESC);

CREATE TABLE logs.checkpoint_logs (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    wbuffer integer,
    files_added integer,
    file_removed integer,
    file_recycled integer,
    write numeric,
    sync numeric,
    total numeric,
    sync_files integer,
    sync_longest numeric,
    sync_avg numeric,
    distance integer,
    estimate integer
);
ALTER TABLE logs.checkpoint_logs OWNER TO grafana;
CREATE INDEX checkpoint_logs_cluster_name_time_idx ON logs.checkpoint_logs USING btree (cluster_name, log_time DESC);
CREATE INDEX checkpoint_logs_time_idx ON logs.checkpoint_logs USING btree (log_time DESC);

CREATE TABLE logs.postgres_log (
    cluster_name text NOT NULL,
    log_time timestamp with time zone NOT NULL,
    user_name text,
    database_name text,
    process_id integer,
    connection_from text,
    session_id text NOT NULL,
    session_line_num bigint NOT NULL,
    command_tag text,
    session_start_time timestamp with time zone,
    virtual_transaction_id text,
    transaction_id bigint,
    error_severity text,
    sql_state_code text,
    message text,
    detail text,
    hint text,
    internal_query text,
    internal_query_pos integer,
    context text,
    query text,
    query_pos integer,
    location text,
    application_name text
);
ALTER TABLE logs.postgres_log OWNER TO grafana;
CREATE INDEX postgres_log_cluster_name_log_time_idx ON logs.postgres_log USING btree (cluster_name, log_time DESC);
CREATE INDEX postgres_log_log_time_idx ON logs.postgres_log USING btree (log_time DESC);
CREATE INDEX postgres_logs_idx ON logs.postgres_log USING btree (log_time, cluster_name, database_name);
CREATE INDEX postgres_logs_pkey ON logs.postgres_log USING btree (cluster_name, session_id, session_line_num);

CREATE TABLE logs.archive_failure_log (
    cluster_name text NOT NULL,
    log_time timestamp with time zone NOT NULL,
    process_id integer,
    message text,
    detail text
);
ALTER TABLE logs.archive_failure_log OWNER TO grafana;
CREATE INDEX archive_failure_log_cluster_name_log_time_idx ON logs.archive_failure_log USING btree (cluster_name, log_time DESC);
CREATE INDEX archive_failure_log_log_time_idx ON logs.archive_failure_log USING btree (log_time DESC);

CREATE TABLE logs.lock_message_types (
    message text
);
ALTER TABLE logs.lock_message_types OWNER TO grafana;

CREATE TABLE logs.postgres_log_databases (
    cluster_name text NOT NULL,
    database_name text NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone
);
ALTER TABLE logs.postgres_log_databases OWNER TO grafana;
ALTER TABLE ONLY logs.postgres_log_databases
    ADD CONSTRAINT postgres_log_databases_pkey PRIMARY KEY (cluster_name, database_name);


CREATE TABLE logs.postgres_log_databases_temp (
    cluster_name text,
    database_name text,
    min timestamp with time zone,
    max timestamp with time zone
);
ALTER TABLE logs.postgres_log_databases_temp OWNER TO grafana;

-- VIEWS: pgmon
CREATE VIEW stats.autovacuum_length AS
 SELECT b.cluster_name,
    b.database_name,
    COALESCE(max(b.running_time)) AS running_time
   FROM (( SELECT max(autovacuum.log_time) AS log_time
           FROM stats.autovacuum) a
     LEFT JOIN stats.autovacuum b USING (log_time))
  GROUP BY b.cluster_name, b.database_name;
ALTER TABLE stats.autovacuum_length OWNER TO grafana;


-- TABLES: tools
CREATE TABLE tools.servers (
    server_name text NOT NULL,
    server text NOT NULL,
    port integer DEFAULT 5432 NOT NULL,
    maintenance_database name NOT NULL,
    username text,
    password text,
    read_all_databases boolean,
    disabled boolean,
    maintenance_db boolean,
    pgpass_file text
);
ALTER TABLE tools.servers OWNER TO grafana;
ALTER TABLE ONLY tools.servers
    ADD CONSTRAINT servers_pkey PRIMARY KEY (server_name, maintenance_database, port);

CREATE TABLE tools.build_items (
    item_schema name NOT NULL,
    item_name name NOT NULL,
    item_sql text,
    build_order numeric,
    disabled boolean DEFAULT false
);
ALTER TABLE tools.build_items OWNER TO grafana;
ALTER TABLE ONLY tools.build_items
    ADD CONSTRAINT build_items_idx PRIMARY KEY (item_schema, item_name);

CREATE TABLE tools.queries_disabled (
    server_name text NOT NULL,
    database_name text NOT NULL,
    port integer DEFAULT 5432 NOT NULL,
    query_name text
);
ALTER TABLE tools.queries_disabled OWNER TO grafana;

-- tools.query
CREATE TABLE tools.query (
    query_name text NOT NULL,
    sql text,
    disabled boolean,
    maintenance_db_only boolean,
    pg_version numeric,
    run_order integer,
    schema_name name,
    table_name name
);
ALTER TABLE tools.query OWNER TO grafana;
COMMENT ON COLUMN tools.query.query_name IS 'Name of the query';
COMMENT ON COLUMN tools.query.sql IS 'SQL, Do not include the ; at the end of the query';
COMMENT ON COLUMN tools.query.disabled IS 'Disable this query';
COMMENT ON COLUMN tools.query.maintenance_db_only IS 'Only run on the maintenance_db aka once per server';
COMMENT ON COLUMN tools.query.pg_version IS 'Postgres must be this version or greater';
COMMENT ON COLUMN tools.query.run_order IS 'This is the order that the queries will be processed';
COMMENT ON COLUMN tools.query.schema_name IS 'The schema in the reports db that this is to be written to.';
COMMENT ON COLUMN tools.query.table_name IS 'The table in the reports db that this is to be written to.';
ALTER TABLE ONLY tools.query
    ADD CONSTRAINT query_pkey UNIQUE (query_name, pg_version);

-- VIEWS: pgmon
CREATE VIEW stats.databases AS
 SELECT DISTINCT cpd.cluster_name,
    cpd.database_name
   FROM (tools.servers s
     LEFT JOIN stats.pg_database cpd ON ((s.server_name = cpd.cluster_name)))
  WHERE (((s.read_all_databases IS TRUE) OR ((s.maintenance_database = cpd.database_name) AND (s.read_all_databases IS FALSE))) AND (cpd.database_name <> ALL (ARRAY['template0'::name, 'template1'::name, 'rdsadmin'::name])))
  ORDER BY cpd.cluster_name, cpd.database_name;
ALTER TABLE stats.databases OWNER TO grafana;

CREATE VIEW tools.hypertable AS
 SELECT ht.schema_name AS table_schema,
    ht.table_name,
    t.tableowner AS table_owner,
    ht.num_dimensions,
    ( SELECT count(1) AS count
           FROM _timescaledb_catalog.chunk ch
          WHERE (ch.hypertable_id = ht.id)) AS num_chunks,
    size.table_size,
    size.index_size,
    size.toast_size,
    size.total_size
   FROM ((_timescaledb_catalog.hypertable ht
     LEFT JOIN pg_tables t ON (((ht.table_name = t.tablename) AND (ht.schema_name = t.schemaname))))
     LEFT JOIN LATERAL public.hypertable_relation_size((
        CASE
            WHEN has_schema_privilege((ht.schema_name)::text, 'USAGE'::text) THEN format('%I.%I'::text, ht.schema_name, ht.table_name)
            ELSE NULL::text
        END)::regclass) size(table_size, index_size, toast_size, total_size) ON (true));
ALTER TABLE tools.hypertable OWNER TO grafana;

CREATE VIEW logs.last_log_entries AS
 SELECT postgres_log.cluster_name,
    min(postgres_log.log_time) AS first_log_time,
    max(postgres_log.log_time) AS last_log_time
   FROM logs.postgres_log
  GROUP BY postgres_log.cluster_name;
ALTER TABLE logs.last_log_entries OWNER TO grafana;

-- VIEWS: tools
CREATE VIEW tools.table_size AS
 SELECT now() AS log_time,
    current_setting('cluster_name'::text) AS cluster_name,
    tables.table_catalog AS database_name,
    tables.table_schema AS schema_name,
    tables.table_name,
    ((quote_ident((tables.table_schema)::text) || '.'::text) || quote_ident((tables.table_name)::text)) AS name,
    pg_relation_size((((quote_ident((tables.table_schema)::text) || '.'::text) || quote_ident((tables.table_name)::text)))::regclass) AS table_size,
    pg_size_pretty(pg_relation_size((((quote_ident((tables.table_schema)::text) || '.'::text) || quote_ident((tables.table_name)::text)))::regclass)) AS table_size_pretty,
    pg_indexes_size((((quote_ident((tables.table_schema)::text) || '.'::text) || quote_ident((tables.table_name)::text)))::regclass) AS index_size,
    pg_size_pretty(pg_indexes_size((((quote_ident((tables.table_schema)::text) || '.'::text) || quote_ident((tables.table_name)::text)))::regclass)) AS index_size_pretty,
    pg_total_relation_size((((quote_ident((tables.table_schema)::text) || '.'::text) || quote_ident((tables.table_name)::text)))::regclass) AS total_size,
    pg_size_pretty(pg_total_relation_size((((quote_ident((tables.table_schema)::text) || '.'::text) || quote_ident((tables.table_name)::text)))::regclass)) AS total_size_pretty,
    now() AS "time"
   FROM information_schema.tables
  WHERE (((tables.table_type)::text = 'BASE TABLE'::text) AND ((tables.table_schema)::text <> ALL (ARRAY[('information_schema'::character varying)::text, ('pg_catalog'::character varying)::text])));
ALTER TABLE tools.table_size OWNER TO grafana;

CREATE VIEW tools.pg_major_version AS
 SELECT ((((current_setting('server_version_num'::text))::integer / 10000))::numeric + (((((current_setting('server_version_num'::text))::integer / 100) - (((current_setting('server_version_num'::text))::integer / 10000) * 100)))::numeric / (10)::numeric)) AS major_version;
ALTER TABLE tools.pg_major_version OWNER TO grafana;

-- Trigger to process RAW log records into specialized tables.
CREATE FUNCTION tools.postgres_log_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
/*
    -- Removed due to slowing down the inserts to much and getting deadlocks that postgres will not resolve.
	IF (NEW.database_name IS NOT NULL) THEN
	-- Maintain logs.postgres_log_databases
		INSERT INTO logs.postgres_log_databases AS a (cluster_name, database_name, start_date, end_date)
			VALUES (NEW.cluster_name, NEW.database_name, NEW.log_time, NEW.log_time) 
			ON CONFLICT (cluster_name, database_name) DO UPDATE SET
				start_date = CASE WHEN a.start_date > EXCLUDED.start_date THEN EXCLUDED.start_date ELSE a.start_date END,
				end_date = CASE WHEN a.end_date < EXCLUDED.end_date THEN EXCLUDED.end_date ELSE a.end_date END;
    END IF;
*/

	IF (NEW.message LIKE 'automatic vacuum %') THEN
	-- Move autovacuum log records from logs.postgres_log into the logs.autovacuum_logs
    
    
    	INSERT INTO logs.autovacuum_logs VALUES (NEW.log_time,
    NEW.cluster_name,
    split_part(trim(both '"' from substr(split_part(split_part(NEW.message, E'\n', 1), ':', 1),27)), '.', 1),
    split_part(trim(both '"' from substr(split_part(split_part(NEW.message, E'\n', 1), ':', 1),27)), '.', 2),
    split_part(trim(both '"' from substr(split_part(split_part(NEW.message, E'\n', 1), ':', 1),27)), '.', 3),
    trim(split_part(split_part(NEW.message, E'\n', 1), ':', 3))::BIGINT,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 1)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 1)), ' ', 1)::bigint * setting('block_size')::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 2)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 2)), ' ', 1)::bigint * setting('block_size')::bigint,
    CASE WHEN split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 3)), ' ', 1) = '' THEN NULL::bigint ELSE split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 3)), ' ', 1)::bigint END,
    CASE WHEN split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 4)), ' ', 1) = '' THEN NULL::bigint ELSE split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 3)), ' ', 1)::bigint END,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 3), ':', 2), ',', 1)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 3), ':', 2), ',', 2)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 3), ':', 2), ',', 3)), ' ', 1)::bigint,
    CASE WHEN split_part(split_part(NEW.message, E'\n', 3), ':', 3) = '' THEN NULL::bigint ELSE split_part(split_part(NEW.message, E'\n', 3), ':', 3)::bigint END,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 4), ':', 2), ',', 1)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 4), ':', 2), ',', 2)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 4), ':', 2), ',', 3)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 4), ':', 2), ',', 3)), ' ', 1)::bigint * setting('block_size')::bigint,
    split_part(trim(split_part(split_part(NEW.message, E'\n', 5), ':', 2)), ' ', 1)::NUMERIC,
    split_part(trim(split_part(split_part(NEW.message, E'\n', 5), ':', 3)), ' ', 1)::NUMERIC,
    CASE WHEN strpos(split_part(NEW.message, E'\n', 6), E'/') > 0 
    	THEN left(split_part(split_part(trim(split_part(split_part(NEW.message, E'\n', 6), ':', 2)), ' ', 2), E'/', 1),-1)::numeric
    	ELSE split_part(trim(split_part(split_part(NEW.message, E'\n', 6), ':', 5)), ' ', 1)::numeric END,    
    CASE WHEN strpos(split_part(NEW.message, E'\n', 6), E'/') > 0 
    	THEN left(split_part(split_part(trim(split_part(split_part(NEW.message, E'\n', 6), ':', 2)), ' ', 2), E'/', 2),-1)::numeric
    	ELSE split_part(trim(split_part(split_part(NEW.message, E'\n', 6), ':', 4)), ' ', 1)::numeric END,    
    CASE WHEN strpos(split_part(NEW.message, E'\n', 6), E'/') > 0 
    	THEN split_part(trim(split_part(split_part(NEW.message, E'\n', 6), ':', 2)), ' ', 5)::numeric
    	ELSE split_part(trim(split_part(split_part(NEW.message, E'\n', 6), ':', 6)), ' ', 1)::numeric END);
    	RETURN NULL;
        
        
	ELSIF (NEW.message LIKE 'automatic analyze%') THEN
	-- Move autoanalyze log records from logs.postgres_log into the logs.autoanalyze_logs
    
    
    	INSERT INTO logs.autoanalyze_logs VALUES (NEW.log_time,
    NEW.cluster_name,
        split_part(trim(both '"' from split_part(NEW.message, '"', 2)), '.', 1),
    split_part(trim(both '"' from split_part(NEW.message, '"', 2)), '.', 2),
    split_part(trim(both '"' from split_part(NEW.message, '"', 2)), '.', 3),
    CASE WHEN strpos(split_part(NEW.message, E':', 2), E'/') > 0 
    	THEN left(split_part(split_part(trim(split_part(NEW.message, E':', 2)), ' ', 2), E'/', 1),-1)::numeric
    	ELSE split_part(trim(split_part(split_part(NEW.message, E':', 4), ',', 1)), ' ', 1)::numeric END,
    CASE WHEN strpos(split_part(NEW.message, E':', 2), E'/') > 0 
    	THEN left(split_part(split_part(trim(split_part(NEW.message, E':', 2)), ' ', 2), E'/', 2),-1)::numeric
    	ELSE split_part(trim(split_part(split_part(NEW.message, E':', 5), ',', 1)), ' ', 1)::numeric END,    
    CASE WHEN strpos(split_part(NEW.message, E':', 2), E'/') > 0 
    	THEN trim(split_part(split_part(NEW.message, E':', 2), ' ', 6))::numeric
    	ELSE split_part(trim(split_part(split_part(NEW.message, E':', 6), ',', 1)), ' ', 1) ::numeric END
    );
    	RETURN NULL;
        

	ELSIF (NEW.message LIKE 'process%acquired%') THEN
	-- Move lock log records from logs.postgres_log into the logs.lock_logs


		INSERT INTO logs.lock_logs VALUES (
	split_part(NEW.message, ' ', 4)::TEXT,  
	CASE split_part(NEW.message, ' ', 6)
    	WHEN 'extension' THEN (split_part(NEW.message, ' ', 6) || ' ' || split_part(NEW.message, ' ', 7) || ' ' || split_part(NEW.message, ' ', 8))::TEXT
    	ELSE split_part(NEW.message, ' ', 6)::TEXT 
    END,  
	CASE split_part(NEW.message, ' ', 6)
    	WHEN 'tuple' THEN split_part(NEW.message, ' ', 10)::TEXT
    	WHEN 'relation' THEN NULL::TEXT
    	ELSE split_part(NEW.message, ' ', 7) ::TEXT
    END,  
	CASE split_part(NEW.message, ' ', 6)
    	WHEN 'relation' THEN split_part(NEW.message, ' ', 7)::pg_catalog.xid
    	ELSE NULL::pg_catalog.xid
    END,  
    CASE split_part(NEW.message, ' ', 6) 
    	WHEN 'object' THEN split_part(NEW.message, ' ', 10)::OID
        ELSE NULL::OID
    END,
    CASE split_part(NEW.message, ' ', 6) 
    	WHEN 'tuple' THEN split_part(NEW.message, ' ', 7)::pg_catalog.tid
        ELSE NULL::pg_catalog.tid
    END,
    CASE split_part(NEW.message, ' ', 6) 
    	WHEN 'relation' THEN split_part(NEW.message, ' ', 10)::OID
    	WHEN 'extension' THEN split_part(NEW.message, ' ', 12)::OID
    	WHEN 'tuple' THEN split_part(NEW.message, ' ', 13)::OID
    	WHEN 'object' THEN split_part(NEW.message, ' ', 13)::OID
    	WHEN 'transaction' THEN NULL::OID
        ELSE NULL
    END,
    CASE split_part(NEW.message, ' ', 6) 
    	WHEN 'relation' THEN split_part(NEW.message, ' ', 12)::NUMERIC
    	WHEN 'extension' THEN split_part(NEW.message, ' ', 14)::NUMERIC
    	WHEN 'tuple' THEN split_part(NEW.message, ' ', 15)::NUMERIC
    	WHEN 'object' THEN split_part(NEW.message, ' ', 15)::NUMERIC
    	WHEN 'transaction' THEN split_part(NEW.message, ' ', 9)::NUMERIC
        ELSE NULL::NUMERIC
    END,
	NEW.cluster_name,
	NEW.log_time,
	NEW.user_name,
	NEW.database_name,
	NEW.process_id,
	NEW.connection_from,
	NEW.session_id,
	NEW.session_line_num,
	NEW.command_tag,
	NEW.session_start_time,
	NEW.virtual_transaction_id,
	NEW.transaction_id,
	NEW.message,
	NEW.internal_query,
	NEW.internal_query_pos,
	NEW.context,
	NEW.query,
	NEW.query_pos,
	NEW.location,
	NEW.application_name
    );
    	RETURN NULL;


	ELSIF (NEW.message LIKE 'checkpoints are occurring too frequently%') THEN
	-- Move checkpoint warnings records from logs.postgres_log into the logs.checkpoint_warning_logs

    
    INSERT INTO logs.checkpoint_warning_logs VALUES (
        NEW.log_time,
    	NEW.cluster_name,
		(regexp_match(NEW.message, 'checkpoints are occurring too frequently \((\d+) seconds apart'))[1]::INTEGER, 
        NEW.hint
    );
    	RETURN NULL;


	ELSIF (NEW.message LIKE 'checkpoint complete%') THEN
	-- Move checkpoint records from logs.postgres_log into the logs.checkpoint_logs

    
    INSERT INTO logs.checkpoint_logs VALUES (
        NEW.log_time,
    	NEW.cluster_name,
	(regexp_match(NEW.message, 'point complete: wrote (\d+) buffers \(([^\)]+)\); (\d+) (?:transaction log|WAL) file\(s\) added, (\d+) removed, (\d+) recycled; write=([0-9\.]+) s, sync=([0-9\.]+) s, total=([0-9\.]+) s'))[1]::INTEGER, 
--	(regexp_match(NEW.message, 'point complete: wrote (\d+) buffers \(([^\)]+)\); (\d+) (?:transaction log|WAL) file\(s\) added, (\d+) removed, (\d+) recycled; write=([0-9\.]+) s, sync=([0-9\.]+) s, total=([0-9\.]+) s'))[2]::NUMERIC, 
	(regexp_match(NEW.message, 'point complete: wrote (\d+) buffers \(([^\)]+)\); (\d+) (?:transaction log|WAL) file\(s\) added, (\d+) removed, (\d+) recycled; write=([0-9\.]+) s, sync=([0-9\.]+) s, total=([0-9\.]+) s'))[3]::INTEGER, 
	(regexp_match(NEW.message, 'point complete: wrote (\d+) buffers \(([^\)]+)\); (\d+) (?:transaction log|WAL) file\(s\) added, (\d+) removed, (\d+) recycled; write=([0-9\.]+) s, sync=([0-9\.]+) s, total=([0-9\.]+) s'))[4]::INTEGER,
	(regexp_match(NEW.message, 'point complete: wrote (\d+) buffers \(([^\)]+)\); (\d+) (?:transaction log|WAL) file\(s\) added, (\d+) removed, (\d+) recycled; write=([0-9\.]+) s, sync=([0-9\.]+) s, total=([0-9\.]+) s'))[5]::INTEGER,
	(regexp_match(NEW.message, 'point complete: wrote (\d+) buffers \(([^\)]+)\); (\d+) (?:transaction log|WAL) file\(s\) added, (\d+) removed, (\d+) recycled; write=([0-9\.]+) s, sync=([0-9\.]+) s, total=([0-9\.]+) s'))[6]::NUMERIC,
	(regexp_match(NEW.message, 'point complete: wrote (\d+) buffers \(([^\)]+)\); (\d+) (?:transaction log|WAL) file\(s\) added, (\d+) removed, (\d+) recycled; write=([0-9\.]+) s, sync=([0-9\.]+) s, total=([0-9\.]+) s'))[7]::NUMERIC,
	(regexp_match(NEW.message, 'point complete: wrote (\d+) buffers \(([^\)]+)\); (\d+) (?:transaction log|WAL) file\(s\) added, (\d+) removed, (\d+) recycled; write=([0-9\.]+) s, sync=([0-9\.]+) s, total=([0-9\.]+) s'))[8]::NUMERIC,
	(regexp_match(NEW.message, 'sync files=(\d+), longest=([0-9\.]+) s, average=([0-9\.]+) s'))[1]::INTEGER, 
	(regexp_match(NEW.message, 'sync files=(\d+), longest=([0-9\.]+) s, average=([0-9\.]+) s'))[2]::NUMERIC, 
	(regexp_match(NEW.message, 'sync files=(\d+), longest=([0-9\.]+) s, average=([0-9\.]+) s'))[3]::NUMERIC, 
	(regexp_match(NEW.message, '; distance=(\d+) kB, estimate=(\d+) kB'))[1]::INTEGER,
	(regexp_match(NEW.message, '; distance=(\d+) kB, estimate=(\d+) kB'))[2]::INTEGER
    );
    	RETURN NULL;


	ELSIF (NEW.message LIKE 'archive command failed%') THEN
	-- Move archive failures from logs.postgres_log into the logs.archive_failure_log

    INSERT INTO logs.archive_failure_log VALUES (
    	NEW.cluster_name,
        NEW.log_time,
        NEW.process_id,
        NEW.message,
        NEW.detail
    );
    	RETURN NULL;


    END IF;
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$;
ALTER FUNCTION tools.postgres_log_trigger() OWNER TO grafana;

CREATE FUNCTION tools.create_logs() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  queries RECORD;
  sql TEXT;
BEGIN
  CREATE SCHEMA IF NOT EXISTS logs;
  FOR queries IN SELECT * FROM tools.query WHERE disabled IS FALSE ORDER BY run_order LOOP
    sql := 'CREATE TABLE IF NOT EXISTS ' || quote_ident(queries.schema_name) || '.' || quote_ident(queries.table_name) ||
    ' AS ' || queries.sql || E' LIMIT 0; SELECT create_hypertable(''' || quote_ident(queries.schema_name) || '.' || quote_ident(queries.table_name) ||
    E'''::pg_catalog.regclass, ''log_time''::name, ''cluster_name''::name, 20, NULL::name, NULL::name, NULL::bigint, TRUE, TRUE);'; 
    RAISE NOTICE 'EXECUTE: %', sql;
    -- TRUNCATE TABLE ONLY ' || quote_ident(queries.schema_name) || '.' || quote_ident(queries.table_name);
    EXECUTE sql;
  END LOOP;

  FOR queries IN SELECT * FROM tools.build_items WHERE disabled IS FALSE ORDER BY build_order LOOP
    sql := 'CREATE SCHEMA IF NOT EXISTS ' || quote_ident(queries.item_schema) || '; ' || queries.item_sql;
    EXECUTE sql;
  END LOOP;
END;
$$;
ALTER FUNCTION tools.create_logs() OWNER TO grafana;

CREATE FUNCTION tools.create_server_database_inherits("server_name" text, database_name text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
  tables RECORD;
  sql TEXT;
BEGIN
  sql := 'CREATE SCHEMA IF NOT EXISTS ' || quote_ident($1 || '-' || $2) || ';';
  EXECUTE sql;

  FOR tables IN SELECT t.*, query.maintenance_db_only FROM information_schema.tables t
LEFT JOIN (SELECT DISTINCT ON (schema_name, table_name) * FROM tools.query WHERE disabled = false AND maintenance_db_only = false) AS query
ON (query.schema_name = t.table_schema AND query.table_name = t.table_name)
WHERE table_schema = 'logs' AND t.table_type = 'BASE TABLE' AND query.maintenance_db_only IS NOT NULL LOOP
    sql := 'CREATE TABLE IF NOT EXISTS ' || quote_ident($1 || '-' || $2) || '.' || quote_ident(tables.table_name) ||
    E' ( CHECK ((cluster_name = ''' || $1 || E''' OR cluster_name = ''' || $1 || E'-a'' OR cluster_name = ''' || $1 || E'-b'') ' || 
    E' AND database_name = ''' || $2 || E''') ' ||
    ') INHERITS (' || quote_ident($1) || '.' || quote_ident(tables.table_name) || ');';
    EXECUTE sql;
  END LOOP;
END;
$_$;
ALTER FUNCTION tools.create_server_database_inherits("server_name" text, database_name text) OWNER TO grafana;

CREATE FUNCTION tools.create_server_inherits("server_name" text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
  tables RECORD;
  sql TEXT;
BEGIN
  sql := 'CREATE SCHEMA IF NOT EXISTS ' || quote_ident($1) || ';';
  EXECUTE sql;

  FOR tables IN SELECT * FROM information_schema.tables WHERE table_schema = 'logs' AND table_type = 'BASE TABLE' LOOP
    sql := 'CREATE TABLE IF NOT EXISTS ' || quote_ident($1) || '.' || quote_ident(tables.table_name) ||
    E' ( CHECK (cluster_name = ''' || $1 || E''' OR cluster_name = ''' || $1 || E'-a'' OR cluster_name = ''' || $1 || E'-b'') ' ||
    ') INHERITS (' || quote_ident(tables.table_schema) || '.' || quote_ident(tables.table_name) || ');';
    EXECUTE sql;
  END LOOP;
END;
$_$;
ALTER FUNCTION tools.create_server_inherits("server_name" text) OWNER TO grafana;

CREATE FUNCTION tools.delete_logs() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  tables RECORD;
  fdw RECORD;
  sql TEXT;
BEGIN
  -- DROP SCHEMAS
  FOR tables IN 
  	SELECT DISTINCT table_schema 
    FROM information_schema.tables 
    WHERE table_schema NOT IN ('tools', 'public', 'logs', 'pg_catalog', 'information_schema') 
    AND table_schema NOT LIKE 'pg_temp%' 
    AND table_schema NOT LIKE 'pg_toast%' 
    LOOP
      sql := 'DROP SCHEMA ' || quote_ident(tables.table_schema) || ' CASCADE;';
      RAISE NOTICE '%', sql;
      EXECUTE sql;
  END LOOP;

  -- RECREATE MASTER TABLES
  PERFORM tools.create_logs();

END;
$$;
ALTER FUNCTION tools.delete_logs() OWNER TO grafana;

CREATE FUNCTION tools.field_list_check(field_in text, list_in text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
/*
Using this function:
When creating Grafana Variables:
Set Multi-value = TRUE
Set Include All option = TRUE
Set Custom all value = NULL

Function Testing:
SELECT 
	tools.field_list_check('test', NULL),
	tools.field_list_check('test', $$$$),
    tools.field_list_check('test', $$'test'$$),
    tools.field_list_check('test', $$'testing', 'test'$$),
    tools.field_list_check('test', $$'testing'$$),
    tools.field_list_check('test', $$NULL$$);
-- Returns: TRUE, TRUE, TRUE, TRUE, FALSE, TRUE
*/

DECLARE
  sql TEXT;
  r RECORD;
BEGIN
  IF list_in = '' THEN 
  	RETURN TRUE;
  END IF;
  IF list_in = 'NULL' THEN 
  	RETURN TRUE;
  END IF;
  IF list_in IS NULL THEN 
  	RETURN TRUE;
  END IF;
  sql := E'SELECT CASE WHEN ''' || field_in || E''' IN (' || list_in|| ') THEN TRUE ELSE FALSE END AS field_check';
  EXECUTE sql INTO r;
  RETURN r.field_check;
END;
$_$;
ALTER FUNCTION tools.field_list_check(field_in text, list_in text) OWNER TO grafana;
COMMENT ON FUNCTION tools.field_list_check(field_in text, list_in text) IS 'This function is used when wanting to filter by Grafana Variables.';


CREATE FUNCTION tools.generate_timestamps("interval" text, "between" text) RETURNS TABLE(start_time timestamp with time zone, end_time timestamp with time zone)
    LANGUAGE plpgsql IMMUTABLE
    AS $_X$
/*
This function is designed to be used inside Grafana
tools.generate_timestamps('$__interval', $$$__timeFilter(log_time)$$)

Example:
SET application_name = 'Grafana';
SELECT c.a AS time, c.ldap_error, COALESCE(e.value1,0) AS value1 
FROM (
	SELECT a.*, b.* 
	FROM tools.generate_timestamps('$__interval', $$$__timeFilter(log_time)$$) a,
	(
    	SELECT 
    		trim(split_part(message, ':', 2)) AS ldap_error 
		FROM logs.postgres_log 
		WHERE message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
		GROUP BY 1
     ) b
) c LEFT JOIN (
	SELECT * FROM (
		SELECT  
			date_trunc('minute', log_time) AS time, 
			trim(split_part(message, ':', 2)) AS ldap_error, 
			count(*) AS value1
		FROM logs.postgres_log 
  		WHERE message LIKE 'LDAP login failed for user%' 
  		GROUP BY 1,2
	) d WHERE $__timeFilter(time)
) e ON c.a = e.time AND c.ldap_error = e.ldap_error;
*/
DECLARE
	time RECORD;
    sql TEXT;
BEGIN
	sql := 'WITH RECURSIVE t(n,z) AS (';
    sql = sql || E'VALUES (''' || split_part(between, E'''', 2) || E'''::timestamp with time zone, ''' || split_part(between, E'''', 2) || E'''::timestamp with time zone+interval ''' || interval || E'''-interval ''1s'')';
    sql = sql || ' UNION ALL ';
    sql = sql || E'SELECT n+interval ''' || interval || E''', z+interval ''' || interval || E''' FROM t WHERE n < ''' || split_part(between, E'''', 4) || E'''::timestamp with time zone';
    sql = sql || ') ';
    sql = sql || 'SELECT n,z FROM t';
    RETURN QUERY EXECUTE sql;
END;
$_X$;
ALTER FUNCTION tools.generate_timestamps("interval" text, "between" text) OWNER TO grafana;

CREATE FUNCTION tools.group_by_interval(grafana_interval text, "interval" text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
/*
Valid values for interval are the same for the date_trunc field
https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-TRUNC

Example:
microseconds
milliseconds
second
minute
hour
day
week
month
quarter
year
decade
century
millennium

RETURNS FALSE if interval_one is a finer resolution than interval_two
*/
SELECT CASE WHEN $1::interval >= ('1 ' || $2)::interval THEN $1 ELSE ('1 ' || $2) END;
$_$;
ALTER FUNCTION tools.group_by_interval(grafana_interval text, "interval" text) OWNER TO grafana;

CREATE FUNCTION tools.interval_to_field(grafana_interval text) RETURNS text
    LANGUAGE sql STRICT
    AS $_$
SELECT substring($1 FROM '[a-zA-Z]+');
$_$;
ALTER FUNCTION tools.interval_to_field(grafana_interval text) OWNER TO grafana;

CREATE FUNCTION tools.parse_csv(s text, raise_on_error boolean DEFAULT true) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
/*
Written by Cary Robbins
https://gist.github.com/carymrobbins/b8e7340ce63a22e8d33c
*/
declare
  result text[] = '{}';
  len int = char_length(s);
  i int = 1;
  pos int;
  start_pos int;
  c char;
begin
  if len = 0 then
    return result;
  end if;
  while i <= len + 1 loop
    -- If this element starts with a quote, consume until the next unescaped quote.
    if substr(s, i) like '"%' then
      i := i + 1;
      start_pos := i;
      while true loop
        -- Find the next quote, it could be an escaped quote or the end of this element.
        pos := position('"' in substr(s, i));
        -- If we can't find another quote, the csv is malformed.
        if pos = 0 then
          if raise_on_error then
            raise exception 'Unable to parse csv, expected string terminator: %', s;
          else
            return null;
          end if;
        end if;
        i := i + pos;
        c := substr(s, i, 1);
        -- If next char is a " then we are just escaping a quote.
        if c = '"' then
          i := i + 1;
          continue;
        else
          -- Otherwise, we'd expect a comma, terminating this field.
          if c in (',', '') then
            -- Append this element, unescaping any quotes.
            result := array_append(result,
              regexp_replace(substr(s, start_pos, i - start_pos - 1), '""', '"', 'g')
            );
            i := i + 1;
            exit;
          else
            if raise_on_error then
              raise exception 'Unable to parse csv, expected comma or EOF, got ''%'' instead: %', c, s;
            else
              return null;
            end if;
          end if;
        end if;
      end loop;
    else
      start_pos := i;
      pos := position(',' in substr(s, start_pos));
      if pos = 0 then
        result := array_append(result, substr(s, start_pos));
        exit;
      else
        i := start_pos + pos;
        result := array_append(result, substr(s, start_pos, greatest(i - start_pos - 1, 0)));
      end if;
    end if;
  end loop;
  return result;
end
$$;
ALTER FUNCTION tools.parse_csv(s text, raise_on_error boolean) OWNER TO grafana;

-- FUNCTIONS logs

CREATE FUNCTION logs.autoanalyze_log(grafana_time_filter text, cluster_name_in text DEFAULT NULL::text, database_name_in text DEFAULT NULL::text, schema_name_in text DEFAULT NULL::text, table_name_in text DEFAULT NULL::text, query_limit bigint DEFAULT 100000) RETURNS TABLE("time" timestamp with time zone, cluster_name text, database_name text, schema_name text, table_name text, cpu_system numeric, cpu_user numeric, elasped_seconds numeric)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM logs.autoanalyze_log($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.autoanalyze_log($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$, 100000);

$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
$DatabaseName is the name of the database you have specified at the top of the page or 'All' for all databases
$SchemaName is the name of the schema you have specified at the top of the page or 'All' for all schemas
$TableName is the name of the table you have specified at the top of the page or 'All' for all tables
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT * FROM logs.autoanalyze_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$)
ORDER BY 1  DESC    
LIMIT ' || query_limit || ';';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.autoanalyze_log(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text, query_limit bigint) OWNER TO grafana;

--
-- Name: autoanalyze_log_count(text, text, timestamp with time zone, timestamp with time zone, text, text, text, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.autoanalyze_log_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, count bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM logs.autoanalyze_log_count('$__interval', $$$__timeFilter(time)$$, $__timeFrom(), $__timeTo(), $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

SET application_name = 'Grafana';
SELECT time, cluster_name || ' - analyze', count FROM logs.autoanalyze_log_count('$GraphInterval', $$$__timeFilter(time)$$, $__timeFrom(), $__timeTo(), $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.autoanalyze_log_count('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

$__interval is the interval period for the display. The more data being displayed the larger the interval.
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
$DatabaseName is the name of the database you have specified at the top of the page or 'All' for all databases
$SchemaName is the name of the schema you have specified at the top of the page or 'All' for all schemas
$TableName is the name of the table you have specified at the top of the page or 'All' for all tables
*/
DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT
   time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || ''') AS "time",
   cluster_name,
  coalesce(count(*),0) AS count
FROM
  logs.autoanalyze_logs
WHERE
  ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$) 
GROUP BY time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || '''), cluster_name
ORDER BY time, cluster_name';

--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.autoanalyze_log_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autoanalyze_log_count_chart(text, text, text, text, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.autoanalyze_log_count_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, table_name text, count bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM logs.autoanalyze_log_count_chart($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.autoanalyze_log_count_chart($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

$__interval is the interval period for the display. The more data being displayed the larger the interval.
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
$DatabaseName is the name of the database you have specified at the top of the page or 'All' for all databases
$SchemaName is the name of the schema you have specified at the top of the page or 'All' for all schemas
$TableName is the name of the table you have specified at the top of the page or 'All' for all tables
*/
DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT
   now() AS "time",
   CASE WHEN $$' || cluster_name_in::text || E'$$ = ''NULL'' THEN cluster_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || database_name_in::text || E'$$ = ''NULL'' THEN database_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || schema_name_in::text || E'$$ = ''NULL'' THEN schema_name || ''.'' ELSE '''' END || 
   table_name AS table_name,
  count(*)
FROM
  logs.autoanalyze_logs
WHERE
  ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$) 
GROUP BY CASE WHEN $$' || cluster_name_in::text || E'$$ = ''NULL'' THEN cluster_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || database_name_in::text || E'$$ = ''NULL'' THEN database_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || schema_name_in::text || E'$$ = ''NULL'' THEN schema_name || ''.'' ELSE '''' END || 
   table_name
ORDER BY 3 DESC NULLS LAST';

--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.autoanalyze_log_count_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autovacuum_autoanalyze_count(text, text, text, text, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.autovacuum_autoanalyze_count(grafana_time_filter text, cluster_name_in text DEFAULT NULL::text, database_name_in text DEFAULT NULL::text, schema_name_in text DEFAULT NULL::text, table_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, vacuum bigint, "analyze" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM logs.autovacuum_autoanalyze_count($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.autovacuum_autoanalyze_count($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$, 100000);

$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
$DatabaseName is the name of the database you have specified at the top of the page or 'All' for all databases
$SchemaName is the name of the schema you have specified at the top of the page or 'All' for all schemas
$TableName is the name of the table you have specified at the top of the page or 'All' for all tables
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT a."time", COALESCE(b.count,0) AS vacuum, COALESCE(c.count,0) AS analyze
FROM (
	SELECT time_bucket(''1h'',time) AS "time"
	FROM logs.autovacuum_logs
    WHERE ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$)
	UNION 
	SELECT time_bucket(''1h'',time) AS "time"
	FROM logs.autoanalyze_logs
    WHERE ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$)
) a
LEFT JOIN (
	SELECT time_bucket(''1h'',time) AS "time", count(*) 
	FROM logs.autovacuum_logs
    WHERE ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$)
	GROUP BY time_bucket(''1h'',time)
) b USING ("time") 
LEFT JOIN (
	SELECT time_bucket(''1h'',time) AS "time", count(*) 
	FROM logs.autoanalyze_logs
    WHERE ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$)
	GROUP BY time_bucket(''1h'',time)
) c USING ("time")   
ORDER BY 1;';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.autovacuum_autoanalyze_count(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autovacuum_log(text, text, text, text, text, bigint); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.autovacuum_log(grafana_time_filter text, cluster_name_in text DEFAULT NULL::text, database_name_in text DEFAULT NULL::text, schema_name_in text DEFAULT NULL::text, table_name_in text DEFAULT NULL::text, query_limit bigint DEFAULT 100000) RETURNS TABLE("time" timestamp with time zone, cluster_name text, database_name text, schema_name text, table_name text, index_scans bigint, pages_removed bigint, removed_size bigint, pages_remain bigint, pages_remain_size bigint, skipped_due_to_pins bigint, skipped_frozen bigint, tuples_removed bigint, tuples_remain bigint, tuples_dead bigint, oldest_xmin bigint, buffer_hits bigint, buffer_misses bigint, buffer_dirtied bigint, buffer_dirtied_size bigint, avg_read_rate numeric, avg_write_rate numeric, cpu_system numeric, cpu_user numeric, elasped_seconds numeric)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM logs.autovacuum_log($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.autovacuum_log($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$, 100000);

$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
$DatabaseName is the name of the database you have specified at the top of the page or 'All' for all databases
$SchemaName is the name of the schema you have specified at the top of the page or 'All' for all schemas
$TableName is the name of the table you have specified at the top of the page or 'All' for all tables
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT * FROM logs.autovacuum_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$) 
LIMIT ' || query_limit || ';';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.autovacuum_log(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text, query_limit bigint) OWNER TO grafana;

--
-- Name: autovacuum_log_count(text, text, timestamp with time zone, timestamp with time zone, text, text, text, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.autovacuum_log_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, count bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM logs.autovacuum_log_count('$__interval', $$$__timeFilter(time)$$, $__timeFrom(), $__timeTo(), $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

SET application_name = 'Grafana';
SELECT time, cluster_name || ' - vacuum', count FROM logs.autovacuum_log_count('$GraphInterval', $$$__timeFilter(time)$$, $__timeFrom(), $__timeTo(), $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.autovacuum_log_count('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

$__interval is the interval period for the display. The more data being displayed the larger the interval.
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
$DatabaseName is the name of the database you have specified at the top of the page or 'All' for all databases
$SchemaName is the name of the schema you have specified at the top of the page or 'All' for all schemas
$TableName is the name of the table you have specified at the top of the page or 'All' for all tables
*/
DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT
   time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || ''') AS "time",
   cluster_name,
  COALESCE(count(*),0) AS count
FROM
  logs.autovacuum_logs
WHERE
  ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$) 
GROUP BY time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || '''), cluster_name
ORDER BY 1,2';

--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.autovacuum_log_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autovacuum_log_count_chart(text, text, text, text, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.autovacuum_log_count_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, table_name text, count bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM logs.autovacuum_log_count_chart($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.autovacuum_log_count_chart($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

$__interval is the interval period for the display. The more data being displayed the larger the interval.
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
$DatabaseName is the name of the database you have specified at the top of the page or 'All' for all databases
$SchemaName is the name of the schema you have specified at the top of the page or 'All' for all schemas
$TableName is the name of the table you have specified at the top of the page or 'All' for all tables
*/
DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT
   now() AS "time",
   CASE WHEN $$' || cluster_name_in::text || E'$$ = ''NULL'' THEN cluster_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || database_name_in::text || E'$$ = ''NULL'' THEN database_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || schema_name_in::text || E'$$ = ''NULL'' THEN schema_name || ''.'' ELSE '''' END || 
   table_name AS table_name,
  count(*)
FROM
  logs.autovacuum_logs
WHERE
  ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$) 
GROUP BY CASE WHEN $$' || cluster_name_in::text || E'$$ = ''NULL'' THEN cluster_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || database_name_in::text || E'$$ = ''NULL'' THEN database_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || schema_name_in::text || E'$$ = ''NULL'' THEN schema_name || ''.'' ELSE '''' END || 
   table_name
ORDER BY 3 DESC NULLS LAST';

--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.autovacuum_log_count_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autovacuum_log_removed_size(text, text, text, text, text, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.autovacuum_log_removed_size(grafana_interval text, grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, removed_size bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM logs.autovacuum_log_removed_size('$__interval', $$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.autovacuum_log_removed_size('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

$__interval is the interval period for the display. The more data being displayed the larger the interval.
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
$DatabaseName is the name of the database you have specified at the top of the page or 'All' for all databases
$SchemaName is the name of the schema you have specified at the top of the page or 'All' for all schemas
$TableName is the name of the table you have specified at the top of the page or 'All' for all tables
*/
DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT
   time_bucket(''' || grafana_interval || ''',time) AS "time",
   cluster_name,
  sum(removed_size)::bigint AS removed_size
FROM
  logs.autovacuum_logs
WHERE
  ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$) 
GROUP BY time_bucket(''' || grafana_interval || ''',time), cluster_name
ORDER BY time, cluster_name';

--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.autovacuum_log_removed_size(grafana_interval text, grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autovacuum_log_removed_space_chart(text, text, text, text, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.autovacuum_log_removed_space_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, table_name text, removed_size bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM logs.autovacuum_log_removed_space_chart($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.autovacuum_log_removed_space_chart($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
$DatabaseName is the name of the database you have specified at the top of the page or 'All' for all databases
$SchemaName is the name of the schema you have specified at the top of the page or 'All' for all schemas
$TableName is the name of the table you have specified at the top of the page or 'All' for all tables
*/
DECLARE
	sql TEXT;
BEGIN
  sql := E'SELECT
   now() AS "time",
   CASE WHEN $$' || cluster_name_in::text || E'$$ = ''NULL'' THEN cluster_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || database_name_in::text || E'$$ = ''NULL'' THEN database_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || schema_name_in::text || E'$$ = ''NULL'' THEN schema_name || ''.'' ELSE '''' END || 
   table_name AS table_name,
  sum(removed_size)::bigint AS removed_size
FROM
  logs.autovacuum_logs
WHERE
  ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$) 
GROUP BY    CASE WHEN $$' || cluster_name_in::text || E'$$ = ''NULL'' THEN cluster_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || database_name_in::text || E'$$ = ''NULL'' THEN database_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || schema_name_in::text || E'$$ = ''NULL'' THEN schema_name || ''.'' ELSE '''' END || 
   table_name
ORDER BY 3 DESC NULLS LAST';

--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.autovacuum_log_removed_space_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autovacuum_log_tuples_removed(text, text, text, text, text, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.autovacuum_log_tuples_removed(grafana_interval text, grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, tuples_removed bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM logs.autovacuum_log_tuples_removed('$__interval', $$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.autovacuum_log_tuples_removed('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

$__interval is the interval period for the display. The more data being displayed the larger the interval.
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
$DatabaseName is the name of the database you have specified at the top of the page or 'All' for all databases
$SchemaName is the name of the schema you have specified at the top of the page or 'All' for all schemas
$TableName is the name of the table you have specified at the top of the page or 'All' for all tables
*/
DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT
   time_bucket(''' || grafana_interval || ''',time) AS "time",
   cluster_name,
  sum(tuples_removed)::bigint AS tuples_removed
FROM
  logs.autovacuum_logs
WHERE
  ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$) 
GROUP BY time_bucket(''' || grafana_interval || ''',time), cluster_name
ORDER BY time, cluster_name';

--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.autovacuum_log_tuples_removed(grafana_interval text, grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

CREATE FUNCTION logs.autovacuum_log_tuples_removed_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, table_name text, tuples_removed bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM logs.autovacuum_log_tuples_removed_chart($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.autovacuum_log_tuples_removed_chart($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
$DatabaseName is the name of the database you have specified at the top of the page or 'All' for all databases
$SchemaName is the name of the schema you have specified at the top of the page or 'All' for all schemas
$TableName is the name of the table you have specified at the top of the page or 'All' for all tables
*/
DECLARE
	sql TEXT;
BEGIN
  sql := E'SELECT
   now() AS "time",
   CASE WHEN $$' || cluster_name_in::text || E'$$ = ''NULL'' THEN cluster_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || database_name_in::text || E'$$ = ''NULL'' THEN database_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || schema_name_in::text || E'$$ = ''NULL'' THEN schema_name || ''.'' ELSE '''' END || 
   table_name AS table_name,
  sum(tuples_removed)::bigint AS tuples_removed
FROM
  logs.autovacuum_logs
WHERE
  ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$) 
GROUP BY CASE WHEN $$' || cluster_name_in::text || E'$$ = ''NULL'' THEN cluster_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || database_name_in::text || E'$$ = ''NULL'' THEN database_name || ''.'' ELSE '''' END || 
   CASE WHEN $$' || schema_name_in::text || E'$$ = ''NULL'' THEN schema_name || ''.'' ELSE '''' END || 
   table_name
ORDER BY 3 DESC NULLS LAST';

--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.autovacuum_log_tuples_removed_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autovacuum_thresholds(text, text, text, timestamp with time zone, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.autovacuum_thresholds(server_name text, database_name text, all_vacuums text, grafana_timeto timestamp with time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, name text, n_tup_ins bigint, n_tup_upd bigint, n_tup_del bigint, n_live_tup bigint, n_dead_tup bigint, reltuples real, av_threshold double precision, last_vacuum timestamp with time zone, last_analyze timestamp with time zone, av_neaded boolean, pct_dead numeric)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT logs.autovacuum_thresholds('$ServerName', '$DatabaseName', '$ShowAllVacuums', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT logs.autovacuum_thresholds('sqltest', 'delphi_continuous_integrator_testing', 'All', '2019-05-08T22:36:44.901Z', '1m');
*/

DECLARE
  sql TEXT;
BEGIN
	sql := E'SELECT log_time, CASE WHEN ''' || server_name || ''' = ''--All--'' THEN b.cluster_name || ''.'' ELSE '''' END || CASE WHEN ''' || database_name || ''' = ''--All--'' THEN b.database_name || ''.'' ELSE '''' END || b.name AS name, 
  b.n_tup_ins,
    b.n_tup_upd,
    b.n_tup_del,
    b.n_live_tup,
    b.n_dead_tup,
    b.reltuples,
    b.av_threshold,
    b.last_vacuum,
    b.last_analyze,
    b.av_neaded,
    b.pct_dead 
FROM (
	SELECT max(log_time) AS log_time, cluster_name, database_name
	FROM logs.autovacuum_thresholds
    WHERE 
        (cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
        AND (database_name = ''' || database_name || ''' OR ''--All--'' = ''' || database_name || ''' OR ''' || all_vacuums || ''' = ''All'')
	GROUP BY cluster_name, database_name
) a
LEFT JOIN logs.autovacuum_thresholds b USING (log_time, cluster_name, database_name)
WHERE (b.cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
  AND (b.database_name = ''' || database_name || ''' OR ''--All--'' = ''' || database_name || ''' OR ''' || all_vacuums || ''' = ''All'')
  AND b.log_time >= ''' || grafana_timeto || '''::TIMESTAMPTZ - INTERVAL ''' || grafana_refresh || '''
  ORDER BY 1 DESC, 2';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;  
END;
$_X$;


ALTER FUNCTION logs.autovacuum_thresholds(server_name text, database_name text, all_vacuums text, grafana_timeto timestamp with time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: checkpoint_buffers(text, text, timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.checkpoint_buffers(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, wbuffer bigint, write numeric, sync numeric, total numeric)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_buffers('$GraphInterval', $$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_buffers('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

$__interval is the interval period for the display. The more data being displayed the larger the interval.
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT 
   time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || ''') AS "time",
   cluster_name,
  coalesce(sum(wbuffer),0) AS wbuffer,
  coalesce(sum(write),0) AS write,
  coalesce(sum(sync),0) AS sync,
  coalesce(sum(total),0) AS total
FROM logs.checkpoint_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
GROUP BY time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || '''), cluster_name
ORDER BY time, cluster_name;';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.checkpoint_buffers(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text) OWNER TO grafana;

--
-- Name: checkpoint_files(text, text, timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.checkpoint_files(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, files_added bigint, files_removed bigint, files_recycled bigint, sync_files bigint, sync_longest numeric, sync_avg numeric)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_files('$GraphInterval', $$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_files('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

$__interval is the interval period for the display. The more data being displayed the larger the interval.
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT 
   time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || ''') AS "time",
   cluster_name,
  coalesce(sum(files_added),0) AS files_added,
  coalesce(sum(file_removed),0) AS files_removed,
  coalesce(sum(file_recycled),0) AS files_recycled,
  coalesce(sum(sync_files),0) AS synced_files,
  coalesce(sum(sync_longest),0) AS sync_longest,
  coalesce(sum(sync_avg),0) AS sync_avg
FROM logs.checkpoint_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
GROUP BY time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || '''), cluster_name
ORDER BY time, cluster_name;';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.checkpoint_files(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text) OWNER TO grafana;

--
-- Name: checkpoint_logs(text, text, bigint); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.checkpoint_logs(grafana_time_filter text, cluster_name_in text DEFAULT NULL::text, query_limit bigint DEFAULT 100000) RETURNS TABLE("time" timestamp with time zone, cluster_name text, wbuffer integer, files_added integer, files_removed integer, files_recycled integer, write numeric, sync numeric, total numeric, sync_files integer, sync_longest numeric, sync_avg numeric, distance integer, estimate integer)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_logs($$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_logs($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT * FROM logs.checkpoint_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
ORDER BY 1  DESC    
LIMIT ' || query_limit || ';';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.checkpoint_logs(grafana_time_filter text, cluster_name_in text, query_limit bigint) OWNER TO grafana;

--
-- Name: checkpoint_wal_file_usage(text, text, timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.checkpoint_wal_file_usage(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, files bigint)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_wal_file_usage('$GraphInterval', $$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_wal_file_usage('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

$__interval is the interval period for the display. The more data being displayed the larger the interval.
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'CREATE TEMP TABLE checkpoint_wal_file_usage_data AS SELECT 
   time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || ''') AS "time",
   cluster_name,
  coalesce(sum(files_added),0) AS files_added,
  coalesce(sum(file_removed),0) AS files_removed,
  coalesce(sum(file_recycled),0) AS files_recycled
FROM logs.checkpoint_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
GROUP BY time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || '''), cluster_name
ORDER BY time, cluster_name;';
--  RAISE NOTICE 'SQL: %', sql;
	EXECUTE sql;
    sql := 'SELECT "time", cluster_name || '' - Files Added'', files_added FROM pg_temp.checkpoint_wal_file_usage_data
    UNION
    SELECT "time", cluster_name || '' - Files Removed'', files_removed FROM pg_temp.checkpoint_wal_file_usage_data
    UNION
    SELECT "time", cluster_name || '' - Files Recycled'', files_recycled FROM pg_temp.checkpoint_wal_file_usage_data
    ORDER BY 1';
  RETURN QUERY EXECUTE sql;
  sql := 'DROP TABLE pg_temp.checkpoint_wal_file_usage_data';
	EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.checkpoint_wal_file_usage(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text) OWNER TO grafana;

--
-- Name: checkpoint_warning_logs(text, text, bigint); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.checkpoint_warning_logs(grafana_time_filter text, cluster_name_in text DEFAULT NULL::text, query_limit bigint DEFAULT 100000) RETURNS TABLE("time" timestamp with time zone, cluster_name text, seconds integer, hint text)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_warning_logs($$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_warning_logs($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT * FROM logs.checkpoint_warning_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
ORDER BY 1  DESC    
LIMIT ' || query_limit || ';';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.checkpoint_warning_logs(grafana_time_filter text, cluster_name_in text, query_limit bigint) OWNER TO grafana;

--
-- Name: checkpoint_warning_logs_count(text, text, timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.checkpoint_warning_logs_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, count bigint)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_warning_logs_count('$GraphInterval', $$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_warning_logs_count('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

$__interval is the interval period for the display. The more data being displayed the larger the interval.
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT 
   time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || ''') AS "time",
   cluster_name,
  coalesce(count(*),0) AS count
FROM logs.checkpoint_warning_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
GROUP BY time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || '''), cluster_name
ORDER BY time, cluster_name;';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.checkpoint_warning_logs_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text) OWNER TO grafana;

--
-- Name: checkpoint_write_buffers(text, text, timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.checkpoint_write_buffers(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, wbuffer bigint)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_write_buffers('$GraphInterval', $$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM logs.checkpoint_write_buffers('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

$__interval is the interval period for the display. The more data being displayed the larger the interval.
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT 
   time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || ''') AS "time",
   cluster_name,
  coalesce(sum(wbuffer),0) AS count
FROM logs.checkpoint_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
GROUP BY time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || '''), cluster_name
ORDER BY time, cluster_name;';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.checkpoint_write_buffers(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text) OWNER TO grafana;

--
-- Name: connection_attempt_history(text, text, text[], text, text, boolean, boolean); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.connection_attempt_history(grafana_interval text, grafana_time_filter text, cluster_name text[] DEFAULT '{''All''::text}'::text[], "interval" text DEFAULT 'second'::text, aggregate text DEFAULT 'avg'::text, display_interval boolean DEFAULT false, display_aggregate boolean DEFAULT false) RETURNS TABLE("time" timestamp with time zone, "Server" text, "Connections" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM logs.connection_attempt_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, 'second', 'avg', False);
SELECT * FROM logs.connection_attempt_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, tools.interval_to_field('$__interval'), 'sum', True);

aka

SELECT * FROM logs.connection_attempt_history('5s', $$log_time BETWEEN '2019-03-11T19:45:08Z' AND '2019-03-11T22:45:08Z'$$, ARRAY['sqltest'], 'second', 'avg', False);

$__interval is the resolution of the graph. This is set by Grafana based on width and and time line for the graph being displayed
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
interval can either be tools.interval_to_field('$__interval') which will auto set the inverval to the same unit at the interval or you may specific the inverval manually.
If the graph is 5m the interval_to_field will set it at minute, but if you still want the data display in seconds put in 'second'
aggregate can be one of the following 'min', 'max', 'sum', or 'avg', Most people will want avg. Following the inverval example, you will want to know the average per second.

Valid values for interval are the same for the date_trunc field
https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-TRUNC

Example:
microseconds
milliseconds
second
minute
hour
day
week
month
quarter
year
decade
century
millennium
*/

DECLARE
	sql TEXT;
BEGIN
--	RAISE NOTICE 'cluster_name: %', cluster_name;
/* -- Old non-TimescaleDB code
	sql := E'SELECT a.start_time AS "Time", b.cluster_name || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END || CASE WHEN ' || display_aggregate || ' THEN '' - ' || aggregate || E''' ELSE '''' END AS "Server", COALESCE(' || aggregate || '(c.count),0)::BIGINT AS "Connections" ';
    sql = sql || E'FROM tools.generate_timestamps(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || '''), $$' || grafana_time_filter || '$$) a (start_time, end_time) ';
    sql = sql || E'CROSS JOIN (SELECT DISTINCT cluster_name FROM logs.postgres_log WHERE ' || grafana_time_filter || E' AND ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[]) b ';
    sql = sql || 'LEFT JOIN (  SELECT ';
    sql = sql || E'date_trunc(''' || interval || ''', log_time) AS log_time, ';
    sql = sql || 'cluster_name, count(*) FROM logs.postgres_log ';
    sql = sql || E'WHERE ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[] AND message LIKE ''connection received%'' ';
    sql = sql || 'AND ' || grafana_time_filter || ' GROUP BY 1,2) c ';
    sql = sql || 'ON c.log_time BETWEEN a.start_time AND a.end_time AND b.cluster_name = c.cluster_name ';
    sql = sql || 'GROUP BY 1,2 ORDER BY 1,2;';
*/    

	sql := E'SELECT time_bucket_gapfill(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || ''')::interval, log_time) AS "Time", cluster_name || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END || CASE WHEN ' || display_aggregate || ' THEN '' - ' || aggregate || E''' ELSE '''' END AS "Server", COALESCE(count(*),0)::BIGINT AS "Connections" ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[] AND message LIKE ''connection received%'' ';
    sql = sql || 'AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1,2 ORDER BY 1,2;';
     
--    RAISE NOTICE 'SQL: %', sql;
	RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.connection_attempt_history(grafana_interval text, grafana_time_filter text, cluster_name text[], "interval" text, aggregate text, display_interval boolean, display_aggregate boolean) OWNER TO grafana;

--
-- Name: connection_history(text, text, text[], text, text, boolean, boolean); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.connection_history(grafana_interval text, grafana_time_filter text, cluster_name text[] DEFAULT '{''All''::text}'::text[], "interval" text DEFAULT 'second'::text, aggregate text DEFAULT 'avg'::text, display_interval boolean DEFAULT false, display_aggregate boolean DEFAULT false) RETURNS TABLE("time" timestamp with time zone, "Server" text, "Connections" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM logs.connection_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, 'second', 'avg', False);
SELECT * FROM logs.connection_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, tools.interval_to_field('$__interval'), 'sum', True);

aka

SELECT * FROM logs.connection_history('5s', $$log_time BETWEEN '2019-03-11T19:45:08Z' AND '2019-03-11T22:45:08Z'$$, ARRAY['sqltest'], 'second', 'avg', False);

$__interval is the resolution of the graph. This is set by Grafana based on width and and time line for the graph being displayed
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
interval can either be tools.interval_to_field('$__interval') which will auto set the inverval to the same unit at the interval or you may specific the inverval manually.
If the graph is 5m the interval_to_field will set it at minute, but if you still want the data display in seconds put in 'second'
aggregate can be one of the following 'min', 'max', 'sum', or 'avg', Most people will want avg. Following the inverval example, you will want to know the average per second.

Valid values for interval are the same for the date_trunc field
https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-TRUNC

Example:
microseconds
milliseconds
second
minute
hour
day
week
month
quarter
year
decade
century
millennium
*/

DECLARE
	sql TEXT;
BEGIN
--	RAISE NOTICE 'cluster_name: %', cluster_name;
/* -- Old non-TimescaleDB code
	sql := E'SELECT a.start_time AS "Time", b.cluster_name || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END || CASE WHEN ' || display_aggregate || ' THEN '' - ' || aggregate || E''' ELSE '''' END AS "Server", COALESCE(' || aggregate || '(c.count),0)::BIGINT AS "Connections" ';
    sql = sql || E'FROM tools.generate_timestamps(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || '''), $$' || grafana_time_filter || '$$) a (start_time, end_time) ';
    sql = sql || E'CROSS JOIN (SELECT DISTINCT cluster_name FROM logs.postgres_log WHERE ' || grafana_time_filter || E' AND ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[]) b ';
    sql = sql || 'LEFT JOIN (  SELECT ';
    sql = sql || E'date_trunc(''' || interval || ''', log_time) AS log_time, ';
    sql = sql || 'cluster_name, count(*) FROM logs.postgres_log ';
    sql = sql || E'WHERE ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[] AND message LIKE ''connection authorized%'' ';
    sql = sql || 'AND ' || grafana_time_filter || ' GROUP BY 1,2) c ';
    sql = sql || 'ON c.log_time BETWEEN a.start_time AND a.end_time AND b.cluster_name = c.cluster_name ';
    sql = sql || 'GROUP BY 1,2 ORDER BY 1,2;';
*/    
	sql := E'SELECT time_bucket_gapfill(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || ''')::interval, log_time) AS "Time", cluster_name || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END || CASE WHEN ' || display_aggregate || ' THEN '' - ' || aggregate || E''' ELSE '''' END AS "Server", COALESCE(count(*),0)::BIGINT AS "Connections" ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[] AND message LIKE ''connection authorized%'' ';
    sql = sql || 'AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1,2 ORDER BY 1,2;';

--    RAISE NOTICE 'SQL: %', sql;
	RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.connection_history(grafana_interval text, grafana_time_filter text, cluster_name text[], "interval" text, aggregate text, display_interval boolean, display_aggregate boolean) OWNER TO grafana;

--
-- Name: autovacuum(text, text, text, timestamp without time zone, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION stats.autovacuum(server_name text, database_name text, all_vacuums text, grafana_timeto timestamp without time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, name text, vacuum boolean, "analyze" boolean, running_time integer, phase text, heap_blks_total bigint, heap_blks_total_size bigint, heap_blks_scanned bigint, heap_blks_scanned_pct numeric, heap_blks_vacuumed bigint, heap_blks_vacuumed_pct numeric, index_vacuum_count bigint, max_dead_tuples bigint, num_dead_tuples bigint, backend_start timestamp with time zone, wait_event_type text, wait_event text, state text, backend_xmin xid)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT stats.autovacuum('$ServerName', '$DatabaseName', '$ShowAllVacuums', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT stats.autovacuum('sqltest', 'delphi_continuous_integrator_testing', 'All', '2019-05-08T22:36:44.901Z', '1m');
*/

DECLARE
  sql TEXT;
BEGIN
	sql := E'SELECT b.log_time, CASE WHEN ''' || server_name || ''' = ''--All--'' THEN b.cluster_name || ''.'' ELSE '''' END || CASE WHEN ''' || database_name || ''' = ''--All--'' THEN b.database_name || ''.'' WHEN ''' || all_vacuums || ''' = ''All'' THEN b.database_name || ''.'' ELSE '''' END || b.name AS name, 
  b.vacuum ,
  b."analyze" ,
  b.running_time ,
  b.phase ,
  b.heap_blks_total ,
  b.heap_blks_total_size ,
  b.heap_blks_scanned ,
  b.heap_blks_scanned_pct ,
  b.heap_blks_vacuumed ,
  b.heap_blks_vacuumed_pct ,
  b.index_vacuum_count ,
  b.max_dead_tuples,
  b.num_dead_tuples,
  b.backend_start,
  b.wait_event_type,
  b.wait_event,
  b.state,
  b.backend_xmin 
FROM (
	SELECT max(log_time) AS log_time
	FROM stats.autovacuum
) a
LEFT JOIN stats.autovacuum b USING (log_time)
WHERE (b.cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
  AND (b.database_name = ''' || database_name || ''' OR ''--All--'' = ''' || database_name || ''' OR ''' || all_vacuums || ''' = ''All'')
  AND b.log_time >= ''' || grafana_timeto || '''::timestamp - INTERVAL ''' || grafana_refresh || '''
  ORDER BY b.cluster_name, b.database_name, b.schema_name, b.table_name, b.log_time DESC';
--    RAISE NOTICE 'SQL: %', sql;
	RETURN QUERY EXECUTE sql;  
END;
$_X$;


ALTER FUNCTION stats.autovacuum(server_name text, database_name text, all_vacuums text, grafana_timeto timestamp without time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: pg_stat_activity_active(text, text, timestamp with time zone, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION stats.pg_stat_activity_active(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, database_name text, pid integer, state text, application_name text, backend_type text, wait_event_type text, wait_event text, backend_start timestamp with time zone, xact_start timestamp with time zone, query_start timestamp with time zone, state_change timestamp with time zone, backend_xmin xid)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT stats.pg_stat_activity_active('$ServerName', '$DatabaseName', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT stats.pg_stat_activity_active('sqltest', 'delphi_continuous_integrator_testing', '2019-05-08T22:36:44.901Z', '1m');
*/

DECLARE
  sql TEXT;
BEGIN
	sql := E'SELECT b.log_time, 
	CASE WHEN ''' || server_name || ''' = ''--All--'' THEN b.cluster_name || ''.'' ELSE '''' END || b.database_name AS database_name, 
	b.pid, b.state, b.application_name, b.backend_type, b.wait_event_type, b.wait_event, b.backend_start, b.xact_start, b.query_start, b.state_change, b.backend_xmin 
FROM (
	SELECT max(log_time) AS log_time
	FROM stats.pg_stat_activity
) a  
LEFT JOIN stats.pg_stat_activity b USING (log_time)
WHERE b.state IN (''idle in transaction'', ''active'')
        AND b.database_name IS NOT NULL
        AND  (b.cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
  	AND (b.database_name = ''' || db_name || ''' OR ''--All--'' = ''' || db_name || ''')
    AND a.log_time >= ''' || grafana_timeto || '''::TIMESTAMPTZ - INTERVAL ''' || grafana_refresh || ''' 
ORDER BY b.cluster_name, b.database_name, b.pid';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;  
END;
$_X$;


ALTER FUNCTION stats.pg_stat_activity_active(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: vacuum_settings(text, text, timestamp with time zone, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION stats.vacuum_settings(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, cluster_name text, name text, setting text, unit text, category text, short_desc text, extra_desc text, context text, vartype text, source text, min_val text, max_val text, enumvals text[], boot_val text, reset_val text, sourcefile text, sourceline integer, pending_restart boolean)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT * FROM stats.granted_locks('$ServerName', '$DatabaseName', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT * FROM stats.granted_locks('sqltest', 'delphi_continuous_integrator_testing', '2019-05-08T22:36:44.901Z', '1m');
*/

DECLARE
  sql TEXT;
BEGIN
	sql := E'SELECT b.*
FROM (
	SELECT max(log_time) AS log_time, cluster_name
	FROM stats.pg_settings
        WHERE (cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
	    AND log_time >= ''' || grafana_timeto || '''::TIMESTAMPTZ - INTERVAL ''' || grafana_refresh || ''' 
	GROUP BY cluster_name
) a  
LEFT JOIN stats.pg_settings b USING (log_time, cluster_name)
WHERE b.category ilike ''%Vacuum%''
ORDER BY b.cluster_name, b.name';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;  
END;
$_X$;


ALTER FUNCTION stats.vacuum_settings(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: custom_table_settings(text, text, timestamp with time zone, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.custom_table_settings(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, cluster_name text, database_name name, table_name text, table_setting text)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT * FROM logs.custom_table_settings('$ServerName', '$DatabaseName', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT * FROM logs.custom_table_settings('sqltest', 'delphi_continuous_integrator_testing', '2019-05-08T22:36:44.901Z', '1m');
*/

DECLARE
  sql TEXT;
BEGIN
	sql := E'SELECT b.log_time, b.cluster_name, b.database_name, b."Table Name", b."Table Setting"
FROM (
	SELECT max(log_time) AS log_time, cluster_name, database_name
	FROM logs.custom_table_settings
        WHERE database_name IS NOT NULL
        AND  (cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
  	AND (database_name = ''' || db_name || ''' OR ''--All--'' = ''' || db_name || ''')
    AND log_time >= ''' || grafana_timeto || '''::TIMESTAMPTZ - INTERVAL ''' || grafana_refresh || ''' 
	GROUP BY cluster_name, database_name
) a  
LEFT JOIN logs.custom_table_settings b USING (log_time, cluster_name, database_name)
ORDER BY b.cluster_name, b.database_name, b."Table Name"';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;  
END;
$_X$;


ALTER FUNCTION logs.custom_table_settings(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: error_history(text, text, text[], text, text, boolean); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.error_history(grafana_interval text, grafana_time_filter text, cluster_name text[] DEFAULT '{''All''::text}'::text[], "interval" text DEFAULT 'second'::text, aggregate text DEFAULT 'avg'::text, display_interval boolean DEFAULT false) RETURNS TABLE("time" timestamp with time zone, "LDAP Errors" text, "Errors" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
-- THIS FUNCTION HAS NOT BEEN FINISHED WRITTEN
/*
SET application_name = 'Grafana';
SELECT * FROM logs.error_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, 'minute', 'sum', False);
SELECT * FROM logs.error_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, tools.interval_to_field('$__interval'), 'sum', True);

aka

SELECT * FROM logs.error_history('5s', $$log_time BETWEEN '2019-03-11T19:45:08Z' AND '2019-03-11T22:45:08Z'$$, 'sqltest', 'second', 'avg', False);

$__interval is the resolution of the graph. This is set by Grafana based on width and and time line for the graph being displayed
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
interval can either be tools.interval_to_field('$__interval') which will auto set the inverval to the same unit at the interval or you may specific the inverval manually.
If the graph is 5m the interval_to_field will set it at minute, but if you still want the data display in seconds put in 'second'
aggregate can be one of the following 'min', 'max', 'sum', or 'avg', Most people will want avg. Following the inverval example, you will want to know the average per second.

Valid values for interval are the same for the date_trunc field
https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-TRUNC

Example:
microseconds
milliseconds
second
minute
hour
day
week
month
quarter
year
decade
century
millennium
*/

DECLARE
	sql TEXT;
BEGIN
/*
	sql := E'SELECT c.start_time AS "Time", c.ldap_error || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END AS "LDAP Errors", COALESCE(' || aggregate || '(e.value),0)::BIGINT AS "Errors" ';
    sql = sql || 'FROM ( ';
    sql = sql || 'SELECT a.*, b.* ';
    sql = sql || 'FROM tools.generate_timestamps(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || '''), $$' || grafana_time_filter || '$$) a (start_time, end_time), ';
    sql = sql || '( ';
    sql = sql || 'SELECT ';
    sql = sql || E'CASE WHEN ''All'' = ''' || cluster_name || E''' THEN cluster_name || '' - '' ELSE '''' END || trim(split_part(message, '':'', 2)) AS ldap_error ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN ''All'' = ''' || cluster_name || E''' THEN cluster_name || '' - '' ELSE '''' END || trim(split_part(message, '':'', 2)) AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE (cluster_name = ''' || cluster_name || E''' OR ''All'' = ''' || cluster_name || E''') AND (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1,2 ';
    sql = sql || ') e ON e.time BETWEEN c.start_time AND c.end_time AND c.ldap_error = e.ldap_error GROUP BY 1,2; ';
*/
	sql := E'SELECT c.start_time AS "Time", c.ldap_error || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END AS "Error Messages", COALESCE(' || aggregate || '(e.value),0)::BIGINT AS "Errors" ';
    sql = sql || 'FROM ( ';
    sql = sql || 'SELECT a.*, b.* ';
    sql = sql || 'FROM tools.generate_timestamps(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || '''), $$' || grafana_time_filter || '$$) a (start_time, end_time), ';
    sql = sql || '( ';
    sql = sql || 'SELECT ';
    sql = sql || E'CASE WHEN array_length(''' || cluster_name::text || E'''::text[], 1) > 1 THEN cluster_name || '' - '' ELSE '''' END || message AS ldap_error ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE error_severity = ''ERROR'' AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN array_length(''' || cluster_name::text || E'''::text[], 1) > 1 THEN cluster_name || '' - '' ELSE '''' END || message AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[] AND error_severity = ''ERROR'' AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1,2 ';
    sql = sql || ') e ON e.time BETWEEN c.start_time AND c.end_time AND c.ldap_error = e.ldap_error GROUP BY 1,2 ORDER BY 1,2; ';



/*    
SELECT c.start_time AS "time", c.ldap_error AS "LDAP Errors", COALESCE(e.value,0)::bigint AS "Errors" 
FROM (
	SELECT a.*, b.* 
	FROM tools.generate_timestamps('$__interval', $$$__timeFilter(log_time)$$) a,
	(
    	SELECT 
    		CASE WHEN 'All' = $ServerName THEN cluster_name || ' - ' ELSE '' END || trim(split_part(message, ':', 2)) AS ldap_error 
		FROM logs.postgres_log 
		WHERE message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
		GROUP BY 1
     ) b
) c LEFT JOIN (
		SELECT  
			date_trunc(tools.interval_to_field('$__interval'), log_time) AS time, 
			CASE WHEN 'All' = $ServerName THEN cluster_name || ' - ' ELSE '' END || trim(split_part(message, ':', 2)) AS ldap_error, 
			count(*) AS value
		FROM logs.postgres_log 
  		WHERE (cluster_name = $ServerName OR 'All' = $ServerName) AND message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
  		GROUP BY 1,2
) e ON c.start_time = e.time AND c.ldap_error = e.ldap_error;    
*/    
    
	RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.error_history(grafana_interval text, grafana_time_filter text, cluster_name text[], "interval" text, aggregate text, display_interval boolean) OWNER TO grafana;

--
-- Name: fatal_history(text, text, text[], text, text, boolean); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.fatal_history(grafana_interval text, grafana_time_filter text, cluster_name text[] DEFAULT '{''All''::text}'::text[], "interval" text DEFAULT 'second'::text, aggregate text DEFAULT 'avg'::text, display_interval boolean DEFAULT false) RETURNS TABLE("time" timestamp with time zone, "LDAP Errors" text, "Errors" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
-- THIS FUNCTION HAS NOT BEEN FINISHED WRITTEN
/*
SET application_name = 'Grafana';
SELECT * FROM logs.fatal_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, 'minute', 'sum', False);
SELECT * FROM logs.fatal_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, tools.interval_to_field('$__interval'), 'sum', True);

aka

SELECT * FROM logs.fatal_history('5s', $$log_time BETWEEN '2019-03-11T19:45:08Z' AND '2019-03-11T22:45:08Z'$$, 'sqltest', 'second', 'avg', False);

$__interval is the resolution of the graph. This is set by Grafana based on width and and time line for the graph being displayed
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
interval can either be tools.interval_to_field('$__interval') which will auto set the inverval to the same unit at the interval or you may specific the inverval manually.
If the graph is 5m the interval_to_field will set it at minute, but if you still want the data display in seconds put in 'second'
aggregate can be one of the following 'min', 'max', 'sum', or 'avg', Most people will want avg. Following the inverval example, you will want to know the average per second.

Valid values for interval are the same for the date_trunc field
https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-TRUNC

Example:
microseconds
milliseconds
second
minute
hour
day
week
month
quarter
year
decade
century
millennium
*/

DECLARE
	sql TEXT;
BEGIN
/*
	sql := E'SELECT c.start_time AS "Time", c.ldap_error || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END AS "LDAP Errors", COALESCE(' || aggregate || '(e.value),0)::BIGINT AS "Errors" ';
    sql = sql || 'FROM ( ';
    sql = sql || 'SELECT a.*, b.* ';
    sql = sql || 'FROM tools.generate_timestamps(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || '''), $$' || grafana_time_filter || '$$) a (start_time, end_time), ';
    sql = sql || '( ';
    sql = sql || 'SELECT ';
    sql = sql || E'CASE WHEN ''All'' = ''' || cluster_name || E''' THEN cluster_name || '' - '' ELSE '''' END || trim(split_part(message, '':'', 2)) AS ldap_error ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN ''All'' = ''' || cluster_name || E''' THEN cluster_name || '' - '' ELSE '''' END || trim(split_part(message, '':'', 2)) AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE (cluster_name = ''' || cluster_name || E''' OR ''All'' = ''' || cluster_name || E''') AND (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1,2 ';
    sql = sql || ') e ON e.time BETWEEN c.start_time AND c.end_time AND c.ldap_error = e.ldap_error GROUP BY 1,2; ';
*/
	sql := E'SELECT c.start_time AS "Time", c.ldap_error || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END AS "Error Messages", COALESCE(' || aggregate || '(e.value),0)::BIGINT AS "Errors" ';
    sql = sql || 'FROM ( ';
    sql = sql || 'SELECT a.*, b.* ';
    sql = sql || 'FROM tools.generate_timestamps(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || '''), $$' || grafana_time_filter || '$$) a (start_time, end_time), ';
    sql = sql || '( ';
    sql = sql || 'SELECT ';
    sql = sql || E'CASE WHEN array_length(''' || cluster_name::text || E'''::text[], 1) > 1 THEN cluster_name || '' - '' ELSE '''' END || message AS ldap_error ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE error_severity = ''FATAL'' AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN array_length(''' || cluster_name::text || E'''::text[], 1) > 1 THEN cluster_name || '' - '' ELSE '''' END || message AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[] AND error_severity = ''FATAL'' AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1,2 ';
    sql = sql || ') e ON e.time BETWEEN c.start_time AND c.end_time AND c.ldap_error = e.ldap_error GROUP BY 1,2 ORDER BY 1,2; ';



/*    
SELECT c.start_time AS "time", c.ldap_error AS "LDAP Errors", COALESCE(e.value,0)::bigint AS "Errors" 
FROM (
	SELECT a.*, b.* 
	FROM tools.generate_timestamps('$__interval', $$$__timeFilter(log_time)$$) a,
	(
    	SELECT 
    		CASE WHEN 'All' = $ServerName THEN cluster_name || ' - ' ELSE '' END || trim(split_part(message, ':', 2)) AS ldap_error 
		FROM logs.postgres_log 
		WHERE message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
		GROUP BY 1
     ) b
) c LEFT JOIN (
		SELECT  
			date_trunc(tools.interval_to_field('$__interval'), log_time) AS time, 
			CASE WHEN 'All' = $ServerName THEN cluster_name || ' - ' ELSE '' END || trim(split_part(message, ':', 2)) AS ldap_error, 
			count(*) AS value
		FROM logs.postgres_log 
  		WHERE (cluster_name = $ServerName OR 'All' = $ServerName) AND message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
  		GROUP BY 1,2
) e ON c.start_time = e.time AND c.ldap_error = e.ldap_error;    
*/    
    
	RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.fatal_history(grafana_interval text, grafana_time_filter text, cluster_name text[], "interval" text, aggregate text, display_interval boolean) OWNER TO grafana;

--
-- Name: granted_locks(text, text, timestamp with time zone, text); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION stats.granted_locks(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, "Server Nname" text, "Database Name" name, "Time" double precision, "PG Process ID" integer, "Application Name" text, "Transaction Start" timestamp with time zone, "Locks" text, "AutoVacuum" text)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT * FROM stats.granted_locks('$ServerName', '$DatabaseName', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT * FROM stats.granted_locks('sqltest', 'delphi_continuous_integrator_testing', '2019-05-08T22:36:44.901Z', '1m');
*/

DECLARE
  sql TEXT;
BEGIN
	sql := E'SELECT b.log_time, b.cluster_name AS "Server Name",
b.database_name AS "Database Name",
b."Time",
    b."PG Process ID",
    b."Application Name",
    b."Transaction Start",
    b."Locks",
    b."AutoVacuum"
FROM (
	SELECT max(log_time) AS log_time, cluster_name, database_name
	FROM stats.granted_locks
        WHERE database_name IS NOT NULL
        AND  (cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
  	AND (database_name = ''' || db_name || ''' OR ''--All--'' = ''' || db_name || ''')
	GROUP BY cluster_name, database_name
) a  
LEFT JOIN stats.granted_locks b USING (log_time, cluster_name, database_name)
WHERE a.log_time >= ''' || grafana_timeto || '''::TIMESTAMPTZ - INTERVAL ''' || grafana_refresh || ''' 
ORDER BY b.cluster_name, b.database_name, b."PG Process ID"';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;  
END;
$_X$;


ALTER FUNCTION stats.granted_locks(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: ldap_error_history(text, text, text[], text, text, boolean); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.ldap_error_history(grafana_interval text, grafana_time_filter text, cluster_name text[] DEFAULT '{''All''::text}'::text[], "interval" text DEFAULT 'second'::text, aggregate text DEFAULT 'avg'::text, display_interval boolean DEFAULT false) RETURNS TABLE("time" timestamp with time zone, "LDAP Errors" text, "Errors" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
-- THIS FUNCTION HAS NOT BEEN FINISHED WRITTEN
/*
SET application_name = 'Grafana';
SELECT * FROM logs.ldap_error_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, 'minute', 'sum', False);
SELECT * FROM logs.ldap_error_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, tools.interval_to_field('$__interval'), 'sum', True);

aka

SELECT * FROM logs.ldap_error_history('5s', $$log_time BETWEEN '2019-03-11T19:45:08Z' AND '2019-03-11T22:45:08Z'$$, 'sqltest', 'second', 'avg', False);

$__interval is the resolution of the graph. This is set by Grafana based on width and and time line for the graph being displayed
$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
interval can either be tools.interval_to_field('$__interval') which will auto set the inverval to the same unit at the interval or you may specific the inverval manually.
If the graph is 5m the interval_to_field will set it at minute, but if you still want the data display in seconds put in 'second'
aggregate can be one of the following 'min', 'max', 'sum', or 'avg', Most people will want avg. Following the inverval example, you will want to know the average per second.

Valid values for interval are the same for the date_trunc field
https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-TRUNC

Example:
microseconds
milliseconds
second
minute
hour
day
week
month
quarter
year
decade
century
millennium
*/

DECLARE
	sql TEXT;
BEGIN
/*
	sql := E'SELECT c.start_time AS "Time", c.ldap_error || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END AS "LDAP Errors", COALESCE(' || aggregate || '(e.value),0)::BIGINT AS "Errors" ';
    sql = sql || 'FROM ( ';
    sql = sql || 'SELECT a.*, b.* ';
    sql = sql || 'FROM tools.generate_timestamps(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || '''), $$' || grafana_time_filter || '$$) a (start_time, end_time), ';
    sql = sql || '( ';
    sql = sql || 'SELECT ';
    sql = sql || E'CASE WHEN ''All'' = ''' || cluster_name || E''' THEN cluster_name || '' - '' ELSE '''' END || trim(split_part(message, '':'', 2)) AS ldap_error ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN ''All'' = ''' || cluster_name || E''' THEN cluster_name || '' - '' ELSE '''' END || trim(split_part(message, '':'', 2)) AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE (cluster_name = ''' || cluster_name || E''' OR ''All'' = ''' || cluster_name || E''') AND (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1,2 ';
    sql = sql || ') e ON e.time BETWEEN c.start_time AND c.end_time AND c.ldap_error = e.ldap_error GROUP BY 1,2; ';
*/
	sql := E'SELECT c.start_time AS "Time", c.ldap_error || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END AS "LDAP Errors", COALESCE(' || aggregate || '(e.value),0)::BIGINT AS "Errors" ';
    sql = sql || 'FROM ( ';
    sql = sql || 'SELECT a.*, b.* ';
    sql = sql || 'FROM tools.generate_timestamps(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || '''), $$' || grafana_time_filter || '$$) a (start_time, end_time), ';
    sql = sql || '( ';
    sql = sql || 'SELECT ';
    sql = sql || E'CASE WHEN array_length(''' || cluster_name::text || E'''::text[], 1) > 1 THEN cluster_name || '' - '' ELSE '''' END || CASE WHEN message LIKE E''%Can''''t contact LDAP server'' THEN trim(split_part(message, ''"'', 1)) ELSE trim(split_part(message, '':'', 2)) END AS ldap_error ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN array_length(''' || cluster_name::text || E'''::text[], 1) > 1 THEN cluster_name || '' - '' ELSE '''' END || CASE WHEN message LIKE E''%Can''''t contact LDAP server'' THEN trim(split_part(message, ''"'', 1)) ELSE trim(split_part(message, '':'', 2)) END AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM logs.postgres_log ';
    sql = sql || E'WHERE ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[] AND (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1,2 ';
    sql = sql || ') e ON e.time BETWEEN c.start_time AND c.end_time AND c.ldap_error = e.ldap_error GROUP BY 1,2 ORDER BY 1,2; ';



/*    
SELECT c.start_time AS "time", c.ldap_error AS "LDAP Errors", COALESCE(e.value,0)::bigint AS "Errors" 
FROM (
	SELECT a.*, b.* 
	FROM tools.generate_timestamps('$__interval', $$$__timeFilter(log_time)$$) a,
	(
    	SELECT 
    		CASE WHEN 'All' = $ServerName THEN cluster_name || ' - ' ELSE '' END || trim(split_part(message, ':', 2)) AS ldap_error 
		FROM logs.postgres_log 
		WHERE message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
		GROUP BY 1
     ) b
) c LEFT JOIN (
		SELECT  
			date_trunc(tools.interval_to_field('$__interval'), log_time) AS time, 
			CASE WHEN 'All' = $ServerName THEN cluster_name || ' - ' ELSE '' END || trim(split_part(message, ':', 2)) AS ldap_error, 
			count(*) AS value
		FROM logs.postgres_log 
  		WHERE (cluster_name = $ServerName OR 'All' = $ServerName) AND message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
  		GROUP BY 1,2
) e ON c.start_time = e.time AND c.ldap_error = e.ldap_error;    
*/    
    
	RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION logs.ldap_error_history(grafana_interval text, grafana_time_filter text, cluster_name text[], "interval" text, aggregate text, display_interval boolean) OWNER TO grafana;

--
-- Name: update_pg_log_databases(); Type: FUNCTION; Schema: logs; Owner: grafana
--

CREATE FUNCTION logs.update_pg_log_databases() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
--  variable_name datatype;
BEGIN
	INSERT INTO logs.postgres_log_databases 
	(SELECT DISTINCT cluster_name, database_name, min(log_time) AS start_date, max(log_time) AS end_date  
	FROM new_table
	WHERE database_name IS NOT NULL
	GROUP BY cluster_name, database_name)
	ON CONFLICT (cluster_name, database_name) DO UPDATE SET end_date = EXCLUDED.end_date;
END;
$$;


ALTER FUNCTION logs.update_pg_log_databases() OWNER TO grafana;





-- Add Triggers
CREATE TRIGGER postgres_log_tr BEFORE INSERT ON logs.postgres_log FOR EACH ROW EXECUTE PROCEDURE tools.postgres_log_trigger();

-- Create list of tables with their settings that we want to turn into hypertables
CREATE TABLE tools.hypertables (
    hypertable_id BIGINT DEFAULT NULL,
    schema_name NAME,
    table_name NAME,
    time_column_name NAME,
    partitioning_column NAME,
    hash_partitions INTEGER DEFAULT 20,
    chunk_time_interval INTERVAL DEFAULT INTERVAL '1 week',
    drop_chunk_policy INTERVAL,
    compress_chunk_policy INTERVAL,
    compress_orderby TEXT,
    compress_segmentby TEXT
);
COMMENT ON COLUMN tools.hypertables.hypertable_id IS 'This is the TimescaleDB hypertable id as seen in _timescaledb_catalog.hypertable.id';
COMMENT ON COLUMN tools.hypertables.schema_name IS 'Schema Name of the Table that we want to turn into a hypertable.';
COMMENT ON COLUMN tools.hypertables.table_name IS 'Table Name of the Table that we want to turn into a hypertable.';
COMMENT ON COLUMN tools.hypertables.time_column_name IS 'Column Name of the Time Column that this table si to be partitioned by.';
COMMENT ON COLUMN tools.hypertables.partitioning_column IS 'Name of an additional column to be partitioned by. Normally we want to partition by cluster_name aka Server Name / Host Name';
COMMENT ON COLUMN tools.hypertables.hash_partitions IS 'Numer of hash partitions to use for partitioning_column, must be > 0';
COMMENT ON COLUMN tools.hypertables.chunk_time_interval IS 'Interval in event time that each chunk covers. Must be > 0. As of TimescaleDB v0.11.0, default is 7 days. For previous versions, default is 1 month.';
COMMENT ON COLUMN tools.hypertables.drop_chunk_policy IS 'Drop chunks older than the given interval of the particular hypertable on a schedule in the background.';
COMMENT ON COLUMN tools.hypertables.compress_chunk_policy IS 'Compress chunks older than the given interval of the particular hypertable on a schedule in the background.';
COMMENT ON COLUMN tools.hypertables.compress_orderby IS E'Order used by compression, specified in the same way as the ORDER BY clause in a SELECT query. The default is the descending order of the hypertable''s time column.';
COMMENT ON COLUMN tools.hypertables.compress_segmentby IS 'Column list on which to key the compressed segments. An identifier representing the source of the data such as device_id or tags_id is usually a good candidate. The default is no segment by columns.';
ALTER TABLE tools.hypertables OWNER TO grafana;

-- Log Processing Tables
INSERT INTO tools.hypertables (schema_name, table_name, time_column_name, partitioning_column, hash_partitions, chunk_time_interval, drop_chunk_policy, compress_chunk_policy, compress_orderby, compress_segmentby) VALUES
('logs', 'archive_failure_log',        'log_time', 'cluster_name', 20, INTERVAL '1 week', INTERVAL '1 year', INTERVAL '1 month', 'log_time DESC', 'cluster_name'),
('logs', 'autoanalyze_logs',           'log_time', 'cluster_name', 20, INTERVAL '1 week', INTERVAL '1 year', INTERVAL '1 month', 'log_time DESC', 'cluster_name'),
('logs', 'autovacuum_logs',            'log_time', 'cluster_name', 20, INTERVAL '1 week', INTERVAL '1 year', INTERVAL '1 month', 'log_time DESC', 'cluster_name'),
('logs', 'checkpoint_logs',            'log_time', 'cluster_name', 20, INTERVAL '1 week', INTERVAL '1 year', INTERVAL '1 month', 'log_time DESC', 'cluster_name'),
('logs', 'checkpoint_warning_logs',    'log_time', 'cluster_name', 20, INTERVAL '1 week', INTERVAL '1 year', INTERVAL '1 month', 'log_time DESC', 'cluster_name'),
('logs', 'lock_logs',                  'log_time', 'cluster_name', 20, INTERVAL '1 week', INTERVAL '1 year', INTERVAL '1 month', 'log_time DESC', 'cluster_name'),
('logs', 'postgres_log',               'log_time', 'cluster_name', 20, INTERVAL '1 week', INTERVAL '1 year', INTERVAL '1 month', 'log_time DESC', 'cluster_name');


-- logs Processing Tables
INSERT INTO tools.hypertables (schema_name, table_name, time_column_name, partitioning_column, hash_partitions, chunk_time_interval, drop_chunk_policy, compress_chunk_policy, compress_orderby, compress_segmentby) VALUES
('stats', 'autovacuum_thresholds',      'log_time', 'cluster_name', 20, INTERVAL '1 hour', INTERVAL '6 hour', INTERVAL '2 hour', 'log_time DESC', 'cluster_name'),
('stats', 'autovacuum',                 'log_time', 'cluster_name', 20, INTERVAL '1 hour', INTERVAL '6 hour', INTERVAL '2 hour', 'log_time DESC', 'cluster_name'),
('stats', 'autovacuum_count',           'log_time', 'cluster_name', 20, INTERVAL '1 hour', INTERVAL '6 hour', INTERVAL '2 hour', 'log_time DESC', 'cluster_name'),
('stats', 'pg_database',                'log_time', 'cluster_name', 20, INTERVAL '1 hour', INTERVAL '6 hour', INTERVAL '2 hour', 'log_time DESC', 'cluster_name'),
('stats', 'pg_settings',                'log_time', 'cluster_name', 20, INTERVAL '1 hour', INTERVAL '6 hour', INTERVAL '2 hour', 'log_time DESC', 'cluster_name'),
('stats', 'pg_stat_activity',           'log_time', 'cluster_name', 20, INTERVAL '1 hour', INTERVAL '6 hour', INTERVAL '2 hour', 'log_time DESC', 'cluster_name'),
('stats', 'replication_status',         'log_time', 'cluster_name', 20, INTERVAL '1 hour', INTERVAL '6 hour', INTERVAL '2 hour', 'log_time DESC', 'cluster_name'),
('stats', 'table_stats',                'log_time', 'cluster_name', 20, INTERVAL '1 hour', INTERVAL '6 hour', INTERVAL '2 hour', 'log_time DESC', 'cluster_name'),
('stats', 'custom_table_settings',      'log_time', 'cluster_name', 20, INTERVAL '1 hour', INTERVAL '6 hour', INTERVAL '2 hour', 'log_time DESC', 'cluster_name'),
('stats', 'granted_locks',              'log_time', 'cluster_name', 20, INTERVAL '1 hour', INTERVAL '6 hour', INTERVAL '2 hour', 'log_time DESC', 'cluster_name');

CREATE FUNCTION tools.timescaledb_enterprise()
RETURNS boolean
LANGUAGE sql
AS $$
    SELECT CASE WHEN edition = 'enterprise' AND expired IS FALSE AND expiration_time > now() THEN TRUE ELSE FALSE END FROM timescaledb_information.license;
$$;
ALTER FUNCTION tools.timescaledb_enterprise() OWNER TO grafana;


CREATE FUNCTION tools.timescaledb_drop_chunks()
RETURNS SETOF text
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  IF tools.timescaledb_enterprise() THEN
    -- Update Intervals in case they were updated.

    RETURN;
  ELSE
    -- Drop chunks older than the drop chunk policy
    RETURN QUERY SELECT public.drop_chunks(drop_chunk_policy, schema_name || '.' || table_name) FROM tools.hypertables;
  END IF;
END $$;
ALTER FUNCTION tools.timescaledb_drop_chunks() OWNER TO grafana;


UPDATE tools.hypertables ht
SET 
    hypertable_id = a.hypertable_id
FROM (
    SELECT (public.create_hypertable(r.schema_name || '.' || r.table_name, r.time_column_name, r.partitioning_column, r.hash_partitions, chunk_time_interval => r.chunk_time_interval)).*
    FROM tools.hypertables r WHERE hypertable_id IS NULL
) a WHERE a.created = true AND ht.schema_name = a.schema_name AND ht.table_name = a.table_name;

SELECT * FROM tools.hypertables;


DO $$
DECLARE
  r RECORD;
BEGIN
    FOR r IN SELECT * FROM tools.hypertables WHERE compress_chunk_policy IS NOT NULL LOOP
        EXECUTE 'ALTER TABLE ' || quote_ident(r.schema_name) || '.' || quote_ident(r.table_name) || ' SET (timescaledb.compress, timescaledb.compress_orderby = ' || quote_literal(r.compress_orderby) || ', timescaledb.compress_segmentby = ' || quote_literal(r.compress_segmentby) || ')';
    END LOOP;
END $$;

SELECT public.add_compress_chunks_policy((schema_name || '.' || table_name)::regclass, compress_chunk_policy) FROM tools.hypertables;

DO $$
DECLARE
BEGIN
/*
If the user has the Enterprise License of TimescaleDB, we will use this function, 
otherwise the logs script will also perform this for comminity licensed versions.
*/
    IF tools.timescaledb_enterprise() THEN
        PERFORM public.add_drop_chunks_policy((schema_name || '.' || table_name)::regclass, drop_chunk_policy, TRUE, TRUE, TRUE) FROM tools.hypertables;
    END IF;
END $$;

-- LOAD DATA INTO tools.query
INSERT INTO tools.query ("query_name", "sql", "disabled", "maintenance_db_only", "pg_version", "run_order", "schema_name", "table_name")
VALUES 
  (E'autovacuum_thresholds', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,\r\n    database() AS database_name,\r\n    av.nspname AS schema_name,\r\n    av.relname AS table_name,\r\n    quote_ident(av.nspname::text) || ''.''::text ||\r\n        quote_ident(av.relname::text) AS name,\r\n    av.n_tup_ins,\r\n    av.n_tup_upd,\r\n    av.n_tup_del,\r\n    av.n_live_tup,\r\n    av.n_dead_tup,\r\n    av.reltuples,\r\n    av.av_threshold,\r\n    av.last_vacuum,\r\n    av.last_analyze,\r\n    av.n_dead_tup::double precision > av.av_threshold AS av_neaded,\r\n        CASE\r\n            WHEN av.reltuples > 0::double precision THEN av.n_dead_tup::numeric\r\n                / av.reltuples::numeric\r\n            ELSE 0::numeric\r\n        END AS pct_dead\r\nFROM (\r\n    SELECT pn.nspname,\r\n            pc.relname,\r\n            pg_stat_get_tuples_inserted(pc.oid) AS n_tup_ins,\r\n            pg_stat_get_tuples_updated(pc.oid) AS n_tup_upd,\r\n            pg_stat_get_tuples_deleted(pc.oid) AS n_tup_del,\r\n            pg_stat_get_live_tuples(pc.oid) AS n_live_tup,\r\n            pg_stat_get_dead_tuples(pc.oid) AS n_dead_tup,\r\n            pc.reltuples,\r\n            round(COALESCE(cto.autovacuum_vacuum_threshold,\r\n                setting(''autovacuum_vacuum_threshold''::text))::integer::double precision + COALESCE(cto.autovacuum_vacuum_scale_factor, setting(''autovacuum_vacuum_scale_factor''::text))::numeric::double precision * pc.reltuples) AS av_threshold,\r\n            date_trunc(''minute''::text,\r\n                GREATEST(pg_stat_get_last_vacuum_time(pc.oid), pg_stat_get_last_autovacuum_time(pc.oid))) AS last_vacuum,\r\n            date_trunc(''minute''::text,\r\n                GREATEST(pg_stat_get_last_analyze_time(pc.oid), pg_stat_get_last_autoanalyze_time(pc.oid))) AS last_analyze\r\n    FROM pg_catalog.pg_class pc\r\n             LEFT JOIN pg_catalog.pg_namespace pn ON pn.oid = pc.relnamespace\r\n             LEFT JOIN (\r\n        SELECT pc_1.oid,\r\n                    split_part(a.reloptions, ''=''::text, 2) AS\r\n                        autovacuum_vacuum_scale_factor,\r\n                    split_part(b.reloptions, ''=''::text, 2) AS\r\n                        autovacuum_vacuum_threshold\r\n        FROM pg_catalog.pg_class pc_1\r\n                     LEFT JOIN (\r\n            SELECT a2.oid,\r\n                            a2.reloptions\r\n            FROM (\r\n                SELECT pc_2.oid,\r\n                                    unnest(pc_2.reloptions) AS reloptions\r\n                FROM pg_catalog.pg_class pc_2\r\n                ) a2\r\n            WHERE split_part(a2.reloptions, ''=''::text, 1) =\r\n                ''autovacuum_vacuum_scale_factor''::text\r\n            ) a ON a.oid = pc_1.oid\r\n                     LEFT JOIN (\r\n            SELECT b2.oid,\r\n                            b2.reloptions\r\n            FROM (\r\n                SELECT pc_2.oid,\r\n                                    unnest(pc_2.reloptions) AS reloptions\r\n                FROM pg_catalog.pg_class pc_2\r\n                ) b2\r\n            WHERE split_part(b2.reloptions, ''=''::text, 1) =\r\n                ''autovacuum_vacuum_threshold''::text\r\n            ) b ON b.oid = pc_1.oid\r\n        ) cto ON cto.oid = pc.oid\r\n    WHERE (pc.relkind = ANY (ARRAY[''r''::\"char\", ''t''::\"char\"])) AND (pn.nspname\r\n        <> ALL (ARRAY[''pg_catalog''::name, ''information_schema''::name])) AND pn.nspname !~ ''^pg_toast''::text\r\n    ) av\r\nORDER BY av.n_dead_tup DESC', False, False, NULL, 1, E'reports', E'autovacuum_thresholds'),
  (E'auto_vacuum_count', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,\r\n    datname AS database_name,\r\ncount(*) AS count\r\nFROM pg_catalog.pg_stat_progress_vacuum\r\nGROUP BY datname', False, True, 9.6, 0, E'reports', E'auto_vacuum_count'),
  (E'autovacuum', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,\r\n    pspv.datname AS database_name,\r\n         CASE\r\n           WHEN substr(psa.query, 0, 28) = ''autovacuum: VACUUM ANALYZE ''::text\r\n             THEN split_part(substr(psa.query, 28), ''.''::text, 1)\r\n           WHEN substr(psa.query, 0, 20) = ''autovacuum: VACUUM ''::text\r\n             THEN split_part(substr(psa.query, 20), ''.''::text, 1)\r\n           WHEN substr(psa.query, 0, 21) = ''autovacuum: ANALYZE ''::text\r\n             THEN split_part(substr(psa.query, 21), ''.''::text, 1)\r\n           ELSE NULL::text\r\n         END AS schema_name,\r\n         CASE\r\n           WHEN substr(psa.query, 0, 28) = ''autovacuum: VACUUM ANALYZE ''::text\r\n             THEN split_part(substr(psa.query, 28), ''.''::text, 2)\r\n           WHEN substr(psa.query, 0, 20) = ''autovacuum: VACUUM ''::text\r\n             THEN split_part(substr(psa.query, 20), ''.''::text, 2)\r\n           WHEN substr(psa.query, 0, 21) = ''autovacuum: ANALYZE ''::text\r\n             THEN split_part(substr(psa.query, 21), ''.''::text, 2)\r\n           ELSE NULL::text\r\n         END AS table_name,\r\n         CASE\r\n           WHEN substr(psa.query, 0, 28) = ''autovacuum: VACUUM ANALYZE ''::text\r\n             THEN substr(psa.query, 28)\r\n           WHEN substr(psa.query, 0, 20) = ''autovacuum: VACUUM ''::text\r\n             THEN substr(psa.query, 20)\r\n           WHEN substr(psa.query, 0, 21) = ''autovacuum: ANALYZE ''::text\r\n             THEN substr(psa.query, 21)\r\n           ELSE NULL::text\r\n         END AS name,\r\n         CASE\r\n           WHEN substr(psa.query, 0, 28) = ''autovacuum: VACUUM ANALYZE ''::text\r\n             THEN TRUE\r\n           WHEN substr(psa.query, 0, 20) = ''autovacuum: VACUUM ''::text\r\n             THEN TRUE\r\n           ELSE FALSE\r\n         END AS vacuum,\r\n         CASE\r\n           WHEN substr(psa.query, 0, 28) = ''autovacuum: VACUUM ANALYZE ''::text\r\n             THEN TRUE\r\n           WHEN substr(psa.query, 0, 21) = ''autovacuum: ANALYZE ''::text\r\n             THEN TRUE\r\n             ELSE FALSE\r\n         END AS analyze,\r\n\r\n\t(date_part(''seconds'', date_trunc(''second'',now()-backend_start)) +\r\n\t(date_part(''minutes'', date_trunc(''second'',now()-backend_start))*60) +\r\n\t(date_part(''hours'', date_trunc(''second'',now()-backend_start))*60*60) +\r\n\t(date_part(''days'', date_trunc(''second'',now()-backend_start))*60*60*24))::INTEGER AS running_time,\r\n/*\r\n\tdate_part(''seconds'', date_trunc(''second'',((pspv.heap_blks_total::numeric / pspv.heap_blks_scanned::numeric) * (now()-backend_start)))) +\r\n\t(date_part(''minutes'', date_trunc(''second'',((pspv.heap_blks_total::numeric / pspv.heap_blks_scanned::numeric) * (now()-backend_start))))*60) +\r\n\t(date_part(''hours'', date_trunc(''second'',((pspv.heap_blks_total::numeric / pspv.heap_blks_scanned::numeric) * (now()-backend_start))))*60*60) +\r\n\t(date_part(''days'', date_trunc(''second'',((pspv.heap_blks_total::numeric / pspv.heap_blks_scanned::numeric) * (now()-backend_start))))*60*60*24) AS estamited_time_left,\r\n*/\t\r\n\tpspv.phase, pspv.heap_blks_total, pspv.heap_blks_total * setting(''block_size'')::bigint AS heap_blks_total_size, \r\n    pspv.heap_blks_scanned, pspv.heap_blks_scanned::numeric / pspv.heap_blks_total::numeric AS heap_blks_scanned_pct, \r\n    pspv.heap_blks_vacuumed, pspv.heap_blks_vacuumed::numeric / pspv.heap_blks_total::numeric AS heap_blks_vacuumed_pct,\r\n    pspv.index_vacuum_count, pspv.max_dead_tuples, pspv.num_dead_tuples,\r\n    backend_start, \r\n    --xact_start, query_start, state_change, \r\n    wait_event_type, wait_event, state, backend_xmin \r\nFROM pg_catalog.pg_stat_progress_vacuum pspv\r\nLEFT JOIN pg_catalog.pg_stat_activity psa ON pspv.pid = psa.pid', False, True, 9.6, 0, E'reports', E'autovacuum'),
  (E'pg_database', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name, datname AS database_name FROM pg_catalog.pg_database', False, True, NULL, 0, E'reports', E'pg_database'),
  (E'pg_settings', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name, *, null::boolean AS pending_restart FROM pg_catalog.pg_settings', False, True, 9.4, 0, E'reports', E'pg_settings'),
  (E'pg_settings', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name, * FROM pg_catalog.pg_settings', False, True, 9.5, 0, E'reports', E'pg_settings'),
  (E'pg_stat_activity', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,\r\ndatname AS database_name,\r\npid, state, application_name, null::text AS backend_type, null::text AS wait_event_type, null::text AS wait_event, backend_start, xact_start, query_start, state_change, backend_xmin\r\nFROM pg_catalog.pg_stat_activity', False, True, 9.4, 0, E'reports', E'pg_stat_activity'),
  (E'pg_stat_activity', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,\r\ndatname AS database_name,\r\npid, state, application_name, null::text AS backend_type, wait_event_type, wait_event, backend_start, xact_start, query_start, state_change, backend_xmin\r\nFROM pg_catalog.pg_stat_activity', False, True, 9.6, 0, E'reports', E'pg_stat_activity'),
  (E'pg_stat_activity', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,\r\ndatname AS database_name,\r\npid, state, application_name, backend_type, wait_event_type, wait_event, backend_start, xact_start, query_start, state_change, backend_xmin\r\nFROM pg_catalog.pg_stat_activity', False, True, 10, 0, E'reports', E'pg_stat_activity'),
  (E'replication_status', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,  COALESCE (\r\n\tCASE WHEN pg_is_in_recovery() IS FALSE THEN ''Primary'' ELSE ''Secondary'' END,\r\n    ''Disconnected''\r\n    ) AS status', False, True, NULL, 0, E'reports', E'replication_status'),
  (E'table_size', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,\r\n    tables.table_catalog AS database_name,\r\n    tables.table_schema AS schema_name,\r\n    tables.table_name AS table_name,\r\n    (quote_ident(tables.table_schema::text) || ''.''::text) ||\r\n        quote_ident(tables.table_name::text) AS name,\r\n    pg_relation_size(((quote_ident(tables.table_schema)::text || ''.''::text) ||\r\n        quote_ident(tables.table_name)::text)::regclass) AS table_size,\r\n    pg_size_pretty(pg_relation_size(((quote_ident(tables.table_schema::text) || ''.''::text)\r\n        || quote_ident(tables.table_name::text))::regclass)) AS table_size_pretty,\r\n    pg_indexes_size(((quote_ident(tables.table_schema::text) || ''.''::text) ||\r\n        quote_ident(tables.table_name::text))::regclass) AS index_size,\r\n    pg_size_pretty(pg_indexes_size(((quote_ident(tables.table_schema::text) || ''.''::text) ||\r\n        quote_ident(tables.table_name::text))::regclass)) AS index_size_pretty,\r\n    pg_total_relation_size(((quote_ident(tables.table_schema::text) || ''.''::text) ||\r\n        quote_ident(tables.table_name::text))::regclass) AS total_size,\r\n    pg_size_pretty(pg_total_relation_size(((quote_ident(tables.table_schema)::text ||\r\n        ''.''::text) || quote_ident(tables.table_name)::text)::regclass)) AS total_size_pretty,\r\n    now() AS \"time\"\r\nFROM information_schema.tables\r\nWHERE tables.table_type::text = ''BASE TABLE''::text AND\r\n    (tables.table_schema::text <> ALL (ARRAY[''information_schema''::character varying::text, ''pg_catalog''::character varying::text]))', True, False, NULL, 0, E'reports', E'table_size'),
  (E'table_stats', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,\r\n    database() AS database_name,\r\n    pg_stat_user_tables.schemaname AS schema_name,\r\n    pg_stat_user_tables.relname AS table_name,\r\n    (quote_ident(pg_stat_user_tables.schemaname::text) || ''.''::text) ||\r\n        quote_ident(pg_stat_user_tables.relname::text) AS name,\r\n    pg_stat_user_tables.last_vacuum,\r\n    pg_stat_user_tables.last_analyze,\r\n    pg_stat_user_tables.last_autovacuum,\r\n    pg_stat_user_tables.last_autoanalyze,\r\n    now() AS \"time\"\r\nFROM pg_stat_user_tables', False, False, NULL, 1, E'reports', E'table_stats'),
  (E'custom_table_settings', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,\r\n    database() AS database_name,\r\n    pn.nspname AS schema_name,\r\n    pc.relname AS table_name,\r\n    (quote_ident(pn.nspname::text) || ''.''::text) ||\r\n        quote_ident(pc.relname::text) AS \"Table Name\",\r\n    unnest(pc.reloptions) AS \"Table Setting\"\r\nFROM pg_catalog.pg_class pc\r\n     JOIN pg_catalog.pg_namespace pn ON pn.oid = pc.relnamespace\r\nWHERE pc.reloptions IS NOT NULL AND (pn.nspname <> ALL\r\n    (ARRAY[''pg_catalog''::name, ''information_schema''::name]))', False, False, NULL, 1, E'reports', E'custom_table_settings'),
  (E'granted_locks', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,\r\n    database() AS database_name,\r\n    date_part(''seconds''::text, now() - psa.xact_start) +\r\n        date_part(''minutes''::text, now() - psa.xact_start) * 60::double precision + date_part(''hours''::text, now() - psa.xact_start) * 60::double precision * 60::double precision + date_part(''days''::text, now() - psa.xact_start) * 60::double precision * 60::double precision * 24::double precision AS \"Time\",\r\n    psa.pid AS \"PG Process ID\",\r\n    psa.application_name AS \"Application Name\",\r\n    psa.xact_start AS \"Transaction Start\",\r\n    locks.\"Locks\",\r\n        NULL::text AS \"AutoVacuum\"\r\nFROM pg_catalog.pg_stat_activity psa\r\n     LEFT JOIN (\r\n    SELECT a.pid,\r\n            string_agg((a.\"Object\" || '' - ''::text) || a.\"Mode\", ''\r\n''::text) AS \"Locks\"\r\n    FROM (\r\n        SELECT psa_1.pid,\r\n                    (pn.nspname::text || ''.''::text) || pc.relname::text AS \"Object\",\r\n                    string_agg(pl.mode, '', ''::text) AS \"Mode\"\r\n        FROM pg_catalog.pg_locks pl\r\n                     LEFT JOIN pg_catalog.pg_stat_activity psa_1 ON pl.pid = psa_1.pid\r\n                     LEFT JOIN pg_catalog.pg_class pc ON pl.relation = pc.oid\r\n                     LEFT JOIN pg_catalog.pg_namespace pn ON pc.relnamespace = pn.oid\r\n        WHERE pl.granted = true\r\n        GROUP BY psa_1.pid, ((pn.nspname::text || ''.''::text) || pc.relname::text)\r\n        ) a\r\n    GROUP BY a.pid\r\n    ) locks USING (pid)\r\nWHERE psa.datname = database() AND locks.\"Locks\" IS NOT NULL', False, False, 9.4, 1, E'reports', E'granted_locks'),
  (E'granted_locks', E'SELECT now() AS log_time, setting(''cluster_name''::text) AS cluster_name,\r\n    database() AS database_name,\r\n    date_part(''seconds''::text, now() - psa.xact_start) +\r\n        date_part(''minutes''::text, now() - psa.xact_start) * 60::double precision + date_part(''hours''::text, now() - psa.xact_start) * 60::double precision * 60::double precision + date_part(''days''::text, now() - psa.xact_start) * 60::double precision * 60::double precision * 24::double precision AS \"Time\",\r\n    psa.pid AS \"PG Process ID\",\r\n    psa.application_name AS \"Application Name\",\r\n    psa.xact_start AS \"Transaction Start\",\r\n    locks.\"Locks\",\r\n        CASE\r\n            WHEN psa.backend_type = ''autovacuum worker''::text THEN psa.query\r\n            ELSE NULL::text\r\n        END AS \"AutoVacuum\"\r\nFROM pg_catalog.pg_stat_activity psa\r\n     LEFT JOIN (\r\n    SELECT a.pid,\r\n            string_agg((a.\"Object\" || '' - ''::text) || a.\"Mode\", ''\r\n''::text) AS \"Locks\"\r\n    FROM (\r\n        SELECT psa_1.pid,\r\n                    (pn.nspname::text || ''.''::text) || pc.relname::text AS \"Object\",\r\n                    string_agg(pl.mode, '', ''::text) AS \"Mode\"\r\n        FROM pg_catalog.pg_locks pl\r\n                     LEFT JOIN pg_catalog.pg_stat_activity psa_1 ON pl.pid = psa_1.pid\r\n                     LEFT JOIN pg_catalog.pg_class pc ON pl.relation = pc.oid\r\n                     LEFT JOIN pg_catalog.pg_namespace pn ON pc.relnamespace = pn.oid\r\n        WHERE pl.granted = true\r\n        GROUP BY psa_1.pid, ((pn.nspname::text || ''.''::text) || pc.relname::text)\r\n        ) a\r\n    GROUP BY a.pid\r\n    ) locks USING (pid)\r\nWHERE psa.datname = database() AND locks.\"Locks\" IS NOT NULL', False, False, 10, 1, E'reports', E'granted_locks');

-- LOAD DATA INTO tools.build_items
INSERT INTO tools.build_items ("item_schema", "item_name", "item_sql", "build_order", "disabled")
VALUES 
  (E'reports', E'autovacuum_length', E'CREATE OR REPLACE VIEW reports.autovacuum_length(\r\n    cluster_name,\r\n    database_name,\r\n    running_time)\r\nAS\r\n  \tSELECT b.cluster_name,\r\n         b.database_name, COALESCE(max(b.running_time)) AS running_time FROM \r\n\t(\r\n    \tSELECT max(log_time) AS log_time FROM reports.autovacuum\r\n    ) a\r\n\tLEFT JOIN reports.autovacuum b USING (log_time)           \r\n  GROUP BY b.cluster_name,\r\n           b.database_name;;', NULL, False),
  (E'reports', E'autovacuum_thresholds_idx', E'CREATE INDEX IF NOT EXISTS autovacuum_thresholds_idx ON reports.autovacuum_thresholds\r\n  USING btree (log_time, cluster_name, database_name);\r\nSELECT create_hypertable(''reports.autovacuum_thresholds'', ''log_time'', ''cluster_name'');', NULL, True),
  (E'reports', E'databases', E'CREATE OR REPLACE VIEW reports.databases (\r\n    cluster_name,\r\n    database_name)\r\nAS\r\nSELECT cpd.cluster_name, cpd.database_name \r\nFROM tools.servers s\r\nLEFT JOIN reports.pg_database cpd\r\nON s.server_name = cpd.cluster_name\r\nWHERE (s.read_all_databases IS TRUE\r\nOR (s.maintenance_database = cpd.database_name AND s.read_all_databases IS FALSE))\r\nAND cpd.database_name NOT IN (''template0'', ''template1'', ''rdsadmin'')', NULL, False),
  (E'reports', E'hypertable', E'-- Needs to be OWNED by user Postgres\r\n-- With SELECT permissions for user Grafana\r\n-- Our current code does not support this setup, that is why this is disabled and created manually.\r\nCREATE OR REPLACE VIEW reports.hypertable (\r\n    table_schema,\r\n    table_name,\r\n    table_owner,\r\n    num_dimensions,\r\n    num_chunks,\r\n    table_size,\r\n    index_size,\r\n    toast_size,\r\n    total_size)\r\nAS\r\nSELECT ht.schema_name AS table_schema,\r\n    ht.table_name,\r\n    t.tableowner AS table_owner,\r\n    ht.num_dimensions,\r\n    (\r\n    SELECT count(1) AS count\r\n    FROM _timescaledb_catalog.chunk ch\r\n    WHERE ch.hypertable_id = ht.id\r\n    ) AS num_chunks,\r\n    size.table_size,\r\n    size.index_size,\r\n    size.toast_size,\r\n    size.total_size\r\nFROM _timescaledb_catalog.hypertable ht\r\n     LEFT JOIN pg_tables t ON ht.table_name = t.tablename AND ht.schema_name =\r\n         t.schemaname\r\n     LEFT JOIN LATERAL hypertable_relation_size(\r\n        CASE\r\n            WHEN has_schema_privilege(ht.schema_name::text, ''USAGE''::text) THEN\r\n                format(''%I.%I''::text, ht.schema_name, ht.table_name)\r\n            ELSE NULL::text\r\n        END::regclass) size(table_size, index_size, toast_size, total_size) ON true;', NULL, True),
  (E'reports', E'last_log_entries', E'CREATE OR REPLACE VIEW reports.last_log_entries AS\r\nSELECT postgres_log.cluster_name,\r\n    min(postgres_log.log_time) AS first_log_time,\r\n    max(postgres_log.log_time) AS last_log_time\r\nFROM reports.postgres_log\r\nGROUP BY postgres_log.cluster_name;\r\n', NULL, False),
  (E'reports', E'postgres_log', E'CREATE TABLE IF NOT EXISTS reports.postgres_log\r\n(\r\n  cluster_name TEXT NOT NULL,\r\n  log_time timestamp(3) with time zone NOT NULL,\r\n  user_name text,\r\n  database_name text,\r\n  process_id integer,\r\n  connection_from text,\r\n  session_id text NOT NULL,\r\n  session_line_num bigint NOT NULL,\r\n  command_tag text,\r\n  session_start_time timestamp with time zone,\r\n  virtual_transaction_id text,\r\n  transaction_id bigint,\r\n  error_severity text,\r\n  sql_state_code text,\r\n  message text,\r\n  detail text,\r\n  hint text,\r\n  internal_query text,\r\n  internal_query_pos integer,\r\n  context text,\r\n  query text,\r\n  query_pos integer,\r\n  location text,\r\n  application_name text,\r\n  PRIMARY KEY (session_id, session_line_num)\r\n);\r\n\r\nCREATE INDEX IF NOT EXISTS postgres_logs_idx ON postgres_logs.postgres_logs\r\n  USING btree (log_time, cluster_name, database_name);\r\n\r\nCREATE INDEX IF NOT EXISTS postgres_logs_log_time_idx ON postgres_logs.postgres_logs\r\n  USING btree (log_time DESC);\r\n\r\nCREATE INDEX IF NOT EXISTS postgres_logs_pkey ON postgres_logs.postgres_logs\r\n  USING btree (cluster_name, session_id, session_line_num);\r\n\r\nSELECT create_hypertable(''reports.postgres_logs'', ''log_time'', ''cluster_name'');\r\n', NULL, True);

INSERT INTO tools.servers ("server_name", "server", "port", "maintenance_database", "username", "password", "read_all_databases", "disabled", "maintenance_db", "pgpass_file")
VALUES
  ('localhost', 'localhost', '30002', 'postgres', NULL, NULL, TRUE, FALSE, TRUE, NULL);
