"""Verify the frozen interaction delivery against its live sources and package."""
import hashlib
import json
import re
from pathlib import Path
from urllib.parse import unquote

ROOT=Path(__file__).resolve().parents[2]
DEST=ROOT/'竞品分析/证据/2026-10-24-拾取与逐层出场'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
manifest=json.loads((DEST/'文件校验.json').read_text('utf-8'))
for row in manifest['files']:
    p=DEST/row['path']
    assert p.stat().st_size==row['bytes'] and sha(p)==row['sha256'],p
sources=0
for folder,pattern,target in [('unity/Assets/Scripts','*.cs','源码/Scripts'),('unity/Assets/Resources/Data','*.json','源码/Data')]:
    for p in (ROOT/folder).glob(pattern):
        assert sha(p)==sha(DEST/target/p.name),p
        sources+=1
links=0
for name in ['README.md','20-拾取入槽与逐层出场.md']:
    p=ROOT/'竞品分析'/name
    for target in re.findall(r'\[[^\]]*\]\(([^)\n]+)\)',p.read_text('utf-8')):
        if re.match(r'^[a-z]+:',target) or target.startswith('#'):continue
        target=unquote(target.split('#')[0].strip('<>'))
        assert (p.parent/target).exists(),(name,target)
        links+=1
assert sha(ROOT/'unity/Builds/WeChat/minigame/game.js')==sha(DEST/'微信/game.js')
summary=json.loads((DEST/'验证汇总.json').read_text('utf-8'))
assert summary['experienceRounds']==summary['experienceWins']==20
assert summary['failedClicks']==summary['outOfBounds']==0
result=dict(passed=True,hashedFiles=len(manifest['files']),liveSources=sources,localLinks=links,
            packageMatchesFrozenExport=True,phoneVerified=False)
(ROOT/'work/interaction-20261024/delivery-verification.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps(result))
