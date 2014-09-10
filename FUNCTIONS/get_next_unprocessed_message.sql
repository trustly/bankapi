CREATE OR REPLACE FUNCTION Get_Next_Unprocessed_Message(
    OUT Datestamp timestamptz,
    OUT MessageID char(10),
    OUT Plaintext text,
    INOUT MessageType text DEFAULT NULL,
    INOUT FromBankID text DEFAULT NULL,
    INOUT ToBankID text DEFAULT NULL
) RETURNS RECORD
SET search_path TO public, pg_temp
AS $BODY$
DECLARE
_OK boolean;
BEGIN
SELECT
    Messages.Datestamp,
    Messages.MessageID,
    Messages.MessageType,
    Messages.FromBankID,
    Messages.ToBankID,
    Files.Plaintext
INTO
    Datestamp,
    MessageID,
    MessageType,
    FromBankID,
    ToBankID,
    Plaintext
FROM Messages
INNER JOIN Files ON (Files.FileID = Messages.FileID)
WHERE Messages.MessageState = 'UNPROCESSED'
AND (Get_Next_Unprocessed_Message.MessageType IS NULL OR Messages.MessageType = Get_Next_Unprocessed_Message.MessageType)
AND (Get_Next_Unprocessed_Message.FromBankID  IS NULL OR Messages.FromBankID  = Get_Next_Unprocessed_Message.FromBankID)
AND (Get_Next_Unprocessed_Message.ToBankID    IS NULL OR Messages.ToBankID    = Get_Next_Unprocessed_Message.ToBankID)
ORDER BY Messages.Datestamp
LIMIT 1
FOR UPDATE OF Messages;
IF NOT FOUND THEN
    RETURN;
END IF;
UPDATE Messages SET MessageState = 'PROCESSING'
WHERE Messages.MessageID = Get_Next_Unprocessed_Message.MessageID
AND Messages.MessageState = 'UNPROCESSED'
RETURNING TRUE INTO STRICT _OK;
RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
