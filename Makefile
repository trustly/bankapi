all: deb

clean:
	$(MAKE) -f debian/bankapi/rules clean

deb:
	$(MAKE) -f debian/bankapi/rules build binary clean
