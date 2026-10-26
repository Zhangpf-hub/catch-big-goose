# 首页奶油圆桌候选

独立家具资源，保持首页直径4.6、高度1.2；不套用可拾取物件最大边1的归一化规格。1496三角面、2个材质，奶油贴图64²、木纹256²、MatCap128²。桌面倒角、独立桌沿、收细桌腿及连接框均含UV；首页无家具刚体。

`home-table.blend`为可编辑源文件，`home-table.glb`已回读验证尺寸、材质和UV，`home-table.fbx`接入Unity；四视图和192／64图标是候选验证输出。Khronos结果见`validation.json`，错误及警告均为0。Unity首页真实渲染在`work/home-lighting-shake-20261025/delivery-home`，不是Blender预览代替实机。

复现：Blender后台运行`tools/unity/build_home_table.py`，再用Python运行`tools/unity/stage_home_table.py`。正式资源保留已有meta，不覆盖GUID。光照、脚底锚点与阴影承接实现见开发报告第38章；手机表现仍需扫码验收。
