"""Promote verified isolated Unity evidence into the current review package."""
from pathlib import Path
import hashlib
import json
import shutil
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'work/duck-b2-unity-qa'
OUT=ROOT/'source-assets/models/candidates/duck-series-v1/model-review-b2'
DEST=OUT/'qa/unity-import'
IDS=('duck-eggtart','duck-steelcup','duck-numberblock')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
report=json.loads((WORK/'audit-output/unity-audit.json').read_text('utf-8'))
assert report['passed'] and report['unityVersion']=='2022.3.62f3'
staging=json.loads((WORK/'staging.json').read_text('utf-8'))
for item in staging['inputs']:assert sha(ROOT/item['source'])==item['sha256'],item
for row in report['models']:
    assert sha(OUT/'models'/row['id']/(row['id']+'.fbx'))==row['visualHash']
    assert sha(WORK/'Assets/candidates'/row['id']/'collision.fbx')==row['collisionHash']
DEST.mkdir(parents=True,exist_ok=True)
for p in (WORK/'audit-output').iterdir():
    if p.is_file():shutil.copy2(p,DEST/p.name)
shutil.copy2(WORK/'staging.json',DEST/'staging.json')
shutil.copy2(Path(__file__).with_name('DuckB2UnityAudit.cs'),DEST/'DuckB2UnityAudit.cs')
shutil.copy2(Path(__file__).with_name('prepare_duck_b2_unity_qa.py'),DEST/'prepare_duck_b2_unity_qa.py')
for id in IDS:
    shutil.copy2(WORK/'Assets/candidates'/id/'collision.fbx',DEST/(id+'-collision.fbx'))
shutil.copy2(WORK/'Assets/candidates/duck-b2-home/duck-b2-home.fbx',DEST/'duck-b2-home.fbx')
fontPath='C:/Windows/Fonts/msyh.ttc'
canvas=Image.new('RGB',(1200,550),'#edf0ec');draw=ImageDraw.Draw(canvas)
draw.text((20,15),'Unity 2022.3.62f3 · 实际 FBX 与 Standard 材质',fill='#223937',font=ImageFont.truetype(fontPath,29))
for i,(id,name) in enumerate(zip(IDS,('蛋挞鸭','钢杯鸭','积木鸭'))):
    canvas.paste(Image.open(DEST/(id+'-hero.png')).resize((400,400)),(i*400,70))
    draw.text((i*400+20,470),name,fill='#223937',font=ImageFont.truetype(fontPath,24))
draw.text((20,515),'独立灰棚检查；非正式游戏灯光。造型仍待用户验收。',fill='#586966',font=ImageFont.truetype(fontPath,20))
canvas.save(OUT/'renders/unity-import-overview.png')
evidence={'passed':True,'scope':report['scope'],'productionProjectImported':False,
    'productionGameVerified':False,'artApproved':False,'report':'unity-audit.json',
    'files':[{'path':p.name,'sha256':sha(p),'bytes':p.stat().st_size} for p in sorted(DEST.iterdir()) if p.is_file() and p.name!='evidence.json']}
(DEST/'evidence.json').write_text(json.dumps(evidence,indent=2),'utf-8')
print(json.dumps({'passed':True,'models':len(report['models']),'clips':len(report['clips']),
                  'sleepingBodies':report['sleepingAfter15Seconds'],'evidenceFiles':len(evidence['files'])}))
