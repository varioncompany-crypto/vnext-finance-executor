#!/usr/bin/env bash
# Run inside the Linux Codex Cloud finance environment, never on the business PC.
set -euo pipefail
if command -v ocrmypdf >/dev/null && command -v pdftotext >/dev/null && tesseract --list-langs 2>/dev/null | grep -qx deu; then exit 0; fi
if ! command -v apt-get >/dev/null; then echo "OCR setup requires a Debian/Ubuntu cloud image" >&2; exit 1; fi
if [ "$(id -u)" = 0 ]; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ocrmypdf tesseract-ocr-deu tesseract-ocr-eng poppler-utils
else
  sudo -n apt-get update
  sudo -n env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ocrmypdf tesseract-ocr-deu tesseract-ocr-eng poppler-utils
fi
ocrmypdf --version
tesseract --list-langs
