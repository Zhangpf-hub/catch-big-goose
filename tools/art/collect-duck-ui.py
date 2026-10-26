"""Compose untouched Unity captures; preserve source and build provenance."""
import json,hashlib,zipfile,xml.etree.ElementTree as ET
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2];WORK=ROOT/'work/duck-ui-20261025';PLAYER=WORK/'brand-player';PROJECT=ROOT/'projects/catch-big-goose-unity'
read=lambda p:json.loads(p.read_text(encoding='utf-8'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def board(items,file,width=390,height=844):
 out=Image.new('RGB',(len(items)*width,height+66),'#fff5df');draw=ImageDraw.Draw(out);font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',22)
 for i,(title,p)in enumerate(items):
  draw.text((i*width+12,16),title,font=font,fill='#57381f');im=Image.open(p).convert('RGB');im.thumbnail((width,height));out.paste(im,(i*width+(width-im.width)//2,66+(height-im.height)//2))
 out.save(WORK/file,quality=94)
qa=read(PLAYER/'acceptance.json');assert qa['passed'],qa['errors']
assert(WORK/'qa-sources.json').read_bytes()==(WORK/'windows-sources.json').read_bytes()
tests=ET.parse(WORK/'editmode-results.xml').getroot();assert tests.attrib['failed']=='0'
board([('上一版柴犬 UI',ROOT/'work/home-stickers-20261025/frozen-player/barbecue-home.png'),('抓鸭子 · Unity 实际画面',PLAYER/'barbecue-home.png')],'before-after.jpg')
board([('加载封面 · 生图资源',PROJECT/'Assets/loading-art/duck-loading.jpg'),('首页 · Unity 实际渲染',PLAYER/'barbecue-home.png')],'loading-and-home.jpg')
ids=['breakfast','barbecue','countryside','grocery','toys'];names=['早餐铺','烧烤摊','乡村小院','杂货铺','童年玩具']
board([(n,PLAYER/(i+'-home.png'))for i,n in zip(ids,names)],'five-theme-homes.jpg',280,606)
frames=[Image.open(p).convert('RGB')for p in sorted((PLAYER/'motion').glob('*.png'))];frames[0].save(WORK/'duck-home-motion.gif',save_all=True,append_images=frames[1:],duration=110,loop=0,optimize=True)
build=PROJECT/'Builds/Windows';archive=WORK/'catch-ducks-duckbrand3-windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,6)as z:
 for p in build.rglob('*'):
  if p.is_file()and not any(s.endswith('_BackUpThisFolder_ButDontShipItWithYourGame')for s in p.parts):z.write(p,p.relative_to(build))
snap=read(WORK/'qa-sources.json');differences=[p for p,h in snap.items()if not(PROJECT/p).exists()or sha(PROJECT/p)!=h]
manifest={'brand':'抓鸭子','uiVersion':qa['uiVersion'],'baseBuild':qa['build'],'runtimeChecks':len(qa['checks']),'editModeTests':int(tests.attrib['passed']),'qaPassed':True,'qaReleaseSnapshotsMatch':True,'currentSourceDifferences':differences,'identity':'approved duck-series-v1 B2; actual DuckHome prefab, same 9-bone rig and 3 clips','generatedAssets':read(ROOT/'source-assets/ui/duck-stickers-v3/runtime-contract.json'),'captureScope':'Windows Unity player mobile profile; loading cover is an asset preview, not a simulated WeChat runtime screenshot','prompts':'source-assets/ui/duck-stickers-v3/prompts.json','outputs':{p.name:{'bytes':p.stat().st_size,'sha256':sha(p)}for p in [archive,WORK/'before-after.jpg',WORK/'loading-and-home.jpg',WORK/'duck-home-motion.gif']}}
(WORK/'delivery.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps({'passed':True,'runtimeChecks':len(qa['checks']),'editmodeTests':manifest['editModeTests'],'currentSourceDifferences':differences}))
