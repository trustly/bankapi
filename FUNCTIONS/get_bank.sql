CREATE OR REPLACE FUNCTION Get_Bank(OUT Protocol text, OUT Host text, OUT Port integer, OUT Path text, _BankID text) RETURNS RECORD
SET search_path TO public, pg_temp
AS $BODY$
SELECT Banks.Protocol, Banks.Host, Banks.Port, Banks.Path FROM Banks WHERE Banks.BankID = $1
$BODY$ LANGUAGE sql STABLE SECURITY DEFINER;
