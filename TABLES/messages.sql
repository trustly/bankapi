CREATE TABLE Messages (
MessageID bytea not null,
FromBankID text not null,
ToBankID text not null,
MessageData bytea not null,
Datestamp timestamptz not null default now(),
PRIMARY KEY (MessageID, FromBankID, ToBankID)
);
