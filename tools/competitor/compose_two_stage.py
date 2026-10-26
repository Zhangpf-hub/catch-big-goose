"""Compose unretouched player evidence and encode actual captured frame sequences."""
from pathlib import Path
import json,sys,subprocess
from PIL import Image,ImageDraw,ImageFont,ImageOps
ROOT=Path(__file__).resolve().parents[2];WORK=ROOT/'work/two-stage-20261025';font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',22);small=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',12)
themes=json.loads((ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data/themes.json').read_text('utf8'))['themes']
models=[(t['name'],id) for t in themes for id in t['items']]
sheet=Image.new('RGB',(12*125,((len(models)+11)//12)*145),(242,236,219));draw=ImageDraw.Draw(sheet)
for i,(theme,id) in enumerate(models):
    x=i%12*125;y=i//12*145;im=Image.open(WORK/'model-preview-clean/models'/id/'icon-192.png').convert('RGBA');im.thumbnail((120,116));sheet.paste(im,(x+(125-im.width)//2,y),im);draw.text((x+3,y+117),id.replace('ref_','')[:20],font=small,fill=(48,35,22))
sheet.save(WORK/'116-models.jpg',quality=93)
if '--gallery-only' in sys.argv:sys.exit(0)
player=WORK/'frozen-playtest-final';assert player.is_dir()
qa=json.loads((player/'story-acceptance.json').read_text('utf8'));assert qa['passed'] and qa['rounds']==10,qa['errors']
def strip(names,labels,output):
    canvas=Image.new('RGB',(390*len(names),892),(242,236,219));draw=ImageDraw.Draw(canvas)
    for i,(name,label) in enumerate(zip(names,labels)):
        im=Image.open(player/(name+'.png')).convert('RGB');assert im.size==(390,844);draw.text((i*390+14,12),label,font=font,fill=(48,35,22));canvas.paste(im,(i*390,48))
    canvas.save(WORK/output,quality=93)
strip(['barbecue-home','barbecue-stage1','barbecue-stage2'],['实装首页 · 可点击柴犬','第一关 · 15 件／不限时','第二关 · 300 件／10 分钟'],'home-and-two-stages.jpg')
strip([t['id']+'-stage2' for t in themes],[t['name']+' · '+str(len(t['items']))+' 类模型池' for t in themes],'five-themes.jpg')
source=Image.open(ROOT/'reference-projects/competitor-goose/2026-10-22/evidence/01-barbecue-initial.png').crop((414,44,861,839)).convert('RGB')
compare=Image.new('RGB',(1170,892),(242,236,219));draw=ImageDraw.Draw(compare)
for i,(im,label) in enumerate([(source,'竞品实际画面 · 冻结样本'),(Image.open(player/'barbecue-stage1.png'),'本项目第一关 · 实际运行'),(Image.open(player/'barbecue-stage2.png'),'本项目第二关 · 实际运行')]):
    im=ImageOps.contain(im,(390,844));draw.text((i*390+12,12),label,font=font,fill=(48,35,22));compare.paste(im,(i*390+(390-im.width)//2,48+(844-im.height)//2))
compare.save(WORK/'competitor-comparison.jpg',quality=93)
import imageio_ffmpeg
for name,fps in [('home',10),('play',8.333333)]:
    frames=list((player/'animation').glob(name+'-*.png'));assert frames
    subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-y','-loglevel','error','-framerate',str(fps),'-i',str(player/'animation'/(name+'-%03d.png')),'-c:v','libx264','-pix_fmt','yuv420p','-crf','19','-movflags','+faststart',str(WORK/(name+'-animation.mp4'))],check=True)
print('Actual player galleries, comparison and silent animation clips encoded.')
