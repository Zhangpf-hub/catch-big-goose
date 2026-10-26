# 鸭子B2：小头小脚与抽象比例修订

用户否定了三款程序几何模型的形体，并补充：竞品头小脚小、比例夸张抽象，要求优化鸭子。当前阶段回到造型修订；原B方案的奶白、橙嘴橙脚、小黑眼和细长方向保留，头脚比例允许按最新要求改变。

## 当前交付

- [B2修订评审页](../../source-assets/models/candidates/duck-series-v1/concepts-b2/review.html)
- [完整鸭子三视图](../../source-assets/models/candidates/duck-series-v1/concepts-b2/duck-b2-turnaround.png)
- [蛋挞融合](../../source-assets/models/candidates/duck-series-v1/concepts-b2/duck-b2-eggtart.png)
- [钢杯融合](../../source-assets/models/candidates/duck-series-v1/concepts-b2/duck-b2-steelcup.png)
- [积木融合](../../source-assets/models/candidates/duck-series-v1/concepts-b2/duck-b2-numberblock.png)
- [内置生图完整提示词及来源](../../source-assets/models/candidates/duck-series-v1/concepts-b2/generation-prompts.json)

四张均为内置image_gen生图，已实际查看。相对第一版概念，头嘴和蹼足明显收小；组合以物件壳体为主，钢杯采用低位探颈，积木保留红壳与大数字，蛋挞保持浅盘结构。图中的比例目标不是三维量测结果，眼睛、脚及颈部的跨款一致性仍需后续母版统一。没有将这些图标为真实模型或同尺寸三维对照。

## 旧模型的问题与状态

先前制作直接用椭球、曲管、重采样和减面构造三种头颈，没有先验收独立3D母版。嘴脸衔接、头部曲面、颈胸过渡与脚部比例偏离设计；过早约束面数并不能解决这些形体问题。格式、尺寸、闭合性和glTF检查只证明技术有效性，不能证明造型通过。

`model-review-v1`标记为造型验收未通过，保留文件与旧ZIP用于追踪，不发布正式资源。用户本轮进一步明确了大物件、小头、小脚、夸张抽象的方向，后续不能机械保留原B的大头大脚比例。

## 产出质量的调整路线

1. 先锁定B2的抽象程度，再整理同一姿态与尺度的独立正、侧、背建模参考。补图只补结构，不另创角色。
2. 先做完整鸭子母版，采用参考图约束的细分曲面/雕刻逐视图校形；也可以使用多视图图生3D生成初始高模后在Blender校形。当前没有对B2做过图生3D实测，不能保证服务直接生成可用模型。
3. 先交付完整母版的正面、侧面、三分之四和参考叠图，确认脸嘴连接、头身比、颈胸曲线与小脚。母版不通过时不批量套壳。
4. 母版通过后，三款使用同一头部和身体网格，通过绑定/变形安排姿态，不按每件重新构造头颈。只让外壳与露出部位变化。
5. 形体通过后再重拓扑、烘焙与移动端预算检查；原高模保留，减面结果必须与母版做轮廓对比。实际GLB更新后重做同尺寸竞品对照。

已核实 [Tripo多视图](https://www.tripo3d.ai/product-doc/model-generation/multi-view-to-3d) 和 [Meshy多图建模](https://docs.meshy.ai/en/api/multi-image-to-3d) 接口存在，均要求同一对象多角度输入；这只是官方能力核实，不是本角色的质量实测或付费授权。本机实测GPU为RTX3070Ti 8GiB，[Hunyuan3D2.1官方](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1) 标准形状生成说明为10GB显存，故不将本机标准完整部署作为当前默认路线；未测试低显存变体。

本轮没有调用付费图生3D、安装模型依赖或更新旧三维。等待用户对B2比例修订确认后再推进3D母版。

本轮检查：四张PNG文件与评审页图片引用完整。目录检查时无新增文档断链，但工作区的Unity SDK中间目录 `Builds/WeChat/minigame` 已出现，导致“中间包应发布至命名builds目录”一项未通过。本轮没有运行Unity或微信构建，也未移动或删除该现有输出；不将这次结构检查记录为全部通过。
