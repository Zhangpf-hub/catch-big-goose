"""Capture a self-contained Unity source project while other tasks keep editing."""
import hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];SOURCE=ROOT/'projects/catch-big-goose-unity';OUT=ROOT/'work/home-stickers-20261025';FROZEN=OUT/'frozen-project'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def manifest():
    return {p.relative_to(SOURCE).as_posix():sha(p)for folder in ['Assets','Packages','ProjectSettings','SourceAssets']for p in (SOURCE/folder).rglob('*')if p.is_file()}
if FROZEN.exists():raise SystemExit('Frozen snapshot already exists; preserve it and use a new revision directory.')
before=manifest();FROZEN.mkdir(parents=True)
for folder in ['Assets','Packages','ProjectSettings','SourceAssets']:shutil.copytree(SOURCE/folder,FROZEN/folder,dirs_exist_ok=True)
shutil.copy2(SOURCE/'WeChatBuild.local.json',FROZEN/'WeChatBuild.local.json')
after=manifest()
if before!=after:raise RuntimeError('Source changed during snapshot; repeat capture before building')
(OUT/'frozen-source-input.json').write_text(json.dumps(after,indent=2),encoding='utf-8')
# Confirmed no code/data path references and no Unity GUID references. Preserve originals.
retired=[]
for name in ['market-courtyard.png','barbecue-ground.png','toys-ground.png','countryside-ground.png','coral-button.png','mint-button.png','lavender-button.png']:
    p=next((FROZEN/'Assets/Resources/Textures').rglob(name),None)
    if p is None:continue
    rel=p.relative_to(FROZEN)
    for item in [p,p.with_name(p.name+'.meta')]:
        destination=OUT/'retired-unused'/item.relative_to(FROZEN);destination.parent.mkdir(parents=True,exist_ok=True);shutil.move(item,destination)
    retired.append(str(rel))
(OUT/'retired-unused.json').write_text(json.dumps(retired,indent=2),encoding='utf-8')
print(json.dumps({'frozenFiles':len(after),'retiredUnusedTextures':retired}))
