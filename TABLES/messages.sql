CREATE TABLE Messages (
MessageID text not null,
FileID text not null,
FromBankID text not null,
ToBankID text not null,
Cipherdata bytea not null,
DeliveryReceipt bytea,
Datestamp timestamptz not null default now(),
Delivered timestamptz,
PRIMARY KEY (MessageID)
);
