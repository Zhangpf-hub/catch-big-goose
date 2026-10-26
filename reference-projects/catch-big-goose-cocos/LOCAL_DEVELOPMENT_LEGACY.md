# 本地开发说明

准备日期：2026-10-21，Windows x64。

## 工程入口

实际开发工程是 `reference-projects/catch-big-goose-cocos/`，使用 **Cocos Creator 3.8.8 + TypeScript + Jolt Physics 1.1.0**。
它是包含四个主题、三种难度、道具和视频奖励的 3D 物理三消游戏。
入口场景是 `reference-projects/catch-big-goose-cocos/assets/scene/main.scene`。根目录 `web/` 是保留的旧原型。

## 已配置环境

| 工具 | 本机状态及位置 |
| --- | --- |
| Cocos Creator | 3.8.8，`D:\开发\CocosEditors\3.8.8\CocosCreator.exe`；已设置用户环境变量 `COCOS_CREATOR` |
| Node.js | 24.22.1，`%LOCALAPPDATA%\Programs\NodeJS`；官方压缩包安装，已校验 SHA-256，已加入用户 PATH |
| npm | 11.19.1，随 Node.js 安装；使用 `https://registry.npmjs.org/` |
| Python | 3.12.14，复用本机 Codex 附带运行时；已加入用户 PATH，并设置 `PYTHON` |
| Git / Bash | Git 2.53.0、Bash 5.2.37，复用现有 Scoop 安装 |
| 工程依赖 | 根目录和 `reference-projects/catch-big-goose-cocos/` 均已按各自的 `package-lock.json` 安装 |
| 资源缓存 | 已由 Creator 首次导入，生成引擎声明、资源缓存和 H5 发布包 |
| 宣传片 | 两支完整 MP4 已同步至预览模板和发布包，合计约 40 MiB |

Python 的实际路径为
`C:\Users\123\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`。
它目前可以正常运行预览服务、语法检查，且已有 NumPy/Pillow；本次没有另装独立 Python。
如以后卸载或清理 Codex 运行时，需要重新配置 Python 的 PATH 和 `PYTHON`。

Creator 来自 [Cocos 官方团队提供的 3.8.8 修订包](https://forum.cocos.org/t/topic/172450/20)，可执行文件数字签名有效。
版本管理和编辑器使用方式可参考 [Cocos 官方安装说明](https://docs.cocos.com/creator/3.8/manual/zh/getting-started/install/index.html)。

## 开始开发

双击根目录的 **`开发终端.cmd`**，会打开位于工程根目录的 PowerShell，并加载新配置的环境。
已打开的其他终端或代码编辑器可能需要重启才能取得新 PATH；使用开发终端无须重启桌面应用。

在开发终端中打开编辑器：

```powershell
& $env:COCOS_CREATOR --project "$PWD\cocos"
```

进入 Creator 后打开 `assets/scene/main.scene`，等待资源导入结束，再点击浏览器预览。
如果编辑器要求登录，需要使用自己的 Cocos 账号完成登录。

日常检查：

```powershell
npm.cmd run check
```

生成 H5 包：先保存并关闭本工程的 Creator，再执行：

```powershell
npm.cmd run build
```

启动已构建的 H5：

```powershell
npm.cmd run dev
```

访问 **http://127.0.0.1:5185/**；按 Ctrl+C 停止服务。
此服务展示 `reference-projects/catch-big-goose-cocos/build/web-mobile/` 的内容；修改源码后需要重新构建，或直接使用 Creator 的浏览器预览。
端口被占用时可运行 `python tools/serve.py --port 5186`。

## 常用代码位置

| 修改内容 | 主要文件（相对 `reference-projects/catch-big-goose-cocos/assets/scripts/core/`） |
| --- | --- |
| 启动、场景和相机 | `Bootstrap.ts` |
| 对局、三消、道具和计时 | `GameManager.ts`、`SlotTray.ts` |
| 主题、关卡和难度 | `LevelConfig.ts` |
| 首页、引导、弹窗和 HUD | `HudUI.ts`、`ui/` |
| 视频播放与结果 | `PromoVideo.ts` |
| 存档与成绩 | `SaveData.ts` |
| 模型加载与物理 | `PrefabCache.ts`、`JoltLoader.ts`、`JoltWorld.ts` |

美术和音频位于 `reference-projects/catch-big-goose-cocos/assets/resources/`，入口场景在 `reference-projects/catch-big-goose-cocos/assets/scene/`。
更新资源时保留对应 `.meta` 文件，避免破坏 UUID 引用。

## 已完成验证

- `npm.cmd run check`：游戏工程 TypeScript、31 项回归测试、资源约束、Shell/Python 语法全部通过。
- `npm.cmd run check:web`：保留的旧 Web 原型类型检查通过。
- `npm.cmd run build`：实际 release/WASM 构建通过，游戏包 19.21 MiB，视频独立约 40.00 MiB。
- 构建产物已检查玩法代码、Jolt 胶水、视频完整性；无 source map，MD5 缓存关闭。
- 浏览器冒烟验证通过：引导页 → 主题地图 → 进入对局 → 拾取物件进入槽位 → 暂停；未发现启动错误。未执行整局通关及全部视频播放的人工验收。
- 修正了构建脚本对 Creator 启动资讯接口超时的误判，并添加 3 项回归测试；构建阶段错误仍会失败。

本机运行截图：

![本机 H5 对局与槽位拾取验证](work/audits/local-preview.png)

## 按开发方向另行准备

- 当前 H5 开发无须 Java、Android SDK 或 Docker。
- `tools/art/` 下许多模型生成脚本使用 Blender 的 `bpy`，应通过 Blender 执行；Blender 不属于当前运行和构建的必需环境。
- 微信小游戏仍是后续适配方向；需要届时准备微信开发者工具、小游戏 AppID 和账号权限，并验证 Jolt/WASM、视频与真机兼容性。
- 当前目录没有 `.git`，是源码目录，尚未建立本地版本历史，也未配置远程仓库。
- 现有全局 Git 配置包含 `127.0.0.1:7897` 代理，本次检查时该端口没有监听。未更改原有代理偏好；如以后拉取仓库失败，先检查代理是否已启动。
