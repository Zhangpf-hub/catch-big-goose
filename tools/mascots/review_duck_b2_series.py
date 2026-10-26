"""Compose actual GLB render review sheets. No AI raster edits."""
import argparse,json,hashlib
from PIL import Image,ImageDraw,ImageFont
from duck_series_catalog import OUT,CATALOG,THEME_NAMES
FONT='C:/Windows/Fonts/msyh.ttc'
def text(d,p,s,size=22):d.text(p,s,font=ImageFont.truetype(FONT,size),fill='#223937')
def picture(canvas,p,box):
    im=Image.open(p).convert('RGBA');im.thumbnail((box[2],box[3]));canvas.paste(im,(box[0]+(box[2]-im.width)//2,box[1]+(box[3]-im.height)//2),im)
def overview(view='hero'):
    edge=290;canvas=Image.new('RGB',(1220,1800),'#edf0ec');d=ImageDraw.Draw(canvas)
    text(d,(20,18),'B2 鸭子组合 · 20 款实际模型',32)
    text(d,(20,63),'统一母模、最大边 1、同镜头与灯光；图片来自 GLB 回读。',20)
    for row,(theme,title) in enumerate(THEME_NAMES.items()):
        y=110+row*335;text(d,(20,y),title,26)
        for col,item in enumerate(r for r in CATALOG if r['theme']==theme):
            x=20+col*300;d.rounded_rectangle((x,y+40,x+edge,y+315),radius=14,fill='#faf9f4')
            path=OUT/'renders'/item['id']/'duck'/(view+'.png')
            if path.exists():picture(canvas,path,(x,y+43,edge,235))
            text(d,(x+14,y+282),item['name'],21)
    dest=OUT/'renders'/('all-models-'+view+'.png');canvas.save(dest);return dest

def comparisons():
    for theme,title in THEME_NAMES.items():
        c=Image.new('RGB',(1440,870),'#edf0ec');d=ImageDraw.Draw(c)
        text(d,(22,15),title+' · 同尺寸实际网格对照',30)
        text(d,(22,61),'上排：竞品大鹅；下排：B2 鸭子。均最大边 1、正交镜头 1.48、相同灯光。',20)
        for i,item in enumerate(r for r in CATALOG if r['theme']==theme):
            x=i*360;id=item['id'];text(d,(x+20,106),item['name'],23)
            for j,kind in enumerate(['reference','duck']):picture(c,OUT/'renders'/id/kind/'hero.png',(x,145+j*350,360,330))
        c.save(OUT/'renders'/('comparison-'+theme+'.png'))
def main():
    p=argparse.ArgumentParser();p.add_argument('--preview',action='store_true');a=p.parse_args()
    overview()
    if a.preview:return
    comparisons()
    for view in ['front','side','back','gameplay']:overview(view)
    for item in CATALOG:
        id=item['id'];c=Image.new('RGB',(1400,450),'#edf0ec');d=ImageDraw.Draw(c);text(d,(20,12),item['name']+' · 四视图',28)
        for i,view in enumerate(['front','side','back','hero']):picture(c,OUT/'renders'/id/'duck'/(view+'.png'),(i*350,60,350,350))
        c.save(OUT/'renders'/(id+'-turnaround.png'))
    c=Image.new('RGB',(1100,920),'#edf0ec');d=ImageDraw.Draw(c);text(d,(20,12),'192px 图标缩放预览 / 64px 原尺寸辨识',28)
    for i,item in enumerate(CATALOG):
        x=20+i%5*215;y=65+i//5*210;id=item['id']
        picture(c,OUT/'renders'/id/'duck/icon-192.png',(x,y,150,150))
        picture(c,OUT/'renders'/id/'duck/icon-64.png',(x+145,y+90,64,64));text(d,(x,y+158),item['name'],18)
    c.save(OUT/'renders/all-icons.png')
    rows=[]
    for item in CATALOG:
        id=item['id'];folder=OUT/'models'/id
        mr=Image.open(folder/'metalrough.png').convert('RGB');_,rough,metal=mr.split();zero=Image.new('L',mr.size,0)
        Image.merge('RGBA',(metal,zero,zero,rough.point(lambda v:255-v))).save(folder/'unity-metallic.png')
        metric=json.loads((OUT/'qa'/(id+'-metrics.json')).read_text('utf-8'))
        rows.append({**item,'model':f'models/{id}/{id}.glb','fbx':f'models/{id}/{id}.fbx','source':f'source/{id}-authored.blend',
            'icon':f'renders/{id}/duck/icon-192.png','collision':f'models/{id}/convex-hull.obj','dimensions':metric['dimensions'],
            'triangles':metric['triangles'],'glbBytes':metric['glbBytes'],'sha256':hashlib.sha256((folder/(id+'.glb')).read_bytes()).hexdigest()})
    (OUT/'batch.json').write_text(json.dumps({'models':rows,'officialThemesReplaced':False},ensure_ascii=False,indent=2),'utf-8')
    html='''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><title>B2 20 款鸭子模型</title><style>body{background:#edf0ec;color:#223937;font:17px/1.6 system-ui,"Microsoft Yahei";max-width:1200px;margin:28px auto}img{max-width:100%;border-radius:12px}a{color:#28695d}section{padding:20px;background:#faf9f4;border-radius:12px;margin:20px 0}nav{display:flex;gap:20px;flex-wrap:wrap}</style><h1>B2 鸭子母模与 20 款组合</h1><p>B2 母模和首三款已通过用户验收。以下图片均为真实 GLB 网格回读渲染，保持统一比例、镜头与灯光。</p><nav><a href="renders/all-models-gameplay.png">游戏俯视</a><a href="renders/all-icons.png">图标辨识</a><a href="qa/glb-validation.json">模型规格检查</a><a href="batch.json">完整资源映射</a></nav><img src="renders/all-models-hero.png">'''
    for key,name in THEME_NAMES.items():html+=f'<section><h2>{name} · 同尺寸竞品对照</h2><img src="renders/comparison-{key}.png"></section>'
    for r in rows:html+=f'<section><h2>{r["themeName"]} · {r["name"]}</h2><p>{r["connection"]}。{r["triangles"]} 三角面；{r["glbBytes"]/1024:.1f} KiB。</p><img src="renders/{r["id"]}-turnaround.png"><p><a href="{r["model"]}">GLB</a> · <a href="{r["fbx"]}">FBX</a> · <a href="{r["source"]}">Blender 源文件</a></p></section>'
    html+='</html>';(OUT/'review.html').write_text(html,'utf-8')
if __name__=='__main__':main()
