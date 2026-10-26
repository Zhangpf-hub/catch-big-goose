"""Verify frozen R3 evidence against current sources and actual exported files."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'competitor-analysis/evidence/2026-10-25-材质模型光照迁移'

def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None

errors = []
for row in read(OUT / '文件校验.json'):
    if sha(OUT / row['path']) != row['sha256']:
        errors.append('archive: ' + row['path'])
for row in read(OUT / 'source-map.json'):
    if sha(ROOT / row['current']) != row['sha256']:
        errors.append('source: ' + row['current'])
for path, digest in read(OUT / 'source-inputs.json').items():
    if sha(ROOT / path) != digest:
        errors.append('input: ' + path)
for category, current in [('wechat', 'builds/catch-big-goose-wechat'), ('native', 'projects/catch-big-goose-unity/Builds/ReferenceLook')]:
    for row in read(OUT / category / 'exported-files.json'):
        if sha(ROOT / current / row['path']) != row['sha256']:
            errors.append(category + ': ' + row['path'])
summary = read(OUT / '验证汇总.json')
assert summary['passed'] and summary['models'] == 80 and summary['sourceMaterials'] == 102
assert summary['ownWins'] == 15 and summary['referenceWins'] == 2
print(json.dumps(dict(passed=not errors, build=summary['build'], errors=errors), ensure_ascii=False))
if errors:
    raise SystemExit(1)
