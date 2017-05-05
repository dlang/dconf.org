ifeq (,$(OUT))
$(error you must define OUT)
endif

TMP = .tmp

HTML_NAMES = $(addsuffix .html, \
	contact index registration schedule/index speakers/index thankyou venue)

TALK_BASENAMES = \
alexandrescu \
arneaud \
bright \
buclaw \
caciulescu \
cojocaru \
dilly \
engelen \
hackathon1 \
hackathon2 \
koch \
lightning \
marques \
meyers \
nacke \
nitu \
nunn \
olshansky \
panel \
panteleev \
schveighoffer \
sechet \
staniloiu \
veelo \
watson \
wilson \

TO_COPY = \
	images/ $(wildcard images/*.png images/*.svg images/*.jpg) \
	includes/ $(wildcard includes/*) \
	$(addprefix talks/, $(addsuffix .pdf, bright arneaud sechet marques nacke buclaw veelo olshansky watson engelen)) \
	$(addprefix talks/, $(addsuffix .pptx, wilson cojocaru meyers)) \
	$(addprefix talks/, $(addsuffix .odp, nitu koch)) \
	$(addprefix talks/, $(addsuffix .d, engelen_code)) \

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

$(OUT)/%.pdf : %.pdf
	cp $^ $@

$(OUT)/%.pptx : %.pptx
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

