"""Verify R2 evidence, source and actual exported package hashes."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'竞品分析/证据/2026-10-24-场景物件比例修正'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
errors=[]
for x in read(OUT/'文件校验.json'):
    if sha(OUT/x['path'])!=x['sha256']:errors.append('archive: '+x['path'])
for x in read(OUT/'source-map.json'):
    if sha(ROOT/x['current'])!=x['sha256']:errors.append('current: '+x['current'])
for x in read(OUT/'wechat/exported-files.json'):
    if sha(ROOT/'unity/Builds/WeChat/minigame'/x['path'])!=x['sha256']:errors.append('export: '+x['path'])
summary=read(OUT/'验证汇总.json')
assert summary['passed'] and summary['ownWins']==15 and summary['referenceWins']==2 and summary['projectionScenes']==21 and summary['unchangedStockAndWeights']
print(json.dumps(dict(passed=not errors,errors=errors,build=summary['build']),ensure_ascii=False))
if errors:raise SystemExit(1)
