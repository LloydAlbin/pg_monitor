/*
CREATE OR REPLACE FUNCTION pgtap_version()
RETURNS NUMERIC AS 'SELECT 1.2;'
LANGUAGE SQL IMMUTABLE;
*/

CREATE OR REPLACE VIEW tap_funky2
 AS SELECT p.oid         AS oid,
           p.pronamespace::regnamespace::name AS schema,
           p.proname     AS name,
           p.proowner::regrole::name AS owner,
           array_to_string(p.proargtypes::regtype[], ',') AS args,
           CASE p.proretset WHEN TRUE THEN 'setof ' ELSE '' END
             || p.prorettype::regtype AS returns,
           p.prolang     AS langoid,
           p.proisstrict AS is_strict,
           _prokind(p.oid) AS kind,
           p.prosecdef   AS is_definer,
           p.proretset   AS returns_set,
           p.provolatile::char AS volatility,
           pg_catalog.pg_function_is_visible(p.oid) AS is_visible,
           COALESCE(pro_in.arg_types,ARRAY[NULL::NAME]) AS arg_types,
           COALESCE(pro_in.arg_names,ARRAY[NULL::NAME])::NAME[] AS arg_names,
           COALESCE(pro_out.arg_types,ARRAY[NULL::NAME]) AS return_arg_types,
           COALESCE(pro_out.arg_names,ARRAY[NULL::NAME])::NAME[] AS return_arg_names
      FROM pg_catalog.pg_proc p
  LEFT JOIN (SELECT oid, array_agg(proallargtype ORDER BY nr) AS arg_types, array_agg(proargname ORDER BY nr) AS arg_names FROM (
SELECT 
    p.oid,
    unnest(
    	CASE WHEN p.proallargtypes IS NULL 
        THEN array_remove( array_cat( ARRAY['']::name[], p.proargtypes::regtype [ ]::name[]), '') 
        ELSE  p.proallargtypes::regtype [ ]::NAME[] 
        END)::name AS proallargtype,
    unnest(p.proargmodes) AS proargmode,
    unnest(p.proargnames) AS proargname,
    generate_subscripts(CASE WHEN p.proallargtypes IS NULL 
        THEN array_remove( array_cat( ARRAY['']::name[], p.proargtypes::regtype [ ]::name[]), '') 
        ELSE  p.proallargtypes::regtype [ ]::NAME[] 
        END,1) AS nr
FROM pg_catalog.pg_proc p
) a
WHERE proargmode IN ('i', 'b', 'v') OR proargmode IS NULL
GROUP BY oid) pro_in ON (p.oid = pro_in.oid)
LEFT JOIN (SELECT oid, array_agg(proallargtype ORDER BY nr) AS arg_types, array_agg(proargname ORDER BY nr) AS arg_names FROM (
SELECT 
    p.oid,
    unnest(
    	CASE WHEN p.proallargtypes IS NULL AND t.typtype != 'c'
        THEN ARRAY[p.prorettype::regtype]::name[] 
    	WHEN p.proallargtypes IS NULL AND t.typtype = 'c'
        THEN ts.coltypes 
        ELSE  p.proallargtypes::regtype [ ]::NAME[] 
        END)::name AS proallargtype,
    unnest(p.proargmodes) AS proargmode,
    unnest(CASE WHEN p.proargmodes IS NULL AND t.typtype != 'c'
    	THEN NULL 
        WHEN p.proargmodes IS NULL AND t.typtype = 'c' 
    	THEN ts.colnames 
        ELSE p.proargnames END) AS proargname,
    generate_subscripts(CASE WHEN p.proallargtypes IS NULL AND t.typtype != 'c'
        THEN ARRAY[p.prorettype::regtype]::name[] 
    	WHEN p.proallargtypes IS NULL AND t.typtype = 'c'
        THEN ts.coltypes 
        ELSE  p.proallargtypes::regtype [ ]::NAME[] 
        END,1) AS nr
FROM pg_catalog.pg_proc p
LEFT JOIN pg_catalog.pg_type t ON p.prorettype = t.oid
LEFT JOIN (SELECT c.oid, array_agg(a.attname ORDER BY a.attnum) AS colnames, 
array_agg(a.atttypid::regtype::name ORDER BY a.attnum) AS coltypes
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_attribute a ON c.oid = a.attrelid
WHERE a.attnum > 0
GROUP BY c.oid) ts ON ts.oid = t.typrelid
) a
WHERE proargmode IN ('o', 'b', 't') OR proargmode IS NULL
GROUP BY oid) pro_out ON (p.oid = pro_out.oid)
;

GRANT SELECT ON tap_funky2 TO PUBLIC;

CREATE OR REPLACE FUNCTION _returns_types ( NAME, NAME, NAME[] )
RETURNS NAME[] AS $$
    SELECT return_arg_types
      FROM tap_funky2
     WHERE schema = $1
       AND name   = $2
       AND arg_types   = $3
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION _returns_types ( NAME, NAME )
RETURNS NAME[] AS $$
    SELECT return_arg_types FROM tap_funky2 WHERE schema = $1 AND name = $2
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION _returns_types ( NAME, NAME[] )
RETURNS NAME[] AS $$
    SELECT return_arg_types
      FROM tap_funky2
     WHERE name = $1
       AND arg_types = $2
       AND is_visible;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION _returns_types ( NAME )
RETURNS NAME[] AS $$
    SELECT return_arg_types FROM tap_funky2 WHERE name = $1 AND is_visible;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION _returns_names ( NAME, NAME, NAME[] )
RETURNS NAME[] AS $$
    SELECT return_arg_names
      FROM tap_funky2
     WHERE schema = $1
       AND name   = $2
       AND arg_types   = $3
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION _returns_names ( NAME, NAME )
RETURNS NAME[] AS $$
    SELECT return_arg_names FROM tap_funky2 WHERE schema = $1 AND name = $2
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION _returns_names ( NAME, NAME[] )
RETURNS NAME[] AS $$
    SELECT return_arg_names
      FROM tap_funky2
     WHERE name = $1
       AND arg_types = $2
       AND is_visible;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION _returns_names ( NAME )
RETURNS NAME[] AS $$
    SELECT return_arg_names FROM tap_funky2 WHERE name = $1 AND is_visible;
$$ LANGUAGE SQL;

-- function_returns_types( schema, function, args[], types[], description )
CREATE OR REPLACE FUNCTION function_returns_types( NAME, NAME, NAME[], NAME[], TEXT )
RETURNS TEXT AS $$
    SELECT _func_compare($1, $2, $3, _returns_types($1, $2, $3), $4, $5 );
$$ LANGUAGE SQL;

-- function_returns_types( schema, function, args[], types[] )
CREATE OR REPLACE FUNCTION function_returns_types( NAME, NAME, NAME[], NAME[] )
RETURNS TEXT AS $$
    SELECT function_returns_types(
        $1, $2, $3, $4,
        'Function ' || quote_ident($1) || '.' || quote_ident($2) || '(' ||
        array_to_string($3, ', ') || ') should return ' || array_to_string($4, ',')
    );
$$ LANGUAGE SQL;

-- function_returns_types( schema, function, types[], description )
CREATE OR REPLACE FUNCTION function_returns_types( NAME, NAME, NAME[], TEXT )
RETURNS TEXT AS $$
    SELECT _func_compare($1, $2, _returns_types($1, $2), $3, $4 );
$$ LANGUAGE SQL;

-- function_returns_types( schema, function, types[] )
CREATE OR REPLACE FUNCTION function_returns_types( NAME, NAME, NAME[] )
RETURNS TEXT AS $$
    SELECT function_returns_types(
        $1, $2, $3,
        'Function ' || quote_ident($1) || '.' || quote_ident($2)
        || '() should return ' || array_to_string($3, ',')
    );
$$ LANGUAGE SQL;

-- function_returns_types( function, args[], types[], description )
CREATE OR REPLACE FUNCTION function_returns_types( NAME, NAME[], NAME[], TEXT )
RETURNS TEXT AS $$
    SELECT _func_compare(NULL, $1, $2, _returns_types($1, $2), $3, $4 );
$$ LANGUAGE SQL;

-- function_returns_types( function, args[], types[] )
CREATE OR REPLACE FUNCTION function_returns_types( NAME, NAME[], NAME[] )
RETURNS TEXT AS $$
    SELECT function_returns_types(
        $1, $2, $3,
        'Function ' || quote_ident($1) || '(' ||
        array_to_string($2, ', ') || ') should return ' || array_to_string($3, ',')
    );
$$ LANGUAGE SQL;

-- function_returns_types( function, types[], description )
CREATE OR REPLACE FUNCTION function_returns_types( NAME, NAME[], TEXT )
RETURNS TEXT AS $$
    SELECT _func_compare(NULL, $1, _returns_types($1), $2, $3 );
$$ LANGUAGE SQL;

-- function_returns_types( function, types[] )
CREATE OR REPLACE FUNCTION function_returns_types( NAME, NAME[] )
RETURNS TEXT AS $$
    SELECT function_returns_types(
        $1, $2,
        'Function ' || quote_ident($1) || '() should return ' || array_to_string($2, ',')
    );
$$ LANGUAGE SQL;

-- function_returns_names( schema, function, args[], names[], description )
CREATE OR REPLACE FUNCTION function_returns_names( NAME, NAME, NAME[], NAME[], TEXT )
RETURNS TEXT AS $$
    SELECT _func_compare($1, $2, $3, _returns_names($1, $2, $3), $4, $5 );
$$ LANGUAGE SQL;

-- function_returns_names( schema, function, args[], names[] )
CREATE OR REPLACE FUNCTION function_returns_names( NAME, NAME, NAME[], NAME[] )
RETURNS TEXT AS $$
    SELECT function_returns_names(
        $1, $2, $3, $4,
        'Function ' || quote_ident($1) || '.' || quote_ident($2) || '(' ||
        array_to_string($3, ', ') || ') should return ' || array_to_string($4, ',')
    );
$$ LANGUAGE SQL;

-- function_returns_names( schema, function, names[], description )
CREATE OR REPLACE FUNCTION function_returns_names( NAME, NAME, NAME[], TEXT )
RETURNS TEXT AS $$
    SELECT _func_compare($1, $2, _returns_names($1, $2), $3, $4 );
$$ LANGUAGE SQL;

-- function_returns_names( schema, function, names[] )
CREATE OR REPLACE FUNCTION function_returns_names( NAME, NAME, NAME[] )
RETURNS TEXT AS $$
    SELECT function_returns_names(
        $1, $2, $3,
        'Function ' || quote_ident($1) || '.' || quote_ident($2)
        || '() should return ' || array_to_string($3, ',')
    );
$$ LANGUAGE SQL;

-- function_returns_names( function, args[], names[], description )
CREATE OR REPLACE FUNCTION function_returns_names( NAME, NAME[], NAME[], TEXT )
RETURNS TEXT AS $$
    SELECT _func_compare(NULL, $1, $2, _returns_names($1, $2), $3, $4 );
$$ LANGUAGE SQL;

-- function_returns_names( function, args[], names[] )
CREATE OR REPLACE FUNCTION function_returns_names( NAME, NAME[], NAME[] )
RETURNS TEXT AS $$
    SELECT function_returns_names(
        $1, $2, $3,
        'Function ' || quote_ident($1) || '(' ||
        array_to_string($2, ', ') || ') should return ' || array_to_string($3, ',')
    );
$$ LANGUAGE SQL;

-- function_returns_names( function, names[], description )
CREATE OR REPLACE FUNCTION function_returns_names( NAME, NAME[], TEXT )
RETURNS TEXT AS $$
    SELECT _func_compare(NULL, $1, _returns_names($1), $2, $3 );
$$ LANGUAGE SQL;

-- function_returns_names( function, names[] )
CREATE OR REPLACE FUNCTION function_returns_names( NAME, NAME[] )
RETURNS TEXT AS $$
    SELECT function_returns_names(
        $1, $2,
        'Function ' || quote_ident($1) || '() should return ' || array_to_string($2, ',')
    );
$$ LANGUAGE SQL;

-- _fcexists( schema, function, args[], column )
CREATE OR REPLACE FUNCTION _fcexists ( NAME, NAME, NAME[], NAME )
RETURNS BOOLEAN AS $$
    SELECT EXISTS(
        SELECT true
          FROM tap_funky2
         WHERE schema = $1
           AND "name" = $2
           AND arg_types = $3
           AND return_arg_names @> ARRAY[$4]
    );
$$ LANGUAGE SQL;

-- _fcexists( function, args[], column )
CREATE OR REPLACE FUNCTION _fcexists ( NAME, NAME[], NAME )
RETURNS BOOLEAN AS $$
    SELECT EXISTS(
        SELECT true
          FROM tap_funky2
         WHERE "name" = $1
           AND arg_types = $2
           AND is_visible = true
           AND return_arg_names @> ARRAY[$3]
    );
$$ LANGUAGE SQL;

-- function_has_column( schema, table, args[], column, description )
CREATE OR REPLACE FUNCTION function_has_column ( NAME, NAME, NAME[], NAME, TEXT )
RETURNS TEXT AS $$
    SELECT ok( _fcexists( $1, $2, $3, $4 ), $5 );
$$ LANGUAGE SQL;

-- function_has_column( schema, table, args[], column )
CREATE OR REPLACE FUNCTION function_has_column ( NAME, NAME, NAME[], NAME )
RETURNS TEXT AS $$
    SELECT function_has_column( $1, $2, $3, $4, 'Function Column ' || quote_ident($1) || '.' || quote_ident($1) || '(' || array_to_string($3, ',') || ').' || quote_ident($4) || ' should exist' );
$$ LANGUAGE SQL;

-- function_has_column( table, args[], column, description )
CREATE OR REPLACE FUNCTION function_has_column ( NAME, NAME[], NAME, TEXT )
RETURNS TEXT AS $$
    SELECT ok( _fcexists( $1, $2, $3 ), $4 );
$$ LANGUAGE SQL;

-- function_has_column( table, args[], column )
CREATE OR REPLACE FUNCTION function_has_column ( NAME, NAME[], NAME )
RETURNS TEXT AS $$
    SELECT function_has_column( $1, $2, $3, 'Function Column ' || quote_ident($1) || '(' || array_to_string($2, ',') || ').' || quote_ident($3) || ' should exist' );
$$ LANGUAGE SQL;

-- function_hasnt_column( schema, table, args[], column, description )
CREATE OR REPLACE FUNCTION function_hasnt_column ( NAME, NAME, NAME[], NAME, TEXT )
RETURNS TEXT AS $$
    SELECT ok( NOT _fcexists( $1, $2, $3, $4 ), $5 );
$$ LANGUAGE SQL;

-- function_hasnt_column( schema, table, args[], column )
CREATE OR REPLACE FUNCTION function_hasnt_column ( NAME, NAME, NAME[], NAME )
RETURNS TEXT AS $$
    SELECT function_hasnt_column( $1, $2, $3, $4, 'Function Column ' || quote_ident($1) || '.' || quote_ident($2) || '(' || array_to_string($3, ',') || ').' || quote_ident($4) || ' should not exist' );
$$ LANGUAGE SQL;

-- function_hasnt_column( table, args[], column, description )
CREATE OR REPLACE FUNCTION function_hasnt_column ( NAME, NAME[], NAME, TEXT )
RETURNS TEXT AS $$
    SELECT ok( NOT _fcexists( $1, $2, $3 ), $4 );
$$ LANGUAGE SQL;

-- function_hasnt_column( table, args[], column )
CREATE OR REPLACE FUNCTION function_hasnt_column ( NAME, NAME[], NAME )
RETURNS TEXT AS $$
    SELECT function_hasnt_column( $1, $2, $3, 'Function Column ' || quote_ident($1) || '(' || array_to_string($2, ',') || ').' || quote_ident($3) || ' should not exist' );
$$ LANGUAGE SQL;

-- _get_function_col_ns_type( schema, function, args[], column )
CREATE OR REPLACE FUNCTION _get_function_col_ns_type ( NAME, NAME, NAME[], NAME )
RETURNS NAME AS $$
    -- Always include the namespace.
    SELECT return_arg_types[array_position(return_arg_names, $4)]
      FROM tap_funky2 n
     WHERE schema = $1
       AND "name" = $2
       AND arg_types = $3
$$ LANGUAGE SQL;

-- function_col_type_is( schema, function, args[], column, schema, type, description )
CREATE OR REPLACE FUNCTION function_col_type_is ( NAME, NAME, NAME[], NAME, NAME, TEXT, TEXT )
RETURNS TEXT AS $$
DECLARE
    have_type TEXT := _get_function_col_ns_type($1, $2, $3, $4);
    want_type TEXT;
BEGIN
    IF have_type IS NULL THEN
        RETURN fail( $7 ) || E'\n' || diag (
            '   Column ' || COALESCE(quote_ident($1) || '.', '')
            || quote_ident($2) || '(' || array_to_string($3, ',') || ').' || quote_ident($4) || ' does not exist'
        );
    END IF;

    want_type := quote_ident($5) || '.' || _quote_ident_like($6, have_type);
    IF have_type = want_type THEN
        -- We're good to go.
        RETURN ok( true, $7 );
    END IF;

    -- Wrong data type. tell 'em what we really got.
    RETURN ok( false, $7 ) || E'\n' || diag(
           '        have: ' || have_type ||
        E'\n        want: ' || want_type
    );
END;
$$ LANGUAGE plpgsql;

-- function_col_type_is( schema, function, args[], column, schema, type )
CREATE OR REPLACE FUNCTION function_col_type_is ( NAME, NAME, NAME[], NAME, NAME, TEXT )
RETURNS TEXT AS $$
    SELECT function_col_type_is( $1, $2, $3, $4, $5, $6, 'Column ' || quote_ident($1) || '.' || quote_ident($2)
        || '(' || array_to_string($3, ',') || ').' || quote_ident($4) || ' should be type ' || quote_ident($5) || '.' || $6);
$$ LANGUAGE SQL;

-- function_col_type_is( schema, function, args[], column, type, description )
CREATE OR REPLACE FUNCTION function_col_type_is ( NAME, NAME, NAME[], NAME, TEXT, TEXT )
RETURNS TEXT AS $$
DECLARE
    have_type TEXT;
    want_type TEXT;
BEGIN
    -- Get the data type.
    IF $1 IS NULL THEN
        have_type := _get_function_col_ns_type($2, $3, $4);
    ELSE
        have_type := _get_function_col_ns_type($1, $2, $3, $4);
    END IF;

    IF have_type IS NULL THEN
        RETURN fail( $6 ) || E'\n' || diag (
            '   Column ' || COALESCE(quote_ident($1) || '.', '')
            || quote_ident($2) || '(' || array_to_string($3, ',') || ').' || quote_ident($4) || ' does not exist'
        );
    END IF;

    want_type := _quote_ident_like($5, have_type);
    IF have_type = want_type THEN
        -- We're good to go.
        RETURN ok( true, $6 );
    END IF;

    -- Wrong data type. tell 'em what we really got.
    RETURN ok( false, $6 ) || E'\n' || diag(
           '        have: ' || have_type ||
        E'\n        want: ' || want_type
    );
END;
$$ LANGUAGE plpgsql;

-- function_col_type_is( schema, function, args[], column, type )
CREATE OR REPLACE FUNCTION function_col_type_is ( NAME, NAME, NAME[], NAME, TEXT )
RETURNS TEXT AS $$
    SELECT function_col_type_is( $1, $2, $3, $4, $5, 'Column ' || quote_ident($1) || '.' || quote_ident($2) || '(' || array_to_string($3, ',') || ').' || quote_ident($4) || ' should be type ' || $5 );
$$ LANGUAGE SQL;

-- function_col_type_is( function, args[], column, type, description )
CREATE OR REPLACE FUNCTION function_col_type_is ( NAME, NAME[], NAME, TEXT, TEXT )
RETURNS TEXT AS $$
    SELECT function_col_type_is( NULL, $1, $2, $3, $4, $5 );
$$ LANGUAGE SQL;

-- function_col_type_is( function, args[], column, type )
CREATE OR REPLACE FUNCTION function_col_type_is ( NAME, NAME[], NAME, TEXT )
RETURNS TEXT AS $$
    SELECT function_col_type_is( $1, $2, $3, $4, 'Column ' || quote_ident($1) || '(' || array_to_string($2, ',') || ').' || quote_ident($3) || ' should be type ' || $3 );
$$ LANGUAGE SQL;

ALTER EXTENSION pgtap ADD VIEW tap_funky2;
ALTER EXTENSION pgtap ADD FUNCTION _returns_types ( NAME, NAME, NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION _returns_types ( NAME, NAME );
ALTER EXTENSION pgtap ADD FUNCTION _returns_types ( NAME, NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION _returns_types ( NAME );
ALTER EXTENSION pgtap ADD FUNCTION _returns_names ( NAME, NAME, NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION _returns_names ( NAME, NAME );
ALTER EXTENSION pgtap ADD FUNCTION _returns_names ( NAME, NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION _returns_names ( NAME );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_types( NAME, NAME, NAME[], NAME[], TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_types( NAME, NAME, NAME[], NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_types( NAME, NAME, NAME[], TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_types( NAME, NAME, NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_types( NAME, NAME[], NAME[], TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_types( NAME, NAME[], NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_types( NAME, NAME[], TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_types( NAME, NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_names( NAME, NAME, NAME[], NAME[], TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_names( NAME, NAME, NAME[], NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_names( NAME, NAME, NAME[], TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_names( NAME, NAME, NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_names( NAME, NAME[], NAME[], TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_names( NAME, NAME[], NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_names( NAME, NAME[], TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_returns_names( NAME, NAME[] );
ALTER EXTENSION pgtap ADD FUNCTION _fcexists ( NAME, NAME, NAME[], NAME );
ALTER EXTENSION pgtap ADD FUNCTION _fcexists ( NAME, NAME[], NAME );
ALTER EXTENSION pgtap ADD FUNCTION function_has_column ( NAME, NAME, NAME[], NAME, TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_has_column ( NAME, NAME, NAME[], NAME );
ALTER EXTENSION pgtap ADD FUNCTION function_has_column ( NAME, NAME[], NAME, TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_has_column ( NAME, NAME[], NAME );
ALTER EXTENSION pgtap ADD FUNCTION function_hasnt_column ( NAME, NAME, NAME[], NAME, TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_hasnt_column ( NAME, NAME, NAME[], NAME );
ALTER EXTENSION pgtap ADD FUNCTION function_hasnt_column ( NAME, NAME[], NAME, TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_hasnt_column ( NAME, NAME[], NAME );
ALTER EXTENSION pgtap ADD FUNCTION _get_function_col_ns_type ( NAME, NAME, NAME[], NAME );
ALTER EXTENSION pgtap ADD FUNCTION function_col_type_is ( NAME, NAME, NAME[], NAME, NAME, TEXT, TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_col_type_is ( NAME, NAME, NAME[], NAME, NAME, TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_col_type_is ( NAME, NAME, NAME[], NAME, TEXT, TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_col_type_is ( NAME, NAME, NAME[], NAME, TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_col_type_is ( NAME, NAME[], NAME, TEXT, TEXT );
ALTER EXTENSION pgtap ADD FUNCTION function_col_type_is ( NAME, NAME[], NAME, TEXT );
