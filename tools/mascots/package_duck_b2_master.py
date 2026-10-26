"""Compose model renders (not concept edits), verify evidence, package B2 mother."""
import hashlib
import json
import re
import zipfile
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'source-assets/models/candidates/duck-series-v1/master-b2'
PAPER=(235,238,235);CARD=(249,248,243);INK=(35,58,56);MUTED=(91,106,104)
def read(p):return json.loads(p.read_text('utf-8'))
def write(p,d):p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n','utf-8')
def font(n):return ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',n)
def label(d,xy,s,n=26,fill=INK):d.text(xy,s,font=font(n),fill=fill)
def pic(c,name,xy,size):
 im=Image.open(OUT/'renders'/name).convert('RGBA').resize(size,Image.Resampling.LANCZOS);c.paste(im,xy,im)
def sheet(name,views,labels,note,edge=580):
 w=48+len(views)*(edge+24);c=Image.new('RGB',(w,edge+215),PAPER);d=ImageDraw.Draw(c)
 label(d,(28,20),'B2 鸭子母模 · 真实 GLB 回读渲染',34)
 label(d,(28,75),note,20,MUTED)
 for i,(v,l) in enumerate(zip(views,labels)):
  x=24+i*(edge+24);d.rounded_rectangle((x,120,x+edge,120+edge),18,CARD)
  pic(c,v,(x,120),(edge,edge));label(d,(x+18,126),l,23)
 label(d,(28,edge+150),'造型待用户验收；概念图未用作模型贴图。',20,MUTED)
 c.save(OUT/'renders'/name)

def silhouette():
 rows=[]
 for view in ['front','side','hero']:
  images=[Image.open(OUT/'renders'/f'{prefix}{view}.png').convert('RGBA') for prefix in ['','high-']]
  masks=[[v>=128 for v in im.getchannel('A').tobytes()] for im in images]
  intersection=sum(a and b for a,b in zip(*masks));union=sum(a or b for a,b in zip(*masks))
  row={'view':view,'iou':intersection/union,'differingPixels':union-intersection,'canvas':list(images[0].size),'passed':intersection/union>=.98}
  rows.append(row)
 result={'passed':all(r['passed'] for r in rows),'minimumIou':.98,'views':rows,'comparison':'high surface versus mobile mesh, same normalization and camera','doesNotProveConceptMatch':True}
 write(OUT/'qa/silhouette-comparison.json',result)
 assert result['passed'],result
 return result

def animations():
 info=read(OUT/'qa/animation-preview.json')
 for clip in info['clips']:
  frames=[]
  for path in sorted((OUT/'renders/animation-frames'/clip['action']).glob('*.png')):
   im=Image.open(path).convert('RGBA');c=Image.new('RGB',im.size,CARD);c.paste(im,(0,0),im);frames.append(c)
  assert len(frames)==clip['frames']
  duration=round(clip['durationSeconds']*1000/(len(frames)-1))
  frames[0].save(OUT/'renders'/(clip['action']+'.gif'),save_all=True,append_images=frames[1:],loop=0,duration=duration,disposal=2)

def html():
 p=read(OUT/'qa/proportions.json');a=read(OUT/'qa/glb-validation.json')
 content='''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>B2 鸭子母模验收</title>
<style>body{margin:0;background:#ebeeeb;color:#233a38;font:16px/1.65 system-ui,"Microsoft Yahei",sans-serif}main{max-width:1240px;margin:auto;padding:30px}h1{font-size:32px;margin:0}h2{font-size:23px;margin-top:38px}p{max-width:1000px}.tag{display:inline-block;background:#e5dfc2;padding:6px 12px;border-radius:9px}img{max-width:100%;display:block;border-radius:12px}.grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}figure{margin:0;background:#f9f8f3;padding:16px;border-radius:14px}figcaption{margin-top:10px}a{color:#236d61}table{border-collapse:collapse;width:100%;background:#f9f8f3}td,th{padding:10px;text-align:left;border-bottom:1px solid #d6ddd5}.small{color:#5b6a68;font-size:14px}@media(max-width:800px){.grid{grid-template-columns:1fr}main{padding:18px}}</style><main>
<span class="tag">真实三维母模 · 造型待验收</span><h1>小头、小脚，先把鸭子本体做准</h1>
<p>B2 生图比例已收到“通过 完成计划”确认。这次交付一只完整、可编辑、可变形的鸭子母模，修正旧模型的大头和头颈断续问题。三款融合模型将沿用这张网格。</p>
<img src="renders/master-turnaround.png" alt="母模正面侧面三分之四渲染">
<p><a href="models/duck-b2-master/duck-b2-master.glb">静态 GLB</a> · <a href="models/duck-b2-master-rig.glb">含三个动作的 GLB</a> · <a href="source/duck-b2-master-cage.blend">可编辑控制网格 Blender</a> · <a href="source/duck-b2-master-rig.blend">绑定与动作 Blender</a></p>
<h2>对照已确认的 B2 概念</h2><img src="../concepts-b2/duck-b2-turnaround.png" alt="已确认的原始 B2 生图三视图">
<p class="small">上图为原始生图，下列图为实际网格。生图各视角并非严格工程投影，造型一致性仍由人工验收；这里没有将概念图当作三维技术验证结果。</p>
<div class="grid"><figure><img src="renders/front.png"><figcaption>正面：小头、窄躯干、贴身翅膀与小蹼足</figcaption></figure><figure><img src="renders/side.png"><figcaption>侧面：连续头颈胸曲线与短尾</figcaption></figure><figure><img src="renders/head-detail.png"><figcaption>头部放大：小黑眼与宽扁鸭嘴，独立近景</figcaption></figure></div>
<h2>同一张网格的姿态与动作</h2><img src="renders/pose-sheet.png"><div class="grid"><figure><img src="renders/duck_idle.gif"><figcaption>待机</figcaption></figure><figure><img src="renders/duck_greet.gif"><figcaption>招呼</figcaption></figure><figure><img src="renders/duck_click.gif"><figcaption>点击回弹</figcaption></figure></div>
<p class="small">动画来自导出 GLB 回读渲染。三个动作都有实际顶点位移，结束回到静止姿态；尚未在 Unity 导入或替换首页。</p>
<h2>游戏俯视与缩略图</h2><div class="grid"><figure><img src="renders/gameplay.png"><figcaption>游戏俯视检查</figcaption></figure><figure><img src="renders/icon-192.png" width="192" height="192"><figcaption>192px 原始图标</figcaption></figure><figure><img src="renders/icon-64.png" width="64" height="64"><figcaption>64px 原始图标</figcaption></figure></div>
<h2>技术状态</h2><table><tr><th>项目</th><th>实际结果</th></tr>
'''
 for key,val in [('实测头宽 / 躯干宽',f"{p['headToTorsoWidth']:.1%}"),('单脚宽 / 躯干宽',f"{p['footToTorsoWidth']:.1%}"),('母模三角面','5,412；低于 6,000 上限，高于 2,000–4,000 目标，未宣称达到组合件目标'),('静态 / 动作 GLB',f"{a['models'][0]['bytes']:,} / {a['models'][1]['bytes']:,} bytes"),('材质','单网格、单材质、单 primitive，256px 图集'),('几何与格式','GLB 回读闭合、尺寸与居中检查；Khronos 零错误、零警告'),('尚待完成','母模造型验收、三款融合重做、同尺寸竞品对照、其余 17 款、Unity 首页与独立评审关及运行验证')]:
  content+=f'<tr><td>{key}</td><td>{val}</td></tr>'
 content+='''</table><h2>高模与简化版轮廓</h2><img src="renders/high-low-sheet.png"><p class="small">同一个控制网格细分得到高模与简化版，使用相同尺度、镜头和灯光。轮廓差异报告只验证简化损失，不代表设计验收。</p><p><a href="qa/silhouette-comparison.json">轮廓对照记录</a> · <a href="qa/glb-validation.json">glTF 检查</a> · <a href="qa/rig-roundtrip-validation.json">动作回读检查</a> · <a href="README.md">交付说明与下一步</a></p></main></html>'''
 (OUT/'review.html').write_text(content,'utf-8')

def verify():
 static=OUT/'models/duck-b2-master/duck-b2-master.glb'
 source=read(OUT/'qa/render-source.json')
 assert source['sha256']==hashlib.sha256(static.read_bytes()).hexdigest(),'stale static render evidence'
 validation=read(OUT/'qa/glb-validation.json');assert validation['passed']
 icons=[]
 for size in [192,64]:
  im=Image.open(OUT/'renders'/f'icon-{size}.png');bbox=im.getchannel('A').getbbox();margin=min(bbox[0],bbox[1],size-bbox[2],size-bbox[3])
  assert im.size==(size,size)
  if size==192:assert margin>=6
  icons.append({'pixels':size,'alphaBounds':bbox,'minimumMargin':margin})
 content=(OUT/'review.html').read_text('utf-8')
 links=re.findall(r'(?:src|href)="([^"#]+)"',content)
 missing=[x for x in links if not (OUT/x).exists()];assert not missing,missing
 write(OUT/'qa/delivery-checks.json',{'passed':True,'icons':icons,'htmlLocalReferences':len(links),'missingReferences':missing,'browserLayoutVerified':False,'staticRenderHashCurrent':True,'artApproval':False,'unityAcceptance':False})

def manifest():
 files=[]
 for p in sorted(OUT.rglob('*')):
  if p.is_file() and p.name!='delivery.json' and 'animation-frames' not in p.parts:
   b=p.read_bytes();files.append({'path':p.relative_to(OUT).as_posix(),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()})
 write(OUT/'delivery.json',{'status':'awaiting-user-b2-master-mesh-review','conceptApproved':True,'masterMeshApproved':False,'paid3dGenerationCalled':False,'unityAssetsChanged':False,'threeCombinationRedoStarted':False,'remainingSeventeenStarted':False,'files':files})
 dest=ROOT/'work/duck-b2-master-review-20261025.zip'
 with zipfile.ZipFile(dest,'w',zipfile.ZIP_DEFLATED) as z:
  for file in files:z.write(OUT/file['path'],'master-b2/'+file['path'])
  z.write(OUT/'delivery.json','master-b2/delivery.json')
  z.write(OUT.parent/'concepts-b2/duck-b2-turnaround.png','concepts-b2/duck-b2-turnaround.png')
 print(json.dumps({'package':str(dest),'bytes':dest.stat().st_size,'files':len(files)},ensure_ascii=False))

def main():
 silhouette();animations()
 sheet('master-turnaround.png',['front.png','side.png','hero.png'],['正面','侧面','三分之四'],'同一母模、同一尺度；头宽约为躯干的 40%，单脚宽约为躯干的 33%。')
 sheet('pose-sheet.png',['pose-rest.png','pose-reach.png','pose-greeting.png'],['自然收翅','向前探颈','抬翅招呼'],'同一母模与骨架，只改变姿态，不重新构造头部。',500)
 sheet('high-low-sheet.png',['high-side.png','side.png'],['高模曲面','简化版 GLB'],'同尺度、同镜头；用于检查细分和减面的轮廓损失。',650)
 html();verify();manifest()

if __name__=='__main__':main()
