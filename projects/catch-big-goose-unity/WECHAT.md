# 微信小游戏接入与 iPhone 验收

2026-10-26 当前触屏选中版本 **SELECT1** 已完整重建并取得微信平台 `√ preview`：按下高亮、滑动切换、抬手确认，支持取消与生命周期清理。本地发布文件集 28.95 MiB，平台编译后显示 29.4 MB。[本轮手机预览码](../../work/selection-highlight-20261025/wechat-preview.png)与[验收报告](../../docs/development-reports/2026-10-26-touch-selection-highlight.md)。iPhone 15 Pro／Android 触屏及持续帧率仍待真机验证；以下旧码对应各自历史版本。

2026-10-25 23:56 已修复预览 `80051 source size 30753KB exceed max limit 30MB`：改用单线程无损 Brotli、清理旧 Wasm 压缩缓存，本地发布预算预留 512 KiB 给工具编译。当前本地包 29.32 MiB，开发者工具真实返回 `√ preview`，平台总包 31,016,587 字节（显示 29.6 MB）、主包 1,477,954 字节。两支完整视频保留。[新预览码](../../work/wechat-preview-size-20261025/preview.png)、[排查与验证报告](../../docs/development-reports/2026-10-25-wechat-preview-size-fix.md)。本轮未执行手机验收；下列包体与二维码是此前各轮记录。

2026-10-25 最新界面预览已完成完整构建：移除关卡测试显示和进度信息、统一时间与道具图片数字、优化首页按钮动画。指定微信工程已在开发者工具模拟器启动并进入关卡；当前发布文件集 29.77 MiB。数字与货车使用微信专用贴图导入尺寸，原图和两支完整视频均保留。详情见[本轮构建与预览报告](../../docs/development-reports/2026-10-25-wechat-hud-home-preview.md)。本轮未生成手机二维码或执行 iPhone 真机验收；下方包体和二维码属于各自历史记录。

2026-10-25 当前包 **20261025-HOME2-SHAKE3**，保留STICKER2首页：新桌及首页独立灯光、投影，手机摇动只对已有动态可见物件有限施力，修复运动显隐与物理恢复。本地完整导出29.63 MiB，两支完整短片均保留；当前[新预览码](../../work/home-lighting-shake-20261025/home2-shake3-preview.png)、[包审计](../../work/home-lighting-shake-20261025/wechat-package-audit.json)与[实施验收报告](../../docs/development-reports/38-首页桌子光照与表层摇动稳定性.md)。DPR 2、2×MSAA不变；**当前包未连接iPhone 15 Pro，不标记真机性能通过**。下面各二维码和包大小为各自历史记录。

2026-10-25 UI2 当前预览：`../work/ui-quality-20261025/wechat-ui2-preview.png`。修正九宫、插画缩小采样，默认请求 DPR 2 和 2× MSAA，本地包 28.53 MiB。诊断和验收见[第 28 章](../../docs/development-reports/28-UI九宫与真机抗锯齿修正.md)。真机清晰度及帧率仍需扫码确认；下列二维码对应各自历史版本。

2026-10-25 两关与 UI 更新：当前包包含 116 类道具及五主题十关，预览码位于 `../work/two-stage-20261025/wechat-preview.png`。本地导出约 29.08 MiB，开发者工具上传约 28.5 MB；实际值及文件哈希见该目录的 `delivery.json`。本轮已生成预览码，手机端触控、传感器和持续帧率仍需真机确认。下面 R3 的 80 类及旧包尺寸为历史记录。

2026-10-25 当前材质版本 **20261025-R3**：材质／模型／光照迁移管线和微信完整重建已通过，当前 `../../builds/catch-big-goose-wechat` 本地文件总量 **24.87 MiB**，61 个导出 JS 及两支完整奖励短片通过校验。80 件当前主题物件保留 102 个源材质分组，恢复轻量 MatCap、独立透明层和单灯阴影；排除了未使用的旧挑战界面资源，没有缩小源材质或删减短片。首页“对照”确认 **材质版本 R3**，进入关卡后在“暂停 → 关卡画面设置”切换材质、阴影或微信清晰度请求。来源、适配与验收见[第 24 章](../../docs/development-reports/24-材质模型与光照迁移管线.md)及[本轮证据](../../competitor-analysis/evidence/2026-10-25-材质模型光照迁移/验证汇总.json)。iPhone 15 Pro 的实际画布、切档行为与帧率尚未连接验证；下面各 R1／R2 记录和旧二维码均为历史状态。

本次开发者工具 CLI 预览已成功返回 `√ preview`，平台包大小 **24.3 MB**，主包约 **1.63 MiB**；新码见[R3 预览二维码](../../competitor-analysis/evidence/2026-10-25-材质模型光照迁移/wechat/wechat-r3-preview.png)。当前工程已打开。下面旧版本 CLI 失败说明是历史问题，本次成功没有沿用旧二维码，也未上传发布版。

2026-10-24 比例修正已更新为 **20261024-R2**，重新完整构建了 `../../builds/catch-big-goose-wechat`。物件公共尺度、铺放范围与相机占屏关系已调整；首页对照弹窗应显示 **比例版本 R2**，旧码不代表当前包。[比例依据与实际运行验证](../../docs/development-reports/22-场景与物件占屏比例修正.md)区分了竞品存储值、截图估测和项目适配；R2 仍需在用户手机上重新预览确认。

2026-10-24 当前交付 **20261024-R1**：用户已反馈 iPhone 15 Pro 持续卡顿，本轮完成运行成本优化和微信完整重建，导出文件共 29.18 MiB。需重新预览 `../../builds/catch-big-goose-wechat`，确认首页“对照”弹窗标识 R1；可选 126／300 件玩具关，默认显示设备性能行；正式关可在暂停中开启“性能数据”。具体差异、17 局脚本通关、包哈希和仍待连接手机实测的边界见[第 21 章](../../docs/development-reports/21-iPhone持续卡顿与玩具对照.md)。下文模拟器截图与旧二维码属于先前版本，不能用作 R1 真机验收或扫码包。

已完成 Unity 2022.3.62f3 的 WebGL 模块安装、官方 WXSDK 接入及真实 WebGL/Wasm 编译、微信转换。AppID 为 `wx60b50db2472c4782`，微信开发者工具已登录，UnityPlugin 已通过申请并成功载入。**模拟器已真实启动，完成触摸拾取、三消、三种道具、入门关整局通关及暂停恢复；iPhone 真机仍待用户反馈验收。**

插件 `wxe5a48f1ed5f544b7`（UnityPlugin）原先未授权的问题已解决。SDK 初始化返回 200；新增首个可交互画面的 `WX.ReportGameStart()` 上报，已在实际微信运行日志确认。补齐导出的 ES module 编译配置，并在构建脚本中先关闭开发者工具里的本工程，避免转换期间的模板占位 AppID 被热加载。

若后台找不到 SDK 提示中的“能力地图 → 开发提效包 → 快适配”，可先在开发者工具的调试器 Console 中找到“插件未授权使用”日志，点击同行的“添加插件”。这是 [Unity 官方部署手册](https://docs.unity.cn/cn/tuanjiemanual/1.9/Manual/UploadWeixinMiniGame.html) 给出的入口。核对是当前小游戏 AppID 与上述插件提供者，再按页面提示处理；若提示待审核或无可添加插件，保留完整提示继续排查，不把申请提交视为已授权。

2026-10-23 实测：开发者工具将占位 AppID 工程打开为“小程序模式”，控制台提示根目录找不到 `app.json`；重新打开并请求自动化运行时，又显示“更改 AppID 失败 touristappid / Error: tourist appid”。导出配置已是 `compileType: game`，不能通过添加小程序 `app.json` 代替小游戏身份配置。下一步需使用自己的小游戏 AppID 重新转换，再验证平台权限及 Unity 启动；当前错误尚不能证明 Unity 运行代码存在问题。

## 注册你的小游戏

1. 在电脑访问 [微信公众平台](https://mp.weixin.qq.com/)，点击“立即注册”，进入小程序/小游戏注册入口。
2. 使用尚未注册公众平台账号的邮箱，完成激活。按实际情况选择个人或企业主体，完成管理员微信及身份资料验证。
3. 选择游戏服务类目；本项目可以查看休闲游戏子类目，最终以后台可选项为准。
4. 注册完成后，在“开发管理 → 开发设置”（或后台相应开发设置入口）取得自己的 AppID。
5. 微信开发者工具使用该小游戏管理员或已添加的开发者微信扫码登录。

请从公众平台的“立即注册”入口完成注册；开发者工具中的“测试号”按钮生成的接口测试号不能替代本次所需的小游戏账号。

这里只需要 AppID，无须把密码、验证码、AppSecret 交给代码助手。若后台出现快适配/UnityPlugin 权限提示，应在此小游戏账号下按平台提示开通；不能用竞品、别人的 AppID 或普通小程序账号替代。

## 构建与打开

保存并关闭该工程的 Unity 编辑器及微信开发者工具中的旧工程窗口，在工作区根目录执行：

```powershell
./tools/unity/build-wechat.ps1 -AppId 你的小游戏AppID
./tools/unity/open-wechat.ps1
```

以后可用 `npm run wechat:build`、`npm run wechat:open`，或双击根目录 `打开微信工程.cmd`。本机 AppID 配置写入 `projects/catch-big-goose-unity/WeChatBuild.local.json`，该文件已忽略。

AppID/导出封面等配置变化而 C#、资源和编译设置完全未变时，可用 `build-wechat.ps1 -AppId 你的小游戏AppID -ConvertOnly` 复用已编译的 WebGL 文件。改过游戏代码、资源或构建参数时应完整构建。

微信工程目录为 `builds/catch-big-goose-wechat`。开发者工具 CLI 需要在工具“设置 → 安全设置”开启服务端口；账号登录和系统权限窗口须由用户手动完成。

本机此版本开发者工具的 CLI `preview` 曾返回 `undefined (code 10)`，但从工具顶部“预览”按钮已成功生成真实手机二维码并通过平台打包校验。优先使用界面预览；不要把 CLI 返回码 0 当作预览成功。仅生成开发预览，不等于上传体验版、审核或发布。

## 适配内容

- 官方 WXSDK 固定到提交 `915d4bf4f60ef0cd1c29316a8d67257185d609a7`，嵌入 `Packages/com.qq.weixin.minigame`。仅适配缺失的可选 InstantGame 引用和 uGUI 引用，完整来源记录见 `work/wechat-integration/wxsdk-install.json`。
- `GOOSE_WECHAT` 编译标记仅用于微信构建；普通 WebGL 入口会移除此标记。微信 UI 使用官方触摸覆盖，物件拾取直接消费 SDK 已换算过的屏幕坐标，避免重复模拟鼠标点击及点穿按钮。
- 切后台保存并暂停游戏；视频中途退出或切后台不发奖励。回到前台由用户继续。
- 两支原视频保留。另生成 854×480、H.264 Baseline 手机版完整短片，合计约 5 MB，放入按需加载的 `goose-media` 分包；播放前复制到微信用户文件目录的内容哈希缓存，再交给真实 VideoPlayer 解码。不存在假完成回调或默认发奖。
- 完整中文字体保存在 `SourceAssets/Fonts/Chinese-full.otf`，运行字体按当前代码/主题配置裁剪。派生字体为 Goose UI CJK，保留 OFL 与版权信息。新增中文文案后运行 `tools/unity/subset_ui_font.py`；微信完整构建会自动执行。
- 主资源、Wasm、视频分别分包，当前无需开发者自建视频 CDN。实际平台能力、权限和 iPhone 解码行为仍须通过真机确认。

## 本地证据

- `work/wechat-integration/unity-wechat-build.log`：真实 Unity/WebGL 导出日志。
- `work/wechat-integration/package-audit.json`：导出文件总量、61 个 JavaScript 文件语法、分包结构、视频及字体哈希；不是手机运行证明。
- `work/wechat-integration/media-bridge-tests.json`：7 项文件缓存/错误路径单元检查，使用模拟微信文件系统；不是平台验收。
- `work/wechat-integration/font-subset.json`：完整字体与裁剪字体的尺寸、字形数和哈希。
- `work/wechat-integration/simulator-acceptance.json`、`simulator-intro-win.png`：微信模拟器真实交互、15/15 通关、得分 500 的验收记录。
- `work/wechat-integration/devtools-runtime-attempt.json`、`devtools-tourist-appid-error.png`：扫码登录后的实际启动尝试与占位 AppID 错误，尚未进入 Unity 游戏。
- `work/wechat-integration/devtools-appid-attempt.json`、`devtools-test-account-startup-error.png`：用户提供 AppID 后的重新转换、接口测试号识别和模拟器启动失败记录。
- `work/unity-migration/editmode-results.xml`：共享规则/碰撞等编辑器测试结果。

`package-audit.json` 中的文件字节总量不是微信开发者工具最终计算的上传包大小。平台上传校验以开发者工具返回为准。

## iPhone 验收记录（待执行）

小游戏账号和插件权限已就绪。已生成开发预览二维码；扫码后的 iPhone 行为须由用户在真实手机上确认。

| 检查 | 当前状态 |
| --- | --- |
| 开发者工具启动、服务端口 | 已启动并确认 CLI 端口可连接 |
| 开发者工具账号登录 | 已扫码登录，CLI 确认成功 |
| 用户提供 AppID 并重新转换 | 已完成；当前为 wx60b50db2472c4782 |
| 小游戏账号类型 | 工具已识别为小游戏模式 |
| UnityPlugin 权限 | 申请已通过，实际插件加载成功 |
| 模拟器首次进入 | 已成功启动；SDK 初始化 200，首次可交互已上报 |
| 中文 UI、触摸拾取、三消及三种道具 | 已实际点击验证 |
| 模拟器整局与暂停恢复 | 已通过；入门关 15/15、100%、得分 500 |
| 五主题资源与视频播放 | 详见 simulator-acceptance.json 中逐项记录 |
| iPhone 扫描该项目预览码并冷启动 | 待执行 |
| 真机完整一局、暂停/恢复、满槽与结算 | 待执行 |
| 两支视频完整观看各发奖一次，提前关闭/失败/切后台不发奖 | 待执行 |
| 退回微信聊天再返回、重启存档与挑战次数 | 待执行 |
| 设备型号、iOS/微信版本、启动耗时、帧率/内存、日志 | 待记录 |

当前没有上传开发/体验版本、没有公开发布，也没有据此宣称已完成 iPhone 验收。

来源：[官方 WXSDK](https://github.com/wechat-miniprogram/minigame-tuanjie-transform-sdk)、[Unity 2022.3.62f3 官方模块下载页](https://unity.com/releases/editor/whats-new/2022.3.62f3)。
