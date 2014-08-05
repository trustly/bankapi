#!/bin/bash
sudo apt-get -y build-dep postgresql postgresql-9.3
sudo apt-get -y install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 postgresql-server-dev-9.3
git clone https://github.com/johto/postgres.git
cd postgres/contrib/pgcrypto
touch pgcrypto--1.1--1.2.sql
USE_PGXS=1 make
sudo env USE_PGXS=1 make install

psql -c "CREATE EXTENSION pgcrypto"

psql -f TABLES/keys.sql
psql -f TABLES/banks.sql
psql -f TABLES/messages.sql

psql -f FUNCTIONS/encrypt_sign_message.sql
psql -f FUNCTIONS/decrypt_verify_message.sql

psql -f TESTBANK001.sql
psql -f TESTBANK002.sql
psql -f TESTBANK003.sql

ENCRYPTED_MESSAGE=$(psql -P format=unaligned -t -c "SELECT Encrypt_Sign_Message('TESTBANK001','TESTBANK002','Hello world')")

echo $ENCRYPTED_MESSAGE

psql -c "SELECT * FROM Decrypt_Verify_Message('$ENCRYPTED_MESSAGE')"
