CREATE OR REPLACE FUNCTION List_Messages(OUT Datestamp timestamptz, OUT MessageID char(10), OUT MessageType text, OUT FromBankID text, OUT ToBankID text) RETURNS SETOF RECORD AS $BODY$
SELECT
    Datestamp::timestamptz(0),
    MessageID::char(10),
    MessageType,
    FromBankID,
    ToBankID
FROM Messages
ORDER BY Datestamp
$BODY$ LANGUAGE sql VOLATILE;
