CREATE OR REPLACE FUNCTION Register_Secret_Keyring(_BankID text, _SecretKeyring text) RETURNS BOOLEAN AS $BODY$
DECLARE
_MainKeyID text;
_Dearmored bytea;
_SubKeyID text;
_OK boolean;
BEGIN

_Dearmored := dearmor(_SecretKeyring);
_MainKeyID := pgp_main_key_id(_Dearmored);
_SubKeyID  := pgp_key_id(_Dearmored);

UPDATE Keys SET SecretKeyring = _Dearmored
WHERE MainKeyID = _MainKeyID AND SubKeyID = _SubKeyID AND BankID = _BankID
RETURNING TRUE INTO STRICT _OK;

RETURN TRUE;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
