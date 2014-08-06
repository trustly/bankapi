CREATE TABLE Files (
FileID text not null,
Plaintext text not null,
Datestamp timestamptz not null default now(),
PRIMARY KEY (FileID)
);
