# 数码工坊完整主题

2026-10-22 已接入第五个主题 `electronics`，对应皮肤同名。普通件顺序为 phone、laptop、camera、headphones、handheld、speaker、mouse、smartwatch、radio。三个难度取前 4/6/9 种，共 48/54/81 个可消物件；后两关另有一只金鹅，冰封 4/7 件。

`tools/art/gen_electronics_scene.py` 生成 `tray_electronics`，底板厚度按最大水平边四单位时顶面落在游戏 y=0 对齐。皮肤为矩形边界，半宽与半深 1.63，视觉托盘四单位，不需要动态三角网格或额外物理引擎。

正式资源在 `reference-projects/catch-big-goose-cocos/assets/resources/models/`、`icons/`、`textures/bg_electronics.jpg`。首页第五站定义在 `HomeScreen.ts` 的 MAP_STATIONS 与 LevelConfig 的 CHALLENGE_MAPS，图标为 `station-medallion-electronics.png`。五站放进原有连续地图，避免添加整张大型地图图片。前五件从候选池迁入时保留了 `.meta` UUID。

`tools/prepare-electronics-assets.py` 把已验证批次投放到正式目录，转换背景 JPEG，并把图标转换为带透明通道的 PNG 调色板以控制包体。修改脚本中的背景源路径时应指向当前已授权生成的实际图片。高分辨率原图保留在 `source-assets/models/electronics/background-source.png`，不进入资源打包。

发布包仍必须低于 20 MiB。当前物件用两段盒体倒角、一段圆柱倒角，在 64px 下保留轮廓；不得通过提高资源上限绕开失败。当前包约 19.93 MiB，后续新增资源先重新评估大小。

若原工程在 Creator 中打开，使用 `tools/build-electronics-isolated.mjs` 对本次工程快照构建，避免与原工程争用日志，不关闭用户编辑器。该脚本验证构建标志、退出码、日志、资源体积后才替换本地预览包。常规构建仍遵从项目关闭编辑器的原要求。

实际端到端测试：`tools/electronics-runtime-audit.cjs` 覆盖三种窗口比例和三个难度；`tools/electronics-navigation-audit.cjs` 从水果篮滚动点击第五站，完成一关并检查结算、升关及主题成绩隔离。Playwright 依赖用环境变量 PLAYWRIGHT_MODULE 指向已有工具运行时，测试只修改独立浏览器存储，不写用户存档。

Creator 导入检查正式目录时使用 `verify_cocos_import.py --asset-dir reference-projects/catch-big-goose-cocos/assets/resources/models --icon-dir reference-projects/catch-big-goose-cocos/assets/resources/icons --library-project <实际构建快照的工程目录>`。输出范围与源候选池验证分开记录。
