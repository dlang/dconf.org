#SITE=erdani.com:www/d/
SITE = dconf.org@digitalmars.com:data/
DMD = dmd
OUT = out

all: $(OUT)/index.php 2013/all 2014/all 2015/all 2016/all 2017/all

.PHONY: rsync
rsync : all
	rsync -avz -p $(OUT)/* $(SITE)

.PHONY: clean
clean: 2013/clean 2014/clean
	rm -rf out

# Patterns

2013/%:
	$(MAKE) DMD=$(DMD) --directory=2013 OUT=../$(OUT)/2013 $*

2014/%:
	$(MAKE) DMD=$(DMD) --directory=2014 OUT=../$(OUT)/2014 $*

2015/%:
	$(MAKE) DMD=$(DMD) --directory=2015 OUT=../$(OUT)/2015 $*

2016/%:
	$(MAKE) DMD=$(DMD) --directory=2016 OUT=../$(OUT)/2016 $*

2017/%:
	$(MAKE) DMD=$(DMD) --directory=2017 OUT=../$(OUT)/2017 $*

$(OUT)/%: %
	mkdir -p $(OUT)
	cp $< $@
