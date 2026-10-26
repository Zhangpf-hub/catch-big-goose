# 柴犬吉祥物 · 第一版

用户于 2026-10-25 否定长颈鹿的斑驳配色，改选柴犬。本版采用已选概念图中的赤茶色、奶白色、立耳、短嘴、卷尾与清楚的四肢。靠轮廓和两块主色识别，不使用斑点、毛发噪点或贴图里的烘焙阴影。长颈鹿资源保留在原候选目录。

## 造型与实际资源

- 原创 Blender 几何；主体连续蒙皮，耳朵、眼鼻、嘴线和卷尾为连接或贴合主体的闭合壳体。
- 微微放大头部，保留修长四肢；柔和塑料质感，低金属度、粗糙度 0.52。
- 静态道具 `model/shiba.glb`、`model/shiba.fbx`；归一化最大边为 1，包围盒居中，5000 三角面、一个网格/材质/primitive。
- `model/albedo.png` 为 512×512 无光照颜色图集。相对普通小物件的默认 256 图集，此处使用 512 保留嘴线与奶白边界；GLB 仍在 256 KiB 门禁内。
- 192/64 px 透明图标；前、侧、背、三分之四和游戏俯视图均来自导出的实际网格。
- `source/shiba-authored.blend` 保留构件与可调配色；`shiba-static.blend` 是移动端静态版；`shiba-animated.blend` 保留 3 根骨骼和动作。

## 动画与 Unity 接入

`Idle`：轻呼吸、轻摆头尾；`Happy`：歪头和摇尾；`Bounce`：以脚底为锚点的压缩回弹。角色没有行走动作。

当前实际游戏工程是 Unity 2022.3.62f3，已导入：

- `unity/Assets/Resources/Models/shiba/` 静态道具与材质。
- `unity/Assets/Resources/Icons/shiba.png` 和 `Resources/Physics/shiba.asset` 凸包。
- `unity/Assets/Mascots/Shiba/ShibaHome.prefab` 可复用动态吉祥物。
- `ShibaMascot.ReactToTap()` 播放回弹，`Greet()` 播放歪头摇尾，播放后回到循环待机；可由主页按钮/场景输入绑定调用。
- 展示比例表新增 `shiba: 1.35`。验收程序临时把柴犬加入水果关卡，与真实物理、生成、点选、托盘及三消代码一起运行。

本阶段交付可验收的模型与 prefab；正式主页场景、音乐和五套主题名单未在此次模型替换中改版。运行普通游戏不会自动把所有大鹅替换为柴犬。

## 重建与复验

在项目根目录，用 Blender 4.5 后台按顺序执行：

1. `tools/mascots/build_shiba.py`
2. `tools/mascots/rig_shiba.py`
3. `node tools/mascots/audit_shiba.mjs`
4. `python tools/mascots/stage_shiba.py`
5. `tools/mascots/run_shiba_acceptance.ps1 -Build`
6. Blender 后台执行 `tools/mascots/render_shiba_review.py`

`stage_shiba.py` 核对 GLB 验证结果与 SHA-256，复制模型时保留 Unity 的 `.meta`。最终报告路径见 `delivery.json`。测试使用桌面 Unity 播放器的手机性能配置及 390×844 窗口；不等同于手机真机帧率测试。
