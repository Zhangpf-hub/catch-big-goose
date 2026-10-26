"""Freeze this delivery without changing previous evidence or its checksums."""
import hashlib
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path
from catalog import ROOT, BATCH, specifications

ANALYSIS=ROOT/'竞品分析'
DEST=ANALYSIS/'证据/2026-10-24-21类与单局体验'

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def read(path):return json.loads(path.read_text('utf-8-sig'))
def write(path,text):path.parent.mkdir(parents=True,exist_ok=True);path.write_text(text,'utf-8')
def copy(source,target):
    target.parent.mkdir(parents=True,exist_ok=True)
    if source.is_dir():shutil.copytree(source,target,dirs_exist_ok=True,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
    else:shutil.copy2(source,target)

def main():
    work=ROOT/'work/theme21';experience=read(work/'experience-final/experience.json')
    algorithm=read(work/'algorithm-final/algorithm-acceptance.json');visual=read(work/'visual-final/algorithm-acceptance.json')
    assert experience['passed'] and len(experience['rounds'])==20
    assert algorithm['passed'] and visual['passed']
    rounds=experience['rounds'];won=sum(r['result']=='win' for r in rounds)
    weights=read(work/'weight-bindings.json');metrics=read(BATCH/'qa/generation.json')
    themes=read(ROOT/'unity/Assets/Resources/Data/themes.json')['themes']
    # Guard that the tested configuration and all production sources are still current.
    tested=work/'algorithm-final/tested-runtime-sources'
    for source in (ROOT/'unity/Assets/Scripts').glob('*.cs'):assert sha(source)==sha(tested/source.name),source
    for name in ['themes.json','core-rounds.json','pile-algorithms.json','level-tuning.json']:
        assert sha(ROOT/'unity/Assets/Resources/Data'/name)==sha(tested/name),name
    for row in read(BATCH/'qa/validated-models.json'):assert sha(BATCH/'models'/f"{row['id']}.glb")==row['sha256']
    for source,target in [
        (work/'algorithm-final','运行/算法'),(work/'experience-final','运行/可见策略'),
        (work/'experience-first-attempt','运行/首轮统计修正前'),(work/'visual-final','画面'),
        (work/'policy-tests','运行/生产CSharp'),(work/'edit-tests.xml','运行/编辑测试.xml'),
        (work/'edit-tests.log','运行/编辑测试.log'),(work/'release-build.log','运行/发行构建.log'),
        (work/'release-startup.log','运行/发行启动.log'),
        (work/'weight-bindings.json','配置/权重来源.json'),(work/'staged-assets.json','资源/接入清单.json'),
        (work/'before-themes.json','配置/扩充前主题.json'),(BATCH,'原创候选'),
        (ROOT/'tools/theme21','复现工具/theme21'),(ROOT/'tools/unity/convert_assets.py','复现工具/convert_assets.py'),
        (ROOT/'tools/unity/prepare_assets.py','复现工具/prepare_assets.py'),
        (ROOT/'skills/match3-model-pipeline/scripts/generate_electronics.py','复现工具/model-pipeline/generate_electronics.py'),
        (ROOT/'skills/match3-model-pipeline/scripts/audit_assets.mjs','复现工具/model-pipeline/audit_assets.mjs'),
        (ROOT/'tools/competitor/run_unity_algorithm_tests.ps1','复现工具/run_unity_algorithm_tests.ps1'),
        (ROOT/'unity/Assets/Tests/Editor','运行/编辑测试源码')]:copy(source,DEST/target)
    for i in range(12):copy(work/'audit-sets'/str(i)/'qa',DEST/'资源/Jolt补充检查'/str(i))
    bindings=['# 16A 自有物品与原始权重对应表','','更新：2026-10-24。共 105 项。**原值是确认的资源证据，语义对应和跨表组合均属项目适配**；不是账号实际加载结果。','',
              '数值取自冻结 LevelData；NameList 与 OtherTypeWeight 按同一原始下标读取。`sourceRow` 是 dataArray 零起始行号，`sourceOrdinal` 是行内零起始下标。同一 Index/模式/关卡可以有多层，不能当唯一行键；对应 JSON 另存原高度与普通数量。完整记录及表哈希见[权重来源](证据/2026-10-24-21类与单局体验/配置/权重来源.json)。','',
              'Goose_ 前缀的竞品特殊造型映射到自有普通物件时，也不是恢复了原特殊目标语义。数码、动物和工具的代理尤其不能视作直接对应。','',
              '| 主题 | 自有 ID | 原值 | Index / 模式 / 关卡 | dataArray 行 | 原 NameList 名称 | 行内下标 | 对应关系（项目适配） |',
              '| --- | --- | ---: | --- | ---: | --- | ---: | --- |']
    for b in weights['bindings']:
        bindings.append(f"| {b['theme']} | {b['id']} | {b['weight']:g} | {b['sourceIndex']} / {b['sourceGameType']} / {b['sourceLevel']} | {b['sourceRow']} | {b['sourceName']} | {b['sourceOrdinal']} | {b['mappingConfidence'].split(': ',1)[1]} |")
    write(ANALYSIS/'16A-物品与实际权重对应.md','\n'.join(bindings)+'\n')
    rows=['| 主题 | 档位 | 自有种子 | 总量 / 消除 | 结果 | 游戏秒 | 槽位峰值* | 移出/凑齐/打乱 | 各层普通种类 |',
          '| --- | --- | ---: | --- | --- | ---: | ---: | --- | --- |']
    for r in rounds:
        rows.append(f"| {r['theme']} | {['轻松','标准','大师'][r['difficulty']]} | {r['seed']} | {r['total']} / {r['removed']} | {r['result']} | {r['gameSeconds']:.1f} | {r['peakTray']} | {'/'.join(map(str,r['tools']))} | {'/'.join(map(str,r['layerKinds']))} |")
    depth=algorithm['snapshots'];depthrows=['| 主题 | 总量 | 隐藏 | 保持刚体 | 动态刚体 | 显示阈值 | 刚体阈值 |','| --- | ---: | ---: | ---: | ---: | ---: | ---: |']
    for s in depth:
        if '/core-2' in s['theme']:depthrows.append(f"| {s['theme']} | {s['total']} | {s['hidden']} | {s['held']} | {s['dynamicBodies']} | {s['visibleThreshold']:.3f} | {s['rigidThreshold']:.3f} |")
    text=f'''# 16 每主题 21 类与单局体验

更新：2026-10-24。本轮已把 Unity 五主题从各 9 类扩成各 21 类（包含各主题原有的鹅），新增 60 件原创模型和图标。它们已经进入实际 Resources、有限库存与发行包；竞品提取网格没有接入运行资源。[完整核心算法链见第 15 章](15-三消单局核心算法与调优.md)。

## 1. 已确认的原始数据

**【确认·资源】** 组数使用 NameList 对应的 OtherTypeWeight。水果活动 Index=1101 的第 2 关有 29 个候选，玉石 Index=3 和菜市场 Index=7 各 22 个，甜品 Index=6 有 21 个；这些候选数量不是统一的 21。水果活动首层 210 件也不能和统一主线样本首层 150 件混写。

实际数值例：水果 Blueberry=1.5、Pineapple=2、Goose_Coconut=0.5；玉石 JadePeanut=2、JadeChime=0.8；菜市场 Broccoli=1.5、Corn_WetMarket=2；甜品 Chocolate=1、Lollipop1=2。全部 105 项的表索引、模式、关卡、名称、下标及映射理由见[16A 对应表](16A-物品与实际权重对应.md)。相同原值被多个自有物品借用，不增加其证据强度。

**【确认·静态】** 类型先等权无放回选入，已选类型再按原取整公式分配完整三件组；OtherTypeWeight 不控制类型是否入选。前 N−1 项 RoundToEven，末项收余数。正权重仍可能得到零组，不能为了“21 类必定都出现”额外塞入三件、破坏总量。实际抽样生命周期和原始 RNG 仍有缺口。

## 2. 项目适配：资源与权重接入

五主题保留原 9 个 ID，各追加 12 个。原有四组普通层的候选上限现在可达到 21/10/8/7，不再被 9 类池截断。入口教学仍从排除目标鹅后的普通池选 2 类；标准档选 6/3 类。

`themes.json.coreGroupWeights` 保存上述来源数值；`GooseRules.MakeQueue` 按每层已选 ID 提取对应权重，交给生产 `WeightedGroupAllocation`。`itemWeights` 仍只管队列投放顺序，旧回归使用的 `groupWeights` 不承担这次主题适配。权重组合是**跨原表、跨语义的项目适配**，尤其数码无原版现代数码主题的完整对应表，借用了旧卧室物件的权重代理；不能宣称这五组就是原版五个主题。

新模型保留 .blend、GLB、192/64 像素图标和四视图。实际范围为 {min(r['triangles'] for r in metrics)}–{max(r['triangles'] for r in metrics)} 三角面、{min(r['bytes'] for r in metrics)}–{max(r['bytes'] for r in metrics)} 字节；简单轮廓低于目标面数，不通过增加无用面数凑预算。60 件均为单材质/单 primitive、64×64 色盘，回导后最长边 1、居中、厚度合格、零开放边和零退化三角形；Khronos 错误/警告均为 0。逐件查看了四视图和 64 像素识别图，并把偏粉的柿子改为橙色。[候选源文件与图集](证据/2026-10-24-21类与单局体验/原创候选/qa/generation.json)保留数值。

12 批 Jolt 补充测试每批 5 类×9 件，共 540 件，通过凸包、15 秒休眠、容器约束、射线和移除测试。它是原模型管线的补充证据，**不是 Unity PhysX 或手机性能报告**。实际 Unity 开发包另对 105 项主题引用创建真实 Collider/Renderer，并在实际关卡中测堆叠和点选。

## 3. 项目适配：分层、深度与难度

本轮主要通过扩大候选和接入非等权配额增加混杂与稀有组差异，保持已有来源层预算：轻松 12+3=15，标准 30+30=60，大师 150+60+45+45=300。大师原始高度 14/18/20/22、600 秒，其他来源字段见第 15 章。水果 29 类活动、不同主题的独立关卡进程尚未整体迁入。

深度基线仍采用已确认的可见深度 4–5、参考高度 21、刚体乘数 0.5、单次前沿下降 0.5；Unity 位置按 0.1 尺度适配为 0.4/0.5/2.1/0.05。密度 1.2/3.1/5、落点净空、稳定等待、遮挡保护、迟滞和移除唤醒属于项目适配；不能称为原几何体积采样复刻。70 仍是软预算，不通过强冻运动件制造“硬限额通过”。

以下是最新算法开发包的独立深堆快照，和通关策略测试不是同一个物理时间点：

{chr(10).join(depthrows)}

## 4. 自有运行观察：完整单局

开发包实际运行屏幕射线点选、七格槽、三消、暂存和正常道具；普通选择不调用 `Pick(true)`。策略只比较当前可射线点到的物件 ID、槽内和暂存物，不用遮住的库存安排下一步。优先补齐槽内对子、选择当前可见三件；临近满槽才请求合法道具，每类最多一次，不复活、不改配额。

**【项目适配·实测】** 20 个样本（五主题×三档，再各补一组大师种子）完成 {won}/20；运行有效性检查 {len(experience['checks'])} 项通过，射线失败点击合计 {sum(r['failedClicks'] for r in rounds)}、结束时越界库存合计 {sum(r['outOfBounds'] for r in rounds)}。每次动作间隔 0.25 游戏秒，测试以 3 倍时间推进以缩短等待；游戏秒包含生成和稳定等待。不同进程调度会改变 PhysX 结果，不能把同种子当二进制布局重放。

{chr(10).join(rows)}

*槽位峰值记录在一次动作和即时三消结算后，完成第三件在结算前的瞬时入槽没有计入。实际约束仍由生产七格槽执行。凑齐工具内部可以按其规则取得遮住的物件，策略只请求正常工具接口，不额外越权点选。

自动策略具有准确 ID、全可见范围扫描和快速决策能力；此表不是人工胜率或竞品胜率。当前样本槽压偏低，不能据此认定难度已等价，也不依据这 20 局臆造隐藏加难或动态改牌。需要同策略运行竞品、人工盲测和更多种子，再决定自有密度/尺寸/识别参数的下一步调整。

首轮验收误把所有名为 goose 的物件从普通类型统计中排除，导致主线普通鹅被漏计。已修复为仅在存在独立目标预算时排除目标；同时取消“正权重一定产生正配额”的错误验收假设。首轮部分报告、日志、当时脚本保留于[统计修正前](证据/2026-10-24-21类与单局体验/运行/首轮统计修正前/experience.json)，没有当作最终通过结果。

## 5. 验证与交付

- 生产 C# {read(work/'policy-tests/policy-tests.json').get('checks',104031):,} 项检查；含既有原 WASM 数值/加权轨迹和配额夹具，范围仍小于完整原版游戏。
- Unity 编辑测试 15/15，包括五主题各 80 个种子的分层完整三件组/库存守恒。
- 实际算法开发包 {len(algorithm['checks'])} 项检查通过；可见策略 {len(experience['checks'])} 项；真实相机和 HUD 绘制 {len(visual['checks'])} 项。
- 五个 300 件主题画面已逐张检查：[水果](证据/2026-10-24-21类与单局体验/画面/core-2.png)、[玉石](证据/2026-10-24-21类与单局体验/画面/antique-core-2.png)、[农场](证据/2026-10-24-21类与单局体验/画面/farm-core-2.png)、[甜品](证据/2026-10-24-21类与单局体验/画面/dessert-core-2.png)、[数码](证据/2026-10-24-21类与单局体验/画面/electronics-core-2.png)。另保留首页、入门与标准暂存画面。
- [Windows 可玩包](../unity/Builds/Windows/CatchGoose.exe)已重建；微信 SDK、广告/账号和手机性能不由这些桌面测试证明。

[验证汇总](证据/2026-10-24-21类与单局体验/验证汇总.json)、[文件校验](证据/2026-10-24-21类与单局体验/文件校验.json)冻结本轮源代码、配置、原创候选、权重对应、运行报告与失败历史。前轮证据未覆写。

## 6. 推测与待确认

1. 当前账号最终 AB 桶、热更加载顺序、最终关卡索引仍未取得；原始包和此前冻结公开响应不能代替这些输入。
2. 水果 29 候选、玉石/菜市 22 候选等完整主题模式，尚不能用统一 21 类主线样本概括。
3. 代理权重的现代数码、动物/工具语义是否合适，仍需人工识别与难度对照。实际数值有来源不等于映射已经确认。
4. 原 CreateInfo 体积采样、全模式随机生命周期、动画和触控时序、目标手机帧率与人工完成率仍缺对照证据。此次没有进一步声称这些已恢复。
'''
    write(ANALYSIS/'16-每主题21类与单局体验.md',text)
    # Update current chapters while preserving their earlier copies in 历史/.
    file=ANALYSIS/'README.md';s=file.read_text('utf-8')
    s=s.replace('9 类自有模型池及几何／输入／动画使体验尚未一比一等价。','五主题已扩为各 21 类，新增 60 件原创资源和 105 项有来源的配额映射；几何／输入／动画及权重语义代理仍使体验尚未一比一等价。')
    if '| [16 每主题' not in s:s=s.replace('全文使用以下标记', '| 补充章节 | 内容 |\n| --- | --- |\n| [16 每主题 21 类与单局体验](16-每主题21类与单局体验.md) | 新增原创资源、实际权重对应、分层深度与完整单局实测 |\n| [16A 物品与实际权重对应](16A-物品与实际权重对应.md) | 105 项原值与项目语义映射，逐项可追溯 |\n\n全文使用以下标记')
    s=s.replace('Unity 编辑模式 14/14、实际开发包算法验收 132 项通过。',f'本轮 Unity 编辑模式 15/15、实际开发包算法验收 {len(algorithm["checks"])} 项、可见策略 {len(experience["checks"])} 项通过，完整单局样本 {won}/20。')
    s=s.replace('[最新证据与验证汇总](证据/2026-10-24-核心单局与运行配置/验证汇总.json)', '[前轮核心证据与验证汇总](证据/2026-10-24-核心单局与运行配置/验证汇总.json)')
    if '本轮交付见[第 16 章]' not in s:s += '\n本轮交付见[第 16 章](16-每主题21类与单局体验.md)及[21 类与单局证据](证据/2026-10-24-21类与单局体验/验证汇总.json)。单局样本来自自有可见策略，不等于人工或竞品胜率。\n'
    write(file,s)
    file=ANALYSIS/'15-三消单局核心算法与调优.md';s=file.read_text('utf-8')
    s=s.replace('每主题现有 9 种模型，类型选择在实际生成时受现有候选数和组数限制；大师第一、二层不能达到原来的 21／10 种。','每主题现有 21 种模型，候选上限已满足大师 21／10／8／7；取整零配额仍可能减少实际非零类型。')
    s=s.replace('itemWeights 是投放顺序权重，groupWeights 是组数配额权重，均按实际候选 ID 映射；没有将烧烤原名权重强套到水果／数码模型。当前未配非等权主题时采用等量名义权重；非等权能力与零配额已测试。','itemWeights 是投放顺序权重；核心档新增 coreGroupWeights，按各层已选 ID 对应到 105 项有来源的非等权数值。groupWeights 保留旧回归用途。跨表组合和语义代理均是项目适配，详见第 16、16A 章；未提供配额时才使用等量名义权重。非等权能力与零配额已测试。')
    s=s.replace('当前 9 类模型、等量名义配额、不同碰撞与自有随机数使主线仍可能更容易。','当前已补至 21 类并使用有来源的非等权配额，但语义代理、不同碰撞与自有随机数仍影响难度。')
    s=s.replace('已分阶段，类型受自有模型池限制 | 每主题扩到足够可识别物品；建立权重语义对应','已分阶段，五主题各 21 类；105 项原值及代理映射 | 完整原主题候选与语义对照，继续验证零配额')
    if '## 11. 21 类扩充后的最新实测' not in s:s += f'\n## 11. 21 类扩充后的最新实测\n\n本轮每主题新增 12 件原创模型；生产非等权配额和分层选择已接入，完整可见策略单局样本 {won}/20，Unity 编辑测试 15/15。具体范围、游戏时长、槽位、深度快照、首轮统计错误和未证等难度的边界见[第 16 章](16-每主题21类与单局体验.md)。本章第 9 节的前轮证据保持历史含义，当前结果以第 16 章为准。\n'
    write(file,s)
    file=ANALYSIS/'05-Unity接入.md';s=file.read_text('utf-8')
    if '## 五主题 21 类接入补充' not in s:s += '\n## 五主题 21 类接入补充（2026-10-24）\n\n核心配额优先读取 `themes.json.coreGroupWeights`，按已选 ID 切片；每主题 21 个正权重，原值来源和语义适配见[16A](16A-物品与实际权重对应.md)。新增 60 件原创 GLB 经选择性转换后进入 FBX Resources，旧 `.meta` 保留。`tools/unity/prepare_assets.py` 刷新旧 Cocos 基线时保留 Unity 追加 ID，并按 ID 重排已有权重，避免静默退回 9 类。分层预算、深度来源和单局验证见[第 16 章](16-每主题21类与单局体验.md)。\n'
    write(file,s)
    file=ANALYSIS/'11-推测与待确认.md';s=file.read_text('utf-8')
    s=s.replace('21 类足量自有模型、权重语义映射、原几何与人工完成率','21 类原创模型已接入、105 项原值已映射；仍缺完整原主题、原几何与人工完成率')
    s=s.replace('补足物品种类及权重语义映射；','继续原主题完整候选与权重语义验证；')
    if '21 类资源扩充与可见策略测试已完成' not in s:s += '\n21 类资源扩充与可见策略测试已完成，详见[第 16 章](16-每主题21类与单局体验.md)。其通关样本不消除本章的账号输入、人工难度和手机性能缺口。\n'
    write(file,s)
    file=ANALYSIS/'07-验证结果与后续清单.md';s=file.read_text('utf-8')
    if '## 21 类与单局体验补充' not in s:s += f'\n## 21 类与单局体验补充（2026-10-24）\n\n本轮新增 60 件原创候选并接入实际 Unity；Khronos 零错误/警告，540 件 Jolt 补充检查通过，编辑测试 15/15，算法开发包 {len(algorithm["checks"])} 项、可见策略 {len(experience["checks"])} 项、相机/HUD {len(visual["checks"])} 项通过。完整单局样本 {won}/20；不是人工或原版胜率。[逐局结果与全部边界](16-每主题21类与单局体验.md)、[本轮证据](证据/2026-10-24-21类与单局体验/验证汇总.json)与本章前轮快照分别归档。\n'
    write(file,s)
    write(BATCH/'README.md','''# 五主题原创扩充候选

2026-10-24：60 件原创程序化模型，每主题 12 件，补到 Unity 每主题 21 类。source/ 保留 .blend，models/ 为标准 GLB，icons/ 为 192 与 64 像素 RGBA 图标，qa/ 为回导、闭合、Khronos/Jolt 数值及逐件四视图/小图图集。简单物品低于 1000 面目标，最大 3052 面；均低于 6000 面/256 KiB 上限。

已逐张检查五份图集，修复西兰花共顶点异常边和柿子色彩；没有导入竞品几何。实际 Unity 接入、分层库存、屏幕射线通关与限制详见 ../../../竞品分析/16-每主题21类与单局体验.md。Jolt 补充结果不替代 Unity PhysX 或目标手机验证。
''')
    copy(BATCH/'README.md',DEST/'原创候选/README.md')
    # Freeze the final current chapters as separate evidence, not just mutable links.
    for name in ['README.md','05-Unity接入.md','07-验证结果与后续清单.md','11-推测与待确认.md','15-三消单局核心算法与调优.md','16-每主题21类与单局体验.md','16A-物品与实际权重对应.md']:
        copy(ANALYSIS/name,DEST/'文档'/name)
    runtime=[]
    for theme in themes:
        for id in theme['items']:
            folder=ROOT/'unity/Assets/Resources/Models'/id
            for path in sorted(folder.iterdir()):
                if path.is_file():runtime.append(dict(theme=theme['id'],id=id,path=path.relative_to(ROOT).as_posix(),sha256=sha(path)))
            icon=ROOT/'unity/Assets/Resources/Icons'/f'{id}.png'
            runtime.append(dict(theme=theme['id'],id=id,path=icon.relative_to(ROOT).as_posix(),sha256=sha(icon)))
    write(DEST/'资源/运行资源哈希.json',json.dumps(runtime,ensure_ascii=False,indent=2))
    release=[]
    for path in sorted((ROOT/'unity/Builds/Windows').rglob('*')):
        if path.is_file():release.append(dict(path=path.relative_to(ROOT).as_posix(),bytes=path.stat().st_size,sha256=sha(path)))
    summary=dict(date=datetime.now(timezone.utc).isoformat(),themes=5,kindsPerTheme=21,newOriginalModels=60,quotaBindings=105,
                 confidence=dict(sourceValues='confirmed frozen resource values',semanticMappings='project adaptations',liveAccount='unknown'),
                 algorithmChecks=len(algorithm['checks']),experienceChecks=len(experience['checks']),visualChecks=len(visual['checks']),editTests=15,
                 fullRounds=len(rounds),wins=won,humanWinRate='not measured',competitorWinRate='not measured',
                 sourceSha256=weights['sourceSha256'],release=release)
    write(DEST/'验证汇总.json',json.dumps(summary,ensure_ascii=False,indent=2))
    manifest=[]
    for path in sorted(DEST.rglob('*')):
        if path.is_file() and path.name!='文件校验.json' and '__pycache__' not in path.parts:
            manifest.append(dict(path=path.relative_to(DEST).as_posix(),bytes=path.stat().st_size,sha256=sha(path)))
    write(DEST/'文件校验.json',json.dumps(manifest,ensure_ascii=False,indent=2))
    print(json.dumps(dict(frozen=len(manifest),wins=won,rounds=len(rounds),algorithm=len(algorithm['checks']),experience=len(experience['checks']),visual=len(visual['checks'])),ensure_ascii=False))

if __name__=='__main__':main()
