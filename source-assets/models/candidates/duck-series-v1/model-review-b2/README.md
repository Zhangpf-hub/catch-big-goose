# B2 三款鸭子融合模型验收

[打开验收页](review.html) · [同尺寸概览](renders/comparison-overview.png) · [俯视对照](renders/comparison-gameplay.png) · [192/64px 对照](renders/thumbnail-comparison.png)

本批包括蛋挞鸭、钢杯鸭、积木鸭，供用户验收真实造型与融合效果。已确认的 B2 概念和三款制作授权用于本批候选；尚未将母模或三款真实模型记为用户已验收。旧 `model-review-v1` 仍为被否定的历史版本。

## 形体来源

三款使用 B2 母模已有的头、鸭嘴、眼睛、细颈、小脚和尾部。通过同一骨架安排姿态；蛋挞和积木使用头部平移延展探颈，保持头部本身尺寸。没有按每款重新拼一个头或重新生成人物网格。

钢杯内可见躯干与颈部是一张连续母模曲面，避免开放杯口中出现裸露截面或重叠闪烁。蛋挞、积木的裁切口藏在实体道具内部。翅膀隐藏在外壳内，不额外外扩组合宽度。

移动端版本保留露出的头颈皮肤网格，只对小脚、嘴、眼睛、尾部及道具做适度简化。`quality-baseline` 保留较密网格和渲染，用同镜头轮廓检查简化损失。面部标记点的距离检查记录在 `qa/*-mother-identity.json`，其中嘴和眼睛的刚性检查发生在附件 LOD 之前；最终外轮廓另行验证，不混为同一证据。

## 技术状态

| 模型 | 三角面 | GLB |
| --- | --- | --- |
| 蛋挞鸭 | 3,752 | 89,480 bytes |
| 钢杯鸭 | 3,940 | 96,100 bytes |
| 积木鸭 | 3,820 | 91,292 bytes |

三款均为单 mesh、单材质、单 primitive，最大边 1、包围盒居中，256px 配色和金属/粗糙度图集。GLB 回读闭合性、非退化面、Khronos 零错误零警告检查通过。

提供 `.blend`、GLB、FBX、贴图、四视图、游戏俯视和透明图标。Unity Standard 用的金属/光滑度贴图已按 R=金属、A=光滑度转换，已在独立 Unity 2022.3.62f3 QA 工程确认贴图引用、色彩空间和材质重映射。GLB 使用 G=粗糙度、B=金属，详见各模型的 `materials.json`。正式游戏工程尚未导入。

离线凸包 OBJ 采用 Blender Z-up，记录顶点、面和体积。独立 QA 将同一批顶点转换为 FBX，确认与实际视觉网格对齐、PhysX 凸包烘焙和射线命中；45 件混合密堆在 15 秒后全部自然休眠，移除底部支撑后 44 件再次稳定。杯口等凹部会被凸包填平。正式发布工程与微信真机性能仍待验收。

[Unity 实际材质预览](renders/unity-import-overview.png)采用独立 Standard 灰棚灯光，并非正式游戏效果。母模三个动作均已用 Unity `BakeMesh` 确认实际顶点变形和返回静止姿态，详见 [Unity QA 记录](qa/unity-import/unity-audit.json)。未替换首页，也未把技术检查当作用户造型验收。

Unity 首次导入发现钢杯 FBX 少 8 个三角面，原因是 FBX 与 GLB 各自处理作者网格中的多边形。已将三款 FBX 改为从原 GLB 的明确三角网格导出；回读后的面数分别为 3,752 / 3,940 / 3,820。GLB 与作者源文件形体保持不变，转换来源保留在 `qa/fbx-triangle-provenance.json`。

## 实际游戏流程

另用当前游戏源码快照构建了独立 Windows QA Player。桌面和移动端配置均完成 45 件生成、三款各 3 次真实屏幕射线拾取、托盘入槽、三消与第二次进出。未修改生成器、拾取、托盘和三消核心代码，未强制显示物件或调用自动拾取接口。三款最大托盘宽度均为槽宽的 76%，结算后槽位清空。

真实移动端材质缓存原先会丢失金属与光滑度贴图；QA 副本加入 `Goose/DuckMobile` 单通道候选材质，并保留其贴图引用。它是风格化近似材质，尚未发布到正式工程。见[游戏内截图](renders/gameplay-acceptance-overview.png)、[移动端配置记录](qa/gameplay/mobile/acceptance.json)、[桌面配置记录](qa/gameplay/desktop/acceptance.json)和[候选 Shader](qa/gameplay/GooseDuckMobile.shader)。

退出恢复五主题内存配置、原主题和关卡；测试过程中故事成绩、每日挑战次数未改变。使用独立公司名及 QA 存档命名空间，PlayerConnection 仅限本机。此项不是微信真机测试，也不代表五主题鸭子评审入口已完成。

## 同尺寸对照条件

竞品来自本项目已有的三个真实 GLB，原始文件不修改。每件模型独立将最大边归一为 1、包围盒居中，再采用相同镜头、正交尺度 1.48、灯光和画布渲染。排版只有统一缩放，没有按轮廓单独裁切放大。

竞品保留提取资源的姿态，材质是恢复的基础色/PBR 近似，不是竞品原游戏截图。生图概念另列供造型参考，未用作三维渲染替代品。

## 当前评审边界

本批与独立母模可一起验收头嘴比例、细颈、融合接口、小脚和物件辨识。三款通过后，再扩展其余 17 款、首页替换与五主题独立评审关。当前未修改正式五主题、未写入正式成绩、未调用付费图生 3D。

## 重现

工作区目录检查最新为 42 项通过、1 项未通过：另一个首页报告指向的 `work/home-lighting-shake-20261025/delivery.json` 尚缺失，SDK 中间目录问题已由外部构建流程消除。本轮未改动这两个路径。候选模型与本验收页文件检查通过，不代表全工作区目录检查通过；以 `qa/structure-check.json` 的最新记录为准。

在工作区根目录，用 `tools/blender.local.json` 指定的 Blender 4.5.14 后台运行 `tools/mascots/build_duck_b2_combinations.py`。使用 `--detail-baseline --duck-only` 生成较密对照；`--hulls-only` 生成离线凸包。

然后运行 `node tools/mascots/audit_duck_b2_combinations.mjs`、`python tools/mascots/package_duck_b2_combinations.py` 和 `npm run structure:check`。脚本依赖工作区中的原始 B2 母模与竞品资源；本包交付的源 `.blend` 和 GLB 可直接查看，不依赖这些脚本运行。
