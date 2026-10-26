"""Package real-game QA evidence only after both player profiles pass."""
from pathlib import Path
import hashlib,json,shutil,zipfile
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'work/duck-b2-gameplay-qa'
OUT=ROOT/'source-assets/models/candidates/duck-series-v1/model-review-b2'
DEST=OUT/'qa/gameplay'
def read(p):return json.loads(p.read_text('utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
snapshot=read(WORK/'source-snapshot.json')
for item in snapshot['candidateInputs']:assert sha(ROOT/item['source'])==item['sha256'],item['source']
core=['GooseGame.cs','GooseRoundPreparation.cs','GooseTrayPresentation.cs','GooseRules.cs','GooseItem.cs','GoosePileDepth.cs']
coreHashes={}
for name in core:
    rel='Assets/Scripts/'+name
    assert sha(WORK/rel)==snapshot['sourceFiles'][rel],name
    coreHashes[name]=sha(WORK/rel)
for name in ('themes.json','theme-rounds.json'):
    rel='Assets/Resources/Data/'+name
    assert sha(WORK/rel)==snapshot['sourceFiles'][rel]
for profile in ('desktop','mobile'):
    result=read(WORK/profile/'acceptance.json')
    assert result['passed'] and result['removed']==9 and result['roundTrips']==2
    assert result['mobileProfile']==(profile=='mobile')
    assert all(r['screenPicks']==3 and r['matched']==3 and r['metallicTextureRetained'] for r in result['items'])
    shutil.copytree(WORK/profile,DEST/profile,dirs_exist_ok=True)
for name in ('source-snapshot.json','build-result.json'):
    shutil.copy2(WORK/name,DEST/name)
for name in ('DuckB2GameplayAcceptance.cs','DuckB2GameplayBuild.cs','GooseDuckMobile.shader','prepare_duck_b2_gameplay_qa.py'):
    if name.endswith('.cs') or name.endswith('.shader'):
        sub='Editor' if name.endswith('Build.cs') else 'Resources' if name.endswith('.shader') else 'Scripts'
        assert sha(Path(__file__).with_name(name))==sha(WORK/'Assets'/sub/name)
    shutil.copy2(Path(__file__).with_name(name),DEST/name)
boot=WORK/'Builds/DuckB2QA_Data/boot.config'
lines=boot.read_text('utf-8-sig').splitlines()
for expected in ('player-connection-mode=Listen','player-connection-multicast=0','player-connection-listen-address=127.0.0.1','player-connection-ip=127.0.0.1'):assert expected in lines
font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',24)
small=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',18)
canvas=Image.new('RGB',(1180,630),'#edf0ec');draw=ImageDraw.Draw(canvas)
draw.text((20,15),'B2 三款 · 实际游戏的移动端配置检查',font=font,fill='#223937')
for i,(name,label) in enumerate([('game-pile','45 件真实生成'),('duck-eggtart-tray','蛋挞鸭入槽'),('duck-steelcup-tray','钢杯鸭入槽'),('duck-numberblock-tray','积木鸭入槽')]):
    im=Image.open(DEST/'mobile'/(name+'.png')).convert('RGB');im.thumbnail((275,650))
    x=20+i*290;canvas.paste(im,(x,75));draw.text((x,45),label,font=small,fill='#223937')
draw.text((20,590),'Windows QA Player；真实生成、屏幕射线拾取、托盘和三消。不是微信真机性能验收。',font=small,fill='#586966')
canvas.save(OUT/'renders/gameplay-acceptance-overview.png')
result={'passed':True,'scope':'Real game snapshot in isolated Windows player; desktop and mobile settings. Not WeChat device or complete 20-model review.',
    'formalProjectModified':False,'coreFilesUnmodifiedFromSnapshot':coreHashes,'candidateInputs':snapshot['candidateInputs'],
    'singlePassDuckShader':'Goose/DuckMobile','shaderScope':'New candidate-only stylized single-pass shader retaining metallic/smoothness. Not yet published to formal project.',
    'networkLocalOnly':True,'playerSha256':sha(WORK/'Builds/DuckB2QA.exe'),
    'artApproved':False,'remainingSeventeenStarted':False,
    'files':[{'path':str(p.relative_to(DEST)).replace('\\','/'),'sha256':sha(p),'bytes':p.stat().st_size} for p in sorted(DEST.rglob('*')) if p.is_file() and p.name!='evidence.json']}
(DEST/'evidence.json').write_text(json.dumps(result,indent=2),'utf-8')
print(json.dumps({'passed':True,'profiles':['desktop','mobile'],'screenshots':len(list(DEST.rglob('*.png'))),'evidenceFiles':len(result['files'])}))
