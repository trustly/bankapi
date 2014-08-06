#!/bin/bash
sudo apt-get -y build-dep postgresql postgresql-9.3
sudo apt-get -y install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 postgresql-server-dev-9.3
git clone https://github.com/johto/postgres.git
cd postgres/contrib/pgcrypto
git checkout pgcrypto_signatures
USE_PGXS=1 make
sudo env USE_PGXS=1 make install

psql -X -f install.sql
