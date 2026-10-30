"""Synthetic image-only PDF integration smoke; no business data or model APIs.
Run with a Python providing Pillow: python -B tests/smoke_invoice_ocr.py.
"""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
def call(*args, success=True):
    p = subprocess.run(list(args), capture_output=True, text=True)
    assert (p.returncode == 0) == success, (args[0], p.returncode, p.stdout, p.stderr)
    return p.stdout

def main():
    with tempfile.TemporaryDirectory(prefix='synthetic-invoice-') as folder:
        folder = Path(folder)
        image = Image.new('RGB', (2480, 3508), 'white')
        draw = ImageDraw.Draw(image)
        font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 54)
        lines = ['SYNTHETISCHE TESTRECHNUNG', 'Keine echte Forderung - nur OCR Test',
                 'Rechnungsnummer: OCR-2026-0042', 'Rechnungsdatum: 30.10.2026',
                 'Testartikel: 100,00 EUR', 'Umsatzsteuer 19 Prozent: 19,00 EUR',
                 'Gesamtbetrag: 119,00 EUR']
        for i, line in enumerate(lines): draw.text((180, 220+i*120), line, font=font, fill='black')
        pdf = folder/'scan.pdf'; image.save(pdf, 'PDF', resolution=300)
        digest = hashlib.sha256(pdf.read_bytes()).hexdigest()
        before = call('pdftotext', str(pdf), '-')
        assert not before.strip(), 'fixture_must_have_no_text_layer'
        output = folder/'first.json'
        result = json.loads(call(sys.executable, '-B', str(ROOT/'tools/invoice_ocr.py'), str(pdf), str(output)))
        payload = json.loads(output.read_text())
        expected = ['OCR-2026-0042', '30.10.2026', '119,00 EUR']
        assert result['method'] == 'tesseract_ocr'
        assert all(value in payload['text'] for value in expected), payload['text']
        assert payload['sourceSha256'] == digest and not payload['bookingApproved']
        assert output.stat().st_mode & 0o777 == 0o600
        second = folder/'second.json'
        again = json.loads(call(sys.executable, '-B', str(ROOT/'tools/invoice_ocr.py'), str(pdf), str(second)))
        assert again['method'] == 'tesseract_ocr'
        assert json.loads(second.read_text())['text'] == payload['text']
        output_hash = hashlib.sha256(output.read_bytes()).hexdigest()
        rejection = json.loads(call(sys.executable, '-B', str(ROOT/'tools/invoice_ocr.py'), str(pdf), str(output), success=False))
        assert rejection['error'] == 'output_must_be_new'
        assert hashlib.sha256(output.read_bytes()).hexdigest() == output_hash
        rejection2 = json.loads(call(sys.executable, '-B', str(ROOT/'tools/invoice_ocr.py'), str(pdf), str(pdf), success=False))
        assert rejection2['error'] == 'output_must_be_new'
        assert hashlib.sha256(pdf.read_bytes()).hexdigest() == digest
        report = {'ok':True, 'syntheticOnly':True, 'inputTextCharacters':len(before.strip()),
                  'method':result['method'], 'expectedFieldsFound':expected, 'originalSha256':digest,
                  'originalUnchanged':True, 'repeatWithFreshOutput':'passed', 'overwriteProtection':'passed',
                  'sourceOverwriteProtection':'passed', 'outputMode':'0600', 'businessWrites':0,
                  'versions':{}}
        for name,args in {'ocrmypdf':['ocrmypdf','--version'], 'tesseract':['tesseract','--version'],
                          'poppler':['pdftotext','-v'], 'ghostscript':['gs','--version']}.items():
            p=subprocess.run(args,capture_output=True,text=True)
            report['versions'][name]=(p.stdout+p.stderr).splitlines()[0]
        print(json.dumps(report,indent=2))
if __name__ == '__main__': main()
