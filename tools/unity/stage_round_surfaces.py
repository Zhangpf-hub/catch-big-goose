import json,shutil,subprocess,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];source=ROOT/'source-assets/models/candidates/round-surfaces-20261025'
backup=ROOT/'projects/catch-big-goose-unity/SourceAssets/before-home-lighting-shake-20261025'
rows=json.loads((source/'metrics.json').read_text('utf-8'));results=[]
for row in rows:
    mid=row['id'];folder=source/mid
    code="const fs=require('fs');require('D:/开发/tools/gltf-audit/node_modules/gltf-validator').validateBytes(new Uint8Array(fs.readFileSync(process.argv[1]))).then(r=>{console.log(JSON.stringify(r.issues));process.exitCode=r.issues.numErrors||r.issues.numWarnings?1:0})"
    r=subprocess.run(['D:/开发/微信web开发者工具/node.exe','-e',code,str(folder/(mid+'.glb'))],text=True,capture_output=True,encoding='utf-8');assert r.returncode==0,r.stdout+r.stderr
    assert row['unchangedVertices'] and row['materials']==2
    target=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Models'/mid
    if not (backup/mid).exists():shutil.copytree(target,backup/mid)
    for p in folder.iterdir():
        if p.suffix in ['.fbx','.json','.png']:shutil.copy2(p,target/p.name)
    results.append(dict(**row,validator=json.loads(r.stdout),files={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in folder.iterdir() if p.is_file()}))
(source/'validation.json').write_text(json.dumps(dict(passed=True,models=results),indent=2),encoding='utf-8');print('Five UV/material candidates staged; FBX GUIDs and authored vertices retained.')
