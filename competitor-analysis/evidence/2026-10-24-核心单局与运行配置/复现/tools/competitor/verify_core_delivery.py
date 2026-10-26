"""Verify active chapter links, archived hashes, source snapshots and build output."""
import hashlib
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
DEST=ROOT/'竞品分析/证据/2026-10-24-核心单局与运行配置'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text('utf-8-sig'))
def main():
    broken=[];count=0
    docs=list((ROOT/'竞品分析').glob('*.md'))+[ROOT/'references/competitor-goose/2026-10-23-skinned/README.md']
    for doc in docs:
        for target in re.findall(r'\]\(([^)]+)\)',doc.read_text('utf-8')):
            if re.match(r'^[a-zA-Z]+:|^#',target):continue
            path=doc.parent/target.split('#')[0]
            count+=1
            if not path.exists():broken.append(dict(file=str(doc.relative_to(ROOT)),target=target))
    checked=0
    manifests=list((ROOT/'竞品分析/证据').glob('*/文件校验.json'))
    manifests += [ROOT/'references/competitor-goose'/d/'文件校验.json' for d in ['2026-10-23','2026-10-23-skinned']]
    for manifest in manifests:
        for entry in read(manifest):
            path=manifest.parent/entry['path']
            if not path.exists() or sha(path)!=entry['sha256']:raise RuntimeError('Integrity mismatch: '+str(path))
            checked+=1
    sources=read(DEST/'验证汇总.json')['runtimeSources']
    for name,value in sources.items():
        if sha(ROOT/'unity/Assets/Scripts'/name)!=value:raise RuntimeError('Runtime source changed: '+name)
    player=ROOT/'unity/Builds/Windows/CatchGoose.exe'
    report=dict(passed=not broken,activeLocalLinks=count,brokenLinks=broken,integrityFiles=checked,
                matchingRuntimeSources=len(sources),windowsPlayer=dict(path=str(player.relative_to(ROOT)),bytes=player.stat().st_size,sha256=sha(player)))
    if broken:raise RuntimeError(json.dumps(report,ensure_ascii=True))
    target=ROOT/'work/competitor-runtime-trace/delivery-verification.json'
    target.write_text(json.dumps(report,ensure_ascii=False,indent=2),'utf-8')
    print(json.dumps(report,ensure_ascii=True))

if __name__=='__main__':main()
