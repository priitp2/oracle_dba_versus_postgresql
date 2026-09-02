#!/usr/local/test_venv/bin/python

import signal, sys, argparse
from datetime import datetime, timedelta
from time import sleep

import psycopg

maxruntime = timedelta(minutes=30)

def db_connect():
    global db_connection_parameters
    return psycopg.connect(db_connection_parameters)


def do_test(db_connection):
    global lastqstart
    with db_connection.cursor() as cur:
        while (datetime.now() - starttime < maxruntime) and not exitnow:
            sleep(0.1)
            lastqstart = datetime.now()
            try:
                cur.execute("select 1")
                _ = cur.fetchone()
            except Exception as e:
                print(
                    f'Failed with "{str(e)}", retrying with empty query to see if connection is still available'
                )
                with db_connection.cursor() as cur2:
                    cur2.execute("")


def signal_handler(sig, frame):
    global exitnow
    exitnow = True


# Parsing arguments
arg_parser = argparse.ArgumentParser(description="PostgreSQL ecosystem failover timing tester")
arg_parser.add_argument("--direct", action="store_true", help="Bypass pgDog and connect directly to the leader database")
arg_parser.add_argument("--direct-any", action="store_true", help="Bypass pgDog and connect directly to any database, leader or replica")
args = arg_parser.parse_args()

# Construct DSN
if args.direct:
    dbhost_dsn = "host=pg1,pg2 port=5432 target_session_attrs=read-write"
elif args.direct_any:
    dbhost_dsn = "host=host=pg1,pg2 port=5432 target_session_attrs=any load_balance_hosts=random"
else:
    dbhost_dsn = "host=pgdog port=6432"
db_connection_parameters = f"{dbhost_dsn} user=demo password=demo123 dbname=demo connect_timeout=2 tcp_user_timeout=2000 sslmode=disable"
print(f"DSN: {db_connection_parameters}")
#
exitnow = False
starttime = datetime.now()
failstart = None
lastqstart = None
signal.signal(signal.SIGINT, signal_handler)
while True:
    print("Connecting...")
    try:
        db = db_connect()
        break
    except Exception as e:
        print(str(e))
        sleep(1)
    if exitnow:
        sys.exit(1)
print("Connected. Running tests (silently).")
starttime = datetime.now()
lastqstart = None
while (datetime.now() - starttime < maxruntime) and not exitnow:
    try:
        if failstart is not None:
            failstart = None
        do_test(db)
    except Exception as e:
        # Database connection was lost, try connecting again
        print(f"FAILED: {str(e)}")
        failstart = datetime.now()
        db = None
        while True:
            if exitnow:
                break
            try:
                db = db_connect()
                print(f"Failure time: {datetime.now() - lastqstart}")
                break
            except:
                sleep(0.1)
        pass
