CREATE OR REPLACE FUNCTION Register_Bank(_BankID text, _Protocol text, _Host text, _Port integer, _Path text) RETURNS BOOLEAN AS $BODY$
INSERT INTO Banks (BankID, Protocol, Host, Port, Path) VALUES ($1, $2, $3, $4, $5) RETURNING TRUE
$BODY$ LANGUAGE sql VOLATILE;
