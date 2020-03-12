ifeq (,$(OUT))
$(error you must define OUT)
endif
ifeq (,$(DMD))
$(error you must define DMD)
endif

TMP = .tmp

TO_COPY = \
	WalterAndrei.pdf \


ALL_RELATIVE_PATHS = $(TO_COPY)

SITE_FILES = $(addprefix $(OUT)/, $(ALL_RELATIVE_PATHS))

# Rules

all : $(SITE_FILES)

clean :
	rm -rf $(OUT)

# Patterns
$(OUT)/%.pdf : %.pdf
	mkdir -p $@ && cp $^ $@
