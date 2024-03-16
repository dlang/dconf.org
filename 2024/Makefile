ifeq (,$(OUT))
$(error you must define OUT)
endif
ifeq (,$(DMD))
$(error you must define DMD)
endif

TMP = .tmp

TO_COPY =  \
	online/ online/index.html \
	online/includes/ $(wildcard online/includes/*) \
	online/images/ $(wildcard online/images/*.png online/images/*.svg online/images/*.jpg) \
	online/slides $(wildcard online/slides/*.pdf)

SITE_FILES = $(addprefix $(OUT)/, $(TO_COPY))

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

