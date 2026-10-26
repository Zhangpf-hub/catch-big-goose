# 工作区维护工具

日常只需执行 `npm run structure:check`。检查目录归属、工程入口、名称、启动路径和当前文档链接，结果写入 `work/structure-migration/layout-verification.json`。

其余脚本是 2026-10-25 本次迁移与排错的记录，不是日常构建命令：

- `reorganize.py`：一次性目录迁移，默认只生成计划，完成后禁止重复执行。
- `finalize-layout.py`、`update-remaining-paths.py`：迁移时的配置与路径修正。
- `write-indexes.py`：生成研究／开发报告索引。
- `find-directory-handles.py`、`find-project-locks.py`：只读诊断文件占用，后者需要迁移工作目录中的临时依赖。

原始文本备份、逐项移动清单、校验及构建日志保存在 `work/structure-migration/`。
