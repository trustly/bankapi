CREATE OR REPLACE FUNCTION Decode_Delivery_Receipt(OUT FileID text, OUT FromBankID text, OUT ToBankID text, _DeliveryReceipt text) RETURNS RECORD AS $BODY$
UPDATE Messages SET DeliveryReceipt = COALESCE(DeliveryReceipt,dearmor($1)), Delivered = COALESCE(Delivered,now())
FROM Decrypt_Verify(dearmor($1)),
Keys AS FromBankKey,
Keys AS ToBankKey
WHERE FromBankKey.SubKeyID = Decrypt_Verify.EncryptionKeyID
AND ToBankKey.MainKeyID    = Decrypt_Verify.SignatureKeyID
AND Messages.FromBankID    = FromBankKey.BankID
AND Messages.ToBankID      = ToBankKey.BankID
AND Messages.FileID        = Decrypt_Verify.Plaintext
RETURNING
Decrypt_Verify.Plaintext,
FromBankKey.BankID,
ToBankKey.BankID
$BODY$ LANGUAGE sql VOLATILE;
