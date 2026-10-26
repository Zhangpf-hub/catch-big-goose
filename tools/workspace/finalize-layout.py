"""Finalize the 2026-10-25 recorded directory migration; safe to re-run."""
import json
from pathlib import Path
import re
import uuid
import zipfile

ROOT = Path(__file__).resolve().parents[2]
UNITY = ROOT / 'projects/catch-big-goose-unity'
BACKUP = ROOT / 'work/structure-migration/finalization-originals.zip'


def write(path, text):
    path = ROOT / path if isinstance(path, str) else path
    if path.exists():
        with zipfile.ZipFile(BACKUP, 'a', zipfile.ZIP_DEFLATED) as z:
            rel = path.relative_to(ROOT).as_posix()
            if rel not in z.namelist():
                z.writestr(rel, path.read_bytes())
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8-sig' if path.suffix == '.ps1' else 'utf-8', newline='')


def change(path, *pairs):
    path = ROOT / path if isinstance(path, str) else path
    text = path.read_text('utf-8-sig')
    for a, b in pairs:
        text = text.replace(a, b)
    write(path, text)


def main():
    for p in (UNITY / 'Assets').rglob('*.cs'):
        text = p.read_text('utf-8-sig')
        updated = re.sub(r'(?<!\./)\.\./work/', '../../work/', text).replace('竞品分析/05-', 'competitor-analysis/05-')
        updated = updated.replace('Path.GetFullPath("SourceAssets/UiNineSliceBaseline-20261025/',
                                  'Path.GetFullPath("source-assets/ui/UiNineSliceBaseline-20261025/')
        updated = updated.replace('Builds/Windows/CatchGoose.exe', 'Builds/Windows/catch-big-goose.exe')
        if updated != text:
            write(p, updated)
    change(UNITY / 'Assets/Editor/GooseProjectSetup.cs',
           ('PlayerSettings.productName = "抓住大鹅"', 'PlayerSettings.productName = GooseWorkspace.ProjectName'))
    p = UNITY / 'ProjectSettings/ProjectSettings.asset'
    text = p.read_text('utf-8-sig')
    write(p, re.sub(r'^  productName:.*$', '  productName: catch-big-goose', text, flags=re.M))
    meta = UNITY / 'Assets/Editor/GooseWorkspace.cs.meta'
    if not meta.exists():
        write(meta, 'fileFormatVersion: 2\nguid: ' + uuid.uuid4().hex + '\n')

    for name in ['package.json', 'package-lock.json']:
        change(name, ('catch-the-goose-workspace', 'catch-big-goose'))
    package = json.loads((ROOT / 'package.json').read_text('utf-8'))
    package['scripts']['check:web'] = 'tsc --noEmit -p reference-projects/catch-big-goose-web/tsconfig.json'
    package['scripts']['structure:check'] = 'python tools/workspace/verify-layout.py'
    write('package.json', json.dumps(package, ensure_ascii=False, indent=2) + '\n')
    change('reference-projects/catch-big-goose-web/tsconfig.json', ('web/**/*.ts', 'src/**/*.ts'))
    change('reference-projects/catch-big-goose-web/index.html', ('/web/main.ts', '/src/main.ts'))
    change('tools/unity/build-wechat.ps1',
           ("(Join-Path $taskProject 'Builds/WeChat/minigame')", "(Join-Path $taskRoot 'builds/catch-big-goose-wechat')"),
           ('WeChat build complete: $taskProject/Builds/WeChat/minigame', 'WeChat build complete: $taskRoot/builds/catch-big-goose-wechat'),
           ('Close the CatchGoose project', 'Close the catch-big-goose project'))
    change('tools/competitor/check_csharp.ps1', ('$taskRoot/unity/', '$taskRoot/projects/catch-big-goose-unity/'))
    change('tools/check.mjs', ("'tools', 'scripts'", "'tools'"))
    # Frozen snapshots retain their original internal tree; only live paths move.
    change('tools/unity/run-frozen-story-qa.ps1',
           ("$taskFrozen 'projects/catch-big-goose-unity/", "$taskFrozen 'unity/"))
    ignore = (ROOT / '.gitignore').read_text('utf-8-sig')
    for entry in ['builds/', 'competitor-analysis/artifacts/']:
        if entry not in ignore.splitlines():
            ignore += '\n' + entry + '\n'
    write('.gitignore', ignore)
    # The only public developer-tools project has the canonical project name.
    p = ROOT / 'builds/catch-big-goose-wechat/project.config.json'
    conf = json.loads(p.read_text('utf-8-sig'))
    conf['projectname'] = 'catch-big-goose'
    write(p, json.dumps(conf, ensure_ascii=False, indent=2) + '\n')
    p = ROOT / 'builds/catch-big-goose-wechat/project.private.config.json'
    if p.exists():
        conf = json.loads(p.read_text('utf-8-sig'))
        if 'projectname' in conf:
            conf['projectname'] = 'catch-big-goose'
            write(p, json.dumps(conf, ensure_ascii=False, indent=2) + '\n')
    # The active font audit is consumed by package auditing. Frozen reports are kept.
    p = ROOT / 'work/wechat-integration/font-subset.json'
    conf = json.loads(p.read_text('utf-8-sig'))
    for key in ['source', 'target']:
        conf[key] = conf[key].replace('\\', '/')
        if conf[key].startswith('unity/'):
            conf[key] = 'projects/catch-big-goose-unity/' + conf[key][6:]
    write(p, json.dumps(conf, ensure_ascii=False, indent=2) + '\n')
    # Keep historical ZIPs/QA binaries as recorded; unify the current release entry.
    windows = UNITY / 'Builds/Windows'
    for old, new in [('CatchGoose.exe', 'catch-big-goose.exe'), ('CatchGoose_Data', 'catch-big-goose_Data')]:
        if (windows / old).exists() and not (windows / new).exists():
            (windows / old).rename(windows / new)
    change('开始游戏.cmd', ('CatchGoose.exe', 'catch-big-goose.exe'))
    for base in ['docs', 'projects/catch-big-goose-unity']:
        files = (ROOT / base).rglob('*.md') if base == 'docs' else (ROOT / base).glob('*.md')
        for p in files:
            text = p.read_text('utf-8-sig')
            updated = text.replace('Builds/Windows/CatchGoose.exe', 'Builds/Windows/catch-big-goose.exe')
            if base.startswith('projects'):
                updated = updated.replace('`Builds/WeChat/minigame`', '`../../builds/catch-big-goose-wechat`')
            if updated != text:
                write(p, updated)
    print('Canonical names, active launch/build paths and project settings updated.')


if __name__ == '__main__':
    main()
