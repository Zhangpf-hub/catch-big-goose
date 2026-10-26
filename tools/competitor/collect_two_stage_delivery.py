"""Freeze successful evidence and distributable hashes without altering the game."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'work/two-stage-20261025'
FROZEN=WORK/'frozen-project';PROJECT=FROZEN/'projects/catch-big-goose-unity';SNAPSHOTS=FROZEN/'work/two-stage-20261025'
def read(p): return json.loads(p.read_text('utf-8-sig'))
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def relative(p): return p.relative_to(ROOT).as_posix()
def evidence(name,flag='passed'):
    p=WORK/name; data=read(p)
    assert data[flag], (name,data.get('errors'))
    return dict(path=relative(p),sha256=sha(p),result=data)

source=evidence('source-verification.json')
play=evidence('frozen-playtest-final/story-acceptance.json')
assert play['result']['rounds']==10
flow=evidence('frozen-flow/flow-acceptance.json')
tutorials=evidence('frozen-tutorial-taps/story-acceptance.json');assert tutorials['result']['rounds']==5
modal=evidence('frozen-modal-layout/modal-acceptance.json')
layouts=[evidence(folder+'/story-acceptance.json') for folder in ['frozen-layout-short','frozen-layout-tall','frozen-layout-safe']]
look=evidence('model-preview-clean/look-acceptance.json')
tests=WORK/'frozen-edit-tests.xml'; result=ET.parse(tests).getroot()
assert result.attrib['result']=='Passed' and int(result.attrib['failed'])==0
models=ROOT/'source-assets/models/candidates/two-stage-models-20261025/validation.json'
containers=ROOT/'source-assets/models/candidates/two-stage-containers-20261025/validation.json'
for p in [models,containers]:
    r=read(p); assert r['passed']
    assert all(x['passed'] and x['issues']['numErrors']==0 and x['issues']['numWarnings']==0 for x in r['models'])
native=read(SNAPSHOTS/'Windows-sources.json'); qa=read(WORK/'frozen-playtest-final/sources.json')
assert native==qa, 'Native release and QA must use the same runtime sources'
modalSources=read(SNAPSHOTS/'StoryFinalQA-sources.json')
assert all(modalSources.get(p)==h for p,h in native.items()), 'Modal QA changed production source'
is_harness=lambda p:p.replace('\\','/').endswith('/GooseStoryAcceptance.cs')
tapSources=read(SNAPSHOTS/'StoryTapQA-sources.json')
assert all(tapSources.get(p)==h for p,h in native.items() if not is_harness(p)), 'Tap QA changed production source'
assert all(sha(PROJECT/p.replace('\\','/'))==h for p,h in native.items() if not is_harness(p)), 'Frozen production sources changed after build'
assert (PROJECT/'Assets/Scripts/GooseStoryAcceptance.cs').read_text('utf8').startswith('#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL')
assert b'GooseStoryAcceptance' not in (PROJECT/'Builds/Windows/catch-big-goose_Data/Managed/CatchGoose.Runtime.dll').read_bytes()
package=PROJECT/'Builds/WeChat/minigame'
audit=read(WORK/'frozen-wechat-audit.json'); assert audit['localPackagePassed']
preview=read(WORK/'wechat-preview-info.json'); assert preview['size']['total']>0
assert (WORK/'wechat-preview.png').stat().st_size>1000
archive=read(WORK/'windows-archive.json');assert sha(ROOT/archive['path'])==archive['sha256']
from PIL import Image, ImageDraw, ImageFont, ImageOps
canvas=Image.new('RGB',(960,1140),(242,236,219));draw=ImageDraw.Draw(canvas)
font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',17)
for row,state in enumerate(['win','retry']):
    for col,size in enumerate(['360x640','390x844','430x932','safe']):
        label=('390x844 刘海' if size=='safe' else size)+(' · 通关' if state=='win' else ' · 重试')
        draw.text((col*240+8,row*570+8),label,font=font,fill=(48,35,22))
        im=ImageOps.contain(Image.open(WORK/'frozen-modal-layout'/(size+'-'+state+'.png')).convert('RGB'),(236,530))
        canvas.paste(im,(col*240+(240-im.width)//2,row*570+35))
canvas.save(WORK/'phone-modal-layouts.jpg',quality=93)
def manifest(folder):
    return [dict(path=relative(p),bytes=p.stat().st_size,sha256=sha(p)) for p in sorted(folder.rglob('*')) if p.is_file() and p.suffix!='.meta']
runtime=manifest(PROJECT/'Assets/Resources')
windows=manifest(PROJECT/'Builds/Windows'); wechat=manifest(package)
assert any(x['path'].endswith('CatchGoose.exe') for x in windows)
report=dict(
    createdUtc=datetime.now(timezone.utc).isoformat(),scope='Frozen 402 source configuration, actual Unity rendering and local distributables',
    localImplementationPassed=True,phoneDeviceAcceptancePassed=None,
    source=source,editorTests=dict(path=relative(tests),sha256=sha(tests),total=int(result.attrib['total']),passed=int(result.attrib['passed']),seedCases=1000),
    runtime=play,flow=flow,tutorialScreenTaps=tutorials,layouts=layouts,modalLayouts=modal,materialPreview=look,
    gltfValidation=[dict(path=relative(p),sha256=sha(p),models=len(read(p)['models'])) for p in [models,containers]],
    runtimeSources=native,modalQaSources=modalSources,tapQaSources=tapSources,qaHarnessDifferences=[p for p,h in native.items() if tapSources.get(p)!=h],resourceFiles=runtime,windowsFiles=windows,windowsArchive=archive,wechatFiles=wechat,
    wechatAudit=dict(path=relative(WORK/'frozen-wechat-audit.json'),rawBytes=audit['rawBytes'],rawMiB=audit['rawMiB'],javascriptFiles=audit['javascriptFiles']),
    frozenProject=relative(PROJECT),qaSaveIsolation='QA development player uses CompanyName CatchGooseStoryFrozenQA; production runtime save code is identical to release.',
    preview=dict(qr='work/two-stage-20261025/wechat-preview.png',uploadedBytes=preview['size']['total'],sha256=sha(WORK/'wechat-preview.png')),
    art=dict(sourceMaterialGroups=191,glassMaterialGroups=17,colorOnlyMaterialGroups=32,mascot='Live Shiba; breathing, sway, tap rebound and sound',formalContainers='Five current R4 circular containers',sourceSceneDressingEnabled=read(PROJECT/'Assets/Resources/Data/interaction-r4.json')['sceneDressing'],recoveredSceneMeshes='Five recovered source scene meshes kept as optional set dressing; disabled in frozen release, excluded from stock and picking'),
    artifacts=['home-and-two-stages.jpg','five-themes.jpg','116-models.jpg','competitor-comparison.jpg','phone-modal-layouts.jpg','home-animation.mp4','play-animation.mp4'],
    limitations=['Normal-speed samples use automated screen taps; they are not human difficulty or competitor win-rate measurements.',
        'Instant complete-inventory traversal verifies conservation and progression, not play difficulty.',
        'Safe-area tests are simulated native player windows; no iPhone or Android device was connected for this delivery.',
        'Preview upload succeeded; device touch, motion sensors, sustained FPS and the latest WeChat runtime remain to be checked on a phone.',
        'The original sampler could repeat a point blocked by the rim. The corrected development-only sampler uses the production collision mask; its five tutorial replays are authoritative for tutorial completion/time.',
        'R3 material reconstruction approximates the original Shader; account-specific AB and server hotfix values are intentionally frozen out.'])
(WORK/'delivery.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),'utf8')
obs=[next(t for t in tutorials['result']['observations'] if t['theme']==o['theme']) if o['stage']==1 else o for o in play['result']['observations']]
lines=['# 两关与 UI 本地交付','',
    '五主题、十关、116 类模型；第一关 15 件／不限时，第二关 300 件。正式 Windows 包和验收包的运行源码哈希一致。','',
    f"编辑测试 {result.attrib['passed']}/{result.attrib['total']}，包含 1000 个种子；十关实际运行及真实入口流程通过。三种手机比例和模拟刘海安全区检查通过。",'',
    f"微信本地文件 {audit['rawMiB']} MiB；开发者工具上传 {preview['size']['total']:,} 字节，二维码已生成。",'',
    '稳定包： [Windows 完整压缩包](CatchGoose-TwoStage-20261025-Windows.zip) · [微信预览码](wechat-preview.png)。解压后运行 `CatchGoose/CatchGoose.exe`。','',
    '| 主题 | 关卡 | 总数 | 本次实际类型 | 正常点击采样（秒） | 点选数 | 最大槽位压力 | 可见物件 |',
    '| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |']
for o in obs:
    lines.append(f"| {o['theme']} | {o['stage']} | {o['total']} | {o['types']} | {o['normalPlaySeconds']:.1f} | {o['picks']} | {o['maxTray']} / 7 | {o['visible']} |")
lines+=['','这些是正常速度自动点选样本；完整库存遍历另外执行，均不代表人工难度或竞品胜率。第一关采用修正筐沿遮挡判断后的五主题复测记录，时间不含开局预加载。原始十关日志按原路径保留。','',
    '画面： [烧烤首页与两关](home-and-two-stages.jpg) · [五主题](five-themes.jpg) · [116 模型](116-models.jpg) · [竞品并排](competitor-comparison.jpg)。','',
    '手机弹窗： [三种比例与模拟刘海](phone-modal-layouts.jpg)，通关和重试按钮均检查安全区与至少 44 像素触控范围。','',
    '动画： [首页](home-animation.mp4) · [入槽消除](play-animation.mp4)。片段由实际采集帧编码，无音轨；游戏内音乐和反馈音效由运行时播放。','',
    '逐层逐类型件数见 `frozen-playtest-final/story-acceptance.json` 的 stocks；模型、材质、源码、包文件哈希及全部验收路径见 [delivery.json](delivery.json)。','',
    '源码与稳定发布包保存在 `frozen-project/`，避免另一活跃任务修改同一工作区造成版本错位。验收开发包采用独立 CompanyName 隔离 PlayerPrefs；正式存档代码与正式包一致。','',
    '真机验收未完成：尚未连接 iPhone／Android 检查触控、传感器与持续帧率；本地画面和预览上传不替代手机实际运行。失败后的中间日志按原路径保留。']
(WORK/'README.md').write_text('\n'.join(lines)+'\n','utf8')
print(f"Delivery frozen: {len(windows)} Windows files, {len(wechat)} WeChat files, {len(runtime)} resource files; {len(obs)} actual rounds.")
