# 竞品道具按场景实装 · 2026-10-25

当前 Unity 正式关卡改为以下五组。本次使用本机已有缓存中的原始网格和贴图，并按 Unity 的尺寸、碰撞和移动端材质要求转换。

| 关卡场景 | 道具数 | 原始资源分组 |
| --- | ---: | --- |
| 早餐铺 | 17 | Breakfast |
| 烧烤摊 | 17 | Barbecue |
| 乡村小院 | 18 | Countryside |
| 童年玩具 | 21 | ChildhoodToys26Obj |
| 杂货铺 | 7 | GroceryStore |

共 80 件普通道具；每个场景沿用项目的 15 / 60 / 300 件三档库存。权重按原始模型名称逐项匹配已提取的 LevelData，缓存子集重新参与项目配额，不声称完整恢复原游戏关卡。详细绑定见 `work/competitor-replacement-20261025/weight-bindings.json`。

资源来源、Prefab 路径和源数据哈希见 `unity/Assets/Resources/Data/competitor-models.json`。原始提取结果位于 `references/competitor-goose/2026-10-25-runtime/`。86 个静态资源中选入 80 件，其他资源保留为参考。

59 件使用单网格、单材质、512 像素图集；修复原始 BaseTint 和透明贴图合成。21 件玩具保留已有的原始材质分组、MatCap 和玻璃适配，每件最多 3 个材质。原 shader 程序未恢复；部分其他场景玻璃外壳按不透明移动材质简化。所有模型使用离线碰撞代理，并适配入槽尺寸。

普通道具已从生成资源切换到竞品资源。容器、背景、系统目标鹅和柴犬吉祥物继续使用项目已有资源。旧普通道具从 Resources 移到 `unity/SourceAssets/BeforeCompetitorReplacement-20261025/retired-runtime/`，保留文件和 Unity 元数据；原配置在同目录的 `Data/`，完整迁移清单为 `retired-assets.json`。恢复时应先备份当前配置，再恢复旧配置与清单中的资源路径，重新烘焙碰撞并构建。

验收证据位于 `work/competitor-replacement-20261025/`：`delivery.json` 汇总当前运行资产哈希；`playtest/acceptance.json` 记录五场景 × 三难度的实际运行检查；`edit-tests-final.xml` 为编辑模式测试；`five-scenes.jpg` 为五个正式关卡实机截图。运行检查覆盖库存、成组三件、堆叠边界、实际屏幕点击、飞入槽位、动画消除和整局清空。

本轮交付 Windows 正式包，390×844 移动布局验证来自 Windows Player，不等同于手机 GPU/FPS 验证。微信构建包未在本轮重新生成。双击根目录 `开始游戏.cmd` 查看本轮结果。
