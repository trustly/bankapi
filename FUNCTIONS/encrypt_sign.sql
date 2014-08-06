CREATE OR REPLACE FUNCTION Encrypt_Sign(OUT Cipherdata bytea, _Plaintext text, _EncryptionKeyID text, _SignatureKeyID text) RETURNS bytea AS $BODY$
SELECT pgp_pub_encrypt_sign_bytea(
    convert_to($1,'UTF8'),
    EncryptionKey.PublicKeyring,
    SignatureKey.SecretKeyring
) 
FROM Keys AS EncryptionKey,
     Keys AS SignatureKey
WHERE EncryptionKey.SubKeyID = $2
AND   SignatureKey.MainKeyID = $3
$BODY$ LANGUAGE sql VOLATILE;
