ALTER TABLE ONLY banks
    ADD CONSTRAINT banks_publickeyid_fkey FOREIGN KEY (PublicKeyID) REFERENCES Keys(KeyID);
