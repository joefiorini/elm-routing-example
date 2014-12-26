ELM_MAKE_OUTPUT = Main.js
ELM_HTML_FILE = index.html
SCSS = scss
CSS_OUTPUT = Main.css
NATIVE = Native/**/*.js
DIST = dist
VENDOR = vendor
SASSC_LOAD_PATH = bower_components/foundation/scss
VENDOR_FILES = $(addprefix $(VENDOR)/,router.js route-recognizer.js rsvp.js)
DIST_FILES = $(ELM_MAKE_OUTPUT) $(ELM_HTML_FILE) $(VENDOR_FILES) $(CSS_OUTPUT)

.PHONY: deploy brew

%.js: %.elm $(NATIVE)
	elm-make --output $@ $<

%.css: $(SCSS)/%.scss
	sassc -t compressed -I $(SASSC_LOAD_PATH) -m $< $@

$(DIST)/%: %
	mkdir -p $(DIST)
	cp $< $@

deploy: Main.elm $(addprefix $(DIST)/,$(DIST_FILES))
	git add .
	git commit -m "Deploy :tada:"
	git subtree push --prefix $(DIST) deploy master

brew:
	brew install sassc
	brew install entr
