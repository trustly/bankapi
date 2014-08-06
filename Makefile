MAKE_BANKAPI=$(MAKE) -f debian/bankapi/rules
MAKE_POSTGRES=$(MAKE) -f debian/postgresql-pgcrypto-signatures/rules

all: deb

.PHONY: clean
clean:
	$(MAKE_BANKAPI) clean
	$(MAKE_POSTGRES) clean

.PHONY: deb
deb:
	$(MAKE_BANKAPI) build binary clean
	$(MAKE_BANKAPI) clean
	$(MAKE_POSTGRES) build binary
	$(MAKE_POSTGRES) clean
