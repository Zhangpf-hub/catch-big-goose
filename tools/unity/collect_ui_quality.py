"""Freeze UI-only render evidence; keep prior two-stage delivery untouched."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,xml.etree.ElementTree as ET
from zipfile import ZipFile,ZIP_DEFLATED
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2];WORK=ROOT/'work/ui-quality-20261025';PLAYER=WORK/'final-player'
def read(p):return json.loads(p.read_text('utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
qa=read(PLAYER/'ui-quality.json');assert qa['passed'] and qa['requestedMsaa']==2 and qa['supportedCaptureMsaa']>=2
tests=ET.parse(WORK/'final-tests.xml').getroot();assert tests.get('result')=='Passed'
audit=read(WORK/'wechat-audit.json');assert audit['localPackagePassed']
preview=read(WORK/'wechat-ui2-preview-info.json');assert preview['size']['total']>0
sources=read(WORK/'UIQualityQA-sources.json');assert sources==read(WORK/'Windows-sources.json')
for size in ['360x640','390x844','430x932']:
    for page in ['home','stage1','stage2','win','retry']:assert Image.open(PLAYER/(size+'-'+page+'.png')).size==tuple(map(int,size.split('x')))
font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',22)
def strip(images,labels,file):
    canvas=Image.new('RGB',(390*len(images),892),(248,242,219));d=ImageDraw.Draw(canvas)
    for i,(p,label) in enumerate(zip(images,labels)):
        im=Image.open(p).convert('RGB');assert im.size==(390,844);d.text((i*390+12,10),label,font=font,fill=(66,38,18));canvas.paste(im,(i*390,48))
    canvas.save(WORK/file,quality=95)
strip([ROOT/'work/two-stage-20261025/frozen-playtest-final/barbecue-home.png',PLAYER/'390x844-home.png'],['前版实际画面','九宫与采样修正后'],'home-before-after.jpg')
strip([PLAYER/'390x844-home.png',PLAYER/'390x844-stage2.png',PLAYER/'390x844-retry.png'],['首页 · 原生九宫背景','对局 · 2× MSAA 捕获','结算 · 固定边框'],'ui2-actual-game.jpg')
windows=ROOT/'projects/catch-big-goose-unity/Builds/Windows';archive=WORK/'CatchGoose-UI2-Windows.zip'
with ZipFile(archive,'w',ZIP_DEFLATED,compresslevel=4) as z:
    for p in sorted(windows.rglob('*')):
        if p.is_file():z.write(p,'CatchGoose/'+p.relative_to(windows).as_posix())
with ZipFile(archive) as z:assert z.testzip() is None
package=ROOT/'builds/catch-big-goose-wechat'
def files(folder):return [dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=sha(p)) for p in sorted(folder.rglob('*')) if p.is_file() and p.suffix!='.meta']
report=dict(createdUtc=datetime.now(timezone.utc).isoformat(),passed=True,revision='UI2',editorTests=dict(total=int(tests.get('total')),passed=int(tests.get('passed'))),nativeRender=qa,
    sourceHashes=sources,nineSlice=read(ROOT/'source-assets/models/candidates/ui-candy-v2/contract.json'),windowsFiles=files(windows),wechatFiles=files(package),
    archive=dict(path=archive.relative_to(ROOT).as_posix(),bytes=archive.stat().st_size,sha256=sha(archive)),wechatRawMiB=audit['rawMiB'],previewBytes=preview['size']['total'],
    renderSettings=dict(msaaRequested=2,wechatPixelRatioRequested=2,webglDefaultQualityMsaa=2,uiSurfaces='256x192 RGBA32; mipmapped/trilinear',toolIllustrationMaxSize=256,homeIconsMipmapped=5),
    screenFiles=[dict(file=p.name,size=Image.open(p).size,sha256=sha(p)) for p in sorted(PLAYER.glob('*.png'))],
    highResolutionDesktopCapture=dict(requested=[780,1688],actual=Image.open(PLAYER/'780x1688-home.png').size,note='Desktop window height is capped by monitor; this is not a real 390x844 Retina phone capture.'),
    phoneAcceptance=None,phoneFpsMeasured=False,limitations=['Native capture used RTX 3070 Ti; WebGL/device MSAA support and sustained frame rate need phone verification.','Pixel ratio 2 renders about 1.78 times the pixels of 1.5; the existing 1.5 comparison option remains available.','Previous two-stage frozen packages remain historical; use this UI2 preview QR for current UI.'])
(WORK/'delivery.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),'utf8')
text=f'''# UI2：九宫与抗锯齿修正

本轮修改正式 UI、采样和渲染设置；关卡、库存、模型、碰撞和存档规则没有调整。原第 25 章冻结交付保留，本轮验收记录在此目录。

## 原因

之前确实使用了 `Image.Type.Sliced`，但长胶囊成品图统一使用 100px 边界和 PPU multiplier 4，套在方形主题入口及高弹窗上会拉伸中部高光和弯曲边缘。启用 Sliced 并不能自动使任意成品图适合九宫。

手机锯齿还存在另外两条路径：移动档关闭了 MSAA，iOS 导出将画布固定为 1.5 倍像素比；大幅缩小的插画缺少 mipmap。源位图分辨率高本身不是根因：采样不当的大图缩小时会产生闪边，画布像素不足又会把整幅渲染结果放大。

## 实施

- 按九宫规则制作三张 256×192 原生 SVG 背景：按钮 border 64、面板 border 48，PPU multiplier 2。角、白边、棕边和立体底座保留在固定切片内，中心只含可拉伸的平直区域。文字与插画分离。
- UI 背景及道具插画使用无损 RGBA32、Clamp、mipmap 与三线性采样。插画按实际显示范围限制导入尺寸为 256，原始素材保留；首页五个缩小图标启用 mipmap，其余收藏图标保持原预算。
- 启用像素对齐、2× MSAA；WebGL 默认 High 档也开启 2× MSAA。iOS 导出及 WX 初始化统一请求 2 倍像素比，材质对照关闭时也恢复到 2，保留 1.5 的性能对照入口。
- 旧位图背景及 GUID 归档到 `source-assets/ui/UiNineSliceBaseline-20261025`；新资源的 SVG 源文件和规格位于 `source-assets/models/candidates/ui-candy-v2`。

## 验证与下载

编辑测试 {tests.get('passed')}/{tests.get('total')}；实际 Image 网格覆盖 15 组素材／比例组合，确认角宽不随控件长宽变化。三种手机比例、模拟安全区、首页、15 件教学、300 件挑战及两类结算弹窗通过实际 Unity 渲染检查。原生捕获实际支持并使用 2× MSAA。QA 与 Windows 正式包源码哈希一致。

[同一渲染器九宫对比](final-player/nine-slice-comparison.png) · [首页前后](home-before-after.jpg) · [实装三联图](ui2-actual-game.jpg)

[Windows 完整包](CatchGoose-UI2-Windows.zip) · [新微信预览码](wechat-ui2-preview.png) · [完整数据与文件哈希](delivery.json)

微信本地包 **{audit['rawMiB']} MiB**，预览上传 **{preview['size']['total']:,} 字节**，通过包预算、61 个 JS 语法和两支原视频完整性检查。Windows 默认启动目录已更新。

未连接真机验证持续帧率。默认像素比从 1.5 升到 2 会增加约 78% 渲染像素；不能用桌面截图保证手机帧率。额外请求 780×1688 的桌面窗口被显示器限制为 780×1440，仅作为高分辨率渲染样本，不冒充手机 Retina 截图。

原理参考：[Unity 2022.3 WebGL 画布与像素比](https://docs.unity3d.com/2022.3/Documentation/Manual/webgl-canvas-size.html)、[WebGL 抗锯齿与平台支持](https://docs.unity3d.com/2022.3/Documentation/Manual/webgl-graphics.html)。
'''
(WORK/'README.md').write_text(text,'utf8')
print('UI2 evidence, visual comparisons and verified Windows archive written.')
