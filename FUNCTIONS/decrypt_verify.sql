CREATE OR REPLACE FUNCTION Decrypt_Verify(OUT EncryptionKeyID text, OUT SignatureKeyID text, OUT Plaintext text, _Cipherdata bytea) RETURNS RECORD AS $BODY$
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
    )
FROM Keys AS EncryptionKey,
     Keys AS SignatureKey
WHERE EncryptionKey.SubKeyID = pgp_key_id($1)
AND   SignatureKey.MainKeyID = (SELECT KeyID FROM pgp_pub_signature_keys($1, EncryptionKey.SecretKeyring))
$BODY$ LANGUAGE sql VOLATILE;
