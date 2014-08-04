CREATE OR REPLACE FUNCTION decrypt_verify_message(OUT FromBankID text, OUT ToBankID text, OUT Message text, _EncryptedSignedMessage text) RETURNS RECORD AS $BODY$
DECLARE
_SecretKey bytea;
_PublicKey bytea;
_MessageData bytea;
_MessageID bytea;
_OK boolean;
BEGIN

_MessageData := dearmor(_EncryptedSignedMessage);

_MessageID := digest(_MessageData, 'sha512');

SELECT
    Keys.Key,
    Banks.BankID
INTO
    _SecretKey,
    Decrypt_Verify_Message.ToBankID
FROM Keys
INNER JOIN Banks ON (Banks.SecretKeyID = Keys.KeyID)
WHERE Keys.KeyID = pgp_key_id(_MessageData);
IF NOT FOUND THEN
    RAISE EXCEPTION 'ERROR_SECRET_KEY_NOT_FOUND KeyID %', pgp_key_id(_MessageData);
END IF;

SELECT
    Keys.Key,
    Banks.BankID
INTO
    _PublicKey,
    Decrypt_Verify_Message.FromBankID
FROM pgp_pub_signature_keys(_MessageData, _SecretKey)
INNER JOIN Keys ON (Keys.KeyID = pgp_pub_signature_keys.KeyID)
INNER JOIN Banks ON (Banks.PublicKeyID = Keys.KeyID)
WHERE pgp_pub_signature_keys.Digest = 'sha512';

Message := convert_from(pgp_pub_decrypt_verify_bytea(_MessageData, _SecretKey, _PublicKey),'UTF8');

IF NOT EXISTS (
    SELECT 1 FROM Messages
    WHERE Messages.MessageID = _MessageID
    AND Messages.FromBankID  = Decrypt_Verify_Message.FromBankID
    AND Messages.ToBankID    = Decrypt_Verify_Message.ToBankID
) THEN
    INSERT INTO Messages ( MessageID,  FromBankID,  ToBankID,  MessageData)
    VALUES               (_MessageID,  FromBankID,  ToBankID, _MessageData)
    RETURNING TRUE INTO STRICT _OK;
END IF;

RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
