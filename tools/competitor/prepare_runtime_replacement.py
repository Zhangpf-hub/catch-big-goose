"""Select cached scene groups and retain source identity for every runtime model."""
from pathlib import Path
import json, shutil
ROOT=Path(__file__).resolve().parents[2]
REF=ROOT/'reference-projects/competitor-goose/2026-10-25-runtime'
OUT=ROOT/'source-assets/models/candidates/competitor-runtime-20261025'
WORK=ROOT/'competitor-analysis/artifacts/competitor-replacement-20261025'
def read(p):return json.loads(p.read_text(encoding='utf8'))
def save(p,v):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding='utf8')
manifest=read(REF/'manifest.json');manifest['date']='2026-10-25'
manifest['purpose']='User-requested local project replacement; original competitor source and hashes retained.'
save(REF/'manifest.json',manifest)
old=read(ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data/reference-lab.json')['theme']['items']
batch=[];selection=[];excluded=[]
for item in manifest['models']:
    data=read(REF/item['source']);name=item['id'];id='ref_'+name.lower()
    group=data['prefab'].rsplit('/',1)[0].split('/')[-1]
    if group=='ChildhoodToys26Obj' and id not in old:
        excluded.append({'id':name,'reason':'Transparent/multipart toy shell requires a separate material path; retain the 21 verified opaque toys.'});continue
    if id in old:
        source=ROOT/'source-assets/models/candidates/mobile-runtime-20261024'/id
        shutil.copytree(source,OUT/id,dirs_exist_ok=True)
        row=read(source/'metrics.json');batch.append({'id':id,'source':row['source'],'target':4000,'reference':True,'textureSize':512})
    else:
        selection.append(item)
        batch.append({'id':id,'source':str(REF/'models'/name/(name+'.blend')),'target':4000,'reference':True,'textureSize':512})
    save(OUT/id/'provenance.json',{'id':id,'sourceId':name,'scene':group,'sourceJson':str((REF/item['source']).relative_to(ROOT)),
         'prefab':data['prefab'],'bundle':data['bundle'],'sourceSha256':item['sourceSha256']})
selected=dict(manifest);selected['models']=selection
save(REF/'build-manifest.json',selected);save(WORK/'batch.json',batch);save(WORK/'excluded.json',excluded)
print('Extracted',len(manifest['models']),'selected',len(batch),'new conversions',len(selection),'reused',len(old))
