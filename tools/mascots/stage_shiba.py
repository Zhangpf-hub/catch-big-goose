"""Stage only a validated Shiba candidate, keeping Unity .meta identities."""
from pathlib import Path
import hashlib, json, shutil
root=Path(__file__).resolve().parents[2]
c=root/'source-assets/models/candidates/shiba-20261025-v1';u=root/'projects/catch-big-goose-unity/Assets'
report=json.loads((c/'qa/glb-validation.json').read_text())
assert report['passed'] and report['sha256']==hashlib.sha256((c/'model/shiba.glb').read_bytes()).hexdigest()
assert json.loads((c/'qa/geometry.json').read_text())['passed']
m=u/'Resources/Models/shiba';m.mkdir(parents=True,exist_ok=True)
h=u/'Mascots/Shiba';h.mkdir(parents=True,exist_ok=True)
for n in ['shiba.fbx','albedo.png','materials.json']:shutil.copy2(c/'model'/n,m/n)
shutil.copy2(c/'model/shiba-home.fbx',h/'shiba-home.fbx')
shutil.copy2(c/'model/icon-192.png',u/'Resources/Icons/shiba.png')
p=u/'Resources/Data/item-presentation.json';d=json.loads(p.read_text(encoding='utf8'))
entry={'id':'shiba','scale':1.35,'evidence':'Slender two-tone Shiba mascot; real pile and seven-slot tray acceptance.'}
found=next((i for i in d['items'] if i['id']=='shiba'),None)
if found: found.update(entry)
else:d['items'].append(entry)
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
print('Staged validated Shiba for Unity review; existing metadata retained.')
