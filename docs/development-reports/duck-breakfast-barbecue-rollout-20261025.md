# 早餐铺、烧烤摊正式接入 B2 鸭子

按用户“早餐 烧烤 两个关卡接入鸭子相关模型，替换大鹅相关模型”的指令，将两主题各 4 款大鹅组合替换为已制作的 B2 鸭子。

| 正式主题 | 替换后的模型 |
| --- | --- |
| 早餐铺 | 鸡蛋饼鸭、蛋挞鸭、小米饼鸭、馒头鸭 |
| 烧烤摊 | 茄子鸭、青椒鸭、煎饼鸭、土豆鸭 |

热身关的三件目标分别改为馒头鸭、煎饼鸭。挑战关每一层的候选池同步替换，物件总数、权重、类型数、倒计时、背景和容器保持原参数。其余三个主题的数据结构逐项比较一致。

修改位置为正式 [themes.json](../../projects/catch-big-goose-unity/Assets/Resources/Data/themes.json)、[theme-rounds.json](../../projects/catch-big-goose-unity/Assets/Resources/Data/theme-rounds.json)，显式映射保存在 [model-replacements.json](../../projects/catch-big-goose-unity/Assets/Resources/Data/model-replacements.json)。原始竞品文件与历史交付包保留；本轮没有重制模型。

为新碰撞形体重新模拟两主题共 4 个布局，合入 [prepared-layouts.json](../../projects/catch-big-goose-unity/Assets/Resources/Data/prepared-layouts.json)，保留其他主题的 6 个布局。配置编译和独立核对工具读取显式替换映射，后续重建配置不会还原旧大鹅 ID。

## 验证

- 独立对照冻结源关卡表：10 个正式阶段的数量、权重、层级和时间参数通过，仅授权的 8 个模型 ID 替换。
- Unity 2022.3.62f3 的正式游戏配置：移动端配置冷准备与桌面缓存重入均通过；两主题热身关各 15 件通过真实屏幕点击全部三消，含新鸭子目标。
- 两主题挑战关各生成 300 件，8 款鸭子均实际生成，旧大鹅组合未生成；网格与专用材质存在，真实屏幕拾取和 3D 托盘入槽通过。挑战关本轮没有自动清空全量 300 件；8 款模型逐件三消已有此前独立评审验收。
- 最终桌面测试确认 4 个新缓存均被采用。其他主题布局保持原数据。
- 当前 Windows 发行目录的 `resources.assets` 中，正式主题、阶段配置、预摆放缓存和替换映射均与当前源文件逐字节一致，验证了当前可执行包包含此次接入。

运行记录：[冷准备](../../work/duck-live-two-themes/live-cold-mobile/acceptance.json)、[最终缓存重入](../../work/duck-live-two-themes/final-cache-desktop/acceptance.json)、[源参数核对](../../work/duck-live-two-themes/configuration-verification.json)、[Windows 内嵌配置核对](../../work/duck-live-two-themes/windows-embedded-configs.json)。

Windows 正式游戏已重新启动并置前。入口为首页直接选择“早餐铺”或“烧烤摊”，无需进入独立评审菜单。成绩仍使用原主题 ID。

本轮 Windows 与 Unity 源配置完成接入；微信最终导出另有并行构建任务，本报告不将本轮因工程占用退出的微信构建记为成功。

最终目录结构检查 43 项通过，无失效文档链接。
