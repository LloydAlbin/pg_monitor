SET client_encoding = 'UTF8';
SELECT pg_catalog.set_config('search_path', '', false);
\set ON_ERROR_STOP true

-- Create grafana user
CREATE USER grafana LOGIN IN ROLE pgmon;

-- Create pgmon_db database
CREATE DATABASE pgmonitor_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US' LC_CTYPE = 'en_US';
ALTER DATABASE pgmonitor_db OWNER TO grafana;
--GRANT CREATE ON DATABASE pgmon_db TO grafana;

-- Connect to pgmon_db database
\connect pgmonitor_db
\set ON_ERROR_STOP true

SET client_encoding = 'UTF8';
SELECT pg_catalog.set_config('search_path', '', false);

-- Install TimescaleDB Extension
CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;
COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data';

-- Create pgmon schema
CREATE SCHEMA pgmon;
ALTER SCHEMA pgmon OWNER TO grafana;

-- Create tools schema
CREATE SCHEMA tools;
ALTER SCHEMA tools OWNER TO grafana;

-- TABLES: pgmon
CREATE TABLE pgmon.current_pg_settings (
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
ALTER TABLE pgmon.current_pg_settings OWNER TO grafana;
CREATE INDEX current_pg_settings_cluster_name_log_time_idx ON pgmon.current_pg_settings USING btree (cluster_name, log_time DESC);
CREATE INDEX current_pg_settings_log_time_idx ON pgmon.current_pg_settings USING btree (log_time DESC);
SELECT create_hypertable('pgmon.current_pg_settings', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.current_pg_stat_activity (
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
ALTER TABLE pgmon.current_pg_stat_activity OWNER TO grafana;
CREATE INDEX current_pg_stat_activity_cluster_name_log_time_idx ON pgmon.current_pg_stat_activity USING btree (cluster_name, log_time DESC);
CREATE INDEX current_pg_stat_activity_log_time_idx ON pgmon.current_pg_stat_activity USING btree (log_time DESC);
SELECT create_hypertable('pgmon.current_pg_stat_activity', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.current_auto_vacuum_count (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name,
    count bigint
);
ALTER TABLE pgmon.current_auto_vacuum_count OWNER TO grafana;
CREATE INDEX current_auto_vacuum_count_cluster_name_log_time_idx ON pgmon.current_auto_vacuum_count USING btree (cluster_name, log_time DESC);
CREATE INDEX current_auto_vacuum_count_log_time_idx ON pgmon.current_auto_vacuum_count USING btree (log_time DESC);
SELECT create_hypertable('pgmon.current_auto_vacuum_count', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.current_replication_status (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    status text
);
ALTER TABLE pgmon.current_replication_status OWNER TO grafana;
CREATE INDEX current_replication_status_cluster_name_log_time_idx ON pgmon.current_replication_status USING btree (cluster_name, log_time DESC);
CREATE INDEX current_replication_status_log_time_idx ON pgmon.current_replication_status USING btree (log_time DESC);
SELECT create_hypertable('pgmon.current_replication_status', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.current_autovacuum (
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
ALTER TABLE pgmon.current_autovacuum OWNER TO grafana;
CREATE INDEX current_autovacuum_cluster_name_log_time_idx ON pgmon.current_autovacuum USING btree (cluster_name, log_time DESC);
CREATE INDEX current_autovacuum_log_time_idx ON pgmon.current_autovacuum USING btree (log_time DESC);
SELECT create_hypertable('pgmon.current_autovacuum', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.current_pg_database (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name
);
ALTER TABLE pgmon.current_pg_database OWNER TO grafana;
CREATE INDEX current_pg_database_cluster_name_log_time_idx ON pgmon.current_pg_database USING btree (cluster_name, log_time DESC);
CREATE INDEX current_pg_database_log_time_idx ON pgmon.current_pg_database USING btree (log_time DESC);
SELECT create_hypertable('pgmon.current_pg_database', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.granted_locks (
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
ALTER TABLE pgmon.granted_locks OWNER TO grafana;
CREATE INDEX granted_locks_cluster_name_log_time_idx ON pgmon.granted_locks USING btree (cluster_name, log_time DESC);
CREATE INDEX granted_locks_log_time_idx ON pgmon.granted_locks USING btree (log_time DESC);
SELECT create_hypertable('pgmon.granted_locks', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.current_table_stats (
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
ALTER TABLE pgmon.current_table_stats OWNER TO grafana;
CREATE INDEX current_table_stats_cluster_name_log_time_idx ON pgmon.current_table_stats USING btree (cluster_name, log_time DESC);
CREATE INDEX current_table_stats_log_time_idx ON pgmon.current_table_stats USING btree (log_time DESC);
SELECT create_hypertable('pgmon.current_table_stats', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.custom_table_settings (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name,
    schema_name name,
    table_name name,
    "Table Name" text,
    "Table Setting" text
);
ALTER TABLE pgmon.custom_table_settings OWNER TO grafana;
CREATE INDEX custom_table_settings_cluster_name_log_time_idx ON pgmon.custom_table_settings USING btree (cluster_name, log_time DESC);
CREATE INDEX custom_table_settings_log_time_idx ON pgmon.custom_table_settings USING btree (log_time DESC);
SELECT create_hypertable('pgmon.custom_table_settings', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.autovacuum_thresholds (
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
ALTER TABLE pgmon.autovacuum_thresholds OWNER TO grafana;
CREATE INDEX autovacuum_thresholds_cluster_name_log_time_idx ON pgmon.autovacuum_thresholds USING btree (cluster_name, log_time DESC);
CREATE INDEX autovacuum_thresholds_log_time_idx ON pgmon.autovacuum_thresholds USING btree (log_time DESC);
SELECT create_hypertable('pgmon.autovacuum_thresholds', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.autoanalyze_logs (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name text,
    schema_name text,
    table_name text,
    cpu_system numeric,
    cpu_user numeric,
    elasped_seconds numeric
);
ALTER TABLE pgmon.autoanalyze_logs OWNER TO grafana;
CREATE INDEX autoanalyze_logs_cluster_name_time_idx ON pgmon.autoanalyze_logs USING btree (cluster_name, log_time DESC);
CREATE INDEX autoanalyze_logs_time_idx ON pgmon.autoanalyze_logs USING btree (log_time DESC);
SELECT create_hypertable('pgmon.autoanalyze_logs', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.autovacuum_logs (
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
ALTER TABLE pgmon.autovacuum_logs OWNER TO grafana;
CREATE INDEX autovacuum_logs_cluster_name_time_idx ON pgmon.autovacuum_logs USING btree (cluster_name, log_time DESC);
CREATE INDEX autovacuum_logs_time_idx ON pgmon.autovacuum_logs USING btree (log_time DESC);
SELECT create_hypertable('pgmon.autovacuum_logs', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.lock_logs (
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
ALTER TABLE pgmon.lock_logs OWNER TO grafana;
CREATE INDEX lock_logs_cluster_name_time_idx ON pgmon.lock_logs USING btree (cluster_name, log_time DESC);
CREATE INDEX lock_logs_time_idx ON pgmon.lock_logs USING btree (log_time DESC);
SELECT create_hypertable('pgmon.lock_logs', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.checkpoint_warning_logs (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    seconds integer,
    hint text
);
ALTER TABLE pgmon.checkpoint_warning_logs OWNER TO postgres;
CREATE INDEX checkpoint_warning_logs_cluster_name_time_idx ON pgmon.checkpoint_warning_logs USING btree (cluster_name, log_time DESC);
CREATE INDEX checkpoint_warning_logs_time_idx ON pgmon.checkpoint_warning_logs USING btree (log_time DESC);
SELECT create_hypertable('pgmon.checkpoint_warning_logs', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.checkpoint_logs (
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
ALTER TABLE pgmon.checkpoint_logs OWNER TO grafana;
CREATE INDEX checkpoint_logs_cluster_name_time_idx ON pgmon.checkpoint_logs USING btree (cluster_name, log_time DESC);
CREATE INDEX checkpoint_logs_time_idx ON pgmon.checkpoint_logs USING btree (log_time DESC);
SELECT create_hypertable('pgmon.checkpoint_logs', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.postgres_log (
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
ALTER TABLE pgmon.postgres_log OWNER TO grafana;
CREATE INDEX postgres_log_cluster_name_log_time_idx ON pgmon.postgres_log USING btree (cluster_name, log_time DESC);
CREATE INDEX postgres_log_log_time_idx ON pgmon.postgres_log USING btree (log_time DESC);
CREATE INDEX postgres_logs_idx ON pgmon.postgres_log USING btree (log_time, cluster_name, database_name);
CREATE INDEX postgres_logs_pkey ON pgmon.postgres_log USING btree (cluster_name, session_id, session_line_num);
SELECT create_hypertable('pgmon.postgres_log', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.archive_failure_log (
    cluster_name text NOT NULL,
    log_time timestamp with time zone NOT NULL,
    process_id integer,
    message text,
    detail text
);
ALTER TABLE pgmon.archive_failure_log OWNER TO postgres;
CREATE INDEX archive_failure_log_cluster_name_log_time_idx ON pgmon.archive_failure_log USING btree (cluster_name, log_time DESC);
CREATE INDEX archive_failure_log_log_time_idx ON pgmon.archive_failure_log USING btree (log_time DESC);
SELECT create_hypertable('pgmon.archive_failure_log', 'log_time', 'cluster_name', 20);

CREATE TABLE pgmon.lock_message_types (
    message text
);
ALTER TABLE pgmon.lock_message_types OWNER TO postgres;

CREATE TABLE pgmon.postgres_log_databases (
    cluster_name text NOT NULL,
    database_name text NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone
);
ALTER TABLE pgmon.postgres_log_databases OWNER TO pgmon;
ALTER TABLE ONLY pgmon.postgres_log_databases
    ADD CONSTRAINT postgres_log_databases_pkey PRIMARY KEY (cluster_name, database_name);


CREATE TABLE pgmon.postgres_log_databases_temp (
    cluster_name text,
    database_name text,
    min timestamp with time zone,
    max timestamp with time zone
);
ALTER TABLE pgmon.postgres_log_databases_temp OWNER TO postgres;

-- VIEWS: pgmon
CREATE VIEW pgmon.autovacuum_length AS
 SELECT b.cluster_name,
    b.database_name,
    COALESCE(max(b.running_time)) AS running_time
   FROM (( SELECT max(current_autovacuum.log_time) AS log_time
           FROM pgmon.current_autovacuum) a
     LEFT JOIN pgmon.current_autovacuum b USING (log_time))
  GROUP BY b.cluster_name, b.database_name;
ALTER TABLE pgmon.autovacuum_length OWNER TO grafana;


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
ALTER TABLE tools.queries_disabled OWNER TO postgres;

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
CREATE VIEW pgmon.databases AS
 SELECT DISTINCT cpd.cluster_name,
    cpd.database_name
   FROM (tools.servers s
     LEFT JOIN pgmon.current_pg_database cpd ON ((s.server_name = cpd.cluster_name)))
  WHERE (((s.read_all_databases IS TRUE) OR ((s.maintenance_database = cpd.database_name) AND (s.read_all_databases IS FALSE))) AND (cpd.database_name <> ALL (ARRAY['template0'::name, 'template1'::name, 'rdsadmin'::name])))
  ORDER BY cpd.cluster_name, cpd.database_name;
ALTER TABLE pgmon.databases OWNER TO grafana;

CREATE VIEW pgmon.hypertable AS
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
ALTER TABLE pgmon.hypertable OWNER TO postgres;

CREATE VIEW pgmon.last_log_entries AS
 SELECT postgres_log.cluster_name,
    min(postgres_log.log_time) AS first_log_time,
    max(postgres_log.log_time) AS last_log_time
   FROM pgmon.postgres_log
  GROUP BY postgres_log.cluster_name;
ALTER TABLE pgmon.last_log_entries OWNER TO grafana;

-- VIEWS: tools
CREATE VIEW tools.current_table_size AS
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
ALTER TABLE tools.current_table_size OWNER TO postgres;

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
	-- Maintain pgmon.postgres_log_databases
		INSERT INTO pgmon.postgres_log_databases AS a (cluster_name, database_name, start_date, end_date)
			VALUES (NEW.cluster_name, NEW.database_name, NEW.log_time, NEW.log_time) 
			ON CONFLICT (cluster_name, database_name) DO UPDATE SET
				start_date = CASE WHEN a.start_date > EXCLUDED.start_date THEN EXCLUDED.start_date ELSE a.start_date END,
				end_date = CASE WHEN a.end_date < EXCLUDED.end_date THEN EXCLUDED.end_date ELSE a.end_date END;
    END IF;
*/

	IF (NEW.message LIKE 'automatic vacuum %') THEN
	-- Move autovacuum log records from pgmon.postgres_log into the pgmon.autovacuum_logs
    
    
    	INSERT INTO pgmon.autovacuum_logs VALUES (NEW.log_time,
    NEW.cluster_name,
    split_part(trim(both '"' from substr(split_part(split_part(NEW.message, E'\n', 1), ':', 1),27)), '.', 1),
    split_part(trim(both '"' from substr(split_part(split_part(NEW.message, E'\n', 1), ':', 1),27)), '.', 2),
    split_part(trim(both '"' from substr(split_part(split_part(NEW.message, E'\n', 1), ':', 1),27)), '.', 3),
    trim(split_part(split_part(NEW.message, E'\n', 1), ':', 3))::BIGINT,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 1)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 1)), ' ', 1)::bigint * current_setting('block_size')::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 2)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 2)), ' ', 1)::bigint * current_setting('block_size')::bigint,
    CASE WHEN split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 3)), ' ', 1) = '' THEN NULL::bigint ELSE split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 3)), ' ', 1)::bigint END,
    CASE WHEN split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 4)), ' ', 1) = '' THEN NULL::bigint ELSE split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 2), ':', 2), ',', 3)), ' ', 1)::bigint END,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 3), ':', 2), ',', 1)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 3), ':', 2), ',', 2)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 3), ':', 2), ',', 3)), ' ', 1)::bigint,
    CASE WHEN split_part(split_part(NEW.message, E'\n', 3), ':', 3) = '' THEN NULL::bigint ELSE split_part(split_part(NEW.message, E'\n', 3), ':', 3)::bigint END,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 4), ':', 2), ',', 1)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 4), ':', 2), ',', 2)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 4), ':', 2), ',', 3)), ' ', 1)::bigint,
    split_part(trim(split_part(split_part(split_part(NEW.message, E'\n', 4), ':', 2), ',', 3)), ' ', 1)::bigint * current_setting('block_size')::bigint,
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
	-- Move autoanalyze log records from pgmon.postgres_log into the pgmon.autoanalyze_logs
    
    
    	INSERT INTO pgmon.autoanalyze_logs VALUES (NEW.log_time,
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
	-- Move lock log records from pgmon.postgres_log into the pgmon.lock_logs


		INSERT INTO pgmon.lock_logs VALUES (
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
	-- Move checkpoint warnings records from pgmon.postgres_log into the pgmon.checkpoint_warning_logs

    
    INSERT INTO pgmon.checkpoint_warning_logs VALUES (
        NEW.log_time,
    	NEW.cluster_name,
		(regexp_match(NEW.message, 'checkpoints are occurring too frequently \((\d+) seconds apart'))[1]::INTEGER, 
        NEW.hint
    );
    	RETURN NULL;


	ELSIF (NEW.message LIKE 'checkpoint complete%') THEN
	-- Move checkpoint records from pgmon.postgres_log into the pgmon.checkpoint_logs

    
    INSERT INTO pgmon.checkpoint_logs VALUES (
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
	-- Move archive failures from pgmon.postgres_log into the pgmon.archive_failure_log

    INSERT INTO pgmon.archive_failure_log VALUES (
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

-- Add Triggers
CREATE TRIGGER postgres_log_tr BEFORE INSERT ON pgmon.postgres_log FOR EACH ROW EXECUTE PROCEDURE tools.postgres_log_trigger();
