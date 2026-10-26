# 05 Unity 接入

更新：2026-10-24。当前默认使用 [core-rounds.json](../unity/Assets/Resources/Data/core-rounds.json) 的分层核心档位，详见[第 15 章](15-三消单局核心算法与调优.md)。下面的数学／深度能力仍生效；原 48／54／81 件只保留为 `enabled=false` 时的旧回归档，不是当前默认体验。

新增 [GooseLevelPolicy.cs](../unity/Assets/Scripts/GooseLevelPolicy.cs)：百分桶、AB 列表及热更解析；[level-tuning.json](../unity/Assets/Resources/Data/level-tuning.json) 默认无覆盖。BeginRound 先创建核心档，再应用显式本地覆盖，生成每层完整三件组。源类型数受自有模型数限制，目标物单列，热更改变类型数时不联动改变组预算。

核心档默认 15／60／300 件，分批间隔按 `min(2*3/count,0.03)`，不加入单只奖励金鹅或冰封。新增独立暂存区、点击取回、每种基础工具一次上限，入门 0 秒按不限时处理。核心档不使用自动解冻、随机赠礼和额外无解判负。旧视频／奖励 QA 主动关闭核心档，新核心玩法用 GooseAlgorithmAcceptance 单独验证。

## 已落地的代码

| 文件 | 职责 | 依据 |
| --- | --- | --- |
| [GooseGeneration.cs](../unity/Assets/Scripts/GooseGeneration.cs) | 历史补偿选择器、三件组权重配额、有限库存生成、连续位置权重 | 已确认核心 + 库存／数值适配 |
| [GooseDepthPolicy.cs](../unity/Assets/Scripts/GooseDepthPolicy.cs) | 配置校验、阈值、前沿下降、静止条件 | 已确认公式 + 工程保护 |
| [GoosePileDepth.cs](../unity/Assets/Scripts/GoosePileDepth.cs) | 定时刷新、遮挡检查、隐藏、深层托住与唤醒 | 已确认显示／物理分离 + 工程适配 |
| [GooseItem.cs](../unity/Assets/Scripts/GooseItem.cs) | 单物件渲染与刚体状态、冰封可见性 | 自有生命周期接入 |
| [GooseRules.cs](../unity/Assets/Scripts/GooseRules.cs) | 可选 itemWeights、完整三件库存、旧洗牌回退 | 自有规则保留 |
| [GooseGame.cs](../unity/Assets/Scripts/GooseGame.cs) | 加载配置、生成、点选、打乱、返回与清理入口 | 自有玩法接入 |
| [GooseDepthIntegrationTests.cs](../unity/Assets/Tests/Editor/GooseDepthIntegrationTests.cs) | 实际 Renderer / Collider / Rigidbody 状态测试 | Unity 编辑模式验证 |
| [GooseAlgorithmAcceptance.cs](../unity/Assets/Scripts/GooseAlgorithmAcceptance.cs) | 五主题与受控支撑场景的实际开发包验收 | 仅编辑器／开发构建编入 |

## 运行流程

`Awake` 创建默认配置，再读取 `Resources/Data/pile-algorithms` 覆盖并校验；创建深度管理器。开始关卡时用固定种子生成有限队列，按已有分帧逻辑投放，出场动画结束后才标记 `DepthReady`。所有物件生成完成后开始保护计时。

深度刷新按 0.1 秒间隔执行，暂停、未开始或未投放完成时不执行。计算前沿和两种阈值后，分别决定渲染和刚体状态。普通手动点选拒绝隐藏件；取走场内物件后唤醒剩余深层体。打乱时全部恢复显示和运动，再等待稳定。关卡清理重置前沿、计数和计时。

冻结刚体前清零速度并采用兼容 kinematic 的碰撞检测方式；唤醒时恢复动态连续检测。碰撞体和 detectCollisions 保留。冰封视觉遵守同一可见性状态，避免本体隐藏但冰壳留在场上。

## 配置与调整

配置文件：[pile-algorithms.json](../unity/Assets/Resources/Data/pile-algorithms.json)。当前 `weightedGeneration` 与 `depthManagement` 均为 `true`。

| 配置 | 当前值 | 调整含义 |
| --- | --- | --- |
| `weightedGeneration` | true | 启用加权队列和格点内权重抖动；false 恢复原均匀洗牌和抖动 |
| `depthManagement` | true | 启用显示和刚体分层；false 释放深层体并显示全部 |
| `visibleDepthMin / Max` | 0.4 / 0.5 | 场景序列化基线按项目尺度映射 |
| `referenceHeight` | 2.1 | 深度插值的参考高度 |
| `rigidDepthMultiplier` | 0.5 | 物理活跃层与可见层的相对深度 |
| `frontierStep / refreshInterval` | 0.05 / 0.1 秒 | 前沿下移速度与刷新频率 |
| `speedGuard / angularSpeedGuard` | 0.2 / 0.6 | 物件仍明显运动时不托住 |
| `settledDuration` | 0.35 秒 | 低速稳定等待 |
| `hysteresis` | 0.06 | 阈值附近避免显示／物理反复切换 |
| `spawnProtection / disturbanceProtection` | 0.8 / 0.8 秒 | 生成完成和扰动后的物理保护 |
| `positionEdgeWeight` | 0.4 | 对称位置曲线的边缘权重，1 为均匀 |
| `maxDynamicBodies` | 70 | 诊断软预算，未强制冻结运动件 |

主题数据的 `itemWeights` 与 `items` 同序，只影响投放顺序；另一个 `groupWeights` 调整完整三件组的数量配额。后者未配置时使用等量名义权重；独立组预算不能整除类型数时，最后一类接收取整余数。前 N−1 项四舍六入五成双，零配额类型不投放。非等权旧回归例 `[1,2,3,4]` 的 16 组分为 `[2,3,5,6]`，即 `[6,9,15,18]` 件。它是接入测试，不是当前核心入门档或竞品类型映射。

顺序权重为 0 不会删除已存在的库存，正权重库存耗尽后仍会投放。修改主题生成脚本时需保留这两个可选字段，避免导入时丢失。实际竞品权重已归档，但未把没有对应关系的烧烤权重复制到自有五主题。

配置变化需要重新进入运行流程并重建玩家包才会反映到对应构建。无需配置竞品路径，也不依赖本机缓存；正式 Unity 资源中没有引用提取的竞品模型。

## 验收入口

在根目录使用 PowerShell：

```powershell
node tools/competitor/validate_recovered.mjs work/competitor-config-trace/methods
node tools/competitor/probe_original_algorithms.mjs work/competitor-config-trace/methods work/competitor-20261023-tests
node tools/competitor/probe_mode_policies.mjs
python tools/competitor/create_quota_fixtures.py
./tools/competitor/run_policy_tests.ps1 -OutputDirectory work/competitor-20261023-tests
./tools/unity/open-project.ps1 -Tests
./tools/competitor/run_unity_algorithm_tests.ps1 -OutputDirectory work/competitor-20261023-tests
```

前两步依赖 `work/competitor-tools/wabt` 与已提取方法；后两种 Unity 批处理操作前，保存并关闭同一工程的编辑器，避免工程锁冲突。测试脚本使用本机已配置的 2022.3.62f3 路径，换机器需调整路径。已有独立算法 QA 包时可用 `-SkipBuild`，但它只能验证旧包；要验证源码修改必须重新构建。

算法开发包位于 `unity/Builds/AlgorithmQA/`，不覆盖另一套 `WindowsQA` 全流程包。上列命令记录输出到 `work/competitor-20261023-tests/`，本轮快照已复制到 [证据目录](证据/2026-10-23-配置与模式/验证汇总.json)。构建脚本会保存运行源码并检查构建期间是否变化。不能以算法验收替代视频奖励、UI 手感、手机性能或微信发布验收。

## 五主题 21 类接入补充（2026-10-24）

核心配额优先读取 `themes.json.coreGroupWeights`，按已选 ID 切片；每主题 21 个正权重，原值来源和语义适配见[16A](16A-物品与实际权重对应.md)。新增 60 件原创 GLB 经选择性转换后进入 FBX Resources，旧 `.meta` 保留。`tools/unity/prepare_assets.py` 刷新旧 Cocos 基线时保留 Unity 追加 ID，并按 ID 重排已有权重，避免静默退回 9 类。分层预算、深度来源和单局验证见[第 16 章](16-每主题21类与单局体验.md)。

## 微信进局性能补充（2026-10-24）

已将资源分帧准备、离线碰撞网格、按主题实例池、HUD/深度分配优化及独立移动性能档接入。竞品池化/预载原方法、前后 CPU 计时、18 项编辑测试、132 项算法检查、移动档 20 局样本及实际微信新包边界见[第 17 章](17-微信进局性能与竞品优化.md)。桌面代理不等于手机性能；首局准备总时长并未缩短。
