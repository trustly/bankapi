CREATE OR REPLACE FUNCTION Read_Message(OUT Plaintext text, OUT FromBankID text, OUT ToBankID text, _MessageID text) RETURNS RECORD AS $BODY$
DECLARE
BEGIN
EXECUTE '
SELECT
    Files.Plaintext,
    Messages.FromBankID,
    Messages.ToBankID
FROM Messages
INNER JOIN Files ON (Files.FileID = Messages.FileID)
WHERE Messages.MessageID LIKE $1' INTO STRICT Plaintext, FromBankID, ToBankID USING (_MessageID || '%');
RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
