# B2 三款模型：真实游戏流程 QA

蛋挞鸭、钢杯鸭、数字积木鸭已在 Unity 2022.3.62f3 构建的独立 Windows Player 中完成真实生成、屏幕拾取、托盘、三消与重复进出。桌面配置和 `-gooseMobileProfile` 配置各跑一遍，均通过。此报告不证明微信真机性能、用户造型验收或完整 20 款计划已完成。

- [实际游戏截图](../../source-assets/models/candidates/duck-series-v1/model-review-b2/renders/gameplay-acceptance-overview.png)
- [移动端配置检查](../../source-assets/models/candidates/duck-series-v1/model-review-b2/qa/gameplay/mobile/acceptance.json)
- [桌面配置检查](../../source-assets/models/candidates/duck-series-v1/model-review-b2/qa/gameplay/desktop/acceptance.json)
- [源码与模型哈希证据](../../source-assets/models/candidates/duck-series-v1/model-review-b2/qa/gameplay/evidence.json)

## 实际覆盖

| 检查 | 证据 |
| --- | --- |
| 真实生成 | 每轮 45 件，三款各 15 件；来自实际 `GooseRoundPreparation` 与 `GooseGame` |
| 屏幕拾取 | 三款各 3 次 `PickAtScreenPosition`；射线必须命中自然可见的候选物件 |
| 托盘 | 实际网格进入七槽托盘，中心误差为 0 像素；宽度占槽宽约 76% |
| 三消 | 每款消除 3 件，累计 9 件；每次匹配后槽位清空 |
| 重复进出 | 第二次进入重新生成完整 45 件，托盘为空 |
| 状态 | 退出恢复五主题内存配置、原主题和阶段；故事成绩与每日次数不变 |
| 材质 | 三款均保留一个材质槽，金属光滑度贴图通过实际资源缓存后仍存在 |
| 网络 | 本机 PlayerConnection，禁用组播，监听 127.0.0.1 |

没有强制将埋藏物件设为可见，没有直接调用 `Pick(item, true)`，没有改动三消结果或绕过托盘流程。截图来自运行中的相机与 UI。

## 本轮修正

`GooseAssetCache.MobileMaterials` 原先把 Standard 材质统一转为只支持基础色的 `Goose/ItemMobile`，会丢失钢杯的金属光滑度输入。QA 副本增加 `Goose/DuckMobile` 候选 Shader，使用基础色与 R=金属、A=光滑度图集，以单个 ForwardBase 通道表现柔和明暗与风格化高光；资源缓存保留这一材质。

这是一种风格化近似材质，不是完整 PBR。当前只在独立 QA 工程使用，没有修改正式 `GooseAssetCache`、正式 Shader 或五主题资源。生成器、拾取、物件、托盘和匹配核心文件与创建 QA 时的当前工程快照哈希一致。测试仅在内存中将早餐铺的候选池设为三款鸭子，退出再还原；磁盘上的五主题与关卡 JSON 保持原快照。

## 文件与复现

独立工程为 `work/duck-b2-gameplay-qa`，不是新的正式游戏入口。准备、构建、运行检查与证据收集分别由 `tools/mascots/prepare_duck_b2_gameplay_qa.py`、`DuckB2GameplayBuild.cs`、`DuckB2GameplayAcceptance.cs`、`collect_duck_b2_gameplay_qa.py` 负责。

QA 使用单独的公司名 `DuckB2IsolatedQA` 与 `GooseSave.IsQa` 存档命名空间。复制原 `GoosePlayerNetworkPolicy`，新建 Player 后又运行 `tools/unity/fix-player-network.ps1` 核对本机网络策略；未请求防火墙权限。没有复制或改写竞品原始资源及冻结证据。

## 尚未完成

1. 用户对 B2 母模及前三款真实模型的造型验收。
2. 剩余 17 款、首页动画控制和五主题独立评审入口。
3. 正式项目的候选材质/资源发布、微信导出与真机运行验收。

单场 45 件 QA 的状态恢复不能作为五主题独立评审关已完成的证明；桌面运行的移动端配置也不能作为微信手机帧率证据。
