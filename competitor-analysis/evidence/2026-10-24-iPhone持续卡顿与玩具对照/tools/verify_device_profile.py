"""Verify the frozen R1 evidence and its correspondence to current source/export."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT/'竞品分析/证据/2026-10-24-iPhone持续卡顿与玩具对照'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None

def read(p):
    return json.loads(p.read_text(encoding='utf-8-sig'))

errors=[]
for row in read(OUT/'文件校验.json'):
    if sha(OUT/row['path']) != row['sha256']: errors.append('archive: '+row['path'])
for row in read(OUT/'source-map.json'):
    if sha(ROOT/row['current']) != row['sha256']: errors.append('source: '+row['current'])
for name in ['runtime-resource-files.json','candidate-file-hashes.json','original-input-hashes.json']:
    for row in read(OUT/name):
        if sha(ROOT/row['path']) != row['sha256']: errors.append(name+': '+row['path'])
for row in read(OUT/'wechat/exported-files.json'):
    if sha(ROOT/'unity/Builds/WeChat/minigame'/row['path']) != row['sha256']: errors.append('export: '+row['path'])
summary=read(OUT/'验证汇总.json')
assert summary['passed'] and summary['iPhoneAcceptancePassed'] is None
print(json.dumps(dict(passed=not errors, errors=errors, build=summary['build']), ensure_ascii=False))
if errors: raise SystemExit(1)
