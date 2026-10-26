"""Combine only required source bundles in an isolated extraction directory."""
import json,shutil,sys,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];WORK=ROOT/'work/two-stage-20261025';INPUT=WORK/'inputs';INPUT.mkdir(exist_ok=True)
sys.path.insert(0,'C:/Users/123/.codex/visualizations/2026/10/21/01a15f1e-af66-7022-bd6a-105254709b3b/competitor-goose/deps')
import UnityPy
def read(p):return json.loads(p.read_text('utf-8-sig'))
def save(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n','utf8')
targets=set(read(WORK/'missing-source-names.json'));entries=read(WORK/'resource-audit.json')['containers'];downloads=[]
for p in (WORK/'downloads').glob('*.bundle'):
    env=UnityPy.load(p.read_bytes());downloads.append(dict(file=p.name,bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),url='https://cdn-zhuadae.lanfeitech.com/wx/prod/2.3/2.3.75/StreamingAssets/aa/WebGL/'+p.name))
    for name,ptr in list(env.container.items()):
        if Path(name).stem in targets:entries.append(dict(path=name,bundle=p.name,file=str(p)))
unique={e['path']:e for e in entries}
for e in unique.values():
    dest=INPUT/e['bundle']
    if not dest.exists():shutil.copy2(e['file'],dest)
assert {Path(e['path']).stem for e in unique.values()}==targets,targets-{Path(e['path']).stem for e in unique.values()}
save(WORK/'complete-audit.json',dict(containers=list(unique.values())))
save(WORK/'downloads.json',downloads)
print('All',len(targets),'missing sources located; bundles',len(list(INPUT.glob('*.bundle'))))
