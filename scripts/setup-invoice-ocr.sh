#!/usr/bin/env bash
# Cloud-only, idempotent setup. No paid API or service.
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ready() {
  command -v ocrmypdf >/dev/null && command -v pdftotext >/dev/null && command -v gs >/dev/null &&
    tesseract --list-langs 2>/dev/null | grep -qx deu && tesseract --list-langs 2>/dev/null | grep -qx eng
}
if [ -d "$root/.runtime/invoice-ocr/tessdata" ]; then export TESSDATA_PREFIX="$root/.runtime/invoice-ocr/tessdata"; fi
if ! ready; then
  if [ "$(id -u)" = 0 ]; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ocrmypdf tesseract-ocr-deu tesseract-ocr-eng poppler-utils
  elif command -v sudo >/dev/null && sudo -n true 2>/dev/null; then
    sudo -n apt-get update
    sudo -n env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ocrmypdf tesseract-ocr-deu tesseract-ocr-eng poppler-utils
  else
    # Base OCR binaries must exist. Install only missing language data without root.
    for tool in ocrmypdf pdftotext tesseract gs; do
      command -v "$tool" >/dev/null || { echo "missing_cloud_binary:$tool; requires image package installation" >&2; exit 1; }
    done
    python3 - "$root/.runtime/invoice-ocr/tessdata" <<'PY'
import hashlib, os, pathlib, subprocess, sys, urllib.request
root = pathlib.Path(sys.argv[1]); root.mkdir(parents=True, exist_ok=True)
# Reuse installed English/orientation data; never replace system files.
listing = subprocess.check_output(['tesseract', '--list-langs'], text=True, env={k:v for k,v in os.environ.items() if k != 'TESSDATA_PREFIX'})
base = pathlib.Path(listing.split('"')[1])
for path in base.iterdir():
    target = root / path.name
    if not target.exists(): target.symlink_to(path)
target = root / 'deu.traineddata'
expected = '19d219bbb6672c869d20a9636c6816a81eb9a71796cb93ebe0cb1530e2cdb22d'
if not target.exists() or hashlib.sha256(target.read_bytes()).hexdigest() != expected:
    url = 'https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/87416418657359cb625c412a48b6e1d6d41c29bd/deu.traineddata'
    data = urllib.request.urlopen(url, timeout=60).read(2000000)
    if hashlib.sha256(data).hexdigest() != expected: raise RuntimeError('language_checksum_mismatch')
    temp = root / 'deu.download'; temp.write_bytes(data); temp.replace(target)
PY
    export TESSDATA_PREFIX="$root/.runtime/invoice-ocr/tessdata"
  fi
fi
ready || { echo 'ocr_setup_verification_failed' >&2; exit 1; }
ocrmypdf --version
tesseract --version 2>&1 | head -n 1
tesseract --list-langs
