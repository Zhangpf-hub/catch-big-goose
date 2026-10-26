# 工程命名与目录规范

整理日期：2026-10-25。工程唯一标识为 `catch-big-goose`，中文游戏名为「抓鸭子」。Unity Product Name、微信开发工程名和根 npm 包名统一为该标识。

```text
工作区/
├── projects/
│   └── catch-big-goose-unity/       Unity 当前源工程
├── builds/
│   └── catch-big-goose-wechat/      微信开发者工具唯一导入入口
├── reference-projects/             独立一级目录：参考项目与源资源
│   ├── catch-big-goose-cocos/      迁移前 Cocos 工程
│   ├── catch-big-goose-web/        历史网页原型
│   └── competitor-goose/           竞品提取资源及原始参数
├── competitor-analysis/            独立一级目录：竞品分析
│   ├── evidence/                  证据归档
│   ├── artifacts/                 原 work/competitor-* 分析产物
│   └── history/                   历史研究记录
├── source-assets/
│   ├── models/                    模型候选、规格
│   ├── ui/                        工作区级 UI 原件备份
│   └── videos/                    原始视频
├── docs/
│   ├── development-plans/         开发计划
│   └── development-reports/       本项目的实施、优化与验收报告
├── tools/
│   ├── unity/                     Unity／微信管线
│   ├── competitor/                竞品分析工具
│   ├── art/                       美术脚本
│   └── workspace/                 结构检查与本次迁移工具
├── tests/
├── skills/
├── work/                          本项目中间产物、日志、迁移备份
├── workspace.json                 路径清单
├── 打开Unity工程.cmd
├── 打开微信工程.cmd
└── 开始游戏.cmd
```

## 命名原则

自定义目录采用小写英文和连字符。工程目录附加平台或引擎后缀：`catch-big-goose-unity`、`catch-big-goose-wechat`、`catch-big-goose-cocos`。用户可读的文档标题与中文快捷启动文件保留中文。

引擎规定的 `Assets`、`Packages`、`ProjectSettings`、`Library`、`Builds` 等目录，以及第三方 SDK、包名、资源 GUID、代码命名空间，保留其技术约定。Unity 工程内部的 `SourceAssets` 是该工程的资源备份，工作区的 `source-assets` 是跨工程美术输入。

外层工作区 `Catch-big-goose-master` 是当前 Codex 绑定的容器路径，本轮保留；内部实际开发工程和导出工程已更名。工具从脚本位置或 `workspace.json` 查找工作区，不依赖外层目录名。

## 新旧路径

| 原路径 | 当前路径 |
| --- | --- |
| `unity/` | `projects/catch-big-goose-unity/` |
| `unity/Builds/WeChat/minigame/` | `builds/catch-big-goose-wechat/` |
| `cocos/` | `reference-projects/catch-big-goose-cocos/` |
| `web/` | `reference-projects/catch-big-goose-web/src/` |
| `references/competitor-goose/` | `reference-projects/competitor-goose/` |
| `竞品分析/` | `competitor-analysis/` |
| 原竞品目录中的本项目第 15、16、17—28 章及 21A | `docs/development-reports/` |
| `work/competitor-*/` | `competitor-analysis/artifacts/competitor-*/` |
| `开发计划/` | `docs/development-plans/` |
| `assets-3d/` | `source-assets/models/` |
| 根目录 `SourceAssets/` | `source-assets/ui/` |
| `video/` | `source-assets/videos/` |
| `scripts/` | `tools/art/` |
| `audit/`、`outputs/` | `work/audits/`、`work/outputs/` |
| `打开项目.cmd` | `打开Unity工程.cmd` |
| `打开微信小游戏.cmd` | `打开微信工程.cmd` |

根目录旧 `project.config.json` 与私有配置已归档到 `work/structure-migration/legacy-root-wechat/`。根目录是工作区，不再可被误当作微信导出工程导入。

## 构建规则与历史证据

Unity SDK 仍在源工程的 `Builds/WeChat/` 下生成编译中间文件。转换和包体检查成功后，将 `minigame` 移到工作区 `builds/catch-big-goose-wechat/`，强制写入统一工程名；替换失败时恢复上一份导出。微信 AppID 保持不变，正式线上名称继续由公众平台管理。

Windows 当前发行入口为 `projects/catch-big-goose-unity/Builds/Windows/catch-big-goose.exe`。QA 包、冻结快照和历史 ZIP 保留其生成时名称，避免修改历史证据。

原始证据、冻结工程和旧验收清单保留记录时的路径与哈希。查阅它们时使用迁移对照，不应将历史路径或过期二维码当作当前入口。逐项迁移记录、文本备份和校验结果位于 `work/structure-migration/`。
