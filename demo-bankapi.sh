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
# /var/www/bankapi/bankapi.py to point to the TESTBANK002 database (dbname=TESTBANK002)
echo "Sending message using bankapi"
echo 'This is another secret message from TESTBANK001 to TESTBANK002' | \
    /usr/bin/bankapi send -d TESTBANK001 TESTBANK001 TESTBANK002 text/plain -



# List the messages present in both databases. The information in the two
# databases should really be the same as we update and keep all the message
# information in sync between the two. 
echo "List messages in the system of TESTBANK001"
/usr/bin/bankapi list -d TESTBANK001

echo "List messages in the system of TESTBANK002"
/usr/bin/bankapi list -d TESTBANK002

echo "The two lists of messages should be identical (apart from minor differences in timestamps)"


# Now fetch the last message in the list from TESTBANK002 database and display it using read
messagerow=$(/usr/bin/bankapi list -d TESTBANK002 | tail -n2 | head -n1)
echo "Displaying the last message in TESTBANK002: $messagerow"
messageid=$(echo "$messagerow" | cut -c21-30)
/usr/bin/bankapi read "$messageid"
