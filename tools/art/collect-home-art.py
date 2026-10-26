"""Document actual player captures without repainting any game content."""
import hashlib,json,shutil,zipfile
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'work/home-art-20261025'
PLAYER=WORK/'final-player'
font=lambda n:ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',n)
def board(items,path,width=390,height=844):
    out=Image.new('RGB',(len(items)*width,height+76),'#fff6df');d=ImageDraw.Draw(out)
    for i,(title,file) in enumerate(items):
        d.text((i*width+18,18),title,font=font(23),fill='#55351e')
        im=Image.open(file).convert('RGB');im.thumbnail((width,height))
        out.paste(im,(i*width+(width-im.width)//2,76+(height-im.height)//2))
    out.save(path,quality=94)
ref=Path('C:/Users/123/AppData/Local/Temp/codex-clipboard-059225b3-e94c-4771-9f92-711d5830cb61.png')
shutil.copy2(ref,WORK/'competitor-reference.png')
old=ROOT/'work/home-gm-video-20261025/player-settings-final/home-390x844.png'
board([('竞品：用户提供截图',ref),('修改前：UI5 实际画面',old),('新版：HOME1 Unity 画面',PLAYER/'barbecue-home.png')],WORK/'competitor-before-after.jpg')
ids=['breakfast','barbecue','countryside','grocery','toys'];names=['早餐铺','烧烤摊','乡村小院','杂货铺','童年玩具']
board([(name,PLAYER/f'{id}-home.png') for id,name in zip(ids,names)],WORK/'five-theme-homes.jpg',width=280,height=606)
board([('首页',PLAYER/'barbecue-home.png'),('第一关',PLAYER/'barbecue-stage1.png'),('第二关',PLAYER/'barbecue-stage2.png')],WORK/'barbecue-real-render.jpg')
frames=[Image.open(p).convert('RGB') for p in sorted((PLAYER/'motion').glob('*.png'))]
frames[0].save(WORK/'home-motion.gif',save_all=True,append_images=frames[1:],duration=110,loop=0,optimize=True)
qa=json.loads((PLAYER/'acceptance.json').read_text(encoding='utf-8'));assert qa['passed'],qa['errors']
assert (WORK/'qa-sources.json').read_bytes()==(WORK/'windows-sources.json').read_bytes()
build=ROOT/'projects/catch-big-goose-unity/Builds/Windows'
archive=WORK/'catch-big-goose-home1-windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,6) as z:
    for p in build.rglob('*'):
        if p.is_file() and not any(s.endswith('_BackUpThisFolder_ButDontShipItWithYourGame') for s in p.parts):z.write(p,p.relative_to(build))
hashfile=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
manifest={'build':'20261025-HOME1','qaPassed':True,'runtimeChecks':len(qa['checks']),'editModeTests':37,'sourceSnapshotsMatch':True,'runtimeCapturePlatform':'Windows Unity player, mobile profile; not WeChat or a phone','backgrounds':[{'theme':id,'master':f'source-assets/ui/home-theme-v1/{id}-master.png','runtime':f'Assets/Resources/Textures/mobile-ui/themes/{id}-v1.bytes'}for id in ids], 'outputs':{p.name:{'bytes':p.stat().st_size,'sha256':hashfile(p)} for p in [archive,WORK/'competitor-before-after.jpg',WORK/'five-theme-homes.jpg',WORK/'home-motion.gif']}}
(WORK/'delivery.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'passed':True,'checks':len(qa['checks']),'windowsZip':archive.name,'outputs':list(manifest['outputs'])},ensure_ascii=False))
