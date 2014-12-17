ELM_MAKE_OUTPUT = Main.js
ELM_HTML_FILE = index.html
NATIVE = Native/**/*.js
DIST = dist
VENDOR = vendor
VENDOR_FILES = $(addprefix $(VENDOR)/,router.js route-recognizer.js rsvp.js)
DIST_FILES = $(ELM_MAKE_OUTPUT) $(ELM_HTML_FILE) $(VENDOR_FILES)

.PHONY: deploy

%.js: %.elm $(NATIVE)
	elm-make --output $@ $<

$(DIST)/%: %
	mkdir -p $(DIST)
	cp $< $@

deploy: Main.elm $(addprefix $(DIST)/,$(DIST_FILES))
	git add .
	git commit -m "Deploy :tada:"
	git subtree push --prefix $(DIST) deploy master
