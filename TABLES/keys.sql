CREATE TABLE Keys (
MainKeyID text not null,
SubKeyID text not null,
PublicKeyring bytea not null,
SecretKeyring bytea,
BankID text not null,
Datestamp timestamptz not null default now(),
PrimaryKey boolean not null default TRUE,
PRIMARY KEY (MainKeyID),
UNIQUE(SubKeyID),
FOREIGN KEY (BankID) REFERENCES Banks(BankID)
);

CREATE UNIQUE INDEX ON Keys(BankID) WHERE PrimaryKey IS TRUE;
