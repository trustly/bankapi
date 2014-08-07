ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_fileid_fkey FOREIGN KEY (FileID) REFERENCES Files(FileID);
