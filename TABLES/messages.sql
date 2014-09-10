CREATE TYPE messagestate AS ENUM ('SENDING','SENT','UNPROCESSED', 'PROCESSING', 'PROCESSED', 'ERROR');

CREATE TABLE Messages (
MessageID text not null,
MessageType text not null,
FileID text not null,
FromBankID text not null,
ToBankID text not null,
Cipherdata bytea not null,
DeliveryReceipt bytea,
Datestamp timestamptz not null default now(),
Delivered timestamptz,
MessageState messagestate not null,
PRIMARY KEY (MessageID),
FOREIGN KEY (FileID) REFERENCES Files(FileID)
);
