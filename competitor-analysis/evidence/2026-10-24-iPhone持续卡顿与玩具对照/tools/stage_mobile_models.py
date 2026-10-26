"""Stage validated candidates; retain all replaced resources outside Assets."""
import hashlib
import json
import shutil
import statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
CAND=ROOT/'assets-3d/candidates/mobile-runtime-20261024'
RES=ROOT/'unity/Assets/Resources'
ARCHIVE=ROOT/'unity/SourceAssets/MobileBaseline-20261024'
def dump(p,x):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def within(p,root):assert p.resolve().is_relative_to(root.resolve()),p
def copy(src,dst):dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
validation=json.loads((CAND/'validation.json').read_text('utf-8'));assert validation['passed']
rows=json.loads((CAND/'batch-results.json').read_text('utf-8'))
ARCHIVE.mkdir(parents=True,exist_ok=True)
if not (ARCHIVE/'original-models').exists():shutil.copytree(RES/'Models',ARCHIVE/'original-models')
staged=[]
for row in rows:
    src=CAND/row['id'];dst=RES/'Models'/row['id'];dst.mkdir(parents=True,exist_ok=True)
    for old in list(dst.iterdir()):
        # Exact individual assets only, after verifying both resolved targets.
        if old.suffix.lower() not in {'.mat','.png','.jpg','.jpeg'} or old.name in {'albedo.png',row['id']+'_mobile.mat'}:continue
        target=ARCHIVE/'removed-runtime-materials'/row['id']/old.name;within(old,RES);within(target,ARCHIVE)
        target.parent.mkdir(parents=True,exist_ok=True)
        if not target.exists():shutil.move(str(old),str(target))
        meta=Path(str(old)+'.meta');meta_target=Path(str(target)+'.meta')
        if meta.exists() and not meta_target.exists():shutil.move(str(meta),str(meta_target))
    for name in [row['id']+'.fbx','materials.json','albedo.png']:copy(src/name,dst/name)
    if (src/'collision.fbx').exists():copy(src/'collision.fbx',ROOT/'unity/Assets/MobileContact'/(row['id']+'.fbx'))
    if row['reference']:
        source=Path(row['source']).parent;copy(source/'icon-192.png',RES/'Icons'/(row['id']+'.png'))
    staged.append(dict(id=row['id'],triangles=row['triangles'],sourceTriangles=row['sourceTriangles'],reference=row['reference']))
refs=[r for r in rows if r['reference']];median=statistics.median(max(r['sourceDimensions']) for r in refs)
scales={
 'watermelon':1.55,'pineapple':1.45,'coconut':1.2,'dragonfruit':1.1,'blueberry':.65,'cherry':.7,'strawberry':.82,'lemon':.9,'goose':1.25,
 'jadevase':1.45,'hulu':1.3,'ruyi':1.4,'yuxi':1.15,'banzhi':.65,'tongqian':.72,'yuzhuo':.95,
 'pumpkin':1.45,'cabbage':1.4,'corn':1.4,'carrot':1.3,'eggplant':1.25,'broccoli':1.2,'duck':1.25,'koi':1.3,'lotus':1.1,
 'cake_slice':1.35,'cupcake':1.15,'donut':1.15,'cookie':.8,'candy':.65,'macaron':.8,'popsicle':1.3,'icecream':1.35,'croissant':1.25,
 'radio':1.4,'alarmclock':1.2,'handheld':1.25,'camera':1.15,'phone':1.2,'earbuds':.75,'usbdisk':.65,'watch':.8,'battery':.75,'pencil':1.4,'charger':.85,
}
items=[dict(id=k,scale=v,evidence='Project adaptation: semantic relative sizes; not recovered competitor sizes') for k,v in scales.items()]
for row in refs:items.append(dict(id=row['id'],scale=round(max(.65,min(1.55,max(row['sourceDimensions'])/median)),4),evidence='Frozen toy authored extent / batch median; clamped to fit own board'))
dump(RES/'Data/item-presentation.json',dict(items=items))
dump(RES/'Data/reference-lab.json',dict(purpose='Local explicitly requested competitor-model experiment, separate from five original themes. Equal group stock is own control setup.',
 theme=dict(id='reference_toys',name='玩具对照',items=[r['id'] for r in refs],background='bg_farm',container='basket_farm',circular=True,halfX=1.6,halfZ=1.6)))
dump(ROOT/'work/device-profile-20261024/model-staging.json',dict(models=staged,originalArchive=str(ARCHIVE),referenceMedianExtent=median))
copy(Path('C:/Users/123/AppData/Local/Temp/codex-clipboard-23070d0a-9e30-45db-b5f8-19e032160001.png'),ROOT/'work/device-profile-20261024/competitor-iphone-screenshot.png')
print('Staged',len(rows),'models; original resources archived outside Assets')
