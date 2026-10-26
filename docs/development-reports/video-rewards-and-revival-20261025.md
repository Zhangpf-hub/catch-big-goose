# 鸭子甩卖货车、视频奖励与首次失败复活

日期：2026-10-25。Unity 2022.3.62f3；当前工程 `projects/catch-big-goose-unity`。

## 最终玩法

正式第二关在有效游玩 120／300／480 秒分别以 80%／50%／50% 概率检查出车，每个时点只抽一次。检查使用独立随机源，不影响关卡生成。加载、暂停、切后台和看视频期间不计时；复活加时不重置已经检查的时点。第一关、参考试玩与模型评审不插入货车。

奶白 B2 鸭驾驶黄蓝货车从右向左经过，三段行驶共 6 秒，中间两次各停留 2.5 秒；停车时车轮停止转动。点击货车直接看视频，完整播放后移出、凑齐、打乱各加一个，并显示图标入账动画。错过或关闭视频均不强制弹出广告；领取后车辆驶离，每趟只发奖一次，后续时点仍可检查。

每关开局三种道具各一个，正式关卡改为按库存使用，领取后可在同一关继续使用，不跨关保存。暂存栏仍为三个位置；存在暂存物品时暂不允许再次移出，不扣道具，避免新库存规则造成溢出。

首次满槽或超时共享一次视频复活机会。失败先冻结并显示选择，不提交最终失败成绩；完整看完才消耗机会。满槽将前三件退回物堆，并在原剩余时间上加 300 秒；超时恢复 300 秒；不限时关卡继续不限时。取消、后台中断或播放失败后仍可重试，主动结束或复活后再次失败才结算。最后一组三消与超时冲突时先结算已经提交的三消。

两个入口共享 `Darkchaser-Battletide.mp4` → `Skycore-Reboot.f5800.mp4` 轮播；本次运行从第一支开始，完成播放后才推进。播放请求与当前关卡绑定，重开、返回首页及重复回调不会重复发奖。微信沿用原生视频层，Windows 沿用真实 VideoPlayer；没有引入微信广告变现 SDK。

## 实现与美术

- 策略配置：[video-rewards.json](../../projects/catch-big-goose-unity/Assets/Resources/Data/video-rewards.json)。状态机独立于画面，集中处理领取、取消、待复活及回调失效。
- 流程：[GooseGame.Rewards.cs](../../projects/catch-big-goose-unity/Assets/Scripts/GooseGame.Rewards.cs)。保留当前点选高亮、鸭子音效及微信播放修复。
- 货车：[GooseSaleTruck.cs](../../projects/catch-big-goose-unity/Assets/Scripts/GooseSaleTruck.cs)。透明车身含 B2 司机，车轮为独立 Sprite，文字由 Unity 绘制。
- 原图、完整提示词、切片范围与哈希：[reward-truck-v1](../../source-assets/ui/reward-truck-v1/)。采用内置 image_gen，参考已有 B2 母模；切片只裁切矩形，保留原始 alpha，没有改动参考母模。
- 竞品证据与适配边界：[局内甩卖与视频复活](../../competitor-analysis/22-局内甩卖与视频复活.md)。原始 402 表和冻结证据保持原样。

## 验证

- 全量编辑测试：57/57 通过，包含 13 项奖励检查及当前点选几何检查。
- 微信视频协议：媒体分包 8 项、原生视频生命周期 7 项通过，覆盖自然结束、取消、错误和旧回调隔离。
- 真实 Windows 视频与玩法回归：最终集成 123 项通过，真实完整播放三次，覆盖两支视频、三个奖励场景、取消、解码失败、切关、重复调用、再次使用道具和最后一组三消与超时冲突；包含三比例、模拟刘海安全区、两次停车及错过后自然退场。
- 补充验收与交付结果以 [delivery.json](../../work/video-rewards-20261025/delivery.json) 为准；三比例、刘海安全区、完整货车经过和最终集成录像见同一清单。

首次运行保留在 `work/video-rewards-20261025/runtime`：111 项通过，唯一未通过的检查以墙钟时间等待停车。录制截图会增加墙钟耗时，而货车按有效游玩时间移动；验收改为等待车辆自身时间，第二轮通过。没有通过改快车辆动画来绕过检查。

旧模型预算检查的口径同时修正：冻结原模型按原模型表核对，当前原创鸭子按独立材质和三角形预算核对；凸包顶点数按几何位置去重，并检查不超过 255 三角形。没有修改任何模型、碰撞网格或冻结预算表。

## 使用与重跑

- Windows 当前入口：[catch-big-goose.exe](../../projects/catch-big-goose-unity/Builds/Windows/catch-big-goose.exe)。微信当前导入目录：[catch-big-goose-wechat](../../builds/catch-big-goose-wechat/)。
- 运行 `powershell.exe -NoProfile -File tools/unity/run-reward-acceptance.ps1` 可重新构建开发包并执行回归；`-SkipBuild` 复用开发包。
- 验收器只编入开发包，以独立 CompanyName 与 QA 存档隔离；正式版没有演示调试入口。Windows QA 保留本机 PlayerConnection，未请求防火墙授权。
- 演示使用实际 Unity 渲染帧及实际采集时间编码，缩短的是等待出车时间，广告完整播放；录像无音轨，不将其描述为手机屏幕录制。

完整演示：[货车、领道具与两类复活](../../work/video-rewards-20261025/runtime-integrated/reward-flow-demo.mp4)。也可分别查看 [货车完整经过](../../work/video-rewards-20261025/runtime-integrated/truck-pass-demo.mp4)、[甩卖领取](../../work/video-rewards-20261025/runtime-integrated/sale-demo.mp4)、[满槽复活](../../work/video-rewards-20261025/runtime-integrated/tray-revive-demo.mp4) 和 [超时复活](../../work/video-rewards-20261025/runtime-integrated/timeout-revive-demo.mp4)。

Windows 与微信冻结压缩包、实际文件哈希、包体大小及最终检查数列于交付清单。微信沿用工程当前单线程 Brotli 与 512 KiB 编译预留预算，额外使用已有 esbuild 只压缩导出 JS 的空白，不重命名变量、不改视频或贴图。压缩过程与包检查日志保留在交付目录。

当前微信导出目录被文件句柄占用，不能整体重命名；包含旧文件清理的发布命令另被自动审批以 `blocked by policy` 拒绝。最终采用保留旧文件的复制方式，逐文件核对新导出字节，并在 `project.config.json` 中逐项排除过期 `.br` 文件；它们未被删除，冻结微信 ZIP 只收录当前导出。

Windows 播放、静态微信协议及构建检查不等于 iPhone／Android 真机验收。本轮没有上传或发布线上版本，仍需在实际手机上复测微信原生视频、生命周期和触控。
