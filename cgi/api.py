#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json
import psycopg2
import psycopg2.extras
import re

pg_connect_str = "dbname=bankapi user=bankapi"
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

    if method in ('encrypt_sign_message', 'decrypt_verify_message'):
        sqldata = None
        try:
            if method == 'encrypt_sign_message':
                verify_params(params, ['frombankid', 'tobankid', 'message'])
                cur.execute('SELECT encryptedsignedmessage FROM encrypt_sign_message(%s, %s, %s)',
                        [params['frombankid'], params['tobankid'], params['message']])
            elif method == 'decrypt_verify_message':
                verify_params(params, ['message'])
                cur.execute('SELECT frombankid, tobankid, message FROM decrypt_verify_message(%s)',
                        [params['message']])

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
                respond(error='Call failed')
        except psycopg2.ProgrammingError as e:
            pg_conn.rollback()
            respond(error='Call failed')
    else:
        respond(error='Invalid method')

sys.exit(0)
