"""Read frozen competitor lighting/materials and current Unity appearance losses."""
import collections,hashlib,json,math,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'work/appearance-analysis-20261025';OUT.mkdir(parents=True,exist_ok=True)
sys.path.insert(0,'C:/Users/123/.codex/visualizations/2026/10/21/01a15f1e-af66-7022-bd6a-105254709b3b/competitor-goose/deps')
import UnityPy
from UnityPy.export.ShaderConverter import export_shader
from PIL import Image
def read(p):return json.loads(p.read_text('utf-8-sig'))
def save(name,x):(OUT/name).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
source=ROOT/'competitor-analysis/artifacts/competitor-config-trace/source/6f7a2014e3c0092b.webgl.data.unityweb.bin'
env=UnityPy.load(str(source));objects=[];shaderErrors=[]
for obj in env.objects:
    if obj.type.name=='Shader':
        try:data=obj.read();parsed=getattr(data,'m_ParsedForm',None);name=getattr(parsed,'m_Name','')
        except Exception as e:
            shaderErrors.append(dict(pathId=obj.path_id,assetsFile=obj.assets_file.name,error=str(e)));continue
        if name in {'ToonLite1','ToonLite1MulMatcap','ToonGlass','ToonGlassCus'}:
            try:
                shader=export_shader(data);folder=OUT/'compiled-shaders';folder.mkdir(exist_ok=True)
                (folder/(name+'.txt')).write_text(shader,encoding='utf-8')
            except Exception as e:save(name+'-shader-export-error.json',{'error':str(e)})
        continue
    if obj.type.name not in {'Light','RenderSettings','QualitySettings'}:continue
    try:
        tree=obj.read_typetree();name=None
        transforms=[]
        if obj.type.name=='Light':
            gameObject=obj.read().m_GameObject.read();name=gameObject.m_Name
            for component in gameObject.m_Component:
                if component.component.type.name=='Transform':transforms.append(component.component.read_typetree())
        objects.append(dict(type=obj.type.name,name=name,pathId=obj.path_id,assetsFile=obj.assets_file.name,data=tree,transforms=transforms))
    except Exception as e:objects.append(dict(type=obj.type.name,pathId=obj.path_id,error=str(e)))
save('competitor-lighting.json',dict(source=str(source),sourceSha256=sha(source),objects=objects))
save('shader-export-errors.json',shaderErrors)
materials=[]
for date in ['2026-10-22','2026-10-23']:
    for p in (ROOT/'reference-projects/competitor-goose'/date/'models').glob('*/source.json'):
        x=read(p)
        for key,m in x.get('materials',{}).items():
            materials.append(dict(date=date,id=x['id'],materialId=key,source=p.relative_to(ROOT).as_posix(),sourceSha256=sha(p),**m))
save('competitor-materials.json',materials)
selected=read(ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data/reference-lab.json')['theme']['items']
toys=[m for m in materials if 'ref_'+m['id'].lower() in selected]
atlases=[]
base=ROOT/'source-assets/models/candidates/mobile-runtime-20261024'
for p in base.glob('*/atlas-input.json'):
    x=read(p);g=1
    while g*g<len(x['materials']):g*=2
    image=Image.open(p.parent/'albedo.png');rows=[]
    for m in x['materials']:
        if m.get('texture'):
            src=Path(m['texture']);im=Image.open(src)
            rows.append(dict(source=src.relative_to(ROOT).as_posix(),sourceDimensions=list(im.size),usableTilePixels=image.width//g-6))
    atlases.append(dict(id=p.parent.name,materials=len(x['materials']),grid=g,atlasDimensions=list(image.size),texturedInputs=rows))
save('current-atlas-audit.json',atlases)
summary=dict(scope='Frozen package settings and extracted material samples, not account runtime settings or connected phone capture.',
             materials=len(materials),toySampleMaterials=len(toys),toyShaderCounts=dict(collections.Counter(m.get('shader') for m in toys)),
             toyTextureSlots=dict(collections.Counter(k for m in toys for k in m.get('textures',{}))),
             toyNormalMapToggleCounts=dict(collections.Counter(str(m.get('floats',{}).get('_IsUseNormalMap')) for m in toys)),
             toyBaseTextureSizes=dict(collections.Counter(str([m['textures']['_BaseColor']['width'],m['textures']['_BaseColor']['height']]) for m in toys if '_BaseColor' in m.get('textures',{}))),
             currentShader=sha(ROOT/'projects/catch-big-goose-unity/Assets/Resources/GooseItemMobile.shader'))
save('summary.json',summary)
print(json.dumps(summary,ensure_ascii=False))
for obj in objects:
    if obj['type']=='Light':
        t=obj['data'];print('LIGHT',obj['name'],obj['pathId'],json.dumps({k:t[k] for k in ['m_Enabled','m_Type','m_Color','m_Intensity','m_Shadows'] if k in t}))
    if obj['type']=='RenderSettings':
        t=obj['data'];print('ENV',obj['assetsFile'],json.dumps({k:v for k,v in t.items() if any(s in k for s in ['Ambient','Sun','Reflection','Fog'])})[:1600])
