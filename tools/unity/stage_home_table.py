"""Validate furniture candidate hashes and stage without replacing existing GUIDs."""
import hashlib,json,shutil,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
C=ROOT/'source-assets/models/candidates/home-table-lighting-20261025'
node='D:/开发/微信web开发者工具/node.exe'
code="const fs=require('fs');require('D:/开发/tools/gltf-audit/node_modules/gltf-validator').validateBytes(new Uint8Array(fs.readFileSync(process.argv[1]))).then(r=>{console.log(JSON.stringify(r.issues));process.exitCode=r.issues.numErrors||r.issues.numWarnings?1:0})"
r=subprocess.run([node,'-e',code,str(C/'home-table.glb')],capture_output=True,text=True,encoding='utf-8');assert r.returncode==0,r.stdout+r.stderr
metrics=json.loads((C/'metrics.json').read_text('utf-8'));assert metrics['roundtrip'] and metrics['triangles']<=4000 and metrics['materials']==2
assert all((C/(name+'.png')).is_file() for name in ['front','side','back','three-quarter','icon-192','icon-64'])
materials=[]
for name in ['cream','wood']:
    materials.append(dict(name='home_table_'+name,referenceMaterial=True,sourceShader='Project furniture adaptation',texture='Models/home-table/'+name,color=[1,1,1,1],matcap='Models/home-table/matcap',matcapScale=.10 if name=='cream' else .06,matcapColor=[.277,.277,.277,0],lightColor=[.27,.27,.27,0]))
(C/'materials.json').write_text(json.dumps(dict(materials=materials),indent=2),encoding='utf-8')
destination=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Models/home-table';destination.mkdir(parents=True,exist_ok=True)
for name in ['home-table.fbx','materials.json','cream.png','wood.png','matcap.png']:shutil.copy2(C/name,destination/name)
files={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in C.iterdir() if p.is_file()}
(C/'validation.json').write_text(json.dumps(dict(passed=True,validator=json.loads(r.stdout),files=files),indent=2),encoding='utf-8')
print(json.dumps(metrics))
