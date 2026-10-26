"""Freeze measured performance evidence and update the current analysis chapters."""
import hashlib
import json
import re
import shutil
import statistics
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'work/performance-20261024'
ANALYSIS=ROOT/'competitor-analysis'
DEST=ANALYSIS / 'evidence/2026-10-24-微信进局性能'


def analysis_document(name):
    """Resolve current project reports separately from competitor research."""
    report = ROOT / 'docs/development-reports' / name
    return report if report.exists() else ROOT / 'competitor-analysis' / name

def read(p):return json.loads(p.read_text('utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,s):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,'utf-8')
def copy(src,dest):
    dest.parent.mkdir(parents=True,exist_ok=True)
    if src.is_dir():shutil.copytree(src,dest,dirs_exist_ok=True,ignore=shutil.ignore_patterns('__pycache__'))
    else:shutil.copy2(src,dest)

def main():
    before=read(WORK/'baseline/performance.json');desktop=read(WORK/'optimized-desktop/performance.json');mobile=read(WORK/'optimized-mobile/performance.json')
    play=read(WORK/'mobile-experience/experience.json');visual=read(WORK/'mobile-visual-final/algorithm-acceptance.json')
    algorithm=read(WORK/'final-algorithm/algorithm-acceptance.json');package=read(ROOT/'work/wechat-integration/package-audit.json')
    assert all(r['passed'] for r in [before,desktop,mobile,play,visual,algorithm]) and len(play['rounds'])==20
    assert all(len(r['samples'])==10 for r in [before,desktop,mobile])
    assert package['localPackagePassed'];tests=ET.parse(WORK/'edit-tests.xml').getroot();assert tests.attrib['result']=='Passed'
    tested=WORK/'final-algorithm/tested-runtime-sources'
    for p in (ROOT/'projects/catch-big-goose-unity/Assets/Scripts').glob('*.cs'):assert sha(p)==sha(tested/p.name),p.name
    for p in (ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data').glob('*.json'):
        if (tested/p.name).exists():assert sha(p)==sha(tested/p.name),p.name
    warm_before=statistics.mean(s['createMs'] for s in before['samples'] if s['warm'])
    warm_after=statistics.mean(s['createMs'] for s in desktop['samples'] if s['warm'])
    cold_before=statistics.mean(s['createMs'] for s in before['samples'] if not s['warm'])
    cold_after=statistics.mean(s['createMs'] for s in desktop['samples'] if not s['warm'])
    table=['| 主题 | 冷/重复 | 原创建累计 ms | 优化后创建累计 ms | 原进局秒 | 优化后进局秒 | 移动档进局秒 | 移动档最长帧 ms |',
           '| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |']
    for a,b,c in zip(before['samples'],desktop['samples'],mobile['samples']):
        assert a['theme']==b['theme']==c['theme'] and a['warm']==b['warm']==c['warm']
        table.append(f"| {a['theme']} | {'重复' if a['warm'] else '冷'} | {a['createMs']:.2f} | {b['createMs']:.2f} | {a['spawnSeconds']:.2f} | {b['spawnSeconds']:.2f} | {c['spawnSeconds']:.2f} | {c['frameMaxMs']:.2f} |")
    models=list((ROOT/'projects/catch-big-goose-unity/Assets/Resources/Physics').glob('*.asset'))
    text=f'''# 17 微信进局卡顿：竞品证据与性能优化

更新：2026-10-24。用户确认卡点是**点击开始后，物件加载/下落阶段**。未提供具体手机型号；本轮不能把桌面代理测试写成手机已达标。

## 1. 定位到的项目开销

**【确认·项目源码】** 原 CreateItem 首次遇到一种物件时，读取完整渲染网格、CombineMeshes、遍历全部顶点后再抽成最多 100 个方向极点，并在生成循环中安装凸包。原普通件最高约 19,904 三角面/5 材质（yuxi），青蛙 8,128 面/9 材质，鸭子 5,860 面/11 材质；这是模型管线原审计值，不能误称每个物件都达到这个量。农场容器约 25,000 面。

原生成每批叠加同步资源查找、实例化、包围盒/组件遍历、Physics.SyncTransforms 和有分配的 OverlapBox 查询；HUD 每帧重复查找槽图标并格式化文本。深度刷新又分配列表、五探针数组和渲染组件数组。移动端原先与桌面共用 120 Hz 物理、12/4 次求解和实时软阴影。它们是可直接确认的成本来源；各项在用户手机上占用多少毫秒仍未取得 Profiler 记录。

## 2. 竞品实际采用的路径

以下来自 402 的 IL2CPP 指针映射及实际 WASM 方法体，未连接竞品服务器或修改其缓存：

| 范围 | 可确认内容 | 证据位置 |
| --- | --- | --- |
| 物件池 | CreateUnitObj 调 LevelObjectPool.Get；Get 取 JObjectPoolGroup.GetItem 并激活对象；Recycle 调 RecycleItem | [主模块](证据/2026-10-24-微信进局性能/竞品/competitor-main/method-map.json)中的 $j7378/$j43490/$j4698 |
| 预载 | PreloadObjMod.Start 调 PrepareLoadMa.PreLoadTempObj；后者调 AssetManager.LoadAsset<GameObject> 并订阅 AssetRequest.Completed | [预载方法](证据/2026-10-24-微信进局性能/竞品/competitor-preload-main/j14179.annotated.wat) |
| 资源缓存 | getLoadedAssetRequest 在按 key/type 分层的字典中查询；存在动态/静态请求容器 | [原字典查找](证据/2026-10-24-微信进局性能/竞品/competitor-main/j15789.annotated.wat) |
| 分帧创建 | 已读普通分支按批次与等待间隔创建；LoopCreateObj 调 HideRigid | 原间隔/每批 3 个及边界见[第 15 章](15-三消单局核心算法与调优.md)；本轮保留相应原方法体 |
| 深度物理 | SetRigid 实际写 Rigidbody.isKinematic；HideRigid 检查已有状态/速度再调 SetRigid | [方法与摘录](证据/2026-10-24-微信进局性能/竞品/competitor-summary.json) |

**【确认·资源】** 此前缓存是分主题/依赖的 bundle 组织，烧烤物件三个包的样本合计约 1.45 MiB；缓存总量不是首包量。[原资源观察](02-操作观察与美术资源.md)仍保留原范围。

**【推测／待确认】** 预载回调不等于后台线程；未恢复其所有请求调度、设备分档、实时帧预算和所有对象池清理触发。不能从类名推出“已完全复现 Addressables”。原场景 real-physics-space=0，不能把 70 当成始终有效的硬限额，也没有证据支持竞品正好用我们的 30 FPS/60 Hz。

## 3. 本项目落地的优化

以下全部标为**【项目适配】**，库存、权重与三件组算法保持现有 21 类基线：

1. `GooseAssetCache` 只准备本局队列涉及的模型、物理网格及容器，以 `Resources.LoadAsync` 逐件载入并在整合之间让帧；缓存资源引用和归一化变换。准备阶段展示进度，不扣游戏倒计时，可正常暂停/返回。
2. `GoosePhysicsBake` 把原方向极点算法迁到 Editor，产出 {len(models)} 件、每件 4–100 顶点的归一化碰撞资源。运行时不再读大渲染网格顶点或 CombineMeshes；预载时准备小凸包。既有七种基础碰撞型继续使用胶囊/盒体。
3. 建立按 ID 的实体实例池，最多保留当前主题 300 件。消除/返首页时回收；重复开局恢复缩放、显隐、碰撞、刚体、选取和深度状态。金鹅特殊材质不进入普通池。换主题清池、清模型引用并让 Unity 回收无用资源，避免叠加保留五套实体。
4. 原每批数量和间隔保留，移动端再加约 2 ms 的创建循环预算。一次工作超过预算会额外让帧；这不是承诺单次 Unity 原生调用一定小于 2 ms。
5. OverlapBox 改成复用缓冲区的 NonAlloc 查询，保留净空检查；缓冲区用满直接报错，不默默接受重叠。深度扫描复用列表和已缓存碰撞/组件引用，五射线继续保留。移除后全体唤醒的保守规则仍在，本轮没有冒险把它换成未经支撑验证的局部唤醒。
6. HUD 缓存 Sprite，并在显示状态改变时更新，减少每帧资源查找、字符串与 Canvas 更新。
7. 微信/WebGL 使用独立基线：30 FPS 渲染目标、60 Hz 物理、6/2 次求解、最大物理补算窗口约 66.7 ms、关闭实时阴影/抗锯齿。保留碰撞连续检测。桌面默认物理频率和材质不按此档降级。
8. 移动端使用原创逐顶点光照 Shader，保留纹理和立体明暗，并启用相同模型的 GPU instancing 材质。实际合批次数和手机 GPU 时间仍需真机测量，不能把 enableInstancing=true 写成已测得的 draw call 降幅。
9. 微信导出改为 Release，保留原 AppID 和媒体分包。SDK 复制出的约 5.2 MB 未压缩符号表归档到工程工具目录；压缩符号仍在包内。当前没有启用增量代码分包，后续若启用需重新核对原符号的构建用途。

接口依据：[Unity 2022.3 LoadAsync](https://docs.unity3d.com/2022.3/Documentation/ScriptReference/Resources.LoadAsync.html)、[Physics.BakeMesh](https://docs.unity3d.com/2022.3/Documentation/ScriptReference/Physics.BakeMesh.html)。异步载入仍有主线程整合成本，凸包准备也不是免费的后台工作。

## 4. 实测：CPU 工作减少，首次准备不等于更短

**【观察·项目桌面代理】** 在 Windows 无图形开发包中，先后对五主题各跑冷/重复开局。原版和优化桌面档保持相同默认渲染目标/物理频率；另单跑移动档。每局实建 300 件，等待生成完成及 2 秒物理阶段。具体顺序和原日志已冻结。

优化桌面档的 `CreateItem` 累计 CPU 时间平均：冷创建 {cold_before:.2f}→{cold_after:.2f} ms，重复创建 {warm_before:.2f}→{warm_after:.2f} ms（约减少 {(1-warm_after/warm_before)*100:.1f}%）。**该计时不含前移到准备阶段的资源载入、整合与凸包准备，也不含整局物理/渲染总开销**，所以不能称为整局性能提高相同比例。

{chr(10).join(table)}

首次进局整体等待增加：桌面约 3.3–3.5 秒变为 4.8–5.0 秒，移动代理约 6.3 秒。它用可响应、有进度的准备换掉重活集中执行；并未测得首次总加载时长缩短。重复开局桌面约 3.7–4.0 秒，移动代理约 4.1 秒。若要进一步缩短冷等待，可在首页空闲时预取；本轮未额外引入这一调度。

移动代理的最长帧约 {max(s['frameMaxMs'] for s in mobile['samples']):.2f} ms，10 个样本结束时越界库存均为 0。这只是本机 Windows 进程、30 FPS 上限下的结果；不是微信模拟器或手机 FPS。旧农场桌面档仍出现约 67–83 ms 的帧峰值，说明原高面容器/物理路径还有继续测量的价值，不能用平均创建时间掩盖尖峰。

## 5. 回归与微信交付

- Unity 编辑测试 {tests.attrib['passed']}/{tests.attrib['total']}，新增离线碰撞尺寸/有限顶点、实体回收状态恢复和移动 Shader 入包检查。
- 最新算法开发包 {len(algorithm['checks'])} 项；移动性能档可见策略 {len(play['checks'])} 项、20/20 完整清盘；该策略有准确 ID、快速扫描能力，不是人工通关率。
- 移动档真实相机/HUD 截图 {len(visual['checks'])} 项通过，并查看五个 300 件主题。首版轻量光照过平，已保留旧图并修复，最终图见[画面](证据/2026-10-24-微信进局性能/运行/最终移动画面/core-2.png)。
- 当前微信目录为 `builds/catch-big-goose-wechat`，Release 包体 {package['rawMiB']:.2f} MiB，导出 JavaScript {package['javascriptFiles']} 件语法通过，数据包和 WASM 已解压检查。视频分包保持完整，未删除玩法资源来压预算。
- 微信实际新包的模拟器运行和目标手机性能**本轮尚未确认**；此前模拟器成功记录属于旧构建，不能移用。手机型号、CPU/GPU 分项时间和加载最长帧仍待采样。
- 尝试自动重新打开新包时，微信开发者工具 CLI 返回 `TypeError: d.on is not a function (code 10)`；因此没有把“已导出”写成“新包模拟器已通过”。新包仍在原目录，可手动导入/重新编译。

每个移动档单局开始约 5 秒后，会输出一条有上限的 `[GoosePerf]` JSON：含平台、准备/生成墙钟时间、最长帧、P95、创建耗时和深度状态。`managedBytes` 仅是托管堆估计，不能称总内存。真正的后续判断应以同一手机的这些日志及微信性能工具为准。

## 6. 复现与失败记录

`tools/competitor/run_unity_algorithm_tests.ps1` 构建/运行规则验收；编辑菜单构建方法 `GooseAlgorithmBuild.BuildPerformance` 生成独立 PerformanceQA 包。运行参数 `-goosePerformanceQa -goosePerformanceOutput <目录>` 采样桌面；加 `-gooseMobileProfile` 强制移动档；`-gooseExperienceQa` 为可见策略整局检查。微信通过 `tools/unity/build-wechat.ps1` 重建。

第一次 Release 导出被 30 MiB 项目预算拒绝（33,517,416 字节），原因之一是原始/压缩符号重复；归档原始符号后再导出通过。旧预算失败日志、首版明暗图、优化前源码及全部原始测试均保留。[本轮汇总](证据/2026-10-24-微信进局性能/验证汇总.json)与[SHA-256 清单](证据/2026-10-24-微信进局性能/文件校验.json)记录当前构建。此前各轮证据保持原样。
'''
    history=ANALYSIS / 'history/2026-10-24-微信性能优化前章节'
    for name in ['README.md','05-Unity接入.md','07-验证结果与后续清单.md','11-推测与待确认.md','15-三消单局核心算法与调优.md','16-每主题21类与单局体验.md']:
        if not (history/name).exists():copy(analysis_document(name),history/name)
    write(ROOT / 'docs/development-reports/17-微信进局性能与竞品优化.md',text)
    note='\n## 微信进局性能补充（2026-10-24）\n\n已将资源分帧准备、离线碰撞网格、按主题实例池、HUD/深度分配优化及独立移动性能档接入。竞品池化/预载原方法、前后 CPU 计时、18 项编辑测试、132 项算法检查、移动档 20 局样本及实际微信新包边界见[第 17 章](17-微信进局性能与竞品优化.md)。桌面代理不等于手机性能；首局准备总时长并未缩短。\n'
    for name in ['05-Unity接入.md','07-验证结果与后续清单.md','11-推测与待确认.md','15-三消单局核心算法与调优.md','16-每主题21类与单局体验.md']:
        p=analysis_document(name);s=p.read_text('utf-8');
        if '## 微信进局性能补充' not in s:write(p,s+note)
    p=ANALYSIS/'README.md';s=p.read_text('utf-8')
    s=s.replace('本轮 Unity 编辑模式 15/15','本轮 Unity 编辑模式 18/18')
    if '[17 微信进局性能' not in s:s=s.replace('全文使用以下标记','| 性能补充 | 内容 |\n| --- | --- |\n| [17 微信进局性能与竞品优化](17-微信进局性能与竞品优化.md) | 物件池、预载、离线凸包、移动档与前后实测；真机边界单列 |\n\n全文使用以下标记')
    write(p,s)
    p=ROOT/'projects/catch-big-goose-unity/README.md';old=p.read_text('utf-8')
    if not (WORK/'unity-readme-before.md').exists():write(WORK/'unity-readme-before.md',old)
    old=old.replace('普通物件总数仍为 48 / 54 / 81，冰封与独立金鹅保留，消除后不补货。当前五主题未强套竞品不同物件的权重。','当前核心档总量为 15 / 60 / 300，每主题 21 类；核心档使用 coreGroupWeights，原值来源与语义代理分别标注。旧 48 / 54 / 81、冰封及独立金鹅只用于回归档。消除后不补货。')
    old=old.replace('本轮实际 Unity 2022.3.62f3 编辑模式 10/10 通过；独立算法开发包 75/75 通过','2026-10-23 历史验收：Unity 2022.3.62f3 编辑模式 10/10 通过；独立算法开发包 75/75 通过')
    if '## 微信进局性能（2026-10-24）' not in old:
        old += '\n## 微信进局性能（2026-10-24）\n\n当前核心档为 15/60/300 件、每主题 21 类；旧 48/54/81 件文字属于回归档历史说明。已加入分帧资源准备、104 件离线碰撞网格、当前主题 300 件上限的实例池，以及独立 WebGL 移动档（30 FPS 目标/60 Hz 物理/无实时阴影）。正式微信包位于 `../../builds/catch-big-goose-wechat`；默认以 Release 构建。冷准备不扣游戏时间，重复开局复用对象；手机性能仍待实际设备采样。原始符号保存在 `work/wechat-integration/release-symbols/`，压缩符号保留在包内。[完整研究、实测和待确认](../../docs/development-reports/17-微信进局性能与竞品优化.md)。\n'
    write(p,old)
    for name in ['baseline','optimized-desktop','optimized-mobile','mobile-experience','mobile-visual-final','final-algorithm','baseline-sources','baseline-instrumented-sources','competitor-main','competitor-secondary','competitor-preload-main']:
        target='竞品/'+name if name.startswith('competitor-') else '运行/'+('最终移动画面' if name=='mobile-visual-final' else name)
        copy(WORK/name,DEST/target)
    for name in ['competitor-summary.json','edit-tests.xml','edit-tests.log','wechat-build-package-budget.log','wechat-convert-symbols-fixed.log','wechat-final-build.log','performance-build.log','baseline-build.log','baseline-build-fixed.log','unity-readme-before.md']:
        copy(WORK/name,DEST/'运行'/name)
    copy(WORK/'visual-before-lighting-fix',DEST/'运行/首版明暗图')
    copy(WORK/'competitor-summary.json',DEST/'竞品/competitor-summary.json')
    copy(WORK/'wechat-payload-check.json',DEST/'构建/载荷与符号校验.json')
    copy(ROOT/'work/wechat-integration/devtools-open.log',DEST/'构建/开发工具打开结果.log')
    for source,target in [('projects/catch-big-goose-unity/Assets/Scripts','源码/运行'),('projects/catch-big-goose-unity/Assets/Editor','源码/编辑器'),('projects/catch-big-goose-unity/Assets/Tests/Editor','源码/编辑测试'),('projects/catch-big-goose-unity/Assets/Resources/Data','资源/配置'),('projects/catch-big-goose-unity/Assets/Resources/Physics','资源/离线碰撞'),('projects/catch-big-goose-unity/Assets/Resources/GooseItemMobile.shader','资源/GooseItemMobile.shader'),('projects/catch-big-goose-unity/Assets/Resources/GooseMobileTemplate.mat','资源/GooseMobileTemplate.mat'),('projects/catch-big-goose-unity/WeChatBuild.local.json','构建/微信配置.json'),('work/wechat-integration/package-audit.json','构建/包体检查.json'),('work/wechat-integration/release-symbols','构建/原始符号'),('tools/unity/archive_performance.py','复现工具/archive_performance.py'),('tools/unity/build-wechat.ps1','复现工具/build-wechat.ps1')]:copy(ROOT/source,DEST/target)
    for p in ANALYSIS.glob('*.md'):copy(p,DEST/'文档'/p.name)
    artifact=[]
    for p in sorted((ROOT/'builds/catch-big-goose-wechat').rglob('*')):
        if p.is_file():artifact.append(dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=sha(p)))
    comparison=dict(scope='Desktop headless CPU calls, same desktop settings before/after, separate forced mobile profile; not phone FPS',
        coldCreateMsBefore=cold_before,coldCreateMsAfter=cold_after,warmCreateMsBefore=warm_before,warmCreateMsAfter=warm_after,
        warmCreateReductionPercent=(1-warm_after/warm_before)*100,coldLatencyImproved=False)
    summary=dict(passed=True,editTests=int(tests.attrib['passed']),algorithmChecks=len(algorithm['checks']),mobileExperienceChecks=len(play['checks']),
        fullRounds=len(play['rounds']),wins=sum(r['result']=='win' for r in play['rounds']),visualChecks=len(visual['checks']),bakedPhysicsMeshes=len(models),
        packageBytes=package['rawBytes'],packageMiB=package['rawMiB'],wechatSimulatorRuntimePassed=None,phoneRuntimePassed=None,phoneModel=None,
        comparison=comparison,artifact=artifact,limits=['No phone or newly exported WeChat simulator performance capture','Cold preparation latency increased; work distributed across frames','GPU instancing enabled, actual draw count not measured','Global support wake retained','Baked collision shape; render geometry not simplified'])
    write(DEST/'验证汇总.json',json.dumps(summary,ensure_ascii=False,indent=2))
    files=[dict(path=p.relative_to(DEST).as_posix(),bytes=p.stat().st_size,sha256=sha(p)) for p in sorted(DEST.rglob('*')) if p.is_file() and p.name!='文件校验.json']
    write(DEST/'文件校验.json',json.dumps(files,ensure_ascii=False,indent=2))
    for r in files:assert sha(DEST/r['path'])==r['sha256']
    links=0
    for p in ANALYSIS.glob('*.md'):
        for target in re.findall(r'(?<!!)\[[^\]]+\]\(([^)]+)\)',p.read_text('utf-8')):
            if '://' in target:continue
            path=(p.parent/target.split('#')[0].strip('<>')).resolve();assert path.exists(),(p.name,target);links+=1
    print(json.dumps(dict(evidenceFiles=len(files),activeLinks=links,comparison=comparison,packageMiB=package['rawMiB']),ensure_ascii=False))

if __name__=='__main__':main()
