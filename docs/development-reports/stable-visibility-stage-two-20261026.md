# 下层显隐稳定与真实转关修复记录

日期：2026-10-26。`20261026-VISIBILITY2-SHAKE11` 已完成全新单一base完整验证，最终332项门禁通过、errors／missing为空；官方CLI于北京时间21:52上传开发版 **1.0.10** 成功。新版136个桌面文件已完整复制校验、未启动，旧窗口保留。体验版选择尚未确认、未公开发布；后台隐私、真实微信硬件回调及iPhone持续性能仍未验收，Git状态见[代码提交及远程核验回执](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/git-push-receipt.json)。旧失败与全部原始证据保留。

依据[计划与审批](../development-plans/stable-visibility-stage-two-20261026.md)及[竞品证据核对](../../competitor-analysis/stable-visibility-stage-two-20261026.md)，优先验证用户所述下层闪烁和真实首关自动进入第二关链，保持未激活下层静止与原渲染/物理预算。

## 未修改生产行为的基线

独立QA在Unity 2022.3.62f3构建，4072项输入与复制快照逐项一致，完整QA播放器另存本轮work，不覆盖SHAKE7既有交付。基线只新增采证脚本，不改生产代码。

| 场景 | 实测 | 证据 |
| --- | --- | --- |
| 真实300件、冻结原几何30秒 | 几何epoch为0，294件初始下层全部有至少两次实际重判；28件反复显隐，最大查询256，下层始终kinematic且无重力 | [冻结基线](../../work/stable-visibility-stage-two-20261026/baseline/visibility-frozen-theme-0-baseline/visibility-stability.json) |
| 真实300件、自然物理30秒 | 几何epoch为0，294件覆盖充分；29件反复显隐 | [自然基线](../../work/stable-visibility-stage-two-20261026/baseline/visibility-natural-theme-0-baseline/visibility-stability.json) |
| 五主题真实清15件→自动300件→首个合成摇动 | 均通过生产pointer down/up与正常入槽；未调用InstantPicks或强制胜利，原目标空中抛高/翻面、屏幕弧线、净XZ及下层约束通过 | [早餐](../../work/stable-visibility-stage-two-20261026/baseline/transition-sensor-theme-0-delay-0-baseline/stage-two-stability.json)、[烧烤](../../work/stable-visibility-stage-two-20261026/baseline/transition-sensor-theme-1-delay-0-baseline/stage-two-stability.json)、[蔬菜](../../work/stable-visibility-stage-two-20261026/baseline/transition-sensor-theme-2-delay-0-baseline/stage-two-stability.json)、[玩具](../../work/stable-visibility-stage-two-20261026/baseline/transition-sensor-theme-3-delay-0-baseline/stage-two-stability.json)、[杂货](../../work/stable-visibility-stage-two-20261026/baseline/transition-sensor-theme-4-delay-0-baseline/stage-two-stability.json) |
| 桌面配置、真实转关后手动Request | 正常60FPS目标配置的手动控制器入口通过；不是OS空格按键或实机传感器证明 | [桌面入口](../../work/stable-visibility-stage-two-20261026/baseline/transition-manual-theme-0-delay-0-desktop-baseline/stage-two-stability.json) |

显隐根因已经证实：原ProbeCovered把其他物件当前DepthVisible作为遮挡依据，再据此修改本物件DepthVisible，形成分帧缓存反馈；这不是物理抖动，也不是只看到开场一次变化。例蒸笼在相同几何epoch中隐藏→显示→再隐藏。旧95行矩阵测过真正第二关，但仅末端计数和短时帧采样没有覆盖这类长时反馈。

第二关“不能摇”在基线源码的上述六条路径尚未复现，不能因此宣布用户反馈错误或将控制器改动作为已证实修复。电脑存在旧目录游戏进程，但用户实际测试入口尚未确认；微信原始传感器回调链也未由本轮原生合成数据证明。

## 独立画面参考基线

保留SHAKE7生产源码，仅在隔离构建加入开发用offscreen oracle，源差异限定为QA与辅助类，见[生产来源清单](../../work/stable-visibility-stage-two-20261026/baseline-oracle/baseline-production-provenance.json)。同一帧、相机、原材质、分辨率、MSAA及颜色空间下，对比实际剔除画面与只对offscreen参考临时显示库存物件的完整画面。游戏逻辑DepthVisible、材质与物理状态不变，全部renderer状态立即恢复。

事先固定门槛：任一RGB通道差超过8/255的像素比例不超过0.25%，平均归一RGB误差不超过0.001；先测相同flags的自对照噪声，不从新版结果反推放宽阈值。

旧版基线为5.3935%差异像素、平均误差0.007453，自对照差异像素为0、平均误差约0.000000219，原renderer状态恢复成功。完整参考375个renderer、正常剔除71个，说明需要保留真实轮廓，而非只消除计时闪烁。见[指标](../../work/stable-visibility-stage-two-20261026/baseline-oracle/visibility-frozen-theme-0-baseline-oracle/baseline-reference.json)、[实际画面](../../work/stable-visibility-stage-two-20261026/baseline-oracle/visibility-frozen-theme-0-baseline-oracle/baseline-actual.png)、[完整参考](../../work/stable-visibility-stage-two-20261026/baseline-oracle/visibility-frozen-theme-0-baseline-oracle/baseline-full-reference.png)。该采图不作为性能结果。

## 早期批准实施范围

独立Agent批准固定相机/几何epoch内按前后rank分类，遮挡只使用同epoch已确认可见的前方计划态；及时发布显示，新隐藏仅在完整且有效epoch末统一提交。静止完成后不周期轮询；实际几何、相机、移除和保护资格变化再置脏，进行中的cursor不因持续变动反复从头开始。保留256查询预算、物理17点曝光、可见侧轮廓、下层held/gravity与原迟滞。

新QA将用两次真实相机变化及恢复原位后的完整分类证明覆盖，最后固定原相机观察至少12秒、默认30秒零重复显隐，并接受独立像素参考门槛。旧按计时器两次重判的失败材料保留，不能要求新正确静态缓存继续轮询来迁就旧测试。第二关控制器仍保持原生产行为，等待实际失败证据。


## 中间验证：稳定性修正与画面误剔除分别记录

fixed-r1 实际固定几何300件验证完成两次相机dirty并恢复，原相机最终窗口零反复显隐，物理下层约束正常；但原全投影画面参考5.3935%差异超限，整次验收保持失败。[fixed-r1完整记录](../../work/stable-visibility-stage-two-20261026/fixed-r1/visibility-frozen-theme-0-fixed-r1/visibility-stability.json)。

隔离阴影控制继续保留原生产 HardOnly/Medium/52米和 WarmSun参数，另一次同帧实际/全显示pair全部禁影，差异仍4.3611%、平均RGB误差0.006883，自对照0差异像素，全部状态恢复成功。因此不是单纯投影变化，不能用关闭阴影或扩大阈值通过。[阴影控制原数据](../../work/stable-visibility-stage-two-20261026/fixed-shadow-control/visibility-frozen-theme-0-shadow-control/final-shadow-control-reference.json)。

独立审批后追加透明材质遮挡资格修正及保持生产投影资格集合的独立彩色几何参考。原全投影与禁影结果不被新判据改写。该新参考只额外显示本depth隐藏的库存彩色renderer，不打开作者forceRenderingOff或可见物件的独立禁用效果；保持原灯、阴影质量和原投影资格flags，新增颜色renderer不投新影。caster身份是enabled与casting flags资格集合，不代表实际GPU所有ShadowCaster pass/距离裁剪清单。


## 透明遮挡修正的中间结果（仍未放行）

独立Agent复核了资格缓存与生产射线公共入口。新增3个真实材质/相机/物理覆盖测试，完整编辑器69项：首次继承旧runner的 `-nographics` 时，真实红色透出取图为0，保留[Null设备失败](../../work/stable-visibility-stage-two-20261026/fixed-opaque/editmode.xml)；同一4076项输入未改生产或断言，只将图形编辑测试使用实际graphics device，再次[69/69通过](../../work/stable-visibility-stage-two-20261026/fixed-opaque/editmode-graphics.xml)。以后该runner图形编辑测试不使用nographics，原生构建仍可headless。

| 隔离构建 | 零闪烁 | 正常/完整renderer | 保持生产投影资格的彩色几何差异 | 状态 |
| --- | --- | --- | --- | --- |
| 旧DAG+新参考控制 | 是 | 71/375 | 4.3590%，平均0.006770 | 失败保留 |
| 透明资格修正opaque-r1 | 是 | 87/375 | 2.2060%，平均0.003542 | 失败保留，未达0.25%/0.001门槛 |

[opaque-r1完整报告](../../work/stable-visibility-stage-two-20261026/fixed-opaque/visibility-frozen-theme-0-opaque-r1/visibility-stability.json)和[逐件颜色恢复诊断](../../work/stable-visibility-stage-two-20261026/fixed-opaque/visibility-frozen-theme-0-opaque-r1/hidden-color-contributors.json)显示：透明修正减少约半数漏画，仍有豆腐脑564像素、玉米280像素、花卷269像素等真实彩色边缘被隐藏。该诊断只逐件临时恢复被depth隐藏的原材质颜色、不增加投影、不改物理；贡献不可相加，也不是通过判据。它证明不能把9个72%内部凸包采样点的“覆盖”当作全部外观轮廓都被挡住。

当时下一步仅批准隔离保守边缘采样原型，并量化五主题实际保留数量；当时主源未采用该原型。后续取舍与最终候选见下节，未以全部渲染通过画面门槛。

## 方案取舍：较小包络方案进入 main，复杂 mesh 原型仅留证据

期间独立构建尝试真实渲染 mesh BVH、最近三角面查询、外部 sidecar 返场与混合遮挡方案。它们不是最终生产实现，候选源码、图形夹具及失败报告只留在本轮 work，未合入 main 或最终交付快照。

真实 mesh 图形夹具发现并证明了 Unity MeshRenderer 对负缩放的绕向补偿，修正后[mesh-r3编辑器79项](../../work/stable-visibility-stage-two-20261026/mesh-prototype-r3/editmode.xml)通过，但烧烤、乡村的颜色几何差异仍约0.4992%／0.4966%，超过原0.25%门槛。后续 nearest／25点隔离分支[86项编辑器测试](../../work/stable-visibility-stage-two-20261026/mesh-prototype-r4/editmode.xml)通过，五主题画面参考反而全部超限，差异像素约2.16%–3.29%。这些通过的模块测试不能抵消真实画面的失败；原型未被“测试数量更多”作为采用依据。[mesh-r3烧烤](../../work/stable-visibility-stage-two-20261026/mesh-prototype-r3/visibility-frozen-theme-1-mesh-r3/visibility-stability.json)、[mesh-r3乡村](../../work/stable-visibility-stage-two-20261026/mesh-prototype-r3/visibility-frozen-theme-2-mesh-r3/visibility-stability.json)、[nearest-r4首主题](../../work/stable-visibility-stage-two-20261026/mesh-prototype-r4/visibility-frozen-theme-0-mesh-r4/visibility-stability.json)保持原失败状态；其他 nearest／hybrid 中间材料也继续保存在 work。

最终取当前 main 中较小的实现：保持同 epoch 前后有向依赖计划，物理曝光和视觉显隐分开；目标使用真实 authored visual bounds 的完整相机投影包络，固定5×5共25个点。遮挡须来自已确认的前方不透明物件，并再次验证其物理代理95%内部，而非用整块凸包外扩边缘消掉下面的彩色轮廓。每件最多64次视觉查询，完整刷新仍最多256次，预算不足保守显示，未恢复全部库存渲染或深层动态物理。该方案不包含 BVH、nearest 或新磁盘 mesh 缓存系统。

最终判断仍使用已批准的“保持生产 caster 资格集合”的原色几何参考：8/255、0.25%与平均0.001均不变。原 raw-lit／no-shadow 对照的独立 pass/fail、自噪声和状态恢复继续保留，不要求它们全部通过来替代该已批准实验，也不抹除它们的失败。

## 已复现并修正的传感器异步 Stop 竞争

本轮随后对实际 `GooseWeChatPlatform` 生命周期方法块进行原样编译，使用可控制异步完成顺序的 SDK mock 重放，而非替换生产算法。在[补丁前记录](../../work/stable-visibility-stage-two-20261026/sensor-race-before/sensor-lifecycle.json)中，五项通过、两项失败：暂停／恢复／再暂停会在前一次 Stop 未完成时重复 Stop；旧 Stop 的迟到 completion 又可能释放新 Stop 的等待状态。此类异步停止会干扰后续监听启动，与游戏内颠锅幅度是不同问题。

main 的最小修正合并进行中的 Stop，并为 completion 增加 Stop generation 校验；仍注销旧 delegate、忽略退役启动／回调，并保留有界失败重试。没有改变加速度门槛、物品物理、原始表层集合或隐私授权条件。[修正后七项记录](../../work/stable-visibility-stage-two-20261026/sensor-race-fixed/sensor-lifecycle.json)全部通过，绑定实际平台源 SHA-256 `9ecab9be1175189faeaf7962b66f4dde70d0f88c197d81d5812fca3a4caa598e`。测试对象是实际源方法与 SDK 时序模型，不是微信硬件回调或 iPhone 实测；它证实并修复了一个真实代码竞争，仍不能断言它就是用户当前入口的唯一原因。

## 旧 final-sensor-delivery 同源候选与当时验证进度（保留）

最终构建源来自当前 main，独立快照位于本轮 `delivery-build-workspace`；原生证明使用 `native-proof-workspace`，不复用上述 BVH 原型。交付证据集中在 [final-sensor-delivery](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery)。[4078项源清单](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/source-inputs.json)、[原生构建输入](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/native-build-inputs.json)与[原生复制对照](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/native-copy-comparison.json)记录同源复制零差异；原型79／86项不计入最终结果，最终[编辑器71项](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/editmode.xml)通过。

本节写入时可核实的进度如下，其余仍在跑的报告不提前记为成功，也不把进行中保存的 `completed=false` 当成已完成失败：

| 本轮最终候选检查 | 当前可核实结果 |
| --- | --- |
| 完整原生矩阵 | [95行矩阵](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/regression-matrix-final/surface-acceptance.json)已完成并通过，errors为空 |
| 五主题固定几何画面 | [早餐](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/visibility-frozen-theme-0-final/visibility-stability.json)、[烧烤](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/visibility-frozen-theme-1-final/visibility-stability.json)、[乡村](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/visibility-frozen-theme-2-final/visibility-stability.json)、[玩具](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/visibility-frozen-theme-3-final/visibility-stability.json)、[杂货](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/visibility-frozen-theme-4-final/visibility-stability.json)均完成通过，approved颜色差异像素分别约0%、0.0991%、0.0168%、0.0084%、0.0126% |
| 其余原生证明 | 五主题自然物理显隐、五主题真实15→300首摇、五主题真实拾取／颠锅显露，以及 fallback、interrupt、clip、toss、交互和选择等辅助回归批次正在继续，待统一 collector 汇总 |
| 微信本地包体 | [包体审计](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/wechat-package-audit.json)通过；本地文件27,340,850字节 |
| 官方 CLI preview | 已完成，平台编译后27,772,822字节；[编译信息](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/wechat-preview-info.json)、[本轮预览码](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/wechat-preview.png)保留。preview不等于upload或设体验版 |
| 本轮开发版本 upload | 拟用1.0.10，因下述玩具转关违规暂缓；当前尚未执行，无成功回执 |

原自然／冻结视觉观察分别遵守获批合同：自然场景记录微漂，不要求初末回到同一 pose；冻结场景以独立 Script simulation／无插值保持精确几何。二者继续要求原报告的覆盖充分、最终稳定窗口与approved颜色门槛，不能为通过更改 raw 结果。

最终完整文件 manifest、发布目录一致性、upload回执和 commit／origin 推送结果由主 Agent 在统一验收完成后补齐。微信后台加速度用途声明是否在正确 AppID 生效、用户真实授权／回调、iPhone 15 Pro颠锅和持续性能仍未通过；当前的 mock、Native、WebGL编译和preview均不能替代这些边界。

## 新阻断：玩具真实转关首摇的下层状态采样

[final-sensor-delivery 玩具 sensor 首摇](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/transition-sensor-theme-3-delay-0-final/stage-two-stability.json)已完成，但整体 `passed=false`，11项检查通过、1项失败。接受集合及下一物理帧集合均为原20件，覆盖1.0；20/20实际受影响、移动、翻转及换邻，受控颠锅完成，floor／boundary违规均为0。然而 `lowerViolations=61`，因此不能放行。61是跨帧累计的违规采样计数，不能据此写成61个不同下层物件。

当时尚不能判定是生产误激活、合法露出后的状态阶段差别，还是QA采样时序造成计数；不能从“动画效果明显”反推下层安全，也不能先把它归咎测试。独立 reviewer 随后批准仅在QA中记录前8个违规样本的原始身份、位姿、物理／显隐／激活状态和采样阶段；原失败报告保持完整，后续确证及新的生产画面阻断见下节。

主线程继续以新 run 标识 `remaining-final` 收集剩余 theme4、desktop manual、Reveal及辅助回归，逐项按实际完成结果记录；这些结果不覆盖或抹除上述失败。1.0.10暂不上传，待该阻断有明确证据并完成必要复验后，再由主 Agent 更新交付状态。

## QA时点确证、稀疏探针修正与独立新画面阻断

真实[v2原始失败](../../work/stable-visibility-stage-two-20261026/lower-violation-diagnostic-v2/transition-sensor-theme-3-delay-0p016-varied-start-witness/stage-two-stability.json)记录了同一drawingboard `-12578`、frame333的两个时点：Fixed11.2在物理模拟前，原pose未动、锁全关闭，刷新后的曝光缓存与生产17点／独立5点都为真，held已合法转为dynamic；同帧EOF11.20945已移动约0.0021／转2.02度，两个即时曝光probe均为假，旧QA据此误记下层违规。原始report仍是 `passed=false/lowerViolations=1`。[独立派生确证](../../work/stable-visibility-stage-two-20261026/lower-violation-diagnostic-v2/v2-evidence.json)绑定4078项完整源输入、209个实际播放器文件及实际采证方法哈希，只证明一次明确时点缺陷，不声称无身份的旧toy61／BBQ1每个计数均由同一原因造成。

Reviewer批准仅两个开发QA源改用Fixed物理前的新鲜合法晋升证据，删除旧EOF豁免，不改变生产激活逻辑。实际C#共享predicate的[R3独立夹具](../../work/stable-visibility-stage-two-20261026/promotion-contract-fixture-r3/promotion-contract-fixture.json)已执行1个真实positive和29个锁／曝光／新鲜度／旧pose／原选择身份等negative，30/30通过，绑定实际源与提取脚本。R2 Stage烧烤仍报171次下层违规，是新增独立5点稀疏oracle漏掉外环真实曝光；当时生产17点、fresh、band、锁和原pose条件合法。Reviewer因此批准R3仅将Stage独立检查改为覆盖原17点的25格，与Reveal一致，共享pure helper不变。[R2原始Stage失败](../../work/stable-visibility-stage-two-20261026/qa-promotion-timing/transition-sensor-theme-1-delay-0-revised-final/stage-two-stability.json)继续保留，不混入最终新报告。

但正确的QA时点不能消除真实生产漏画。[R2烧烤真实拾取／颠锅Reveal](../../work/stable-visibility-stage-two-20261026/qa-promotion-timing/reveal-theme-1-revised-final/reveal-stability.json)的lower／floor／boundary／补选身份违规均为0，Fixed合法晋升计数21次评估、21次接受；实际保存前8项witness，其余13项仅保留计数。唯一失败为 `original color geometry reference after-toss`：

| 阶段 | 差异像素 | 差异比例 | 平均RGB误差 | 原门槛结论 |
| --- | --- | --- | --- | --- |
| initial | 189 | 0.099103% | 0.000111712 | 通过 |
| after-pick-1 | 170 | 0.089141% | 0.000094185 | 通过 |
| after-toss | 663 | 0.347648% | 0.000545152 | 比例超过0.25%，失败 |

该 after-toss 颜色失败是真实生产问题，不能归入QA时点缺陷、不能supersede，也不能以平均误差低于0.001代替同时必须满足的像素比例。旧 raw、R2所有报告及原 .95 WebGL／release均保留；当前不再允许靠QA-only修订复用旧发布来交付1.0.10。

当时审批仅允许在work隔离一次 .95→.90内部代理验证试验，25点完整包络、DAG、256全刷新预算、不透明资格、全部画面／物理门槛均不变。后续pilot通过并获正式采用后，已建立下述新BuildId及clean新base；旧base已通过检查不冒称新生产同源通过。

## .90 pilot通过与新主源采用

[烧烤真实pick+toss隔离复验](../../work/stable-visibility-stage-two-20261026/visual-proxy-candidate-r1/reveal-theme-1-interior-090-reveal-output-fixed/reveal-stability.json)已完成通过，initial／after-pick／after-toss的approved颜色差异像素分别11／12／5，约0.005768%／0.006292%／0.002622%，均在原门槛内。五主题固定几何[早餐](../../work/stable-visibility-stage-two-20261026/visual-proxy-candidate-r1/visibility-frozen-theme-0-interior-090-static/visibility-stability.json)、[烧烤](../../work/stable-visibility-stage-two-20261026/visual-proxy-candidate-r1/visibility-frozen-theme-1-interior-090-static/visibility-stability.json)、[乡村](../../work/stable-visibility-stage-two-20261026/visual-proxy-candidate-r1/visibility-frozen-theme-2-interior-090-static/visibility-stability.json)、[玩具](../../work/stable-visibility-stage-two-20261026/visual-proxy-candidate-r1/visibility-frozen-theme-3-interior-090-static/visibility-stability.json)、[杂货](../../work/stable-visibility-stage-two-20261026/visual-proxy-candidate-r1/visibility-frozen-theme-4-interior-090-static/visibility-stability.json)也全部通过，颜色差异像素为0／11／32／0／6。

成本没有省略：烧烤三个阶段实际可见217／218／220件、renderer233／234／236，仍非全部300件渲染；最大查询246／249／249，不超过原256。记录的收敛时间为5.56／10.11／9.74秒，各自另完成12秒稳定窗口。这些含独立探针、取图及贡献诊断的QA记录不作为手机FPS或纯生产耗时测量，也不能把“像素通过”描述成没有可见数量成本。

第一次pilot发生[目录输出异常日志](../../work/stable-visibility-stage-two-20261026/visual-proxy-candidate-r1/reveal-theme-1-interior-090-reveal/player.log)：写入 `initial-contributors/hidden-color-contributors.json` 时 `DirectoryNotFoundException`，对应原报告未完成，不能算通过。原日志及[infrastructure-stop](../../work/stable-visibility-stage-two-20261026/visual-proxy-candidate-r1/reveal-theme-1-interior-090-reveal/infrastructure-stop.json)保留；只补QA输出目录创建后使用新的 `reveal-output-fixed` 目录重跑，没有覆盖旧报告或放宽断言。

reviewer正式批准主源窗口后采用 .90，仍是较小DAG＋25完整包络／不透明代理内部方案，不包含BVH／nearest／hybrid。当前实际源绑定为：

| 文件／身份 | SHA-256 |
| --- | --- |
| GoosePileDepth.cs，interior=.90 | `b4490b794ec00c1c3867dd76dd52490b257132ef073f99a857035bcdb500e20c` |
| GooseRuntimePerformance.cs，BuildId=`20261026-VISIBILITY2-SHAKE10` | `1c3da20faf5e6cfbce06a72dd4c7382878e139cb163a251c7d7b0653fb5e6a13` |
| StageTwo QA，完整25格严格物理前witness | `21fdc408460bffdaeb4997d7c430e8b9827fa0a6ad1829bf1e08cb7844b4733b` |
| Reveal QA，成本／贡献记录与输出目录创建 | `c9795d77528fa3a4cbfb90e80963ab67a55f5ea1c988adbf908c11d3ad510956` |

## final-visibility2-delivery 同源验证（Source10历史阶段）

新证据只收 [final-visibility2-delivery](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery)。[source-inputs](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/source-inputs.json)与[native-build-inputs](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/native-build-inputs.json)均为4078项，逐文件无差异；[新Editor71/71](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/editmode.xml)实际通过。[新sensor生命周期7项](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/sensor-lifecycle/sensor-lifecycle.json)通过，平台适配实际源仍为9ecab9be…；[新predicate夹具30/30](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/promotion-contract-fixture.json)通过并绑定新Reveal c9795d…完整源，不挪用R2/R3旧二进制。

本节首次汇总时，三条原生批次的实际进度为：

| 批次 | 本次只读进度 |
| --- | --- |
| [新矩阵](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/regression-matrix-full-final/surface-acceptance.json) | 已保存19/95行、errors=0，尚未completed，不写整套通过 |
| 10组显隐 | 新早餐[natural](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/visibility-natural-theme-0-full-final/visibility-stability.json)与[frozen](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/visibility-frozen-theme-0-full-final/visibility-stability.json)均完成通过；其余主题批次继续 |
| 五主题Reveal | [新早餐](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/reveal-theme-0-full-final/reveal-stability.json)三阶段完成通过；烧烤仍在initial阶段且无error，其余继续 |

该Source10历史阶段当时仍须按新base完整采集五主题真实转关、toss／interrupt／clip／interaction／selection，不能由旧base或QA-revision复用路径抵扣。新WebGL构建同步进行，尚不记成功；旧preview只保留历史。主 Agent 后续再补统一collector、全文件发布校验、upload和git回执。当前不提前上传1.0.10，不提前声称iPhone实际传感器、后台隐私声明或持续帧率通过。


## 新真实阻断：单表层倾斜书无法按原姿态安全落位

[final-visibility2-delivery矩阵](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/regression-matrix-full-final/surface-acceptance.json)现已完整95行、2996项检查，但 `passed=false`，三个错误均对应玩具 `button/18` 的实际完成、受控颠锅完成及可见效果。原世界该时刻只有一个表层目标 `ref_gtstickerbook/-64870`，lower／floor／boundary未因此获得豁免。

[原始播放器日志](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/regression-matrix-full-final/player.log)第43529及43541行记录真实9点凸包、原quat `(0.73324,0.56618,0.35471,0.12642)`、109.08°倾角，以及五点LP底值 `[-0.3112469,-0.2287812,-0.3922431,-0.2363683,-0.3844694]`。底面跨度0.1634619大于原支撑可行界0.0996，仅调整高度无法使原姿态的五点同时落在允许支撑间隙内；最终 `shake_single_no_safe_neighbour/single_unstable_com_support` 是真实安全规划失败，不能归QA或supersede。1.0.10继续未上传。

Reviewer批准的最小隔离候选只为单目标controlled toss增加备用 `endRotation`：原姿态无安全邻位时，另试更直立落姿，按新姿态重新计算真实形状与五点支撑。原取消姿态独立保存；多目标、收费重排、下层状态、原目标身份及全部安全／净位移／期限门槛不变。候选Shuffle SHA-256 `0401a3e505248273b0a419cb6c493f6d983a43aa90536aa3380c79fbedae76c6` 仅在work，写入本节时**主源生产Shuffle尚未采用**。

## 单目标备用落姿候选：实证范围与成本

[候选R2专门报告](../../work/stable-visibility-stage-two-20261026/single-upright-candidate-r2/regression-single-rotation-theme-3-settled-book/surface-acceptance.json)已completed／passed，四case、66checks、errors为空。它使用未替换的真实 `ref_gtstickerbook` 9点凸包及上述原quat；初始普通gravity／constraintsNone，在开始前Sleep仅为可重复受控初姿态，不声称该高倾角已自然平衡。夹具实际底面跨度0.1627316，同样证明原姿态支撑不可行。

| case | 已证明结果与边界 |
| --- | --- |
| 真实倾斜书成功 | 原倾角109.0818°，选用更直立终态；约1.000004秒完成，peakRise0.708827，同帧抛高与翻面成立，初末净XZ0.2639；恢复普通重力／无约束后实际落稳净XZ0.241569，五点gap最小-0.0000219345、最大0.0000038147，最大穿透0.000329226，下层违规0 |
| 动画中catchCancel | 已发生抛高和转动后约0.666676秒取消，同步捕获、未推进下一物理步即恢复原position／quat／velocity／collider等状态，下层违规0 |
| 50°斜面拒绝 | 确实接受并进入两姿态规划，最终因 `single_unstable_com_support` 安全拒绝，非空集合／无资格早退，原姿态恢复 |
| 100 unique双LP | 真实 `ref_bfsesameball` 两姿态各161700组合，LP wall约433.128＋433.492ms，总约0.900002秒后因斜支撑安全拒绝、恢复；没有完成动画，不能作为双LP再颠锅成功的期限证明 |

[R1原始失败](../../work/stable-visibility-stage-two-20261026/single-upright-candidate-r1/regression-single-rotation-theme-3-actual-book/surface-acceptance.json)仍为false，两条错误仅是新增QA把约2ms协作切片目标误当硬上限：cold12.3783ms及large2.024ms。R2移除了这条新增错误断言，没有放宽原生产2ms切片机制或1.51秒硬期限。R2实际最大slice仍完整记录：cold12.6964ms、warm取消0.6264ms／拒绝0.8056ms、large2.0258ms；cold规划CPU21.4153ms、large53.5294ms。这些桌面QA/JIT及协程采样不能解释为手机FPS或稳定2ms上限。

候选另有[旧fallback](../../work/stable-visibility-stage-two-20261026/single-upright-candidate-r2/regression-fallback-theme-0-original-convex-budgets/surface-acceptance.json)六case／340checks通过，以及[玩具主题矩阵](../../work/stable-visibility-stage-two-20261026/single-upright-candidate-r2/regression-matrix-theme-3-actual-toys-path/surface-acceptance.json)19行／611checks通过。但该次玩具18件button表层9件，原失败世界为1件，不能称复现并修好同一个world；确定的大倾角机制由专门真实模型夹具证明。

当前仍在主源采用之前：Root申请独立审批的主源写窗口、新BuildId11及clean最终全套；新base必须重新取得适用的原生、微信、完整清单与发布证据。未提前记录主源采用、upload、体验版或手机性能成功，全部旧失败、R1／R2与目录输出异常保留。


## Source11正式采用与新最终base验证进度

独立reviewer已批准主源写窗口，将隔离验证的单目标备用落姿纳入生产；原姿态规划失败后才尝试新落姿，不放开下层、目标集合、邻位、支撑或期限门槛。当前实际源身份为：

| 来源 | SHA-256 |
| --- | --- |
| GooseSurfaceShuffle.cs，原获批候选 | `0401a3e505248273b0a419cb6c493f6d983a43aa90536aa3380c79fbedae76c6` |
| Surface QA，四case＋暂停catchCancel／itemScale | `9df370ea5633cfa56531092f73ae7fcd88651cfd52b605645c691da139ef15b0` |
| Runtime，`20261026-VISIBILITY2-SHAKE11` | `f342625e4415a3c69ba6a7e8cddfe93ad6f70ce98f1223fa6c066d9108c5dd42` |

新证据只来自 [final-shake11-delivery](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery)。原生与微信快照分别为本轮 `native-shake11-workspace` 与 `delivery-shake11-workspace`；[source-inputs](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/source-inputs.json)及[native-build-inputs](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/native-build-inputs.json)均4078项且逐项完全相同。下列为本次只读时已落盘的终态，未把旧base通过抵扣新binary：

| 新base验证 | 实际结果／证据 |
| --- | --- |
| 编辑器／SDK／时点predicate | [Editor71/71](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/editmode.xml)、[SDK方法mock7](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/sensor-lifecycle/sensor-lifecycle.json)、[实际predicate30](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/promotion-contract-fixture.json)通过；mock仍不是硬件传感器验收 |
| 新单目标夹具 | [四case、67checks](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-single-rotation-theme-3-full-final/surface-acceptance.json)完成通过，含暂停中同步catchCancel、新姿态真实落稳、50°和100点双LP安全拒绝 |
| 完整五主题矩阵 | [95行、2999checks](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-matrix-full-final/surface-acceptance.json)全部完成通过、errors为空；旧Source10失败独立保留 |
| 自然／冻结显隐 | 新base下 `visibility-natural-theme-0..4-full-final` 与 `visibility-frozen-theme-0..4-full-final` 共10组均completed/pass/errors0，保留各自原获批自然／精确冻结合同及颜色门槛 |
| 真实拾取及颠锅显露 | 新base `reveal-theme-0..4-full-final/reveal-stability.json` 五主题各930checks均完成通过，含每报告三阶段／实际picks，不挪用pilot |
| 辅助回归 | [fallback340](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-fallback-theme-0-full-final/surface-acceptance.json)、[interrupt110](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-interrupt-full-final/surface-acceptance.json)、[clip22](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-clip-theme-0-full-final/surface-acceptance.json)、[interaction61](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-interaction-full-final/interaction.json)、[selection122](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-selection-full-final/acceptance.json)通过 |
| 三种库存颠锅 | [stock3](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-toss-theme-0-stock-3-full-final/surface-acceptance.json)、[barbecue18](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-toss-theme-1-stock-18-full-final/surface-acceptance.json)、[stock300](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-toss-theme-0-stock-300-full-final/surface-acceptance.json)现均完成通过；检查数分别321／306／25 |
| 真实首关→第二关 | `transition-sensor-theme-0..4-delay-0-full-final` 五主题sensor各12checks已通过；[desktop manual](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/transition-manual-theme-0-delay-0-desktop-full-final/stage-two-stability.json)本次读取仍completedfalse、errors为空，批次剩余项不能提前记完整七场通过 |

Source11单件成本另按本新binary记录：cold最大slice13.8936ms，warm取消0.768ms／拒绝0.9919ms，大模型2.1198ms；四case耗时依次约1.000090／0.666669／0.033333／1.066775秒，均在1.51秒内。旧候选12.6964等数值只留在历史节，不当作本新构建成本，仍不声称硬2ms或手机FPS。Reviewer已只读核对新67项实际报告及context，批准collector单件合同；完整collector尚未执行。

新的官方CLI [preview信息](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/wechat-preview-info.json)为27,777,093字节，约26.5MiB；[新包体audit](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/wechat-package-audit.json)通过，本地包27,345,121字节。[70文件微信manifest](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/wechat-files.json)与[136文件Windows release manifest](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/windows-release-files.json)已生成并绑定新native输入；preview与暂存不是upload回执，不等于设体验版。

该历史采证阶段当时仍需Root执行启用 `--require-single-rotation` 的完整collector、收齐转关终态及发布文件全SHA核验，再补上传与git真实回执。**1.0.10在该历史阶段尚未上传**。所有原失败、Source10及R1／R2候选raw继续保留；后台用途声明、用户实际微信回调、iPhone15 Pro效果与持续帧率依然没有本轮实机证据，不能由桌面、mock或平台编译替代。


## Source11完整统一门禁与桌面复制终态

此前进行中的七转关现全部completed／passed、各12checks且errors为空：五主题sensor、[桌面manual](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/transition-manual-theme-0-delay-0-desktop-full-final/stage-two-stability.json)以及[玩具0.016秒边界](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/transition-sensor-theme-3-delay-0p016-boundary-full-final/stage-two-stability.json)。这是生产首关实际清15件、自动进入300件后的合成输入／桌面入口证明，不是微信硬件数据。

Root已实际运行新base完整collector，启用 `--require-single-rotation`；331项门禁全部通过，errors=[]、missing=[]。publisher随后执行发布目录门禁，[当前delivery-verification](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/delivery-verification.json)已更新为332项、completed=true、passed=true，仍errors=[]、missing=[]；新增末条为 `Published WeChat complete file set exactly matches tested export`。这是文件发布目录一致性的额外证明，不等于官方upload成功回执。

本次不采用QA-only revision/reuse：完整4078项Source11输入、同一新QA播放器的逐run完整文件SHA、71Editor、7实际SDK方法mock、30实际predicate、67单件夹具、95行矩阵、10显隐、五Reveal、七转关、三库存toss及全部辅助回归按新base统一收集。历史Source10单件失败、旧663像素颜色失败、QA时点失败及R1误加硬slice门槛失败没有被改成pass或删除，也没有混入新base抵扣新检查。Windows release与微信各自的完整manifest共同绑定同一生产输入；跨平台产物不声称为同一个binary。

[desktop-copy-receipt.json](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/desktop-copy-receipt.json)实际记录：`copied=true`、`files=136`、`launched=false`、`oldRunningPlayerUntouched=true`，目标 `C:/Users/123/Desktop/catch-big-goose-shake11`，绑定release manifest SHA-256 `3f0f4317c0eb4f6fe4fae32867476378e219233a4acceea3a22c5cad5e53dd56`。Root已作完整文件SHA比对；未启动新版、未停止或替换旧窗口，不能据此认定用户已切换测试入口。

上述上传待回执阶段随后已取得下节官方成功回执；git状态见[代码提交及远程核验回执](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/git-push-receipt.json)。`phoneAcceptancePassed=false`、真实微信sensor验收未定的边界继续保留：后台加速度用途声明是否生效、实际授权／硬件回调、iPhone15 Pro效果及持续帧率均不能由本轮桌面／mock／preview／文件门禁替代。


## 最终交付：官方开发版本1.0.10已上传

| 交付项 | 实际终态与证据 |
| --- | --- |
| 源码／完整统一门禁 | `20261026-VISIBILITY2-SHAKE11`；[最终delivery-verification](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/delivery-verification.json)completed／passed=true，332checks、errors=[]、missing=[]；完整新base，无QA-only复用 |
| 官方开发版本 | [wechat-upload-receipt](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/wechat-upload-receipt.json)：uploaded=true、exitCode=0、version=1.0.10、AppID=wx60b50db2472c4782，UTC13:52:21.536566／北京时间21:52完成 |
| 包体及上传后完整性 | 平台编译27,777,093字节，约26.5MiB；`privateUploadFilesUnchangedAfterUpload=true`、`publishedFilesUnchangedAfterUpload=true`；export manifest SHA-256 `fcde91809d43cb11bdf4295646aeb735b48e1c8a9c0222c01be4582f8580be3b`，CLI日志及info哈希由receipt绑定 |
| 桌面新版 | [复制回执](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/desktop-copy-receipt.json)136个完整release文件SHA匹配至 `C:/Users/123/Desktop/catch-big-goose-shake11`；未launch、旧窗口未动 |
| 新版效果材料 | [Native实际颠锅GIF](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-clip-theme-0-full-final/shake-moderate.gif)、[33帧帧表](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-clip-theme-0-full-final/shake-frame-sheet.jpg)，来自本新binary的生产相机与合成手势，不是手机录像 |
| 体验版／公开发布 | receipt中 `experienceVersionSelected=null`、`publicReleasePerformed=false`；只确认开发版本已上传，不声称已设体验或已公开发布 |
| Git／真实手机 | 代码提交与origin核验以[代码提交及远程核验回执](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/git-push-receipt.json)为准。后台隐私用途声明、实际微信授权／传感器回调、iPhone15 Pro效果和持续帧率仍未验收 |

旧Source10玩具单件失败、663像素颜色失败、QA原始时点失败、R1不恰当硬slice断言失败及所有中间原型仍完整保留。本次成功来自经独立审批的新生产修复和同一新QA二进制的完整套件，未通过抹除历史、放宽原颜色／下层／位移门槛或全部激活道具获得通过。
