"""Validate actual entry paths and detect newly broken documentation links."""
import ast
import json
import os
from pathlib import Path
import re
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'work/structure-migration'
checks, errors = [], []


def check(ok, message):
    (checks if ok else errors).append(message)


def moved(relative):
    for m in sorted(migration['moves'], key=lambda m: len(m['source']), reverse=True):
        a, b = m['source'], m['target']
        if relative == a or relative.startswith(a + '/'):
            return b + relative[len(a):]
    return relative


def targets(p, text):
    for raw in re.findall(r'\]\(([^)\n]+)\)', text):
        target = raw.strip('<>')
        if re.match(r'^[a-zA-Z]+:|^#|^/', target):
            continue
        path = target.partition('#')[0]
        if path:
            yield raw, (p.parent / path).resolve()


manifest = json.loads((ROOT / 'workspace.json').read_text('utf-8'))
migration = json.loads((OUT / 'migration.json').read_text('utf-8'))
for key, relative in manifest['paths'].items():
    path = (ROOT / relative).resolve()
    check(path.is_relative_to(ROOT) and path.is_dir(), 'Workspace path: ' + key)
check(manifest['name'] == 'catch-big-goose', 'Canonical workspace name')
unity = ROOT / manifest['paths']['unity']
wechat = ROOT / manifest['paths']['wechat']
for relative in ['Assets/Scenes/Main.unity', 'Packages/manifest.json', 'ProjectSettings/ProjectVersion.txt']:
    check((unity / relative).is_file(), 'Unity entry: ' + relative)
for relative in ['game.js', 'game.json', 'project.config.json']:
    check((wechat / relative).is_file(), 'WeChat entry: ' + relative)
config = json.loads((wechat / 'project.config.json').read_text('utf-8-sig'))
check(config.get('projectname') == manifest['name'] and config.get('compileType') == 'game', 'WeChat project name and game type')
check(config.get('appid') == 'wx60b50db2472c4782', 'Existing registered AppID retained')
check('productName: catch-big-goose' in (unity / 'ProjectSettings/ProjectSettings.asset').read_text('utf-8'), 'Unity product name')
check(json.loads((ROOT / 'package.json').read_text('utf-8'))['name'] == manifest['name'], 'npm workspace name')
for old in ['unity', 'cocos', 'web', 'references', '竞品分析', '开发计划', 'assets-3d', 'SourceAssets', 'video', 'scripts', 'audit', 'outputs']:
    check(not (ROOT / old).exists(), 'Retired root removed: ' + old)
check(not (ROOT / 'project.config.json').exists(), 'Root cannot be mistaken for a WeChat project')
check(not (unity / 'Builds/WeChat/minigame').exists(), 'SDK intermediate package published to canonical directory')
for name in ['打开Unity工程.cmd', '打开微信工程.cmd', '开始游戏.cmd']:
    check((ROOT / name).exists(), 'Launcher: ' + name)
check((unity / 'Builds/Windows/catch-big-goose.exe').exists() and (unity / 'Builds/Windows/catch-big-goose_Data').is_dir(), 'Named Windows executable and matching data folder')
for name in ['open-project.ps1', 'build-wechat.ps1']:
    check('projects/catch-big-goose-unity' in (ROOT / 'tools/unity' / name).read_text('utf-8-sig'), 'Unity script path: ' + name)
for name in ['open-wechat.ps1', 'build-wechat.ps1']:
    check('builds/catch-big-goose-wechat' in (ROOT / 'tools/unity' / name).read_text('utf-8-sig'), 'WeChat script path: ' + name)
check(r'projects\catch-big-goose-unity\Builds\Windows\catch-big-goose.exe' in (ROOT / '开始游戏.cmd').read_text('utf-8'), 'Windows launcher path')

# Baseline old Markdown: a link is pre-existing only if it was already broken
# after resolving all recorded moves. Current navigation files are always strict.
preexisting = {}
with zipfile.ZipFile(OUT / 'original-sources.zip') as backup:
    for old in backup.namelist():
        if not old.endswith('.md'):
            continue
        broken = set()
        for raw, target in targets(ROOT / old, backup.read(old).decode('utf-8-sig')):
            if target.is_relative_to(ROOT):
                target = ROOT / moved(target.relative_to(ROOT).as_posix())
            if not target.exists():
                broken.add(raw)
        preexisting[moved(old)] = broken
files = [ROOT / 'README.md', ROOT / 'docs/README.md', ROOT / 'docs/project-structure.md',
         ROOT / 'reference-projects/README.md', ROOT / 'source-assets/README.md', ROOT / 'builds/README.md', ROOT / 'projects/README.md']
files += list((ROOT / 'docs').rglob('*.md')) + list((ROOT / 'competitor-analysis').glob('*.md')) + list(unity.glob('*.md'))
strict = {p.relative_to(ROOT).as_posix() for p in files[:7]}
legacy_broken, new_broken, link_count = [], [], 0
for p in dict.fromkeys(files):
    rel = p.relative_to(ROOT).as_posix()
    for raw, target in targets(p, p.read_text('utf-8-sig')):
        link_count += 1
        if not target.exists():
            item = dict(file=rel, link=raw)
            if rel not in strict and raw in preexisting.get(rel, set()):
                legacy_broken.append(item)
            else:
                new_broken.append(item)
check(not new_broken, 'No new broken documentation links')
py_count = 0
for p in (ROOT / 'tools').rglob('*.py'):
    if '__pycache__' in p.parts:
        continue
    try:
        ast.parse(p.read_text('utf-8-sig'), filename=str(p))
    except SyntaxError as e:
        errors.append(str(e))
    py_count += 1
check(True, f'Parsed Python tool scripts: {py_count}')
result = dict(passed=not errors, checks=checks, errors=errors, documentLinks=link_count,
              newBrokenLinks=new_broken, preexistingBrokenLinks=legacy_broken,
              unityMigrationAssetFilesChecked=migration['unityAssetFilesChecked'],
              unityMigrationAssetErrors=migration['assetErrors'])
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'layout-verification.json').write_text(json.dumps(result, ensure_ascii=False, indent=2), 'utf-8')
print(json.dumps({'passed': result['passed'], 'checks': len(checks), 'errors': errors,
                  'documentLinks': link_count, 'newBrokenLinks': new_broken,
                  'preexistingBrokenLinkCount': len(legacy_broken)}, ensure_ascii=False, indent=2))
if errors:
    sys.exit(1)
