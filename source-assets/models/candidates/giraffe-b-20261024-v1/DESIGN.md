# 长颈鹿 B：建模规格与验收

用户选择长颈鹿继续推进；本轮采用此前推荐的 B 版细长比例。竞品截图只作为简洁玩具质感参考，模型几何、斑块与动作由本项目独立制作。

## 造型

窄躯干、柔和弯曲的长脖子、小脑袋和四条清楚分开的腿。奶黄色主色、较大的焦糖色斑块、奶油色嘴部、小黑眼、粉橙色耳内、短双角与棕色蹄尖。肩部、脖子、头和腿使用连续圆滑的主体网格；眼、鼻、耳内等为有实际连接位置的闭合细节壳体。没有毛发、服装或外部品牌细节。

## 技术目标

- 当前引擎为 Unity 2022.3，不套用旧 Cocos/Jolt 的验收结果。
- 局内模型：最多 6,000 三角面、一个网格、一个材质、一个绘制部分；最大边 1、包围盒居中；GLB 不超过 256 KiB。
- 贴图采用当前 Unity 移动模型规格的 512×512，比旧电子产品图集更高，以保留弯曲脖子上的斑块和脸部细节。单材质，无毛发和透明贴片。
- 首页模型：同一造型和贴图，另加四骨骼颈部绑定，待机 Idle、探头 Peek、回弹 Bounce 三个短动作。此轮未做四足行走。
- 碰撞使用按模型极值点生成的简化凸包；细腿之间的空隙不会逐一参与碰撞。验收使用 Unity 的实际物理引擎与拾取/入槽/三消流程。

## 文件

- `source/giraffe-authored.blend`：可编辑部件和斑块材质。
- `source/giraffe-static.blend`、`model/giraffe.glb`、`model/giraffe.fbx`：局内定姿模型。
- `source/giraffe-animated.blend`、`model/giraffe-home.fbx`：首页绑定与动作。
- `renders/model-review.png`：真实网格渲染；`renders/animation-review.mp4`：真实骨骼动作演示。
- `renders/front.png`、`side.png`、`back.png`、`gameplay.png`：导出 GLB 回读后的视角检查。
- `model/icon-192.png`、`model/icon-64.png`：透明图标。
- `qa/`：网格、glTF、Unity 导入、物理与对局验收记录。

## 复现

使用 `tools/blender.local.json` 中的 Blender 可执行文件，依次运行：

```text
blender --background --factory-startup --python-exit-code 1 --python tools/mascots/build_giraffe.py
node tools/mascots/audit_giraffe.mjs
blender --background --factory-startup --python-exit-code 1 --python tools/mascots/rig_giraffe.py
blender --background --factory-startup --python-exit-code 1 --python tools/mascots/render_giraffe_review.py
```

通过候选验收后，将局内 FBX、albedo.png、materials.json 置于 `unity/Assets/Resources/Models/giraffe/`，首页 FBX 置于 `unity/Assets/Mascots/Giraffe/`。Unity 执行 `CatchGoose.Editor.GiraffeModelSetup.BuildReview` 后，用评审包的 `-giraffeQa -gooseMobileProfile -giraffeOutput <绝对输出目录>` 运行验证。

运行目录不包含 `.blend` 和 GLB 的重复副本。独立评审包在 `unity/Builds/GiraffeReview/`，现有五个主题的物品列表和首页布局未在本轮替换；正式出场方式在模型验收后确定。

## 已完成的验收

- GLB：5,000 三角面，247,376 字节，一个网格/材质/绘制部分；Khronos 验证零错误、零警告。
- 网格：GLB 回读并焊接 UV 接缝后，无开边、无非流形边、无退化面；最大边和居中符合规格。
- 图标：192px 图标非透明范围为 (66,24)–(124,176)，满足四周至少 6px 留白；64px 已目视检查。
- Unity：导入保留 5,000 三角面和单材质；58 个支撑点生成凸包。三个动画片段均通过实际蒙皮顶点位移检查。
- 最终原生播放器移动配置验收：`qa/unity-final/acceptance.json` 的 15 项检查全部通过。45 只动态长颈鹿在 15 秒内全部自然休眠，移除支撑后未穿出底板；正式生成器的混合道具堆、屏幕射线点击、实际网格入槽、单格尺寸和三消流程通过。
- 尺寸配置已追加 giraffe=1.7；未改动其他物件尺寸。长颈鹿需要比宽体水果更大的最长边，才能保留被遮挡时的头部识别。
- `qa/unity-mobile-sized/` 保留一次失败的补测：当时测试脚本把物件直接从高于围栏的位置投下。最终使用正式生成器的支撑排布和预沉降流程，保留原有位置边界检查，没有放宽门禁。
- 当前结果来自 Windows 播放器启用移动端配置，尚未完成手机真机测试。本轮不宣称移动端实测帧率。

完整清单与哈希见 `delivery.json`。可用 `powershell -File tools/mascots/run_giraffe_acceptance.ps1 -Build` 重新构建与验收，报告保存在新的时间戳目录。
