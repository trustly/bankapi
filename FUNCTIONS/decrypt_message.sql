CREATE OR REPLACE FUNCTION Decrypt_Message(OUT Plaintext text, OUT FromBankID text, OUT ToBankID text, OUT CreationTime timestamptz, _MessageID text) RETURNS RECORD AS $BODY$
SELECT
    Decrypt_Verify.Plaintext,
    FromBankKey.BankID,
    ToBankKey.BankID,
    Decrypt_Verify.CreationTime
FROM Decrypt_Verify(dearmor(Get_Message($1))), Keys AS FromBankKey, Keys AS ToBankKey
WHERE FromBankKey.MainKeyID = Decrypt_Verify.SignatureKeyID
AND   ToBankKey.SubKeyID    = Decrypt_Verify.EncryptionKeyID
$BODY$ LANGUAGE sql VOLATILE;
