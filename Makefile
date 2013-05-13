SITE = erdani.com:www/d/conf/
SITE = dconf.org@digitalmars.com:data/

OUT = out
TMP = .tmp

HTML_NAMES = $(addsuffix .html, index contact faq venue registration	\
 schedule/index speakers/index kickstarter/index)

TALK_BASENAMES = alexandrescu bright buclaw cehreli chevalier_boisvert	\
 clugston edwards evans_1 evans_2 gertzfield lucarella nadlinger		\
 nowak olshansky panteleev rohe schadek schuetze simcha wilson

TO_COPY = images/ includes/ talks/bright.pdf talks/buclaw.pdf	\
talks/cehreli.pdf talks/schadek.pdf

VERBATIM = $(addprefix $(OUT)/, $(TO_COPY))

TALK_NAMES = $(addprefix talks/, $(addsuffix .html, ${TALK_BASENAMES} panel))

SPEAKER_BITS = $(addprefix $(TMP)/speakers/, $(addsuffix .gen.ddoc, ${TALK_BASENAMES}))

SCHEDULE_BITS = $(addprefix $(TMP)/schedule/, $(addsuffix .gen.ddoc, ${TALK_BASENAMES}))

ALL_RELATIVE_PATHS = $(HTML_NAMES) $(TALK_NAMES) $(TO_COPY)

SITE_NOW = $(addprefix $(OUT)/, $(ALL_RELATIVE_PATHS))

SITE_2013 = $(addprefix $(OUT)/2013/, $(ALL_RELATIVE_PATHS))

# Rules

all : $(SITE_NOW) $(SITE_2013)

clean :
	rm -rf $(OUT) $(TMP)

rsync : all
	rsync -avz $(OUT)/* $(SITE)

# Patterns

$(OUT)/talks/%.html : macros.ddoc talks/macros.ddoc talks/%.dd
	dmd -c -o- -Df$@ $^

$(TMP)/speakers/%.gen.ddoc : macros.ddoc speakers/fragment.ddoc talks/%.dd
	dmd -c -o- -Df$@ $^

$(OUT)/speakers/index.html : macros.ddoc ${SPEAKER_BITS} speakers/index.dd
	dmd -c -o- -Df$@ $^

$(OUT)/schedule/index.html : macros.ddoc ${SCHEDULE_BITS} $(TMP)/schedule/panel.gen.ddoc \
		schedule/index.dd
	dmd -c -o- -Df$@ $^

$(TMP)/schedule/%.gen.ddoc : macros.ddoc talks/macros.ddoc schedule/fragment.ddoc talks/%.dd
	dmd -c -o- -Df$@ $^

$(OUT)/kickstarter/%.html : macros.ddoc kickstarter/%.dd
	dmd -c -o- -Df$@ $^

$(OUT)/%.html : macros.ddoc %.dd
	dmd -c -o- -Df$@ $^

$(OUT)/%/ : %/
	cp -r $^ $@

$(OUT)/%.pdf : %.pdf
	cp $^ $@

$(OUT)/2013/% : $(OUT)/%
	@mkdir -p `dirname $@`
	cp -r $^ $@
