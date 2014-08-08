CREATE OR REPLACE FUNCTION Register_Public_Keyring(_BankID text, _PublicKeyring text) RETURNS BOOLEAN AS $BODY$
DECLARE
_MainKeyID text;
_Dearmored bytea;
_SubKeyID text;
_OK boolean;
BEGIN

_Dearmored := dearmor(_PublicKeyring);
_MainKeyID := pgp_main_key_id(_Dearmored);
_SubKeyID  := pgp_key_id(_Dearmored);

IF EXISTS (SELECT 1 FROM Keys WHERE MainKeyID = _MainKeyID AND SubKeyID = _SubKeyID AND BankID = _BankID) THEN
    UPDATE Keys SET PublicKeyring = _Dearmored
    WHERE MainKeyID = _MainKeyID AND SubKeyID = _SubKeyID AND BankID = _BankID
    RETURNING TRUE INTO STRICT _OK;
    RETURN TRUE;
END IF;

INSERT INTO Keys (MainKeyID,  SubKeyID,  PublicKeyring, BankID)
VALUES          (_MainKeyID, _SubKeyID, _Dearmored,    _BankID)
RETURNING TRUE INTO STRICT _OK;

RETURN TRUE;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
