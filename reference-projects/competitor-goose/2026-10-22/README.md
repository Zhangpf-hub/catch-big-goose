# 《抓大鹅》风格参考资源

从用户指定竞品的本地缓存提取，日期 2026-10-22。共 **17 个烧烤普通物品**，单独保存于本目录，不属于 Unity 或 Cocos 的游戏资源目录。

后续算法研究与 Unity 接入见 [竞品分析分章目录](../../../竞品分析/README.md)：已从首轮 18 个方法体扩展到 34 个，并完成原方法隔离数值对照和实际 Unity 深度验收。本目录保留首轮资源及方法证据。

2026-10-23 又完成版本 402 的实际配置与模式追踪，并新增 [27 个童年玩具静态参考](../2026-10-23/README.md)，现共 44 个静态模型。最新数量、测试与待确认边界以分章目录为准，本目录资源不覆盖更新。

- `contact-sheet-three-quarter.jpg` / `contact-sheet-top.jpg`：两张总览图。
- `models/<物品名>/`：可打开的 `.blend`、`.glb`、`.obj/.mtl`、原贴图、两视图以及 `source.json`。
- `source.json`：完整源网格顶点、面、UV、材质参数、层级变换和碰撞体记录。移除预制体根平移，保留原缩放；没有把这些参考模型强制归一化为自有游戏的尺寸。
- `manifest.json`：源 bundle 路径、哈希、原始三角数和模型索引。
- `export-verification.json`：GLB 回读后的三角数、尺寸误差与 UV 检查。
- `gltf-validation.json`：17 个参考模型和 1 个原创候选的 Khronos 验证结果，全部零错误、零警告。
- `project-audit.json/.csv`：50 个自有资源按实际场景节点实例计数的审计表；普通件与容器分开。
- `algorithm/README.md`：本次新取得的方法体及分析结论。
- `evidence/`：2026-10-21 原竞品报告和两张真实游戏截图。

预览使用源颜色贴图与中性灯光，**未重现原版 ToonLite1 / MatCap Shader**。法线、AO、粗糙度与 MatCap 原图和启用参数都已保留，但没有一律打开；玉米的 `_IsUseNormalMap` 源值就是 0。

三角数变化有明确原因：玉米源数据 514 → 导出 513，煎饺 570 → 568，鸡腿 1008 → 1007，均为清理源数据中顶点索引相同的重复面。其余普通件三角数保持一致。原始重复面仍保留在 `source.json`，没有隐瞒网格差异。

特殊的 `Goose_Pancake` 含蒙皮与组合变换，本次没有将它当普通静态物件导出，避免把未恢复姿态的大鹅作为正确结果交付。

这里的竞品资源用于用户要求的本地风格研究。原创候选位于工作区 `assets-3d/candidates/competitor-alignment-corn/`，其几何和贴图由独立脚本生成，没有使用竞品模型或贴图。

复现脚本位于工作区 `tools/competitor/`：`extract_reference.py`、`build_reference.py`、`audit_alignment.py`、`inspect_packages.mjs`、`recover_methods.py`。Python 工具参数指定证据、依赖和目标目录；Blender 工具通过 `--background --factory-startup --python-exit-code 1 --python <script> -- <arguments>` 运行。
