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

/*
ok 45 - Function tools.postgres_log_trigger() should be owned by grafana
ok 46 - Function tools.create_logs() should be owned by grafana
ok 47 - Function tools.create_server_database_inherits(text, text) should be owned by grafana
ok 48 - Function tools.create_server_inherits(text) should be owned by grafana
ok 49 - Function tools.delete_logs() should be owned by grafana
ok 50 - Function tools.field_list_check(text, text) should be owned by grafana
ok 51 - Function logs.connection_attempt_history(text, text, text[], text, text, boolean, boolean) should be owned by grafana
ok 52 - Function logs.connection_history(text, text, text[], text, text, boolean, boolean) should be owned by grafana
ok 53 - Function tools.generate_timestamps(text, text) should be owned by grafana
ok 54 - Function tools.group_by_interval(text, text) should be owned by grafana
ok 55 - Function tools.interval_to_field(text) should be owned by grafana
ok 56 - Function tools.parse_csv(text, boolean) should be owned by grafana
ok 57 - Function logs.autoanalyze_log(text, text, text, text, text, bigint) should be owned by grafana
ok 58 - Function logs.autoanalyze_log_count(text, text, timestamp with time zone, timestamp with time zone, text, text, text, text) should be owned by grafana
ok 59 - Function logs.autoanalyze_log_count_chart(text, text, text, text, text) should be owned by grafana
ok 60 - Function logs.autovacuum_autoanalyze_count(text, text, text, text, text) should be owned by grafana
ok 61 - Function logs.error_history(text, text, text[], text, text, boolean) should be owned by grafana
ok 62 - Function logs.fatal_history(text, text, text[], text, text, boolean) should be owned by grafana
ok 63 - Function logs.autovacuum_log(text, text, text, text, text, bigint) should be owned by grafana
ok 64 - Function logs.autovacuum_log_count(text, text, timestamp with time zone, timestamp with time zone, text, text, text, text) should be owned by grafana
ok 65 - Function logs.autovacuum_log_count_chart(text, text, text, text, text) should be owned by grafana
ok 66 - Function logs.autovacuum_log_removed_size(text, text, text, text, text, text) should be owned by grafana
ok 67 - Function logs.autovacuum_log_removed_space_chart(text, text, text, text, text) should be owned by grafana
ok 68 - Function logs.autovacuum_log_tuples_removed(text, text, text, text, text, text) should be owned by grafana
ok 69 - Function logs.autovacuum_log_tuples_removed_chart(text, text, text, text, text) should be owned by grafana
ok 70 - Function logs.autovacuum_thresholds(text, text, text, timestamp with time zone, text) should be owned by grafana
ok 71 - Function logs.checkpoint_buffers(text, text, timestamp with time zone, timestamp with time zone, text) should be owned by grafana
ok 72 - Function logs.checkpoint_files(text, text, timestamp with time zone, timestamp with time zone, text) should be owned by grafana
ok 73 - Function logs.checkpoint_logs(text, text, bigint) should be owned by grafana
ok 74 - Function logs.checkpoint_wal_file_usage(text, text, timestamp with time zone, timestamp with time zone, text) should be owned by grafana
ok 75 - Function logs.checkpoint_warning_logs(text, text, bigint) should be owned by grafana
ok 76 - Function stats.vacuum_settings(text, text, timestamp with time zone, text) should be owned by grafana
ok 77 - Function logs.custom_table_settings(text, text, timestamp with time zone, text) should be owned by grafana
ok 78 - Function logs.checkpoint_warning_logs_count(text, text, timestamp with time zone, timestamp with time zone, text) should be owned by grafana
ok 79 - Function logs.checkpoint_write_buffers(text, text, timestamp with time zone, timestamp with time zone, text) should be owned by grafana
ok 80 - Function stats.autovacuum(text, text, text, timestamp without time zone, text) should be owned by grafana
ok 81 - Function stats.pg_stat_activity_active(text, text, timestamp with time zone, text) should be owned by grafana
ok 82 - Function stats.granted_locks(text, text, timestamp with time zone, text) should be owned by grafana
ok 83 - Function logs.ldap_error_history(text, text, text[], text, text, boolean) should be owned by grafana
ok 84 - Function logs.update_pg_log_databases() should be owned by grafana
ok 85 - Function tools.timescaledb_enterprise() should be owned by grafana
ok 86 - Function tools.timescaledb_drop_chunks() should be owned by grafana
*/

END IF;

END $$;


