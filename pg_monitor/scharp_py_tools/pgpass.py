from scharp_py_tools import scharp_logging
logger = scharp_logging.Logger()

__author__ = "Lloyd Albin (lalbin@fredhutch.org, lloyd@thealbins.com)"
__version__ = "0.0.4"
__copyright__ = "Copyright (C) 2019 Fred Hutchinson Cancer Research Center"

# For finding out who the current user is
import getpass
# For reading the users home directory
import os
# For reading the .pgpass file
import csv
# For testing to see if file exists
from pathlib import Path

def get_default_pgpass():
    return os.path.expanduser('~'+getpass.getuser())+"/.pgpass"

def get_default_user():
    return getpass.getuser()

def append_pgpass_files(pgpass_file):
    if pgpass_file:
        global pgpass_files
        pgpass_files.append(pgpass_file)

def reset_pgpass_files():
    global pgpass_files
    pgpass_files = [get_default_pgpass()]

def read_pgpass(pg_server, pg_database, pg_user, pg_port = "5432", new_pgpass_file = ""):
    global pgpass_files
    if len(new_pgpass_file):
        pgpass_files = [new_pgpass_file]
    #logging.debug("List of pgpass files: %s", ', '.join(pgpass_files))
    for pgpass_file in pgpass_files:
        #logging.debug("Processing File: %s", pgpass_file)
        #file = Path(pgpass_file)
        if Path(pgpass_file).is_file():
            with open(pgpass_file, newline='') as csvfile:
                pgpassreader = csv.reader(csvfile, delimiter=':', escapechar='\\', quoting=csv.QUOTE_NONE)
                for row in pgpassreader:
                    if row == []:
                        continue
                    if row[0][0] == "#":
                        continue
                    #logging.trace(', '.join(row))
                    if (row[0] == pg_server or row[0] == "*") and (row[1] == pg_port or row[1] == "*") and (row[2] == pg_database or row[2] == "*") and (row[3] == pg_user or row[3] == "*"):
                        return row[4]
        else:
            logger.debug("Skipping Missing File: %s", pgpass_file)

pgpass_files = [get_default_pgpass()]

class Pgpass:
    pass
