"""Lay out untouched Unity captures and encode their animation as a review artifact."""
import hashlib,json,shutil,zipfile,xml.etree.ElementTree as ET
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2];WORK=ROOT/'work/home-stickers-20261025';PLAYER=WORK/'frozen-player';PROJECT=WORK/'frozen-project'
read=lambda p:json.loads(p.read_text(encoding='utf-8'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def board(items,file,width=390,height=844):
    canvas=Image.new('RGB',(len(items)*width,height+66),'#fff5df');draw=ImageDraw.Draw(canvas);font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',22)
    for i,(title,path) in enumerate(items):
        draw.text((i*width+12,15),title,font=font,fill='#57381f');im=Image.open(path).convert('RGB');im.thumbnail((width,height));canvas.paste(im,(i*width+(width-im.width)//2,66+(height-im.height)//2))
    canvas.save(WORK/file,quality=94)
qa=read(PLAYER/'acceptance.json');assert qa['passed'],qa['errors']
assert (WORK/'qa-sources.json').read_bytes()==(WORK/'windows-sources.json').read_bytes()
tests=ET.parse(WORK/'editmode-results.xml').getroot();assert tests.attrib['failed']=='0'
reference=ROOT/'work/home-art-20261025/competitor-reference.png';old=ROOT/'work/home-art-20261025/final-player/barbecue-home.png'
board([('竞品参考',reference),('被否定的 HOME1',old),('生图贴纸 STICKER2',PLAYER/'barbecue-home.png')],'competitor-before-after.jpg')
ids=['breakfast','barbecue','countryside','grocery','toys'];names=['早餐铺','烧烤摊','乡村小院','杂货铺','童年玩具']
board([(name,PLAYER/(id+'-home.png'))for id,name in zip(ids,names)],'five-theme-homes.jpg',280,606)
board([('常态',PLAYER/'barbecue-home.png'),('按住压缩',PLAYER/'button-pressed.png'),('松开回弹与爆星',PLAYER/'button-released.png')],'button-interaction.jpg')
frames=[Image.open(p).convert('RGB') for p in sorted((PLAYER/'motion').glob('*.png'))]
frames[0].save(WORK/'home-motion.gif',save_all=True,append_images=frames[1:],duration=110,loop=0,optimize=True)
build=PROJECT/'Builds/Windows';archive=WORK/'catch-big-goose-sticker2-windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,6)as z:
    for p in build.rglob('*'):
        if p.is_file()and not any(s.endswith('_BackUpThisFolder_ButDontShipItWithYourGame')for s in p.parts):z.write(p,p.relative_to(build))
snap=read(WORK/'qa-sources.json');changed=[p for p,h in snap.items()if sha(PROJECT/p)!=h];assert not changed,changed
active=ROOT/'projects/catch-big-goose-unity';active_diff=[p for p,h in snap.items()if not(active/p).exists()or sha(active/p)!=h]
manifest={'uiVersion':qa['uiVersion'],'baseBuild':qa['build'],'runtimeChecks':len(qa['checks']),'editModeTests':int(tests.attrib['passed']),'qaPassed':True,'qaWindowsSourcesMatch':True,'frozenSourcesMatch':True,'activeSourceDifferences':active_diff,'generatedAssets':read(ROOT/'source-assets/ui/home-stickers-v2/runtime-contract.json'),'actualCapture':'Windows Unity mobile profile, not WeChat or phone FPS','artPromptSet':'source-assets/ui/home-stickers-v2/prompts.json','outputs':{p.name:{'bytes':p.stat().st_size,'sha256':sha(p)}for p in [archive,WORK/'competitor-before-after.jpg',WORK/'five-theme-homes.jpg',WORK/'home-motion.gif']}}
(WORK/'delivery.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps({'passed':True,'runtimeChecks':manifest['runtimeChecks'],'editModeTests':manifest['editModeTests']}))
