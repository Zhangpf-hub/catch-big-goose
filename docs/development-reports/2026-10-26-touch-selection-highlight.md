# 触屏选中与竞品高亮迁移

实施于 2026-10-25 至 2026-10-26，Unity 2022.3.62f3。源码已接入，Windows 实际渲染验收与微信完整构建通过，新手机预览码已取得平台 `√ preview` 成功结果。iPhone 15 Pro／Android 微信真机验收仍待执行。

## 现在的交互

按下物品显示黄色覆盖、黑色描边和外发光；保持按住可滑到另一件物品切换高亮，抬手拾取当前预览目标。滑到空白清除高亮，滑回可重新选中；滑入 UI、移出游戏视口或收到触摸取消则取消整次手势。第一根有效手指拥有手势，其他手指不会抢选或重复拾取。

抬手只提交已预览且仍有效的物件，结束坐标命中其他物品时取消，避免没有显示过高亮便拾取。暂停、后台、目标隐藏／停用、程序化拾取、重开、回收和结算均清理状态。现有入槽、重排、三消、暂存和道具仍使用生产路径。首页触摸互动保留独立的原有点击规则。

核心接口为 `BeginPointer / MovePointer / EndPointer / CancelPointer`，只读目标为 `CurrentSelectedItem`；微信订阅 Start／Move／End／Cancel，沿用 SDK 已转换的屏幕坐标。桌面鼠标也使用按下预选、抬起确认。`Pick` 和 `PickAtScreenPosition` 保留供程序化调用。

## 迁移方式与边界

竞品依据、Shader 恢复及参数详见[触屏选中与高亮管线研究](../../competitor-analysis/21-触屏选中与高亮管线.md)。恢复了冻结 402 包实际引用的两个组件和 Profile，并从压缩程序提取 19 个 Shader 的 44 段完整 GLSL。主／次 WASM 分析模块各恢复 66／39 个方法体并通过结构验证。

- 迁移当前 Medium 分支的八方向扩展、GPU 实例化、覆盖三角波、发光正弦变化、深度／模板测试与遮挡透视着色。覆盖 .5、描边宽 .2、发光强度 1.86／宽 .25 按源公式换算，淡入淡出为零。
- 独立效果材质与 Shader 叠加在原模型上，基础材质、MatCap、贴图、UV、缩放和碰撞体保留。保留一个运行时效果材质，不逐帧创建材质。
- 平滑法线使用独立缓存网格，并在移动端释放原网格 CPU 数据前准备。当前目标的蒙皮使用复用的 BakeMesh 容器和法线列表。
- 透视着色使用恢复出的公式；被挡像素通过 GPU 深度判定，替代原插件周期性 CPU 遮挡粗筛。按住物品没有额外冻结／抬升物理；该部分沿用项目现有逻辑。因此是有明确适配边界的转写，没有宣称逐像素完整复原原插件。

生产入口见[统一输入](../../projects/catch-big-goose-unity/Assets/Scripts/GooseGame.Selection.cs)、[高亮组件](../../projects/catch-big-goose-unity/Assets/Scripts/GooseSelectionHighlight.cs)、[专用 Shader](../../projects/catch-big-goose-unity/Assets/Resources/GooseSelectionHighlight.shader)。资源包含独立 `.mat`、源参数 JSON 及稳定 GUID。微信 Release 包保留了 8 个 GLES3 内部 Shader 程序，包括实例化变体。

## 本地验收

| 检查 | 结果与证据 |
| --- | --- |
| 最终编辑模式测试 | 57/57，[XML](../../work/selection-highlight-20261025/editmode-final.xml) |
| 真实播放器选中验收 | 122/122，[报告](../../work/selection-highlight-20261025/native-r4/acceptance.json) |
| 原有拾取、入槽、三消、暂存与满槽回归 | 61/61，[报告](../../work/selection-highlight-20261025/interaction-final/interaction.json) |
| 微信媒体桥接与原生视频协议 | 8＋7 项通过，使用模拟微信 API，不是手机视频实测 |
| 微信最终文件审计 | 通过，[报告](../../work/selection-highlight-20261025/wechat-package-audit.json) |
| 目录与链接检查 | `npm run structure:check` 通过 |

122 项验收包括真实生产接口、快速释放、结束坐标变更、多指、UI、后台、隐藏／回收、五主题及原材质完整性；四主题中的透明附件、五主题中的多材质模型均有实际截图。当前主题资源中的 FBX 可为静态烘焙结果，蒙皮分支另外用带权重和骨骼变形的 SkinnedMeshRenderer 夹具验证，未将其冒充竞品原模型的动画复原。

截图：[早餐选中](../../work/selection-highlight-20261025/native-r4/breakfast-selected.png)、[透明附件](../../work/selection-highlight-20261025/native-r4/breakfast-transparent.png)、[玩具选中](../../work/selection-highlight-20261025/native-r4/toys-selected.png)、[蒙皮夹具](../../work/selection-highlight-20261025/native-r4/breakfast-weighted-skin.png)。

15 组 300 件场景采样覆盖空闲、持续按住和滑动切换，采样段 GC 回收均为 0，反复切换没有增加材质数。桌面 RTX 3070 Ti 上，选中提交平均约 .078–.188 ms，实例化后额外模型提交为 5–20 次，另有两次模板清理。

这些样本使用隐藏 Windows QA 窗口和复用的离屏 MSAA 目标显式渲染生产相机。原始整帧计时保留了玩具／杂货滑选 P95 约 66／771 ms 的异常，尚未归因，不能据此证明手机持续 30 FPS，也没有据此删减高亮效果。真机还需采集完整 CPU／GPU、帧率与内存数据。

旧交互验收脚本在满槽触发复活弹窗后使用缩放时间等待，因暂停而卡住；本轮只修正该验收脚本为实时等待，并检查复活弹窗与拒绝复活后的结算，生产复活规则没有因此修改。初轮构建目录冲突后改用本轮独立快照，保留 `GoosePlayerNetworkPolicy`，Windows QA 使用本地 PlayerConnection。

复跑命令：`powershell -File tools/unity/run-selection-acceptance.ps1`。构建、旧尝试和临时资源都位于 `work/selection-highlight-20261025`，原始参考数据未修改。

## 微信交付与真机入口

当前正式导出目录为 `builds/catch-big-goose-wechat`，工程名 `catch-big-goose`，AppID `wx60b50db2472c4782`。

- 已完整重建 WebGL／Wasm，并同步项目最新的 Release 打包管线：单线程 Brotli、JS 空白压缩、诊断 source map 上传关闭、排除未使用的旧首页资源。当前源码与验收使用的实际运行代码一致。
- 本地发布文件集 **30,359,546 字节／28.95 MiB**，低于保留 512 KiB 工具编译余量的 29.5 MiB 门槛。
- 微信平台实际预览成功：**30,791,889 字节／工具显示 29.4 MB**；主包 1,477,936 字节。两支完整视频仍在媒体分包中，材质与贴图没有为压包被缩减。
- [新手机预览码](../../work/selection-highlight-20261025/wechat-preview.png)、[平台结果](../../work/selection-highlight-20261025/wechat-preview-info.json)、[预览日志](../../work/selection-highlight-20261025/wechat-preview-release.log)、[最终文件哈希](../../work/selection-highlight-20261025/published-file-hashes-final.json)。

前一版 29.78 MiB 文件集曾在平台编译后超过上限，失败记录保留；最终二维码对应重新打包并通过平台校验的版本。旧导出已备份。发布时处理了开发者工具的目录占用，最终对命名导出目录与构建结果逐文件比对了哈希。

手机扫码后验收：长按可见物品、跨物品滑动、空白滑回、抬手确认；再检查多指、按钮区域、后台恢复和重开清理。iPhone 15 Pro 与 Android 的这组真实触屏操作、持续帧率、GPU 时间和内存均标记为**待真机验证**；平台预览成功不等于上述项目已经通过。
