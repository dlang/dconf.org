#SITE = erdani.com:www/d/bvbvuntf
SITE = dconf.org@digitalmars.com:data/

OUT = out

all: $(OUT)/index.php 2013/all 2014/all

.PHONY: rsync
rsync : all
	rsync -avz -p $(OUT)/* $(SITE)

.PHONY: clean
clean: 2013/clean 2014/clean
	rm -rf out

# Patterns

2013/%:
	$(MAKE) --directory=2013 OUT=../$(OUT)/2013 $*

2014/%:
	$(MAKE) --directory=2014 OUT=../$(OUT)/2014 $*

$(OUT)/%: %
	mkdir -p $(OUT)
	cp $< $@

