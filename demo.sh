#!/bin/bash
export PGOPTIONS="-c client_min_messages=ERROR"

# Let's create two databases, one for TESTBANK001 and another for TESTBANK002.
# This will allow us to see exactly what is being written to each one of the databases.

dropdb TESTBANK001
dropdb TESTBANK002
createdb TESTBANK001
createdb TESTBANK002

psql -X -q -o /dev/null -1 -v ON_ERROR_STOP=1 -f install.sql -d TESTBANK001
psql -X -q -o /dev/null -1 -v ON_ERROR_STOP=1 -f install.sql -d TESTBANK002
psql -X -q -o /dev/null -1 -v ON_ERROR_STOP=1 -f test-banks.sql -d TESTBANK001
psql -X -q -o /dev/null -1 -v ON_ERROR_STOP=1 -f test-banks.sql -d TESTBANK002
psql -X -q -o /dev/null -1 -v ON_ERROR_STOP=1 -f test-publickeyrings.sql -d TESTBANK001
psql -X -q -o /dev/null -1 -v ON_ERROR_STOP=1 -f test-publickeyrings.sql -d TESTBANK002
psql -X -q -o /dev/null -1 -v ON_ERROR_STOP=1 -f test-secretkeyring-TESTBANK001.sql -d TESTBANK001
psql -X -q -o /dev/null -1 -v ON_ERROR_STOP=1 -f test-secretkeyring-TESTBANK002.sql -d TESTBANK002

# Use Create_Message() to encrypt/sign a new message.

MessageID=$(psql -P format=unaligned -t -c "
    SELECT MessageID FROM Create_Message(
        _Plaintext  := 'This is a secret message from TESTBANK001 to TESTBANK002',
        _FromBankID := 'TESTBANK001',
        _ToBankID   := 'TESTBANK002'
    );
" -d TESTBANK001)

# A unique MessageID is returned, which is a SHA512 hash of the encrypted/signed
# data stored in Messages.Cipherdata in which table the MessageID is the primary key.
# The Plaintext is written to Files.Plaintext, where the Files.FileID is a SHA512
# hash of the Plaintext and is also the primary key of the same table.

echo "MessageID: '$MessageID'"
echo

# Use Get_Message() to get the Messages.Cipherdata in ASCII armored format.
# This is the data we will transmit to the "to bank" in this case TESTBANK002.

Ciphertext=$(psql -P format=unaligned -t -c "
    SELECT Ciphertext FROM Get_Message(
        _MessageID := '$MessageID'
    );
" -d TESTBANK001)

echo "Ciphertext:"
echo "$Ciphertext"
echo

# The "to bank" receiving the message should make the Receive_Message()
# function accessible via HTTPS POST, allowing the "from bank" to call
# the function with the Ciphertext returned by Get_Message().

DeliveryReceipt=$(psql -P format=unaligned -t -c "
    SELECT DeliveryReceipt FROM Receive_Message(
        _Ciphertext := '$Ciphertext'
    );
" -d TESTBANK002)

echo "DeliveryReceipt:"
echo "$DeliveryReceipt"

# The Receive_Message() returns a DeliveryReceipt which is a proof that
# the "to bank" received the message, and consists of a SHA512 hash
# of the plaintext message, encrypted/signed by the "to bank",
# which allows the "from bank" to decrypt/verify the signature
# of the DeliveryReceipt, to be sure the message was delivered.

echo "Decode_Delivery_Receipt(DeliveryReceipt):"

psql -c "
    SELECT FileID, FromBankID, ToBankID FROM Decode_Delivery_Receipt(
        _DeliveryReceipt := '$DeliveryReceipt'
    );
" -d TESTBANK001

# Since the FileID is a SHA512 hash of the message, we know it will be:
# aac8c8a1bfc8e6ae97c8aaa132472f39cc2497db23bfae424b6ee52e4e34a92574e34f6d0cd713cdd630da72a4aa151030b3c1b3745ca393af119e45b929c943
# as the message in this case was 'This is a secret message from TESTBANK001 to TESTBANK002'.

# Now, let's look at the content of the tables Files and Messages in the two databases TESTBANK001 and TESTBANK002:

echo "TESTBANK001.Files:"
psql -P expanded -c "SELECT * FROM Files" -d TESTBANK001

echo "TESTBANK002.Files:"
psql -P expanded -c "SELECT * FROM Files" -d TESTBANK002

# As we can see, the message has been transferred successfully from TESTBANK001 to TESTBANK002.

# Now, let's look at Messages in both databases:

echo "TESTBANK001.Messages:"
psql -P expanded -c "SELECT * FROM Messages" -d TESTBANK001

echo "TESTBANK002.Messages:"
psql -P expanded -c "SELECT * FROM Messages" -d TESTBANK002

