CREATE OR REPLACE FUNCTION Decrypt_Verify(OUT EncryptionKeyID text, OUT SignatureKeyID text, OUT Plaintext text, OUT CreationTime timestamptz, _Cipherdata bytea) RETURNS RECORD AS $BODY$
SELECT
    EncryptionKey.SubKeyID,
    SignatureKey.MainKeyID,
    convert_from(
        pgp_pub_decrypt_verify_bytea(
            $1,
            EncryptionKey.SecretKeyring,
            SignatureKey.PublicKeyring
        ),
        'UTF8'
    ),
    (SELECT Creation_Time FROM pgp_pub_signatures($1, EncryptionKey.SecretKeyring, '', TRUE))
FROM Keys AS EncryptionKey,
     Keys AS SignatureKey
WHERE EncryptionKey.SubKeyID = pgp_key_id($1)
AND   SignatureKey.MainKeyID = (SELECT KeyID FROM pgp_pub_signatures($1, EncryptionKey.SecretKeyring))
$BODY$ LANGUAGE sql VOLATILE;
