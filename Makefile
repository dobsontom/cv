PDF := build/Tom-Dobson-CV.pdf
PRETTIER := npx --yes prettier@latest
TAG ?= v$(shell date +%Y.%m.%d)

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
# The tag is annotated because --follow-tags silently skips a lightweight one and still exits 0.
release: check preview
	@git diff --quiet HEAD \
		|| { echo 'commit your changes, the refreshed preview included, before releasing' >&2; exit 1; }
	git tag -a $(TAG) -m '$(TAG)'
	git push --follow-tags

clean:
	latexmk -C
