# 鸭子 B：三款真实模型同尺寸评审

用户已明确确认 B 母版与三款融合方向，并要求先验收蛋挞鸭、钢杯鸭、积木鸭及竞品同类模型的同尺寸对照。当前状态：**用户已否定造型，模型验收未通过，仅保留问题记录，不作为发布或批量母版**。

## 先看效果

- [三分之四同尺寸对照](renders/comparison-hero.png)
- [游戏俯视同尺寸对照](renders/comparison-gameplay.png)
- [192/64px 小图对照](renders/thumbnail-comparison.png)
- [完整本地评审页](model-review.html)

所有对照均为 GLB 导出后回读的真实模型渲染，不使用概念图代替模型。每组左为竞品提取件，右为鸭子 B 原创模型；保留源姿态，每件最长边归一到1、包围盒中心归零，统一正交尺度1.48、镜头方向、棚光及画布。没有按每张图的 alpha 范围重新裁切放大。竞品仅为基础色/PBR材质近似，未还原原游戏 Shader。

## 实际交付

| 模型 | 三角面 | GLB 字节 | 材质/网格/primitive | 图集 |
| --- | ---: | ---: | --- | --- |
| duck-eggtart | 3,672 | 86,028 | 1 / 1 / 1 | 256×256 |
| duck-steelcup | 3,706 | 88,100 | 1 / 1 / 1 | 256×256 |
| duck-numberblock | 3,328 | 77,332 | 1 / 1 / 1 | 256×256 |

`source/` 提供可编辑构件 `.blend`、单材质归一化 `.blend`、带灯光与相机的实际评审场景；`models/<id>/` 提供GLB、FBX、颜色图集、材质说明及离线凸包OBJ。`renders/<id>/duck/` 提供正面、侧面、背面、三分之四、俯视和192/64px透明图标。原始GLB内部不包含相机、灯光、骨骼或动画。

三个模型通过同一个 `bird()` 和 `bill()` 构造头颈与鸭嘴，按外壳安排颈部弯曲；蛋挞采用浅盘与贴图烤色，钢杯具有杯沿、内壁、把手和后侧尾孔，积木使用红壳、侧颈连接与绿色数字1。隐藏身体是连续白色皮肤，外壳及配件为有连接位置的闭合壳体，允许装配交叠。

## 验证状态

- 生成及GLB回读通过；最大边与居中符合1e-4门禁，UV接缝焊接检查无非流形边和退化面。
- 三款 Khronos glTF 验证均为零错误、零警告、零提示。
- 同镜头、灯光、画布、归一尺寸及当前源文件哈希通过自动核对；图标透明留白与全部视角未裁切检查通过。
- 已实际查看三分之四、俯视、小图和其他视角对照。64px下能区分三种外壳及橙色嘴脚，眼睛与烤色等细节会明显减弱；这仍需要用户确认游戏中预期的识别效果。
- 离线凸包OBJ仅做几何检查。**尚未做 Unity 导入、PhysX cooking、动态密堆/休眠、屏幕拾取/入槽/三消及移动端性能验证。**没有将这些待验项目标成通过。
- 正式首页、五主题和竞品原始/冻结资料未修改，其余17款未制作。模型尚未获得用户验收批准。

## 复现

在工作区根目录用 `tools/blender.local.json` 配置的 Blender 4.5.14执行：

```text
blender --background --factory-startup --python-exit-code 1 --python tools/mascots/build_duck_representatives.py
blender --background --factory-startup --python-exit-code 1 --python tools/mascots/build_duck_representatives.py -- --hulls-only
node tools/mascots/audit_duck_representatives.mjs
python tools/mascots/compose_duck_review.py
npm run structure:check
```

`--build-only`、`--render-only`、`--duck-only`、`--reference-only` 和 `--only <id>` 可限定重建范围。脚本只读参考GLB并在内存里归一，输出均进入此候选目录；默认不向Unity运行资源发布。

提示：完整渲染流程使用本地CPU Cycles 16采样，源材质为PBR近似。查看截图或打开静态GLB不等于移动端游戏验收。图像比较中的参考GLB原始尺寸、比例缩放和来源SHA-256保存在 `qa/*-comparison.json`。
