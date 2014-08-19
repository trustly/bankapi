## Web of trust
>In cryptography, a web of trust is a concept used in PGP, GnuPG, and other OpenPGP-compatible systems to establish the authenticity of the binding between a public key and its owner. Its decentralized trust model is an alternative to the centralized trust model of a public key infrastructure (PKI), which relies exclusively on a certificate authority (or a hierarchy of such). As with computer networks, there are many independent webs of trust, and any user (through their identity certificate) can be a part of, and a link between, multiple webs.
(http://en.wikipedia.org/wiki/Web_of_trust)

The more banks that exchange public keys, the stronger will a potential "web of trust" be where each bank would sign the other banks public keys,
allowing others to trust an unknown bank's public key because it has been signed by multiple other banks, which public keys can be found on their websites.

But before you have a lot of banks who have migrated to this new way of communicating, SWIFT is an excellent way of doing the exchange of public keys.
It's excellent because all banks already know how to send each other manual text messages via SWIFT, so they can just copy/paste the ASCII armored public keyring in the SWIFT terminal and send it, probably in a FIN MT999, which is a SWIFT message type which allows free text messages.

The exchange of public keys via SWIFT could also be automated, but we can worry about that when the number of BankAPI banks reach a sufficiently high number to motivate automating the task.
