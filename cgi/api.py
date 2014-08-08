#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json
import psycopg2
import psycopg2.extras
import re

pg_connect_str = "dbname=bankapi"
pg_conn = None

def respond(result=None, error=None):
    global pg_conn

    response = {
            "version": "1.1"
            }

    if result is not None:
        response['result'] = result
    else:
        if error is None:
            error = 'Unknown error'
        response['error'] = error

    print "Content-Type: application/json"
    print ""

    json_str = json.dumps(response)
    print json_str

    if pg_conn is not None:
        pg_conn.close()

    sys.exit(0)

def verify_params(params, keys):
    for key in keys:
        if params.get(key) is None:
            respond(error='Invalid %s' % (key))

try:
    pg_conn = psycopg2.connect(pg_connect_str)
except psycopg2.OperationalError as e:
    respond(error='Failed to connect to database')

try:
    indata = json.loads(sys.stdin.read())
except ValueError as e:
    respond(error='Bad input')
except TypeError as e:
    respond(error='Missing input')
except Exception as e:
    respond(error='Failed to decode input data')

if indata is not None:
    try:
        if str(indata['version']) != '1.1':
            respond(error='Invalid version')
    except KeyError as e:
        respond(error='Missing version')

    method = None
    try:
        method = indata['method']
    except KeyError as e:
        respond(error='Missing method')

    params = None
    try:
        params = indata['params']
    except KeyError as e:
        respond(error='Missing params')

    if type(params) is not dict:
        respond(error='Invalid params')

    cur = pg_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

    if method == 'receive_message':
        sqldata = None
        try:
            verify_params(params, ['ciphertext'])
            cur.execute('SELECT deliveryreceipt FROM receive_message(%s)',
                    [params['ciphertext']])

            sqldata = cur.fetchone()
            pg_conn.commit()
            respond(result=dict(sqldata))
        except KeyError as e:
            pg_conn.rollback()
        except psycopg2.InternalError as e:
            pg_conn.rollback()
            mg = re.match('ERROR:\s+(ERROR_\S+)', e.pgerror)
            if mg is not None:
                respond(error=mg.group(1))
            else:
                respond(error='Receieve processing failed')
        except psycopg2.ProgrammingError as e:
            pg_conn.rollback()
            respond(error='Recieve processing failed')
    else:
        respond(error='Invalid method')

sys.exit(0)
