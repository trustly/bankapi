CREATE OR REPLACE FUNCTION Receive_Message(OUT DeliveryReceipt text, _Ciphertext text) RETURNS TEXT AS $BODY$
DECLARE
_Cipherdata bytea;
_MessageID text;
_MessageType text;
_EncryptionKeyID text;
_SignatureKeyID text;
_Plaintext text;
_DeliveryReceipt bytea;
_SecretKey bytea;
_PublicKey bytea;
_MessageData bytea;
_OK boolean;
_FromBankID text;
_ToBankID text;
_Message text;
_FileID text;
BEGIN

_Cipherdata := dearmor(_Ciphertext);
_MessageType := COALESCE(pgp_armor_header(_Ciphertext,'Comment'),'text/plain');

_MessageID := encode(digest(_Cipherdata, 'sha512'),'hex');

SELECT EncryptionKeyID,  SignatureKeyID,  Plaintext
INTO  _EncryptionKeyID, _SignatureKeyID, _Plaintext
FROM Decrypt_Verify(_Cipherdata);

SELECT BankID INTO STRICT _FromBankID FROM Keys WHERE MainKeyID = _SignatureKeyID;
SELECT BankID INTO STRICT _ToBankID   FROM Keys WHERE SubKeyID  = _EncryptionKeyID;

_FileID := encode(digest(_Plaintext, 'sha512'),'hex');

IF NOT EXISTS (SELECT 1 FROM Files WHERE FileID = _FileID) THEN
    INSERT INTO Files (FileID, Plaintext) VALUES (_FileID, _Plaintext) RETURNING TRUE INTO STRICT _OK;
END IF;

SELECT Messages.DeliveryReceipt INTO _DeliveryReceipt FROM Messages WHERE MessageID = _MessageID;
IF NOT FOUND THEN
    INSERT INTO Messages ( MessageID,  MessageType,  FileID,  FromBankID,  ToBankID,  Cipherdata)
    VALUES               (_MessageID, _MessageType, _FileID, _FromBankID, _ToBankID, _Cipherdata)
    RETURNING TRUE INTO STRICT _OK;
END IF;
IF _DeliveryReceipt IS NULL THEN
    _DeliveryReceipt := Encrypt_Sign(
        _Plaintext       := _FileID,
        _EncryptionKeyID := FromBankKey.SubKeyID,
        _SignatureKeyID  := ToBankKey.MainKeyID
    ) FROM Keys AS FromBankKey,
           Keys AS ToBankKey
    WHERE FromBankKey.BankID     = _FromBankID
    AND   FromBankKey.PrimaryKey IS TRUE
    AND   ToBankKey.BankID       = _ToBankID
    AND   ToBankKey.PrimaryKey   IS TRUE;
    IF _DeliveryReceipt IS NULL THEN
        RAISE EXCEPTION 'ERROR_ENCRYPT_SIGN_FAILED FileID % EncryptionKeyID % SignatureKeyID %', _FileID, _SignatureKeyID, _EncryptionKeyID;
    END IF;
    UPDATE Messages SET DeliveryReceipt = _DeliveryReceipt, Delivered = now() WHERE Messages.MessageID = _MessageID AND Messages.DeliveryReceipt IS NULL AND Messages.Delivered IS NULL RETURNING TRUE INTO STRICT _OK;
END IF;

DeliveryReceipt := armor(_DeliveryReceipt);
RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
