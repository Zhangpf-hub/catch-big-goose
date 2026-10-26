# 算法方法体复核 · 2026-10-22

> 此页为首轮 18 个方法的研究记录。后续已扩展至 34 个签名匹配方法，并完成原 WASM 隔离执行、C# 对照和 Unity 接入；当前结论见 [生成算法](../../../../竞品分析/03-生成算法.md)、[深度与物理](../../../../竞品分析/04-深度与物理管理.md) 与 [验证记录](../../../../竞品分析/07-验证结果与后续清单.md)。本页中运行参数、完整生命周期等未确认边界仍需遵守。

> 2026-10-23 后续：本地实际权重和场景序列化值已经取得；版本 402 映射 344 个匹配入口／251 个独立函数体。具体更新见 [实际配置](../../../../竞品分析/08-实际关卡权重与深度参数.md) 与 [模式链](../../../../竞品分析/09-各模式调用链.md)。在线最终取值、完整生命周期和未展开的模式仍需区分。

对象：本机微信小游戏《抓大鹅》，AppID `wxb98ac240fd74b0e3`，本地版本目录 `401`。这是静态二进制研究，不是恢复的原始 C# 工程。没有执行提取的游戏脚本，没有连接竞品服务器，没有修改竞品缓存。

## 本次比旧报告增加了什么

旧报告只读取 `global-metadata.dat` 的声明。缓存中的同名 `.wasm.br` 确为 1 字节占位，但同一个 AppID 的安装分包包含实际代码。

| 来源 | 取得的内容 |
| --- | --- |
| `_wasmcode_.wxapkg` | Brotli 展开后的 WASM 为 18,128,665 字节 |
| `_wasmcode1_.wxapkg` | 第二个有效 WASM，为 22,842,675 字节 |
| `__WITHOUT_MULTI_PLUGINCODE__.wxapkg` | 微信/Unity 桥接 JavaScript、配置及图片；没有执行 |
| WebGL data 缓存 | IL2CPP 元数据 v29 |

解析得到 CodeRegistration `0x26b030`、MetadataRegistration `0x142220`。Il2CppDumper 6.7.46 输出的方法指针通过主 WASM 的真实 element table 映射到函数；本次保留 **18 个签名匹配的编译后方法体**，见 `recovered/method-map.json` 和同目录 `.wat`。额外一个 `GetUnit` 的签名不匹配，已剔除，不解释其方法体。

WASM 标识符可能包含多个 `$`，解析 element table 时必须按空白切分。按 `\$\w+` 搜索会把 `$fimport$510` 错分为两个函数，导致指针错位。本次已修正，并逐个验证参数与返回值签名；生成的分析模块也通过 WABT 的名称解析、类型和控制流校验。

WABT 的高级 `wasm-decompile` 在该样本上报内存越界；最终使用经过校验的 WAT 指令直接分析，没有把失败的 C 类反编译输出当证据。完整临时二进制和工具位于工作区 `work/`，交付目录只保留相关方法与索引。

## 1. 生成中确实使用权重与历史修正

`LevelManager.CreateLevel` 的方法体出现 `Method$Kunpo.KFakeRandom<int>.Roll()` 的实际调用，随后还有候选移除。这里已超出“仅存在一个随机工具类”的证据强度，但仍需区分不同生成分支。

`KFakeRandom<T>.RollIndex` 的指令流程可以概括为：

1. 累加每个候选当前的 `pro`，写入累计权重表。
2. 调用 `UnityEngine.Random.Range(0, totalWeight)`。
3. 选择第一个累计权重大于抽取值的候选；边界回落为最后一个索引。
4. 总抽取次数加一；命中后调用 `CalProToAlloc`，随后调用 `AllocPro`。

泛型上下文槽位 23、24 分别对应这两个修正函数，已经和生成的 RGCTX 声明交叉核对。`RealRandomRollIndex` 则读取当前权重抽取并增加总次数，但没有调用上述两个修正函数。

`CalProToAlloc` 更新命中项的次数和实际频率，计算实际频率与初始概率的差额，并调整该项的当前 `pro`。`AllocPro` 把待分配量按其他候选的初始概率比例分配，同时更新它们的实际频率记录。因此该实现有**依赖历史的权重补偿**，不能描述成每次独立均匀随机，也不能把“伪随机”直接说成作弊。

尚未确定：全部关卡采用哪一个入口、候选初始概率的实际数值、各生成分支中的调用次数。尤其不能由此推导“玩家快失败时临时更换物品”。

## 2. 连续位置采样也有权重

`ValueManager.GetWeightMultiPart(min[], max[], weightList[])` 为区段 i 加入权重 `(weightList[i].x + weightList[i].y) * weightList[i].z`，通过 `KFakeRandom<int>.Roll()` 选区段，再调用 `GetWeightRandom` 在区段内采样。生成协程 `LoopCreateObj.MoveNext` 确实调用了这两个方法，结果参与位置向量缩放。

`GetWeightRandom(min,max,w0,w1)`：端点权重近似相等时调用均匀的 `Random.Range(min,max)`；否则指令直接对应：

```text
r = Random.Range(0, (w0 + w1) / 2)
d = w1 - w0
b = 2 * w0 / d
t = sqrt(2 * r / d + b * b / 4) - b / 2
result = min + (max - min) * t
```

这是方法体的算式转写。该分支对权重取值有配置域假设，本次没有取得所有区段数值，也没有证明任意递减权重都能正确使用该式。不要直接作为无输入校验的通用生产函数复制。

## 3. 深度阈值的具体计算已经读到

结合 `LevelManager` 字段偏移，`GetDynamicVisibleHeight(index,multi)` 可转写为：

```text
touch = index == 1 ? _minTouchHeight : _p2MinTouchHeight
ratio = Clamp01((_minVisibleY - touch) / _minVisibleY)
depth = _visibleMinHeight + (_visibleMaxHeight - _visibleMinHeight) * ratio
threshold = touch - depth * Min(multi, 1)
```

`CheckVisible` 比较物品的**世界坐标** `position.y` 与该阈值，调用 `ObjectUnit.SetVisible(position.y >= threshold)`。`CheckRigid` 则额外检查物品当前缩放与目标缩放是否近似相等，再决定 `HideRigid`；两条路径是独立的。

`LoopOptimization.MoveNext` 在非暂停分支调用高度检查与全体刚体/显示检查，随后让出协程。资源中的 `_rigidDepth`、最大物理数量和这些深度参数的运行值没有完整提取，不能仅凭阈值公式猜一个生产用常数，也不能把深层碰撞全部删除，否则上层可能失去支撑。

## 4. 难度变体与三消的边界

`GetMainLevelABOffsetTypeCount(layer)` 从 `_dailySimpleABData.ReduceType` 读取对应层索引；`GetMainLevelABOffsetGroupCount(layer)` 从 `ReduceGroup` 读取。对象、数组或索引不可用时返回 0。`CreateLevel` 中可见以总数量除以 3 计算组数，再应用相关偏移和边界处理。

`GetTriple(type)` 的这个编译体没有直接完成三件消除，而是对 `IGameModeLevelCtrl` 的接口槽位进行调用。完整三消、补货和胜利条件必须继续追踪对应的模式实现。原报告中的“连续三根玉米消除、露出既有下层、未观察补货”仍是有效的局部实测，不能扩展为所有玩法。

目前没有验证：固定随机种子、每次重试同布局、保证可解、按七格占用实时调整难度、全局保底。自有项目的固定种子和完整三消集合属于自己的设计。

## 工具与复现依据

- 容器封装格式参考：[pc_wxapkg_decrypt 原作者仓库](https://github.com/BlackTrace/pc_wxapkg_decrypt)。工具仅针对用户指定竞品的本地文件处理。
- 指针与字段解析：[Il2CppDumper](https://github.com/Perfare/Il2CppDumper)，采用官方 v6.7.46 发布件。
- WASM 读取与验证：[WABT](https://github.com/WebAssembly/wabt)，npm 1.0.39 包的 SHA-512 与 registry 完整性值一致。
- IL2CPP 编译性质：[Unity IL2CPP 文档](https://docs.unity.cn/Manual/scripting-backends-il2cpp.html)。编译体不保留原始 C# 的完整语法、变量名和注释。

`package-inventory.json` 保存本地分包来源、条目长度与哈希；`recovery.json` 保存元数据和两个 WASM 的哈希；`recovered/` 保存签名、指针、校验后的分析模块及逐个方法体。
