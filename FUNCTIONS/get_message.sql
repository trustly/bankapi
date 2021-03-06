CREATE OR REPLACE FUNCTION Get_Message(OUT Ciphertext text, _MessageID text) RETURNS TEXT
SET search_path TO public, pg_temp
AS $BODY$
DECLARE
BEGIN
EXECUTE $SQL$SELECT armor(Cipherdata,ARRAY['Comment'],ARRAY[MessageType]) FROM Messages WHERE MessageID LIKE $1$SQL$ INTO STRICT Ciphertext USING (_MessageID || '%');
RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

