---
name: match3-model-pipeline
description: 为抓住大鹅 Cocos 三消项目创建或加工 Blender 物件模型，按已有 GLB、图标、Jolt 凸包与移动端预算规范生成候选资源并验证。适用于三消新物品和主题资源，不用于网页原型或无关 Blender 工程。
---

# 三消物件模型生成管线

目标是可辨识、可复现、可加载和可碰撞的游戏资源。以用户当前工程为准，先确认项目根目录；本项目实际工程是 `reference-projects/catch-big-goose-cocos/`，`web/` 是停用原型。

读 [模型规范](references/model-standard.md) 确认既有约定与新增预算；安装或排查 MCP 时读 [Blender 接入](references/blender-setup.md)。不要把候选模型直接写入 `resources/`：Cocos 会全量打包该目录。模型发布与主题上线按用户请求范围执行。

## 工作方式

1. 检查 `reference-projects/catch-big-goose-cocos/assets/resources/models/`、`icons/`、`LevelConfig.ts`、`PrefabCache.ts` 和 `JoltWorld.ts`。通过已有资源的实际数据确认规格，区分历史异常和应遵守的约定。
2. 先写明每个物品的轮廓、主色、至少三项辨识特征、真实部件连接、允许简化项和预算。生成候选放 `source-assets/models/candidates/<batch>/`，保留源文件。需要第三方图生 3D 时先确认服务和成本授权，使用单物体参考；不要把多视图拼图直接送入图生 3D。
3. 适合结构明确的电子产品时，用 Blender 几何生成；MCP 适合查看和修改现场景，批处理用后台 Blender。新会话已提供 `blender` MCP 时优先直接调用；本会话若未刷新工具列表，可用 MCP SDK 初始化同一 stdio 服务进行验证，不能将普通 socket 测试冒充 MCP 测试。
4. 九类电子产品已有可重复脚本；v1 五件保留归档，v2 九件用于数码工坊。示例中的 `<...>` 均由实际路径替换，PowerShell 路径加引号：

```powershell
& '<blender.exe>' --background --factory-startup --python-exit-code 1 --python '<skill>/scripts/generate_electronics.py' -- --output '<project>/assets-3d/candidates/electronics-v2'
node '<skill>/scripts/audit_assets.mjs' --project '<project>' --candidate '<project>/assets-3d/candidates/electronics-v2' --validator '<gltf-validator module directory>'
& '<python.exe>' '<skill>/scripts/compose_qa.py' --project '<project>' --candidate '<project>/assets-3d/candidates/electronics-v2'
```

脚本通过 `--only phone,camera` 限定重建范围，`--skip-render` 仅用于几何调试，不能替代交付时的视觉验收。`audit_assets.mjs` 使用项目自己的 Three.js、测试模块加载器及 Jolt 1.1.0；验证器依赖 `gltf-validator@2.0.0-dev.3.10`，可安装在工程外的工具目录。合成检查图依赖 Pillow。

5. 查看导出 GLB 重新导入后的四视图、64px 图标和既有资源对照图，检查辨识、漏面、悬空细节、光照与留白。自动门禁验证导出后的世界坐标尺寸、实际三角数、材质、扩展、Khronos glTF 规则，调用真实 `extractHullPoints` 和 `JoltWorld` 跑密堆、落地、休眠、射线及移除。门禁失败则修正后重跑；不能仅根据生成成功日志交付。
6. 如需进入 Cocos，运行 `python <skill>/scripts/stage_candidates.py --project <project> --candidate <batch>`，脚本会核对报告哈希并复制到 `reference-projects/catch-big-goose-cocos/assets/models-pool/electronics/`。Creator 导入后，运行 `python <skill>/scripts/verify_cocos_import.py --project <project> --candidate <batch>` 验证真实 library 中的网格、UV、贴图链接、材质和预制体。同名候选有改动时可用 `--replace` 更新，保留旧 `.meta` UUID；新模型让 Creator 创建 UUID，不复制其他资源的元数据。

## 交付与验收边界

交付 `.blend`、独立 `.glb`、192px RGBA 图标、64px 缩略图、四视图、预算及碰撞报告。记录工具版本、模型哈希、运行命令、来源与可复现参数。

把以下状态分别报告：生成成功、GLB 回读通过、物理管线验证通过、Creator 导入通过、实际关卡验证通过。Node 下使用 Cocos 数学适配器的 Jolt 验证不能证明 Creator 材质导入或触控与托盘表现；未做的项目明确标记待验证。

完整主题至少九件，前四件主色和轮廓应明显不同。用户要求上线完整主题时补齐物品、容器、背景和关卡配置，再在真实游戏中测载入、点击、托盘、三消、冰封与资源包大小。数码工坊的完整接入路径见 [主题接入](references/electronics-theme.md)。
