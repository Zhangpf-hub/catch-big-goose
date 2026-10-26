# 自有玉米 · 竞品路线候选

792 三角形、一个 mesh/primitive/材质、一张 512×512 颜色贴图，GLB 为 223372 字节（约 218 KiB），最大边 1.0、包围盒中心归零。玉米棒、三片闭合折叶和短茎保持连接位置，粒纹用原创程序贴图表现，几何与纹理未使用竞品资源。

识别要素：黄色长锥形玉米棒、纵横粒纹、三片绿色外翻苞叶、底部短茎。允许省略逐粒立体凸起、细叶脉和微小颗粒。

`review.jpg` 为四视图和 192/64px 图标；`corn.blend` 可继续编辑，`corn.glb` 为独立候选，`corn-basecolor.png` 是原创贴图，`verification.json` 记录检查边界。

已检查源网格闭合、尺寸归一和 GLB 回读；Khronos glTF Validator 零错误、零警告。已经查看四视图与 64px 实际缩略图，轮廓和三项主要识别特征可辨，但风格仍偏卡通，不能算作实物贴图路线的最终版本。

尚未运行物理管线、Creator/Unity 导入或真实游戏关卡；未替换任何正式模型或图标。自有现行玉米为 6576 三角形、6 个材质，本候选用于先验证资源预算收益。

复现：在工作区根目录，以 Blender 后台执行 `tools/competitor/generate_corn_candidate.py`，随后用有 Pillow 的 Python 执行 `tools/competitor/compose_candidate.py` 生成图标与总览。文件开头定义了完整参数，不需要图生 3D 或外部付费服务。
