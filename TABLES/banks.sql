CREATE TABLE Banks (
BankID text not null,
PublicKeyID text not null,
SecretKeyID text not null,
Protocol text not null,
Host text not null,
Port integer not null,
Path text not null,
Datestamp timestamptz not null default now(),
PRIMARY KEY (BankID),
FOREIGN KEY (PublicKeyID) REFERENCES Keys(KeyID),
UNIQUE(PublicKeyID),
UNIQUE(SecretKeyID)
);
