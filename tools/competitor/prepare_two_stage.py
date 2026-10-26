"""Explicit 402 source bindings and a complete source asset inventory."""
import json,sys,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'work/two-stage-20261025';WORK.mkdir(parents=True,exist_ok=True)
RAW=ROOT/'reference-projects/competitor-goose/2026-10-25-complete'
CACHE=Path('C:/Users/123/AppData/Roaming/Tencent/WechatGameCenter/radium/users/dd647c18de157b29177f70d4b724ca3a/applet/local/wxb98ac240fd74b0e3/usr/__GAME_FILE_CACHE')
sys.path.insert(0,'C:/Users/123/.codex/visualizations/2026/10/21/01a15f1e-af66-7022-bd6a-105254709b3b/competitor-goose/deps')
def read(p):return json.loads(p.read_text('utf-8-sig'))
def save(p,x):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n','utf8')
table=read(ROOT/'competitor-analysis/artifacts/competitor-config-trace/serialized-verified/LevelData.json')['dataArray']
bindings=[('breakfast',8,'MainLevel'),('barbecue',5,'MainLevel'),('countryside',1,'MainLevel'),('grocery',4,'MainLevel'),('toys',19181,'GooseToysSpLevel')]
profiles=[];wanted=set()
for theme,index,mode in bindings:
    stages=[]
    for stage in [1,2]:
        rows=[r for r in table if r['_index']==index and r['_gametype']==mode and r['_level']==stage]
        if theme=='toys' and stage==1:
            rows=[dict(_namelist=['Goose_GTNumberBlock','GTCrocodile','GTDinosaur'],_wintype=[1],_wincount=[3],_othertypeweight=[1,1],_cancreatetype=[2,3],_sumcount=12,_typecount=2,_height=6,_limittime=[0],_limitheight=4,_scenesize=1.1,_sceneobj='GooseToys')]
        assert rows,(theme,stage)
        wanted.update(rows[0]['_namelist'])
        stages.append(dict(stage=stage,custom=theme=='toys' and stage==1,sourceIndex=index,sourceMode=mode,rows=rows))
    profiles.append(dict(theme=theme,stages=stages))
sources={}
for src in (ROOT/'reference-projects/competitor-goose').glob('*/models/*/source.json'):
    d=read(src);name=d['id']
    if name in wanted and (src.parent/(name+'.blend')).exists():sources.setdefault(name,str(src.relative_to(ROOT)))
save(WORK/'source-profiles.json',profiles);save(WORK/'existing-sources.json',sources)
missing=wanted-sources.keys();save(WORK/'missing-source-names.json',sorted(missing))
if '--scan' in sys.argv:
    import UnityPy
    entries=[];allentries=[];errors=[]
    files=list(CACHE.rglob('*.bundle'))+list(CACHE.glob('*.bin'))
    for path in files:
        try:
            env=UnityPy.load(path.read_bytes())
            for name,ptr in list(env.container.items()):
                if not name.lower().endswith('.prefab'):continue
                row=dict(path=name,bundle=path.name,file=str(path),type=ptr.type.name)
                allentries.append(row)
                if Path(name).stem in missing:entries.append(row)
        except Exception as e:errors.append(dict(file=str(path),error=str(e)))
    save(WORK/'resource-audit.json',dict(containers=entries,errors=errors))
    save(WORK/'all-prefabs.json',dict(containers=allentries,errors=errors))
    save(WORK/'barbecue-prefabs.json',[])
    found={Path(x['path']).stem for x in entries}
    print(json.dumps(dict(required=len(wanted),existing=len(sources),found=len(found),unavailable=sorted(missing-found),prefabs=len(allentries),errors=errors),ensure_ascii=False))
else:print(json.dumps(dict(required=len(wanted),existing=len(sources),missing=sorted(missing))))
