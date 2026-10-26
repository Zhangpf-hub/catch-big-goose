# Windows 测试包防火墙免重复授权

日期：2026-10-25。引擎：Unity 2022.3.62f3。

## 原因与证据

用户确认反复出现的是 Windows 防火墙“允许访问”，不是 UAC 管理员提升或 Codex 执行审批。

Development Build 内置 PlayerConnection。修复前的性能测试日志 `work/session-perf-20261025/floor-probe/player.log` 明确记录 TCP 调试端口 55000，以及向 `225.0.0.222:54997` 发送 UDP 发现广播；即使 `player-connection-debug=0` 仍会启动这部分网络功能。QA 脚本依赖 `DEVELOPMENT_BUILD`，不能简单改成正式包。

Windows 防火墙应用规则绑定完整 EXE 路径、不支持路径通配符，详见 [Microsoft 应用规则说明](https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/rules#applications-rules)。本机已有规则同时涉及迁移前 `unity/Builds/...`、迁移后 `projects/catch-big-goose-unity/Builds/...`，以及 `baseline-player`、`perf-player`、`final-player` 等临时副本；每个新路径都可能触发首次监听提示。

## 修复

- 新增 `Assets/Editor/GoosePlayerNetworkPolicy.cs`：所有 Windows Development Build 构建完成后统一设置 `player-connection-multicast=0`、`player-connection-listen-address=127.0.0.1`、`player-connection-ip=127.0.0.1`，以 Listen 模式保留本机 Profiler 连接。使用最后顺序的通用构建回调，覆盖各 QA 构建方法及 Editor UI 构建。
- 新增 `tools/unity/player-network.ps1` 与 `fix-player-network.ps1`，修复已有开发包；操作幂等、保留首次修改前备份、跳过正式包。`npm run unity:network:fix` 批量处理当前 `Builds`。
- 玩法、UI、剧情、材质、算法与两个模型验收入口在启动旧包前补齐配置。AGENTS.md 与本地开发说明明确要求新测试工作区保留钩子、旧包副本在启动前修复。
- 已修复当前 `Builds` 下 18 个开发包，以及 `work/session-perf-20261025` 下 baseline/perf/final 三个可修改副本。参考数据与冻结证据保持原状。
- 无需管理员权限；未修改防火墙、通知、UAC 或 Codex 权限设置。本机三个网络配置的防火墙与监听通知仍全部启用。

需要远程 Profiler 时，在启动 Unity 构建进程前显式设置 `GOOSE_REMOTE_PROFILER=1`，再构建新包，恢复该新包的 Unity 默认网络配置。详见 [本地开发说明](../local-development.md)。本机 Profiler 使用直接地址连接，局域网自动发现不再可用；Unity Editor 自身网络服务不在此 Player 配置范围内。

## 验证

1. Unity 批处理真实重新构建 WindowsQA，退出码 0；构建日志 `work/unity-migration/unity-qa-build.log` 出现 `[GooseNetwork] Local profiler only; LAN discovery disabled`，输出 boot.config 含上述本机限制。
2. 从未授权的新目录 `work/unity-firewall/probe-player` 启动开发包，观察到游戏欢迎界面与 Development Build 标记，没有防火墙提示；重复启动后监听仅为 `127.0.0.1:55000`，没有 UDP 端点。
3. 将本轮新构建包另复制到 `work/unity-firewall/rebuilt-player`，运行真实算法验收。双实例期间新进程仅监听 `127.0.0.1:55001`；两个全新路径均未生成任何防火墙应用规则。日志与验收报告位于 `work/unity-firewall/acceptance`。完整算法套件退出码 1：100 项通过、32 项玩法断言失败（包含旧的 81+金色物件数量、冰冻分配、配额与遮挡断言），不能记为完整玩法验收通过；本轮只修改 PlayerConnection 配置和测试启动／构建入口，没有修改玩法实现，未扩展修复这些算法断言。
4. PowerShell 解析通过；重复修复两次的 boot.config 哈希不变；正式包 boot.config 哈希不变。
5. 执行 `npm run structure:check`：42 项中仅微信 SDK 临时 `Builds/WeChat/minigame` 残留检查失败；文档无新增断链。该目录已有 19:15:05—19:15:23 的导出文件，早于本轮 WindowsQA 构建启动时间 19:15:41。本轮未处理该独立微信导出状态。

本修复验证基于当前安装的 Unity 2022.3.62f3 原生 Player 实际端点；升级引擎后应重新检查监听地址及广播行为。旧冻结包若要测试，先复制到可修改目录，再运行指定 PlayerPath 的修复命令。
