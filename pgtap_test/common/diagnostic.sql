-- Turn off echo and keep things quiet.
--\set ECHO
\set QUIET 1

-- Format the output for nice TAP.
\pset format unaligned
\pset tuples_only true
\pset pager

-- Revert all changes on failure.
\set ON_ERROR_ROLLBACK 1
\set ON_ERROR_STOP true
\set QUIET 1

-- Begin the transaction.
BEGIN;

SET search_path TO public;

-- Inline function to set the role for extension installation
DO $BODY$
DECLARE db_owner record;
BEGIN

    SELECT pg_user.usename INTO db_owner
    FROM pg_database 
    LEFT JOIN pg_catalog.pg_user
        ON pg_database.datdba = pg_user.usesysid
    WHERE datname = current_database();

    IF db_owner.usename <> current_user THEN
        EXECUTE 'SET ROLE ' || db_owner.usename;
        SET search_path TO public;
    END IF;

END
$BODY$
LANGUAGE plpgsql;

-- Install the TAP functions if it is not already installed.
CREATE EXTENSION IF NOT EXISTS pgtap;

-- Set the role to the user you wish to run the tests as.
CREATE TEMP TABLE __pgtap_db_server__ (server  text, username text, production_database text);
INSERT INTO __pgtap_db_server__ (server, username, production_database) VALUES (:'HOST', :'test_user', :'test_production_database');


DO $BODY$
DECLARE
    server_name record;
BEGIN
    SELECT server, username, production_database INTO server_name FROM __pgtap_db_server__;

    IF server_name.production_database = current_database() THEN
        -- If production database, run as the owner of the database
        PERFORM 'SET ROLE ' || server_name.username;
        SET search_path TO public;
        --SELECT diag('Running on a production database');
    ELSE
        -- If not a production database, run as the executing user aka developer
        RESET ROLE;        
        SET search_path TO public;
    END IF;
    
END
$BODY$
LANGUAGE plpgsql;

-- Plan the tests.
SELECT plan(:plan + 16);

-- Configuration Data
SELECT diag('Configuration');
SELECT diag('=================================');
SELECT diag('Test Name: ' || :'test_name');
SELECT diag('Date: ' || current_timestamp);
SELECT diag('Current Server: ' || :'HOST');
SELECT diag('Current Database: ' || current_database());
SELECT diag('Current Port: ' || :'PORT');
SELECT diag('');
SELECT diag('Current Session User: ' || session_user);
SELECT diag('Current User: ' || current_user);
SELECT diag('pgTAP Version: ' || pgtap_version());
SELECT diag('pgTAP Postgres Version: ' || pg_version());
SELECT diag('Postgres Version: ' || current_setting( 'server_version'));
SELECT diag('OS: ' || os_name());
SELECT diag('');
SELECT diag('Common Tests');
SELECT diag('=================================');

SELECT ok((SELECT CASE WHEN current_setting( 'server_version_num') = pg_version_num()::text
    THEN TRUE
    ELSE FALSE
    END), 'pgTAP is compiled against the correct Postgres Version');    

SELECT is(
        (SELECT extname FROM pg_catalog.pg_extension WHERE extname = 'plpgsql')
    , 'plpgsql', 'Verifying extension plpgsql is installed');
SELECT is(
        (SELECT extname FROM pg_catalog.pg_extension WHERE extname = 'plperl')
    , 'plperl', 'Verifying extension plperl is installed');
SELECT is(
        (SELECT extname FROM pg_catalog.pg_extension WHERE extname = 'pgtap')
    , 'pgtap', 'Verifying extension pgtap is installed');
SELECT CASE 
    WHEN current_database() = 'postgres' 
    THEN collect_tap(
        is(
                (SELECT extname FROM pg_catalog.pg_extension WHERE extname = 'adminpack')
            , 'adminpack', 'Verifying extension adminpack is installed'),
        is(
                (SELECT extname FROM pg_catalog.pg_extension WHERE extname = 'pg_buffercache')
            , 'pg_buffercache', 'Verifying extension pgbuffercache is installed'),
        is(
                (SELECT count(*)::int FROM pg_catalog.pg_extension)
            , 5, 'Verifying only 5 extensions are installed')
    )
    ELSE collect_tap(
        skip('Skipping extenstion test for adminpack', 1),
        skip('Skipping extenstion test for pg_buffercache', 1),
        is(
                (SELECT count(*)::int FROM pg_catalog.pg_extension)
            , 3, 'Verifying only 3 extensions are installed')
    )
    END;

SELECT diag('Extra Extension Installed: ' || extname)
FROM pg_catalog.pg_extension 
    WHERE (
        current_database() = 'postgres' 
        AND extname != 'plpgsql' 
        AND extname != 'plperl' 
        AND extname != 'pgtap' 
        AND extname != 'adminpack' 
        AND extname != 'pg_buffercache')
        OR (
        current_database() <> 'postgres' 
        AND extname != 'plpgsql' 
        AND extname != 'plperl' 
        AND extname != 'pgtap');
    
SELECT has_language( 'c' );
SELECT has_language( 'internal' );
SELECT has_language( 'sql' );
SELECT has_language( 'plpgsql' );
SELECT has_language( 'plperl' );
SELECT hasnt_language( 'plperlu' );
SELECT is(
        (SELECT count(*)::int FROM pg_catalog.pg_language)
    , 5, 'Verifying no extra languages are installed');   

SELECT diag('Extra Languages Installed: ' || lanname)
FROM pg_catalog.pg_language 
    WHERE lanname != 'c' 
        AND lanname != 'internal' 
        AND lanname != 'sql' 
        AND lanname != 'plpgsql' 
        AND lanname != 'plperl';

SET ROLE postgres;
SET search_path TO public;

CREATE FUNCTION public.perl_test ()
RETURNS integer AS
$body$
return 1;
$body$
LANGUAGE 'plperl'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;

GRANT EXECUTE
  ON FUNCTION public.perl_test() TO PUBLIC;
PREPARE dba_perl_test AS SELECT * FROM public.perl_test();
SELECT lives_ok('dba_perl_test','Testing plperl has multiplicity defined - Test 1');
SET ROLE dba;
SET search_path TO public;
SELECT lives_ok('dba_perl_test','Testing plperl has multiplicity defined - Test 2');
RESET ROLE;

DO $BODY$
DECLARE
    server_name record;
BEGIN
    SELECT server, username, production_database INTO server_name FROM __pgtap_db_server__;

    IF server_name.production_database = current_database() THEN
        -- If production database, run as the owner of the database
        PERFORM 'SET ROLE ' || server_name.username;
        --SELECT diag('Running on a production database');
    ELSE
        -- If not a production database, run as the executing user aka developer
        RESET ROLE;        
    END IF;
END
$BODY$
LANGUAGE plpgsql;

        
SELECT diag('Tests');
SELECT diag('=================================');
    