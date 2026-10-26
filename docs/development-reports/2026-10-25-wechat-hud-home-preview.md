# 微信新版 HUD 与首页动画构建预览

日期：2026-10-25。Unity 2022.3.62f3，实际导出目录 builds/catch-big-goose-wechat，工程名 catch-big-goose，小游戏 AppID wx60b50db2472c4782。

## 结果

完整执行 WebGL/Wasm 编译、微信 SDK 转换、包体检查及发布到指定 builds 目录。最后一次构建退出码 0。已通过微信开发者工具 CLI 打开同名工程，在实际小游戏模拟器观察到首页，点击开始进入关卡，验证图片数字、不限时符号、三类道具角标、暂停及返回首页。

包体按 project.config.json 发布排除规则计算为 31,215,589 字节，即 29.77 MiB，低于 30 MiB 限额。61 个 JavaScript 文件语法检查通过；两支完整视频及其源文件的哈希检查通过。主界面 60 FPS／移动关卡 30 FPS 的策略已编译进当前包；本轮没有测量或据此宣称微信真机帧率。

## 构建修复

首次构建遇到另一个聊天正在接入的奖励功能：主脚本已调用新接口，而实现文件尚未齐全。未回退或覆盖其修改，待接口和素材写入后重新构建。本包包含构建当时已经写入且可编译的奖励流程；该功能的完整视频、复活和结算验收由对应开发工作单独记录。

新增原始贴图使导出首次达到 34,652,339 字节，超过项目预算。针对手机 DPR 2 的实际显示尺寸设置 WebGL 专用导入覆盖：

| 资源 | 保留的原图尺寸 | WebGL 最大边长 | 格式 |
| --- | --- | ---: | --- |
| 金色数字图集 | 1448×1086 | 512 | RGBA32 |
| 货车车身 | 1490×642 | 512 | RGBA32 |
| 独立车轮 | 282×282 | 256 | RGBA32 |

数字约 112 px 高的导入字形覆盖手机上约 74 px 高的计时显示，货车导入宽度也覆盖约 460 px 的手机显示宽度。保持透明通道、mipmap、三线性采样；没有编辑原始图片，也没有缩短或移除视频。桌面导入设置维持原有高分辨率。

Unity 没有仅因导入器代码变更就重导入缓存中的三张贴图，因此在 GooseWeChatBuild 中增加构建前的定向 ForceUpdate / ForceSynchronousImport，确保配置实际进入后续导出。

## 验证与记录

- npm run wechat:build：最终成功。
- npm run wechat:open：CLI 确认 open，窗口标题 catch-big-goose，小游戏模式。
- audit-wechat-package.py：15 项本地包检查通过，61 个 JS 文件无语法错误，媒体哈希一致。
- npm run wechat:check：8 项媒体缓存桥接、7 项原生视频生命周期检查通过；这两项使用模拟 API，不等同于真机播放。
- npm run structure:check：43 项结构检查通过，无新增损坏链接。
- WebGL 导入下的数字切片专项验证：1/1 Passed，见 sprite-tests-final.xml、sprite-tests-final.log；覆盖 0–9、冒号、不限时符号、单个与多位数量及布局边界。
- 模拟器界面已确认主菜单、精简 HUD、图片数量、暂停与返回首页；截图展示于本轮对话的 Windows 窗口工具结果。
- 未生成新的手机预览二维码，未上传体验版、审核或发布。iPhone 等真机性能与完整播放仍需实际设备验证。

证据目录：work/wechat-ui-preview-20261025。final-build.log 是本次最终构建日志，package-audit.json 和 final-package-files.json 是包审计，package-hashes.json 记录数据包与 Wasm 哈希。失败尝试日志和超预算清单也保留在该目录，便于追踪包体优化。
