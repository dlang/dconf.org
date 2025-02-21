DMD = dmd
OUT = docs

all: $(OUT)/index.html $(OUT)/favicon.png $(OUT)/CNAME \
	2007/all \
	2013/all \
	2014/all \
	2015/all \
	2016/all \
	2017/all \
	2018/all \
	2019/all \
	2020/all \
	2021/all \
	2022/all \
	2023/all \
	2024/all \
	2025/all

.PHONY: clean
clean: 2007/clean \
	2013/clean \
	2014/clean \
	2015/clean \
	2016/clean \
	2017/clean \
	2018/clean \
	2019/clean \
	2020/clean \
	2021/clean \
	2022/clean \
	2023/clean \
	2024/clean \
	2025/clean
	rm -rf $(OUT)
	rm -rf 20??/.tmp

# Patterns
2007/%:
	$(MAKE) DMD=$(DMD) --directory=2007 OUT=../$(OUT)/2007 $*

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

2018/%:
	$(MAKE) DMD=$(DMD) --directory=2018 OUT=../$(OUT)/2018 $*

2019/%:
	$(MAKE) DMD=$(DMD) --directory=2019 OUT=../$(OUT)/2019 $*

2020/%:
	$(MAKE) DMD=$(DMD) --directory=2020 OUT=../$(OUT)/2020 $*

2021/%:
	$(MAKE) DMD=$(DMD) --directory=2021 OUT=../$(OUT)/2021 $*
	
2022/%:
	$(MAKE) DMD=$(DMD) --directory=2022 OUT=../$(OUT)/2022 $*
	
2023/%:
	$(MAKE) DMD=$(DMD) --directory=2023 OUT=../$(OUT)/2023 $*
	
2024/%:
	$(MAKE) DMD=$(DMD) --directory=2024 OUT=../$(OUT)/2024 $*

2025/%:
	$(MAKE) DMD=$(DMD) --directory=2025 OUT=../$(OUT)/2025 $*

$(OUT)/%: %
	mkdir -p $(OUT)
	cp $< $@
