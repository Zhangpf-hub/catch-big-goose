"""Stage only validated reference candidates; retain old GUIDs and archive R2 assets."""
import hashlib,json,shutil,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
CANDIDATE=ROOT/'source-assets/models/candidates/reference-look-20261025'
if '--root' in sys.argv:CANDIDATE=ROOT/sys.argv[sys.argv.index('--root')+1]
validation=json.loads((CANDIDATE/'validation.json').read_text('utf-8'));assert validation['passed']
BACKUP=ROOT/'projects/catch-big-goose-unity/SourceAssets/ReferenceLookBaseline-20261025'
policy=ROOT/'projects/catch-big-goose-unity/Assets/Editor/retired-resources.json'
retired=set(json.loads(policy.read_text('utf-8'))['retiredModelIds']) if policy.exists() else set()
validation['models']=[row for row in validation['models'] if row['id'] not in retired]
needed_textures=set()
for row in validation['models']:
    mid=row['id'];folder=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Models'/mid
    material_data=json.loads((CANDIDATE/mid/'materials.json').read_text('utf-8'))
    for material in material_data['materials']:
        for key in ['texture','matcap','matcap1','matcap2','mask','aoMap']:
            value=material.get(key)
            if value and value.startswith('ReferenceTextures/'):needed_textures.add(Path(value).name+'.png')
    for name,key in [(mid+'.glb','sha256'),(mid+'.fbx','fbxSha256'),('materials.json','materialSha256')]:
        assert hashlib.sha256((CANDIDATE/mid/name).read_bytes()).hexdigest()==row[key],name
    assert folder.resolve().is_relative_to((ROOT/'projects/catch-big-goose-unity/Assets/Resources/Models').resolve())
    backup=BACKUP/'original-models'/mid
    if folder.exists() and not backup.exists():shutil.copytree(folder,backup)
    folder.mkdir(parents=True,exist_ok=True)
    for old in list(folder.iterdir()):
        if old.is_file() and (old.suffix in {'.mat','.png'} or old.name.endswith(('.mat.meta','.png.meta'))):
            target=BACKUP/'retired'/mid/old.name;target.parent.mkdir(parents=True,exist_ok=True)
            if not target.exists():shutil.move(old,target)
    for name in [mid+'.fbx','materials.json']:shutil.copy2(CANDIDATE/mid/name,folder/name)
textures=json.loads((CANDIDATE/'texture-sources.json').read_text('utf-8'))
destination=ROOT/'projects/catch-big-goose-unity/Assets/Resources/ReferenceTextures';destination.mkdir(exist_ok=True)
assert needed_textures<=textures.keys(),needed_textures-textures.keys()
for name,info in textures.items():
    if name not in needed_textures:continue
    assert hashlib.sha256((CANDIDATE/'textures'/name).read_bytes()).hexdigest()==info['sha256'],name
    shutil.copy2(CANDIDATE/'textures'/name,destination/name)
if '--no-contract' not in sys.argv:
    contract=json.loads((CANDIDATE/'model-contract.json').read_text('utf-8'))
    contract['models']=[row for row in contract['models'] if row['id'] not in retired]
    (ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data/reference-material-models.json').write_text(json.dumps(contract,ensure_ascii=False,indent=2)+'\n','utf-8')
report=dict(models=len(validation['models']),materials=sum(x['materials'] for x in validation['models']),textures=len(needed_textures),backup=str(BACKUP),scope='All active cached reference props; current theme selection/weights retained; original FBX GUIDs retained.')
(ROOT/'work/reference-look-20261025/staging.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(report,ensure_ascii=False))
