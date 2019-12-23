CREATE OR REPLACE FUNCTION tools.generate_pgtap (
)
RETURNS SETOF text AS
$body$
DECLARE
  r RECORD;
  r2 RECORD;
  count BIGINT;
  sql TEXT;
BEGIN
  count = 0;
  sql = '';

  CREATE EXTENSION IF NOT EXISTS pgtap;

  sql = sql || E'SELECT diag(''================================='');\n';
  sql = sql || E'SELECT diag(''Role Tests'');\n';
  sql = sql || E'SELECT has_role(''grafana''::name);\n';
  count = count + 1;

  sql = sql || E'SELECT diag(''================================='');\n';
  sql = sql || E'SELECT diag(''Schema Tests'');\n';
  sql = sql || E'SELECT has_schema(''logs'');\n';
  sql = sql || E'SELECT schema_owner_is(''logs'', ''grafana''::NAME);\n';
  sql = sql || E'SELECT has_schema(''stats'');\n';
  sql = sql || E'SELECT schema_owner_is(''stats'', ''grafana''::NAME);\n';
  sql = sql || E'SELECT has_schema(''tools'');\n';
  sql = sql || E'SELECT schema_owner_is(''tools'', ''grafana''::NAME);\n';
  count = count + 6;

  sql = sql || E'SELECT diag(''================================='');\n';
  sql = sql || E'SELECT diag(''Table Tests'');\n';
  FOR r IN SELECT * FROM information_schema.tables WHERE table_type = 'BASE TABLE' AND table_schema IN ('logs', 'stats', 'tools') LOOP
  	sql = sql || 'SELECT has_table ( ' || quote_literal(r.table_schema) || ', ' || quote_literal(r.table_name) || E'::NAME );\n';
  	sql = sql || 'SELECT table_owner_is ( ' || quote_literal(r.table_schema) || ', ' || quote_literal(r.table_name) || E'::NAME, ''grafana''::NAME);\n';
    count = count + 2;
	  FOR r2 IN SELECT * FROM information_schema.columns WHERE table_schema = r.table_schema AND table_name = r.table_name ORDER BY ordinal_position LOOP
        sql = sql || 'SELECT has_column( ' || quote_literal(r.table_schema) || ', ' || quote_literal(r.table_name) || E'::NAME, ' || quote_literal(r2.column_name) || E'::NAME, ''Column ' || quote_ident(r.table_schema) || '.' || quote_ident(r.table_name) || '.' || quote_ident(r2.column_name) || E' should exist'' );\n';
        sql = sql || 'SELECT col_type_is( ' || quote_literal(r.table_schema) || ', ' || quote_literal(r.table_name) || E'::NAME, ' || quote_literal(r2.column_name) || '::NAME, ' || 
        	CASE  
            	WHEN r2.data_type = 'ARRAY' THEN quote_literal(
                	CASE r2.udt_name 
                    	WHEN '_text' 
                        THEN 'text' 
                        END || '[]') 
            	WHEN r2.data_type = 'timestamp with time zone' AND r2.datetime_precision <> 6 THEN quote_literal('timestamp(' || r2.datetime_precision || ') with time zone')
                ELSE quote_literal(r2.data_type) 
            END || E' );\n';
	    count = count + 2;
	  END LOOP;
  END LOOP;

  sql = sql ||  E'\n';
  sql = sql ||  E'SELECT diag(''================================='');\n';
  sql = sql ||  E'SELECT diag(''View Tests'');\n';
  FOR r IN SELECT * FROM information_schema.tables WHERE table_type = 'VIEW' AND table_schema IN ('logs', 'stats', 'tools') LOOP
  	sql = sql || 'SELECT has_view ( ' || quote_literal(r.table_schema) || ', ' || quote_literal(r.table_name) || E'::NAME, ''View ' || quote_ident(r.table_schema) || '.' || quote_ident(r.table_name) || E' should exist'' );\n';
  	sql = sql || 'SELECT view_owner_is ( ' || quote_literal(r.table_schema) || ', ' || quote_literal(r.table_name) || E'::NAME, ''grafana''::NAME);\n';
    count = count + 2;
	  FOR r2 IN SELECT * FROM information_schema.columns WHERE table_schema = r.table_schema AND table_name = r.table_name ORDER BY ordinal_position LOOP
        sql = sql || 'SELECT has_column( ' || quote_literal(r.table_schema) || ', ' || quote_literal(r.table_name) || E'::NAME, ' || quote_literal(r2.column_name) || E'::NAME, ''Column ' || quote_ident(r.table_schema) || '.' || quote_ident(r.table_name) || '.' || quote_ident(r2.column_name) || E' should exist'' );\n';
        sql = sql || 'SELECT col_type_is( ' || quote_literal(r.table_schema) || ', ' || quote_literal(r.table_name) || E'::NAME, ' || quote_literal(r2.column_name) || '::NAME, ' || 
        	CASE  
            	WHEN r2.data_type = 'ARRAY' THEN quote_literal(
                	CASE r2.udt_name 
                    	WHEN '_text' 
                        THEN 'text' 
                        END || '[]') 
            	WHEN r2.data_type = 'timestamp with time zone' AND r2.datetime_precision <> 6 THEN quote_literal('timestamp(' || r2.datetime_precision || ') with time zone')
                WHEN r2.domain_name IS NOT NULL THEN quote_literal(r2.domain_schema || '.' || r2.domain_name)
                ELSE quote_literal(r2.data_type) 
            END || E' );\n';
	    count = count + 2;
	  END LOOP;
  END LOOP;

  sql = sql ||  E'\n';
  sql = sql || E'SELECT diag(''================================='');\n';
  sql = sql || E'SELECT diag(''Function Tests'');\n';
  FOR r IN SELECT * FROM public.tap_funky WHERE schema IN ('logs', 'stats', 'tools') AND "name" != 'generate_pgtap' LOOP
    IF r.args = '' THEN
      sql = sql || 'SELECT has_function ( ' || quote_literal(r.schema) || ', ' || quote_literal(r.name) || E'::NAME );\n';
    ELSE
      sql = sql || 'SELECT has_function ( ' || quote_literal(r.schema) || ', ' || quote_literal(r.name) || '::NAME, ' || quote_literal(r.args) || E' );\n';
    END IF;
  	sql = sql || 'SELECT function_owner_is ( ' || quote_literal(r.schema) || ', ' || quote_literal(r.name) || '::NAME, ' || quote_literal('{' || r.args || '}') || '::regtype[]::name[], ' || quote_literal(r.owner) || E'::NAME);\n';
    count = count + 2;
  END LOOP;
  
  sql = '-- USE SELECT * FROM tools.generate_pgtap(); TO GENERATE THIS FILE
\connect pgmonitor_db

-- Setup Test Variables
\set test_name ''permissions''
\set test_user ''grafana''
\set test_production_database ''pgmonitor_db''
\set plan ' || count || '

-- Install pgTAP, show diagnostics, and start common tests
--\ir ../common/diagnostic.sql
\i common/diagnostics.pg

' || sql;
  RETURN NEXT sql;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY DEFINER
PARALLEL UNSAFE
COST 100 ROWS 1000;

ALTER FUNCTION tools.generate_pgtap ()
  OWNER TO postgres;