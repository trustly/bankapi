CREATE OR REPLACE FUNCTION encrypt_sign_message(OUT EncryptedSignedMessage text, _FromBankID text, _ToBankID text, _Message text) RETURNS TEXT AS $BODY$
DECLARE
_SecretKey bytea;
_PublicKey bytea;
_MessageData bytea;
_MessageID bytea;
_OK boolean;
BEGIN
SELECT Keys.Key INTO _SecretKey FROM Banks INNER JOIN Keys ON (Keys.KeyID = Banks.SecretKeyID) WHERE Banks.BankID = _FromBankID;
IF NOT FOUND THEN
    RAISE EXCEPTION 'ERROR_SECRET_KEY_NOT_FOUND BankID %', _FromBankID;
END IF;
SELECT Keys.Key INTO _PublicKey FROM Banks INNER JOIN Keys ON (Keys.KeyID = Banks.PublicKeyID) WHERE Banks.BankID = _ToBankID;
IF NOT FOUND THEN
    RAISE EXCEPTION 'ERROR_PUBLIC_KEY_NOT_FOUND KeyID %', _ToBankID;
END IF;

_MessageData := pgp_pub_encrypt_sign_bytea(
    convert_to(_Message,'UTF8'), -- Converts the _Message input parameter from UTF8 text into bytea
    _PublicKey, -- The recipient bank's pubic key used to encrypt the message
    _SecretKey  -- Our own secret key used to sign the message
);

_MessageID := digest(_MessageData, 'sha512');

INSERT INTO Messages ( MessageID,  FromBankID,  ToBankID,  MessageData)
VALUES               (_MessageID, _FromBankID, _ToBankID, _MessageData)
RETURNING TRUE INTO STRICT _OK;

EncryptedSignedMessage := armor(_MessageData);
RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
