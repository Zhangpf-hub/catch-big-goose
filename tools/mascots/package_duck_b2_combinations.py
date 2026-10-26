"""Evidence and review package for the three actual B2 combination meshes."""
from pathlib import Path
import hashlib
import importlib.util
import json
import re
import zipfile
from PIL import Image,ImageDraw,ImageFont

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'source-assets/models/candidates/duck-series-v1/model-review-b2'
IDS=['duck-eggtart','duck-steelcup','duck-numberblock']
NAMES={'duck-eggtart':'蛋挞鸭','duck-steelcup':'钢杯鸭','duck-numberblock':'积木鸭'}
PAPER=(237,240,236);CARD=(250,249,244);INK=(34,57,55);MUTED=(88,105,102)
spec=importlib.util.spec_from_file_location('checks',Path(__file__).with_name('compose_duck_review.py'))
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S);S.OUT=OUT

def read(p):return json.loads(p.read_text('utf-8'))
def write(p,d):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n','utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def font(n):return ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',n)
def text(d,xy,s,n=24,fill=INK):d.text(xy,s,font=font(n),fill=fill)
def pic(c,p,xy,size=None):
 im=Image.open(p).convert('RGBA')
 if size:im=im.resize(size,Image.Resampling.LANCZOS)
 c.paste(im,xy,im)
def card(c,xy,size):
 x,y=xy;w,h=size;ImageDraw.Draw(c).rounded_rectangle((x,y,x+w,y+h),14,CARD)

def comparison(view):
 edge=640 if view in ['hero','gameplay'] else 512
 w=edge*2+96;row=edge+72;h=166+row*3+80
 c=Image.new('RGB',(w,h),PAPER);d=ImageDraw.Draw(c)
 label={'hero':'三分之四','gameplay':'游戏俯视','front':'正面','side':'侧面','back':'背面'}[view]
 text(d,(30,22),'B2 鸭子 × 竞品同类模型',34)
 text(d,(30,73),label+' · 每件最长边统一为 1 · 同镜头、灯光、画布 · 无单独裁切放大',19,MUTED)
 text(d,(30,118),'竞品实际网格',23);text(d,(edge+64,118),'B2 实际网格',23)
 for i,id in enumerate(IDS):
  y=166+i*row;m=read(OUT/'qa'/f'{id}-metrics.json')
  text(d,(30,y),f'{NAMES[id]}  /  {m["triangles"]:,} 三角面',23)
  for col,kind in enumerate(['reference','duck']):
   x=32+col*(edge+32);card(c,(x,y+38),(edge,edge));pic(c,OUT/'renders'/id/kind/(view+'.png'),(x,y+38))
 text(d,(30,h-58),'竞品保留源姿态，以提取材质的 PBR 近似显示；不是原游戏截图。造型待用户验收。',17,MUTED)
 c.save(OUT/'renders'/f'comparison-{view}.png')

def overview():
 edge=400;gap=24;c=Image.new('RGB',(edge*3+gap*4,1100),PAPER);d=ImageDraw.Draw(c)
 text(d,(24,22),'B2 三款组合 · 同尺寸真实模型对照',34)
 text(d,(24,74),'每件最大边 = 1，同镜头、同灯光。上：竞品；下：B2 鸭子。',20,MUTED)
 for i,id in enumerate(IDS):
  x=24+i*(edge+gap);text(d,(x,122),NAMES[id],26)
  for j,kind in enumerate(['reference','duck']):
   y=168+j*438;card(c,(x,y),(edge,edge));pic(c,OUT/'renders'/id/kind/'hero.png',(x,y),(edge,edge))
   text(d,(x+14,y+10),'竞品' if j==0 else 'B2',21)
 text(d,(24,1035),'实际 GLB 回读渲染；竞品材质为 PBR 近似，保留源姿态。',19,MUTED)
 c.save(OUT/'renders/comparison-overview.png')

def turnarounds():
 for id in IDS:
  edge=360;views=['front','side','back','hero'];labels=['正面','侧面','背面','三分之四']
  c=Image.new('RGB',(edge*4+100,edge+160),PAPER);d=ImageDraw.Draw(c)
  text(d,(22,20),NAMES[id]+' · 同一 GLB 的四视图',30)
  for i,(v,l) in enumerate(zip(views,labels)):
   x=20+i*(edge+20);card(c,(x,88),(edge,edge));pic(c,OUT/'renders'/id/'duck'/(v+'.png'),(x,88),(edge,edge));text(d,(x+12,96),l,20)
  text(d,(22,edge+112),'保持完整物体比例与相同正交尺度；未按每张图的轮廓单独放大。',18,MUTED)
  c.save(OUT/'renders'/f'{id}-turnaround.png')

def thumbs():
 c=Image.new('RGB',(1352,650),PAPER);d=ImageDraw.Draw(c)
 text(d,(24,20),'192 / 64px 缩略图对照',32)
 text(d,(24,70),'每组左为竞品，右为 B2；均按原始像素显示。',20,MUTED)
 for i,id in enumerate(IDS):
  x=26+i*448;text(d,(x,118),NAMES[id],26)
  for col,kind in enumerate(['reference','duck']):
   xx=x+col*210;card(c,(xx,180),(192,192));pic(c,OUT/'renders'/id/kind/'icon-192.png',(xx,180))
   text(d,(xx+55,385),'竞品' if col==0 else 'B2',20)
   card(c,(xx+64,462),(64,64));pic(c,OUT/'renders'/id/kind/'icon-64.png',(xx+64,462))
 text(d,(24,586),'透明 PNG 单独交付；缩略图辨识仍需结合实际游戏密堆和托盘验收。',18,MUTED)
 c.save(OUT/'renders/thumbnail-comparison.png')

def quality():
 rows=[]
 for id in IDS:
  for view in ['front','side','back','hero','gameplay']:
   paths=[OUT/'quality-baseline/renders'/id/'duck'/(view+'.png'),OUT/'renders'/id/'duck'/(view+'.png')]
   images=[Image.open(p).convert('RGBA') for p in paths]
   assert images[0].size==images[1].size
   masks=[[v>=128 for v in im.getchannel('A').tobytes()] for im in images]
   inter=sum(a and b for a,b in zip(*masks));union=sum(a or b for a,b in zip(*masks));iou=inter/union
   rows.append({'id':id,'view':view,'iou':iou,'passed':iou>=.98,'imageHashes':[sha(p) for p in paths]})
 result={'passed':all(r['passed'] for r in rows),'minimumIou':.98,'rows':rows,'method':'Detailed and mobile GLB roundtrip silhouettes, each maximum edge 1, same camera and canvas; includes tiny normalization differences.','doesNotProveArtApproval':True,'exposedHeadNeckSkinFurtherDecimated':False}
 write(OUT/'qa/mobile-silhouette-check.json',result);assert result['passed'],result
 edge=400;c=Image.new('RGB',(edge*2+72,3*(edge+60)+150),PAPER);d=ImageDraw.Draw(c)
 text(d,(24,20),'简化前后轮廓检查',30);text(d,(24,70),'左：较密版本；右：移动端版本',20,MUTED)
 for i,id in enumerate(IDS):
  y=120+i*(edge+60);text(d,(24,y),NAMES[id],24)
  for j,folder in enumerate([OUT/'quality-baseline',OUT]):
   x=24+j*(edge+24);card(c,(x,y+38),(edge,edge));pic(c,folder/'renders'/id/'duck/hero.png',(x,y+38),(edge,edge))
 c.save(OUT/'renders/mobile-silhouette-review.png')
 return result

def unity_evidence():
 path=OUT/'qa/unity-import/unity-audit.json'
 if not path.exists():return None
 result=read(path);assert result['passed'] and result['unityVersion']=='2022.3.62f3'
 for row in result['models']:
  assert row['visualHash']==sha(OUT/'models'/row['id']/(row['id']+'.fbx'))
 for item in read(OUT/'qa/unity-import/staging.json')['inputs']:
  assert sha(ROOT/item['source'])==item['sha256'],item['source']
 for item in read(OUT/'qa/unity-import/evidence.json')['files']:
  assert sha(OUT/'qa/unity-import'/item['path'])==item['sha256'],item['path']
 return result

def gameplay_evidence():
 path=OUT/'qa/gameplay/evidence.json'
 if not path.exists():return None
 result=read(path);assert result['passed']
 for item in result['candidateInputs']:assert sha(ROOT/item['source'])==item['sha256'],item['source']
 for item in result['files']:assert sha(path.parent/item['path'])==item['sha256'],item['path']
 for profile in ['desktop','mobile']:
  report=read(path.parent/profile/'acceptance.json')
  assert report['passed'] and report['removed']==9 and report['roundTrips']==2
 return result

def materials_and_batch():
 unity=unity_evidence()
 rows=[]
 for id in IDS:
  folder=OUT/'models'/id
  mr=Image.open(folder/'metalrough.png').convert('RGB');_,rough,metal=mr.split()
  zero=Image.new('L',mr.size,0);smooth=rough.point(lambda v:255-v)
  Image.merge('RGBA',(metal,zero,zero,smooth)).save(folder/'unity-metallic.png')
  write(folder/'materials.json',{'materialName':id+'-mobile','baseColor':{'file':'albedo.png','sRGB':True},'gltfMetalRough':{'file':'metalrough.png','sRGB':False,'metallic':'B','roughness':'G'},'unityStandardMetallic':{'file':'unity-metallic.png','sRGB':False,'metallic':'R','smoothness':'A','conversion':'R=B, A=1-G from metalrough.png'},'unityImportVerified':bool(unity),'unityImportScope':'Isolated Unity 2022.3.62f3 QA project' if unity else None,'productionProjectImported':False})
  m=read(OUT/'qa'/f'{id}-metrics.json');ref=read(OUT/'qa'/f'{id}-reference-comparison.json');col=read(OUT/'qa'/f'{id}-collision.json')
  assert col['offlineGeometryPassed'] and col['sourceSha256']==sha(folder/(id+'.glb'))
  row={'id':id,'name':NAMES[id],'model':f'models/{id}/{id}.glb','fbx':f'models/{id}/{id}.fbx','source':f'source/{id}-authored.blend','icon192':f'renders/{id}/duck/icon-192.png','icon64':f'renders/{id}/duck/icon-64.png','albedo':f'models/{id}/albedo.png','collision':f'models/{id}/convex-hull.obj','collisionCoordinates':'Blender Z-up, offline proxy only','normalizedDimensionsBlenderZUp':m['dimensions'],'normalizedDimensionsGltfYUp':[m['dimensions'][0],m['dimensions'][2],m['dimensions'][1]],'reference':ref['input'],'referenceSha256':ref['sourceSha256'],'triangles':m['triangles'],'glbBytes':m['glbBytes'],'hullTriangles':col['triangles'],'unityImported':False,'artApproved':False}
  row['unityImported']=bool(unity);row['unityImportScope']='isolated-qa-project' if unity else None;row['productionProjectImported']=False
  row['realGameSnapshotVerified']=bool(gameplay_evidence());row['wechatDeviceVerified']=False
  rows.append(row)
 write(OUT/'batch.json',{'stage':'three-representative-art-review','items':rows,'formalThemesChanged':False,'remainingSeventeenStarted':False,'homepageChanged':False})
 return rows

def html(rows):
 content='''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>B2 三款鸭子模型验收</title><style>body{margin:0;background:#edf0ec;color:#223937;font:16px/1.65 system-ui,"Microsoft Yahei",sans-serif}main{max-width:1280px;margin:auto;padding:28px}h1{font-size:34px;margin:0}h2{margin-top:38px;font-size:24px}img{display:block;max-width:100%;border-radius:12px}a{color:#267464}p{max-width:1080px}.grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}figure{margin:0;padding:16px;border-radius:14px;background:#faf9f4}figcaption{margin-top:8px}.tag{display:inline-block;padding:7px 12px;border-radius:8px;background:#e3e1c6}.small{font-size:14px;color:#586966}table{border-collapse:collapse;width:100%;background:#faf9f4}td,th{padding:10px;text-align:left;border-bottom:1px solid #d5ddd3}nav{display:flex;gap:18px;flex-wrap:wrap;margin:15px 0}@media(max-width:800px){.grid{grid-template-columns:1fr}main{padding:18px}}</style><main><span class="tag">真实模型 · 待造型验收</span><h1>B2 蛋挞鸭、钢杯鸭、积木鸭</h1><p>三款使用同一鸭子母模的头、嘴、眼睛、颈部与小脚，通过骨架安排探颈姿态。原先大头、小短颈的三款已被替换为本批候选；旧版作为历史问题证据保留。</p><img src="renders/comparison-overview.png"><p class="small">每个对象最长边统一为 1、包围盒居中，采用相同正交镜头、灯光和画布。竞品保留提取时姿态，显示的是基础色/PBR 近似，不是原游戏画面。没有按每张图轮廓单独放大。</p><nav><a href="renders/comparison-hero.png">大图对照</a><a href="renders/comparison-gameplay.png">游戏俯视对照</a><a href="renders/comparison-front.png">正面对照</a><a href="renders/comparison-side.png">侧面对照</a><a href="renders/comparison-back.png">背面对照</a><a href="renders/thumbnail-comparison.png">192/64px 对照</a></nav>'''
 for row in rows:
  id=row['id'];concept={'duck-eggtart':'eggtart','duck-steelcup':'steelcup','duck-numberblock':'numberblock'}[id]
  content+=f'''<h2>{row['name']}</h2><img src="renders/{id}-turnaround.png"><div class="grid"><figure><img src="renders/{id}/duck/hero.png"><figcaption>真实移动端 GLB</figcaption></figure><figure><img src="../concepts-b2/duck-b2-{concept}.png"><figcaption>已确认的 B2 融合生图方向</figcaption></figure><figure><img src="renders/{id}/duck/gameplay.png"><figcaption>游戏俯视检查</figcaption></figure></div><p><a href="{row['model']}">GLB</a> · <a href="{row['fbx']}">FBX</a> · <a href="{row['source']}">可编辑 Blender</a> · <a href="models/{id}/materials.json">贴图映射</a></p>'''
 content+='''<h2>预算与验证</h2><table><tr><th>模型</th><th>三角面</th><th>GLB</th><th>状态</th></tr>'''
 for r in rows:content+=f'<tr><td>{r["name"]}</td><td>{r["triangles"]:,}</td><td>{r["glbBytes"]/1024:.1f} KiB</td><td>单网格 / 材质 / primitive；256px 图集</td></tr>'
 content+='''</table><p>三款均落在 2,000–4,000 三角面目标内。GLB 回读、居中与最大边检查、闭合性及 Khronos 零错误零警告检查通过；已生成离线凸包。Unity 材质导入、PhysX 密堆/休眠、拾取/托盘/三消仍待后续运行验收。</p><h2>简化与辨识检查</h2><img src="renders/mobile-silhouette-review.png"><img src="renders/thumbnail-comparison.png"><p class="small">较密版本与移动端版本均由实际网格渲染；轮廓检查用于限制简化损失，不能替代造型验收。</p><p><a href="qa/mobile-silhouette-check.json">简化轮廓记录</a> · <a href="qa/comparison-verification.json">同尺寸条件检查</a> · <a href="qa/glb-validation.json">Khronos 检查</a> · <a href="batch.json">模型与物件映射</a> · <a href="README.md">交付说明</a></p><p>当前为前三款联合验收。尚未扩展其余 17 款或替换首页和正式主题；没有调用付费图生 3D。</p></main></html>'''
 if unity_evidence():
  content=content.replace('Unity 材质导入、PhysX 密堆/休眠、拾取/托盘/三消仍待后续运行验收。','独立 Unity 2022.3.62f3 QA 工程已验证材质、骨骼顶点变形、45 件 PhysX 混合密堆与自然休眠。正式游戏的拾取/托盘/三消尚未接入验证。')
  section='''<h2>Unity 导入检查</h2><img src="renders/unity-import-overview.png"><p>灰棚使用 Unity Standard 材质，非正式游戏灯光。三款 FBX 三角面与 GLB 一致；45/45 刚体在 15 秒内自然休眠，移除底部支撑后 44/44 再次稳定。母模三个动作都使实际蒙皮顶点运动并返回静止姿态。</p><p><a href="qa/unity-import/unity-audit.json">Unity 检查记录</a> · <a href="qa/unity-import/physx-mixed-pile.png">实际物理堆叠</a> · <a href="qa/fbx-triangle-provenance.json">FBX 网格来源</a></p>'''
  content=content.replace('<h2>简化与辨识检查</h2>',section+'<h2>简化与辨识检查</h2>')
 if gameplay_evidence():
  content=content.replace('正式游戏的拾取/托盘/三消尚未接入验证。','独立 Windows QA Player 已使用真实游戏代码验证屏幕拾取、托盘、三消与重复进出；尚未发布到正式工程或进行微信真机验收。')
  section='''<h2>实际游戏流程检查</h2><img src="renders/gameplay-acceptance-overview.png"><p>使用真实游戏代码的独立 Windows QA Player。桌面配置与移动端配置均生成 45 件鸭子，三款各经三次屏幕射线拾取完成三消，重复进出后重新生成。未强制显示埋藏物件，也未使用自动拾取绕过输入。退出时恢复测试前主题与关卡配置，故事成绩及挑战次数未改变。</p><p>新增的鸭子专用单通道材质保留金属/光滑度贴图，目前只在 QA 副本中使用。上述证据不代表微信真机性能通过，也不代表其余 17 款或五主题评审关已完成。</p><p><a href="qa/gameplay/mobile/acceptance.json">移动端配置检查</a> · <a href="qa/gameplay/desktop/acceptance.json">桌面配置检查</a> · <a href="qa/gameplay/GooseDuckMobile.shader">候选鸭子材质</a></p>'''
  content=content.replace('<h2>简化与辨识检查</h2>',section+'<h2>简化与辨识检查</h2>')
 (OUT/'review.html').write_text(content,'utf-8')

def manifest_and_zip():
 files=[]
 for p in sorted(OUT.rglob('*')):
  rel=p.relative_to(OUT)
  if not p.is_file() or p.name=='delivery.json':continue
  if 'quality-baseline' in rel.parts and ('source' in rel.parts or p.suffix=='.fbx'):continue
  files.append({'path':rel.as_posix(),'bytes':p.stat().st_size,'sha256':sha(p)})
 workspace=read(OUT/'qa/structure-check.json') if (OUT/'qa/structure-check.json').exists() else None
 write(OUT/'delivery.json',{'status':'awaiting-user-three-model-art-review','conceptsApproved':True,'b2MasterMeshSeparatelyApproved':False,'threeModelsArtApproved':False,'formalThemesReplaced':False,'remainingSeventeenStarted':False,'unityImported':bool(unity_evidence()),'unityImportScope':'isolated-qa-project','realGameSnapshotVerified':bool(gameplay_evidence()),'wechatDeviceVerified':False,'productionProjectImported':False,'productionGameVerified':False,'paid3dGenerationCalled':False,'workspaceStructureCheckPassed':workspace['passed'] if workspace else None,'files':files})
 zipPath=ROOT/'work/duck-three-models-b2-review-20261025.zip'
 with zipfile.ZipFile(zipPath,'w',zipfile.ZIP_DEFLATED) as z:
  for f in files:z.write(OUT/f['path'],'model-review-b2/'+f['path'])
  z.write(OUT/'delivery.json','model-review-b2/delivery.json')
  for name in ['eggtart','steelcup','numberblock']:z.write(OUT.parent/'concepts-b2'/f'duck-b2-{name}.png',f'concepts-b2/duck-b2-{name}.png')
 with zipfile.ZipFile(zipPath) as z:
  assert z.testzip() is None
  for f in files:assert hashlib.sha256(z.read('model-review-b2/'+f['path'])).hexdigest()==f['sha256']
 print(json.dumps({'candidatePackageChecksPassed':True,'workspaceStructureCheckPassed':workspace['passed'] if workspace else None,'zip':str(zipPath),'bytes':zipPath.stat().st_size,'files':len(files)},ensure_ascii=False))

def main():
 assert read(OUT/'qa/glb-validation.json')['passed']
 comparisonEvidence=S.verify();quality()
 for view in ['hero','gameplay','front','side','back']:comparison(view)
 overview();turnarounds();thumbs();rows=materials_and_batch();html(rows)
 links=re.findall(r'(?:src|href)="([^"#]+)"',(OUT/'review.html').read_text('utf-8'))
 missing=[link for link in links if not (OUT/link).exists()];assert not missing,missing
 workspace=read(OUT/'qa/structure-check.json') if (OUT/'qa/structure-check.json').exists() else None
 write(OUT/'qa/delivery-checks.json',{'passed':True,'scope':'candidate-local files, rendering evidence and input hashes; isolated Unity QA recorded separately','workspaceStructureCheckPassed':workspace['passed'] if workspace else None,'workspaceStructureErrors':workspace['errors'] if workspace else None,'sameSizeComparisonPassed':comparisonEvidence['passed'],'offlineHullGeometryAndInputHashesPassed':True,'htmlLocalReferences':len(links),'missingReferences':missing,'browserLayoutVerified':False,'isolatedUnityEditorQaPassed':bool(unity_evidence()),'unityRuntimeVerified':bool(gameplay_evidence()),'unityRuntimeScope':'isolated Windows player, real-game snapshot, desktop and mobile settings','wechatDeviceVerified':False,'artAccepted':False})
 manifest_and_zip()

if __name__=='__main__':main()
