#!/bin/bash
set -e

# This script is based upon the databases configurd in demo.sh script. 
#
# Deliver a message from TESTBANK001 to TESTBANK002 using sendbankmessage. 
# In order for this to work it requires that there is a web server listening
# accepting incoming connections on http://localhost/bankapi that is connected
# to the database for TESTBANK002 here. It also requires that TESTBANK001
# database is initialized as in demo.sh
#
# Install the debian packages for bankapi to get the cgi listening, then modify
# /var/www/bankapi/api.py to point to the TESTBANK002 database (dbname=TESTBANK002)
echo "Sending message using sendmessage"
echo 'This is another secret message from TESTBANK001 to TESTBANK002' | \
    /usr/bin/sendbankmessage -d TESTBANK001 TESTBANK001 TESTBANK002

