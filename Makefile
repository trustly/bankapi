MAKE_BANKAPI=$(MAKE) -f debian/bankapi/rules
MAKE_POSTGRES=$(MAKE) -f debian/postgresql-pgcrypto-openpgp/rules

all: deb

.PHONY: clean
clean:
	$(MAKE_BANKAPI) clean
	$(MAKE_POSTGRES) clean

.PHONY: deb
deb: bankapi pgcrypto


.PHONY: pgcrypto
pgcrypto:
	$(MAKE_POSTGRES) build binary
	$(MAKE_POSTGRES) clean


.PHONY: bankapi
bankapi:
	$(MAKE_BANKAPI) build binary
	$(MAKE_BANKAPI) clean
