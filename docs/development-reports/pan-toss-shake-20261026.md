# 表层颠锅摇动与微信体验包（SHAKE7）

最终阻塞审计：当前交付文件再次通过完整校验，1.0.7开发版本上传成功。连续三轮剩余条件均为后台体验版设置与真实iPhone验收不可核实；官方CLI没有体验版切换命令，当前未检测到Apple USB设备，也没有新实机验收结果。独立Agent确认没有遗漏的可自主完成本地步骤，建议将目标标为blocked，等待可验证后台会话或实际设备操作条件。详见[阻塞审计记录](../../work/mobile-surface-performance-20261026/shake7-blocked-audit.json)。这不是功能或包体回归失败，也不把原生与预览结果当作真机通过。

日期：2026-10-26。Unity 2022.3.62f3，目标设备iPhone 15 Pro。当前状态：r4同源原生完整验收通过，五主题95行／3007项检查、下层违规0、错误0；微信完整WebGL构建、包体审计与官方CLI开发版本 `1.0.7` 上传均已成功。后台是否将该版本选为体验版仍未核实，SHAKE7微信GUI、手机传感器声明生效及iPhone真实摇动／持续性能未通过验收。首轮、r2和r3失败证据继续保留。

用户要求摇动时将物品颠起并翻面，类似颠锅，完成后自动上传微信新体验包。实现与验收依据为[本轮计划及独立Agent审批](../development-plans/pan-toss-shake-20261026.md)，继续遵守[正常模式分层计划](../development-plans/mobile-surface-performance-20261026.md)。此前性能与摇动落稳工作见[SHAKE6报告](mobile-surface-shake6-20261026.md)；旧报告、旧二维码和原始竞品证据保留，不视为本轮新包证明。

## 物理原型未通过，停止继续加力

首轮仅增加受力与同向翻转，普通合成1.6g输入下，300件场景的原6个表层目标中只有3个同时达到抛高与翻转要求，低于至少60%即4件的门槛。5件达抛高门槛、3件达翻转门槛，春卷仍存在接触夹持。原型没有穿底／越界或下层违规，但这不能抵消颠锅效果未达标。

失败记录见[物理原型验收](../../work/mobile-surface-performance-20261026/toss-0-stock-300-shake7-probe/surface-acceptance.json)，原型源码和配置冻结在[shake7-physics-prototype](../../work/mobile-surface-performance-20261026/shake7-physics-prototype)。按事先约定停止继续扩大力，未降低通过门槛或重写旧结果。

物理profile已恢复安全档：向上目标2.8、累计正向上行增量预算5.4、注入速度限制4.5、角速度限制8、水平有符号向量预算2.4。预算描述不等于碰撞后最终速度上限，也不把水平有符号向量误称为各方向冲量绝对值累计。

## 独立审批后的受控表层颠锅

独立Agent `plan_reviewer` 审批通过受控方案，`competitor_research` 实现并配合生产相机复核。手势接受时固定原始已激活表层集合，沿0.90秒弧线抛起，绕水平轴完成翻转，再接回通过实际碰撞、支撑及容器约束检查的安全位置。该路径明确记录为 `controlled-pan-toss`，属于本项目适配，不宣称它是已经还原的竞品物理Force。

高度、翻转、水平弧线和落稳后的净XZ位移由验收自己的原姿态与实际逐帧姿态计算。正交俯视相机不能仅靠世界Y升高自证视觉效果，因此同时检查横向位移及屏幕像素变化。旋转全周的意图也不能只靠一个控制器参数证明。

只处理接受时的原目标，不从下层补足数量，不重扫成更容易通过的目标集合。下层保留kinematic碰撞支撑、不模拟重力、不被颠锅带动；手机颠锅不消耗、退款或增加收费道具使用次数。普通重排道具继续自身收费／失败退款契约。暂停、回首页、跨局取消、身份与原容器检查、安全落位和超时仍需通过。无安全落位或中断时记录真实失败，不用播放过动画替代完成。

## 首轮与r2证据

当前BuildId为 `20261026-SIZE1-SURFACE1-SHAKE7`。同一标签不足以区分文件修订，交付还须绑定源码、原生完整文件集、Wasm、数据包和微信导出的实际哈希。下表为首轮已完成的局部记录；不代表r2、r3或r4全量通过，也不是iPhone或真实手机传感器输入。

| 运行 | 结果 | 边界 |
| --- | --- | --- |
| [早餐300件颠锅](../../work/mobile-surface-performance-20261026/toss-0-stock-300-release-shake7/surface-acceptance.json) | 原6个目标中6/6同时达抛高／翻转要求，6/6具有可见横弧；25项检查通过，零错误 | `controlled-pan-toss`，生产相机，合成1.6g输入 |
| [烧烤18件颠锅](../../work/mobile-surface-performance-20261026/toss-1-stock-18-release-shake7/surface-acceptance.json) | 原2个目标中2/2同时达抛高／翻转要求，2/2具有可见横弧；306项检查通过，零错误 | 真实18件残局，不用额外目标凑数量 |
| [表层／生命周期夹具](../../work/mobile-surface-performance-20261026/fallback-0-release-shake7/surface-acceptance.json) | 完成，158项检查、零错误 | 保留目标、下层、道具计数及中断清理验证；重复检查数不是业务条件 |
| [生产相机拍摄](../../work/mobile-surface-performance-20261026/clip-0-release-shake7/surface-acceptance.json) | 完成，22项检查、零错误 | 原帧拍摄会改变时序，不用于性能结论 |
| Unity编辑测试 | 66项通过 | 编辑测试不能代替Wasm／ANGLE运行或手机验收 |
| [首轮五主题矩阵](../../work/mobile-surface-performance-20261026/matrix-release-shake7/surface-acceptance.json) | 38行主动停止，保留 `home interruption shuffle begins` 失败 | 不标为全部通过；修正夹具前提后重新运行r2 |

首矩阵停止时有38行、1184项已通过检查和上述一项错误。独立复核定位到旧QA前提：3件残局连续重排后，合格表层可能不足两个，中断测试仍无条件要求重排开始。原运行报告不改写；旧QA完整二进制、输入与构建清单归档在[shake7-first-native](../../work/mobile-surface-performance-20261026/shake7-first-native)。修正只保证中断夹具具有真实可用的表层目标，不放宽生产资格或“至少两件才可用普通重排”的契约；独立生命周期夹具的通过不替代这一失败项。

r2从统一源码重新构建，五主题独立interrupt完成110项检查，两场颠锅及生命周期夹具也通过。但[完整r2矩阵](../../work/mobile-surface-performance-20261026/matrix-release-shake7-r2/surface-acceptance.json)最终为95行、2996项通过检查、3项错误，`completed=true`、`passed=false`。错误分别是早餐 `button/3` 的实际运动完成、受控颠锅完成、可见位移／翻转／换邻效果三个断言；它们来自同一个真实落位取消，不能当作先前QA前提问题删除。

该残局库存3件而实际合格表层只有一只倾斜蒸笼。原单目标算法将相交AABB当成实心平顶，把目标从期望约11.51抬到约12.02，再因重心支撑间隙检查取消，记录 `shake_single_no_safe_neighbour` 与 `single_com_support_gap`。本次没有安全邻位是真实运行算法问题，不是目标数量不足，也没有靠补入下层物件解决。r2完整旧二进制、脚本、输入及构建清单归档在[shake7-r2-native](../../work/mobile-surface-performance-20261026/shake7-r2-native)，原矩阵报告保持失败状态。

## r3真实支撑已验证，恢复动态后边界仍失败

独立Agent审批通过仅修手机单目标落位：物理代理的69顶点是凸包点云，原索引是占位伪扇形，PhysX会从点云烹制实际凸包，不能将这些索引直接视为闭合三角面。新算法用点云线性规划的下凸包包络，求五个重心邻域探针的实际下表面；再通过真实支撑射线解落位Y，最后仍执行原有窄相碰撞与稳定支撑检查。

原0.2—0.3模型尺度的邻位范围、坡度、支撑高度差、间隙与时限均保持。包络计算仅对单目标缓存一次，每128个组合让出协作步骤，继续受原2ms切片检查和1.51秒整体期限约束；2ms是让出执行的检查目标，不能在未采样前声称每个原子步骤都严格低于2ms。多目标及收费重排路径不改，失败仍取消恢复，不放宽门槛掩盖悬空。

新QA使用真实蒸笼Collider.Raycast与15°斜台复现支撑，刚体为 `constraints.None`，避免旋转锁掩盖落位不稳；3件残局保存三件物品完整初始／最终位姿，便于独立复现及核对下层不动。

r3的[fallback夹具](../../work/mobile-surface-performance-20261026/fallback-0-release-shake7-r3/surface-acceptance.json)完成215项检查、零错误。69点真实倾斜蒸笼在15°斜台、无旋转锁的独立夹具中落稳，净XZ约0.262，手势约1.133秒。fresh [stock3颠锅](../../work/mobile-surface-performance-20261026/toss-0-stock-3-release-shake7-r3/surface-acceptance.json)也通过，但该次有两个合格顶层目标，不能把它当作真实单目标案例的替代。

r3的[300件颠锅](../../work/mobile-surface-performance-20261026/toss-0-stock-300-release-shake7-r3/surface-acceptance.json)仅边界断言失败：采到两帧中心越界，报告保留为失败。旧r3完整二进制、脚本及输入／构建清单冻结在[shake7-r3-native](../../work/mobile-surface-performance-20261026/shake7-r3-native)，没有把局部支撑通过写成整个版本通过。

随后保留九次定位运行，第九次[真实边界诊断](../../work/mobile-surface-performance-20261026/toss-0-stock-300-shake7-boundary-probe9/surface-acceptance.json)复现了两帧：手势后1.265745／1.333599秒，中心半径1.772797／1.772241，超过当时容器半径1.72加原验收容差0.05。两帧均为 `ownerPhoneToss=false`、`SurfaceAnimating=false`、`kinematic=false`、`gravity=true`，证实问题发生在动画结束、恢复动态物理之后，不能归咎于受控弧线期间的状态或直接放宽容差。

## r4边界防线与点云规模

独立审批只将原容器约束补到LateUpdate，处理已激活的动态物品；仍以半径超过原 `Radius+.02` 触发，回收到 `Radius-.02`。held、kinematic及动画目标跳过，不唤醒／解冻下层；Y、角速度和切向速度保持，仅移除向外径向速度。修正时同步Body与Transform，并在本次确有修正后统一执行一次 `Physics.SyncTransforms`，不在每帧无条件同步全场。

新独立QA在同一帧注入边界外动态体，保持FrameCount不变并在EndOfFrame检查Body与可见Transform都已纠正，同时核对速度和下层状态。它验证本帧防线，不能通过等下一次FixedUpdate才回收来掩盖一帧越界。

116个模型目录的点数审计还发现，8个鸭子代理有254—314个raw顶点，精确位置实际仅49—57个。新实现用 `HashSet<Vector3>` 精确去重，未量化、近似焊接或移动任何几何点；去重后的凸包不变。目录中独立点数最大为芝麻球100点。

独立[规模诊断](../../work/mobile-surface-performance-20261026/fallback-0-shake7-envelope-probe/surface-acceptance.json)记录：真实100点案例手势1.4333秒，累计规划CPU29.6658ms，最大切片2.0269ms；raw314点精确去重为57点后，手势1.0667秒、累计CPU6.809ms。CPU为累计分帧工作，不能写成单帧耗时；2.0269ms也说明2ms是检查目标而非严格硬上限。

该规模诊断唯一失败是QA自身平台前提断言：本应验证水平支撑平台，却采用目标重心二次换面后的normal作为平台角度。独立复核后只改为明确up的平台、按实际凸包MinY平放并自由settle再验证，没有放宽运行时坡度或间隙。原诊断335项通过检查和该失败保留，修正后的六类几何与同帧边界夹具已在r4完整复跑通过。

## r4原生最终验收与文件一致性

`release-shake7-r4` 由统一4068份同源快照构建，以下全部为最终终态通过，错误均为0。独立审批Agent已复核原生整包并放行；这项放行范围不包含尚在构建中的微信导出或手机实测。

| 最终运行 | 完成结果 | 证据与边界 |
| --- | --- | --- |
| Unity编辑测试 | 66项通过 | [编辑结果](../../work/mobile-surface-performance-20261026/editmode.xml)；不能替代WebGL或手机 |
| 五主题矩阵 | 95行、3007项检查通过；下层违规0、错误0 | [r4矩阵](../../work/mobile-surface-performance-20261026/matrix-release-shake7-r4/surface-acceptance.json) |
| fallback／真实几何／同帧Late | 六类几何，341项检查通过 | [r4夹具](../../work/mobile-surface-performance-20261026/fallback-0-release-shake7-r4/surface-acceptance.json)，含真实倾斜蒸笼、点数规模和本帧Body／render防线 |
| 五主题中断 | 110项检查通过 | [r4 interrupt](../../work/mobile-surface-performance-20261026/interrupt-release-shake7-r4/surface-acceptance.json) |
| 300件颠锅 | 原6目标6/6同时抛高／翻转、6/6可见弧线、6/6净XZ达标；25项检查通过 | [r4 300件](../../work/mobile-surface-performance-20261026/toss-0-stock-300-release-shake7-r4/surface-acceptance.json)；下层／穿底／越界均0 |
| 18件颠锅 | 原3目标3/3同时抛高／翻转、3/3可见弧线、3/3净XZ达标；307项检查通过 | [r4 18件](../../work/mobile-surface-performance-20261026/toss-1-stock-18-release-shake7-r4/surface-acceptance.json)；下层／穿底／越界均0 |
| 3件颠锅 | 原3目标3/3同时抛高／翻转、3/3可见弧线、3/3净XZ达标；322项检查通过 | [r4 3件](../../work/mobile-surface-performance-20261026/toss-0-stock-3-release-shake7-r4/surface-acceptance.json)；下层／穿底／越界均0 |
| 生产相机clip | 33帧、22项检查通过 | [r4 clip](../../work/mobile-surface-performance-20261026/clip-0-release-shake7-r4/surface-acceptance.json)，不采作性能结果 |
| 触控／入槽交互 | 61项检查通过 | [r4 interaction](../../work/mobile-surface-performance-20261026/interaction-release-shake7-r4/interaction.json) |
| 点选高亮 | 122项检查通过 | [r4 selection](../../work/mobile-surface-performance-20261026/selection-release-shake7-r4/acceptance.json)，原生通过不替代ANGLE运行 |

[原生收集与SHA验证](../../work/mobile-surface-performance-20261026/delivery-verification.json)使用 `--matrix matrix-release-shake7-r4` 完成。完整4068项源输入、复制快照和当前运行时一致，各验收运行的完整播放器文件集均与该QA程序一致；不是只对外壳EXE或BuildId进行匹配。旧失败报告及其独立二进制／输入清单仍保留，未改写为通过。

最终实际生产相机结果：[颠锅GIF](../../work/mobile-surface-performance-20261026/toss-0-stock-300-release-shake7-r4/shake-moderate.gif)、[六帧图](../../work/mobile-surface-performance-20261026/toss-0-stock-300-release-shake7-r4/shake-frame-sheet.jpg)、[33张原帧与时间](../../work/mobile-surface-performance-20261026/toss-0-stock-300-release-shake7-r4/clip-timing.json)。这些是合成1.6g输入后的原生画面，展示颠起、翻面、横弧及落稳新布局，不是手机录屏。

性能边界：最终矩阵最大规划切片实测7.7271ms，夹具冷启动最大8.4407ms，不能宣传严格2ms上限。100点独立案例手势约1.4秒，相对原1.51秒期限仅约0.11秒余量；这是原生限定观测，Wasm／手机的规划尖峰和持续性能仍需实测。结构检查43项／613个链接、8项媒体桥接与7项视频生命周期回归通过。

微信完整WebGL／小游戏导出已完成，本地包审计27,336,654字节（26.07MiB），61个JS文件语法、AppID、媒体及相关检查均通过。完整4068项主工程输入对比无差异、运行时diff为空；隔离导出阶段仅 `Main.unity` 和微信SDK生成配置两个文件出现已记录的生成变化，没有混入未经原生验证的新运行时脚本或资源。

首次整体移动发布目录因IDE占用失败，随后先完整备份旧70文件并逐项核对哈希，再仅逐文件更新已生成的70个发布文件；过期payload仅删除已知MD5对应的BR文件，没有删除工程根目录或关闭其他应用。备份位置与source／live 70文件匹配结果见[逐文件发布记录](../../work/mobile-surface-performance-20261026/shake7-inplace-publication.json)。上传前后 `collector --require-published` 均通过，完整发布文件集与验收导出哈希一致。

颠锅门槛为原目标中至少60%在同次实际采样中达到升高不少于0.6倍关卡公共尺度、翻转不少于75°；可见横弧还需不少于0.18尺度与15屏幕像素。300件与18件最终记录的下层违规、穿底和越界计数均为0，落稳后净XZ门槛保留。不能只看瞬时峰值、总受力数或翻转代码声称有效。

首轮[300件颠锅原帧](../../work/mobile-surface-performance-20261026/toss-0-stock-300-release-shake7)与[18件原帧](../../work/mobile-surface-performance-20261026/toss-1-stock-18-release-shake7)继续保留，当前最终效果以r4链接为准。上述原生通过不延伸为手机持续帧率、温升或真实加速度计通过。

## 开发版本1.0.7已上传，体验版设置未核实

已按用户授权在实现验证后自动上传，无再次请求确认。官方CLI执行 `upload --version 1.0.7`，AppID为 `wx60b50db2472c4782`，退出码0并返回 `√ upload`；平台编译后27,768,626字节（工具显示26.5MB），低于30MiB限额。证据分别为[上传请求](../../work/mobile-surface-performance-20261026/shake7-upload-request.json)、[上传回执](../../work/mobile-surface-performance-20261026/shake7-upload-receipt.json)、[平台编译信息](../../work/mobile-surface-performance-20261026/shake7-upload-info.json)及[CLI完整日志](../../work/mobile-surface-performance-20261026/shake7-upload.log)。

CLI `upload` 已上传的是后台开发版本，和 `preview` 生成预览二维码不同。该AppID后台是否把 `1.0.7` 选为体验版仍未核实，清单 `experienceVersionSelected=null`；不能把预览码或上传成功当作设体验版成功，也不表示提审或公开发布。

本轮preview也已实际返回 `√ preview`、退出码0，平台编译后27,768,626字节，与upload一致。当前[SHAKE7预览码](../../work/mobile-surface-performance-20261026/shake7-preview.png)和[预览编译信息](../../work/mobile-surface-performance-20261026/shake7-preview-info.json)已生成，并把QR／info哈希及preview成功状态追加到最终清单；预览后再次执行 `collector --require-published` 全部通过。此链接明确是预览码，不是已选体验版的证明。

[最终交付清单](../../work/mobile-surface-performance-20261026/final-delivery-shake7.json)绑定源码／原生输入、完整发布文件集、平台包体、upload回执及本轮预览QR／info哈希。活动Wasm标识为 `55dc60f82307acd5`，数据标识为 `c910beebf9fab3ce`；各自完整SHA256在清单中，避免仅凭BuildId或旧二维码识别当前版本。

本轮仅查看既有公众平台浏览器会话时，Computer Use helper自动停止，确切原因是无法可靠确定当前浏览器URL以执行策略：`Computer Use has been stopped for this turn because it could not determine the current browser URL on Windows with enough confidence to enforce policy.` 这不是操作者自行谨慎暂停；未返回可确认的后台页面内容或新截图，因此不能证明MP会话已登录，也没有代设体验版、自动登录或修改隐私设置。没有为绕开该停止而换工具重试UI。

已在不操作后台UI的前提下完成获授权的CLI上传；该UI限制没有被用作停止上传的理由。目前分别记录为“开发版本1.0.7上传成功”和“设为体验版未核实”，不能把两者合并成未经核实的成功，也不能把开发者工具登录状态当作MP后台已登录的证明。

## 未通过项与交付边界

此前真实微信运行的加速度计连续三次返回 `startAccelerometer:fail please go to mp to announce your privacy usage`，说明启动与有界重试执行过，但平台后台用途声明尚未获实际运行验证。用户授权上传不等于授权修改隐私设置；本轮不绕过接口校验、不代填后台声明，也不将该运行拦截作为停止已授权上传的理由。

后台传感器声明、生效版本、iPhone 15 Pro真实手势、持续FPS／P95、温升及最终手机图形效果仍未通过。当前SHAKE7没有新的微信GUI运行验收；清单 `currentWechatRuntimeAcceptancePassed=null` 表示未执行，不能沿用SHAKE6的ANGLE触控结果。原生颠锅、WebGL构建、upload和preview已成功，但上述GUI、体验版及手机边界保持独立。
