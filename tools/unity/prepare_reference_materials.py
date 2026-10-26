"""Create an immutable, source-linked Unity reference-look candidate batch."""
import hashlib,json,shutil,argparse
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser();parser.add_argument('--root',default='source-assets/models/candidates/reference-look-20261025');parser.add_argument('--themes',default='projects/catch-big-goose-unity/Assets/Resources/Data/themes.json');parser.add_argument('--ids-file');args=parser.parse_args()
OUT=ROOT/args.root;OUT.mkdir(parents=True,exist_ok=True)
def save(p,x):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
ids=set(json.loads((ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data/reference-lab.json').read_text('utf-8'))['theme']['items'])
for theme in json.loads((ROOT/args.themes).read_text('utf-8'))['themes']:ids.update(x for x in theme['items'] if x.startswith('ref_'))
if args.ids_file:ids=set(json.loads((ROOT/args.ids_file).read_text('utf8')))
batch=[];textures={}
sources={}
for date in ['2026-10-25-containers','2026-10-25-complete-skinned','2026-10-25-complete','2026-10-25-runtime','2026-10-23-skinned','2026-10-23','2026-10-22']:
    for src in (ROOT/'reference-projects/competitor-goose'/date/'models').glob('*/source.json'):
        data=json.loads(src.read_text('utf-8'));mid=data['id'] if data['id'].startswith('scene_') else 'ref_'+data['id'].lower()
        if mid in ids and mid not in sources and (src.parent/(data['id']+'.blend')).exists():sources[mid]=src
assert ids==sources.keys(),ids-sources.keys()
for mid,src in sorted(sources.items()):
    data=json.loads(src.read_text('utf-8'));mid=data['id'] if data['id'].startswith('scene_') else 'ref_'+data['id'].lower()
    if mid not in ids:continue
    materials=[]
    for index,(key,raw) in enumerate(data['materials'].items()):
        floats=raw.get('floats',{});colors=raw.get('colors',{});tex=raw.get('textures',{})
        glass=raw['shader'] in ['ToonGlass','ToonGlassCus','CustomCrystal']
        def texture(slot):
            entry=tex.get(slot)
            if not entry:return None
            p=src.parent/entry['file'];digest=sha(p);name=('d_' if slot in ['_MatcapAreaSplit','_AOTex'] else 't_')+digest[:24]+'.png'
            dest=OUT/'textures'/name;dest.parent.mkdir(exist_ok=True)
            if not dest.exists():shutil.copy2(p,dest)
            textures[name]=dict(source=p.relative_to(ROOT).as_posix(),sha256=digest)
            return 'ReferenceTextures/'+Path(name).stem
        base=texture('_BaseColor') or texture('_MainTex') or texture('_SurfaceCellTex')
        matcap=texture('_Matcap') or texture('_SurfaceMatcap')
        tint=colors.get('_BaseTint',colors.get('_SurfaceLayerColor',[1,1,1,1]))
        opacity=max(.05,min(.45,tint[3])) if glass and raw['shader']!='CustomCrystal' else .55 if glass else 1
        material=dict(name=mid+'_m'+str(index),sourceName=raw['name'],sourceShader=raw['shader'],referenceMaterial=True,
                      texture=base,color=tint[:3]+[1],metallic=0,roughness=.65,glass=glass,opacity=opacity,
                      matcap=matcap,matcap1=texture('_Matcap1'),matcap2=texture('_Matcap2'),mask=texture('_MatcapAreaSplit'),
                      matcapScale=floats.get('_MatcapScale',.9 if matcap else 0),
                      matcapScale1=floats.get('_MatcapScale1',0),matcapScale2=floats.get('_MatcapScale2',0),
                      matcapColor=colors.get('_MatcapColor',[.277,.277,.277,0]),
                      matcapColor1=colors.get('_MatcapColor1',[.277,.277,.277,0]),matcapColor2=colors.get('_MatcapColor2',[.277,.277,.277,0]),
                      lightColor=colors.get('_LightColor',[.27,.27,.27,0]),
                      aoMap=texture('_AOTex') if floats.get('_AOScale',0)>0 else None,aoScale=floats.get('_AOScale',0),
                      sourceFloats=floats,sourceColors=colors,
                      adaptation='Own lightweight pixel lighting/MatCap and glass blend; source shader program not recovered.')
        materials.append(material)
    folder=OUT/mid;folder.mkdir(exist_ok=True)
    save(folder/'materials.json',dict(materials=materials))
    metrics=ROOT/'source-assets/models/candidates/competitor-runtime-20261025'/mid/'metrics.json'
    if not metrics.exists():metrics=ROOT/'source-assets/models/candidates/mobile-runtime-20261024'/mid/'metrics.json'
    if metrics.exists():triangles=json.loads(metrics.read_text('utf-8'))['triangles']
    else:
        verification=json.loads((src.parent.parent.parent/'export-verification.json').read_text('utf8'))['models']
        triangles=next(x['exportedTriangles'] for x in verification if x['id']==data['id'])
    batch.append(dict(id=mid,source=str(src.parent/(data['id']+'.blend')),sourceJson=str(src),sourceSha256=sha(src),materials=materials,expectedTriangles=triangles))
save(OUT/'batch.json',batch);save(OUT/'texture-sources.json',textures)
save(OUT/'model-contract.json',dict(models=[dict(id=x['id'],materials=len(x['materials']),triangles=x['expectedTriangles'],glassMaterials=sum(m['glass'] for m in x['materials']),colorOnlyMaterials=sum(not m['texture'] for m in x['materials'])) for x in batch]))
print(json.dumps(dict(models=len(batch),materials=sum(len(x['materials']) for x in batch),textures=len(textures))))
