ELM_MAKE_OUTPUT = Main.js
ELM_HTML_FILE = index.html
DIST = dist
DIST_FILES = $(ELM_MAKE_OUTPUT) $(ELM_HTML_FILE)

.PHONY: deploy

%.js: %.elm
	elm-make --output $@ $<

$(DIST)/%: %
	mkdir -p $(DIST)
	cp $< $@

deploy: Main.elm $(addprefix $(DIST)/,$(DIST_FILES))
	git add .
	git commit -m "Deploy :tada:"
	git subtree push --prefix $(DIST) deploy HEAD
