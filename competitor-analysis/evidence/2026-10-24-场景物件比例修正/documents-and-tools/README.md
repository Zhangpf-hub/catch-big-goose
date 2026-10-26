# 抓住大鹅 · Unity 迁移工程

编辑器：Unity 2022.3.62f3。入口：`Assets/Scenes/Main.unity`。桌面运行与 MCP 验收结果见 [迁移状态](MIGRATION_STATUS.md)。

2026-10-24 当前比例版本 **R2**：普通物件基础尺度至少 0.70，玩具同为 0.70；三种窄生成范围扩到 1.72，取消随生成层号向中心收缩。相机按屏宽及容器近沿适配，物件更大、容器贴近栏位，短屏另有高度兜底。库存和权重不变。微信新导出仍在 `Builds/WeChat/minigame`，重新预览后首页“对照”弹窗应显示 **比例版本 R2**。依据和实际画面对照见[第 22 章](../竞品分析/22-场景与物件占屏比例修正.md)；下面 R1 记录保留为上一轮状态。

该工程从当前 Cocos 工程迁移自身的五主题资源和玩法。正式五主题使用自有模型；按用户要求新增独立的 21 件竞品玩具模型本地对照关，仅用于几何、辨识和性能比较。原提取来源保留在 `references/competitor-goose`。C# 源码位于 `Assets/Scripts`；原 Cocos 工程保留供迁移对照。

2026-10-24 性能版本 **R1**：合并复杂物件网格／材质、普通物件减面、独立低面容器接触网格、局部物理唤醒、30 Hz 移动物理档与遮挡缓存；补充大小区别。首页左上“对照”可进入 126／300 件玩具关；正式关在“暂停 → 性能数据”开启 FPS／可见数／活动刚体统计。当前微信导出为 `Builds/WeChat/minigame`，需重新预览并确认弹窗显示 R1。详细证据与尚未完成的 iPhone 验收见[第 21 章](../竞品分析/21-iPhone持续卡顿与玩具对照.md)。

2026-10-24 交互更新：点选使用原 3D 模型飞入七格栏，同类物件平滑挤位，到位后再聚拢消除与结算；开局在隐藏稳定后自底逐层长出，显示结束才开始计时。资源缓存、物件池和离线凸包继续使用。参数证据、项目适配、实测与真机边界见[拾取入槽与逐层出场](../竞品分析/20-拾取入槽与逐层出场.md)。

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

- 水果、古玩、农场、甜品、数码五个主题，各 21 类物件。
- 三档关卡：15 / 60 / 300 个可消物件；配额、分层和深度配置见 `Assets/Resources/Data/pile-algorithms.json` 及[第 15、16 章](../竞品分析/15-三消单局核心算法与调优.md)。
- 固定种子、频率补偿权重抽样与完整三件组库存；分段加权落点、分帧投放、Unity PhysX 刚体与容器边界。
- 堆深可见性与静止刚体管理，保留深层碰撞支撑；移出和打乱后唤醒。参数在 `Assets/Resources/Data/pile-algorithms.json`，项目适配范围见 `竞品分析/05-Unity接入.md`。
- 七格同类相邻排列、三件消除、满槽失败、残局处理。
- 移出、凑齐、打乱及独立暂存栏；核心对标档关闭额外冰封和单只金鹅奖励，旧分支保留。
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

`itemWeights` 影响投放顺序；新增 `groupWeights` 按权重分配完整三件组，前若干项取整、最后一项接收余数。两者均与 `items` 同序，未配置时保留原等量库存。当前核心档总量为 15 / 60 / 300，每主题 21 类；核心档使用 coreGroupWeights，原值来源与语义代理分别标注。旧 48 / 54 / 81、冰封及独立金鹅只用于回归档。消除后不补货。

深度隐藏只关闭渲染并限制手动点选，支撑碰撞继续有效；物件稳定后才转为 kinematic。已按场景序列化基线更新为可见深度 0.4–0.5、参考高度 2.1、刚体乘数 0.5、单次下降 0.05、软预算 70；位置值乘 0.1 是本项目尺度选择，不是已测得的世界单位换算。依据和工程保护见 [实际配置研究](../竞品分析/08-实际关卡权重与深度参数.md) 与 [Unity 接入](../竞品分析/05-Unity接入.md)。

2026-10-23 历史验收：Unity 2022.3.62f3 编辑模式 10/10 通过；独立算法开发包 75/75 通过，涵盖五主题库存、隐藏、支撑、重新激活和非等权组数生成／清空。算法包为 `Builds/AlgorithmQA/CatchGooseAlgorithmQA.exe`，与 `WindowsQA` 分开：

```powershell
./tools/competitor/run_policy_tests.ps1 -OutputDirectory work/competitor-20261023-tests
./tools/competitor/run_unity_algorithm_tests.ps1 -OutputDirectory work/competitor-20261023-tests
```

结果写入根目录 `work/competitor-20261023-tests/`；[本轮归档结果](../竞品分析/07-验证结果与后续清单.md) 保留记录和源码哈希。该验收使用无图形开发包，不替代画面、人工点选、移动端性能或微信发布验收。

## 微信进局性能（2026-10-24）

当前核心档为 15/60/300 件、每主题 21 类；旧 48/54/81 件文字属于回归档历史说明。已加入分帧资源准备、104 件离线碰撞网格、当前主题 300 件上限的实例池，以及独立 WebGL 移动档（30 FPS 目标/60 Hz 物理/无实时阴影）。正式微信包位于 `Builds/WeChat/minigame`；默认以 Release 构建。冷准备不扣游戏时间，重复开局复用对象；手机性能仍待实际设备采样。原始符号保存在 `work/wechat-integration/release-symbols/`，压缩符号保留在包内。[完整研究、实测和待确认](../竞品分析/17-微信进局性能与竞品优化.md)。

## 手机 UI（2026-10-24）

首页采用原创大鹅插画、浅蓝底、五主题卡片及黄色开始按钮；对局采用顶部计时/进度、中央独立物件区、七格浅灰槽与底部三个道具按钮。`GoosePhoneLayout` 统一安全区与相机视口，适配全面屏、平板和横屏窗口；微信另预留胶囊区域。运行 `tools/unity/run-ui-acceptance.ps1` 可重建并执行多尺寸实际播放器验收。竞品依据、设计尺寸、资源提示词及真机验证边界见 [UI 布局与手机适配](../竞品分析/18-UI布局与手机适配.md)。

后续依据用户提供的竞品首页截图，将浅蓝首页升级为市集地面与圆桌陈列，主题入口改为两侧贴纸按钮，主按钮改为蓝色；增加可用的成绩/玩法弹窗，统一对局背景并提亮移动端材质。当前视觉以 [市集风 UI 与画风优化](../竞品分析/19-市集风UI与画风优化.md) 为准，前一版作为历史保留。实际播放器移动档验收可使用 `-MobileProfile -OutputDirectory work/ui-market-20261024/final-mobile`。
