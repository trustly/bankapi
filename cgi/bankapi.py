#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json
import psycopg2
import psycopg2.extras
import re
import datetime
import os

pg_connect_str = "dbname=bankapi"
pg_conn = None

debug_incoming_data = False
debug_path = '/tmp/bankapi'

def respond(result=None, error=None, httperrorcode=None):
    global pg_conn

    if result is not None:
        data =  """Status: 200 OK
Content-Type: text/plain

""" + result
    else:
        if httperrorcode is None:
            httperrorcode = 500
        if error is None:
            error = 'Unknown error'

        data = "Status: %s %s" % (httperrorcode, error)

    print data
    debug_request('out', data)

    if pg_conn is not None:
        pg_conn.close()

    sys.exit(0)

def error_log(s):
    sys.stderr.write("%s\n" % (s))

def debug_request(extension, data):
    global debug_incoming_data
    global debug_path

    if debug_incoming_data == True:
        td = datetime.datetime.today()
        path = debug_path + '/' + td.strftime('%Y%m%d')
        filename = path + '/' + td.isoformat()

        if not os.path.exists(path):
            os.makedirs(path)

        fh = open(filename + '.' + extension, 'w')
        fh.write(data)

try:
    pg_conn = psycopg2.connect(pg_connect_str)
except psycopg2.Error as e:
    error_log("Failed to connect to database: error=%s, code=%s" % (e.pgerror, e.pgcode))
    respond(error='Failed to connect to database', httperrorcode=500)

try:
    indata = sys.stdin.read().strip()
except Exception as e:
    respond(error='Failed to decode input data', httperrorcode=400)

if indata is None or len(indata) == 0:
    respond(error='No data', httperrorcode=400)

debug_request('in', indata)

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

sys.exit(0)
