# 下层显隐稳定与第二关颠锅修复计划

用户反馈：下层道具持续显示/隐藏；第二关不能摇起，要求核对并复刻竞品效果。沿用先计划、独立Agent审批、多Agent协作；Unity 2022.3.62f3。下层仍为静止碰撞支撑，禁止通过全部渲染、全部激活、释放下层或补选目标掩盖问题。

## 当前证据与尚未证实部分

- 初始反馈时源码为SHAKE7；当时已交付桌面测试包与微信开发版本1.0.7。电脑有来自常规Windows目录的旧进程，不足以证明用户测试的入口，已异步询问；后续新版本进度见末节。
- `ProbeCovered`依赖其他道具的`DepthVisible`，再据结果更新本身`DepthVisible`；held每秒重探且隐藏延迟只有0.35秒，存在状态反馈风险，必须用实际几何和长时采样复现。
- 旧r4验收入口确实为`SelectDifficulty(1)`，测过真正第二关300件；缺少第一关真实消完15件→自动过渡→第二关首摇、连续游戏及长期显隐稳定验收，不能说旧测试仅测了第一关。
- 第二关不摇的原因尚未证实。分别记录手势入口/拒绝原因、原始表层集合、动画开始/完成/取消、规划失败与实际位姿，区分输入、资格、规划及发布入口问题。

## 第一阶段：只增加复现与证据

独立审批后允许新增隔离的开发验收脚本和运行工具，不修改生产行为。使用实际主题模型、生产相机与真实两关流程，不把第二个主题当第二关。

1. 记录正常300件开场结束后的逐件renderer状态、`VisibilityChanges`、遮挡缓存、body位姿、held/gravity、表层资格；持续观察默认30秒，重判覆盖不足时有界延长至60秒。静止几何夹具须能隔离显隐状态反馈，另采正常物理下的真实场景录像。可见边缘不能被错误消掉。
2. 通过真正首关清除与自动转关建立第二关，记录首个可交互时刻以及之后多次普通1.6g合成手势/Windows空格入口。原始目标只来自接受时已激活表层；记录完成与失败，而非只看Request返回true。
3. 冻结旧桌面包/日志和本轮源输入基线。新QA输出放`work/stable-visibility-stage-two-20261026`，保留本轮失败材料与SHAKE7既有交付，不改历史报告结果。

## 第二阶段：根因与实施审批

复现后由独立Agent批准最小生产修改。显隐方案须消除渲染状态作为自身遮挡依据的循环，采用与实际几何、相机及结构变化一致的稳定判定；继续预算化计算并验证选择轮廓和显露后的及时显示。不能仅扩大延时把周期拉长。

第二关只修证实的输入/转关/表层资格/规划问题，保持上层可见抛起、横向弧线、翻面、落稳新位置；下层不加重力、不被摇动、不被收费重排。保留暂停、取消、原容器/实例身份、库存和边界约束。竞品结论与冻结代码证据分开记录，不把本项目适配称为已逐行还原。

## 验收、发布与版本识别

- 新增长时显隐和真实转关回归；原95行矩阵、表层/生命周期/实际凸包/同帧边界、交互与高亮回归按改动影响继续保留，测试不能降低原门槛来通过。
- 录像至少覆盖静止下层、首关转第二关后颠锅、完成后的下层稳定。Windows合成输入不是iPhone实测。
- 基于同一冻结源码构建新Windows独立包和微信包，校验全部配套文件与包体，再依既有授权自动上传新开发版本。桌面新包须明确版本，不能让旧运行窗口冒充新包。后台体验版设置/传感器声明/实际iPhone验收仍按真实状态单列。
- 完成适当检查后按当前AGENTS提交本任务变更并正常推送origin当前分支，排除无关并发改动，不改写远程历史；报告分支、commit和推送验证。

第一阶段审批状态：独立Agent plan_reviewer已批准仅新增隔离QA与采证运行工具。后续已按下述独立审批实施 DAG、透明遮挡资格及保守完整包络，并修正已实际重放证实的传感器 Stop 竞争。真实after-toss颜色失败迫使停止旧base的QA-only复用；.90 pilot通过后已正式批准并采用新 `20261026-VISIBILITY2-SHAKE10` 主源，clean新base完整验证发现下述单目标倾斜姿态真失败。隔离候选已通过专门夹具，后续已获主源窗口采用单目标备用落姿并升级BuildId11；新base七转关及全部必要验证现已完成，单一新base完整collector已通过；官方CLI已于本地21:52实际上传开发版1.0.10，最终332项门禁通过；体验版选择、公开发布和手机验收不标记完成，Git状态见[代码提交及远程核验回执](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/git-push-receipt.json)。


## 生产实施审批与参考实验范围

独立 Agent plan_reviewer 已根据自然/固定几何下分别29/28件反复显隐的实际证据，批准固定几何/相机 epoch、前后有向依赖的视觉计划；不再用上次 renderer 输出作为新遮挡输入，保留256查询预算、物理表层与下层支撑状态。

fixed-r1 实际固定几何验证零闪烁，但原全投影参考差异5.3935%超标。QA控制排除阴影后仍4.3611%，证明不能仅归因阴影。真实 ReferenceGlass 混合材质杯子会透出下面几何，却被整块凸包当作不透明遮挡。Agent 随后正式批准最小 opaque-cover 修正：只允许所有实际材质已确认不透明的 whole-item proxy 作遮挡；透明、cutout和未知均保守跳过；在缓存/epoch准备阶段分类，renderer集合和材质属性变化会失效，不在每条ray分配材质数组。

Agent 另批准独立“保持生产投影者集合的彩色几何参考”：仅为reference新打开的隐藏颜色renderer临时关闭新增投影，保留原可见投影者、灯光、材质和阴影质量。记录投影者身份、添加数量并finally恢复casting flags；ShadowsOnly等不明语义标不适用。沿用差异像素不超过0.25%、平均RGB差不超过0.001的数值门槛。原全投影参考和全禁影实验继续独立保留，包括失败；新实验只回答当前生产照明下有无漏画彩色几何，不回答恢复全隐藏投影后的整体光照相同。

第二关真实生产转关及合成sensor五主题目前都能完成颠锅，不能据此声称修复尚未复现的硬件问题。禁止为猜测修改controller；继续区分旧入口、真实微信传感器失败和游戏内动画链。

## 后续审批取舍与最终实施范围

独立 Agent 曾批准仅在隔离 work 中探索完整包络、真实 mesh BVH、最近面查询与 sidecar 生命周期原型，并用真实图形夹具和五主题原色参考检验。这些探索的失败、修订和通过的模块测试全部保留；不因模块79／86项测试通过就放行画面超限，不放宽0.25%／0.001参考门槛。最终没有选择 BVH／nearest／hybrid，相关代码和试验只留 work，不进入 main 或交付构建。

最终采用当前 main 的较小 DAG＋25点完整 authored visual 投影包络＋95%代理内部验证方案，遮挡只认同 epoch 已确认的前方不透明物件。每件视觉查询最多64、整刷新仍最多256，预算不足保守显示；物理表层、隐藏下层静态支撑、拾取／取消和原始目标集合约束不变。独立颜色参考保留生产 caster 资格集合；raw-lit与no-shadow作为独立实验保留各自失败、自噪声及恢复记录，不混写为新实验通过。

新增 Reveal QA 是最终必需证明：五主题各有同报告的 initial、真实1–3次生产拾取及 after-toss 阶段；检查实际库存减少、此前隐藏物件及时显露并持续可见、每阶段至少12秒稳定及不超过256查询、原颜色参考门槛。首摇仍只作用原已激活表层，覆盖不少于80%、最多48件；联合升高翻面／可见弧至少60%，最终净XZ至少半数，下层、底、边界和补选身份违规为0。自然场景允许并记录真实微漂，不暗加初末同pose；冻结场景精确保持几何。所有数值沿获批QA，不事后增加全表层100%或改写失败报告。

## 传感器 Stop 竞争的证实与最小补丁

对真实 `GooseWeChatPlatform` 方法块的 SDK 异步mock重放，[补丁前两项失败](../../work/stable-visibility-stage-two-20261026/sensor-race-before/sensor-lifecycle.json)分别为重复 Stop 与旧 completion 错误释放新 Stop。独立审查后采用最小 Stop coalesce＋Stop generation 补丁，[补丁后七项通过](../../work/stable-visibility-stage-two-20261026/sensor-race-fixed/sensor-lifecycle.json)，绑定平台源 SHA-256 `9ecab9be1175189faeaf7962b66f4dde70d0f88c197d81d5812fca3a4caa598e`。不改controller幅度、手势门槛或下层资格，不绕后台隐私检查；这是代码竞争的证明，不是用户iPhone链已验证的证明。

## 旧 final-sensor-delivery 交付阶段记录（保留）

当前 final-sensor-delivery 使用 main 的4078项输入：`delivery-build-workspace`导出微信，`native-proof-workspace`构建原生证明，[复制清单对照](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/native-copy-comparison.json)零差异；[71项编辑器测试](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/editmode.xml)通过。95行矩阵和五主题固定几何颜色参考现已通过，其他自然、转关、Reveal及辅助回归继续运行；进度详见[本轮修复记录](../development-reports/stable-visibility-stage-two-20261026.md)，待同源collector统一放行。

本轮微信构建、[本地审计](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/wechat-package-audit.json)和CLI preview已通过，平台编译后27,772,822字节。[预览码](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/wechat-preview.png)仅是preview。根据用户续令，在必要原生和包体校验完成后自动上传新开发版本，当前拟用1.0.10；**因下述新阻断暂缓，尚未执行，不得提前写成功或设体验版完成**。

统一验收、发布哈希、upload回执及commit／push验证由主 Agent 后续补齐。后台传感器声明／用户实际授权、iPhone15 Pro真实加速度计与持续帧率仍单列未过；不能用本轮源码mock、合成转关或预览结果代替。

## 玩具首摇违规的QA采证审批（历史阶段）

[玩具真实转关 sensor 报告](../../work/stable-visibility-stage-two-20261026/final-sensor-delivery/transition-sensor-theme-3-delay-0-final/stage-two-stability.json)已完成，原20件全部完成可见受控颠锅，candidateCoverage=1，floor／boundary=0，但lowerViolations=61，整次失败。该数值是采样次数，不是不同物件数；目前未证实是生产误激活或QA时序，不凭推测改生产或放宽下层门槛。

Reviewer正式批准QA-only前8个offender原始采证，记录对象／阶段／原始与当前状态，再确定最小后续措施。原失败文件不覆盖。其余theme4、manual、Reveal及辅助回归使用新run `remaining-final`继续收集真值；1.0.10在此阻断解除及必要验收完成前不上传。

## QA采样确证与当前真实颜色阻断

真实[v2 raw](../../work/stable-visibility-stage-two-20261026/lower-violation-diagnostic-v2/transition-sensor-theme-3-delay-0p016-varied-start-witness/stage-two-stability.json)已确证一次Fixed物理前合法晋升、同帧EOF移动后probe变假的采样时点缺陷；[派生证据](../../work/stable-visibility-stage-two-20261026/lower-violation-diagnostic-v2/v2-evidence.json)完整绑定源与播放器，原rawfalse不变。Reviewer批准仅StageTwo／Reveal两个guarded QA改为Fixed新鲜witness；[实际共享predicate夹具](../../work/stable-visibility-stage-two-20261026/promotion-contract-fixture-r3/promotion-contract-fixture.json)1positive＋29negative全过。旧toy61／BBQ1无逐件身份，只能说明旧门槛含已证实采样缺陷、需要新QA替代，不能逐计数归因。

R2 Stage烧烤171次又暴露独立5点探针漏外环真实曝光，原生产17点与fresh／band／锁／pose条件合法。已批准R3只将Stage独立oracle补成覆盖原17点的25格，与Reveal统一，pure helper不变；R2失败保持独立build，不捞入新最终结果。

更重要的是[R2烧烤Reveal](../../work/stable-visibility-stage-two-20261026/qa-promotion-timing/reveal-theme-1-revised-final/reveal-stability.json)：下层／底／边界／补选违规0，Fixed评估与接受21/21，但after-toss颜色663像素、0.347648%超过原0.25%，均值0.000545仍不足以通过双门槛。initial189像素和after-pick170像素各自通过；唯一after-toss色差错误不能归QA、不能supersede。当前停止旧生产QA-only复用发布路径，1.0.10禁止上传。

当时Reviewer仅批准work中一次 Depth内部代理系数 .95→.90 pilot，25点／DAG／256查询／不透明资格与所有既有门槛不变。后续烧烤真实pick+toss与五主题静态原色参考已通过，保留renderer及查询成本记录；正式批准后才修改main并进入下述clean新base，旧报告和旧产物只作为历史。

## .90采用审批与新base完整验证（Source10历史阶段）

[隔离烧烤真实Reveal](../../work/stable-visibility-stage-two-20261026/visual-proxy-candidate-r1/reveal-theme-1-interior-090-reveal-output-fixed/reveal-stability.json)三阶段颜色差异11／12／5像素，五主题静态参考也全部通过。保留可见数217／218／220、renderer233／234／236、最大query246／249／249及收敛成本，不以全渲染掩盖问题。首轮贡献输出的目录异常与未完成报告继续保留；只修QA CreateDir后新目录重跑，不覆盖旧raw。

reviewer正式批准主源窗口，Depth b4490b…采用interior=.90，Runtime1c3da…使用 `20261026-VISIBILITY2-SHAKE10`，Stage21fdc4…保留完整25格strict witness，Reveal c9795d…记录成本／贡献并创建输出目录。只有这些已批准修改进入main，复杂BVH／nearest原型继续只在work。

新 [final-visibility2-delivery](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery) 的两份完整4078项source/native输入逐文件相同，[Editor71](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/editmode.xml)、[新sensor生命周期7项](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/sensor-lifecycle/sensor-lifecycle.json)、[新predicate30项](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/promotion-contract-fixture.json)已实际通过，后者绑定新Reveal源。新95矩阵、10组自然／冻结显隐、五Reveal原生批次及WebGL构建继续进行；每个run须绑定本新base播放器，不使用qa-revision flags抵扣旧base。

该历史中间阶段当时仍须新五转关、toss／interrupt／clip／interaction／selection等全部必要回归及完整文件校验，继而由主 Agent 补upload/git真实回执；未完成前1.0.10不上传。后台用途声明、真实微信/iPhone传感器与持续性能依然未过。该段记录当时进行中状态；最终交付以文首和末节为准，未用部分结果提前放行。


## 单目标大倾角真失败与隔离候选审批（采用前记录）

`final-visibility2-delivery` 的[完整95行矩阵](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/regression-matrix-full-final/surface-acceptance.json)已完成但失败，错误限定为玩具 `button/18` 的颠锅完成／效果三项；当时仅一个表层目标 `ref_gtstickerbook`。其实际9点凸包、109.08°原姿态的五点LP底面跨度0.1634619，大于原支撑可行界0.0996，保持原姿态无法靠整体升降获得合法支撑，不是QA采样豁免问题。原[几何日志](../../work/stable-visibility-stage-two-20261026/final-visibility2-delivery/regression-matrix-full-final/player.log)与失败JSON均保留，1.0.10继续禁止上传。

Reviewer批准仅在work验证单目标受控颠锅的备用 `endRotation`：原姿态规划无合法邻位时，另算更直立落姿的真实凸包与五点支撑；取消仍恢复原姿态。多目标、收费重排、原始表层集合、下层静止、0.2–0.3倍ItemScale邻位、穿透及1.51秒硬期限不变。候选Shuffle源SHA为 `0401a3e505248273b0a419cb6c493f6d983a43aa90536aa3380c79fbedae76c6`，此时仅在隔离候选，**主源生产Shuffle尚未修改**。

[候选R2专测](../../work/stable-visibility-stage-two-20261026/single-upright-candidate-r2/regression-single-rotation-theme-3-settled-book/surface-acceptance.json)四case／66项全过：真实大倾角书成功、动画中同步取消、50°斜支撑安全拒绝、100 unique双LP预算安全拒绝。正例初始Sleep仅建立可重复受控姿态，不声称原倾斜姿态已自然平衡；完成后普通gravity／None真实落稳，净XZ0.241569、五点gap[-0.0000219345,0.0000038147]、最大穿透0.000329226、下层违规0，同帧抛高翻面成立。100点两次各161700组合、约0.9秒，只证明安全拒绝与恢复，不能声称完成颠锅动画。

[R1失败](../../work/stable-visibility-stage-two-20261026/single-upright-candidate-r1/regression-single-rotation-theme-3-actual-book/surface-acceptance.json)原样保留：新增QA将约2ms协作切片目标误写成硬上限，cold12.3783ms／large2.024ms因此失败；R2删除这条新增错误门槛，生产原切片机制和1.51秒硬期限均未改。R2实测cold12.6964ms、warm0.6264／0.8056ms、large2.0258ms如实保留，不作为手机帧率证明。

[原fallback六case／340项](../../work/stable-visibility-stage-two-20261026/single-upright-candidate-r2/regression-fallback-theme-0-original-convex-budgets/surface-acceptance.json)及[玩具19行／611项](../../work/stable-visibility-stage-two-20261026/single-upright-candidate-r2/regression-matrix-theme-3-actual-toys-path/surface-acceptance.json)均通过，但后者18件button实际表层9件，不是原失败的单表层world；大倾角机制由专门真实模型夹具证明。下一步由Root申请主源写窗口与新BuildId11，再建立clean最终base完整重验及新微信包；尚未采用、上传或最终放行。


## Source11主源采用与最终同源验证（当前阶段）

Reviewer已正式批准主源写窗口：采用原隔离候选Shuffle `0401a3e505248273b0a419cb6c493f6d983a43aa90536aa3380c79fbedae76c6`；Surface QA `9df370ea5633cfa56531092f73ae7fcd88651cfd52b605645c691da139ef15b0`包含R2四case、暂停中catchCancel及itemScale字段；Runtime `f342625e4415a3c69ba6a7e8cddfe93ad6f70ce98f1223fa6c066d9108c5dd42`身份为 `20261026-VISIBILITY2-SHAKE11`。仅单件受控备用落姿进入生产，其余已批准视觉和目标／下层合同不变；旧Source10单表层失败、候选R1错误硬slice断言及其raw全部保留。

新base为 [final-shake11-delivery](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery)，两份4078项[source](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/source-inputs.json)／[native](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/native-build-inputs.json)输入逐文件相同，独立原生／微信快照分别 `native-shake11-workspace`／`delivery-shake11-workspace`。已实际通过Editor71、SDK方法mock7、timing predicate30、单件暂停取消67、完整矩阵95行（2999checks）、五自然＋五冻结显隐、五真实Reveal（各930checks），以及fallback340、interrupt110、clip22、interaction61、selection122。均为新base新binary，不挪用旧候选通过。

当前读取原始报告时，stock3／18／300三场toss均已completed/pass，五sensor真实转关各12checks已过；desktop manual仍在运行，不能提前宣称完整七转关通过。最终collector将启用 `--require-single-rotation` 并继续严格绑定完整source／player文件；尚未完成统一collector与最终发布放行。

新官方CLI [preview](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/wechat-preview-info.json)实际成功，平台包27,777,093字节，约26.5MiB；[包体audit](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/wechat-package-audit.json)通过，[70文件微信清单](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/wechat-files.json)及[136文件Windows release清单](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/windows-release-files.json)均绑定新native输入。这里只记preview／暂存与清单，不写upload或体验版成功。1.0.10尚未上传，等待Root补完整collector、upload和commit／push真实回执；后台隐私用途、真实微信／iPhone传感器及持续手机帧率仍未过。

Source11实际单件slice为cold13.8936ms／warm0.768与0.9919ms／large2.1198ms，继续只记录不暗加硬2ms；四case均<=1.51秒。Reviewer已审新67项实际报告并批准可选collector单件合同，最终publisher强制该开关，尚待统一collector执行。


## 完整新base放行、桌面交付与上传待回执

Source11新base的七条真实转关现均完成通过：五主题sensor、桌面manual及玩具0.016秒边界，各12checks、errors为空。[桌面manual终态](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/transition-manual-theme-0-delay-0-desktop-full-final/stage-two-stability.json)与[玩具边界终态](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/transition-sensor-theme-3-delay-0p016-boundary-full-final/stage-two-stability.json)补齐此前进行中部分。

Root已实际执行完整collector，启用 `--require-single-rotation`、使用全新 `final-shake11-delivery`，不启用QA-only revision/reuse。完整331项门禁通过、errors／missing均为空；publisher随后追加正式发布目录完整文件比对，本次读取[当前统一证据](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/delivery-verification.json)为332项、completed／passed=true、errors=[]、missing=[]，新增的一项仅证明发布目录与测试微信导出全文件一致，不作为upload回执。新source4078逐文件一致、每个run绑定同一新QA播放器；Windows release和微信是各自构建产物，以完整清单绑定同一源输入，不冒称跨平台二进制相同。

[桌面复制回执](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/desktop-copy-receipt.json)记录136个release文件已完整复制并SHA比对至 `C:/Users/123/Desktop/catch-big-goose-shake11`，未launch，旧运行窗口未改动。它交付新版文件，不证明用户已打开新窗口。

上述待回执阶段随后已取得下节官方成功receipt。所有旧失败、候选与原始报告保留；后台隐私用途声明、微信实际硬件回调、iPhone15 Pro颠锅及持续帧率仍未验收。


## 开发版1.0.10上传完成（最终交付状态）

[官方CLI上传回执](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/wechat-upload-receipt.json)已实际确认 `uploaded=true`、exitCode=0、版本1.0.10、AppID `wx60b50db2472c4782`，完成UTC `2026-10-26T13:52:21.536566+00:00`（北京时间21:52）。平台编译包27,777,093字节，约26.5MiB；上传后私有上传目录及正式发布目录完整文件均未变化，export manifest SHA-256为 `fcde91809d43cb11bdf4295646aeb735b48e1c8a9c0222c01be4582f8580be3b`。完整新base门禁最终332项通过、errors／missing为空；新版桌面136文件复制比对完成、未启动，旧运行窗口保留。

`experienceVersionSelected=null`、`publicReleasePerformed=false`：已上传开发版本，不声称已选体验版或公开发布。新[实测颠锅GIF](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-clip-theme-0-full-final/shake-moderate.gif)与[帧表](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/regression-clip-theme-0-full-final/shake-frame-sheet.jpg)随新base保留，是Native合成输入画面。Git状态以[代码提交及远程核验回执](../../work/stable-visibility-stage-two-20261026/final-shake11-delivery/git-push-receipt.json)为准，不改变本次已上传源码／包体；后台隐私与真实iPhone验收边界继续保持。
