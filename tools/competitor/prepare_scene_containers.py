"""Keep source container render meshes; exclude debug walls and background quads."""
from pathlib import Path
import json,shutil,hashlib
ROOT=Path(__file__).resolve().parents[2];RAW=ROOT/'reference-projects/competitor-goose/2026-10-25-scenes';OUT=ROOT/'reference-projects/competitor-goose/2026-10-25-containers';models=[]
specs={'barbecue':('Barbecue',{'BarbecueKaojiaoMa','BarbecueFireMa','BarbecueNetMa','BarbecueIronTableMa'}),'breakfast':('Breakfast',{'woodBoxBottom','woodBox'}),'countryside':('CountrysideStove',{'FireTableMetalMa','ZaotaiMa'}),'toys':('GooseToys',{'ChildhoodToys_Box_Outside','ChildhoodToys_Box_Inside'}),'grocery':('GroceryStore',{'StoreBoxMa'})}
for theme,(name,allowed) in specs.items():
    src=RAW/'models'/name/'source.json';d=json.loads(src.read_text('utf8'));mid='scene_'+theme
    meshes=[m for m in d['meshes'] if set(d['materials'][k]['name'] for k in m['materials']).issubset(allowed) and not(theme=='countryside' and m['name']=='Plane')]
    used={k for m in meshes for k in m['materials']};assert meshes
    d.update(id=mid,meshes=meshes,materials={k:v for k,v in d['materials'].items() if k in used},triangles=sum(len(t) for m in meshes for t in m['triangles']),sourceScene=name,sourceSha256=hashlib.sha256(src.read_bytes()).hexdigest())
    dest=OUT/'models'/mid;dest.mkdir(parents=True,exist_ok=True)
    for p in src.parent.glob('*.png'):shutil.copy2(p,dest/p.name)
    (dest/'source.json').write_text(json.dumps(d,ensure_ascii=False,indent=2),'utf8');models.append(dict(id=mid,triangles=d['triangles']))
    # Preserve source floor imagery separately; never bake it into the normalized container.
    floor=next((m for m in json.loads(src.read_text('utf8'))['materials'].values() if any(n in m['name'].lower() for n in ['floorma','dimian','woodwall'])),None)
    if floor:
        tex=floor['textures'].get('_BaseColor') or floor['textures'].get('_MainTex')
        if tex:
            target=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Textures/story-scenes';target.mkdir(exist_ok=True);shutil.copy2(src.parent/tex['file'],target/(theme+'-ground.png'))
(OUT/'manifest.json').write_text(json.dumps(dict(models=models),indent=2),'utf8')
(ROOT/'work/two-stage-20261025/scene-ids.json').write_text(json.dumps([m['id'] for m in models]),'utf8')
print(json.dumps(models))
