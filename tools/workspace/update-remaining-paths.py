"""Repair split path expressions that the initial literal migration cannot match."""
import json
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'work/structure-migration'
moves = json.loads((OUT / 'migration.json').read_text('utf-8'))['moves']
reports = {Path(m['source']).name: m['target'] for m in moves if m['target'].startswith('docs/development-reports/')}
helper = '''\n\ndef analysis_document(name):
    """Resolve current project reports separately from competitor research."""
    report = ROOT / 'docs/development-reports' / name
    return report if report.exists() else ROOT / 'competitor-analysis' / name
'''
count = 0
with zipfile.ZipFile(OUT / 'split-path-originals.zip', 'a', zipfile.ZIP_DEFLATED) as backup:
    for p in (ROOT / 'tools').rglob('*'):
        if p.suffix not in ['.py', '.ps1'] or p.parent.name == 'workspace':
            continue
        raw = p.read_bytes()
        text = raw.decode('utf-8-sig')
        updated = re.sub(r'([\x22\x27])竞品分析\1', r'\1competitor-analysis\1', text)
        updated = re.sub(r'\b(ANALYSIS|DEST)\s*/\s*([\x22\x27])证据', r'\1 / \2evidence', updated)
        updated = re.sub(r'\b(ANALYSIS|DEST)\s*/\s*([\x22\x27])历史', r'\1 / \2history', updated)
        def static_report(m):
            return 'ROOT / ' + repr(reports[m[3]]) if m[3] in reports else m[0]
        updated = re.sub(r'\b(ANALYSIS|DEST)\s*/\s*([\x22\x27])([^\x22\x27]+\.md)\2', static_report, updated)
        if re.search(r'\bANALYSIS\s*/\s*name\b', updated) or re.search(r"ROOT\s*/\s*'competitor-analysis'\s*/\s*name\b", updated):
            updated = re.sub(r'\bANALYSIS\s*/\s*name\b', 'analysis_document(name)', updated)
            updated = re.sub(r"ROOT\s*/\s*'competitor-analysis'\s*/\s*name\b", 'analysis_document(name)', updated)
            if 'def analysis_document(' not in updated:
                at = updated.find('\ndef ')
                updated = updated[:at] + helper + updated[at:]
        updated = updated.replace('Builds/Windows/CatchGoose.exe', 'Builds/Windows/catch-big-goose.exe')
        updated = updated.replace('Builds/Windows/CatchGoose_Data', 'Builds/Windows/catch-big-goose_Data')
        if updated != text:
            rel = p.relative_to(ROOT).as_posix()
            if rel not in backup.namelist():
                backup.writestr(rel, raw)
            p.write_text(updated, 'utf-8-sig' if p.suffix == '.ps1' else 'utf-8')
            count += 1
print('Remaining split path expressions updated:', count)
