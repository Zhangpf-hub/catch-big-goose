import hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
source=ROOT/'competitor-analysis/artifacts/competitor-config-trace/main-402.wat'
out=ROOT/'work/r4-interaction-20261025/competitor';out.mkdir(parents=True,exist_ok=True)
target={'14312':'ObjectUnit.AddForce','21513':'ObjectUnit.CanShake'}
current=None;lines=[];found=[]
with source.open(encoding='utf-8') as f:
    for line in f:
        m=re.match(r'  \(func \$j(\d+) ',line)
        if m:
            if current:
                file=out/('j'+current+'.watfrag');file.write_text(''.join(lines),encoding='utf-8');found.append(dict(method=target[current],symbol='j'+current,file=file.name))
            current=m.group(1) if m.group(1) in target else None;lines=[]
        if current:lines.append(line)
if current:(out/('j'+current+'.watfrag')).write_text(''.join(lines),encoding='utf-8')
for name in ['j95011.annotated.wat','j43545.annotated.wat','j14620.annotated.wat','j43511.annotated.wat','j95003.annotated.wat']:
    p=ROOT/'competitor-analysis/evidence/2026-10-24-核心单局与运行配置/方法/primary'/name
    (out/name).write_bytes(p.read_bytes())
scene=json.loads((ROOT/'competitor-analysis/artifacts/competitor-config-trace/serialized-verified/LevelManager.json').read_text(encoding='utf-8-sig'))
fields={k:v for k,v in scene.items() if 'shake' in k.lower() or 'sharePower' in k or k in ['_baceForce','_heighForce']}
report=dict(version=402,sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(),methods=found,serializedFields=fields,
    confirmed=dict(gravityY=-19.81,staticFriction=.6,dynamicFriction=.6,bounce=0,fixedStep=.02),
    limits='Frozen package/static branches; not account live overrides. ShakeObj tool fields are not assumed to govern phone shake. No verified competitor dynamic basket shrink.',
    projectAdaptation=dict(cooldown=.8,productionMobileFixedStep=1/30,filteredSensorBurst=True,physicalVelocityChange=True))
(out/'evidence.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False,indent=2))
