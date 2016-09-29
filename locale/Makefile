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
POFILES = $(shell find . -name '$(DOMAIN).po')
MOFILES = $(patsubst %.po,%.mo,$(POFILES))
POXFILES = $(patsubst %.po,%.pox,$(POFILES))
EDITFILES = $(patsubst %.po,%.edit.po,$(POFILES))

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

# Unify duplicate translations
uniq-po:
	for f in $(shell find ./ -name "*.po") ; do \
		msguniq $$f -o $$f ; \
	done

tx-pull: $(EDITFILES)
	tx pull -f

# Extract strings and update the .pot, prepare .edit.po files
extract-strings:
	bundle exec rake locale:find DOMAIN=$(DOMAIN) SKIP_MODEL=1

# Merge .edit.po into .po
update-po:
	bundle exec rake locale:find locale:po_to_json DOMAIN=$(DOMAIN) SKIP_MODEL=1

tx-update: extract-strings tx-pull update-po
	git commit -m "i18n - extracting new, pulling from tx" . ../app/assets/javascripts/locale
	-echo Changes commited!

# Remove all MO files
clean:
	-rm -f messages.mo
	find . \( -name "*.mo" -o -name "*.pox" \) -exec rm -f '{}' ';'
	find . -path *LC_MESSAGES | xargs rm -rf
