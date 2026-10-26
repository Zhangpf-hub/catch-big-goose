# B2 鸭子母模：真实网格验收

B2 概念比例已由用户“通过 完成计划”确认。本包是此后重建的完整鸭子母模，造型尚待用户验收。旧 `model-review-v1` 的三款模型仍是已否定版本，不是当前交付。

[打开验收页](review.html) · [真实三视图](renders/master-turnaround.png) · [姿态检查](renders/pose-sheet.png)

## 本轮实际完成

- 一张连续的头、颈、胸、躯干、尾部控制网格，以 B2 正侧轮廓约束形体。翅膀、嘴、眼睛和蹼足为独立闭合附属网格；整件导出为单 mesh、单材质、单 primitive。
- 可编辑 `.blend` 控制网格、较密高模、静态 GLB / FBX、256px 配色图集、骨架及待机 / 招呼 / 点击回弹三个动作。
- 正、侧、背、三分之四、游戏俯视、头部近景，以及 192px / 64px 图标。图片来自实际 GLB 回读，不以生图代替三维渲染。
- 源文件和导出回读均检查实际顶点运动；三个动作结束回到静止姿态。此证据不替代 Unity 动画导入与实际运行检查。

## 形体与预算

实测头宽 / 不含翅膀的躯干宽为 39.7%，单脚宽 / 躯干宽为 32.9%。这些是当前网格尺寸，不是由生图提示词推断的数值，也不代表用户已验收。

当前完整母模 5,412 三角面，低于 6,000 上限，但高于组合件 2,000–4,000 的目标。组合时应在外壳内部裁除不可见躯干，再分别做预算和轮廓检查；不能把完整母模与道具直接相加后宣称达到预算。

静态 GLB 与带骨架 GLB 均小于 256 KiB。较密高模 GLB 是建模源资产，不是运行包，不套用移动端文件预算。头颈躯干没有体素拼接或整体随机减面；附属部件进行了局部减面，保留高模对照。

## 待验收与剩余范围

按此前质量修正路线，先验收真实母模的头嘴、颈胸、小脚与侧面轮廓，再用同一网格重做蛋挞鸭、钢杯鸭和积木鸭。三款仍需要实际模型与竞品在相同最大边、镜头和灯光下的对照。当前母模包没有完成这三款的新对照。

之后仍需完成其余 17 款、Unity 首页动作控制与柴犬替换、五主题独立评审关、正式状态恢复及实际物理/拾取/托盘/三消验收。本轮没有更改 Unity 项目或正式主题，没有调用付费图生 3D。

## 证据

- [几何回读](qa/duck-b2-master-geometry.json)
- [Khronos 验证](qa/glb-validation.json)
- [高模与简化版轮廓对照](qa/silhouette-comparison.json)：只检查简化损失，不证明与概念匹配。
- [骨架动作回读](qa/rig-roundtrip-validation.json)
- [比例实测](qa/proportions.json)
- [图片与文件引用检查](qa/delivery-checks.json)：未进行浏览器布局验收。

## 重现

从工作区根目录使用 `tools/blender.local.json` 指定的 Blender 4.5.14，以 `--background --factory-startup --python-exit-code 1 --python <脚本>` 依次运行：

1. `tools/mascots/build_duck_b2_master.py`
2. `tools/mascots/rig_duck_b2_master.py`
3. `tools/mascots/inspect_duck_b2_master.py`

然后运行 `node tools/mascots/audit_duck_b2_master.mjs`、`python tools/mascots/package_duck_b2_master.py` 和 `npm run structure:check`。渲染与导出共用的基础工具位于 `tools/mascots/build_duck_representatives.py`，其旧版头颈构造函数没有用于本母模。
