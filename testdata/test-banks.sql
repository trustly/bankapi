SELECT Register_Bank(
    _BankID   := 'TESTBANK001',
    _Protocol := 'https',
    _Host     := 'www.testbank1.com',
    _Port     := 443,
    _Path     := '/api'
);

SELECT Register_Bank(
    _BankID   := 'TESTBANK002',
    _Protocol := 'https',
    _Host     := 'www.testbank2.com',
    _Port     := 443,
    _Path     := '/api'
);
