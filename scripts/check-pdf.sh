#!/usr/bin/env bash
set -euo pipefail

usage="usage: $0 <pdf> <log>"
pdf=${1:?$usage}
log=${2:?$usage}
# grep exits 2 on a missing file, which the check below cannot tell from a clean build.
[[ -f $log ]] || { echo "no build log at $log" >&2; exit 1; }
# make preview renders this many SVGs and the README embeds them by name, so a page appearing or
# vanishing would break the README silently.
want_pages=2
status=0

info=$(pdfinfo "$pdf")
text=$(pdftotext "$pdf" -)

pages=$(awk '/^Pages:/ { print $2 }' <<<"$info")
if ((pages != want_pages)); then
  echo "FAIL: $pages pages, expected $want_pages"
  status=1
else
  echo "ok: $pages pages"
fi

if grep -q '^Title:.*Tom Dobson' <<<"$info"; then
  echo "ok: PDF title metadata set"
else
  echo "FAIL: PDF title metadata missing"
  status=1
fi

if grep -qi 'tom dobson' <<<"$text"; then
  echo "ok: name found in extracted text"
else
  echo "FAIL: name not found in extracted text"
  status=1
fi

# A warning to TeX, but visible on the page.
if overfull=$(grep -m 10 'Overfull \\hbox' "$log"); then
  echo "FAIL: overfull boxes"
  echo "$overfull"
  status=1
else
  echo "ok: no overfull boxes"
fi

exit $status
