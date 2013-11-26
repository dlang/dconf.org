SITE = erdani.com:www/d/conf/
SITE = dconf.org@digitalmars.com:data/

OUT = out

all: $(OUT)/index.php 2013/all 2014/all

$(OUT)/index.php: index.php
	mkdir -p $(OUT)
	cp $< $@

.PHONY: rsync
rsync : all
	rsync -avz $(OUT)/* $(SITE)

.PHONY: clean
clean: 2013/clean 2014/clean
	rm -rf .made out

# Patterns

2013/%:
	$(MAKE) --directory=2013 $*

2014/%:
	$(MAKE) --directory=2014 $*
