CREATE OR REPLACE FUNCTION List_Messages(
OUT Datestamp timestamptz,
OUT MessageID char(10),
OUT MessageType text,
OUT FromBankID text,
OUT ToBankID text,
OUT ProcessingState processsingtate,
_ProcessingState processsingtate DEFAULT NULL,
_MessageType text DEFAULT NULL,
_FromBankID text DEFAULT NULL,
_ToBankID text DEFAULT NULL
) RETURNS SETOF RECORD AS $BODY$
SELECT
    Datestamp::timestamptz(0),
    MessageID::char(10),
    MessageType,
    FromBankID,
    ToBankID,
    ProcessingState
FROM Messages
WHERE ($1 IS NULL OR ProcessingState = $1)
AND   ($2 IS NULL OR MessageType     = $2)
AND   ($3 IS NULL OR FromBankID      = $3)
AND   ($4 IS NULL OR ToBankID        = $4)
ORDER BY Datestamp
$BODY$ LANGUAGE sql VOLATILE;
