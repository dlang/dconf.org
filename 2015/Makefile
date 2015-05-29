ifeq (,$(OUT))
$(error you must define OUT)
endif

TMP = .tmp

HTML_NAMES = $(addsuffix .html, \
	contact index registration schedule/index speakers/index venue thankyou)

TALK_BASENAMES = alexandrescu allison bright colvin davis gubler \
 isaacson murphy nadlinger neves nowak panel1 panel2 ruppe schott sechet smith \
 strasuns wakeling zvibel

TO_COPY = images/ includes/ $(addsuffix .pdf, $(addprefix talks/, \
	allison davis isaacson murphy smith strasuns zvibel))

TALK_NAMES = $(addprefix talks/, $(addsuffix .html, ${TALK_BASENAMES}))

SPEAKER_BITS = $(addprefix $(TMP)/speakers/, $(addsuffix .gen.ddoc, ${TALK_BASENAMES}))

SCHEDULE_BITS = $(addprefix $(TMP)/schedule/, $(addsuffix .gen.ddoc, ${TALK_BASENAMES}))

ALL_RELATIVE_PATHS = $(HTML_NAMES) $(TALK_NAMES) $(TO_COPY)

SITE_FILES = $(addprefix $(OUT)/, $(ALL_RELATIVE_PATHS))

# Rules

all : $(SITE_FILES)

clean :
	rm -rf $(OUT) $(TMP)

# Patterns

$(OUT)/talks/%.html : macros.ddoc talks/macros.ddoc talks/%.dd
	dmd -c -o- -Df$@ $^

$(TMP)/speakers/%.gen.ddoc : macros.ddoc speakers/fragment.ddoc talks/%.dd
	dmd -c -o- -Df$@ $^

$(OUT)/speakers/index.html : macros.ddoc ${SPEAKER_BITS} speakers/index.dd
	dmd -c -o- -Df$@ $^

$(OUT)/schedule/index.html : macros.ddoc ${SCHEDULE_BITS} \
		schedule/index.dd
	dmd -c -o- -Df$@ $^

$(TMP)/schedule/%.gen.ddoc : macros.ddoc talks/macros.ddoc schedule/fragment.ddoc talks/%.dd
	dmd -c -o- -Df$@ $^

$(OUT)/%.html : macros.ddoc %.dd
	dmd -c -o- -Df$@ $^

$(OUT)/%/ : %/
	cp -r $^ $@

$(OUT)/%.pdf : %.pdf
	cp $^ $@

