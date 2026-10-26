import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
work=ROOT/'work/device-profile-20261024'
audit=json.loads((work/'baseline-assets.json').read_text('utf-8'))
themes=json.loads((ROOT/'unity/Assets/Resources/Data/themes.json').read_text('utf-8'))['themes']
containers={t['container'] for t in themes}
batch=[]
for m in audit['models']:
    if m['drawSlots']<=1 and m['triangles']<=4000 and m['id'] not in containers:continue
    archived=ROOT/'unity/SourceAssets/MobileBaseline-20261024/original-models'/m['id']
    folder=archived if archived.exists() else ROOT/'unity/Assets/Resources/Models'/m['id']
    batch.append(dict(id=m['id'],source=str(folder/(m['id']+'.fbx')),materialFile=str(folder/'materials.json'),
        target=100000 if m['id'] in containers else 3000 if m['triangles']>6000 else 4000,container=m['id'] in containers,textureSize=512))
names=['GTCrocodile','GTDinosaur','GTDrawingBoard','GTFruitEraser','GTGooseStamp','GTKaleidoscope','GTLaserPen','GTMagicCubeL',
 'GTPaperBoat','GTPaperFortune','GTPaperStar','GTPaperTree','GTPlanePen','GTPlasterDeer','GTPlaydough','GTRaceCar','GTRingCandy','GTSandbag','GTSmileDoll','GTStickerBook','GTWaterGame']
for name in names:
    source=ROOT/'references/competitor-goose/2026-10-23/models'/name/(name+'.blend')
    assert source.exists(),source
    batch.append(dict(id='ref_'+name.lower(),source=str(source),target=4000,reference=True,textureSize=512))
(work/'mobile-batch.json').write_text(json.dumps(batch,ensure_ascii=False,indent=2),encoding='utf-8')
print('Own conversions:',len(batch)-len(names),'Reference toys:',len(names))
