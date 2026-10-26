# Unity 迁移验收报告 · 2026-10-23

**Unity Windows 迁移已通过实际编译、构建与运行验收。** 当前主工程为 `projects/catch-big-goose-unity/`，原 Cocos 工程保留。WebGL 与微信小游戏发布尚未验收。

后续微信接入阶段已完成 WebGL 模块、WXSDK 和微信转换构建，开发者工具运行与 iPhone 真机尚待账号条件；独立进度见 [WECHAT.md](WECHAT.md)。本报告中的桌面正式包和哈希记录对应桌面迁移验收时的构建。

## 交付入口

- 根目录 `打开Unity工程.cmd`：启动 Unity 2022.3.62f3、打开 Main 场景、连接本机 MCP。
- 根目录 `开始游戏.cmd`：启动 Windows 正式版。
- 正式游戏：`projects/catch-big-goose-unity/Builds/Windows/catch-big-goose.exe`。分发时须复制整个 Windows 目录。
- 场景：`projects/catch-big-goose-unity/Assets/Scenes/Main.unity`。

编辑器安装于 `D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe`；Unity Hub 位于 `D:/unity/Hub/Unity Hub.exe`。Hub 登录与 Personal 许可证已激活，实际 Unity 编译、测试和构建均返回成功。

## 验收证据

| 项目 | 结果 | 文件（相对工作区根目录） |
| --- | --- | --- |
| Unity 语义编译、五主题资源导入、材质审计 | 通过 | `work/unity-migration/unity-build.log` |
| NUnit EditMode | 10 通过，0 失败 | `work/unity-migration/editmode-results.xml` |
| Windows QA 实际玩家运行 | 86 通过，0 错误 | `work/unity-migration/acceptance/acceptance.json` |
| 五主题视觉复核 | 物件、容器方向、背景、计时、按钮标签正常 | `work/unity-migration/acceptance/*-playing.png` |
| 正式包鼠标操作 | 引导、首页、开局、物件入槽、暂停通过 | `work/unity-migration/release-mouse-pause.png` |
| MCP 与真实编辑器连接 | 48 个工具；Main 场景读取、Play、层级读取、Stop、控制台读取成功 | `work/unity-migration/mcp-verification.json` |
| 资源来源与转换哈希 | 125 项资源与 2 支视频通过 | `work/unity-migration/delivery-verification.json` |
| 50 个模型几何往返 | 尺寸、三角形数量和 UV 检查通过 | `work/unity-migration/geometry-roundtrip.json` |
| 正式程序集排除 QA | 两个开发验收类均未编入正式运行程序集 | `work/unity-migration/delivery-verification.json` |

自动运行覆盖五主题 48 件掉落留存与边界、可用材质、槽位图标、三件消除、移出守恒、打乱守恒与留存、暂停计时、整局胜利；标准关的金鹅和四件冰封、匹配解冻、凑齐道具；两支视频正常速度完整播放及提前关闭不奖励；大师关 82 件与七件冰封、超时复活入口、七格失败与一次救援。自动拾取有显式测试入口绕过深度可见性限制，以验证规则；真实鼠标拾取另由正式包验证。

手动验证使用正式存档消耗的三次机会已恢复，记录见 `work/unity-migration/manual-save-restoration.json`。自动验收使用独立 QA 存档。

## 完成的迁移与修复

- 原生 C# 玩法与 uGUI，五主题、三档难度、七格三消、道具、冰封、金鹅、暂停、成绩、日次数及视频奖励。
- 50 个现有源 GLB 转为原生 FBX；修正导入根节点方向和缩放，重建 Unity 材质，源文件保持不变。
- PhysX 碰撞采用静态容器网格、保护边界与各物件碰撞代理；生成、移出、打乱时避开初始穿插，解决掉出容器及穿底问题。
- 使用可重现的有限三件组库存、频率补偿加权选择、分段加权落点及堆深管理。竞品可确认部分与项目适配范围见 `competitor-analysis/05-Unity接入.md`；这不代表竞品整个生成系统已复刻。
- 两支源视频转换为无 B 帧 H.264 Baseline；无音轨短片不调用不存在音轨的静音接口。奖励依据真实 VideoPlayer 自然结束事件，未伪造结束回调。
- 三个固定道具标签烘焙为透明 UI 图片，解决切换主题时偶发文字缺失；其他文案仍使用中文字体。
- 安装 MCP for Unity 10.3.0 编辑器包与独立 Python 服务端；端点 `http://127.0.0.1:8088/mcp` 仅绑定本机。实际协议返回的服务版本字段为 FastMCP 3.4.11，与插件包版本不同。
- 根目录启动脚本和 npm 的 dev/check/qa/build 已切到 Unity；Cocos 旧命令保留为 cocos:dev、cocos:build、cocos:check，旧文档已保存。

## 验收范围

已验证本机 Windows x64 与 Unity 编辑器。尚未执行 WebGL 构建、微信转换 SDK 接入、AppID 配置、原生广告与微信真机验收。桌面视频奖励为本地短片流程，不是已接入的微信激励广告。

Cocos 原存档不会自动迁入 Unity PlayerPrefs。跨引擎光照与碰撞实现存在差异；没有声称美术效果逐像素一致。

## 复验

关闭该工程的 Unity 编辑器后，在根目录执行 `npm run check`、`npm run qa`、`npm run build`。MCP 复验需先打开编辑器，运行 `tools/unity/mcp-probe.py --play-check`（使用 `D:/开发/tools/unity-mcp-venv/Scripts/python.exe`）；该命令会启动再停止 Main 场景，应在编辑器空闲时执行。

完整安装与资源管线说明见 [README](README.md)。旧的中间失败报告留在工作目录用于追溯，最终汇总以 `delivery-verification.json` 和本报告为准。
