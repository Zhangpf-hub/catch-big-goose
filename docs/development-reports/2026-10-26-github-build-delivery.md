# GitHub 构建包交付（2026-10-26 08:41，北京时间）

- 仓库：`Zhangpf-hub/catch-big-goose`，私有。
- 包体源码版本：[468e926](https://github.com/Zhangpf-hub/catch-big-goose/commit/468e92656aac61700dc6edcdea97a1d38ee45f83)。
- 下载：[GitHub Release](https://github.com/Zhangpf-hub/catch-big-goose/releases/tag/build-20261026-084136-468e926)。
- Unity：2022.3.62f3；运行时标识：`20261026-SIZE1-SURFACE1-SHAKE5`。
- 构建方式：从指定提交导出独立源码快照，保留 SDK 所需本机依赖及 `GoosePlayerNetworkPolicy`；两个正式包来自同一快照。构建期间其他会话的后续修改不会自动进入这两个包。

| 附件 | 压缩包大小（MiB） | SHA-256 |
| --- | ---: | --- |
| `catch-big-goose-windows-468e926.zip` | 106.27 | `b63eaa8265ff48e70ab51127e11947fa39ab8149a2de28ae551a1257bae0cf04` |
| `catch-big-goose-wechat-468e926.zip` | 25.39 | `fcb8d627a859f87a6448a009496898dbe7b18a06ef01ed4da6e6fd2b00c93c89` |
| `catch-big-goose-validation-468e926.zip` | 0.01 | `fd11a28cdbb61c5074541fc442eeb4fb9113eb5b6c191065c107b143caf5b7d9` |

Release 另提供 `build-manifest.json` 和 `SHA256SUMS.txt`；三个 ZIP 均已通过解压 CRC 完整性检查。

## 验证结果

- 构建前工程目录结构检查：43 项通过，未发现新增失效文档链接。
- 固定源码快照的 Unity EditMode 测试：64/64 通过，失败 0，跳过 0。
- 构建目录中的 106 个运行脚本、插件及 Data JSON 已与指定 Git 提交逐字节核对一致。
- Windows 正式构建成功；运行所需 EXE、UnityPlayer、Mono 和游戏数据均已包含；正式包未开启 PlayerConnection，也未包含开发验收类。
- 微信本地导出审计通过，发布文件集 26.06 MiB，61 个 JavaScript 文件通过语法检查；Wasm、数据分包、两支完整视频及字体哈希已核对。
- 微信视频缓存桥接 8 项、原生视频生命周期 7 项本地检查通过。这些检查使用模拟 API。
- 本轮未执行微信平台预览打包、手机真机验收或 Windows 交互验收；本地构建成功不等于这些验收已通过。

## 使用

1. 下载并解压 Windows ZIP，运行 `catch-big-goose-windows/catch-big-goose.exe`，保留整个目录。
2. 下载并解压微信 ZIP，在微信开发者工具导入 `catch-big-goose-wechat`；工程名为 `catch-big-goose`，使用工程配置中的现有 AppID。
3. 使用 `SHA256SUMS.txt` 校验下载文件。`validation` ZIP 包含测试 XML、本地微信包审计、视频桥接检查和本轮构建/打包脚本。

源码及本报告随 `main` 提交；二进制包体通过同一私有仓库的 Release 附件保存，继续遵守构建产物的 Git 忽略规则。
