--
-- PostgreSQL database dump
--

-- Dumped from database version 11.6
-- Dumped by pg_dump version 11.6 (Ubuntu 11.6-1.pgdg18.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: reports; Type: SCHEMA; Schema: -; Owner: grafana
--

CREATE SCHEMA reports;


ALTER SCHEMA reports OWNER TO grafana;

--
-- Name: tools; Type: SCHEMA; Schema: -; Owner: grafana
--

CREATE SCHEMA tools;


ALTER SCHEMA tools OWNER TO grafana;

--
-- Name: postgres_log_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.postgres_log_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
/*
    -- Removed due to slowing down the inserts to much and getting deadlocks that postgres will not resolve.
	IF (NEW.database_name IS NOT NULL) THEN
	-- Maintain reports.postgres_log_databases
		INSERT INTO reports.postgres_log_databases AS a (cluster_name, database_name, start_date, end_date)
			VALUES (NEW.cluster_name, NEW.database_name, NEW.log_time, NEW.log_time) 
			ON CONFLICT (cluster_name, database_name) DO UPDATE SET
				start_date = CASE WHEN a.start_date > EXCLUDED.start_date THEN EXCLUDED.start_date ELSE a.start_date END,
				end_date = CASE WHEN a.end_date < EXCLUDED.end_date THEN EXCLUDED.end_date ELSE a.end_date END;
    END IF;
*/

	IF (NEW.message LIKE 'automatic vacuum %') THEN
	-- Move autovacuum log records from reports.postgres_log into the reports.autovacuum_logs
    
    
    	INSERT INTO reports.autovacuum_logs VALUES (NEW.log_time,
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
	-- Move autoanalyze log records from reports.postgres_log into the reports.autoanalyze_logs
    
    
    	INSERT INTO reports.autoanalyze_logs VALUES (NEW.log_time,
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
	-- Move lock log records from reports.postgres_log into the reports.lock_logs


		INSERT INTO reports.lock_logs VALUES (
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
	-- Move checkpoint warnings records from reports.postgres_log into the reports.checkpoint_warning_logs

    
    INSERT INTO reports.checkpoint_warning_logs VALUES (
        NEW.log_time,
    	NEW.cluster_name,
		(regexp_match(NEW.message, 'checkpoints are occurring too frequently \((\d+) seconds apart'))[1]::INTEGER, 
        NEW.hint
    );
    	RETURN NULL;


	ELSIF (NEW.message LIKE 'checkpoint complete%') THEN
	-- Move checkpoint records from reports.postgres_log into the reports.checkpoint_logs

    
    INSERT INTO reports.checkpoint_logs VALUES (
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
	-- Move archive failures from reports.postgres_log into the reports.archive_failure_log

    INSERT INTO reports.archive_failure_log VALUES (
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


ALTER FUNCTION public.postgres_log_trigger() OWNER TO postgres;

--
-- Name: autoanalyze_log(text, text, text, text, text, bigint); Type: FUNCTION; Schema: reports; Owner: postgres
--

CREATE FUNCTION reports.autoanalyze_log(grafana_time_filter text, cluster_name_in text DEFAULT NULL::text, database_name_in text DEFAULT NULL::text, schema_name_in text DEFAULT NULL::text, table_name_in text DEFAULT NULL::text, query_limit bigint DEFAULT 100000) RETURNS TABLE("time" timestamp with time zone, cluster_name text, database_name text, schema_name text, table_name text, cpu_system numeric, cpu_user numeric, elasped_seconds numeric)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM reports.autoanalyze_log($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.autoanalyze_log($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$, 100000);

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
  sql := E'SELECT * FROM reports.autoanalyze_logs a
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


ALTER FUNCTION reports.autoanalyze_log(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text, query_limit bigint) OWNER TO postgres;

--
-- Name: autoanalyze_log_count(text, text, timestamp with time zone, timestamp with time zone, text, text, text, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.autoanalyze_log_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, count bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM reports.autoanalyze_log_count('$__interval', $$$__timeFilter(time)$$, $__timeFrom(), $__timeTo(), $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

SET application_name = 'Grafana';
SELECT time, cluster_name || ' - analyze', count FROM reports.autoanalyze_log_count('$GraphInterval', $$$__timeFilter(time)$$, $__timeFrom(), $__timeTo(), $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.autoanalyze_log_count('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

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
  reports.autoanalyze_logs
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


ALTER FUNCTION reports.autoanalyze_log_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autoanalyze_log_count_chart(text, text, text, text, text); Type: FUNCTION; Schema: reports; Owner: postgres
--

CREATE FUNCTION reports.autoanalyze_log_count_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, table_name text, count bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM reports.autoanalyze_log_count_chart($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.autoanalyze_log_count_chart($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

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
  reports.autoanalyze_logs
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


ALTER FUNCTION reports.autoanalyze_log_count_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO postgres;

--
-- Name: autovacuum_autoanalyze_count(text, text, text, text, text); Type: FUNCTION; Schema: reports; Owner: postgres
--

CREATE FUNCTION reports.autovacuum_autoanalyze_count(grafana_time_filter text, cluster_name_in text DEFAULT NULL::text, database_name_in text DEFAULT NULL::text, schema_name_in text DEFAULT NULL::text, table_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, vacuum bigint, "analyze" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM reports.autovacuum_autoanalyze_count($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.autovacuum_autoanalyze_count($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$, 100000);

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
	FROM reports.autovacuum_logs
    WHERE ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$)
	UNION 
	SELECT time_bucket(''1h'',time) AS "time"
	FROM reports.autoanalyze_logs
    WHERE ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$)
) a
LEFT JOIN (
	SELECT time_bucket(''1h'',time) AS "time", count(*) 
	FROM reports.autovacuum_logs
    WHERE ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
    AND tools.field_list_check(database_name, $$' || database_name_in::text || E'$$) 
    AND tools.field_list_check(schema_name, $$' || schema_name_in::text || E'$$) 
    AND tools.field_list_check(table_name, $$' || table_name_in::text || E'$$)
	GROUP BY time_bucket(''1h'',time)
) b USING ("time") 
LEFT JOIN (
	SELECT time_bucket(''1h'',time) AS "time", count(*) 
	FROM reports.autoanalyze_logs
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


ALTER FUNCTION reports.autovacuum_autoanalyze_count(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO postgres;

--
-- Name: autovacuum_log(text, text, text, text, text, bigint); Type: FUNCTION; Schema: reports; Owner: postgres
--

CREATE FUNCTION reports.autovacuum_log(grafana_time_filter text, cluster_name_in text DEFAULT NULL::text, database_name_in text DEFAULT NULL::text, schema_name_in text DEFAULT NULL::text, table_name_in text DEFAULT NULL::text, query_limit bigint DEFAULT 100000) RETURNS TABLE("time" timestamp with time zone, cluster_name text, database_name text, schema_name text, table_name text, index_scans bigint, pages_removed bigint, removed_size bigint, pages_remain bigint, pages_remain_size bigint, skipped_due_to_pins bigint, skipped_frozen bigint, tuples_removed bigint, tuples_remain bigint, tuples_dead bigint, oldest_xmin bigint, buffer_hits bigint, buffer_misses bigint, buffer_dirtied bigint, buffer_dirtied_size bigint, avg_read_rate numeric, avg_write_rate numeric, cpu_system numeric, cpu_user numeric, elasped_seconds numeric)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM reports.autovacuum_log($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.autovacuum_log($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$, 100000);

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
  sql := E'SELECT * FROM reports.autovacuum_logs a
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


ALTER FUNCTION reports.autovacuum_log(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text, query_limit bigint) OWNER TO postgres;

--
-- Name: autovacuum_log_count(text, text, timestamp with time zone, timestamp with time zone, text, text, text, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.autovacuum_log_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, count bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM reports.autovacuum_log_count('$__interval', $$$__timeFilter(time)$$, $__timeFrom(), $__timeTo(), $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

SET application_name = 'Grafana';
SELECT time, cluster_name || ' - vacuum', count FROM reports.autovacuum_log_count('$GraphInterval', $$$__timeFilter(time)$$, $__timeFrom(), $__timeTo(), $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.autovacuum_log_count('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

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
  reports.autovacuum_logs
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


ALTER FUNCTION reports.autovacuum_log_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autovacuum_log_count_chart(text, text, text, text, text); Type: FUNCTION; Schema: reports; Owner: postgres
--

CREATE FUNCTION reports.autovacuum_log_count_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, table_name text, count bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM reports.autovacuum_log_count_chart($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.autovacuum_log_count_chart($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

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
  reports.autovacuum_logs
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


ALTER FUNCTION reports.autovacuum_log_count_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO postgres;

--
-- Name: autovacuum_log_removed_size(text, text, text, text, text, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.autovacuum_log_removed_size(grafana_interval text, grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, removed_size bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM reports.autovacuum_log_removed_size('$__interval', $$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.autovacuum_log_removed_size('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

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
  reports.autovacuum_logs
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


ALTER FUNCTION reports.autovacuum_log_removed_size(grafana_interval text, grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autovacuum_log_removed_space_chart(text, text, text, text, text); Type: FUNCTION; Schema: reports; Owner: postgres
--

CREATE FUNCTION reports.autovacuum_log_removed_space_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, table_name text, removed_size bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM reports.autovacuum_log_removed_space_chart($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.autovacuum_log_removed_space_chart($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

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
  reports.autovacuum_logs
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


ALTER FUNCTION reports.autovacuum_log_removed_space_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO postgres;

--
-- Name: autovacuum_log_tuples_removed(text, text, text, text, text, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.autovacuum_log_tuples_removed(grafana_interval text, grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, tuples_removed bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM reports.autovacuum_log_tuples_removed('$__interval', $$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.autovacuum_log_tuples_removed('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

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
  reports.autovacuum_logs
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


ALTER FUNCTION reports.autovacuum_log_tuples_removed(grafana_interval text, grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO grafana;

--
-- Name: autovacuum_log_tuples_removed_chart(text, text, text, text, text); Type: FUNCTION; Schema: reports; Owner: postgres
--

CREATE FUNCTION reports.autovacuum_log_tuples_removed_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) RETURNS TABLE("time" timestamp with time zone, table_name text, tuples_removed bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM reports.autovacuum_log_tuples_removed_chart($$$__timeFilter(time)$$, $$$ServerName$$, $$$DatabaseName$$, $$$SchemaName$$, $$$TableName$$);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.autovacuum_log_tuples_removed_chart($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-a'$$, $$'delphi_importer_venice_odm_dcostanz_1'$$, $$'continuous_integrator_ready_area'$$, $$'dataset'$$);

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
  reports.autovacuum_logs
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


ALTER FUNCTION reports.autovacuum_log_tuples_removed_chart(grafana_time_filter text, cluster_name_in text, database_name_in text, schema_name_in text, table_name_in text) OWNER TO postgres;

--
-- Name: autovacuum_thresholds(text, text, text, timestamp with time zone, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.autovacuum_thresholds(server_name text, database_name text, all_vacuums text, grafana_timeto timestamp with time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, name text, n_tup_ins bigint, n_tup_upd bigint, n_tup_del bigint, n_live_tup bigint, n_dead_tup bigint, reltuples real, av_threshold double precision, last_vacuum timestamp with time zone, last_analyze timestamp with time zone, av_neaded boolean, pct_dead numeric)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT reports.autovacuum_thresholds('$ServerName', '$DatabaseName', '$ShowAllVacuums', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT reports.autovacuum_thresholds('sqltest', 'delphi_continuous_integrator_testing', 'All', '2019-05-08T22:36:44.901Z', '1m');
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
	FROM reports.autovacuum_thresholds
    WHERE 
        (cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
        AND (database_name = ''' || database_name || ''' OR ''--All--'' = ''' || database_name || ''' OR ''' || all_vacuums || ''' = ''All'')
	GROUP BY cluster_name, database_name
) a
LEFT JOIN reports.autovacuum_thresholds b USING (log_time, cluster_name, database_name)
WHERE (b.cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
  AND (b.database_name = ''' || database_name || ''' OR ''--All--'' = ''' || database_name || ''' OR ''' || all_vacuums || ''' = ''All'')
  AND b.log_time >= ''' || grafana_timeto || '''::TIMESTAMPTZ - INTERVAL ''' || grafana_refresh || '''
  ORDER BY 1 DESC, 2';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;  
END;
$_X$;


ALTER FUNCTION reports.autovacuum_thresholds(server_name text, database_name text, all_vacuums text, grafana_timeto timestamp with time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: checkpoint_buffers(text, text, timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.checkpoint_buffers(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, wbuffer bigint, write numeric, sync numeric, total numeric)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_buffers('$GraphInterval', $$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_buffers('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

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
FROM reports.checkpoint_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
GROUP BY time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || '''), cluster_name
ORDER BY time, cluster_name;';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION reports.checkpoint_buffers(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text) OWNER TO grafana;

--
-- Name: checkpoint_files(text, text, timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.checkpoint_files(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, files_added bigint, files_removed bigint, files_recycled bigint, sync_files bigint, sync_longest numeric, sync_avg numeric)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_files('$GraphInterval', $$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_files('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

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
FROM reports.checkpoint_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
GROUP BY time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || '''), cluster_name
ORDER BY time, cluster_name;';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION reports.checkpoint_files(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text) OWNER TO grafana;

--
-- Name: checkpoint_logs(text, text, bigint); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.checkpoint_logs(grafana_time_filter text, cluster_name_in text DEFAULT NULL::text, query_limit bigint DEFAULT 100000) RETURNS TABLE("time" timestamp with time zone, cluster_name text, wbuffer integer, files_added integer, files_removed integer, files_recycled integer, write numeric, sync numeric, total numeric, sync_files integer, sync_longest numeric, sync_avg numeric, distance integer, estimate integer)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_logs($$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_logs($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT * FROM reports.checkpoint_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
ORDER BY 1  DESC    
LIMIT ' || query_limit || ';';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION reports.checkpoint_logs(grafana_time_filter text, cluster_name_in text, query_limit bigint) OWNER TO grafana;

--
-- Name: checkpoint_wal_file_usage(text, text, timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.checkpoint_wal_file_usage(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, files bigint)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_wal_file_usage('$GraphInterval', $$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_wal_file_usage('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

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
FROM reports.checkpoint_logs a
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


ALTER FUNCTION reports.checkpoint_wal_file_usage(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text) OWNER TO grafana;

--
-- Name: checkpoint_warning_logs(text, text, bigint); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.checkpoint_warning_logs(grafana_time_filter text, cluster_name_in text DEFAULT NULL::text, query_limit bigint DEFAULT 100000) RETURNS TABLE("time" timestamp with time zone, cluster_name text, seconds integer, hint text)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_warning_logs($$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_warning_logs($$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

$__timeFilter(log_time) is the time period you have specified at the top of the page
$ServerName is the name of the server you have specified at the top of the page or 'All' for all servers
*/

DECLARE
--  variable_name datatype;
	sql TEXT;
BEGIN
  sql := E'SELECT * FROM reports.checkpoint_warning_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
ORDER BY 1  DESC    
LIMIT ' || query_limit || ';';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION reports.checkpoint_warning_logs(grafana_time_filter text, cluster_name_in text, query_limit bigint) OWNER TO grafana;

--
-- Name: checkpoint_warning_logs_count(text, text, timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.checkpoint_warning_logs_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, count bigint)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_warning_logs_count('$GraphInterval', $$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_warning_logs_count('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

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
FROM reports.checkpoint_warning_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
GROUP BY time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || '''), cluster_name
ORDER BY time, cluster_name;';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION reports.checkpoint_warning_logs_count(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text) OWNER TO grafana;

--
-- Name: checkpoint_write_buffers(text, text, timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.checkpoint_write_buffers(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text DEFAULT NULL::text) RETURNS TABLE("time" timestamp with time zone, cluster_name text, wbuffer bigint)
    LANGUAGE plpgsql
    AS $_X$
/*
SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_write_buffers('$GraphInterval', $$$__timeFilter(time)$$, $$$ServerName$$, $QueryLimit);

aka

SET application_name TO 'Grafana';
SELECT * FROM reports.checkpoint_write_buffers('5m', $$time BETWEEN '2019-04-25T23:05:42.82Z' AND '2019-05-02T23:05:42.82Z'$$, $$'sqltest-b'$$, 100000);

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
FROM reports.checkpoint_logs a
WHERE 
    ' || grafana_time_filter || '
    AND tools.field_list_check(cluster_name, $$' || cluster_name_in::text || E'$$) 
GROUP BY time_bucket_gapfill(''' || grafana_interval || ''',time, ''' || grafana_from_time || ''', ''' || grafana_to_time || '''), cluster_name
ORDER BY time, cluster_name;';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION reports.checkpoint_write_buffers(grafana_interval text, grafana_time_filter text, grafana_from_time timestamp with time zone, grafana_to_time timestamp with time zone, cluster_name_in text) OWNER TO grafana;

--
-- Name: connection_attempt_history(text, text, text[], text, text, boolean, boolean); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.connection_attempt_history(grafana_interval text, grafana_time_filter text, cluster_name text[] DEFAULT '{''All''::text}'::text[], "interval" text DEFAULT 'second'::text, aggregate text DEFAULT 'avg'::text, display_interval boolean DEFAULT false, display_aggregate boolean DEFAULT false) RETURNS TABLE("time" timestamp with time zone, "Server" text, "Connections" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM reports.connection_attempt_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, 'second', 'avg', False);
SELECT * FROM reports.connection_attempt_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, tools.interval_to_field('$__interval'), 'sum', True);

aka

SELECT * FROM reports.connection_attempt_history('5s', $$log_time BETWEEN '2019-03-11T19:45:08Z' AND '2019-03-11T22:45:08Z'$$, 'sqltest', 'second', 'avg', False);

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
	sql := E'SELECT a.start_time AS "Time", b.cluster_name || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END || CASE WHEN ' || display_aggregate || ' THEN '' - ' || aggregate || E''' ELSE '''' END AS "Server", COALESCE(' || aggregate || '(c.count),0)::BIGINT AS "Connections" ';
    sql = sql || E'FROM tools.generate_timestamps(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || '''), $$' || grafana_time_filter || '$$) a (start_time, end_time) ';
    sql = sql || E'CROSS JOIN (SELECT DISTINCT cluster_name FROM reports.postgres_log WHERE ' || grafana_time_filter || E' AND ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[]) b ';
    sql = sql || 'LEFT JOIN (  SELECT ';
    sql = sql || E'date_trunc(''' || interval || ''', log_time) AS log_time, ';
    sql = sql || 'cluster_name, count(*) FROM reports.postgres_log ';
    sql = sql || E'WHERE ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[] AND message LIKE ''connection received%'' ';
    sql = sql || 'AND ' || grafana_time_filter || ' GROUP BY 1,2) c ';
    sql = sql || 'ON c.log_time BETWEEN a.start_time AND a.end_time AND b.cluster_name = c.cluster_name ';
    sql = sql || 'GROUP BY 1,2 ORDER BY 1,2;';
--    RAISE NOTICE 'SQL: %', sql;
	RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION reports.connection_attempt_history(grafana_interval text, grafana_time_filter text, cluster_name text[], "interval" text, aggregate text, display_interval boolean, display_aggregate boolean) OWNER TO grafana;

--
-- Name: connection_history(text, text, text[], text, text, boolean, boolean); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.connection_history(grafana_interval text, grafana_time_filter text, cluster_name text[] DEFAULT '{''All''::text}'::text[], "interval" text DEFAULT 'second'::text, aggregate text DEFAULT 'avg'::text, display_interval boolean DEFAULT false, display_aggregate boolean DEFAULT false) RETURNS TABLE("time" timestamp with time zone, "Server" text, "Connections" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
SET application_name = 'Grafana';
SELECT * FROM reports.connection_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, 'second', 'avg', False);
SELECT * FROM reports.connection_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, tools.interval_to_field('$__interval'), 'sum', True);

aka

SELECT * FROM reports.connection_history('5s', $$log_time BETWEEN '2019-03-11T19:45:08Z' AND '2019-03-11T22:45:08Z'$$, 'sqltest', 'second', 'avg', False);

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
	sql := E'SELECT a.start_time AS "Time", b.cluster_name || CASE WHEN ' || display_interval || ' THEN '' - ' || grafana_interval || E' Inverval'' ELSE '''' END || CASE WHEN ' || display_aggregate || ' THEN '' - ' || aggregate || E''' ELSE '''' END AS "Server", COALESCE(' || aggregate || '(c.count),0)::BIGINT AS "Connections" ';
    sql = sql || E'FROM tools.generate_timestamps(tools.group_by_interval(''' || grafana_interval || E''', ''' || interval || '''), $$' || grafana_time_filter || '$$) a (start_time, end_time) ';
    sql = sql || E'CROSS JOIN (SELECT DISTINCT cluster_name FROM reports.postgres_log WHERE ' || grafana_time_filter || E' AND ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[]) b ';
    sql = sql || 'LEFT JOIN (  SELECT ';
    sql = sql || E'date_trunc(''' || interval || ''', log_time) AS log_time, ';
    sql = sql || 'cluster_name, count(*) FROM reports.postgres_log ';
    sql = sql || E'WHERE ARRAY[cluster_name] <@ ''' || cluster_name::text || E'''::text[] AND message LIKE ''connection authorized%'' ';
    sql = sql || 'AND ' || grafana_time_filter || ' GROUP BY 1,2) c ';
    sql = sql || 'ON c.log_time BETWEEN a.start_time AND a.end_time AND b.cluster_name = c.cluster_name ';
    sql = sql || 'GROUP BY 1,2 ORDER BY 1,2;';
--    RAISE NOTICE 'SQL: %', sql;
	RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION reports.connection_history(grafana_interval text, grafana_time_filter text, cluster_name text[], "interval" text, aggregate text, display_interval boolean, display_aggregate boolean) OWNER TO grafana;

--
-- Name: current_autovacuum(text, text, text, timestamp without time zone, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.current_autovacuum(server_name text, database_name text, all_vacuums text, grafana_timeto timestamp without time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, name text, vacuum boolean, "analyze" boolean, running_time integer, phase text, heap_blks_total bigint, heap_blks_total_size bigint, heap_blks_scanned bigint, heap_blks_scanned_pct numeric, heap_blks_vacuumed bigint, heap_blks_vacuumed_pct numeric, index_vacuum_count bigint, max_dead_tuples bigint, num_dead_tuples bigint, backend_start timestamp with time zone, wait_event_type text, wait_event text, state text, backend_xmin xid)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT reports.current_autovacuum('$ServerName', '$DatabaseName', '$ShowAllVacuums', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT reports.current_autovacuum('sqltest', 'delphi_continuous_integrator_testing', 'All', '2019-05-08T22:36:44.901Z', '1m');
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
	FROM reports.current_autovacuum
) a
LEFT JOIN reports.current_autovacuum b USING (log_time)
WHERE (b.cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
  AND (b.database_name = ''' || database_name || ''' OR ''--All--'' = ''' || database_name || ''' OR ''' || all_vacuums || ''' = ''All'')
  AND b.log_time >= ''' || grafana_timeto || '''::timestamp - INTERVAL ''' || grafana_refresh || '''
  ORDER BY b.cluster_name, b.database_name, b.schema_name, b.table_name, b.log_time DESC';
--    RAISE NOTICE 'SQL: %', sql;
	RETURN QUERY EXECUTE sql;  
END;
$_X$;


ALTER FUNCTION reports.current_autovacuum(server_name text, database_name text, all_vacuums text, grafana_timeto timestamp without time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: current_pg_stat_activity_active(text, text, timestamp with time zone, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.current_pg_stat_activity_active(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, database_name text, pid integer, state text, application_name text, backend_type text, wait_event_type text, wait_event text, backend_start timestamp with time zone, xact_start timestamp with time zone, query_start timestamp with time zone, state_change timestamp with time zone, backend_xmin xid)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT reports.current_pg_stat_activity_active('$ServerName', '$DatabaseName', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT reports.current_pg_stat_activity_active('sqltest', 'delphi_continuous_integrator_testing', '2019-05-08T22:36:44.901Z', '1m');
*/

DECLARE
  sql TEXT;
BEGIN
	sql := E'SELECT b.log_time, 
	CASE WHEN ''' || server_name || ''' = ''--All--'' THEN b.cluster_name || ''.'' ELSE '''' END || b.database_name AS database_name, 
	b.pid, b.state, b.application_name, b.backend_type, b.wait_event_type, b.wait_event, b.backend_start, b.xact_start, b.query_start, b.state_change, b.backend_xmin 
FROM (
	SELECT max(log_time) AS log_time
	FROM reports.current_pg_stat_activity
) a  
LEFT JOIN reports.current_pg_stat_activity b USING (log_time)
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


ALTER FUNCTION reports.current_pg_stat_activity_active(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: current_vacuum_settings(text, text, timestamp with time zone, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.current_vacuum_settings(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, cluster_name text, name text, setting text, unit text, category text, short_desc text, extra_desc text, context text, vartype text, source text, min_val text, max_val text, enumvals text[], boot_val text, reset_val text, sourcefile text, sourceline integer, pending_restart boolean)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT * FROM reports.granted_locks('$ServerName', '$DatabaseName', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT * FROM reports.granted_locks('sqltest', 'delphi_continuous_integrator_testing', '2019-05-08T22:36:44.901Z', '1m');
*/

DECLARE
  sql TEXT;
BEGIN
	sql := E'SELECT b.*
FROM (
	SELECT max(log_time) AS log_time, cluster_name
	FROM reports.current_pg_settings
        WHERE (cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
	    AND log_time >= ''' || grafana_timeto || '''::TIMESTAMPTZ - INTERVAL ''' || grafana_refresh || ''' 
	GROUP BY cluster_name
) a  
LEFT JOIN reports.current_pg_settings b USING (log_time, cluster_name)
WHERE b.category ilike ''%Vacuum%''
ORDER BY b.cluster_name, b.name';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;  
END;
$_X$;


ALTER FUNCTION reports.current_vacuum_settings(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: custom_table_settings(text, text, timestamp with time zone, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.custom_table_settings(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, cluster_name text, database_name name, table_name text, table_setting text)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT * FROM reports.custom_table_settings('$ServerName', '$DatabaseName', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT * FROM reports.custom_table_settings('sqltest', 'delphi_continuous_integrator_testing', '2019-05-08T22:36:44.901Z', '1m');
*/

DECLARE
  sql TEXT;
BEGIN
	sql := E'SELECT b.log_time, b.cluster_name, b.database_name, b."Table Name", b."Table Setting"
FROM (
	SELECT max(log_time) AS log_time, cluster_name, database_name
	FROM reports.custom_table_settings
        WHERE database_name IS NOT NULL
        AND  (cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
  	AND (database_name = ''' || db_name || ''' OR ''--All--'' = ''' || db_name || ''')
    AND log_time >= ''' || grafana_timeto || '''::TIMESTAMPTZ - INTERVAL ''' || grafana_refresh || ''' 
	GROUP BY cluster_name, database_name
) a  
LEFT JOIN reports.custom_table_settings b USING (log_time, cluster_name, database_name)
ORDER BY b.cluster_name, b.database_name, b."Table Name"';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;  
END;
$_X$;


ALTER FUNCTION reports.custom_table_settings(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: error_history(text, text, text[], text, text, boolean); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.error_history(grafana_interval text, grafana_time_filter text, cluster_name text[] DEFAULT '{''All''::text}'::text[], "interval" text DEFAULT 'second'::text, aggregate text DEFAULT 'avg'::text, display_interval boolean DEFAULT false) RETURNS TABLE("time" timestamp with time zone, "LDAP Errors" text, "Errors" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
-- THIS FUNCTION HAS NOT BEEN FINISHED WRITTEN
/*
SET application_name = 'Grafana';
SELECT * FROM reports.error_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, 'minute', 'sum', False);
SELECT * FROM reports.error_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, tools.interval_to_field('$__interval'), 'sum', True);

aka

SELECT * FROM reports.error_history('5s', $$log_time BETWEEN '2019-03-11T19:45:08Z' AND '2019-03-11T22:45:08Z'$$, 'sqltest', 'second', 'avg', False);

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
    sql = sql || 'FROM reports.postgres_log ';
    sql = sql || E'WHERE (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN ''All'' = ''' || cluster_name || E''' THEN cluster_name || '' - '' ELSE '''' END || trim(split_part(message, '':'', 2)) AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM reports.postgres_log ';
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
    sql = sql || 'FROM reports.postgres_log ';
    sql = sql || E'WHERE error_severity = ''ERROR'' AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN array_length(''' || cluster_name::text || E'''::text[], 1) > 1 THEN cluster_name || '' - '' ELSE '''' END || message AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM reports.postgres_log ';
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
		FROM reports.postgres_log 
		WHERE message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
		GROUP BY 1
     ) b
) c LEFT JOIN (
		SELECT  
			date_trunc(tools.interval_to_field('$__interval'), log_time) AS time, 
			CASE WHEN 'All' = $ServerName THEN cluster_name || ' - ' ELSE '' END || trim(split_part(message, ':', 2)) AS ldap_error, 
			count(*) AS value
		FROM reports.postgres_log 
  		WHERE (cluster_name = $ServerName OR 'All' = $ServerName) AND message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
  		GROUP BY 1,2
) e ON c.start_time = e.time AND c.ldap_error = e.ldap_error;    
*/    
    
	RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION reports.error_history(grafana_interval text, grafana_time_filter text, cluster_name text[], "interval" text, aggregate text, display_interval boolean) OWNER TO grafana;

--
-- Name: fatal_history(text, text, text[], text, text, boolean); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.fatal_history(grafana_interval text, grafana_time_filter text, cluster_name text[] DEFAULT '{''All''::text}'::text[], "interval" text DEFAULT 'second'::text, aggregate text DEFAULT 'avg'::text, display_interval boolean DEFAULT false) RETURNS TABLE("time" timestamp with time zone, "LDAP Errors" text, "Errors" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
-- THIS FUNCTION HAS NOT BEEN FINISHED WRITTEN
/*
SET application_name = 'Grafana';
SELECT * FROM reports.fatal_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, 'minute', 'sum', False);
SELECT * FROM reports.fatal_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, tools.interval_to_field('$__interval'), 'sum', True);

aka

SELECT * FROM reports.fatal_history('5s', $$log_time BETWEEN '2019-03-11T19:45:08Z' AND '2019-03-11T22:45:08Z'$$, 'sqltest', 'second', 'avg', False);

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
    sql = sql || 'FROM reports.postgres_log ';
    sql = sql || E'WHERE (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN ''All'' = ''' || cluster_name || E''' THEN cluster_name || '' - '' ELSE '''' END || trim(split_part(message, '':'', 2)) AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM reports.postgres_log ';
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
    sql = sql || 'FROM reports.postgres_log ';
    sql = sql || E'WHERE error_severity = ''FATAL'' AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN array_length(''' || cluster_name::text || E'''::text[], 1) > 1 THEN cluster_name || '' - '' ELSE '''' END || message AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM reports.postgres_log ';
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
		FROM reports.postgres_log 
		WHERE message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
		GROUP BY 1
     ) b
) c LEFT JOIN (
		SELECT  
			date_trunc(tools.interval_to_field('$__interval'), log_time) AS time, 
			CASE WHEN 'All' = $ServerName THEN cluster_name || ' - ' ELSE '' END || trim(split_part(message, ':', 2)) AS ldap_error, 
			count(*) AS value
		FROM reports.postgres_log 
  		WHERE (cluster_name = $ServerName OR 'All' = $ServerName) AND message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
  		GROUP BY 1,2
) e ON c.start_time = e.time AND c.ldap_error = e.ldap_error;    
*/    
    
	RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION reports.fatal_history(grafana_interval text, grafana_time_filter text, cluster_name text[], "interval" text, aggregate text, display_interval boolean) OWNER TO grafana;

--
-- Name: granted_locks(text, text, timestamp with time zone, text); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.granted_locks(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) RETURNS TABLE(log_time timestamp with time zone, "Server Nname" text, "Database Name" name, "Time" double precision, "PG Process ID" integer, "Application Name" text, "Transaction Start" timestamp with time zone, "Locks" text, "AutoVacuum" text)
    LANGUAGE plpgsql STRICT
    AS $_X$
/*
Usage:
SET application_name = 'Grafana';
SELECT * FROM reports.granted_locks('$ServerName', '$DatabaseName', $__timeTo(), '$__interval');

Example:
SET application_name = 'Grafana';
SELECT * FROM reports.granted_locks('sqltest', 'delphi_continuous_integrator_testing', '2019-05-08T22:36:44.901Z', '1m');
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
	FROM reports.granted_locks
        WHERE database_name IS NOT NULL
        AND  (cluster_name IN (''' || server_name || ''', ''' || server_name || '-a'', ''' || server_name || '-b'') OR ''--All--'' = ''' || server_name || ''')
  	AND (database_name = ''' || db_name || ''' OR ''--All--'' = ''' || db_name || ''')
	GROUP BY cluster_name, database_name
) a  
LEFT JOIN reports.granted_locks b USING (log_time, cluster_name, database_name)
WHERE a.log_time >= ''' || grafana_timeto || '''::TIMESTAMPTZ - INTERVAL ''' || grafana_refresh || ''' 
ORDER BY b.cluster_name, b.database_name, b."PG Process ID"';
--  RAISE NOTICE 'SQL: %', sql;
  RETURN QUERY EXECUTE sql;  
END;
$_X$;


ALTER FUNCTION reports.granted_locks(server_name text, db_name text, grafana_timeto timestamp with time zone, grafana_refresh text) OWNER TO grafana;

--
-- Name: ldap_error_history(text, text, text[], text, text, boolean); Type: FUNCTION; Schema: reports; Owner: grafana
--

CREATE FUNCTION reports.ldap_error_history(grafana_interval text, grafana_time_filter text, cluster_name text[] DEFAULT '{''All''::text}'::text[], "interval" text DEFAULT 'second'::text, aggregate text DEFAULT 'avg'::text, display_interval boolean DEFAULT false) RETURNS TABLE("time" timestamp with time zone, "LDAP Errors" text, "Errors" bigint)
    LANGUAGE plpgsql STRICT
    AS $_X$
-- THIS FUNCTION HAS NOT BEEN FINISHED WRITTEN
/*
SET application_name = 'Grafana';
SELECT * FROM reports.ldap_error_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, 'minute', 'sum', False);
SELECT * FROM reports.ldap_error_history('$__interval', $$$__timeFilter(log_time)$$, $ServerName, tools.interval_to_field('$__interval'), 'sum', True);

aka

SELECT * FROM reports.ldap_error_history('5s', $$log_time BETWEEN '2019-03-11T19:45:08Z' AND '2019-03-11T22:45:08Z'$$, 'sqltest', 'second', 'avg', False);

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
    sql = sql || 'FROM reports.postgres_log ';
    sql = sql || E'WHERE (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN ''All'' = ''' || cluster_name || E''' THEN cluster_name || '' - '' ELSE '''' END || trim(split_part(message, '':'', 2)) AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM reports.postgres_log ';
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
    sql = sql || 'FROM reports.postgres_log ';
    sql = sql || E'WHERE (message LIKE ''LDAP login failed for user%'' OR message LIKE E''%Can''''t contact LDAP server'') AND ' || grafana_time_filter || ' ';
    sql = sql || 'GROUP BY 1 ';
    sql = sql || ') b ';
    sql = sql || ') c LEFT JOIN ( ';
    sql = sql || 'SELECT ';
    sql = sql || E'date_trunc(''' || interval || E''', log_time) AS time, ';
    sql = sql || E'CASE WHEN array_length(''' || cluster_name::text || E'''::text[], 1) > 1 THEN cluster_name || '' - '' ELSE '''' END || CASE WHEN message LIKE E''%Can''''t contact LDAP server'' THEN trim(split_part(message, ''"'', 1)) ELSE trim(split_part(message, '':'', 2)) END AS ldap_error, ';
    sql = sql || 'count(*) AS value ';
    sql = sql || 'FROM reports.postgres_log ';
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
		FROM reports.postgres_log 
		WHERE message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
		GROUP BY 1
     ) b
) c LEFT JOIN (
		SELECT  
			date_trunc(tools.interval_to_field('$__interval'), log_time) AS time, 
			CASE WHEN 'All' = $ServerName THEN cluster_name || ' - ' ELSE '' END || trim(split_part(message, ':', 2)) AS ldap_error, 
			count(*) AS value
		FROM reports.postgres_log 
  		WHERE (cluster_name = $ServerName OR 'All' = $ServerName) AND message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
  		GROUP BY 1,2
) e ON c.start_time = e.time AND c.ldap_error = e.ldap_error;    
*/    
    
	RETURN QUERY EXECUTE sql;
END;
$_X$;


ALTER FUNCTION reports.ldap_error_history(grafana_interval text, grafana_time_filter text, cluster_name text[], "interval" text, aggregate text, display_interval boolean) OWNER TO grafana;

--
-- Name: update_pg_log_databases(); Type: FUNCTION; Schema: reports; Owner: postgres
--

CREATE FUNCTION reports.update_pg_log_databases() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
--  variable_name datatype;
BEGIN
	INSERT INTO reports.postgres_log_databases 
	(SELECT DISTINCT cluster_name, database_name, min(log_time) AS start_date, max(log_time) AS end_date  
	FROM new_table
	WHERE database_name IS NOT NULL
	GROUP BY cluster_name, database_name)
	ON CONFLICT (cluster_name, database_name) DO UPDATE SET end_date = EXCLUDED.end_date;
END;
$$;


ALTER FUNCTION reports.update_pg_log_databases() OWNER TO postgres;

--
-- Name: create_reports(); Type: FUNCTION; Schema: tools; Owner: grafana
--

CREATE FUNCTION tools.create_reports() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  queries RECORD;
  sql TEXT;
BEGIN
  CREATE SCHEMA IF NOT EXISTS reports;
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


ALTER FUNCTION tools.create_reports() OWNER TO grafana;

--
-- Name: create_server_database_inherits(text, text); Type: FUNCTION; Schema: tools; Owner: grafana
--

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
WHERE table_schema = 'reports' AND t.table_type = 'BASE TABLE' AND query.maintenance_db_only IS NOT NULL LOOP
    sql := 'CREATE TABLE IF NOT EXISTS ' || quote_ident($1 || '-' || $2) || '.' || quote_ident(tables.table_name) ||
    E' ( CHECK ((cluster_name = ''' || $1 || E''' OR cluster_name = ''' || $1 || E'-a'' OR cluster_name = ''' || $1 || E'-b'') ' || 
    E' AND database_name = ''' || $2 || E''') ' ||
    ') INHERITS (' || quote_ident($1) || '.' || quote_ident(tables.table_name) || ');';
    EXECUTE sql;
  END LOOP;
END;
$_$;


ALTER FUNCTION tools.create_server_database_inherits("server_name" text, database_name text) OWNER TO grafana;

--
-- Name: create_server_inherits(text); Type: FUNCTION; Schema: tools; Owner: grafana
--

CREATE FUNCTION tools.create_server_inherits("server_name" text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
  tables RECORD;
  sql TEXT;
BEGIN
  sql := 'CREATE SCHEMA IF NOT EXISTS ' || quote_ident($1) || ';';
  EXECUTE sql;

  FOR tables IN SELECT * FROM information_schema.tables WHERE table_schema = 'reports' AND table_type = 'BASE TABLE' LOOP
    sql := 'CREATE TABLE IF NOT EXISTS ' || quote_ident($1) || '.' || quote_ident(tables.table_name) ||
    E' ( CHECK (cluster_name = ''' || $1 || E''' OR cluster_name = ''' || $1 || E'-a'' OR cluster_name = ''' || $1 || E'-b'') ' ||
    ') INHERITS (' || quote_ident(tables.table_schema) || '.' || quote_ident(tables.table_name) || ');';
    EXECUTE sql;
  END LOOP;
END;
$_$;


ALTER FUNCTION tools.create_server_inherits("server_name" text) OWNER TO grafana;

--
-- Name: delete_reports(); Type: FUNCTION; Schema: tools; Owner: grafana
--

CREATE FUNCTION tools.delete_reports() RETURNS void
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
    WHERE table_schema NOT IN ('tools', 'public', 'reports', 'pg_catalog', 'information_schema') 
    AND table_schema NOT LIKE 'pg_temp%' 
    AND table_schema NOT LIKE 'pg_toast%' 
    LOOP
      sql := 'DROP SCHEMA ' || quote_ident(tables.table_schema) || ' CASCADE;';
      RAISE NOTICE '%', sql;
      EXECUTE sql;
  END LOOP;

  -- RECREATE MASTER TABLES
  PERFORM tools.create_reports();

END;
$$;


ALTER FUNCTION tools.delete_reports() OWNER TO grafana;

--
-- Name: field_list_check(text, text); Type: FUNCTION; Schema: tools; Owner: postgres
--

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


ALTER FUNCTION tools.field_list_check(field_in text, list_in text) OWNER TO postgres;

--
-- Name: FUNCTION field_list_check(field_in text, list_in text); Type: COMMENT; Schema: tools; Owner: postgres
--

COMMENT ON FUNCTION tools.field_list_check(field_in text, list_in text) IS 'This function is used when wanting to filter by Grafana Variables.';


--
-- Name: generate_timestamps(text, text); Type: FUNCTION; Schema: tools; Owner: postgres
--

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
		FROM reports.postgres_log 
		WHERE message LIKE 'LDAP login failed for user%' AND $__timeFilter(log_time)
		GROUP BY 1
     ) b
) c LEFT JOIN (
	SELECT * FROM (
		SELECT  
			date_trunc('minute', log_time) AS time, 
			trim(split_part(message, ':', 2)) AS ldap_error, 
			count(*) AS value1
		FROM reports.postgres_log 
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


ALTER FUNCTION tools.generate_timestamps("interval" text, "between" text) OWNER TO postgres;

--
-- Name: group_by_interval(text, text); Type: FUNCTION; Schema: tools; Owner: postgres
--

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


ALTER FUNCTION tools.group_by_interval(grafana_interval text, "interval" text) OWNER TO postgres;

--
-- Name: interval_to_field(text); Type: FUNCTION; Schema: tools; Owner: postgres
--

CREATE FUNCTION tools.interval_to_field(grafana_interval text) RETURNS text
    LANGUAGE sql STRICT
    AS $_$
SELECT substring($1 FROM '[a-zA-Z]+');
$_$;


ALTER FUNCTION tools.interval_to_field(grafana_interval text) OWNER TO postgres;

--
-- Name: parse_csv(text, boolean); Type: FUNCTION; Schema: tools; Owner: grafana
--

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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: current_pg_settings; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.current_pg_settings (
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


ALTER TABLE reports.current_pg_settings OWNER TO grafana;

--
-- Name: current_pg_stat_activity; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.current_pg_stat_activity (
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


ALTER TABLE reports.current_pg_stat_activity OWNER TO grafana;

--
-- Name: current_auto_vacuum_count; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.current_auto_vacuum_count (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name,
    count bigint
);


ALTER TABLE reports.current_auto_vacuum_count OWNER TO grafana;

--
-- Name: current_replication_status; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.current_replication_status (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    status text
);


ALTER TABLE reports.current_replication_status OWNER TO grafana;

--
-- Name: current_autovacuum; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.current_autovacuum (
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


ALTER TABLE reports.current_autovacuum OWNER TO grafana;

--
-- Name: current_pg_database; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.current_pg_database (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name
);


ALTER TABLE reports.current_pg_database OWNER TO grafana;

--
-- Name: granted_locks; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.granted_locks (
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


ALTER TABLE reports.granted_locks OWNER TO grafana;

--
-- Name: current_table_stats; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.current_table_stats (
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


ALTER TABLE reports.current_table_stats OWNER TO grafana;

--
-- Name: custom_table_settings; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.custom_table_settings (
    log_time timestamp with time zone NOT NULL,
    cluster_name text,
    database_name name,
    schema_name name,
    table_name name,
    "Table Name" text,
    "Table Setting" text
);


ALTER TABLE reports.custom_table_settings OWNER TO grafana;

--
-- Name: autovacuum_thresholds; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.autovacuum_thresholds (
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


ALTER TABLE reports.autovacuum_thresholds OWNER TO grafana;

--
-- Name: autoanalyze_logs; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.autoanalyze_logs (
    "time" timestamp with time zone NOT NULL,
    cluster_name text,
    database_name text,
    schema_name text,
    table_name text,
    cpu_system numeric,
    cpu_user numeric,
    elasped_seconds numeric
);


ALTER TABLE reports.autoanalyze_logs OWNER TO grafana;

--
-- Name: autovacuum_logs; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.autovacuum_logs (
    "time" timestamp(3) with time zone NOT NULL,
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


ALTER TABLE reports.autovacuum_logs OWNER TO grafana;

--
-- Name: lock_logs; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.lock_logs (
    lock_type text,
    object_type text,
    relation_id text,
    transaction_id2 xid,
    class_id oid,
    relation_tuple tid,
    database_id oid,
    wait_time numeric,
    cluster_name text,
    "time" timestamp(3) with time zone NOT NULL,
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


ALTER TABLE reports.lock_logs OWNER TO grafana;

--
-- Name: checkpoint_warning_logs; Type: TABLE; Schema: reports; Owner: postgres
--

CREATE TABLE reports.checkpoint_warning_logs (
    "time" timestamp with time zone NOT NULL,
    cluster_name text,
    seconds integer,
    hint text
);


ALTER TABLE reports.checkpoint_warning_logs OWNER TO postgres;

--
-- Name: checkpoint_logs; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.checkpoint_logs (
    "time" timestamp with time zone NOT NULL,
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


ALTER TABLE reports.checkpoint_logs OWNER TO grafana;

--
-- Name: postgres_log; Type: TABLE; Schema: reports; Owner: grafana
--

CREATE TABLE reports.postgres_log (
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


ALTER TABLE reports.postgres_log OWNER TO grafana;

--
-- Name: archive_failure_log; Type: TABLE; Schema: reports; Owner: postgres
--

CREATE TABLE reports.archive_failure_log (
    cluster_name text NOT NULL,
    log_time timestamp with time zone NOT NULL,
    process_id integer,
    message text,
    detail text
);


ALTER TABLE reports.archive_failure_log OWNER TO postgres;

--
-- Name: tables; Type: TABLE; Schema: public; Owner: grafana
--

CREATE TABLE public.tables (
    table_catalog information_schema.sql_identifier,
    table_schema information_schema.sql_identifier,
    table_name information_schema.sql_identifier,
    table_type information_schema.character_data,
    self_referencing_column_name information_schema.sql_identifier,
    reference_generation information_schema.character_data,
    user_defined_type_catalog information_schema.sql_identifier,
    user_defined_type_schema information_schema.sql_identifier,
    user_defined_type_name information_schema.sql_identifier,
    is_insertable_into information_schema.yes_or_no,
    is_typed information_schema.yes_or_no,
    commit_action information_schema.character_data
);


ALTER TABLE public.tables OWNER TO grafana;

--
-- Name: testing_lloyd; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.testing_lloyd (
    "time" timestamp(3) with time zone,
    cluster_name text,
    one text[],
    two text[],
    three text[],
    four text[],
    message text
);


ALTER TABLE public.testing_lloyd OWNER TO postgres;

--
-- Name: autovacuum_length; Type: VIEW; Schema: reports; Owner: grafana
--

CREATE VIEW reports.autovacuum_length AS
 SELECT b.cluster_name,
    b.database_name,
    COALESCE(max(b.running_time)) AS running_time
   FROM (( SELECT max(current_autovacuum.log_time) AS log_time
           FROM reports.current_autovacuum) a
     LEFT JOIN reports.current_autovacuum b USING (log_time))
  GROUP BY b.cluster_name, b.database_name;


ALTER TABLE reports.autovacuum_length OWNER TO grafana;

--
-- Name: servers; Type: TABLE; Schema: tools; Owner: grafana
--

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

--
-- Name: databases; Type: VIEW; Schema: reports; Owner: grafana
--

CREATE VIEW reports.databases AS
 SELECT DISTINCT cpd.cluster_name,
    cpd.database_name
   FROM (tools.servers s
     LEFT JOIN reports.current_pg_database cpd ON ((s.server_name = cpd.cluster_name)))
  WHERE (((s.read_all_databases IS TRUE) OR ((s.maintenance_database = cpd.database_name) AND (s.read_all_databases IS FALSE))) AND (cpd.database_name <> ALL (ARRAY['template0'::name, 'template1'::name, 'rdsadmin'::name])))
  ORDER BY cpd.cluster_name, cpd.database_name;


ALTER TABLE reports.databases OWNER TO grafana;

--
-- Name: hypertable; Type: VIEW; Schema: reports; Owner: postgres
--

CREATE VIEW reports.hypertable AS
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


ALTER TABLE reports.hypertable OWNER TO postgres;

--
-- Name: last_log_entries; Type: VIEW; Schema: reports; Owner: grafana
--

CREATE VIEW reports.last_log_entries AS
 SELECT postgres_log.cluster_name,
    min(postgres_log.log_time) AS first_log_time,
    max(postgres_log.log_time) AS last_log_time
   FROM reports.postgres_log
  GROUP BY postgres_log.cluster_name;


ALTER TABLE reports.last_log_entries OWNER TO grafana;

--
-- Name: lock_message_types; Type: TABLE; Schema: reports; Owner: postgres
--

CREATE TABLE reports.lock_message_types (
    message text
);


ALTER TABLE reports.lock_message_types OWNER TO postgres;

--
-- Name: postgres_log_databases; Type: TABLE; Schema: reports; Owner: pg_monitor
--

CREATE TABLE reports.postgres_log_databases (
    cluster_name text NOT NULL,
    database_name text NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone
);


ALTER TABLE reports.postgres_log_databases OWNER TO pg_monitor;

--
-- Name: postgres_log_databases_temp; Type: TABLE; Schema: reports; Owner: postgres
--

CREATE TABLE reports.postgres_log_databases_temp (
    cluster_name text,
    database_name text,
    min timestamp with time zone,
    max timestamp with time zone
);


ALTER TABLE reports.postgres_log_databases_temp OWNER TO postgres;

--
-- Name: build_items; Type: TABLE; Schema: tools; Owner: grafana
--

CREATE TABLE tools.build_items (
    item_schema name NOT NULL,
    item_name name NOT NULL,
    item_sql text,
    build_order numeric,
    disabled boolean DEFAULT false
);


ALTER TABLE tools.build_items OWNER TO grafana;

--
-- Name: current_table_size; Type: VIEW; Schema: tools; Owner: postgres
--

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

--
-- Name: pg_major_version; Type: VIEW; Schema: tools; Owner: grafana
--

CREATE VIEW tools.pg_major_version AS
 SELECT ((((current_setting('server_version_num'::text))::integer / 10000))::numeric + (((((current_setting('server_version_num'::text))::integer / 100) - (((current_setting('server_version_num'::text))::integer / 10000) * 100)))::numeric / (10)::numeric)) AS major_version;


ALTER TABLE tools.pg_major_version OWNER TO grafana;

--
-- Name: queries_disabled; Type: TABLE; Schema: tools; Owner: postgres
--

CREATE TABLE tools.queries_disabled (
    server_name text NOT NULL,
    database_name text NOT NULL,
    port integer DEFAULT 5432 NOT NULL,
    query_name text
);


ALTER TABLE tools.queries_disabled OWNER TO postgres;

--
-- Name: query; Type: TABLE; Schema: tools; Owner: grafana
--

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

--
-- Name: COLUMN query.query_name; Type: COMMENT; Schema: tools; Owner: grafana
--

COMMENT ON COLUMN tools.query.query_name IS 'Name of the query';


--
-- Name: COLUMN query.sql; Type: COMMENT; Schema: tools; Owner: grafana
--

COMMENT ON COLUMN tools.query.sql IS 'SQL, Do not include the ; at the end of the query';


--
-- Name: COLUMN query.disabled; Type: COMMENT; Schema: tools; Owner: grafana
--

COMMENT ON COLUMN tools.query.disabled IS 'Disable this query';


--
-- Name: COLUMN query.maintenance_db_only; Type: COMMENT; Schema: tools; Owner: grafana
--

COMMENT ON COLUMN tools.query.maintenance_db_only IS 'Only run on the maintenance_db aka once per server';


--
-- Name: COLUMN query.pg_version; Type: COMMENT; Schema: tools; Owner: grafana
--

COMMENT ON COLUMN tools.query.pg_version IS 'Postgres must be this version or greater';


--
-- Name: COLUMN query.run_order; Type: COMMENT; Schema: tools; Owner: grafana
--

COMMENT ON COLUMN tools.query.run_order IS 'This is the order that the queries will be processed';


--
-- Name: COLUMN query.schema_name; Type: COMMENT; Schema: tools; Owner: grafana
--

COMMENT ON COLUMN tools.query.schema_name IS 'The schema in the reports db that this is to be written to.';


--
-- Name: COLUMN query.table_name; Type: COMMENT; Schema: tools; Owner: grafana
--

COMMENT ON COLUMN tools.query.table_name IS 'The table in the reports db that this is to be written to.';


--
-- Name: postgres_log_databases postgres_log_databases_pkey; Type: CONSTRAINT; Schema: reports; Owner: pg_monitor
--

ALTER TABLE ONLY reports.postgres_log_databases
    ADD CONSTRAINT postgres_log_databases_pkey PRIMARY KEY (cluster_name, database_name);


--
-- Name: build_items build_items_idx; Type: CONSTRAINT; Schema: tools; Owner: grafana
--

ALTER TABLE ONLY tools.build_items
    ADD CONSTRAINT build_items_idx PRIMARY KEY (item_schema, item_name);


--
-- Name: query query_pkey; Type: CONSTRAINT; Schema: tools; Owner: grafana
--

ALTER TABLE ONLY tools.query
    ADD CONSTRAINT query_pkey UNIQUE (query_name, pg_version);


--
-- Name: servers servers_pkey; Type: CONSTRAINT; Schema: tools; Owner: grafana
--

ALTER TABLE ONLY tools.servers
    ADD CONSTRAINT servers_pkey PRIMARY KEY (server_name, maintenance_database, port);


--
-- Name: archive_failure_log_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: postgres
--

CREATE INDEX archive_failure_log_cluster_name_log_time_idx ON reports.archive_failure_log USING btree (cluster_name, log_time DESC);


--
-- Name: archive_failure_log_log_time_idx; Type: INDEX; Schema: reports; Owner: postgres
--

CREATE INDEX archive_failure_log_log_time_idx ON reports.archive_failure_log USING btree (log_time DESC);


--
-- Name: autoanalyze_logs_cluster_name_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX autoanalyze_logs_cluster_name_time_idx ON reports.autoanalyze_logs USING btree (cluster_name, "time" DESC);


--
-- Name: autoanalyze_logs_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX autoanalyze_logs_time_idx ON reports.autoanalyze_logs USING btree ("time" DESC);


--
-- Name: autovacuum_logs_cluster_name_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX autovacuum_logs_cluster_name_time_idx ON reports.autovacuum_logs USING btree (cluster_name, "time" DESC);


--
-- Name: autovacuum_logs_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX autovacuum_logs_time_idx ON reports.autovacuum_logs USING btree ("time" DESC);


--
-- Name: autovacuum_thresholds_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX autovacuum_thresholds_cluster_name_log_time_idx ON reports.autovacuum_thresholds USING btree (cluster_name, log_time DESC);


--
-- Name: autovacuum_thresholds_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX autovacuum_thresholds_log_time_idx ON reports.autovacuum_thresholds USING btree (log_time DESC);


--
-- Name: checkpoint_logs_cluster_name_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX checkpoint_logs_cluster_name_time_idx ON reports.checkpoint_logs USING btree (cluster_name, "time" DESC);


--
-- Name: checkpoint_logs_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX checkpoint_logs_time_idx ON reports.checkpoint_logs USING btree ("time" DESC);


--
-- Name: checkpoint_warning_logs_cluster_name_time_idx; Type: INDEX; Schema: reports; Owner: postgres
--

CREATE INDEX checkpoint_warning_logs_cluster_name_time_idx ON reports.checkpoint_warning_logs USING btree (cluster_name, "time" DESC);


--
-- Name: checkpoint_warning_logs_time_idx; Type: INDEX; Schema: reports; Owner: postgres
--

CREATE INDEX checkpoint_warning_logs_time_idx ON reports.checkpoint_warning_logs USING btree ("time" DESC);


--
-- Name: current_auto_vacuum_count_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_auto_vacuum_count_cluster_name_log_time_idx ON reports.current_auto_vacuum_count USING btree (cluster_name, log_time DESC);


--
-- Name: current_auto_vacuum_count_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_auto_vacuum_count_log_time_idx ON reports.current_auto_vacuum_count USING btree (log_time DESC);


--
-- Name: current_autovacuum_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_autovacuum_cluster_name_log_time_idx ON reports.current_autovacuum USING btree (cluster_name, log_time DESC);


--
-- Name: current_autovacuum_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_autovacuum_log_time_idx ON reports.current_autovacuum USING btree (log_time DESC);


--
-- Name: current_pg_database_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_pg_database_cluster_name_log_time_idx ON reports.current_pg_database USING btree (cluster_name, log_time DESC);


--
-- Name: current_pg_database_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_pg_database_log_time_idx ON reports.current_pg_database USING btree (log_time DESC);


--
-- Name: current_pg_settings_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_pg_settings_cluster_name_log_time_idx ON reports.current_pg_settings USING btree (cluster_name, log_time DESC);


--
-- Name: current_pg_settings_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_pg_settings_log_time_idx ON reports.current_pg_settings USING btree (log_time DESC);


--
-- Name: current_pg_stat_activity_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_pg_stat_activity_cluster_name_log_time_idx ON reports.current_pg_stat_activity USING btree (cluster_name, log_time DESC);


--
-- Name: current_pg_stat_activity_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_pg_stat_activity_log_time_idx ON reports.current_pg_stat_activity USING btree (log_time DESC);


--
-- Name: current_replication_status_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_replication_status_cluster_name_log_time_idx ON reports.current_replication_status USING btree (cluster_name, log_time DESC);


--
-- Name: current_replication_status_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_replication_status_log_time_idx ON reports.current_replication_status USING btree (log_time DESC);


--
-- Name: current_table_stats_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_table_stats_cluster_name_log_time_idx ON reports.current_table_stats USING btree (cluster_name, log_time DESC);


--
-- Name: current_table_stats_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX current_table_stats_log_time_idx ON reports.current_table_stats USING btree (log_time DESC);


--
-- Name: custom_table_settings_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX custom_table_settings_cluster_name_log_time_idx ON reports.custom_table_settings USING btree (cluster_name, log_time DESC);


--
-- Name: custom_table_settings_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX custom_table_settings_log_time_idx ON reports.custom_table_settings USING btree (log_time DESC);


--
-- Name: granted_locks_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX granted_locks_cluster_name_log_time_idx ON reports.granted_locks USING btree (cluster_name, log_time DESC);


--
-- Name: granted_locks_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX granted_locks_log_time_idx ON reports.granted_locks USING btree (log_time DESC);


--
-- Name: lock_logs_cluster_name_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX lock_logs_cluster_name_time_idx ON reports.lock_logs USING btree (cluster_name, "time" DESC);


--
-- Name: lock_logs_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX lock_logs_time_idx ON reports.lock_logs USING btree ("time" DESC);


--
-- Name: postgres_log_cluster_name_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX postgres_log_cluster_name_log_time_idx ON reports.postgres_log USING btree (cluster_name, log_time DESC);


--
-- Name: postgres_log_log_time_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX postgres_log_log_time_idx ON reports.postgres_log USING btree (log_time DESC);


--
-- Name: postgres_logs_idx; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX postgres_logs_idx ON reports.postgres_log USING btree (log_time, cluster_name, database_name);


--
-- Name: postgres_logs_pkey; Type: INDEX; Schema: reports; Owner: grafana
--

CREATE INDEX postgres_logs_pkey ON reports.postgres_log USING btree (cluster_name, session_id, session_line_num);


--
-- Name: postgres_log postgres_log_tr; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER postgres_log_tr BEFORE INSERT ON reports.postgres_log FOR EACH ROW EXECUTE PROCEDURE public.postgres_log_trigger();


--
-- Name: archive_failure_log ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.archive_failure_log FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: autoanalyze_logs ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.autoanalyze_logs FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: autovacuum_logs ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.autovacuum_logs FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: autovacuum_thresholds ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.autovacuum_thresholds FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: checkpoint_logs ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.checkpoint_logs FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: checkpoint_warning_logs ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.checkpoint_warning_logs FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: current_auto_vacuum_count ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.current_auto_vacuum_count FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: current_autovacuum ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.current_autovacuum FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: current_pg_database ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.current_pg_database FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: current_pg_settings ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.current_pg_settings FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: current_pg_stat_activity ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.current_pg_stat_activity FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: current_replication_status ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.current_replication_status FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: current_table_stats ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.current_table_stats FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: custom_table_settings ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.custom_table_settings FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: granted_locks ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.granted_locks FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: lock_logs ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.lock_logs FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: postgres_log ts_insert_blocker; Type: TRIGGER; Schema: reports; Owner: grafana
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON reports.postgres_log FOR EACH ROW EXECUTE PROCEDURE _timescaledb_internal.insert_blocker();


--
-- Name: TABLE checkpoint_warning_logs; Type: ACL; Schema: reports; Owner: postgres
--

GRANT SELECT ON TABLE reports.checkpoint_warning_logs TO grafana;


--
-- Name: TABLE archive_failure_log; Type: ACL; Schema: reports; Owner: postgres
--

GRANT SELECT ON TABLE reports.archive_failure_log TO grafana;


--
-- Name: TABLE hypertable; Type: ACL; Schema: reports; Owner: postgres
--

GRANT SELECT ON TABLE reports.hypertable TO grafana;


--
-- PostgreSQL database dump complete
--

