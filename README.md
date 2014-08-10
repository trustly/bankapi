# bankapi

## What is it?

BankAPI is a secure decentralized messaging system to send files/messages between banks and other types of financial institutions.

There is a reference implementation of the protocol which can be used off-the-shelf, which is production grade quality and is not only for testing and demonstration, although it fulfils those two roles as well.

The BankAPI protocol relies on OpenPGP (RFC 4880) + SHA512 + HTTPS. That's it.
There is nothing more to it, as we have enough of standards already, let's not invent any new building blocks, let's just put together the building blocks we already have and create something useful.

BankAPI is a transportation layer protocol, and makes no assumptions of what kind of messages or file types banks will want to exchange with each other.

## Intended audience

For any of this to make sense, you have to be a bank or a financial institution and understand how messages are sent today between banks.

In this text, to save space, the word "bank" will be used to refer to both banks and financial institutions.

## Why?

All banks currently communicate with each other the one and only SWIFT network.
The message types sent over SWIFT will probably remain the same for a long time, such as FIN MT-files or FileAct ISO20022 XML-files.
Many banks depend on legacy systems and cannot easily change the file formats they use to communicate with each other.

SWIFT is a centralized system, which basically is a gigantic mailserver in which each bank has a mail account with a mail address, a so called BIC (Bank Identifier Code), such as "TRLYSESSXXX".
SWIFT is highly secure and guarantees the plaintext data you send over unencrypted over the network won't be read by anyone else than potentially SWIFT themselves,
and also guarantees the message a bank receives originates from the bank who sent the message.

Of all arguments, cost is probably the primary. We take for granted emails are free of charge. But SWIFT messages are not free of charge, which is perfectly understandable, as it's a centralized platform, and the SWIFT company must make money to keep the platform up and running.
The email protocol is by design decentralized, meaning there is no single giant mailserver in the middle responsible for delivering all emails between its users. There are some really big ones though, like Gmail.

The fees charged by SWIFT was the main reason why this project took off in the first place.
We wanted a way to communicate with other banks in a more efficient way without any fees to do something simple as messaging.

The decentralized design of BankAPI protocol ensures noone controls it, noone owns it, noone can shut it down, just like the Internet.
The un-innovative design of BankAPI protocol ensures noone can critizise it, as there is nothing new invented, it's just a combination of existing well prooven technologies.

Imagine if all mail in the world would be sent to a single central SMTP mailserver in Belgium, and from there delivered to the addressee.
That would be horrible from an efficiency perspective.
It would be slower, more costly, and just plain stupid, than the obvious idea, to send the messages as fast and cheap as possible from A to B.
Let's imagine banks would send their messages between each other via the insecure Internet instead of over the secure SWIFT network.
How could B be certain the message sent from A really comes from B? And what if the message is confidential?
We all know the Internet is insecure, data sent can be "sniffed" by all the routers between A and B.
We all know IP-addresses on the Internet can be "spoofed", so how can B really know the message came from A?

At about the same time both Internet and SWIFT was invented more than 40 years ago, another important invention came about the same time, called RSA (public key cryptography).
But RSA is just an algorithm to do encryption/decryption using public/secret keys.
There was still not a widely accepted standard to solve the problem of communicating securely until the OpenPGP standard, defined by RFC 4880, released in 2007.

A good thing with OpenPGP is it doesn't say anything about what you can send in a message.
A message can be a binary file, a text file a message or anything you like to send from A to B.

OpenPGP could even be used to send the types of files exchange between banks.
Many banks are probably still using 7-bit file formats, but even those are supported.

So given we have the Internet and a widely accepted standard to do secure messaging over an insecure network,
could we somehow come up with a drop-in replacement to let banks send their messages between each other over the Internet instead of SWIFT?

The one tricky part is how they would exchange public keys. If they would send them by email, the emails could have been spoofed.
If they would exchange public keys in person by visiting each others bank headquarters, that would be inefficient.

It turns out SWIFT is perfectly suited for the task of exchanging public keys.
If bank A sends their public keys to bank B as a normal SWIFT text message, bank B will know it really comes from A.
Bank B will also be able to later on provide proof to others bank A really did send them that particular public key, as SWIFT messages are archieved.
That also means Bank B will be able to proove all messages sent over the Internet from bank A really comes from bank A.

The more banks that exchange public keys, the stronger will a potential "web of trust" be where each bank would sign the other banks public keys,
allowing others to trust an unknown bank's public key because it has been signed by multiple other banks, which public keys can be found on their websites.

But before you have a lot of banks who have migrated to this new way of communicating, SWIFT is an excellent way of doing the exchange of public keys.
It's excellent because all banks already know how to send each other manual text messages via SWIFT, so they can just copy/paste the ASCII armored public keyring in the SWIFT terminal and send it, probably in a FIN MT999, which is a SWIFT message type which allows free text messages.

The exchange of public keys via SWIFT could also be automated, but we can worry about that when the number of BankAPI banks reach a sufficiently high number to motivate automating the task.

## Key exchange

![layout](https://raw.githubusercontent.com/trustly/bankapi/master/doc/BankAPI%20Key%20Exchange.png)

## Protocol design

![layout](https://raw.githubusercontent.com/trustly/bankapi/master/doc/BankAPI%20Protocol%20Design.png)

## System design

![layout](https://raw.githubusercontent.com/trustly/bankapi/master/doc/BankAPI%20System%20Design.png)

BankAPI is a OpenPGP compliant secure decentralized messaging system.

The system is built on top of PostgreSQL and uses its pgcrypto contrib module.

Messages are encrypted and signed using RSA public key cryptography.

Each bank generates a RSA key-pair consisting of a public and a secret key.

The public keys and API URLs are exchanged between the banks.

The task of exchanging public keys and API URLs is preferrably done over the
SWIFT network, by sending them in a normal MT999 SWIFT FIN-message.  This
allows banks to trust the validity of the public key and API URL, as the origin
of SWIFT messages can be trusted.

## Highlights

- RSA-encryption
- SHA512
- JSON-RPC / HTTPS
- Linux / PostgreSQL / Apache
- Open source / MIT-license
- Real-time request/response
- Instant delivery receipt
- Local archiving of files in PostgreSQL

## Overview of the interface

To send a message, the sending bank encrypts and signs a message using
Create\_Message(), and calls Get\_Message() to get the actual ciphertext
content of the message.  The ciphertext is then delivered to the receiving bank
by calling its Receive\_Message() API method, accessible at the API URL
provided by the receiving bank.  The API implementation must adhere to the
JSON-RPC standard and accept HTTPS POST.

The Receive\_Message() function returns a _delivery receipt_, which is a
cryptographic proof of the fact that the sender was able to verify the
signature contained within the message against the receiving bank's public key.
This allows the sender to be certain that the message was delivered and
decrypted successfully by the recipient.

The sending bank calls Decode\_Delivery\_Receipt() with the _delivery receipt_
as input to verify its validity.

## Database tables and columns

### Banks
- BankID : Unique identifier for the bank, preferrably the SWIFT BIC (PRIMARY KEY)
- Protocol : API procotol, example "https"
- Host : API host, Internet domain name, example "bank.com"
- Port : API port, Internet network port, example 443
- Path : API path, example "/api"
- Datestamp : Date/time when added to the table

### Files
- FileID : SHA512 hash of the Plaintext (PRIMARY KEY)
- Plaintext : The content of the file (UTF8)
- Datestamp : Date/time when added to the table

### Keys
- MainKeyID : Signature key (PRIMARY KEY)
- SubKeyID : Encryption key
- PublicKeyring : Contains public keys
- SecretKeyring : Contains secret keys (only set for your own bank, NULL for others)
- BankID : The BankID which the keys belong to
- Datestamp : Date/time when added to the table
- PrimaryKey : Only set to TRUE for one row per BankID, other keys are still valid, but this key is used when creating new messages

### Messages
- MessageID : SHA512 hash of the Cipherdata (PRIMARY KEY)
- FileID : The hash of the file send in the message
- FromBankID : The bank who sent the message
- ToBankID : The bank who received the message
- Cipherdata : The encrypted and signed message
- DeliveryReceipt : The encrypted and signed delivery receipt
- Datestamp : The date/time when the message was created
- Delivered : The date/time when the message was delivered

## Database functions

### Create\_Message(Plaintext, FromBankID, ToBankID)

Create\_Message() takes the plaintext context of a file as input and prepares
an encrypted _message_ signed by **FromBankID** which can be only decrypted by
**ToBankID**.  If the _message_ already exists, the existing data is reused.
An error is returned if the _secret key_ of **FromBankID** or the _public key_
of **ToBankID** can not be located in the database.

The return value is the _message id_ of the message.

### Get\_Message(MessageID)

Given a _message id_ as input, Get\_Message() returns the ASCII armored PGP
message.  This data can then be HTTPS POSTed to the Receive\_Message API method
of **ToBank**.

### Receive\_Message(Ciphertext text)

Receive\_Message() decrypts and verifies the signature of the input _message_.
The message's details are written to the _Messages_ table, and information
about the file and its plaintext contents are written into the _Files_ table.
This function will raise an error if:

1. The _secret key_ counterpart of the _public key_ used to encrypt the
message is not present in the table _Keys_.

2. The _public key_ counterpart of the _secret key_ used to sign the message
is not present in the table _Keys_.

3. The message is corrupt or the signature can not be verified.

The return value is a _delivery receipt_, which should be then used as the
contents of the response to the caller of the Receive\_Message API method.

### Decode\_Delivery\_Receipt(DeliveryReceipt text)

Decode\_Delivery\_Receipt() decrypts and verifies the given _delivery receipt_,
where the keys involved and the plaintext should match a row in Messages.  If
so, the Message has been successfully delivered, and the
Messages.DeliveryReceipt and Messages.Delivered columns are set.

## Installing and building .deb packages for installation

The repository includes scripts for building debian/ubuntu packages for the
bankapi and the required pgcrypto extensions (in PostgreSQL) in order to run
the code.

If you are running a different version of PostgreSQL then 9.3 then replace the
version in the commands below with the appropriate version. If you are running
the default version in Debian you can omit the version extension of the
packages names.

- sudo apt-get -y build-dep postgresql-9.3
- sudo apt-get -y install postgresql-server-dev-9.3
- make

This should produce two deb files, one for bankapi and one for the pgcrypto
extension.

### bankapi-0.1.deb

Package contains the command line tools for sending messages
(/usr/bin/bankapi), SQL needed for creating the bankapi in postgres and
installes a CGI as an endpoint for receving incoming communication messages.

The installation of the module installs and activates the CGI script. It will
be available under http://localhost/bankapi .

The installation does not finish the installation of the database but leaves
this as a manual task. Follow the following steps for a default database
installation:

- cd /usr/share/bankapi
- sudo -u postgres createdb bankapi
- sudo -u postgres psql --dbname=bankapi --single-transaction --no-psqlrc --file=install.sql
- Make sure www-data user can connect to the bankapi database, this can for
  instance be done by adding the following line where appropriate in the active
  pg\_hba.conf file: local www-data bankapi peer
- To optionally install the test bank data: sudo -u postgres psql --dbname=bankapi --single-transaction --no-psqlrc --file=testdata/index.sql

### postgresql-pgcrypto-signatures-9.3.deb

This is an extension to the pgcrypto PostgreSQL extension. The extension only
installs with the extended functions, all functions normally in pgcrypto is
still accessed from the standard pgcrypto extension. The extension is called
pgcrypto\_signatures.
