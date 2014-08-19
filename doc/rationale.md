## Why?

All banks currently communicate with each other over the SWIFT network.
The message types sent over SWIFT will probably remain the same for a long time, such as FIN MT-files or FileAct ISO20022 XML-files.
Many banks depend on legacy systems and cannot easily change the file formats they use to communicate with each other.

SWIFT is a centralized system, which basically is a gigantic mailserver in which each bank has a mail account with a mail address, a so called BIC, such as "TRLYSESSXXX".
SWIFT is highly secure and guarantees the plaintext data you send over the network won't be read by anyone else than potentially SWIFT themselves,
and also guarantees the message a bank receives originates from the bank who claims to have sent the message.

We take for granted emails are free of charge. But SWIFT messages are not free of charge, which is perfectly understandable, as it's a centralized system, and they must make money to keep the platform up and running.
Compare this with for instance the email protocol SMTP, which is by its design decentralized, meaning there is no single giant mailserver in the middle responsible for delivering all emails between its users. There are some really big ones though, like Gmail.

The fees charged by SWIFT was the main reason why this project took off in the first place.
We wanted a way to communicate with other banks in a more efficient way without any fees to do something as simple as sending a message from A to B.

The decentralized design of BankAPI protocol ensures noone controls it, noone owns it, noone can shut it down, just like the Internet.
The un-innovative design of BankAPI protocol ensures noone can critizise it, as there is nothing new invented, it's just a combination of existing well proven technologies.

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
That also means Bank B will be able to prove all messages sent over the Internet from bank A really comes from bank A.

The more banks that exchange public keys, the stronger will a potential "web of trust" be where each bank would sign the other banks public keys,
allowing others to trust an unknown bank's public key because it has been signed by multiple other banks, which public keys can be found on their websites.

But before you have a lot of banks who have migrated to this new way of communicating, SWIFT is an excellent way of doing the exchange of public keys.
It's excellent because all banks already know how to send each other manual text messages via SWIFT, so they can just copy/paste the ASCII armored public keyring in the SWIFT terminal and send it, probably in a FIN MT999, which is a SWIFT message type which allows free text messages.

The exchange of public keys via SWIFT could also be automated, but we can worry about that when the number of BankAPI banks reach a sufficiently high number to motivate automating the task.
