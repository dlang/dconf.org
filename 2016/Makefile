ifeq (,$(OUT))
$(error you must define OUT)
endif

ifeq (,$(DMD))
DMD = dmd
endif

TMP = .tmp

HTML_NAMES = $(addsuffix .html, \
	contact index registration schedule/index speakers/index thankyou venue)

TALK_BASENAMES = alexandrescu bof bright cehreli clugston colvin \
	hunsur lucarella \
	marques nacke panel1 panel2 panel3 panteleev piolat nowak schadek \
	schveighoffer sechet smith thaut watson zvibel

TO_COPY = images/ includes/
#TO_COPY = images/ includes/ $(addsuffix .pdf, $(addprefix talks/, \
  alexandrescu allison bright colvin davis gubler isaacson murphy nadlinger neves ruppe sechet smith strasuns wakeling zvibel))\
  talks/schott.zip

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
	$(DMD) -c -o- -Df$@ $^

$(TMP)/speakers/%.gen.ddoc : macros.ddoc speakers/fragment.ddoc talks/%.dd
	$(DMD) -c -o- -Df$@ $^

$(OUT)/speakers/index.html : macros.ddoc ${SPEAKER_BITS} speakers/index.dd
	$(DMD) -c -o- -Df$@ $^

$(OUT)/schedule/index.html : macros.ddoc ${SCHEDULE_BITS} \
		schedule/index.dd
	$(DMD) -c -o- -Df$@ $^

$(TMP)/schedule/%.gen.ddoc : macros.ddoc talks/macros.ddoc schedule/fragment.ddoc talks/%.dd
	$(DMD) -c -o- -Df$@ $^

$(OUT)/%.html : macros.ddoc %.dd
	$(DMD) -c -o- -Df$@ $^

$(OUT)/%/ : %/
	cp -r $^ $@

$(OUT)/%.pdf : %.pdf
	cp $^ $@

$(OUT)/%.zip : %.zip
	cp $^ $@
