CREATE OR REPLACE FUNCTION Update_Message_State(_MessageID text, _FromState messagestate, _ToState messagestate) RETURNS BOOLEAN
SET search_path TO public, pg_temp
AS $BODY$
DECLARE
_OK boolean;
BEGIN
UPDATE Messages SET MessageState = _ToState WHERE MessageID = _MessageID AND MessageState = _FromState RETURNING TRUE INTO STRICT _OK;
RETURN TRUE;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
