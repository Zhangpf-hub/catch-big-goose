"""Snapshot the real game into a separate Windows QA project; never publish assets."""
from pathlib import Path
import hashlib, json, shutil

ROOT=Path(__file__).resolve().parents[2]
ACTIVE=ROOT/'projects/catch-big-goose-unity'
OUT=ROOT/'work/duck-b2-gameplay-qa'
BATCH=ROOT/'source-assets/models/candidates/duck-series-v1/model-review-b2'
IDS={'duck-eggtart':'ref_goose_eggtart','duck-steelcup':'ref_goose_steelcup','duck-numberblock':'ref_goose_gtnumberblock'}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
if (OUT/'Temp/UnityLockfile').exists():raise RuntimeError('QA Unity project is open')
snap={}
for folder in ('Assets/Scripts','Assets/Resources','Assets/Scenes','Assets/Mascots','Assets/MobileContact','Assets/StreamingAssets','ProjectSettings'):
    src=ACTIVE/folder;dst=OUT/folder
    if src.exists():
        shutil.copytree(src,dst,dirs_exist_ok=True)
        for p in src.rglob('*'):
            if p.is_file():
                rel=p.relative_to(ACTIVE).as_posix();snap[rel]=sha(p)
                assert sha(OUT/rel)==snap[rel]
(OUT/'Packages').mkdir(exist_ok=True)
for name in ('manifest.json','packages-lock.json'):
    src=ACTIVE/'Packages'/name
    if src.exists():shutil.copy2(src,OUT/'Packages'/name)
editor=OUT/'Assets/Editor';editor.mkdir(exist_ok=True)
shutil.copy2(ACTIVE/'Assets/Editor/GoosePlayerNetworkPolicy.cs',editor/'GoosePlayerNetworkPolicy.cs')
for name,dest in [('DuckB2GameplayBuild.cs',editor),('DuckB2GameplayAcceptance.cs',OUT/'Assets/Scripts'),('GooseDuckMobile.shader',OUT/'Assets/Resources')]:
    shutil.copy2(Path(__file__).with_name(name),dest/name)
# Preserve only the new duck shader through the existing mobile material cache.
cache=OUT/'Assets/Scripts/GooseAssetCache.cs';text=cache.read_text('utf-8')
before='if(original.shader.name.StartsWith("Goose/Reference"))continue;'
after='if(original.shader.name.StartsWith("Goose/Reference") || original.shader.name=="Goose/DuckMobile")continue;'
assert text.count(before)==1
cache.write_text(text.replace(before,after),'utf-8')
inputs=[]
for id,ref in IDS.items():
    dest=OUT/'Assets/Resources/Models'/id;dest.mkdir(exist_ok=True)
    for name in (id+'.fbx','albedo.png','unity-metallic.png'):
        src=BATCH/'models'/id/name;shutil.copy2(src,dest/name)
        inputs.append({'source':str(src.relative_to(ROOT)),'sha256':sha(src)})
    hullSrc=BATCH/'qa/unity-import'/(id+'-collision.fbx')
    hullDest=OUT/'Assets/duck-collision-inputs';hullDest.mkdir(exist_ok=True)
    shutil.copy2(hullSrc,hullDest/hullSrc.name)
    src=BATCH/'renders'/id/'duck/icon-192.png'
    shutil.copy2(src,OUT/'Assets/Resources/Icons'/(id+'.png'))
    inputs.append({'source':str(hullSrc.relative_to(ROOT)),'sha256':sha(hullSrc)})
# The QA copies inherit the measured same-size competitor presentation scale.
sizes=OUT/'Assets/Resources/Data/item-presentation.json'
data=json.loads(sizes.read_text('utf-8'));lookup={i['id']:i for i in data['items']}
data['items']=[i for i in data['items'] if i['id'] not in IDS]
for id,ref in IDS.items():
    scale=lookup[ref]['scale'] if ref in lookup else 1
    data['items'].append({'id':id,'scale':scale,'evidence':'QA candidate: same unit extent and presentation scale as '+ref+(' (runtime default 1)' if ref not in lookup else '')})
sizes.write_text(json.dumps(data,ensure_ascii=False,indent=2),'utf-8')
changed=[rel for rel,h in snap.items() if sha(ACTIVE/rel)!=h]
assert not changed,('Active project changed during snapshot',changed)
(OUT/'source-snapshot.json').write_text(json.dumps({'activeProject':str(ACTIVE),'sourceFiles':snap,
    'qaOnlyPatches':['Assets/Scripts/GooseAssetCache.cs','Assets/Resources/Data/item-presentation.json'],
    'candidateInputs':inputs,'formalProjectModified':False},indent=2),'utf-8')
print(json.dumps({'project':str(OUT),'snapshotFiles':len(snap),'candidateModels':len(IDS)}))
