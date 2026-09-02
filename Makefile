PDF := build/tom-dobson-cv.pdf
PRETTIER := npx --yes prettier@3.9.6

# Pins pdfTeX's timestamps to the last commit, so rebuilding a commit gives a byte-identical PDF.
export SOURCE_DATE_EPOCH ?= $(shell git log -1 --format=%ct 2>/dev/null || date +%s)

.PHONY: pdf check lint format preview clean

pdf:
	latexmk

check: pdf
	scripts/check-pdf.sh $(PDF)

lint:
	$(PRETTIER) --check . '!vendor'
	shellcheck scripts/*.sh

format:
	$(PRETTIER) --write . '!vendor'

preview: pdf
	pdftoppm -png -gray -r 96 -f 1 -l 1 -singlefile $(PDF) .github/preview

clean:
	latexmk -C
