# Catch Big Goose · 抓鸭子

统一工程标识为 `catch-big-goose`。使用 Unity 2022.3.62f3 开发，再通过微信 SDK 导出小游戏。

| 目录 | 内容 | 使用方式 |
| --- | --- | --- |
| [projects/catch-big-goose-unity](projects/catch-big-goose-unity/README.md) | 当前 Unity 源工程 | Unity 打开此目录；入口 `Assets/Scenes/Main.unity` |
| [builds/catch-big-goose-wechat](builds/README.md) | 当前微信小游戏导出工程 | 微信开发者工具导入此目录 |
| [reference-projects](reference-projects/README.md) | 历史 Cocos 工程、网页原型、竞品参考资源 | 独立保留，供对照研究 |
| [competitor-analysis](competitor-analysis/README.md) | 竞品研究、证据与分析产物 | 查阅算法和来源边界 |
| [source-assets](source-assets/README.md) | 模型候选、UI 原件、源视频 | 美术加工输入 |
| [docs](docs/README.md) | 项目规范、开发计划、实施与验收报告 | 查阅工程说明 |
| `tools/` | 启动、构建、资源加工和研究脚本 | 从工作区根目录执行 |
| `tests/` | 自动验证与测试夹具 | 配合对应检查命令 |
| `work/` | 本项目临时构建、日志和历史验收输出 | 不是微信导入目录 |
| `skills/` | 项目专用工作流 | 模型处理规范 |

## 打开和测试

- 双击 `打开Unity工程.cmd`：打开当前 Unity 工程并连接本机 MCP。
- 双击 `打开微信工程.cmd`：打开当前微信小游戏工程。
- 双击 `开始游戏.cmd`：启动已有 Windows 正式包。
- 微信开发者工具中的工程名为 `catch-big-goose`，目录名为 `catch-big-goose-wechat`，AppID 为 `wx60b50db2472c4782`。

```powershell
npm run dev               # Unity 编辑器
npm run check             # Unity 编辑模式测试
npm run build             # Windows 构建
npm run wechat:build      # Unity 编译、微信转换并更新导出工程
npm run wechat:open       # 微信开发者工具
npm run wechat:check      # 微信视频桥接检查
npm run structure:check   # 目录、入口、名称与文档链接检查
```

修改玩法、场景、模型和 UI，应修改 Unity 源工程，再重新构建。`builds/` 为生成结果，下一次构建会更新。SDK 内部的 `minigame` 仅作为转换中间目录，成功后自动移到命名明确的微信导出目录。

旧 Cocos 命令保留为 `npm run cocos:dev`、`npm run cocos:build`、`npm run cocos:check`；网页原型只作历史参考。

当前游戏和验收状态见 [开发报告索引](docs/README.md)，微信接入及真机限制见 [微信工程说明](projects/catch-big-goose-unity/WECHAT.md)。目录迁移不会把旧模拟器记录等同于当前真机验收。

命名和路径对照见 [项目结构规范](docs/project-structure.md)。可供工具读取的路径清单位于 [workspace.json](workspace.json)。
