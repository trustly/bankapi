#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json
import psycopg2
import psycopg2.extras
import re

pg_connect_str = "dbname=bankapi"
pg_conn = None

def respond(result=None, error=None, httperrorcode=None):
    global pg_conn

    if result is not None:
        print "Status: 200 OK"
        print "Content-Type: text/plain"
        print ""
        print result
    else:
        if httperrorcode is None:
            httperrorcode = 500
        if error is None:
            error = 'Unknown error'

        print "Status: %s %s" % (httperrorcode, error)

    if pg_conn is not None:
        pg_conn.close()

    sys.exit(0)

def error_log(s):
    sys.stderr.write("%s\n" % (s))

try:
    pg_conn = psycopg2.connect(pg_connect_str)
except psycopg2.Error as e:
    error_log("Failed to connect to database: error=%s, code=%s" % (e.pgerror, e.pgcode))
    respond(error='Failed to connect to database', httperrorcode=500)

try:
    indata = sys.stdin.read()
except Exception as e:
    respond(error='Failed to decode input data', httperrorcode=400)

if indata is not None:
    cur = pg_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

    sqldata = None
    try:
        cur.execute('SELECT DeliveryReceipt FROM receive_message(%s)',
                [indata])

        sqldata = cur.fetchone()
        pg_conn.commit()
        respond(result=sqldata['deliveryreceipt'])
    except psycopg2.InternalError as e:
        pg_conn.rollback()
        error_log("Call to Receive_Message failed: error=%s, code=%s" % (e.pgerror, e.pgcode))

        mg = re.match('ERROR:\s+(ERROR_\S+)', e.pgerror)
        if mg is not None:
            respond(error=mg.group(1), httperrorcode=500)
        else:
            respond(error='Receieve processing failed', httperrorcode=500)

    except psycopg2.ProgrammingError as e:
        error_log("Call to Receive_Message failed with ProgrammingError: error=%s, code=%s" % (e.pgerror, e.pgcode))
        pg_conn.rollback()
        respond(error='Recieve processing failed', httperrorcode=500)
else:
    respond(error='Invalid method', httperrorcode=404)

sys.exit(0)
