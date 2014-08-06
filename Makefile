all: deb

clean:
	$(MAKE) -f debian/rules clean

deb:
	$(MAKE) -f debian/rules build binary clean
