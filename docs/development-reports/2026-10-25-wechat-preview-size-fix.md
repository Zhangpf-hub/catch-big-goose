# 微信预览 80051 包体超限排查

## 原因与复现

微信开发者工具 Stable 2.01.2510290 对当前 `builds/catch-big-goose-wechat` 预览返回 `80051, source size 30753KB exceed max limit 30MB`，CLI 实际复现相同错误。不是 AppID 或登录失败。

此前本地按 `project.config.json` 排除规则统计为 31,215,589 字节（29.77 MiB），只剩 241,691 字节预算。开发者工具编译、转换与打包后的平台口径不同，本地低于 30 MiB 不能证明可预览。旧报告的本地检查结论不构成平台预览通过。

SDK 当前开启 `CompileOptions.brotliMT`。SDK 自带设置说明指出该模式提高出包速度但降低压缩率；本项目没有使用 Wasm 代码拆分，应使用单线程 Brotli 压缩提高压缩率。

排查期间还短暂观察到导出目录包含一份 `catch-big-goose-wechat/` 同名嵌套工程，其数据包为 `41aca28bca03df29`、Wasm 为 `bd9520ef1ec6686c`。该次预览返回 60837KB，属于重复输出导致的额外问题；不将这次结果作为 source map 开关的对比实验。后续验证要求不存在嵌套工程。

## 修改

- `GooseWeChatBuild` 强制单线程 Brotli，保留原始资源、模型、纹理和两支完整视频。
- 转换前清理 SDK 可重建的 Wasm 压缩缓存。命名导出发布后 SDK 内部 `minigame` 已移出，SDK 无法从旧 `unity-namespace.js` 读取压缩模式，可能把旧多线程缓存误认为单线程；必须重新压缩，保证文件与解码器一致。
- 发布配置关闭 `uploadWithSourceMap`，只影响上传诊断信息；不以此宣称已单独验证缩包效果。
- 本地发布预算改为 29.5 MiB，预留 512 KiB 给开发者工具编译（本次实测差值约 270 KiB）。平台上限仍按 30 MiB 记录，平台预览仍是最终校验。
- 构建及包审计拒绝包含多份 `project.config.json` 的嵌套工程；审计额外核实单线程解码标志与发布配置。

## 验证

微信开发者工具 CLI 真实返回 `√ preview`，二维码生成成功。本轮只生成开发预览，没有上传发布版。

| 指标 | 结果 |
| --- | ---: |
| 最终本地发布文件 | 30,740,983 字节（29.32 MiB） |
| 微信平台实际总包 | 31,016,587 字节（工具显示 29.6 MB） |
| 微信平台主包 | 1,477,954 字节 |
| 数据分包 | 20,030,426 字节 |
| 视频分包 | 5,165,126 字节 |
| Wasm 分包 | 4,343,081 字节 |
| 平台总包剩余空间 | 440,693 字节（约 430 KiB） |

- 最终包审计 18 项通过，61 个 JS 语法检查通过，两支移动视频与源视频哈希核对通过。
- 单线程 Brotli 解压后的数据与 Wasm 分别与本轮 Unity 编译输入逐字节一致。记录见 `compression-integrity.json`，不是重采样或删减资源。
- `npm run wechat:check`：8 项媒体桥接、7 项原生视频生命周期检查通过。
- `npm run structure:check`：43 项检查通过，无新增断链。
- 最终构建脚本经 Unity 2022.3.62f3 重新编译验证，退出码 0，见 `editor-compile.log`。

本轮完整 WebGL 编译与转换已经完成，但最初采用的 29 MiB 中间预算阻止了自动发布。根据平台编译差值约 270 KiB，最终将本地预算定为 29.5 MiB，预留 512 KiB，并重新编译脚本验证；已完成的包通过最终预算审计后发布到唯一命名目录。`full-build.log` 的最后退出码 1 对应中间预算，不把它描述为最终自动构建退出码 0。

发布时 Windows 占用了导出目录句柄，目录整体重命名失败。关闭工程后将旧目录内容逐项归档至 `previous-export/`，再复制审计通过的新内容；完整转换输出另存 `completed-export/`，未把一份工程嵌套到另一份工程中。

开发者工具还缓存了旧数据包名 `1f322789b3d3ed25`，导致新文件已经存在时仍报旧路径 ENOENT；清理文件/编译缓存及 `reset-fileutils` 未解决，退出工具并重新启动后，实际预览成功。重启后界面出现项目作者信任提示，本轮未自动点击安全提示，也不宣称完成新包模拟器或手机运行验收；平台上传预览与二维码生成已独立通过。

当前二维码：[preview.png](../../work/wechat-preview-size-20261025/preview.png)。平台返回：[preview-info.json](../../work/wechat-preview-size-20261025/preview-info.json)。

证据目录：`work/wechat-preview-size-20261025/`。`before-preview.log` 为原始错误复现，`before-files.json` 为修复前文件哈希清单；`without-source-map-preview.log` 的 60837KB 结果受到嵌套导出影响，不能用作开关效果证据。
