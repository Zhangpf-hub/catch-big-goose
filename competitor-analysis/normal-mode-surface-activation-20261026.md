# 正常模式分层、手机摇动与局部重排复核

日期：2026-10-26。研究对象为本地冻结竞品包 402；没有取得竞品当前线上账号同机帧率、热更后的最终对象状态或新录制的手机视频。本章只补充静态证据和项目建议，未修改游戏实现。原始包、既有冻结证据均未改动。

## 结论

竞品确实有分开的渲染隐藏、刚体停模拟和局部重排机制。“全部库存存在于列表”不等于“全部渲染、全部动态”。但现有证据不能把 70 件说成竞品始终生效的硬上限，更不能把根物体 SetActive(false) 说成唯一或完整策略。

必须区分三个入口：手机加速度回调、ToolShake（枚举 6）和 ToolMessUp（枚举 2）。普通打乱道具进入第三条链：先选上层、临时冻结其物理、绕共同中心公转、最后将这些物品换到集合内原有位置；不是重新投放全部库存，也不是只让物品原位自转。

## 分层显隐和物理的原始证据

以下方法来自 [402 方法目录](evidence/2026-10-23-配置与模式/方法与调用图/method-map.json)。行号均指所链接文件的当前保存版本。

| 方法及位置 | 确认内容 | 不应扩大解读的部分 |
| --- | --- | --- |
| [CheckVisible / j10885](evidence/2026-10-23-配置与模式/方法与调用图/j10885.annotated.wat)，约 20–35 行 | 物件 Transform 世界 Y 与 GetDynamicVisibleHeight(index,1) 比较，再 SetVisible | 没有屏幕像素覆盖率、GPU occlusion 或五射线逻辑 |
| [SetVisible / j7288](evidence/2026-10-23-配置与模式/方法与调用图/j7288.annotated.wat)，约 25–140 行 | 切换 col 子 GameObject 激活状态、isHiding、主/蒙皮/附属 Renderer；调用 PlayAnim | 不等于停用整个 ObjectUnit 根物体；该方法未修改 realCol |
| [CheckRigid / j6450](evidence/2026-10-23-配置与模式/方法与调用图/j6450.annotated.wat)，约 20–110 行 | 比较单独深度阈值并检查当前 scale 与目标 scale；经 HideRigid 切模拟 | 隐藏阈值与物理阈值不是一个状态 |
| [HideRigid / j4344](evidence/2026-10-23-配置与模式/方法与调用图/j4344.annotated.wat)，约 25–115 行 | 已达目标状态、被选中、不可抓、存放等状态有保护；非强制冻结会检查线速度 0.2；SetRigid 最终写 isKinematic | 不是每帧对所有物件一刀切停模拟 |
| [CheckAllRigidAndVisible / j22259](evidence/2026-10-23-配置与模式/方法与调用图/j22259.annotated.wat)，约 25–80 行 | 遍历普通物件集合，先 CheckRigid，再 CheckVisible；刚体深度倍率按模式条件读取 | 列表遍历不证明每件都动态或都渲染 |
| [LoopOptimization / j74002](evidence/2026-10-23-配置与模式/方法与调用图/j74002.annotated.wat)，约 20–80 行 | 在非禁用状态下周期性 CheckObjMaxHeight + CheckAllRigidAndVisible，然后 yield TimerManager 持有的等待对象 | 当前方法没有直接写等待时长，不能凭这段宣称固定每帧或固定 0.1 秒 |

动态可见阈值为：`frontier - Lerp(minDepth,maxDepth,Clamp01((reference-frontier)/reference))*Min(multiplier,1)`。场景确认值为 min/max/reference=4/5/21、rigid multiplier=.5、frontier 单次下降 .5；实际世界尺度须由项目自行映射。原配置同时有 `_maxPhysicObjCount=70` 与 `_isUseRealPhysicSpace=0`，所以 70 是配置值，不能据此宣称所有模式恒定硬限 70。参见 [序列化深度参数](evidence/2026-10-23-配置与模式/关卡配置/LevelManager-depth.json)。

字段分工可用 [dump.cs](artifacts/competitor-config-trace/dumper/dump.cs) 32101–32126 行核对：`_rigid=0x14`、`col=0x18`、`realCol=0x1c`、`_render=0x20`、`_skinRender=0x24`。仅靠名字不证明两条 collider 的所有运行语义；本次仅陈述具体调用实际改了哪些字段。

## 手机摇动：只给已动态刚体施力

[j95011 手机回调](../work/r4-interaction-20261025/competitor/j95011.annotated.wat) 约 110–180 行恢复回调时间修正，约 345–450 行遍历物件并 CanShake/AddForce。两层门禁分别是 [CanShake / j21513](../work/r4-interaction-20261025/competitor/j21513.watfrag) 的 `!rigid.isKinematic` 与 [AddForce / j14312](../work/r4-interaction-20261025/competitor/j14312.watfrag) 的再次非运动学检查。该链不主动解冻、不强制显示下层。

静态可恢复公式为：

```text
timeFactor = Clamp(callbackDt,.033,1) * 5 * 6 * (.02/fixedDeltaTime) * modeForceMultiplier
excess = Clamp(length(rawAcceleration)-2,0,4*modeMaxMultiplier)
force = normalize(mappedRawAcceleration) * excess * currentCoefficient * timeFactor
```

场景的普通系数 7、iOS 字段 6，不等于每个线上模式最终必定使用该值。`_shakeOnceDepth=.5`、`_shakeMaxDepthCount=3` 属于另一条 ToolShake 链，不应混入手机回调。用户要求手机只摇当前可见且激活的最上层，比竞品单纯非 kinematic 判定更严格，应在项目中明确采用这一额外约束。

现项目 SHAKE3 对 0.30 秒窗口累计新增水平速度 1.2、竖直 0.6 进行封顶，并在 1.5 秒冷却内拒绝新 Request。对正反摇手机，若按绝对值累计消耗同一个预算，反向动作会在前几步后几乎无法继续输入；这可解释“检测到了但物堆没怎么动”的一种机制，但没有对应手机运行数据时不能断定它是唯一原因。应记录每步有效输入、实际施力物件数、可见位移与邻居变化，再比较有界的往返输入效果。

## ToolShake 与 ToolMessUp 的差异

枚举定义见 [dump.cs](artifacts/competitor-config-trace/dumper/dump.cs) 86383 行起。`ToolMessUp=2`、`ToolShake=6`。

### ToolShake：速度翻动物理

[ShakeObj / j43510](evidence/2026-10-23-配置与模式/方法与调用图/j43510.annotated.wat) 先按 `_shakeOnceDepth/_shakeMaxDepthCount` 有限次降低前沿并刷新深度，然后遍历调用 MessForce。新提取 [j21508](artifacts/surface-activation-20261026/j21508.annotated.wat) 只有 `!isKinematic` 才设置速度为 `(Random(-10,10),yforce,Random(-10,10))`。调用的 [j6321](artifacts/surface-activation-20261026/j6321.annotated.wat) 已通过元数据表槽核对是 `Rigidbody.set_velocity`，不是 AddForce。

### ToolMessUp：选上层公转，再换位

[UseTool / j10876](artifacts/competitor-runtime-trace/primary-methods/j10876.annotated.wat) 1255–1265 行调用 `MessObjRotaAnim`，1270–1280 行是另一个 ToolShake 分支。普通打乱对应 [j73982](artifacts/competitor-runtime-trace/primary-methods/j73982.annotated.wat)：

1. 约 85–170 行：先刷新最高高度；选 `item.y > _maxHeight - _messHeight` 且未 isStore 的物品，放入 canMessObj，并 `HideRigid(true,true)` 临时冻结。这里并未显式检查 isHiding 或原来是否 kinematic，项目的“仅原先激活上层”须额外收紧。
2. 约 175–255 行：将这些物品原有 world position 和 visible 标志放入 CreateInfo 列表。
3. 约 260–305 行：每次随机 RemoveAt 再 Add 改变物品顺序。不是已证明均匀分布的 Fisher–Yates。
4. 约 310–425 行：排序 CreateInfo；把随机物品顺序与原位置列表配对；以容器共享 `_rotaCenterUpTrans`、目标旧位置和随机旋转速度调用 InitRota。
5. [InitRota / j41506](artifacts/surface-activation-20261026/j41506.annotated.wat)：关闭 col 与 realCol 子 GameObject，保存中心 Transform、目标位置、速度。
6. [RotaAnim / j41503](artifacts/surface-activation-20261026/j41503.annotated.wat)：每帧 `RotateAround(center.position,center.up,speed*deltaTime*distanceMultiplier)`。这是围绕共同中心公转；同时 Y 以 `Clamp01(2*dt)` 向目标 Y 逼近，记录当前坐标。
7. j73982 约 590–700 行：运行 `_messRotaTime` 后对选中集合 `MoveToTargetPos(.3)`，等 .3 秒，再 `RotaToPos(1)`。 [MoveToTargetPos / j41505](artifacts/surface-activation-20261026/j41505.annotated.wat) 开启 col 与 realCol，再 DOMove 到目标旧位置；[RotaToPos / j41502](artifacts/surface-activation-20261026/j41502.annotated.wat) 在当前记录位置与目标旧位置之间插值，参数 1 保证到终点。
8. 最后逐件恢复原 scale，执行 CheckVisible 与 CheckRigid，并恢复控制。

因此它最终交换选中上层的位置，同时伴随共同中心公转；没有重新调用全局生成器、重新摆放下层或给全场物品重力落下。

实际场景 `_messHeight=4`、`_messRotaTime=1`、`_messRotaSpeed=[540,720]`、`_messRotaDisSpeedMul=[1.2,.15]`，参见 [LevelManager.json](artifacts/competitor-config-trace/serialized-verified/LevelManager.json) 2286–2306 行。这些是竞品场景单位。不能直接复制到项目后就声称视觉/碰撞和真机效果一致。新提取八个函数的元数据名称、主 WAT 源行和原始方法体 SHA-256 见 [index.json](artifacts/surface-activation-20261026/index.json)；这是静态提取，并未执行原动画链。

## 可采用的项目方案及验收约束

- 分层状态应明确区分渲染、交互、动态物理、静态支撑和库存；隐藏下层保持必要支撑即可，无需每次拾取/重排后全体解冻。上层露出时局部恢复，避免悬空或永久藏件。
- 动态与可见集应有预算和可测超限原因；不要让少于 70 件时“全部动态”的特殊分支掩盖边界跳变，也不要为了凑预算冻结正坠落或承担不稳定支撑的物品。
- 手机摇动和重排道具从同一个“当前可见、激活、最上层”候选集取快照；从此集合外的 hidden/held 件在整个操作期间位置、旋转、isKinematic、visible 都应保持不变。碰撞自然传递也不得使原未激活下层参与模拟。
- 重排采用短时局部可见公转/弧线，终点是集合内位置的置换；保留模型尺寸差异校验、边界与落位支撑检查。不能把不同尺寸物品盲目换位后的重叠当作“与竞品一致”。失败时恢复原姿态/物理状态，不消费无效道具。
- 手机摇动保留去重力滤波及时间归一化，给合理的有限持续时间和速度上限；以真实位置变化、转角、换邻居比例验收。仅“接受请求”“震动反馈”“脉冲次数”均不足以证明重排序有效。
- 性能记录至少覆盖 300/150/71/70/69/30 件，静止、连点拾取、连摇、打乱、返首页再进局；分开统计总库存、Renderer.enabled、动态体、活动动态体、深层隐藏、超预算原因、穿底恢复、主线程/物理/渲染耗时和帧时间分位数。Windows 移动档是代理，只能对应代理结论；手机微信包必须另采实际帧时间与画面。

### 手机摇动的量化调参起点

此表是本项目拟议起点，尚未实施或由手机验证，也不是竞品恢复参数。当前 `GooseRoundPreparation` 的 ItemScale 至少 .70，`GooseGame.CreateItem` 设置质量 .95；重力 19.81、摩擦 .6。现 .6 m/s 竖直预算的理想抛高只有 `v²/(2g)≈.009m`，每个 30Hz 物理步重力又贡献约 .66m/s 下落速度，足以解释为何短小的同向力难以解锁接触。水平静摩擦的简化加速度尺度约 `μg=11.9m/s²`；实际堆叠接触法线、挤压和质量分布会改变结果，不能把简化式视为求解器真实阈值。

| 项目 | 建议起点 | 目的与限制 |
| --- | --- | --- |
| 有效强摇窗口 | .45–.60 秒 | 窗口内接收往返方向，安静输入及时衰减；冷却不吞掉当前窗口中的有效反向输入 |
| 水平速度尺度 | 1.8–2.4 m/s | 以最终有符号速度/逐步增量限制，不能前几帧耗尽绝对路径预算 |
| 强摇短抬升速度尺度 | 2.0–2.8 m/s | 理想抛高约 .10–.20m，约当前 .70 尺寸的 14–28%；仅候选上层且须容器/穿底检查。主动抬升是项目适配，不冒充竞品手机回调 |
| 总线速与角速上限 | 4–4.5 m/s、8 rad/s | 限制飞出、恢复负担及碰撞尖峰 |
| 目标数 | 40–48 件以内 | 从同一可见激活表层集合选取；不是从深层补够数量 |
| 最小运动门槛 | 候选中 ≥25% 移动 ≥.35×ItemScale；≥20% 最近邻改变 | 与重排结果相关；微抖动、接受次数不算有效翻动 |
| 隔离与收敛 | 集合外 hidden/held 的位姿和状态不变；停摇约 2 秒后主要物件静稳 | 对高瘦形状可单列更长收敛时限，不应伪造一刀切通过 |

指定验收设备为 iPhone 15 Pro。需要在实际微信新包上录制上述输入、画面和帧时间；本章没有新增该设备的实测结果。具体速度值应依据多主题不同形状调低或调高，并以实际效果和安全边界共同确定。

## 官方资料复核

Unity 2022.3 的运动学刚体由脚本/动画控制，可保留对其他动态体的碰撞支撑；因此隐藏深层与保留静态支撑可以独立处理。见 [Rigidbody.isKinematic](https://docs.unity3d.com/2022.3/Documentation/ScriptReference/Rigidbody-isKinematic.html)。

Force 模式的新增速度取决于 `force*fixedDeltaTime/mass`，多次 AddForce 会在下次模拟前累计。不能把传感器回调频率、物理步长和每次回调力值分别调大后视作等效。见 [Rigidbody.AddForce](https://docs.unity3d.com/2022.3/Documentation/ScriptReference/Rigidbody.AddForce.html)。

同网格同材质可 GPU instancing，Shader 须支持；SkinnedMeshRenderer 不支持此常规路径。它能减少重复模型提交，但不能代替物理分层，也没有证据证明竞品一定用了某种实例化方式。见 [Unity 2022.3 GPU instancing](https://docs.unity3d.com/2022.3/Documentation/Manual/GPUInstancing.html)。

以上官方资料于 2026-10-26 在线核查。未把 Unity 6/7 专属优化路径当作本项目 Unity 2022.3 可直接采用的能力。
