# 圆形容器UV与材质适配

五套圆容器沿用R4几何；生成脚本逐顶点比较改动前后坐标，保留原始拓扑、Unity FBX GUID、碰撞支撑和铺放缓存。这里只补圆形UV、源贴图／MatCap映射与轻微木纹。

早餐竹纹、烧烤网格和可复用MatCap来自本项目留存的竞品资源，具体路径写在各`materials.json`与`metrics.json`。圆形UV、木纹、MatCap强度上限0.25属于项目适配，未宣称复原竞品原始Shader。五个GLB通过Khronos检查，0错误／0警告；无纹理预览材质可能产生UNUSED_OBJECT信息，完整Unity材质使用对应UV。

生成入口：`tools/unity/build_round_surfaces.py`；验证接入：`tools/unity/stage_round_surfaces.py`。原模型保留于Unity工程`SourceAssets/before-home-lighting-shake-20261025`，历史原始证据未改动。
