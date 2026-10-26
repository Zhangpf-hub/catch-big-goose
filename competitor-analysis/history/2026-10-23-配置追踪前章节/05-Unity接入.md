# 05 Unity 接入

## 已落地的代码

| 文件 | 职责 | 依据 |
| --- | --- | --- |
| [GooseGeneration.cs](../unity/Assets/Scripts/GooseGeneration.cs) | 历史补偿选择器、有限库存生成、连续位置权重 | 已确认核心 + 库存／数值适配 |
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
| `visibleDepthMin / Max` | 0.4 / 0.6 | 前沿下方保留的可见深度 |
| `referenceHeight` | 2 | 深度插值的参考高度 |
| `rigidDepthMultiplier` | 0.75 | 物理活跃层与可见层的相对深度 |
| `frontierStep / refreshInterval` | 0.1 / 0.1 秒 | 前沿下移速度与刷新频率 |
| `speedGuard / angularSpeedGuard` | 0.2 / 0.6 | 物件仍明显运动时不托住 |
| `settledDuration` | 0.35 秒 | 低速稳定等待 |
| `hysteresis` | 0.06 | 阈值附近避免显示／物理反复切换 |
| `spawnProtection / disturbanceProtection` | 0.8 / 0.8 秒 | 生成完成和扰动后的物理保护 |
| `positionEdgeWeight` | 0.4 | 对称位置曲线的边缘权重，1 为均匀 |
| `maxDynamicBodies` | 80 | 诊断软预算，未强制冻结运动件 |

如果需要某主题调整投放先后，在主题数据中添加与 `items` 顺序一致的 `itemWeights`。它只影响顺序，不修改各类型总库存；未配置时等权。零权重不会永久丢弃该类库存，待正权重库存耗尽后仍会投放。修改主题生成脚本时应同步保留该字段，避免重新导入数据时丢失。

配置变化需要重新进入运行流程并重建玩家包才会反映到对应构建。无需配置竞品路径，也不依赖本机缓存；正式 Unity 资源中没有引用提取的竞品模型。

## 验收入口

在根目录使用 PowerShell：

```powershell
node tools/competitor/validate_recovered.mjs
node tools/competitor/probe_original_algorithms.mjs
./tools/competitor/run_policy_tests.ps1
./tools/unity/open-project.ps1 -Tests
./tools/competitor/run_unity_algorithm_tests.ps1
```

前两步依赖 `work/competitor-tools/wabt` 与已提取方法；后两种 Unity 批处理操作前，保存并关闭同一工程的编辑器，避免工程锁冲突。测试脚本使用本机已配置的 2022.3.62f3 路径，换机器需调整路径。已有独立算法 QA 包时可用 `-SkipBuild`，但它只能验证旧包；要验证源码修改必须重新构建。

算法开发包位于 `unity/Builds/AlgorithmQA/`，不覆盖另一套 `WindowsQA` 全流程包。记录输出到 `work/competitor-algorithm-tests/`，本轮交付快照已复制到 [证据目录](证据/2026-10-22-生成与深度/验证汇总.json)。不能以算法验收替代视频奖励、UI 手感、手机性能或微信发布验收。
