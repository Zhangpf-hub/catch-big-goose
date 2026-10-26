"""Generate concise indexes for the reorganized research and development folders."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
analysis = ROOT / 'competitor-analysis'
old = ROOT / 'work/structure-migration/competitor-index-before-layout.md'
if not old.exists():
    old.write_bytes((analysis / 'README.md').read_bytes())
rows = ['# 竞品分析', '', '本目录集中保存竞品研究结论、证据和分析产物。参考工程与提取原件位于 [reference-projects](../reference-projects/README.md)，本项目实施和验收报告位于 [docs](../docs/README.md)。', '',
        '研究对象为抓大鹅 AppID `wxb98ac240fd74b0e3`，已有版本 401／402 的资料。结论的证据范围、推测和待确认事项以各章为准。', '',
        '| 研究文档 |', '| --- |']
for p in sorted(analysis.glob('*.md')):
    if p.name != 'README.md':
        rows.append(f'| [{p.stem}]({p.name}) |')
rows += ['', '- `evidence/`：按研究批次归档的源码、截图、结果和哈希证据。',
         '- `artifacts/`：原 `work/competitor-*` 中间产物与冻结副本。',
         '- `history/`：早期研究记录。', '',
         '原第 15、16、17—28 章及 21A 的本项目接入、画面优化和验收报告已移至 [开发报告](../docs/README.md)。历史证据内部的旧路径与哈希保留，查找时参照 [迁移对照](../docs/project-structure.md)。', '']
(analysis / 'README.md').write_text('\n'.join(rows), 'utf-8')
rows = ['# 项目文档', '', '- [工程命名与目录规范](project-structure.md)', '- [本地开发环境](local-development.md)',
        '- [Unity 工程说明](../projects/catch-big-goose-unity/README.md)', '- [微信接入说明](../projects/catch-big-goose-unity/WECHAT.md)',
        '- [竞品研究索引](../competitor-analysis/README.md)', '',
        '以下文档包含不同批次的实施和验收记录；历史二维码和旧版本结果不代表当前导出包。', '',
        '## 开发报告', '', '| 文档 |', '| --- |']
for p in sorted((ROOT / 'docs/development-reports').glob('*.md')):
    rows.append(f'| [{p.stem}](development-reports/{p.name}) |')
rows += ['', '## 开发计划', '']
for p in sorted((ROOT / 'docs/development-plans').glob('*.md')):
    rows.append(f'- [{p.stem}](development-plans/{p.name})')
rows.append('')
(ROOT / 'docs/README.md').write_text('\n'.join(rows), 'utf-8')
