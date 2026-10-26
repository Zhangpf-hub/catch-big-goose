# 本地开发说明

当前工程是 `projects/catch-big-goose-unity/`，编辑器为 **Unity 2022.3.62f3**。

双击 `打开Unity工程.cmd` 打开工程；双击 `开始游戏.cmd` 启动 Windows 正式版。

- Unity Editor：`D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe`
- Unity Hub：`D:/unity/Hub/Unity Hub.exe`
- 场景：`projects/catch-big-goose-unity/Assets/Scenes/Main.unity`
- MCP：`http://127.0.0.1:8088/mcp`；打开工程脚本会启动服务并连接编辑器。
- 服务端 Python：`D:/开发/tools/unity-mcp-venv/Scripts/python.exe`

运行与构建命令见 [Unity 说明](../projects/catch-big-goose-unity/README.md)，状态见 [迁移验收报告](../projects/catch-big-goose-unity/MIGRATION_STATUS.md)。

## Windows 测试包与防火墙

QA 包保留 Development Build 和自动验收脚本；`GoosePlayerNetworkPolicy` 在每次 Windows 开发包构建后关闭 PlayerConnection 的局域网广播，并将调试监听限制为 `127.0.0.1`。因此复制包、更换输出目录和重新构建都不需要再次允许防火墙访问。本机 Profiler 可通过 `127.0.0.1:55000` 手动连接（端口冲突时以日志／实际监听端口为准）。

已有测试包可执行 `npm run unity:network:fix` 修复当前工程 `Builds` 下的包；指定临时副本使用：

```powershell
powershell.exe -NoProfile -File tools/unity/fix-player-network.ps1 -PlayerPath 'work/example-player/CatchGooseQA.exe'
```

常用自动验收入口会在启动旧包前补齐配置。修复脚本只修改开发包的 `boot.config`，首次修改前保存 `boot.config.before-local-network`。冻结证据需先复制到可修改的测试目录，不能在原件上运行修复。

确实需要其他设备连接 Windows Player 的 Profiler 时，在构建 Unity 进程启动前设置 `GOOSE_REMOTE_PROFILER=1`，再构建新包；该包恢复 Unity 默认网络行为，可能需要防火墙许可。该变量不会撤销已有包的本机限制，已有包需重新构建或从备份恢复。Unity Editor 自身的网络服务不属于此 Windows Player 配置。

迁移前的 Creator、Node.js、Python 与 Jolt 环境保留，历史操作见 [旧本地开发说明](../reference-projects/catch-big-goose-cocos/LOCAL_DEVELOPMENT_LEGACY.md)。
