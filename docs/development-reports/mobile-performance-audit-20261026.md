# 正常模式其余性能热路径审计

日期：2026-10-26。范围：当前 Unity 2022.3.62f3 源码的只读检查。本文没有修改光照、材质、分辨率、抗锯齿或运行实现；没有进行真机 CPU/GPU A/B。当前工作继续优先验证本轮分层激活、局部拾取和表层重排的成本与画面。

## 首要发现：正常关卡仍有实时阴影

`GooseRuntimePerformance.Configure()` 虽在移动档设置 `QualitySettings.shadows=Disable`，但这不是最终关卡状态。`GooseGame.ReferenceScene` 会检测主题是否包含 `ref_` 物件，`BeginRound()` 随后调用 `ReferenceLighting.Apply(ReferenceScene)`。正常主题使用这套模型，因此会进入 `Apply(true)`。

`GooseReferenceLighting.Apply()` 重新设置方向光为 Hard、全局阴影为 HardOnly；当前 `Resources/Data/reference-look.json` 的 `shadows=true`、`shadowDistance=32`。`GooseReferenceOpaque.shader` 有独立 SHADOWCASTER pass，共享光照片段使用 `UNITY_LIGHT_ATTENUATION`。所以可见模型增加时，主画面提交之外还存在阴影投射与接收成本，不能根据启动时的移动档配置声称正式关卡已关闭阴影。

可复查源码：

- [关卡与参考材质路径](../../projects/catch-big-goose-unity/Assets/Scripts/GooseGame.cs)，`ReferenceScene`、`BeginRound()`。
- [最终关卡灯光状态](../../projects/catch-big-goose-unity/Assets/Scripts/GooseReferenceLighting.cs)，`Apply()`，约48—58行。
- [当前光照配置](../../projects/catch-big-goose-unity/Assets/Resources/Data/reference-look.json)。
- [不透明材质的投影pass](../../projects/catch-big-goose-unity/Assets/Resources/GooseReferenceOpaque.shader)与[共享片段光照](../../projects/catch-big-goose-unity/Assets/Resources/GooseReferenceLighting.cginc)。

**本轮不直接关闭阴影。** 后续真机应分离主画面、阴影、透明层的提交与GPU耗时；若尝试收紧阴影覆盖范围，应以实际可见投影、轮廓和接触关系不变的截图对照为前提。不能直接把shadowDistance从32改成较小数字并推定画质相同。

## 模型与材质提交

GPU instancing并非没有开启：`GooseReferenceMaterialImport.cs:40` 已设置 `material.enableInstancing=true`，Opaque和Glass Shader均有 `multi_compile_instancing`；移动材质缓存也按共享原材质复用，未在每帧为每件创建新材质。后续需要验证实际同Mesh、同Material的分组与阴影变体是否批次合并，不能只再打开一次开关。

当前玻璃材质保留透明混合、`ZWrite Off`、独立材质分组；多层玻璃与不透明部件重叠会增加透明提交和像素覆盖。Opaque片段还按材质关键词保留AO、单/多MatCap采样。这些是现有外观组成，不能为提高帧率直接删除透明层或统一为简化色块。

改前本地结构基线见[device-benchmark.json](../../work/mobile-surface-performance-20261026/baseline/device-benchmark.json)：

| 场景/阶段 | 可见件 | Renderer/材质槽 | 可见几何三角形 | 实际计数器 draw calls / SetPass |
| --- | ---: | ---: | ---: | ---: |
| 早餐，拾取后 | 117 | 165 | 149,256 | 273 / 90 |
| 乡野，拾取后 | 163 | 200 | 144,999 | 383 / 74 |
| 杂货，拾取后 | 220 | 502 | 242,172 | 615 / 144 |
| 参考玩具300，拾取后 | 170 | 224 | 244,548 | 431 / 99 |

这是Windows graphics player强制移动档的改前记录。静置阶段的图形计数器返回0，属于该运行窗口计数不可用，不能解释为没有绘制。也不能由上述draw calls或桌面33.33ms限帧推断手机FPS；它们仅说明除了动态刚体，Renderer、材质分组和额外渲染pass仍是应测对象。

## 其余每帧路径

| 路径 | 已确认行为 | 判断 |
| --- | --- | --- |
| `GooseGame.Update()` / `GooseHud.Refresh()` | 每帧调用Refresh，但有状态hash；数字组件还按值缓存，只在秒数或库存等改变后改图形 | 没有发现按物堆300件逐个刷新HUD的逻辑，不应先改UI画质 |
| Selection | 指针开始/移动/结束才查询场景；缓存PointerEventData、命中数组与UI命中列表。高亮只在MainCamera、且有当前目标时执行；单目标包含轮廓/光晕等额外pass | 可测按住复杂模型时的附加成本；不是静置时随全堆数量线性执行的高亮循环 |
| PhoneLayout / Overlay | 每帧读取安全区与Canvas scale，尺寸未变就返回；Overlay仍写同步属性 | 有小型常驻工作，未发现物堆数量放大，优先级低于物理与渲染提交 |
| 首页/装饰 | 首页进入关卡后隐藏root、关闭相机与独立灯；SceneDressing默认关闭；托盘相机仅有托盘物件时启用 | 不是正常关卡同时持续绘制首页模型的证据 |
| 材质加载 | Shader/模型扫描主要发生在准备、实例化或外观切换；共享材质复用 | 未发现正常静置时全堆Resources.Load或逐帧材料克隆 |
| 容器 | 静置时扫描边界只处理动态件；收拢中仍会对held支撑做kinematic MovePosition，并移动32面墙 | 收拢阶段的代价仍随支撑件数增加，需单列测量；不得把kinematic等同于零成本。摇动暂停收拢、重排暂停写入，但不是已证明所有收拢真机成本达标 |

对应源码：[HUD](../../projects/catch-big-goose-unity/Assets/Scripts/GooseHud.cs)、[数字缓存](../../projects/catch-big-goose-unity/Assets/Scripts/GooseSpriteNumber.cs)、[选择输入](../../projects/catch-big-goose-unity/Assets/Scripts/GooseGame.Selection.cs)、[选择高亮](../../projects/catch-big-goose-unity/Assets/Scripts/GooseSelectionHighlight.cs)、[容器](../../projects/catch-big-goose-unity/Assets/Scripts/GooseCircularContainer.cs)、[模型材质缓存](../../projects/catch-big-goose-unity/Assets/Scripts/GooseAssetCache.cs)。

## 后续明确待项

1. 本轮先完成恢复完整轮廓后的300件静置、连续拾取、收拢、摇动、重排成本对照；同时记录可见件、Renderer、活动/唤醒刚体、深度查询预算与CPU时间。
2. 在真实手机上区分CPU与GPU限制，记录实际画布尺寸、30FPS目标下P95和>50ms帧比例；静置、按住高亮、收拢、连续操作分别采样，不把QA断言耗时算作发行帧成本。
3. 对正常关卡当前阴影、透明层、实际GPU instancing进行同画质A/B；只有能复现且通过画面对照的改动才进入实现。

本文不确认真机性能通过，也不以关闭阴影、减少玻璃、降低DPR/MSAA或让物堆出现空洞作为优化结果。
