CREATE EXTENSION pgcrypto;
CREATE EXTENSION pgcrypto_signatures;

\i TABLES/banks.sql
\i TABLES/keys.sql
\i TABLES/files.sql
\i TABLES/messages.sql

\i FK_CONSTRAINTS/keys_bankid_fkey.sql
\i FK_CONSTRAINTS/messages_fileid_fkey.sql

\i FUNCTIONS/encrypt_sign.sql
\i FUNCTIONS/decrypt_verify.sql
\i FUNCTIONS/create_message.sql
\i FUNCTIONS/get_message.sql
\i FUNCTIONS/receive_message.sql
\i FUNCTIONS/read_message.sql
\i FUNCTIONS/decode_delivery_receipt.sql
