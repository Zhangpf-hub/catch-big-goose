"""Read camera/transform evidence from frozen competitor data; no runtime overrides inferred."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,'C:/Users/123/.codex/visualizations/2026/10/21/01a15f1e-af66-7022-bd6a-105254709b3b/competitor-goose/deps')
import UnityPy
source=ROOT/'competitor-analysis/artifacts/competitor-config-trace/source/6f7a2014e3c0092b.webgl.data.unityweb.bin'
env=UnityPy.load(str(source));rows=[]
def name(pointer):
    try:return pointer.read().m_Name
    except Exception:return None
for obj in env.objects:
    if obj.type.name!='Camera':continue
    data=obj.read();tree=obj.read_typetree()
    transforms=[]
    for component in data.m_GameObject.read().m_Component:
        pointer=component.component
        try:
            if pointer.type.name in {'Transform','RectTransform'}:transforms.append(pointer.read_typetree())
        except Exception:pass
    rows.append(dict(pathId=obj.path_id,assetsFile=obj.assets_file.name,name=name(data.m_GameObject),
                     camera={k:v for k,v in tree.items() if any(term in k.lower() for term in ['orthographic','field of view','fov','viewport','rect','clip','enabled','depth'])},transforms=transforms))
level=json.loads((ROOT/'competitor-analysis/artifacts/competitor-config-trace/serialized-verified/LevelManager.json').read_text('utf-8'))
level={k:v for k,v in level.items() if any(term in k.lower() for term in ['size','scale','camera','boxtrans','maincontent','depth'])}
transforms={}
objects={obj.path_id:obj for obj in env.objects if obj.assets_file.name=='sharedassets0.assets'}
def resolve_transform(path_id):
    key=str(path_id)
    if key in transforms or path_id not in objects:return
    obj=objects[path_id]
    if obj.type.name not in {'Transform','RectTransform'}:return
    tree=obj.read_typetree();transforms[key]=tree
    tree['resolvedName']=name(obj.read().m_GameObject)
    parent=tree.get('m_Father',{}).get('m_PathID',0)
    if parent:resolve_transform(parent)
for value in level.values():
    if isinstance(value,dict) and value.get('m_FileID')==0:resolve_transform(value.get('m_PathID',0))
output=ROOT/'work/scale-alignment-20261024';output.mkdir(parents=True,exist_ok=True)
(output/'competitor-camera-transforms.json').write_text(json.dumps(dict(source=str(source),sha256=hashlib.sha256(source.read_bytes()).hexdigest(),cameras=rows,levelManager=level,referencedTransforms=transforms),ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(dict(cameras=len(rows),rows=[{k:v for k,v in r.items() if k!='transforms'} for r in rows],levelManager=level),ensure_ascii=False)[:5000])
