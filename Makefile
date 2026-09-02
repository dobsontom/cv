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
	$(PRETTIER) --check .
	shellcheck scripts/*.sh

format:
	$(PRETTIER) --write .

preview: pdf
	pdftocairo -svg -f 1 -l 1 $(PDF) .github/preview-1.svg
	pdftocairo -svg -f 2 -l 2 $(PDF) .github/preview-2.svg

clean:
	latexmk -C
