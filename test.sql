SELECT MessageID FROM Create_Message(
    _Plaintext      := 'Hello world',
    _MessageType    := 'text/plain',
    _FromBankID     := 'TESTBANK001',
    _ToBankID       := 'TESTBANK002'
);
--                                                             messageid                                                             
-- ----------------------------------------------------------------------------------------------------------------------------------
--  f9df7006a9b8617462ccc34125e02c7d34d6c1cf0773f9c9e23394c2eef6383c477a19beb515daeb669d812588bcf73110ef04796ce71d7ba8bbd53977fcfee7
-- (1 row)

SELECT Ciphertext FROM Get_Message(
    _MessageID := Create_Message('Hello world','text/plain','TESTBANK001','TESTBANK002')
);
--                                   ciphertext                                  
-- ------------------------------------------------------------------------------
--  -----BEGIN PGP MESSAGE-----                                                 +
--                                                                              +
--  wcBMA6i1kJX5yWCQAQf/cfbi6O1vQ8OtUKjkufGljQPPFxi26/Ac6+esQHyzkkY9c2cjPWaRoTxK+
--  4y3Qhw0RVek2nZCLZbvt8smjSqYwb5QpoegBhF9qaon1WxBfxWhRLYocEae+TRyccfPOM/SwxTXD+
--  l+ITsmm1KdKd38Poxet2BG60nHyiV8uciVi9HdjG95WMYxuWE/80dsGtc2+bAb+SVf5fpfxL5e2m+
--  /S+f0GoEyhgcndvfYkyXIPABrJK2TOiZ81vimZ5QxTHSzH2XaMj1uuMLE73vdvmIo8JUw5oilBSc+
--  3IAgzX0dn7jyX4iFBAEUTJOesSbh6yCk9KNonAgSsQaEjmV68ESZQjWlIdLAqgGUMMZoFZsElfh7+
--  bTJnlDXdFOVx5rgzDF0581nFDkVYeqfnBuftNT4AgNeSnY+cadB+4sJzE7FA7Ifj7LSihMqneBjL+
--  Aw33hNI9YwuMHiP2bpGgwfbwNHB+qmkWkcd0EVxfZMdjdZGl0zqFkR9r34m9c0p/1UcHXyzLp7jH+
--  NgDB38V/lcZRAfoekiO2p+9YKlNjlITyEiUW3RrX9BMcB/nIy6nbj1BZ41UqGQZaC6L9SX910sYD+
--  aaL2ZnyHxBNYytb26MUFTBSCGSMVf8NsEvO71cHQmp10WhYSGlhlky0FBC1adoK/GegQDeRiAxZe+
--  s2tl3tH8mw4wJ715R2F/pVTdUQ4hDcaEkiEaDT/N0Qs99Ufr7x92GnKewwcAfEorD6lveNtNcvT8+
--  FkvEM1lLD7G6p0k3r86Z2w4/d7kSF34x15f3dOrN40bwhh86ufgQef0dCWysPXhuIW15CDIgRM1k+
--  mPYyferGxgb6                                                                +
--  =eslQ                                                                       +
--  -----END PGP MESSAGE-----                                                   +
--  
-- (1 row)

SELECT Plaintext, FromBankID, ToBankID FROM Read_Message(
    _MessageID := Create_Message('Hello world','text/plain','TESTBANK001','TESTBANK002')
);
--   plaintext  | frombankid  |  tobankid   
-- -------------+-------------+-------------
--  Hello world | TESTBANK001 | TESTBANK002
-- (1 row)

SELECT EncryptionKeyID, SignatureKeyID, Plaintext FROM Decrypt_Verify(
    _Cipherdata := dearmor(Get_Message(Create_Message('Hello world','text/plain','TESTBANK001','TESTBANK002')))
);
--  encryptionkeyid  |  signaturekeyid  |  plaintext  
-- ------------------+------------------+-------------
--  A8B59095F9C96090 | 4F5C0E03014223B9 | Hello world
-- (1 row)


SELECT FileID, FromBankID, ToBankID FROM Decode_Delivery_Receipt(
    _DeliveryReceipt := Receive_Message(Get_Message(Create_Message('Hello world','text/plain','TESTBANK001','TESTBANK002')))
);
--                                                               fileid                                                              | frombankid  |  tobankid   
-- ----------------------------------------------------------------------------------------------------------------------------------+-------------+-------------
--  b7f783baed8297f0db917462184ff4f08e69c2d5e5f79a942600f9725f58ce1f29c18139bf80b06c0fff2bdd34738452ecf40c488c22a7e3d80cdf6f9c1c0d47 | TESTBANK001 | TESTBANK002
-- (1 row)

SELECT EncryptionKeyID, SignatureKeyID, Plaintext FROM Decrypt_Verify(
    _Cipherdata := dearmor(Get_Message(Create_Message('Hello world','text/plain','TESTBANK001','TESTBANK002')))
);
--  encryptionkeyid  |  signaturekeyid  |  plaintext  
-- ------------------+------------------+-------------
--  A8B59095F9C96090 | 4F5C0E03014223B9 | Hello world
-- (1 row)

SELECT Cipherdata FROM Encrypt_Sign(
    _Plaintext          := 'Hello world',
    _EncryptionKeyID    := (SELECT SubKeyID FROM Keys WHERE BankID = 'TESTBANK001'),
    _SignatureKeyID     := (SELECT MainKeyID FROM Keys WHERE BankID = 'TESTBANK001')
);
--                                                                                                                            cipherdata                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  \xc1c04c033395abb62bd7c2ed0107ff48da45cd7f812535e7fd01a7004907114245d3b7538e995e223b1a687f87853b42d471e60dc0c8bc9314d39f509e900b1a90bd77fc8c604199d905feb08acd27393f7a4d14f8153e716ee9d44eb335abb563b30494a4d604781c066e4768dee4978c79d805236c3ff90c4cc756bb37ea9e0c347558460fd9ef66969d5b8571712f32396422c298923b5fb62a0eb4c1554dc6ee8374b1ed1610e1bd1f29f4cddce65fa08777285e916c8c34182072fe0c6e325ace2064bca6d75011814ed69fc9a8b1acaecfe8e6f5e77bc38e8018a8f43aeb8356012e4a9a39aea6e0f8396d6264eaa973737c98d1d2259f31f7339c72b14520634c66fc014f86f8c27641c1d3d2c0aa0154f8fbc743e101e0035f8ced17e2c6406cce3c05695945d24870afe803944292499d445771b38f278174553cb4cb9e90137828ab99c9c16b35a0326c758c4e0db7bf7008658eebd6ce2680ff085950656179edc4347d7fc00ef4583b760f4e398cc25696772f65e839f4b014a9155249899776cbe683281e526aced2e9c79574c6cb8eb061cd9327e614945fef7d7909bb71b5b8787f64773e616a5220b6f7b8b677dab4d7f06999f1f147588104dd223910f2f778f393121af7187631ff61392d1c91e1be11f3b4667a3b6e35b12ca1f658251dd190675704de04bada707bb6facb0a304266a4bd7879c4e21c4cc8d589b3c41bb9d1bd116abc5982e50dc46819345d9765dc2c7f2fcdaf38854da47c9b2e35b98bd4dbc36c8b64dc6ccf92904365d7190ef8096fb756917fef6d0e11c04f1f977aab2239a5fd307a7ae14e7f6e09a9687889eb721f9519521814f8e27fcdcbf9e7be8f5e6cc97bc1d7df2ceb257245930f34baa363
-- (1 row)

SELECT DeliveryReceipt FROM Receive_Message(
    _Ciphertext := Get_Message(Create_Message('Hello world','text/plain','TESTBANK001','TESTBANK002'))
);

--                                deliveryreceipt                                
-- ------------------------------------------------------------------------------
--  -----BEGIN PGP MESSAGE-----                                                 +
--                                                                              +
--  wcBMAzOVq7Yr18LtAQf/YbzuQdGbTVz9B6ZanLnVj4W/4gowMzEwNUC9BCw88yqNN2hTzdb0JvIz+
--  I3sBmLZ8tC9Hf3EQvI+a6tluMJG4n2Ldi7BW9SHqaI82b0EL0YoKfdAvIQ+lpgikzUnjFkBrJDfA+
--  Jv7HqLuyrT5bAimWtWV87CFygkwYAca52RE3NSE1mY27JiYZ9+DMfInWDlmB2X2j4KCVJAE6BQNj+
--  MLfzDuA4ADDsJW7+TWHhHS0uX2BqeLf5GE8nN/oECMLgT7u+MsTdSXqmcHxOrEk/m0jM3GR08ZPu+
--  jZ5S9NYwvBgQuUDlUoUWBC0WcrAzbzjKSGcxqWA1UmX0FCVChxyTvQZDf9LBHwFOdLe4yMWWPQFg+
--  5hrlAN5beCAV6rVL5p4m+2ri368XwJnNxGpLGh36SooeGPxXzTwfr3TAliQP9WLZED8FD5O5qnQ3+
--  tYvNvGxtxaeyNG+LYbPOKEpr5WBUrfXuwoXVzuiMHecN5vOxhdyKWZCdvvYxToFgyWoOJRqDoIMH+
--  EO22rJRgwqygu0FWl5TGiKzmx7HevxTHiUovO5SWLT+ZQ8oDQBHjv1MrSshQ1Me+di/QmtPYxSKi+
--  T8KtJV7MZBrsViZj+sDcBuL8AAxsGWkb+wD62jyHJtB7PCjdplEQ53Tb6D+EDX+iCsgH1099QDer+
--  Eo8tsG22GSTfWnponi3tmixgzenSKEVqNDoevyblhYsKoOwKWkLYYdh9Widgs+mwSkiASOwggM5W+
--  7k0nbh1jSblVb/MMFM3DfibnoXiRIf34lZh63OK43yv7r5yBZI4OJJPawnDtYHk5iDmgBAEWuX8k+
--  qJDydR+7cBQ9RN9wxQsCsBGHMqPnxEzoJWeznE7UtsuxeGGHAGWJSxj7rxUW1+6659Udyr0/Hk7Q+
--  eqfQuuf5PylR9w1IMq/3s3ug7O7/dIS4eVB+4fLJmhgBC+3pNhH8+cKvcNnDAJ0uFKKaAYDdLI/t+
--  xYaw9L9kxdFqY5L3                                                            +
--  =wS1a                                                                       +
--  -----END PGP MESSAGE-----                                                   +
--  
-- (1 row)


