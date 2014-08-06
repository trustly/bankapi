all: deb

deb:
	$(MAKE) -f debian/rules build
	$(MAKE) -f debian/rules binary

