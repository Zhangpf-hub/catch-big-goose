# 电子产品首批模型验证

完成日期：2026-10-21（Asia/Shanghai）。首批为手机、笔记本电脑、相机、头戴耳机、掌机，共五件原创候选。当前未注册新关卡主题；完整主题仍需九件及配套场景资源。

## 交付物

- `models/`：五个独立 GLB，最大边 1、居中、Y-up、单材质、64×64 内嵌配色图集。
- `source/`：五个可编辑 `.blend`，另有 MCP 导入手机的验证场景。
- `icons/`：五个 192×192 透明 PNG。
- `qa/contact-sheet.png`：总览与 64px 检查；`four-view-sheet.png`：四视图；`underside-sheet.png`：底面；`reference-comparison.png`：与既有图标对照。
- `cocos/assets/models-pool/electronics/`：已由 Creator 实际导入的候选模型、图标与自动生成的 `.meta`。
- 可调用 skill：`$match3-model-pipeline`，安装于 `C:/Users/123/.codex/skills/match3-model-pipeline/`，工程内保存同名源码。

## 资源结果

| 物品 | id | 三角形 | GLB | 材质 / primitive | 凸包采样点 |
| --- | --- | ---: | ---: | ---: | ---: |
| 手机 | phone | 2,636 | 59.4 KiB | 1 / 1 | 45 |
| 笔记本电脑 | laptop | 3,316 | 75.7 KiB | 1 / 1 | 67 |
| 相机 | camera | 3,496 | 78.0 KiB | 1 / 1 | 84 |
| 头戴耳机 | headphones | 2,388 | 55.0 KiB | 1 / 1 | 49 |
| 掌机 | handheld | 4,048 | 90.4 KiB | 1 / 1 | 33 |

总 GLB 358.6 KiB。所有模型均满足最大边、中心、厚度、三角形、体积及材质门禁。`qa/asset-audit.json` 记录准确字节数、SHA256、游戏坐标尺寸，并包含全部 40 个既有模型的实测对照。容器、高面数历史物品与普通新物件的预算分别说明在 skill 模型规范中。

## 已完成的验证

| 验证 | 结果与证据 |
| --- | --- |
| Blender 生成与 GLB 回读 | 五件通过；回读后无非有限坐标、开边或退化三角形；`qa/generation.json` |
| Khronos glTF Validator | 五件均零错误、零警告；`qa/*.gltf-validation.json` |
| 材质兼容 | 标准 PBR、metallic=0、roughness=0.6、无材质扩展、无外部解码依赖 |
| 图标与目视 | 192px RGBA 和透明留白通过；已查看总览、四视图、底面及现有图标对照，64px 轮廓可区分；`qa/icon-audit.json` |
| 项目物理管线 | 调用真实 `extractHullPoints` 与 `JoltWorld`，Cocos 数学接口由 Three.js 适配，Jolt 1.1.0 WASM；45 件、1/120 固定步长、CCD，15 秒后 45/45 自然休眠；无逃逸或凸包降级；射线拾取通过，移除三件后继续模拟五秒；`qa/asset-audit.json` |
| Creator 导入 | Creator 3.8.8 自动创建五个 GLB 的 prefab、mesh、材质、贴图及图标元数据；实际 library 验证法线、UV、albedo 链接、metallic/roughness 与单 MeshRenderer 通过；`qa/cocos-import.json` |
| MCP 链路 | 固定 `mcp-for-blender==2.2.2`、插件协议 14；SDK 完成 initialize、九项工具枚举、执行 Blender Python、导入最终手机 GLB、保存场景和再次查询；`qa/mcp-verification.json` |
| 可复现 | 独立后台会话重新生成手机，GLB SHA256 与交付文件完全相同 |
| 工程检查与发布 | `node tools/check.mjs` 全通过，包含 TypeScript、31 项回归、项目资源约束、Shell 与 Python 语法；Web Mobile release/WASM 构建成功，游戏包 19.21 MiB，另有 40.00 MiB 按需宣传片 |

Node 物理验证与 Creator 导入验证各有范围。候选模型尚未进入正式关卡，因此没有声称五个新物品已完成游戏内触控、托盘、三消和冰封验收；现有玩法由回归检查与构建验证。耳机的物理凸包会填实头梁内孔，这是明确的近似。

## 工具与复用

Blender 4.5.14 LTS 便携安装于 `D:/开发/tools/blender/`，安装包通过官方 SHA256 校验，已添加开始菜单快捷方式和用户 PATH。MCP 已注册到 Codex 用户配置，只连接 localhost，遥测关闭。工具版本、路径及校验值见 `qa/installation.json`。

重启 Codex 后可在新聊天使用 `blender` MCP 和 `$match3-model-pipeline`。先保持 Blender 运行；项目内 `tools/start-blender-mcp.ps1` 默认隐藏启动一个专用 Blender 进程。生成、审计、图标合成、候选池投放和 Creator 导入检查的命令均在 skill 中。

模型均为本次确定性脚本原创，无外部模型、品牌贴图或付费服务依赖。生成简报及预算见 `assets-3d/specs/electronics-v1.json`。
