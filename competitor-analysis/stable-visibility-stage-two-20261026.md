# 稳定显隐、手机摇动与真实第二关链复核

日期：2026-10-26。本文对应用户反馈“下层持续闪显隐、第二关摇不起来”。竞品证据来自本地冻结 402 包及既有提取；项目部分是本轮生产修改前的只读源码审计。未运行竞品手机、Unity 或 UI，未改原始包、冻结 WAT、既有失败报告。当前阶段只确定证据边界和复现设计，不能据此宣布用户手机问题已解决。

## 竞品已证实的分工

### 显示和物理分别决定

- [CheckVisible / j10885](evidence/2026-10-23-配置与模式/方法与调用图/j10885.annotated.wat) 第 13–25 行读取物件 Transform 世界位置，取 Y，与 `GetDynamicVisibleHeight(index,1)` 比较，再调用 `SetVisible`。该函数内没有摄像机覆盖射线，也没有读取其他物件当前 Renderer 状态作为显隐依据。
- [SetVisible / j7288](evidence/2026-10-23-配置与模式/方法与调用图/j7288.annotated.wat) 第 25–34 行切换 `col` 子物体并写 `isHiding`；第 45–59、74–88 行先比较主 Renderer／SkinnedMeshRenderer 的 `enabled`，变化时才写入；第 99 行调用显示动画，第 101–125 行处理附属 Renderer。此函数没有把整个库存根物体统一停用，也未在这里修改 `realCol`。
- [CheckAllRigidAndVisible / j22259](evidence/2026-10-23-配置与模式/方法与调用图/j22259.annotated.wat) 第 58–80 行分别调用 `CheckRigid`、`CheckVisible`。[CheckRigid / j6450](evidence/2026-10-23-配置与模式/方法与调用图/j6450.annotated.wat) 第 17–30、95–115 行经另一深度倍率调用 `HideRigid`。[LoopOptimization / j74002](evidence/2026-10-23-配置与模式/方法与调用图/j74002.annotated.wat) 第 47–64 行周期刷新最高高度及两类状态；等待对象来自 TimerManager，不能仅凭此段认定固定刷新秒数。

因此，可借鉴的是独立、稳定的显隐与物理资格。不能把“复刻”解释成全部物品渲染、全部物理激活，也不能把渲染隐藏等同于移除必要的下层支撑。

### 手机物理链不等于打乱道具动画

| 入口 | 冻结证据与精确位置 | 已确认的行为 |
| --- | --- | --- |
| 手机加速度回调 | [j95011](../work/r4-interaction-20261025/competitor/j95011.annotated.wat) 第 110–153、341–405 行；[CanShake / j21513](../work/r4-interaction-20261025/competitor/j21513.watfrag) 第 2–9 行；[AddForce / j14312](../work/r4-interaction-20261025/competitor/j14312.watfrag) 第 9–15、35–40 行 | 按回调时间和 fixedDeltaTime 修正力，遍历时先 `CanShake`，再 `AddForce`；两层均检查非 kinematic，不主动解冻下层。 |
| 普通打乱 `ToolMessUp=2` | [UseTool / j10876](artifacts/competitor-runtime-trace/primary-methods/j10876.annotated.wat) 第 1255–1265 行；[MessObjRotaAnim / j73982](artifacts/competitor-runtime-trace/primary-methods/j73982.annotated.wat) | 调用局部选集、冻结、公转及旧位置换位链。`ToolShake=6` 是相邻的另一分支。 |

`MessObjRotaAnim` 的当前冻结文件可直接核对：

1. `j73982` 第 87–165 行先刷新高度，选 `item.y > maxHeight - messHeight` 且非 `isStore` 的物件，并 `HideRigid(true,true)`。此处未明确要求原先动态、可见；项目“只影响原已激活可见表层”是额外收紧，须继续保留。
2. 第 175–255 行保留旧世界位置和可见标志，第 260–305 行打乱物件顺序，第 310–423 行把物件与旧位置配对后 `InitRota`。
3. [InitRota / j41506](artifacts/surface-activation-20261026/j41506.annotated.wat) 第 2–16 行关闭 `col`、`realCol`，其余部分保存共享中心、目标位置及速度。[RotaAnim / j41503](artifacts/surface-activation-20261026/j41503.annotated.wat) 第 13–39 行取共享中心及 up，第 83–94 行 `RotateAround`，随后以 `Clamp01(2*deltaTime)` 向目标 Y 逼近。这是公转，不能只描述成每件原地自转。
4. `j73982` 第 738–754 行调用 `MoveToTargetPos(.3)` 并等待 .3 秒，第 784–786 行 `RotaToPos(1)`；第 876、886、897 行恢复 scale，重新 `CheckVisible`、`CheckRigid`，第 919 行恢复控制。

场景序列化值见 [LevelManager.json](artifacts/competitor-config-trace/serialized-verified/LevelManager.json) 第 2288–2301 行：`messHeight=4`、`messRotaTime=1`、旋转速度 540–720、距离倍率 1.2–.15。这些是竞品场景单位。方法映射、WAT 来源行号及方法体 SHA-256 见 [提取索引](artifacts/surface-activation-20261026/index.json)。上述动画落位的当前行号是 740、786、886、897、919；旧报告的近似段落号应以当前冻结文件为准。

没有证据证明竞品手机回调会调用这条打乱动画，更没有证据证明手机每次都做固定 360° 翻面。当前项目 SHAKE7 的约 .9 秒受控颠锅，是针对用户可见效果与夹持场景的项目适配，不能称为逐行复刻竞品手机物理链。也未取得竞品当前线上热更、同一 iPhone 15 Pro 运行轨迹或持续帧率。

## 项目真实第二关及尚未覆盖的窗口

本节行号对应本轮只读源码，后续修改后应按方法名重新定位。

- [GooseGame.Flow.cs](../projects/catch-big-goose-unity/Assets/Scripts/GooseGame.Flow.cs) 第 12–15 行：首页正常开始先设 `Difficulty=0`；第 18–27 行：完成教学后等待 .7 秒，再设 `Difficulty=1`、`BeginRound()`。这是同主题从 15 件教学关进入 300 件挑战，不能拿 `ThemeIndex=1` 代表第二关。
- [ThemeRoundCatalog.cs](../projects/catch-big-goose-unity/Assets/Scripts/ThemeRoundCatalog.cs) 第 17–30 行按 `stageIndex+1` 选 profile。[theme-rounds.json](../projects/catch-big-goose-unity/Assets/Resources/Data/theme-rounds.json) 的第二关早餐／烧烤／乡村／杂货为 150、60、45、45 件四层，玩具为 240、30、30 件三层；均共 300 件。当前 [level-tuning.json](../projects/catch-big-goose-unity/Assets/Resources/Data/level-tuning.json) 的 overrides 为空。
- [GooseGame.cs](../projects/catch-big-goose-unity/Assets/Scripts/GooseGame.cs) 第 268–280 行清理旧局、取消摇动／动画并重置深度；第 338–345 行采用准备好的新容器；第 353–399 行在揭示前分类，最后同步设 `SpawnComplete=true`、`Depth.SpawnFinished(true)`、`Depth.RefreshNow()`。源码不支持“第二关始终未执行激活”的直接断言。
- [GooseShakeController.cs](../projects/catch-big-goose-unity/Assets/Scripts/GooseShakeController.cs) 第 76–92 行接受请求并固定 `CopySurface` 快照、设 `pending=true`，第 28 行 `Active=pending||tracking`；第 101 行在下一 Fixed 再执行 `CanShake` 过滤。虽然深度组件 [GoosePileDepth.cs](../projects/catch-big-goose-unity/Assets/Scripts/GoosePileDepth.cs) 第 7 行执行顺序为 -100，但第 161–188 行在 `Shake.Active` 时锁定表层／遮挡查询，第 192–193 行也跳过物件的显隐与物理重新分类。因此正常接受请求后，深度刷新不会在下一 Fixed 自行撤销其 SurfaceActive／冻结状态。**此前仅依据 Fixed 顺序提出的“资格可能被深度刷新清空”假设已被该保护排除，不作为生产修复理由。**第 119 行调用受控 helper；helper [GooseSurfaceShuffle.cs](../projects/catch-big-goose-unity/Assets/Scripts/GooseSurfaceShuffle.cs) 的 `BeginInternal` 再核验存活、容器及表层资格。后续筛除仅需审计显式拾取、回收／失活、外部改状态等生命周期变化；不能把合法的失效检查当成已证实缺陷。
- [GooseWeChatPlatform.cs](../projects/catch-big-goose-unity/Assets/Scripts/GooseWeChatPlatform.cs) 第 126–143 行按 Playing、Paused、SpawnComplete、AppVisible 管理监听；转关期间不满足条件会停监听，新局完成后重启。第 146–170 行为每次尝试注册代次保护的回调并调用 `StartAccelerometer(interval="ui")`，失败最多重试三次；第 179–187 行注销原 delegate、清状态并停监听。直接调用 `Shake.Sample` 的 Native 测试绕过真实 SDK 停启、授权及回调到达链。

现 [SurfacePerformanceAcceptance.Open](../projects/catch-big-goose-unity/Assets/Scripts/GooseSurfacePerformanceAcceptance.cs) 第 128–136 行确实 `SelectDifficulty(1)`，所以测试配置是第二关；但它直接入局并 `Settle(3)`，跳过用户的真实自动转关和刚完成揭示的首摇。[FlowAudioAcceptance](../projects/catch-big-goose-unity/Assets/Scripts/GooseFlowAudioAcceptance.cs) 有 15→300 自动转关检查，后续摇动主要验证音频，不能替代逐目标抛高、翻转、落稳与下层不动的效果验收。

## 闪显隐的当前代码风险与最小复现

[GoosePileDepth.ProbeCovered](../projects/catch-big-goose-unity/Assets/Scripts/GoosePileDepth.cs) 第 300–308 行会命中碰撞体，但仅将 `cover.DepthVisible` 为真的其他物件作为遮挡者。显隐判定因而依赖上一状态的显隐结果。第 184–186 行还按不同周期缓存覆盖结果，第 223–232 行有立即显示、延迟隐藏处理。该反馈与竞品 `j10885` 独立高度判断不同；它足以构成静态物堆显隐振荡的审查对象，仍需固定几何的长期逐物件 trace 证实，而非凭静态阅读宣布唯一根因。

建议先完成以下可复现证据，再安排生产修改：

1. 从真实首页入口完成同主题 15 件，等待自动进入 `Difficulty=1 / Total=300`，不直接调用第二关入口。记录 cold／cached 准备、容器代次、模型尺寸、seed、SDK start/stop 代次、回调计数。
2. 在 SpawnComplete 第一个可交互帧及其后 .1、.5、3 秒分别摇动；记录 Request 候选 ID、下一 Fixed 保留 ID、helper 接受／规划／首个可见位姿／完成／失败时间及明确原因。若数量变化，须对应显式拾取或对象失效记录，不预设深度分类竞争。另覆盖连续拾取后首摇、暂停恢复和再次自动转关。
3. 固定几何与相机，对长期静止第二关记录每件 visible/held/surface 状态转换及相邻遮挡者；保持下层 kinematic、gravity=false、支撑 collider 不变。可在独立 QA 中比较不依赖当前 Renderer 状态的几何遮挡结果，确定是否存在状态反馈。
4. Native 的 synthetic sensor 可证明控制器和受控轨迹；真实微信必须另核 `StartAccelerometer` 成功、回调实际到达、门禁通过及 helper 完成。已知旧包／旧进程和曾出现的隐私声明错误只能列为待排分支；未经用户入口或新日志确认，不能当作本轮根因。

若复现证实显隐反馈，最小调整是去掉以当前 Renderer 状态决定遮挡资格的循环依赖，并保留稳定状态、迟滞和查询预算；不以全渲染或全动态掩盖问题。摇动方面先补真实微信 start/stop 代次、原始回调、Request 拒绝原因及 helper mode/tossFailure 诊断；仅在复现证实生命周期或规划失败后修相应环节，不基于已排除的 Fixed 分类假设改第二关摇动，不先加大力度、不增补下层、不降低落位或净位移门槛。当前无证据要求再次更改 .9 秒颠锅幅度。

## 附录：真实微信拒绝与电脑入口差异

本轮 baseline 的五主题真实 15 件点击消除→自动 300 件→同帧合成 sensor 已通过，说明该固定播放器的流程和合成输入可执行。它不经过 iPhone 硬件、微信 SDK 启动及隐私校验，不能据此宣称手机已恢复。

### 加速度计后台声明与用户同意是两层条件

[实际微信 r5 验收记录](../work/mobile-surface-performance-20261026/wechat-runtime-r5-acceptance.json) 明确记录：已清 15 件、自动进入 300 件、打乱道具完成，但 `sensorStartupAllowed=false`，启动错误为 `startAccelerometer:fail please go to mp to announce your privacy usage`。[SHAKE6 报告](../docs/development-reports/mobile-surface-shake6-20261026.md) 记录三次有界重试均拒绝。它是历史微信 DevTools Windows ANGLE 运行事实，不是新 SHAKE7 或 iPhone 实测。

官方主源分别说明：

- [隐私类型对应表](https://developers.weixin.qq.com/miniprogram/dev/framework/user-privacy/miniprogram-intro.html)：后台类型“调用你的加速传感器”对应 `wx.startAccelerometer`。[填写说明](https://developers.weixin.qq.com/miniprogram/dev/framework/user-privacy/) 给出用户隐私保护指引配置入口。对本项目须核对 AppID `wx60b50db2472c4782` 的该项用途以及已审核生效的声明版本，不能只核对工具登录账号。
- [隐私接口指引](https://developers.weixin.qq.com/miniprogram/dev/framework/user-privacy/PrivacyAuthorize.html)：未声明对应信息时接口会被禁用；后台声明与客户端用户同意不是同一件事。后台业务用途草稿可为“识别玩家摇动手机的动作，驱动当前表层物品重排”，最终内容必须真实并由有权限者确认。本轮没有进入或修改后台。
- [小游戏 requirePrivacyAuthorize](https://developers.weixin.qq.com/minigame/dev/api/open-api/privacy/wx.requirePrivacyAuthorize.html) 是可选的提前授权辅助接口，不是后台声明替代品；没有注册自定义隐私监听时，可走平台统一授权弹窗。2026-10-26 本轮再次只读请求该官方页面，HTTP 200，页面仍包含上述说明。
- [小游戏 getPrivacySetting](https://developers.weixin.qq.com/minigame/dev/api/open-api/privacy/wx.getPrivacySetting.html) 的 `needAuthorization=false` 也可能表示后台未声明任何收集类型，不能作为“声明与同意都通过”的单一证据。

项目实际 SDK 在 [Packages/com.qq.weixin.minigame/Runtime/WX.cs](../projects/catch-big-goose-unity/Packages/com.qq.weixin.minigame/Runtime/WX.cs)：第 2104–2110 行说明统一弹窗与辅助接口可选，第 2123–2125 行转发 `RequirePrivacyAuthorize`，第 2581–2583 行转发 `StartAccelerometer`。[当前 game.json](../builds/catch-big-goose-wechat/game.json) 的渲染／子包配置不能代替 MP 后台用途声明；本轮未发现项目注册自定义隐私同意处理。不能通过增加一个虚构的 `scope.accelerometer` 字段、模拟同意或只加 RequirePrivacyAuthorize 来修复后台未声明错误。

官方原文、抓取 URL、HTTP 状态和 SHA-256 已保存于[主源索引](../work/mobile-surface-performance-20261026/wechat-privacy-official-source-index.json)。当前后台实际声明内容、生效版本、用户是否已同意以及新手机启动结果仍未知。最小可执行顺序是先核对正确 AppID 生效的加速传感器用途，再用新包真实记录 `start_success → first_callback → sensor shake_accepted → helper completed`；若实际变成用户未同意的错误，再处理真实授权交互。当前不需要以修改物理、扩大激活集合或绕开权限作为补救。

### 多个电脑入口确有不同二进制，但用户窗口归属仍未知

本轮仅只读进程、磁盘 DLL 与快捷方式元数据，没有关闭或启动这些程序：

| 入口／文件 | 实际观察 | 不能推出的结论 |
| --- | --- | --- |
| 工作区 `projects/catch-big-goose-unity/Builds/Windows/catch-big-goose.exe` | 观察时 PID 1676 来自该路径；同目录 `CatchGoose.Runtime.dll` 内嵌 SHAKE5，SHA-256 `6a222a816f9db73f1a1dc77fe0d58a89c9097712d95c7010db042ecf2c1ff9bd` | 未确认用户反馈时正在操作此窗口，不能直接归为旧包问题。 |
| 桌面 `catch-big-goose-shake7/catch-big-goose_Data/Managed/CatchGoose.Runtime.dll` | 内嵌 SHAKE7，SHA-256 `02b6cc4ded75eac67aadfd892e9fa123e80e0b0b5aebe898c1c2c93961e6955b` | 桌面存在该文件不证明该文件正在运行，也不证明体验版已切换。 |
| 本轮 baseline 固定播放器的同名 DLL | 内嵌 SHAKE7，SHA-256 `e442a029ce0434b4981ef134dec1dadbe0a8304111456fa67e50e38557c76673` | 同一 BuildId 可有多个修订，须同时绑定文件哈希和输入快照。 |
| `AppData/LocalLow/GooseStudio/catch-big-goose/Player.log` | 当前保存日志含 SHAKE4 | 旧 Player.log 不一定对应正在运行的进程，不能仅用它给用户当前版本定性。 |
| 桌面“抓大鹅.lnk” | 指向腾讯游戏中心，参数 AppID 为竞品 `wxb98ac240fd74b0e3` | 此快捷方式不是本项目 AppID，也不证明用户点击过它。 |

[上传回执](../work/mobile-surface-performance-20261026/shake7-upload-receipt.json) 证明本项目开发版本 1.0.7 上传成功，但 `experienceVersionSelected=null`；[交付清单](../work/mobile-surface-performance-20261026/final-delivery-shake7.json) 的当前微信运行验收仍为 null。版本确认须先取得实际入口及对应新会话日志，不能把开发版上传、桌面归档、体验版选择和当前运行窗口混为一谈。

### 固定播放器的通用回归入口

新增 [run-stability-regressions.ps1](../tools/unity/run-stability-regressions.ps1)，以 `BuildName` 指定 `work/stable-visibility-stage-two-20261026/<BuildName>/player`，只运行该固定播放器，不构建或复制生产源。支持 matrix、fallback、interrupt、toss、clip、interaction、selection；输出保留在同一 build 的新目录中，已有目录直接拒绝覆盖。

执行前只读校验 PlayerConnection 为本地回环，拒绝现场改写固定输入；正式运行记录完整播放器逐文件 SHA-256，结束后再次核对，并保存命令上下文、独立进程退出码、超时和验收报告。超时只终止该 runner 自己启动的进程。示例：

```powershell
powershell.exe -NoLogo -NoProfile -File tools/unity/run-stability-regressions.ps1 -BuildName fixed-r1 -RunName acceptance-1 -Part matrix
powershell.exe -NoLogo -NoProfile -File tools/unity/run-stability-regressions.ps1 -BuildName fixed-r1 -RunName toss-1 -Part toss -Theme 0 -Stock 300
```

本轮仅完成 PowerShell 语法解析与 `-DescribeOnly` 参数预览，没有借该 runner 启动构建或 QA。其 synthetic 结果边界与上述硬件边界相同。

## 补充复核：下层晋升与摇动集合不能混为同一合同

1. **已证实是按当前状态刷新，并非“只有拾取才晋升”。** [LoopOptimization / j74002](evidence/2026-10-23-配置与模式/方法与调用图/j74002.annotated.wat) 第28行检查 manager 的 offset56锁，未锁时第45、48行依次更新最高高度、全部物件刚体与可见性；[j22259](evidence/2026-10-23-配置与模式/方法与调用图/j22259.annotated.wat) 第56、66行分别调用 CheckRigid、CheckVisible。[CheckRigid / j6450](evidence/2026-10-23-配置与模式/方法与调用图/j6450.annotated.wat) 第17–30行判断世界Y和动态阈值，结合scale条件后第94／101行分别请求冻结／解冻。[HideRigid / j4344](evidence/2026-10-23-配置与模式/方法与调用图/j4344.annotated.wat) 第20–42行有既有状态、选择／存放等保护，第45–89行对非强制冻结保留速度0.2保护。因此已知晋升与高度、scale和保护状态有关；尚不能从这些方法证明所有模式的完整晋升时机或只有某种操作才能晋升。
2. **固定集合的直接证据属于付费打乱动画。** [MessObjRotaAnim / j73982](artifacts/competitor-runtime-trace/primary-methods/j73982.annotated.wat) 第74行置manager offset56锁，第87–165行一次选出上层物件并保存 canMessObj，后续动画遍历该保存集合；第886／897行在结束阶段重新检查可见性／刚体，第909行解除锁。这里证实的是 ToolMessUp 的固定局部选集；其原始筛选不等同于本项目更严的 SurfaceActive／可见／动态三重资格。
3. **手机回调只证明“当次给当前动态集施力”，未证明整个手势固定快照。** [手机回调 / j95011](../work/r4-interaction-20261025/competitor/j95011.annotated.wat) 第341–405行在每次回调遍历当前库存；[CanShake / j21513](../work/r4-interaction-20261025/competitor/j21513.watfrag) 第2–9行、[AddForce / j14312](../work/r4-interaction-20261025/competitor/j14312.watfrag) 第9–15行均检查非kinematic。现有证据不能声称后续回调绝不会纳入已自然晋升的动态物件。**本项目手机摇动固定接受时原surface快照、下层不受摇动，是用户明确提出的更严格合同；不能借“复刻竞品”扩大集合或放开本轮 lowerViolations=0 要求。**该说明不裁定玩具61次违规采样的生产或QA根因。
