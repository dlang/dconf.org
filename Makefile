SITE = erdani.com:www/d/conf/
SITE = dconf.org@digitalmars.com:data/

OUT = out

all: .made 2013/.made 2014/.made

.made: index.php
	cp index.php $(OUT)/
	touch $@

2013/.made:
	$(MAKE) --directory=2013
	touch $@

2014/.made:
	$(MAKE) --directory=2014

.PHONY: rsync
rsync : all
	rsync -avz $(OUT)/* $(SITE)

.PHONY: clean
clean:
	$(MAKE) --directory=2013 clean
	rm -rf .made 2013/.made
