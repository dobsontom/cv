#!/usr/bin/env bash
# Usage: scripts/check-pdf.sh build/tom-dobson-cv.pdf
set -euo pipefail

pdf=${1:?usage: $0 <pdf>}
log=${pdf%.pdf}.log
max_pages=2
status=0

info=$(pdfinfo "$pdf")
text=$(pdftotext "$pdf" -)

pages=$(awk '/^Pages:/ { print $2 }' <<<"$info")
if ((pages > max_pages)); then
  echo "FAIL: $pages pages, limit is $max_pages"
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
  echo "ok: text extracts"
else
  echo "FAIL: name not found in extracted text"
  status=1
fi

# An overfull box is a visible defect on a CV, so it fails the check.
if grep -q 'Overfull \\hbox' "$log"; then
  echo "FAIL: overfull boxes"
  grep 'Overfull \\hbox' "$log" | head
  status=1
else
  echo "ok: no overfull boxes"
fi

exit $status
