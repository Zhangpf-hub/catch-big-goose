"""Stage only validated reference candidates; retain old GUIDs and archive R2 assets."""
import hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
CANDIDATE=ROOT/'assets-3d/candidates/reference-look-20261025'
validation=json.loads((CANDIDATE/'validation.json').read_text('utf-8'));assert validation['passed']
BACKUP=ROOT/'unity/SourceAssets/ReferenceLookBaseline-20261025'
for row in validation['models']:
    mid=row['id'];folder=ROOT/'unity/Assets/Resources/Models'/mid
    for name,key in [(mid+'.glb','sha256'),(mid+'.fbx','fbxSha256'),('materials.json','materialSha256')]:
        assert hashlib.sha256((CANDIDATE/mid/name).read_bytes()).hexdigest()==row[key],name
    assert folder.resolve().is_relative_to((ROOT/'unity/Assets/Resources/Models').resolve())
    backup=BACKUP/'original-models'/mid
    if not backup.exists():shutil.copytree(folder,backup)
    for old in list(folder.iterdir()):
        if old.is_file() and (old.suffix in {'.mat','.png'} or old.name.endswith(('.mat.meta','.png.meta'))):
            target=BACKUP/'retired'/mid/old.name;target.parent.mkdir(parents=True,exist_ok=True)
            if not target.exists():shutil.move(old,target)
    for name in [mid+'.fbx','materials.json']:shutil.copy2(CANDIDATE/mid/name,folder/name)
textures=json.loads((CANDIDATE/'texture-sources.json').read_text('utf-8'))
destination=ROOT/'unity/Assets/Resources/ReferenceTextures';destination.mkdir(exist_ok=True)
for name,info in textures.items():
    assert hashlib.sha256((CANDIDATE/'textures'/name).read_bytes()).hexdigest()==info['sha256'],name
    shutil.copy2(CANDIDATE/'textures'/name,destination/name)
shutil.copy2(CANDIDATE/'model-contract.json',ROOT/'unity/Assets/Resources/Data/reference-material-models.json')
report=dict(models=len(validation['models']),materials=sum(x['materials'] for x in validation['models']),textures=len(textures),backup=str(BACKUP),scope='All active cached reference props; current theme selection/weights retained; original FBX GUIDs retained.')
(ROOT/'work/reference-look-20261025/staging.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(report,ensure_ascii=False))
