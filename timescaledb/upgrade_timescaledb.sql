\set upgrade_to_pgmonitor_version 2
\set hash_partitions 20
\set ON_ERROR_STOP true

DO $$
DECLARE
    r RECORD;
BEGIN
    SELECT * INTO r FROM pg_catalog.pg_database WHERE datname = 'reports';
    IF FOUND THEN
        ALTER DATABASE reports RENAME TO pgmonitor_db;
    END IF;
END $$;

\connect pgmonitor_db
\set ON_ERROR_STOP true

SET client_encoding = 'UTF8';
SELECT pg_catalog.set_config('search_path', '', false);

DO $$
DECLARE
    r RECORD;
BEGIN
    SELECT * INTO r FROM information_schema.tables WHERE table_schema = 'tools' AND table_name = 'version';
    IF NOT FOUND THEN
        CREATE TABLE tools.version (
            db_version TEXT
        );
        ALTER TABLE tools.version OWNER TO grafana;
        INSERT INTO tools.version VALUES (1);
    END IF;

    SELECT * INTO r FROM tools.version;

    IF r.db_version = '1' THEN
        -- Create logs schema
        CREATE SCHEMA logs;
        ALTER SCHEMA logs OWNER TO grafana;

        -- Create logs schema
        CREATE SCHEMA stats;
        ALTER SCHEMA stats OWNER TO grafana;

        ALTER TABLE reports.archive_failure_log SET SCHEMA logs;
        ALTER TABLE logs.archive_failure_log OWNER TO grafana;

        ALTER TABLE reports.autoanalyze_logs SET SCHEMA logs;
        ALTER TABLE logs.autoanalyze_logs OWNER TO grafana;

        ALTER TABLE reports.autovacuum_logs SET SCHEMA logs;
        ALTER TABLE logs.autovacuum_logs OWNER TO grafana;

        ALTER TABLE reports.checkpoint_logs SET SCHEMA logs;
        ALTER TABLE logs.checkpoint_logs OWNER TO grafana;

        ALTER TABLE reports.checkpoint_warning_logs SET SCHEMA logs;
        ALTER TABLE logs.checkpoint_warning_logs OWNER TO grafana;

        ALTER TABLE reports.lock_logs SET SCHEMA logs;
        ALTER TABLE logs.lock_logs OWNER TO grafana;

        ALTER TABLE reports.lock_message_types SET SCHEMA stats;
        ALTER TABLE stats.lock_message_types OWNER TO grafana;

        ALTER TABLE reports.postgres_log SET SCHEMA logs;
        ALTER TABLE logs.postgres_log OWNER TO grafana;

        ALTER TABLE reports.postgres_log_databases SET SCHEMA logs;
        ALTER TABLE logs.postgres_log_databases OWNER TO grafana;

        ALTER TABLE reports.postgres_log_databases_temp SET SCHEMA logs;
        ALTER TABLE logs.postgres_log_databases_temp OWNER TO grafana;

        ALTER TABLE reports.current_autovacuum SET SCHEMA stats;
        ALTER TABLE stats.current_autovacuum RENAME TO autovacuum;
        ALTER TABLE stats.autovacuum OWNER TO grafana;

        ALTER TABLE reports.current_auto_vacuum_count SET SCHEMA stats;
        ALTER TABLE stats.current_auto_vacuum_count RENAME TO autovacuum_count;
        ALTER TABLE stats.autovacuum_count OWNER TO grafana;

        ALTER TABLE reports.autovacuum_thresholds SET SCHEMA stats;
        ALTER TABLE stats.autovacuum_thresholds OWNER TO grafana;

        ALTER TABLE reports.custom_table_settings SET SCHEMA stats;
        ALTER TABLE stats.custom_table_settings OWNER TO grafana;

        ALTER TABLE reports.granted_locks SET SCHEMA stats;
        ALTER TABLE stats.granted_locks OWNER TO grafana;

        ALTER TABLE reports.current_pg_database SET SCHEMA stats;
        ALTER TABLE stats.current_pg_database RENAME TO pg_database;
        ALTER TABLE stats.pg_database OWNER TO grafana;

        ALTER TABLE reports.current_pg_settings SET SCHEMA stats;
        ALTER TABLE stats.current_pg_settings RENAME TO pg_settings;
        ALTER TABLE stats.pg_settings OWNER TO grafana;

        ALTER TABLE reports.current_pg_stat_activity SET SCHEMA stats;
        ALTER TABLE stats.current_pg_stat_activity RENAME TO pg_stat_activity;
        ALTER TABLE stats.pg_stat_activity OWNER TO grafana;

        ALTER TABLE reports.current_replication_status SET SCHEMA stats;
        ALTER TABLE stats.current_replication_status RENAME TO replication_status;
        ALTER TABLE stats.replication_status OWNER TO grafana;

        ALTER TABLE reports.current_table_stats SET SCHEMA stats;
        ALTER TABLE stats.current_table_stats RENAME TO table_stats;
        ALTER TABLE stats.table_stats OWNER TO grafana;

        ALTER TABLE tools.build_items OWNER TO grafana;

        ALTER TABLE tools.queries_disabled OWNER TO grafana;

        ALTER TABLE tools.query OWNER TO grafana;

        ALTER TABLE tools.servers OWNER TO grafana;

        ALTER VIEW reports.autovacuum_length SET SCHEMA logs;
        ALTER VIEW logs.autovacuum_length OWNER TO grafana;

        ALTER VIEW reports.databases SET SCHEMA logs;
        ALTER VIEW logs.databases OWNER TO grafana;

        ALTER VIEW reports.last_log_entries SET SCHEMA logs;
        ALTER VIEW logs.last_log_entries OWNER TO grafana;

        ALTER VIEW tools.pg_major_version OWNER TO grafana;

--        ALTER VIEW tools.table_size OWNER TO grafana;

        ALTER VIEW reports.hypertable SET SCHEMA tools;
        ALTER VIEW tools.hypertable OWNER TO grafana;


END IF;

END $$;


