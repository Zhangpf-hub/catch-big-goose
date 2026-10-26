"""Compose actual Blender render comparisons, verify framing and package inputs.

Uses Pillow only for labels/layout and alpha compositing of genuine mesh renders.
No concept image is modified, projected or substituted for a model render.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import hashlib
import json

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'source-assets/models/candidates/duck-series-v1/model-review-v1'
IDS=['duck-eggtart','duck-steelcup','duck-numberblock']
NAMES={'duck-eggtart':'蛋挞','duck-steelcup':'钢杯','duck-numberblock':'积木'}
PAPER=(244,242,235);INK=(38,57,58);MUTED=(93,110,110);WHITE=(255,255,252)
FONT=Path('C:/Windows/Fonts/msyh.ttc')


def font(size):return ImageFont.truetype(str(FONT),size)


def text(draw,xy,value,size=24,fill=INK):draw.text(xy,value,font=font(size),fill=fill)


def read(p):return json.loads(p.read_text('utf-8'))


def picture(canvas,src,xy,size=None):
    image=Image.open(src).convert('RGBA')
    if size and image.size!=size:image=image.resize(size,Image.Resampling.LANCZOS)
    canvas.paste(image,xy,image)


def comparison_sheet(view):
    edge=640 if view in ['hero','gameplay'] else 512
    # Same source render dimensions; there is no per-object alpha crop/refitting.
    width=edge*2+96;row=edge+86;height=166+row*3+88
    canvas=Image.new('RGB',(width,height),PAPER);d=ImageDraw.Draw(canvas)
    labels={'hero':'三分之四','gameplay':'游戏俯视','front':'正面','side':'侧面','back':'背面'}
    text(d,(32,25),'鸭子 B × 竞品同类模型',34)
    text(d,(32,77),labels[view]+' · 每件最长边统一为 1 · 同镜头、同灯光、同画布 · 保持原比例',19,MUTED)
    text(d,(32,125),'左：竞品提取模型',23)
    text(d,(edge+64,125),'右：原创鸭子 B 模型',23)
    for i,id in enumerate(IDS):
        top=166+i*row
        ours=read(OUT/'qa'/f'{id}-metrics.json')
        text(d,(32,top+10),NAMES[id]+' / '+str(ours['triangles'])+' 三角面 · 单材质',23)
        for col,kind in enumerate(['reference','duck']):
            x=32+col*(edge+32)
            d.rounded_rectangle((x,top+52,x+edge,top+52+edge),radius=14,fill=WHITE)
            picture(canvas,OUT/'renders'/id/kind/f'{view}.png',(x,top+52))
    text(d,(32,height-65),'真实 GLB 回读渲染；竞品保留源姿态，材质为基础色/PBR 近似，不是原游戏截图。',17,MUTED)
    path=OUT/'renders'/f'comparison-{view}.png';canvas.save(path)
    return path


def icon_sheet():
    canvas=Image.new('RGB',(1352,680),PAPER);d=ImageDraw.Draw(canvas)
    text(d,(28,23),'同尺寸缩略图 · 真实模型渲染',32)
    text(d,(28,72),'每组左为竞品，右为鸭子 B；192px 与 64px 图标按原始像素显示，没有单独放大。',18,MUTED)
    for i,id in enumerate(IDS):
        x=28+i*448;text(d,(x,126),NAMES[id],25)
        text(d,(x,173),'192 px',18,MUTED)
        for col,kind in enumerate(['reference','duck']):
            xx=x+col*210
            d.rounded_rectangle((xx,210,xx+192,402),radius=10,fill=WHITE)
            picture(canvas,OUT/'renders'/id/kind/'icon-192.png',(xx,210))
            text(d,(xx+50,419),'竞品' if col==0 else '鸭子 B',18)
            picture(canvas,OUT/'renders'/id/kind/'icon-64.png',(xx+64,494))
        text(d,(x,464),'64 px',18,MUTED)
    text(d,(28,612),'透明图标与原始 PNG 一并交付；此图只组合排版，没有重绘或补画模型。',18,MUTED)
    path=OUT/'renders/thumbnail-comparison.png';canvas.save(path)
    return path


def verify():
    result={'passed':True,'models':[],'renderSource':'GLB roundtrip, Blender Cycles 16 samples','noConceptImageSubstitution':True}
    for id in IDS:
        records=[read(OUT/'qa'/f'{id}-{kind}-comparison.json') for kind in ['reference','duck']]
        a,b=records
        checks={'sameCamera':a['cameras']==b['cameras'],'sameOrthographicScale':a['orthographicScale']==b['orthographicScale']==1.48,'sameLighting':a['lighting']==b['lighting'],'normalizedMaximumExtent':all(abs(max(r['normalizedWorldDimensions'])-1)<1e-5 for r in records),'centered':all(max(abs(x) for x in r['normalizedCenter'])<1e-5 for r in records),'inputHashesCurrent':all(hashlib.sha256((ROOT/r['input']).read_bytes()).hexdigest()==r['sourceSha256'] for r in records)}
        icons=[]
        for kind in ['reference','duck']:
            for size in [192,64]:
                p=OUT/'renders'/id/kind/f'icon-{size}.png';image=Image.open(p).convert('RGBA')
                bbox=image.getchannel('A').getbbox();assert bbox is not None
                margin=min(bbox[0],bbox[1],size-bbox[2],size-bbox[3])
                icons.append(dict(kind=kind,size=size,alphaBounds=bbox,minimumMargin=margin))
                checks[f'{kind}{size}Size']=image.size==(size,size)
                if size==192:checks[f'{kind}IconMargin']=margin>=6
        for view in ['front','side','back','hero','gameplay']:
            images=[Image.open(OUT/'renders'/id/kind/f'{view}.png') for kind in ['reference','duck']]
            checks[view+'SameCanvas']=images[0].size==images[1].size
            checks[view+'NoCropping']=all((lambda box,size:box is not None and min(box[0],box[1],size[0]-box[2],size[1]-box[3])>=5)(im.getchannel('A').getbbox(),im.size) for im in images)
        row={'id':id,'passed':all(checks.values()),'checks':checks,'icons':icons,'normalization':records}
        result['models'].append(row);result['passed'] &= row['passed']
    (OUT/'qa/comparison-verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n','utf-8')
    assert result['passed'],result
    return result


def main():
    verify()
    for view in ['hero','gameplay','front','side','back']:comparison_sheet(view)
    icon_sheet()
    print(json.dumps({'passed':True,'comparisonSheets':5,'thumbnailSheet':True,'noRefitting':True}))


if __name__=='__main__':main()
