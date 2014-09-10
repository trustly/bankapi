CREATE OR REPLACE FUNCTION Update_Message_Processing_State(_MessageID text, _FromState processingstate, _ToState processingstate) RETURNS BOOLEAN
SET search_path TO public, pg_temp
AS $BODY$
DECLARE
_OK boolean;
BEGIN
UPDATE Messages SET ProcessingState = _ToState WHERE MessageID = _MessageID AND ProcessingState = _FromState RETURNING TRUE INTO STRICT _OK;
RETURN TRUE;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
