# 鸭子 B 三款代表模型与竞品同尺寸对照

日期：2026-10-25。用户已确认B母版及三款融合方向，本轮要求先交付真实模型效果，并与竞品同类模型同尺寸比较，由用户验收。

后续验收结果：**用户否定了本轮模型形体，未通过造型验收**。本章保留技术检查和对照记录，不再作为可发布模型结论。最新方向见[鸭子B2小头小脚抽象比例修订](duck-b2-abstract-shape-revision-20261025.md)。

## 查看模型效果

- [三分之四对照](../../source-assets/models/candidates/duck-series-v1/model-review-v1/renders/comparison-hero.png)
- [游戏俯视对照](../../source-assets/models/candidates/duck-series-v1/model-review-v1/renders/comparison-gameplay.png)
- [192/64px 图标对照](../../source-assets/models/candidates/duck-series-v1/model-review-v1/renders/thumbnail-comparison.png)
- [完整模型评审与文件入口](../../source-assets/models/candidates/duck-series-v1/model-review-v1/model-review.html)
- [制作说明、预算与复现方式](../../source-assets/models/candidates/duck-series-v1/model-review-v1/README.md)

全部图片来自实际GLB回读渲染。左侧为竞品Goose_EggTart、Goose_SteelCup、Goose_GTNumberBlock静态姿态提取件，右侧为本轮原创几何；不是继续生图。双方按完整模型最大边归一到1并居中，不改变纵横比例。同视角使用相同正交尺度1.48、镜头、灯光与画布；保留资源保存姿态，没有按截图单独裁切放大。竞品源材质为恢复后的基础色/PBR近似，非原游戏Shader或真机截图。

## 实际结果

蛋挞鸭3,672面/86,028字节，钢杯鸭3,706面/88,100字节，积木鸭3,328面/77,332字节。三款均为一个网格、一个材质、一个primitive，256px配色图集，GLB小于90KiB；提供可编辑Blender构件、归一化单材质源件、FBX、GLB、纹理、五视角及透明图标。

采用同一头颈与宽扁嘴构造。蛋挞使用薄盘壳体与平面烤色，避免凸起斑块读成饼干；钢杯采用侧放杯体、厚杯沿与内壁，鸭颈从杯口伸出；积木采用红色圆角壳、侧颈连接和绿色数字。几何与贴图只在新的候选目录中生成，未改竞品原文件。

GLB回读的尺寸、居中、闭合壳体、退化面检查通过；Khronos三款零错误、零警告、零提示。同尺寸对照的镜头、灯光、画布、源哈希和透明留白检查通过。离线凸包提供独立OBJ和几何报告，尚未进行Unity/PhysX运行验证。

实际查看主视角、俯视、其他视角及小图；三种外壳的大色块可区分，64px下眼睛与烤色细节减弱。模型具体比例和同尺寸占形是否符合产品预期，交由用户本轮验收。对照图展示出鸭子较高的头颈及露出的蹼足，不强行把外壳放大到竞品外壳同宽，以免掩盖完整模型占形差异。

## 当前边界

本轮状态为**等待用户模型验收**。未做Unity正式导入、实际关卡碰撞/拾取/三消或手机性能测试，未替换首页或五主题，未扩展其余17款。用户验收后的调整以三款效果为准再推进，不将此前概念确认当成本轮模型已批准。

源码入口是 `tools/mascots/build_duck_representatives.py`、`audit_duck_representatives.mjs` 与 `compose_duck_review.py`。Blender实时连接不可用，本轮使用已配置的本地Blender 4.5.14后台模式；没有调用付费第三方生成服务。
