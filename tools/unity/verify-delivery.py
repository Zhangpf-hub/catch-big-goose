"""Audit the installed Unity delivery and record reproducible evidence."""
import datetime, hashlib, json
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'work/unity-migration'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    errors, sources = [], []
    for manifest in ['source-manifest.json', 'video-manifest.json']:
        entries = json.loads((ROOT / 'projects/catch-big-goose-unity/SourceAssets' / manifest).read_text(encoding='utf-8'))
        for item in entries:
            source, target = ROOT / item['source'], ROOT / 'projects/catch-big-goose-unity' / item['target']
            expected = item.get('sourceSha256', item.get('sha256'))
            if sha(source) != expected or sha(target) != item['targetSha256']:
                errors.append('Resource hash mismatch: ' + str(target))
        sources.append(dict(manifest=manifest, checked=len(entries)))
    qa = json.loads((WORK / 'acceptance/acceptance.json').read_text(encoding='utf-8'))
    tests = ET.parse(WORK / 'editmode-results.xml').getroot()
    dll = ROOT / 'projects/catch-big-goose-unity/Builds/Windows/catch-big-goose_Data/Managed/CatchGoose.dll'
    if not dll.exists():
        candidates = list((dll.parent).glob('*.dll'))
        dll = next(p for p in candidates if b'CatchGoose.GooseGame' in p.read_bytes() or b'GooseGame' in p.read_bytes())
    data = dll.read_bytes()
    qa_absent = all(name not in data for name in (b'GooseAcceptance', b'GooseAlgorithmAcceptance'))
    if not qa['passed'] or qa['errors']: errors.append('Runtime QA failed')
    if tests.attrib['result'] != 'Passed' or tests.attrib['failed'] != '0': errors.append('EditMode tests failed')
    if not qa_absent: errors.append('Release contains QA classes')
    release = ROOT / 'projects/catch-big-goose-unity/Builds/Windows/catch-big-goose.exe'
    probe = json.loads((WORK / 'mcp-verification.json').read_text(encoding='utf-8'))
    play_ok = all(probe.get('playCheck', {}).get(name, {}).get('structuredContent', {}).get('success') is True
                  for name in ('play', 'hierarchy', 'stop'))
    if not play_ok: errors.append('MCP play/stop verification missing')
    if not (WORK / 'release-mouse-pause.png').exists(): errors.append('Manual screenshot missing')
    report = dict(timestamp=datetime.datetime.now().astimezone().isoformat(), passed=not errors,
        unityVersion=qa['unityVersion'], resources=sources, runtimeChecks=len(qa['checks']),
        editModeTests=int(tests.attrib['passed']), release=str(release), releaseExeSha256=sha(release),
        releaseAssembly=str(dll), releaseAssemblySha256=sha(dll), releaseQaClassesAbsent=qa_absent,
        mcpToolCount=len(probe['tools']), mcpConsoleCallSucceeded=probe['console']['structuredContent']['success'], mcpPlayCheckPassed=play_ok,
        manualMouseEvidence='release-mouse-pause.png', errors=errors)
    (WORK / 'delivery-verification.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if errors: raise SystemExit(1)

if __name__ == '__main__':
    main()
