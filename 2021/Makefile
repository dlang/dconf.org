ifeq (,$(OUT))
$(error you must define OUT)
endif
ifeq (,$(DMD))
$(error you must define DMD)
endif

TMP = .tmp

$(addprefix $(OUT)/, includes/%): includes/%
	cp $^ $@

TO_COPY = \
	includes/ $(wildcard includes/*) \
	$(wildcard talks/*.pdf) \
	$(wildcard talks/*.pptx) \
	$(wildcard talks/*.odp) \
	$(wildcard talks/code.*.d) \
	index.html \
	online/images/ $(wildcard online/images/*.png online/images/*.svg online/images/*.jpg) \
	online/slides/ $(wildcard online/slides/*.pdf online/slides/*.pptx online/slides/*.odp) \
	online/ online/index.html \


ALL_RELATIVE_PATHS = $(TO_COPY)

SITE_FILES = $(addprefix $(OUT)/, $(ALL_RELATIVE_PATHS))

# Rules

all : $(SITE_FILES)

clean :
	rm -rf $(OUT)

# Patterns
$(OUT)/%.html : %.html
	cp $^ $@

$(OUT)/%.pdf : %.pdf
	cp $^ $@

$(OUT)/%.pptx : %.pptx
	cp $^ $@

$(OUT)/%.ppt : %.ppt
	cp $^ $@

$(OUT)/%.odp : %.odp
	cp $^ $@

$(OUT)/%.zip : %.zip
	cp $^ $@

$(OUT)/%.png : %.png
	cp $^ $@

$(OUT)/%.svg : %.svg
	cp $^ $@

$(OUT)/%.jpg : %.jpg
	cp $^ $@

$(OUT)/%.d : %.d
	cp $^ $@

$(OUT)/%.css : %.css
	cp $^ $@

$(OUT)/%/ : %/
	mkdir -p $@

