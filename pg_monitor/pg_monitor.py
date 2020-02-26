#!/usr/bin/env python3

# Syntax:
# python3 pg_monitor.py -s hostname -d pgmonitor_db -U postgres -r grafana -vv

# For reading the command line arguments
import argparse
# For PostgreSQL
import psycopg2
from psycopg2 import pool
from psycopg2.extras import RealDictCursor
# file like stream for stdout and stdin used by postgres copy command
import io
#import scharp_tools.py
from scharp_py_tools import scharp_logging
import scharp_py_tools.pgpass
from scharp_py_tools import threading
threader = threading.Threader()
# Allows us to run this script as a daemon
import daemon
from daemon import pidfile
# Allows to to sleep between runs
import time
# Allows us to find the working directory for the daemon
import os
# Required for getting the current error message
import sys

# Setting up command line argument parser
parser = argparse.ArgumentParser(add_help=False)
parser.add_argument("-h", "--host", help="database host or socket directory (default: \"localhost\")")
parser.add_argument("-d", "--dbname", help="database server database (default: \"reports\")")
parser.add_argument("-p", "--port", help="database server port (default: \"5432\")")
parser.add_argument("-s", "--server", help="restrict to specific tools.servers.server_name and changes --pid-file to --server (default: all)")
parser.add_argument("-U", "--user", help="database user name (default: \"" + scharp_py_tools.pgpass.get_default_user() + "\")")
parser.add_argument("-W", "--password", help="set postgres password (default: Read from .pgpass file in " + scharp_py_tools.pgpass.get_default_pgpass() + " or --user's home directory)")
parser.add_argument("-r", "--role", help="set role name (default: \"none\")")
parser.add_argument("-pf", "--passfile", help="set postgres password file (default: .pgpass in the users home directory)")
parser.add_argument("-1", "--transaction", help="execute as a single transaction (per database)", action="store_true")
parser.add_argument("-v", "--verbose", help="set verbose mode to Info (default: \"Error\"", action="store_true")
parser.add_argument("-vv", "--debug", help="set verbose mode to Debug (default: \"Error\"", action="store_true")
parser.add_argument("-vvv", "--trace", help="set verbose mode to Trace (default: \"Error\")", action="store_true")
parser.add_argument("-V", "--version", help="output version information, then exit", action="store_true")
parser.add_argument("-j", "--jobs", help="number of job to run simultaneously", type=int)
parser.add_argument("--daemon", help="run in daemon mode (default: \"False\"", action="store_true")
parser.add_argument("-l", "--log", help="set the file file location and name (default: \"none\")")
parser.add_argument("-w", "--wait", help="set the length between starting each loop (default: \"none\", No looping)", type=int)
parser.add_argument("--pid-file", help="set pid file location (default: \"pg_monitor2.pid'\")")
parser.add_argument("--help", help="show this help message and exit", action="store_true")
args = parser.parse_args()

if args.version:
    print ("pg_monitor2.py 0.03")
    exit()

if args.help:
    parser.print_help()
    exit()

stats_pool_count = 0

def copyData(cursor_stats, stats_query, cursor_reports_write, copy_to_schema, copy_to_table):
    data = io.StringIO()
    statement_stats = """COPY (""" + stats_query + """) TO STDOUT;"""
    logger.debug("Performing: %s", statement_stats)
    cursor_stats.copy_expert(statement_stats, data)
    logger.trace(data.getvalue())
    data.seek(0)

    statement_reports = """COPY \"""" + copy_to_schema + """\".\"""" + copy_to_table + """\" FROM STDIN;"""
    logger.debug("Performing: %s", statement_reports)
    cursor_reports_write.copy_expert(statement_reports, data)
    #cursor_reports_write.copy_from(data, "\"" + copy_to_schema + "\".\"" + copy_to_table + "\"")
    
    if (default_logging_level == logger.TRACE):
        cursor_reports_write.execute("SELECT * FROM \"" + reports_schema + "\".\"" + row['table_name'] + "\"")
        written_rows = cursor_reports_write.fetchall()
        for written_row in written_rows:
            logger.trace(', '.join(written_row))

    data.close()



def getMonitorStats(reports_server, reports_database, reports_port, reports_user, reports_password, get_stats_from_server_name, get_stats_from_server, get_stats_from_database, get_stats_from_port, get_stats_from_user, get_stats_from_password, is_maintenance_db, pg_pool, stats_pool):
    global default_logging_level;
    global stats_pool_count;
    if (default_logging_level == logger.TRACE):
        logger.trace("Performing Maintenance DB: %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s", reports_server, reports_database, reports_port, reports_user, reports_password, get_stats_from_server_name, get_stats_from_server, get_stats_from_database, get_stats_from_port, get_stats_from_user, get_stats_from_password, is_maintenance_db)
    else:
        logger.info("Performing Maintenance DB: %s, %s, %s, %s, xxxx, %s, %s, %s, %s, xxxx, %s, %s", reports_server, reports_database, reports_port, reports_user, get_stats_from_server_name, get_stats_from_server, get_stats_from_database, get_stats_from_port, get_stats_from_user, is_maintenance_db)

    logger.info("Connecting to Reports DB (Reading): psycopg2:database=%s, host=%s, port=%s, user=%s", reports_database, reports_server, reports_port, reports_user);
    # reports_read = psycopg2.connect(host=reports_server,port=reports_port,database=reports_database,user=reports_user,password=reports_password, application_name = 'pg_monitor (Reports Read-'+get_stats_from_server_name+')')
    obtain_connection = True
    while (obtain_connection):
        reports_read = None
        try:
            reports_read = pg_pool.getconn()
            reports_read.isolation_level
            obtain_connection = False
        except psycopg2.pool.PoolError as e:
            logger.error('POOL ERROR (getMonitorStats - Reports Read): %s', e)
            pg_pool.putconn(reports_read, close=True)
            #raise(e)
        except psycopg2.Error as e:
            logger.error('POSTGRES ERROR (getMonitorStats - Reports Read): %s', e.error)
            #raise(e)
        except OperationalError as oe:
            # Close bad connections and then loop and try opening the next connection in the pool
            pg_pool.putconn(reports_read, close=True)
    reports_read.autocommit = True
    if reports_read is not None:
        logger.info('Database connection opened')
    else:
        logger.error('Failed to open database connection')
        exit()
    cursor_reports_read = reports_read.cursor(cursor_factory=RealDictCursor)    
    
    logger.info("Connecting to Reports DB (Writing): psycopg2:database=%s, host=%s, port=%s, user=%s", reports_database, reports_server, reports_port, reports_user);
    # reports_write = psycopg2.connect(host=reports_server,port=reports_port,database=reports_database,user=reports_user,password=reports_password, application_name = 'pg_monitor (Reports Write-'+get_stats_from_server_name+')')
    obtain_connection = True
    while (obtain_connection):
        reports_write = None
        try:
            reports_write = pg_pool.getconn()
            reports_write.isolation_level
            obtain_connection = False
        except psycopg2.pool.PoolError as e:
            logger.error('POOL ERROR (getMonitorStats - Reports Write): %s', e)
            pg_pool.putconn(reports_write, close=True)
            #raise(e)
        except psycopg2.Error as e:
            logger.error('POSTGRES ERROR (getMonitorStats - Reports Write): %s', e.error)
            #raise(e)
        except OperationalError as oe:
            # Close bad connections and then loop and try opening the next connection in the pool
            pg_pool.putconn(reports_write, close=True)
    reports_write.autocommit = False
    if args.transaction:
        reports_write.autocommit = False
    else:
        reports_write.autocommit = True
    if reports_write is not None:
        logger.info('Database connection opened')
    else:
        logger.error('Failed to open database connection')
        exit()
    cursor_reports_write = reports_write.cursor(cursor_factory=RealDictCursor)    
    
    logger.info("Connecting to Stats DB: psycopg2:database=%s, host=%s, port=%s, user=%s", get_stats_from_database, get_stats_from_server, get_stats_from_port, get_stats_from_user);
    #stats = psycopg2.connect(host=get_stats_from_server,port=get_stats_from_port,database=get_stats_from_database,user=get_stats_from_user,password=get_stats_from_password, application_name = 'pg_monitor (Stats Read-'+get_stats_from_server_name+')')
    obtain_connection = True
    while (obtain_connection):
        stats = None
        try:
            stats_pool_count = stats_pool_count + 1
            stats = stats_pool.getconn()
            stats.isolation_level
            obtain_connection = False
        except psycopg2.pool.PoolError as e:
            logger.error('POOL ERROR (getMonitorStats - Stats): %s (Pool Count: %s)', e, stats_pool_count)
            #stats_pool.putconn(stats, close=True)
            #raise(e)
        except psycopg2.Error as e:
            logger.error('POSTGRES ERROR (getMonitorStats - Stats): %s', e.error)
            #raise(e)
        except OperationalError as oe:
            # Close bad connections and then loop and try opening the next connection in the pool
            #stats_pool.putconn(stats, close=True)
            stats_pool.putconn(stats)
            stats_pool_count = stats_pool_count - 1
    stats.autocommit = True
    if stats is not None:
        logger.info('Database connection opened')
    else:
        logger.error('Failed to open database connection')
        exit()
    cursor_stats = stats.cursor(cursor_factory=RealDictCursor)    
    
    ############################# NEED TO CHECK FOR SUPERUSER PERMSIONS #############################
    # For debugging only, Requires superuser permissions
    if (default_logging_level <= logger.DEBUG):
        statement = """DO $$
DECLARE
r RECORD;
BEGIN
    SELECT rolsuper INTO r FROM pg_catalog.pg_roles WHERE rolname = current_user;
    IF r.rolsuper THEN
        SET log_min_duration_statement = '0';
    END IF;
END 
$$;"""
        logger.debug('Performing: %s', statement)
        cursor_reports_write.execute(statement)
        cursor_reports_read.execute(statement)
        cursor_stats.execute(statement)
    
    if args.role:
        statement = "SET ROLE " + args.role + ";";
        logger.debug('Performing: %s', statement)
        cursor_reports_read.execute(statement)
        cursor_reports_write.execute(statement)
    
    statement = "SET client_min_messages = 'ERROR';"
    logger.debug('Performing: %s', statement)
    cursor_reports_read.execute(statement)
    statement = "SET client_min_messages = 'ERROR';"
    logger.debug('Performing: %s', statement)
    cursor_reports_write.execute(statement)
    statement = "SET client_min_messages = 'ERROR';"
    logger.debug('Performing: %s', statement)
    cursor_stats.execute(statement)
    
    logger.info("Starting Work!")

    statement = """SELECT (current_setting('server_version_num'::text)::INTEGER/10000)::numeric +
(((current_setting('server_version_num'::text)::INTEGER/100) - ((current_setting('server_version_num'::text)::INTEGER/10000)*100))::numeric / 10)
AS major_version """;
    logger.debug('Performing: %s', statement)
    cursor_stats.execute(statement)
    row = cursor_stats.fetchone()
    pg_version = row['major_version']
    
    logger.info("PG Version: %.2f", pg_version)
    ############################## REVISE THIS IF STATEMENT
    pg_clustername = None
    if pg_version < 9.5:
        pg_clustername = get_stats_from_server_name
        logger.debug("Setting Cluster Name (%s): %s", pg_version, pg_clustername)
    elif pg_version >= 9.5:
        statement = "SELECT COALESCE(current_setting('cluster_name'::text),'') AS cluster_name";
        logger.debug('Performing: %s', statement)
        pg_clustername = get_stats_from_server_name
        logger.debug("Setting Cluster Name: %s", pg_clustername)
        
    maintenance_db_check = ""
    if not is_maintenance_db:
        maintenance_db_check = """ AND maintenance_db_only = FALSE """
    statement_reports_read = """
SELECT query_name, sql, disabled, maintenance_db_only, pg_version, run_order, schema_name, table_name FROM (
    SELECT DISTINCT ON (query_name) * FROM tools.query 
    WHERE disabled = false 
        AND (pg_version IS NULL OR pg_version <= '""" + str(pg_version) + """') """ + maintenance_db_check + """
        """ + maintenance_db_check + """ 
    ORDER BY query_name, pg_version DESC
) a 
ORDER BY run_order ASC
    """
    logger.debug('Performing: %s', statement_reports_read)
    cursor_reports_read.execute(statement_reports_read)
    rows = cursor_reports_read.fetchall()
    created_schema = False
    
    for row in rows:
        # If query is for Maintenance db only use ServerName otherwise use ServerName-DatabaseName for the schema name
        #if row['maintenance_db_only'] == True:
        #    reports_schema = get_stats_from_server_name;
        #    #create_schema = "SELECT tools.create_server_inherits('" + get_stats_from_server_name + "');"
        #else:
        #    reports_schema = get_stats_from_server_name + "-" + get_stats_from_database
        #    #create_schema = "SELECT tools.create_server_database_inherits('" + get_stats_from_server_name + "', '" + get_stats_from_database + "');"
        reports_schema = "reports"

        #logger.debug('Performing: %s', create_schema)
        #cursor_reports_write.execute(create_schema)

        statement_reports = """
DO $$
DECLARE
    tables RECORD;
BEGIN
    SELECT * INTO tables FROM information_schema.tables WHERE table_schema = '""" + reports_schema + """' AND table_name = '""" + row['table_name'] + """';
    IF FOUND THEN
        DELETE FROM ONLY \"""" + reports_schema + """\".\"""" + row['table_name'] + """\";
    END IF;
END
$$;
        """
        logger.debug('Performing: %s', statement_reports)
        cursor_reports_write.execute(statement_reports)
    
        sql = row['sql']

        if not pg_clustername is None:
            logger.debug("Manually Setting Cluster Name: %s", pg_clustername)
            find = """current_setting('cluster_name'::text)"""
            replace = "'" + pg_clustername + "'"
            logger.trace("Find: %s - With: %s", find, replace)
            sql = sql.replace(find, replace)
            
        if not row['pg_version'] is None:
            query_pg_version = row['pg_version']
        else:
            query_pg_version = '(none)'
            
        logger.info("Performing: %s - PG Version: %s", row['query_name'], query_pg_version);
        copyData(cursor_stats, sql, cursor_reports_write, reports_schema, row['table_name']);

    logger.info("Finished Work!")

    logger.info("Closing Stats Connection");
    stats.commit()
    cursor_stats.close()
    #stats.close()
    stats_pool.putconn(stats)
    #stats_pool.putconn(stats, close=True)
    stats_pool_count = stats_pool_count - 1
    logger.info("Closing Reports Connection (Reading)");
    reports_read.commit()
    cursor_reports_read.close()
    pg_pool.putconn(reports_read)
    # reports_read.close()
    logger.info("Closing Reports Connection (Writing)");
    reports_write.commit()
    cursor_reports_write.close()
    pg_pool.putconn(reports_write)
    # reports_write.close()

def pg_monitor(args):
    global default_logging_level;
    global logger;
    global MAX_THREAD_COUNT;
    global db_pools;
    db_pools = {}
    # Setting Defaults
    logger = scharp_logging.Logger(level = 10, threading = True)
    default_logging_level = logger.WARNING
    MAX_THREAD_COUNT = 15
    # Custom Logging Levels
    PG_DATABASE = "reports"
    PG_SERVER = "localhost"
    PG_PORT = "5432"

    if args.verbose:
        default_logging_level = logger.INFO
    
    if args.debug:
        default_logging_level = logger.DEBUG
    
    if args.trace:
        default_logging_level = logger.TRACE
    
    logger.close()
    
    if os.path.dirname(__file__) != "":
        os.chdir(os.path.dirname(__file__))
    if args.log:
        local_log_file = args.log
    elif args.verbose and args.daemon and args.server:
        local_log_file = os.getcwd() + "/" + args.server + ".log"
    elif args.verbose and args.daemon:
        local_log_file = 'pg_monitor.log'
    else:
        # Changed on 4/12/2019 to log all errors to the log file.
        local_log_file = 'pg_monitor.log'
        # local_log_file = None

    if local_log_file == None:
        logger = scharp_logging.Logger(level = default_logging_level, threading = True)
    else:
        logger = scharp_logging.Logger(level = default_logging_level, threading = True, file_name = local_log_file)
    
    if args.host:
        PG_SERVER = args.host
        
    if args.dbname:
        PG_DATABASE = args.dbname
    
    if args.port:
        PG_PORT = args.port
        
    if args.jobs == None:
        threader.MAX_THREADS = int('0')
    else:
        threader.MAX_THREADS = args.jobs    
    #if args.jobs:
    #threader.MAX_THREADS = args.jobs
    #print("jobs = '" + str(args.jobs) + "'")
    #else:
    #    threader.MAX_THREADS = 5 # 1 Parent Thread, +5 Child Threads

    
    logger.info('Starting pg_monitor2.py')

    logger.info("Postgres Host: %s", PG_SERVER)
    logger.info("Postgres Datbase: %s", PG_DATABASE)
    logger.info("Postgres Port: %s", PG_PORT)
    PG_USER = scharp_py_tools.pgpass.get_default_user()
    if args.user:
        PG_USER = args.user
    logger.info("Postgres User: %s", PG_USER)
    if args.role:
        logger.info("Postgres Role: %s", args.role)
    
    PG_PASSWORD_FILE = scharp_py_tools.pgpass.get_default_pgpass()
    if args.passfile:
        PG_PASSWORD_FILE = args.passfile
    logger.info("Postgres Password File: %s", PG_PASSWORD_FILE)
    
    if args.password:
        PG_PASSWORD = args.password
    else:
        PG_PASSWORD = scharp_py_tools.pgpass.read_pgpass(PG_SERVER, PG_DATABASE, PG_USER, PG_PORT, PG_PASSWORD_FILE)
    if PG_PASSWORD == None:    
        logger.error("Postgres Password: %s", PG_PASSWORD)
        exit()
    logger.trace("Postgres Password: %s", PG_PASSWORD)
    
    if args.server:
        server_app_name = '-'+args.server
    else:
        server_app_name = ''
    # conn = psycopg2.connect(host=PG_SERVER,port=PG_PORT,database=PG_DATABASE,user=PG_USER,password=PG_PASSWORD,application_name = 'pg_monitor (Reports Master'+server_app_name+')')
    threaded_postgreSQL_pool = psycopg2.pool.ThreadedConnectionPool(3, ((threader.MAX_THREADS*3)+1),host=PG_SERVER,port=PG_PORT,database=PG_DATABASE,user=PG_USER,password=PG_PASSWORD,application_name = 'pg_monitor (Reports Master'+server_app_name+')')
    if(threaded_postgreSQL_pool):
        logger.info("Connection pool created successfully using ThreadedConnectionPool")
        
    while (True):
        try:
            start_time = time.time()
            # Use getconn() method to Get Connection from connection pool
            conn  = threaded_postgreSQL_pool.getconn()
            conn.autocommit = True
            if conn is not None:
                logger.info('Database connection opened')
            else:
                logger.error('Failed to open database connection')
                exit()
            cur = conn.cursor(cursor_factory=RealDictCursor)  
            
                  
            
            if args.role:
                statement = "SET ROLE " + args.role + ";";
                logger.debug('Performing: %s', statement)
                cur.execute(statement)
            
            statement = "SET client_min_messages = 'ERROR'";
            logger.debug('Performing: %s', statement)
            cur.execute(statement)
            
            statement = "SELECT tools.create_reports();";
            logger.debug('Performing: %s', statement)
            cur.execute(statement)
            
            # Primary Databases in tools.servers
            if args.server:
                server_filter = " AND a.server_name = '" + args.server + "'"
            else:
                server_filter = ""
            
            statement = """SELECT server_name, server, maintenance_database, username, password, maintenance_db, port, pgpass_file 
            FROM tools.servers a
            WHERE disabled = FALSE """ + server_filter + """
            --AND maintenance_db = TRUE
            ORDER BY maintenance_db DESC;""";
            logger.debug('Performing: %s', statement)
            cur.execute(statement)
            rows = cur.fetchall()
            
                
            for row in rows:
                if row['username']:
                    DB_PG_USER = row['username']
                else:
                    DB_PG_USER = PG_USER
            
                scharp_py_tools.pgpass.reset_pgpass_files()        
                if not row['password'] is None:
                    logger.debug("Password Specified in tools.server")
                    DB_PG_PASSWORD = row['password']
                elif not row['pgpass_file'] is None:
                    logger.debug("Password File Specified in tools.server")
                    DB_PG_PASSWORD = scharp_py_tools.pgpass.read_pgpass(row['server'], row['maintenance_database'], DB_PG_USER, row['port'], DB_PG_PASSWORD_FILE)
                else:
                    logger.debug("Looking up Password in: %s", PG_PASSWORD_FILE)
                    DB_PG_PASSWORD = scharp_py_tools.pgpass.read_pgpass(row['server'], row['maintenance_database'], DB_PG_USER, row['port'])
                if DB_PG_PASSWORD is None:
                    logger.debug("Using Command Line Password")
                    DB_PG_PASSWORD = PG_PASSWORD
            
                server_id = row['server'] + "_" + row['maintenance_database'] + "_" + str(row['port']) + "_" + DB_PG_USER
                if (server_id not in db_pools):        
                    db_pools[server_id] = psycopg2.pool.ThreadedConnectionPool(1, 1,host=row['server'],port=row['port'],database=row['maintenance_database'],user=DB_PG_USER,password=DB_PG_PASSWORD,application_name = 'pg_monitor (Stats Read-'+row['server_name']+')')
                    if(db_pools[server_id]):
                        logger.info("Connection pool created successfully using ThreadedConnectionPool for: " + server_id)
    
                threader.spawn_thread(getMonitorStats, PG_SERVER, PG_DATABASE, PG_PORT, PG_USER, PG_PASSWORD, row['server_name'], row['server'], row['maintenance_database'], row['port'], DB_PG_USER, DB_PG_PASSWORD, row['maintenance_db'], threaded_postgreSQL_pool, db_pools[server_id])
            
            # Secondary Databases aka "Read All Databases" check in tools.servers
            statement = """SELECT a.server_name, a.server, cpd.database_name AS maintenance_database, a.username, a.password, FALSE::boolean AS maintenance_db, a.port, a.pgpass_file 
            FROM tools.servers a
            LEFT JOIN (
    SELECT max(log_time) AS log_time, cluster_name
    FROM reports.current_pg_database
    GROUP BY cluster_name
) b ON b.cluster_name = a.server_name
            LEFT JOIN reports.current_pg_database cpd
            ON (cpd.cluster_name = b.cluster_name OR cpd.cluster_name = b.cluster_name || '-a' OR cpd.cluster_name = b.cluster_name || '-b') 
            AND b.log_time = cpd.log_time
            WHERE a.disabled = FALSE """ + server_filter + """
            AND a.read_all_databases = TRUE
            AND a.maintenance_database != cpd.database_name
            AND cpd.database_name NOT IN ('template0', 'template1', 'rdsadmin', a.maintenance_database) 
            AND cpd.database_name NOT LIKE 'template_restore%' 
            AND cpd.database_name NOT LIKE 'tmp_%' 
            ORDER BY 1,3;""";
            logger.debug('Performing: %s', statement)
            cur.execute(statement)
            rows = cur.fetchall()
            
                
            for row in rows:
                if row['username']:
                    DB_PG_USER = row['username']
                else:
                    DB_PG_USER = PG_USER
            
                scharp_py_tools.pgpass.reset_pgpass_files()        
                if not row['password'] is None:
                    logger.debug("Password Specified in tools.server")
                    DB_PG_PASSWORD = row['password']
                elif not row['pgpass_file'] is None:
                    logger.debug("Password File Specified in tools.server")
                    DB_PG_PASSWORD = scharp_py_tools.pgpass.read_pgpass(row['server'], row['maintenance_database'], DB_PG_USER, row['port'], DB_PG_PASSWORD_FILE)
                else:
                    logger.debug("Looking up Password in: %s", PG_PASSWORD_FILE)
                    DB_PG_PASSWORD = scharp_py_tools.pgpass.read_pgpass(row['server'], row['maintenance_database'], DB_PG_USER, row['port'])
                if DB_PG_PASSWORD is None:
                    logger.debug("Using Command Line Password")
                    DB_PG_PASSWORD = PG_PASSWORD
    
                server_id = row['server'] + "_" + row['maintenance_database'] + "_" + str(row['port']) + "_" + DB_PG_USER
                if (server_id not in db_pools):        
                    logger.info("Creating Connection pool using ThreadedConnectionPool for: " + server_id)
                    db_pools[server_id] = psycopg2.pool.ThreadedConnectionPool(1, 1,host=row['server'],port=row['port'],database=row['maintenance_database'],user=DB_PG_USER,password=DB_PG_PASSWORD,application_name = 'pg_monitor (Stats Read-'+row['server_name']+')')
                    if(db_pools[server_id]):
                        logger.info("Connection pool created successfully using ThreadedConnectionPool for: " + server_id)
    
                threader.spawn_thread(getMonitorStats, PG_SERVER, PG_DATABASE, PG_PORT, PG_USER, PG_PASSWORD, row['server_name'], row['server'], row['maintenance_database'], row['port'], DB_PG_USER, DB_PG_PASSWORD, row['maintenance_db'], threaded_postgreSQL_pool, db_pools[server_id])
            
            threader.wait_for_all_threads()
            cur.close()
            
            #Use this method to release the connection object and send back ti connection pool
            threaded_postgreSQL_pool.putconn(conn)
            logger.info("Put away a PostgreSQL connection")
            
            if args.wait == None:
                break
            else:
                sleep_time = args.wait - round(time.time() - start_time)
                if (sleep_time > 0):
                    time.sleep(sleep_time)
                continue

        
        except psycopg2.pool.PoolError as e:
            logger.error('POOL ERROR (pg_monitor - Reports Read): %s', e)
            #raise(e)
        except psycopg2.Error as e:
            logger.error('POSTGRES ERROR (pg_monitor - Reports Read): %s', e.error)
            #raise(e)
        #except OperationalError as oe:
        #    # Close bad connections and then loop and try opening the next connection in the pool
        #    threaded_postgreSQL_pool.putconn(conn, close=True)
        except:
            e = sys.exc_info()[0]
            logger.error("Type: " + e)
            #logger.error("Value: " + sys.exc_info()[1])
            #logger.error("Traceback: " + sys.exc_info()[2])
        
    if (threaded_postgreSQL_pool):
        threaded_postgreSQL_pool.closeall()
        logger.info("Threaded PostgreSQL connection pool is closed")
    
    for k, v in db_pools.items():
        v.closeall()
        logger.info("Threaded PostgreSQL connection pool is closed - " + k)
    
    logger.info('Finished pg_monitor2.py')
    #logger.slogger.shutdown()

def run():
    #logger.info('Starting pg_monitor2.py Master Thread')
    if (args.daemon):
        if args.pid_file:
            local_pid_file = args.pid_file
        elif args.server:
            local_pid_file = args.server + '.pid'
        else:    
            local_pid_file = 'pg_monitor2.pid'
        
        if os.path.dirname(__file__) != "":
            os.chdir(os.path.dirname(__file__))
        with daemon.DaemonContext(working_directory=os.getcwd(), umask=0o002, pidfile=pidfile.TimeoutPIDLockFile(os.getcwd() + "/" + local_pid_file)) as context:
            pg_monitor(args)
    else:
        pg_monitor(args)

if __name__ == "__main__":
    run()