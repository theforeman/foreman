#
# Makefile for PO merging and MO generation. More info in the README.
#
# make all-mo (default) - generate MO files
# make check - check translations using translate-tool
# make tx-update - download and merge translations from Transifex
# make clean - clean everything
#
DOMAIN = foreman
POTFILE = $(DOMAIN).pot
MOFILE = $(DOMAIN).mo
POFILES = $(shell find . -name '*.po')
MOFILES = $(patsubst %.po,%.mo,$(POFILES))
POXFILES = $(patsubst %.po,%.pox,$(POFILES))

%.mo: %.po
	mkdir -p $(shell dirname $@)/LC_MESSAGES
	msgfmt -o $(shell dirname $@)/LC_MESSAGES/$(MOFILE) $<

# Generate MO files from PO files
all-mo: $(MOFILES)

# Check for malformed strings
%.pox: %.po
	msgfmt -c $<
	pofilter --nofuzzy -t variables -t blank -t urls -t emails -t long -t newlines \
		-t endwhitespace -t endpunc -t puncspacing -t options -t printf -t validchars --gnome $< > $@
	cat $@
	! grep -q msgid $@

check: $(POXFILES)
	msgfmt -c ${POTFILE}

# Merge PO files
update-po:
	for f in $(shell find ./ -name "*.po") ; do \
		msgmerge -N --backup=none -U $$f ${POTFILE} ; \
	done

# Unify duplicate translations
uniq-po:
	for f in $(shell find ./ -name "*.po") ; do \
		msguniq $$f -o $$f ; \
	done

tx-pull:
	tx pull -a -f -r foreman.foreman
	git commit -a -m 'i18n - updating translations from transifex'
	-git add -A
	-git commit -a -m 'i18n - adding new languages from transifex'

tx-update: tx-pull update-po
	-git commit -a -m 'i18n - merging gettext po files'

# Remove all MO files
clean:
	-rm -f messages.mo
	find . \( -name "*.mo" -o -name "*.pox" \) -exec rm -f '{}' ';'
	find . -path *LC_MESSAGES | xargs rm -rf
