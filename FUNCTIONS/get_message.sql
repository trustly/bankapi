CREATE OR REPLACE FUNCTION Get_Message(OUT Ciphertext text, _MessageID text) RETURNS TEXT AS $BODY$
SELECT armor(Cipherdata) FROM Messages WHERE MessageID = $1
$BODY$ LANGUAGE sql VOLATILE;
