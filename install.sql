CREATE EXTENSION pgcrypto_openpgp;

\i TABLES/banks.sql
\i TABLES/keys.sql
\i TABLES/files.sql
\i TABLES/messages.sql

\i FUNCTIONS/encrypt_sign.sql
\i FUNCTIONS/decrypt_verify.sql
\i FUNCTIONS/create_message.sql
\i FUNCTIONS/get_message.sql
\i FUNCTIONS/get_bank.sql
\i FUNCTIONS/receive_message.sql
\i FUNCTIONS/read_message.sql
\i FUNCTIONS/decrypt_message.sql
\i FUNCTIONS/decode_delivery_receipt.sql
\i FUNCTIONS/list_messages.sql
\i FUNCTIONS/register_bank.sql
\i FUNCTIONS/register_public_keyring.sql
\i FUNCTIONS/register_secret_keyring.sql
\i FUNCTIONS/get_next_unprocessed_message.sql
\i FUNCTIONS/update_message_state.sql
