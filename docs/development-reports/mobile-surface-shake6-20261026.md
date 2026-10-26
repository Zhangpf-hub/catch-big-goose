# 摇动落稳重排修复（SHAKE6）

日期：2026-10-26。目标设备：iPhone 15 Pro。状态：r5原生统一包、微信真实触控及渲染复测、平台预览上传通过；手机摇动被后台传感器用途声明拦截，等待用户配置生效与真机验收。

用户确认旧包卡顿改善，但摇动仍像抖一下。根因之一是接触夹持：力已施加，物品短暂移动后回到原槽。验收因此同时检查落稳后的水平净位移，不能只统计瞬时抬升、最大位移或动画播放次数。

本轮延续[分层与摇动实施计划及独立审批](../development-plans/mobile-surface-performance-20261026.md)和[竞品研究](../../competitor-analysis/normal-mode-surface-activation-20261026.md)。此前参数与失败记录见[SHAKE5阶段报告](mobile-surface-shake5-20261026.md)。原始竞品证据保持完整。

## 当前修复

保留自然受力优先；一次手势固定接受时已激活的表层集合，不从下层补足数量。接受的双峰信号保留峰值，首物理步提供水平反馈，前0.14秒在累计预算内补偿被接触抵消的抬升。

若0.65秒后不足半数原目标保留至少0.12倍模型尺度的水平净位移，尝试一次短局部换位。该路径复用安全落位检查，公转约0.3秒、落位约0.25秒，总手势不含暂停最多2.3秒。它是本项目对夹持场景的适配，不是已证实的竞品手机回调行为。

手机换位只接收原容器、原轮次的目标引用；不重扫、显露或解冻下层，不消费、退款或累计任何道具使用次数。活跃期间新手势不能覆盖原集合。取消、暂停和跨局恢复独立检查。普通重排道具保持自身收费与退款逻辑，单目标仍不可用。

单目标手机换位只尝试0.2—0.3倍模型尺度的邻位，必须通过实际碰撞、稳定支撑与容器检查。无安全落点或超时记真实失败并恢复，不将取消计为完成。

单目标按实际刚体姿态重建局部碰撞形状，避免插值后的显示姿态污染规划；落点对静态支撑保守向上避让，从邻域最高支撑上方执行重心五点稳定性检测。此几何修正已使原倾斜夹具落稳通过，没有实施额外的25°落面姿态调整。

表层曝光保留0.72外环并增加0.30内环，共17点，补足中心与外缘被遮挡、内侧仍真实露出的情形。活动高度带不变，每件最多34次查询，每次分类硬上限仍256；不通过扩大下层活动范围补足数量。

微信传感器启动失败后，每个连续监听周期最多尝试三次，失败后分别退避0.5秒和1秒。每次监听按请求代次隔离旧回调；暂停、离关和后台取消重试，回到需要监听的新周期才重置次数。真实微信条件分支编译通过，27项受控C#回调状态机检查通过；它们不能代替SDK运行或手机输入实测。

完整回归还发现本轮引入的一处道具动画回归：为手机模式参数化时长后，Unity Mono保留的 `1f + .3f` 中间精度大于存入float的末帧时间，导致结束条件无法满足。实际Unity Mono探针复现原逻辑150帧仍不结束；统一预存float时长后39帧完成。修复仅统一时长计算并使用0.0001秒数值容差，没有加长原超时预算。失败矩阵及探针保留，旧夹具成功不代表这处回归通过。

## 验收状态

最终统一QA包的[夹持与生命周期夹具](../../work/mobile-surface-performance-20261026/fallback-0-release-shake6-r5/surface-acceptance.json)完成110项检查、零错误：夹持三目标和单目标落稳后均保留水平位移，自由三目标不启用兜底；下层位姿与重力、手机路径道具计数、暂停／回首页／跨局恢复和不足时间拒绝均通过。重复拒绝检查随帧数变化，不以固定110次作为功能条件。早期失败证据保留。

同一二进制的[五主题矩阵](../../work/mobile-surface-performance-20261026/matrix-release-shake6-r5/surface-acceptance.json)已完成95行、2906项检查、零错误；300件强输入、普通输入和道具的15组独立曝光覆盖均100%，未暴露下层违规合计0，查询峰值253。普通输入最终XZ达标数依次为4/4、8/11、11/16、14/21、11/18。矩阵中的19次解卡兜底来自按钮行，均完成；不能称为19次真实手机手势。独立夹具另验证了合成传感器触发兜底。

66项Unity编辑测试通过，包含内侧开口、全覆盖34次查询和总预算回归；[交互回归](../../work/mobile-surface-performance-20261026/interaction-release-shake6-r5/interaction.json)61项、[点选高亮回归](../../work/mobile-surface-performance-20261026/selection-release-shake6-r5/acceptance.json)122项通过。逐文件路径、大小、SHA256清单证明各次运行使用相同QA程序。完整Assets、Packages、ProjectSettings源清单与复制快照匹配，并记录原生构建及导出阶段输入变化。

[生产相机GIF](../../work/mobile-surface-performance-20261026/clip-0-release-shake6-r5/shake-moderate.gif)、[六帧对照](../../work/mobile-surface-performance-20261026/clip-0-release-shake6-r5/shake-frame-sheet.jpg)及[实际帧时间](../../work/mobile-surface-performance-20261026/clip-0-release-shake6-r5/clip-timing.json)来自33张合成1.6g输入后的原始帧，显示蒸笼转向、横移和落稳布局变化。拍摄不用于性能采样，也不是iPhone录屏。

五主题300件静置时，可见件依次72／111／123／86／75，动态表层6／12／20／20／18，醒着刚体均为0。桌面强制移动档的33.33ms限帧不证明手机FPS。最大规划切片实测7.8948ms；2ms只是让出执行的检查目标，单个原子步骤可超出，不能写成严格2ms上限。Wasm及手机尖峰仍需实测。

当前BuildId为 `20261026-SIZE1-SURFACE1-SHAKE6`；同标签不代表同修订，交付时需同时记录源码、Wasm、数据包和完整导出文件集哈希。Windows强制移动档和合成1.6g输入不能代替iPhone真实传感器、持续帧率或温升验证。

## r4实际微信运行发现

Wasm完整编译与包体审计通过，发布候选26.06 MiB，实际开发者工具SDK初始化返回200、首页正常、真实触控完成三消。但触控高亮出现GLSL链接错误 `X3067: 'uint_ctor': ambiguous function call`，继而内部变体失败及DrawMesh无效pass。构建日志确认六个pass和八个GLES3程序均保留，不能归因于变体被裁剪。[实际Console文本](../../work/mobile-surface-performance-20261026/wechat-runtime-candidate-r4-console.txt)和[r4文件身份清单](../../work/mobile-surface-performance-20261026/candidate-r4-evidence/delivery-verification.json)保留。

独立Agent批准仅将清理三角形的混合整型位运算替换为显式浮点索引分支，保持原顶点、六个pass、模板状态、八方向与实例化。此Shader-only修补需重新构建并在相同ANGLE环境实测，不能以原生通过替代。

同次运行三次启动加速度计均返回 `startAccelerometer:fail please go to mp to announce your privacy usage`。这说明请求和重试已执行，但微信未允许传感器接口；用户已被询问该AppID后台用途声明是否生效。未绕开校验或代改隐私设置，也未将此状态标为真实手机摇动通过。

后台官方项目为“调用你的加速传感器”，对应 `wx.startAccelerometer`；在该AppID的“账号设置 → 服务内容声明 → 用户隐私保护指引 → 去完善”填写并核对已审核生效的声明版本。用途业务草稿为“识别玩家摇动手机的动作，驱动当前表层物品重排”。可选客户端 `requirePrivacyAuthorize` 不能解除后台未声明拦截，且 `getPrivacySetting.needAuthorization=false` 也可能表示后台未声明，不能据此判定授权通过。[官方填写说明](https://developers.weixin.qq.com/miniprogram/dev/framework/user-privacy/)、[小游戏接口说明](https://developers.weixin.qq.com/minigame/dev/api/open-api/privacy/wx.getPrivacySetting.html)及[主源归档索引](../../work/mobile-surface-performance-20261026/wechat-privacy-official-source-index.json)。

## r5实际微信复测与交付

相同Windows ANGLE环境实际完成拖动、白杯及鸭子连续点选、15件全部消除、自动进入300件正常关，并使用一次表层重排道具。布局发生可见横向换位，落稳后保留新布局，库存从1减至0；控制台渲染错误为0，旧GLSL链接和无效pass错误未再出现。六个pass、八方向和实例化没有删除。记录见[微信运行验收](../../work/mobile-surface-performance-20261026/wechat-runtime-r5-acceptance.json)及[实际界面错误计数](../../work/mobile-surface-performance-20261026/wechat-runtime-r5-ui-summary.txt)。

该开发者工具还存在准备阶段的kinematic速度设置警告，不能写成“零警告”。自愿开启监测后的最后9条可见记录显示约26.55—26.71 FPS、P95 40—41ms，实际缓冲区1170×2532；这与原生390×844强制移动档不同，不能把配置中的DPR调用值当成最终缓冲区证据，也不能据此宣称手机30FPS目标已经通过。监测时可见47件、动态表层11件、醒着0件、恢复中0件、穿底纠正0、受保护隐藏违规0；此为重排后的单个Windows场景，不是五主题真机数据。[原始监测记录](../../work/mobile-surface-performance-20261026/wechat-runtime-r5-monitor.json)。

预览上传CLI返回成功，平台编译后27,757,887字节（显示26.5MB），低于30MiB上限。本地完整导出为27,325,827字节；未排除活动Wasm、数据或视频来绕预算。[预览码](../../work/mobile-surface-performance-20261026/shake6-r5-preview.png)仅可在后台声明生效后用于手机摇动验证，当前传感器仍被平台拒绝，不能标记为可用摇动已验收。

完整发布文件集与验收导出逐文件一致，发布前包已备份。原生与导出输入仅场景重新生成fileID、微信SDK编辑器配置发生阶段变化；脚本、JSON、物理资源、模型、材质和贴图保持。Wasm标识 `d788bf9f5ed4d629`，SHA256 `b65dd816c2c3b31ea799042eb591af3d287c2a2da1c58434d530a65619eeb20c`；数据标识 `90fb31fa1c150bd0`，SHA256 `9363a5daab9972a0231d1cc7a0083d86b50a82839d6645f59bbb7d022af9d3e4`。此Shader-only修订与r4的Wasm相同而数据不同，再次说明仅BuildId或Wasm不足以识别版本。

[最终交付清单](../../work/mobile-surface-performance-20261026/final-delivery-r5.json)绑定二维码、平台编译信息、源码输入、原生文件集、完整发布文件集及Wasm／数据哈希。[Windows发行候选](../../work/mobile-surface-performance-20261026/release/catch-big-goose.exe)在work内，不覆盖用户正在使用的旧播放器。目标保持未完成，余项为后台声明生效、iPhone 15 Pro真实手势及持续性能验证。
