CREATE OR REPLACE FUNCTION List_Messages(
OUT Datestamp timestamptz,
OUT MessageID char(10),
OUT MessageType text,
OUT MessageState messagestate,
OUT FromBankID text,
OUT ToBankID text,
_MessageState messagestate DEFAULT NULL,
_MessageType text DEFAULT NULL,
_FromBankID text DEFAULT NULL,
_ToBankID text DEFAULT NULL
) RETURNS SETOF RECORD
SET search_path TO public, pg_temp
AS $BODY$
SELECT
    Datestamp::timestamptz(0),
    MessageID::char(10),
    MessageType,
    MessageState,
    FromBankID,
    ToBankID
FROM Messages
WHERE ($1 IS NULL OR MessageState = $1)
AND   ($2 IS NULL OR MessageType  = $2)
AND   ($3 IS NULL OR FromBankID   = $3)
AND   ($4 IS NULL OR ToBankID     = $4)
ORDER BY Datestamp
$BODY$ LANGUAGE sql VOLATILE SECURITY DEFINER;
