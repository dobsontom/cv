PDF := build/Tom-Dobson-CV.pdf
PRETTIER := npx --yes prettier@latest
# -l reads .latexindent.yaml, and -m is what applies its wrapping rules.
LATEXINDENT := latexindent -l -m -s -c build/
TAG ?= v$(shell date +%Y.%m.%d)

.PHONY: pdf check lint format preview release clean

pdf:
	latexmk

check: pdf
	scripts/check-pdf.sh $(PDF) $(PDF:.pdf=.log)

lint:
	$(PRETTIER) --check .
	shellcheck scripts/*.sh
	@$(LATEXINDENT) -k *.tex *.sty || { echo 'LaTeX is not formatted, run make format' >&2; exit 1; }

format:
	$(PRETTIER) --write .
	$(LATEXINDENT) -wd *.tex *.sty

preview: pdf
	pdftocairo -svg -f 1 -l 1 $(PDF) .github/preview-1.svg
	pdftocairo -svg -f 2 -l 2 $(PDF) .github/preview-2.svg

# Depends on preview so a stale image shows up as a dirty tree here rather than on the README. The
# delete clears the tag both sides, so a second release in a day replaces the first. Annotated
# because --follow-tags silently skips a lightweight tag.
release: check preview
	@git diff --quiet HEAD \
		|| { echo 'commit your changes, the refreshed preview included, before releasing' >&2; exit 1; }
	@gh release delete $(TAG) --cleanup-tag --yes 2>/dev/null || true
	git tag -a $(TAG) -m '$(TAG)'
	git push --follow-tags

clean:
	latexmk -C
