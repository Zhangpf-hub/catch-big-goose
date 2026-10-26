# 抓住大鹅 · 参考工程还原版

本机环境、编辑器位置和开发命令见 [本地开发说明](docs/local-development.md)。双击根目录 `开发终端.cmd` 可加载已配置的开发环境。

## 当前工程与来源

**实际运行工程是 `reference-projects/catch-big-goose-cocos/`，使用 Cocos Creator 3.8.8。**

此前的 `OrchardGame` / `OrchardHud` / Three.js 水果篮是另写的简化版，并不是参考项目。本次已从本机 `work/upstream-playable/game/` 直接迁入参考工程的源码、资源、场景和发布模板，不再用程序化球体和自制菜单代替参考内容。

- 原版引导页、地图首页、难度选择、游戏 HUD、道具、暂停和结算流程。
- 水果篮、古玩铺、池塘农场、甜品小镇、数码工坊五个主题，以及轻松、标准、大师难度。
- 50 个正式 GLB 资源，另有 3 个历史候选；配套图标、页面切图、背景和音效，保留已有 `.meta` UUID。
- 原版 Jolt WASM 物理、模型碰撞、三消、道具、存档与音频逻辑。
- 保留当前 `reference-projects/catch-big-goose-cocos/` 的工程 UUID，避免同一目录在 Dashboard 中变成另一个工程。

旧版完整备份：`work/cocos-simplified-backup-20261009-180118/`。原参考目录没有修改。

## 启动方式

### 运行已构建的游戏

在仓库根目录执行：

```powershell
npm run dev
```

浏览器访问 `http://127.0.0.1:5185/`。`dev` 和 `preview` 现在服务的是 **`reference-projects/catch-big-goose-cocos/build/web-mobile/`**，不再启动旧 Vite 原型。服务设置禁止缓存，避免持续看到旧发布包；若端口已占用，可以执行 `python tools/serve.py --port 5186` 并访问 `http://127.0.0.1:5186/`。

初次进入应看到参考版引导页，完成引导后进入地图首页，而不是“鹅鹅农场”的绿色简化弹窗。

### 在 Creator 中编辑和发布

1. Dashboard 导入或打开仓库下的 **`reference-projects/catch-big-goose-cocos/`**，编辑器版本选 **3.8.8**。
2. 等资源导入完成，打开 **`assets/scene/main.scene`**（`scene` 是单数；旧入口 `assets/scenes/main.scene` 已停用）。
3. 点击编辑器的浏览器预览，即可进入引导页、地图首页和关卡。已打开的旧预览页面需要刷新，才能重新执行启动流程。
4. 正式发布时先保存。Windows 下关闭这个工程的 Creator，再在仓库根目录执行 `npm run build`；构建成功后运行 `npm run dev`。

编辑器预览通过 `reference-projects/catch-big-goose-cocos/preview-template/jolt-glue.js` 加载 Jolt，正式发布通过 `build-templates/web-mobile/jolt-glue.js` 提供同一文件。升级 Jolt 或文件缺失时，运行 `node tools/art/gen-jolt-glue.mjs`，会同时生成并同步两份文件；回归测试检查它们逐字节一致。编辑器预览使用 Creator 的页面外壳，正式 H5 包还包含参考项目的自定义加载页。不要开启发布包的 MD5 缓存，否则固定路径的 Jolt 胶水文件会被改名。

## 技术栈

| 层次 | 当前使用 |
| --- | --- |
| 引擎 | Cocos Creator 3.8.8，原生 3D 场景与 UI |
| 语言 | TypeScript |
| 物理 | Jolt Physics 1.1.0，WASM；不是旧简化版的 Cannon |
| 美术 | GLB 模型、PNG 页面切图和物件图标，保留参考资源 UUID |
| 数据 | 原版 `SaveData` 本地存档、主题成绩与每日次数；道具每局默认各 1 个，局中奖励和通关后下一局的星级奖励额外叠加 |
| 发布 | Web Mobile release/WASM，自定义 HTML/CSS 加载页 |
| 检查 | TypeScript、Node.js 回归测试、资源与构建产物门禁 |

## 目录结构

```text
.
├─ reference-projects/catch-big-goose-cocos/                         # Dashboard 打开的实际工程
│  ├─ package.json                # 3.8.8 标识、Jolt 依赖、原工程 UUID
│  ├─ assets/
│  │  ├─ scene/main.scene         # 原版场景入口
│  │  ├─ tools/art/core/
│  │  │  ├─ Bootstrap.ts          # 原版启动入口，创建 GameManager
│  │  │  ├─ GameManager.ts        # 游戏流程与交互
│  │  │  ├─ JoltLoader.ts         # 加载发布包根目录 Jolt 胶水
│  │  │  ├─ JoltWorld.ts          # 物理世界与碰撞代理
│  │  │  ├─ LevelConfig.ts        # 四主题与难度配置
│  │  │  ├─ HudUI.ts              # 游戏 HUD、弹窗和页面调度
│  │  │  └─ ui/                   # 引导、地图首页、UI 路由与组件
│  │  ├─ resources/               # 模型、图标、切图和音频
│  │  └─ models-pool/             # 参考工程保留的候选模型
│  ├─ settings/                   # 原版引擎模块与项目设置
│  ├─ build-templates/web-mobile/ # HTML/CSS 加载页、Jolt 胶水
│  ├─ preview-template/           # 编辑器预览用的 Jolt 胶水
│  └─ build/web-mobile/           # 本机重新生成的 H5 发布包
├─ tools/                         # 检查、构建、禁缓存预览服务
├─ tests/                         # 原版回归测试，检查当前 cocos 源码
├─ tools/art/                       # 原版资源加工工具
├─ web/                           # 保留的旧 Three.js 原型，不参与当前启动
└─ work/                          # 原参考项目与旧版备份，不参与构建
```

## 检查与维护

### 竞品对齐（2026-10-22）

[首轮对齐与算法复核](docs/development-plans/竞品对齐与算法复核_20261022.md) 记录 Unity 迁移版的接触材质、简化碰撞与贴图预算修改，以及尚待许可证可用后进行的运行验收。[竞品参考目录](reference-projects/competitor-goose/2026-10-22/README.md) 包含 17 个静态物品模型、贴图、总览图与 18 个经过签名核对的 WASM 方法体分析；参考文件单独存放。原创低模玉米候选位于 `source-assets/models/candidates/competitor-alignment-corn/`，未替换正式资源。

### Blender 三消模型管线

已安装 Blender 4.5 LTS 与本机 MCP，生成规范与可复用 skill 位于 [skills/match3-model-pipeline/SKILL.md](skills/match3-model-pipeline/SKILL.md)。[数码工坊接入与验证](source-assets/models/candidates/electronics-v2/VALIDATION.md) 包含九件电子产品、工作台托盘、背景、地图第五站和三档关卡，正式资源已进入 `reference-projects/catch-big-goose-cocos/assets/resources/`。首批五件历史版本保存在 `source-assets/models/candidates/electronics-v1/`；Excel 模型台账位于 `outputs/01a15ee5-dea9-76b2-917c-bc8251d360fc/存量模型管理台账_20261021.xlsx`，已更新为 53 个模型与五主题映射。

### 宣传片奖励（H5）

每局倒计时首次达到初始时长的一半时，一只背着三种道具的大鹅从右向左走过，约 14 秒后离场。点击后随机播放 `video/` 中的两支 MP4 之一；观看期间暂停计时、物理和背景音乐，完整播放后返回对局，随机增加一个移出、凑齐或打乱道具。提前关闭、播放失败和加载超时均不发奖。

每局首次超时时先弹出复活提示，完整观看宣传片后补时 **60 秒**，保留当前物件、槽位和得分。提前关闭会回到复活提示，可重试或放弃；第二次超时直接结算。超时复活前不发结算奖励，避免同一局重复领取。

`npm run build` 自动复制两支完整 MP4 到发布包的 `video/`，视频约 40 MiB，按需加载并单独核验；游戏资源仍执行原有 20 MiB 门禁。部署时须上传整个发布目录。编辑器首次预览前执行 `npm run sync:videos`；`dev` 和 `preview` 也会自动同步。下载中的 `.ytdl` 和 `-Frag` 文件不参与发布。当前播放器用于浏览器 H5，微信小游戏原生播放器适配仍属后续工作。

```powershell
npm run check
npm run build
npm run preview
```

`check` 检查当前 `reference-projects/catch-big-goose-cocos/`，覆盖存档容错、模型加载、统计队列、主题资源和发布包完整性。`build` 拒绝与 Windows 下打开的同一工程编辑器并行运行，检查真实玩法脚本与 Jolt 文件，避免空壳包。Creator 的成功退出码 36 由脚本正确处理。

依赖安装：根目录 `npm install`，Cocos 工程 `npm --prefix cocos ci`。检查需要 Node.js、Python 3.8+、Git for Windows 的 Bash；Creator 非默认安装路径可设置 `COCOS_CREATOR`。

远程页面装饰图保留原参考项目的本地降级资源；统计接口默认关闭，不自动上传事件。旧 Web 原型保留独立规则文件 `web/game.ts`，可用 `npm run check:web` 检查，但缺少历史 `web/main.ts`，不作为当前游戏运行入口。
