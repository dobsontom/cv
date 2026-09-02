PDF := build/tom-dobson-cv.pdf
PRETTIER := npx --yes prettier@3.9.6
TAG ?= v$(shell date +%Y.%m.%d)

# Pins pdfTeX's timestamps to the last commit, so rebuilding a commit gives a byte-identical PDF.
export SOURCE_DATE_EPOCH ?= $(shell git log -1 --format=%ct 2>/dev/null || date +%s)

.PHONY: pdf check lint format preview release clean

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

# Depends on preview so a stale image shows up as a dirty tree here rather than on the README.
release: check preview
	@git diff --quiet && git diff --cached --quiet \
		|| { echo 'commit your changes, the refreshed preview included, before releasing' >&2; exit 1; }
	git tag $(TAG)
	git push --follow-tags

clean:
	latexmk -C
