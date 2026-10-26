"""Install verified competitor items and scene catalogs with a reversible baseline."""
from pathlib import Path
import json,shutil,hashlib,statistics
ROOT=Path(__file__).resolve().parents[2]
CAND=ROOT/'source-assets/models/candidates/competitor-runtime-20261025'
RES=ROOT/'projects/catch-big-goose-unity/Assets/Resources'
ARCHIVE=ROOT/'projects/catch-big-goose-unity/SourceAssets/BeforeCompetitorReplacement-20261025'
WORK=ROOT/'competitor-analysis/artifacts/competitor-replacement-20261025'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def save(p,v):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(a,b):b.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(a,b)
validation=read(CAND/'validation.json');assert validation['passed']
metrics=read(CAND/'batch-results.json');valid={x['id']:x for x in validation['models']}
for m in metrics:
    assert valid[m['id']]['sha256']==sha(CAND/m['id']/(m['id']+'.glb'))
    assert (CAND/m['id']/'icon-192.png').exists()
for name in ['themes.json','item-presentation.json','reference-lab.json']:
    dest=ARCHIVE/'Data'/name
    if not dest.exists():copy(RES/'Data'/name,dest)
baseline=read(ARCHIVE/'Data/themes.json')
oldids=set(i for t in baseline['themes'] for i in t['items'])
# Copy the old mesh, material, icon and physics metadata before any replacement.
for id in sorted(oldids):
    for kind in ['Models','Icons','Physics']:
        source=RES/kind/(id if kind=='Models' else id+('.png' if kind=='Icons' else '.asset'))
        dest=ARCHIVE/kind/source.name
        if source.exists() and not dest.exists():
            if source.is_dir():shutil.copytree(source,dest)
            else:copy(source,dest)
        meta=Path(str(source)+'.meta')
        if meta.exists() and not Path(str(dest)+'.meta').exists():copy(meta,Path(str(dest)+'.meta'))
for m in metrics:
    id=m['id'];source=CAND/id;dest=RES/'Models'/id;dest.mkdir(parents=True,exist_ok=True)
    # Preserve the richer, separately validated source-material reconstruction.
    existing=read(dest/'materials.json') if (dest/'materials.json').exists() else {}
    protected=any(x.get('referenceMaterial') for x in existing.get('materials',[]))
    if not protected:
        for name in [id+'.fbx','albedo.png','materials.json']:copy(source/name,dest/name)
    copy(source/'icon-192.png',RES/'Icons'/(id+'.png'))

specs=[('breakfast','早餐铺','Breakfast','ref_bfxiaolongbao','tray_dessert','bg_redwood',False,1.72),
       ('barbecue','烧烤摊','Barbecue','ref_grilledcorn','tray_electronics','bg_redwood',False,1.72),
       ('countryside','乡村小院','Countryside','ref_corn','basket_farm','bg_farm',True,1.60),
       ('toys','童年玩具','ChildhoodToys26Obj','ref_gtcrocodile','basket_redwood','bg_farm',False,1.72),
       ('grocery','杂货铺','GroceryStore','ref_toycar','basket_redwood','bg_redwood',False,1.72)]
tableFile=ROOT/'competitor-analysis/artifacts/competitor-config-trace/serialized-verified/LevelData.json'
table=read(tableFile)['dataArray'];themes=[];bindings=[]
sizes=read(RES/'Data/item-presentation.json');bySize={x['id']:x for x in sizes['items']}
for id,name,scene,icon,container,background,circular,half in specs:
    rows=[m for m in metrics if read(CAND/m['id']/'provenance.json')['scene']==scene and m['id']!='goose']
    names=[read(CAND/m['id']/'provenance.json')['sourceId'] for m in rows]
    choices=[x for x in table if x['_level']==2 and len(x['_namelist'])==len(x['_othertypeweight'])]
    source=max(choices,key=lambda x:(len(set(names)&set(x['_namelist'])),x['_gametype']=='MainLevel'))
    assert set(names).issubset(source['_namelist']),scene
    weights=[source['_othertypeweight'][source['_namelist'].index(n)] for n in names]
    assert all(w>0 for w in weights)
    themes.append(dict(id=id,name=name,icon=icon,items=[m['id'] for m in rows],background=background,container=container,
                       circular=circular,halfX=half,halfZ=half,coreGroupWeights=weights,
                       coreWeightEvidence='Exact source-name match to frozen LevelData; cached subset, project stock and container adaptation.'))
    median=statistics.median(max(m['sourceDimensions']) for m in rows)
    for m,n,w in zip(rows,names,weights):
        bySize[m['id']]=dict(id=m['id'],scale=round(max(.65,min(1.55,max(m['sourceDimensions'])/median)),4),evidence='Source authored extent / scene median; clamped for project board')
        bindings.append(dict(theme=id,id=m['id'],sourceName=n,weight=w,sourceIndex=source['_index'],sourceGameType=source['_gametype'],sourceLevel=2,sourceOrdinal=source['_namelist'].index(n)))
save(RES/'Data/themes.json',dict(themes=themes));save(RES/'Data/item-presentation.json',dict(items=list(bySize.values())))
save(WORK/'weight-bindings.json',dict(sourceSha256=sha(tableFile),bindings=bindings))
save(RES/'Data/competitor-models.json',dict(date='2026-10-25',models=[read(CAND/m['id']/'provenance.json') for m in metrics]))
save(WORK/'staging.json',dict(models=len(metrics),themes=[dict(id=t['id'],name=t['name'],count=len(t['items'])) for t in themes],baseline=str(ARCHIVE.relative_to(ROOT))))
print('Staged',len(metrics),'models:',[(t['name'],len(t['items'])) for t in themes])
