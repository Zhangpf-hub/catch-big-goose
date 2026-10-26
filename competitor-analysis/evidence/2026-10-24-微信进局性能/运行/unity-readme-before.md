# 抓住大鹅 · Unity 迁移工程

编辑器：Unity 2022.3.62f3。入口：`Assets/Scenes/Main.unity`。桌面运行与 MCP 验收结果见 [迁移状态](MIGRATION_STATUS.md)。

该工程从当前 Cocos 工程迁移自身的五主题资源和玩法，不包含竞品资源。C# 源码位于 `Assets/Scripts`；原 Cocos 工程保留供迁移对照。

## 运行与构建

在工作区根目录执行：

```powershell
./tools/unity/open-project.ps1
```

启动脚本会打开 Main 场景并连接本机 MCP，点击编辑器 Play 即可运行。
也可关闭编辑器后执行 `./tools/unity/open-project.ps1 -Prepare`，自动导入并配置项目。

```powershell
./tools/unity/open-project.ps1 -Tests
./tools/unity/open-project.ps1 -Qa
./tools/unity/open-project.ps1 -Build
./tools/unity/run-acceptance.ps1
```

批处理构建与测试前，先保存并关闭该工程的编辑器。日志位于根目录 `work/unity-migration/`。

Windows 发布包目标：`Builds/Windows/CatchGoose.exe`；验收专用开发包目标：`Builds/WindowsQA/CatchGooseQA.exe`。是否已生成、测试是否通过，以实际构建日志与 `acceptance.json` 为准。

## 迁移内容

- 水果、古玩、农场、甜品、数码五个主题，各九种物件。
- 三档关卡：48 / 54 / 81 个可消物件，255 / 210 / 165 秒。
- 固定种子、频率补偿权重抽样与完整三件组库存；分段加权落点、分帧投放、Unity PhysX 刚体与容器边界。
- 堆深可见性与静止刚体管理，保留深层碰撞支撑；移出和打乱后唤醒。参数在 `Assets/Resources/Data/pile-algorithms.json`，项目适配范围见 `竞品分析/05-Unity接入.md`。
- 七格同类相邻排列、三件消除、满槽失败、残局处理。
- 移出、凑齐、打乱；冰封逐次解冻；金鹅的加时、加分和道具奖励。
- 引导、主题选择、难度选择、暂停、结算、连击、成绩与每日次数。
- 两支本地 MP4，提前退出不发奖，完成播放奖励；首次超时观看复活补时 60 秒。
- Unity PlayerPrefs 使用独立存档命名空间；不会自动读取旧浏览器的 localStorage。

当前是 Unity 桌面与编辑器迁移。WebGL 提供构建入口，需另装 WebGL 模块后实测；微信小游戏发布还需接入微信 Unity 转换 SDK、AppID、原生广告和真机验收，不能把桌面运行通过等同于微信发布通过。

后续微信接入已完成模块/SDK 安装和转换构建，详细进度见 [微信接入与 iPhone 验收](WECHAT.md)。本项目继续使用自有短片奖励流程，未接入微信激励广告。

## 资源管线

`tools/unity/prepare_assets.py` 从现行 Cocos 资源生成主题配置、资源快照与哈希清单；AAC 背景音乐转为 Unity 可导入的 OGG。两支 MP4 经 `convert_videos.py` 转为无 B 帧的 H.264 Baseline；源视频保留，转换前后哈希记录在 `SourceAssets/video-manifest.json`。

`tools/unity/convert_assets.py` 在 Blender 后台将 GLB 转成原生 FBX，保留几何与 UV，导出材质参数和颜色贴图。Unity 导入器重建 Standard 材质；这是材质适配，不承诺 Cocos 与 Unity 的光照像素完全一致。

`SourceAssets/Models` 保留 50 个源 GLB；`SourceAssets/source-manifest.json` 记录来源。运行时读取转换后的资源，不依赖外部 Blender 或 GLB 导入插件。

中文字体来自 Noto Sans CJK，许可见 `Assets/Resources/Fonts/OFL.txt`。原项目模型来源仍按 `cocos/assets/resources/models/CREDITS.md` 与各资源源文件署名说明维护。

微信接入阶段将完整字体移到 `SourceAssets/Fonts/Chinese-full.otf` 作为源文件，运行字体按当前 UI/配置所需字符生成子集并更名 Goose UI CJK，保留版权与 OFL；新增中文文案后应重新运行 `tools/unity/subset_ui_font.py`。

三个固定道具标签由 `tools/unity/bake_control_labels.py` 使用同一中文字体烘焙成透明 PNG，避免动态字体在多次切换主题时丢失字形；其他文案继续使用原生 Text。

## MCP

编辑器插件：MCP for Unity 10.3.0，嵌入在 `Packages/com.coplaydev.unity-mcp`。

服务端使用独立 Python 环境 `D:/开发/tools/unity-mcp-venv`；本机端点为 `http://127.0.0.1:8088/mcp`，仅绑定回环地址。

```powershell
./tools/unity/start-mcp.ps1
```

打开工程后运行菜单 `Goose > Connect MCP`。Codex 用户配置已添加 `mcp_servers.unity`；新聊天或刷新 MCP 连接后才可能出现在工具列表中。当前会话可通过同一个 MCP SDK 直接验证协议和真实编辑器工具：

```powershell
& 'D:/开发/tools/unity-mcp-venv/Scripts/python.exe' tools/unity/mcp-probe.py
```

仅服务端监听不代表编辑器已经连通。验收应包含实例列表以及成功的编辑器工具调用。

来源：[Unity 官方编辑器发布页](https://unity.com/releases/editor/whats-new/2022.3.62f3)、[MCP for Unity 项目](https://github.com/CoplayDev/unity-mcp)、[Codex MCP 配置](https://developers.openai.com/codex/mcp)。

## 验收

编辑模式测试覆盖组数完整、随机重现、同类排序、七格边界与移出守恒。开发包的 `-gooseQa` 验收运行真实模型、物理和玩法，截图与结果写入指定目录：

```powershell
./tools/unity/run-acceptance.ps1 -SkipBuild
```

QA 独立存档，不占玩家次数；两支视频均按正常速度播放，并由实际 VideoPlayer 的自然播放结束事件判定完成。正式发布包不编入 QA 入口。

## 加权生成与深度管理

配置位于 `Assets/Resources/Data/pile-algorithms.json`，`weightedGeneration`、`depthManagement` 默认开启。关闭前者恢复原洗牌和位置抖动，关闭后者恢复全体显示与动态刚体。配置会在启动时加载，修改后需重新运行或构建。

`itemWeights` 影响投放顺序；新增 `groupWeights` 按权重分配完整三件组，前若干项取整、最后一项接收余数。两者均与 `items` 同序，未配置时保留原等量库存。普通物件总数仍为 48 / 54 / 81，冰封与独立金鹅保留，消除后不补货。当前五主题未强套竞品不同物件的权重。

深度隐藏只关闭渲染并限制手动点选，支撑碰撞继续有效；物件稳定后才转为 kinematic。已按场景序列化基线更新为可见深度 0.4–0.5、参考高度 2.1、刚体乘数 0.5、单次下降 0.05、软预算 70；位置值乘 0.1 是本项目尺度选择，不是已测得的世界单位换算。依据和工程保护见 [实际配置研究](../竞品分析/08-实际关卡权重与深度参数.md) 与 [Unity 接入](../竞品分析/05-Unity接入.md)。

本轮实际 Unity 2022.3.62f3 编辑模式 10/10 通过；独立算法开发包 75/75 通过，涵盖五主题库存、隐藏、支撑、重新激活和非等权组数生成／清空。算法包为 `Builds/AlgorithmQA/CatchGooseAlgorithmQA.exe`，与 `WindowsQA` 分开：

```powershell
./tools/competitor/run_policy_tests.ps1 -OutputDirectory work/competitor-20261023-tests
./tools/competitor/run_unity_algorithm_tests.ps1 -OutputDirectory work/competitor-20261023-tests
```

结果写入根目录 `work/competitor-20261023-tests/`；[本轮归档结果](../竞品分析/07-验证结果与后续清单.md) 保留记录和源码哈希。该验收使用无图形开发包，不替代画面、人工点选、移动端性能或微信发布验收。
