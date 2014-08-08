CREATE OR REPLACE FUNCTION Get_Message(OUT Ciphertext text, _MessageID text) RETURNS TEXT AS $BODY$
DECLARE
BEGIN
EXECUTE 'SELECT armor(Cipherdata) FROM Messages WHERE MessageID LIKE $1' INTO STRICT Ciphertext USING (_MessageID || '%');
RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;

