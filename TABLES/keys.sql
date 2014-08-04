CREATE TABLE Keys (
KeyID text not null,
Key bytea not null,
Datestamp timestamptz not null default now(),
PRIMARY KEY (KeyID)
);
