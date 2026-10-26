"""One-time, recorded workspace migration. Dry-run by default; --apply moves files.

Third-party packages, caches, frozen evidence and asset bytes are not rewritten.
The migration journal retains the original names for historical report lookup.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'work/structure-migration'
PLANS = [
    ('unity', 'projects/catch-big-goose-unity'),
    ('unity/Builds/WeChat/minigame', 'builds/catch-big-goose-wechat'),
    ('cocos', 'reference-projects/catch-big-goose-cocos'),
    ('web', 'reference-projects/catch-big-goose-web/src'),
    ('public', 'reference-projects/catch-big-goose-web/public'),
    ('index.html', 'reference-projects/catch-big-goose-web/index.html'),
    ('tsconfig.json', 'reference-projects/catch-big-goose-web/tsconfig.json'),
    ('references/competitor-goose', 'reference-projects/competitor-goose'),
    ('竞品分析', 'competitor-analysis'),
    ('竞品分析/历史', 'competitor-analysis/history'),
    ('竞品分析/证据', 'competitor-analysis/evidence'),
    ('开发计划', 'docs/development-plans'),
    ('本地开发说明.md', 'docs/local-development.md'),
    ('assets-3d', 'source-assets/models'),
    ('SourceAssets', 'source-assets/ui'),
    ('video', 'source-assets/videos'),
    ('scripts', 'tools/art'),
    ('audit', 'work/audits'),
    ('outputs', 'work/outputs'),
    ('project.config.json', 'work/structure-migration/legacy-root-wechat/project.config.json'),
    ('project.private.config.json', 'work/structure-migration/legacy-root-wechat/project.private.config.json'),
    ('打开项目.cmd', '打开Unity工程.cmd'),
    ('打开微信小游戏.cmd', '打开微信工程.cmd'),
]
for p in sorted((ROOT / '竞品分析').glob('*.md')):
    if re.match(r'(?:1[5-9]|2[0-9])-|21A-', p.name):
        PLANS.append((p.relative_to(ROOT).as_posix(), 'docs/development-reports/' + p.name))
for p in sorted((ROOT / 'work').glob('competitor-*')):
    if p.is_dir():
        PLANS.append((p.relative_to(ROOT).as_posix(), 'competitor-analysis/artifacts/' + p.name))


def translate(rel, plans=PLANS):
    for old, new in sorted(plans, key=lambda x: len(x[0]), reverse=True):
        if rel == old or rel.startswith(old + '/'):
            return new + rel[len(old):]
    return rel


SKIP = {'node_modules', 'Library', 'library', 'Temp', 'temp', 'Logs', 'logs',
        'Packages', 'Builds', 'build', 'profiles', '.git', '__pycache__', 'UserSettings'}
TEXT_EXT = {'.md', '.py', '.ps1', '.cmd', '.mjs', '.cjs', '.js', '.ts', '.json',
            '.sh', '.html', '.yaml', '.yml', '.asset', '.asmdef', '.txt'}


def source_files():
    for base in ['tools', 'scripts', 'tests', 'skills', 'unity/Assets/Scripts',
                 'unity/Assets/Editor', 'unity/ProjectSettings', 'cocos', 'web',
                 '竞品分析', '开发计划']:
        for parent, dirs, files in os.walk(ROOT / base):
            dirs[:] = [d for d in dirs if d not in SKIP and d not in ['历史', '证据', 'artifacts']]
            for name in files:
                p = Path(parent) / name
                if p.suffix in TEXT_EXT and p.stat().st_size < 4_000_000 and p != Path(__file__):
                    yield p
    for p in ROOT.iterdir():
        if p.is_file() and (p.suffix in TEXT_EXT or p.name == '.gitignore'):
            yield p
    for name in ['README.md', 'WECHAT.md', 'MIGRATION_STATUS.md',
                 'SourceAssets/source-manifest.json', 'SourceAssets/video-manifest.json']:
        p = ROOT / 'unity' / name
        if p.exists():
            yield p


def links(text, old_rel, new_rel):
    old_parent = (ROOT / old_rel).parent
    new_parent = (ROOT / new_rel).parent
    def replace(m):
        raw = m[1]
        target = raw.strip('<>')
        if re.match(r'^[a-zA-Z]+:|^#|^/', target):
            return m[0]
        path, sep, anchor = target.partition('#')
        old = (old_parent / path).resolve()
        if not old.is_relative_to(ROOT):
            return m[0]
        # Broken historical links are kept as historical text, not silently guessed.
        if not old.exists() and not (ROOT / translate(old.relative_to(ROOT).as_posix())).exists():
            return m[0]
        moved = ROOT / translate(old.relative_to(ROOT).as_posix())
        relative = os.path.relpath(moved, new_parent).replace('\\', '/')
        if sep:
            relative += '#' + anchor
        if raw.startswith('<') or ' ' in relative:
            relative = '<' + relative + '>'
        return '](' + relative + ')'
    return re.sub(r'\]\(([^)\n]+)\)', replace, text)


def rewrite(text, old_rel, new_rel):
    # Resolve Markdown links before physical moves, including their new parent depth.
    if old_rel.endswith('.md'):
        text = links(text, old_rel, new_rel)
    # Longest explicit paths first; placeholder prevents mapping the same segment twice.
    specific = [(a, b) for a, b in PLANS if '/' in a]
    specific += [('unity/Builds/WeChat/minigame', 'builds/catch-big-goose-wechat'),
                 ('SourceAssets/UiNineSliceBaseline-20261025', 'source-assets/ui/UiNineSliceBaseline-20261025')]
    placeholders = {}
    def hold(value):
        token = f'@@MIGRATION_PATH_{len(placeholders)}@@'
        placeholders[token] = value
        return token
    for old, new in sorted(specific, key=lambda x: len(x[0]), reverse=True):
        for sep in ['/', '\\', '\\\\']:
            a, b = old.replace('/', sep), new.replace('/', sep)
            text = text.replace(a, hold(b))
    for old, new in [('unity', 'projects/catch-big-goose-unity'),
                     ('cocos', 'reference-projects/catch-big-goose-cocos'),
                     ('assets-3d', 'source-assets/models'),
                     ('竞品分析', 'competitor-analysis'), ('开发计划', 'docs/development-plans')]:
        # Absolute workspace paths and root-relative quoted paths; preserve tools/unity
        # and installed Cocos Creator's cocos/editors location.
        for sep in ['/', '\\', '\\\\']:
            text = text.replace(str(ROOT).replace('\\', sep) + sep + old + sep,
                                hold(str(ROOT).replace('\\', sep) + sep + new.replace('/', sep) + sep))
        text = re.sub(r'(?<![\w/\\-])' + re.escape(old) + r'(?=[/\\])(?![/\\]editors)',
                      lambda m: hold(new), text)
        if old in ['unity', 'cocos']:
            text = re.sub(r'([\x22\x27])' + old + r'\1', lambda m: m[1] + hold(new) + m[1], text)
    text = re.sub(r'(?<![\w/\\-])scripts/', lambda m: hold('tools/art/'), text)
    text = re.sub(r'(?<![\w/\\-])audit/', lambda m: hold('work/audits/'), text)
    text = re.sub(r"(ROOT\s*/\s*|join\(root,\s*)(['\"])video\2",
                  lambda m: m[1] + m[2] + hold('source-assets/videos') + m[2], text)
    for old, new in PLANS:
        if old in ['打开项目.cmd', '打开微信小游戏.cmd', '本地开发说明.md']:
            text = text.replace(old, hold(new))
    for token, value in placeholders.items():
        text = text.replace(token, value)
    if old_rel.startswith('scripts/') and old_rel.endswith('.py'):
        text = text.replace('Path(__file__).resolve().parents[1]', 'Path(__file__).resolve().parents[2]')
    return text


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    if not (ROOT / 'unity').exists() and (OUT / 'plan.json').exists():
        PLANS[:] = [(m['source'], m['target']) for m in json.loads((OUT / 'plan.json').read_text('utf-8'))['moves']]
    report = {'workspace': str(ROOT), 'moves': [dict(source=a, target=b) for a, b in PLANS]}
    if not args.apply:
        (OUT / 'plan.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), 'utf-8')
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return
    if (OUT / 'migration.json').exists():
        raise SystemExit('Migration already recorded; do not repeat.')
    resuming = (OUT / 'original-sources.zip').exists() and not (ROOT / 'unity').exists()
    # Validate every absolute source/target, including future nested moves, first.
    for old, new in PLANS:
        assert (ROOT / old).resolve().is_relative_to(ROOT)
        assert (ROOT / new).resolve().is_relative_to(ROOT)
        assert (ROOT / old).exists() or (ROOT / new).exists() or resuming, old
        if not resuming:
            assert not (ROOT / new).exists(), new
    sources = list(dict.fromkeys(source_files()))
    edits = []
    if resuming:
        with zipfile.ZipFile(OUT / 'original-sources.zip') as backup:
            originals = [(ROOT / name, backup.read(name)) for name in backup.namelist()]
    else:
        originals = [(p, p.read_bytes()) for p in sources]
    with zipfile.ZipFile(OUT / 'original-sources.zip', 'a' if resuming else 'w', zipfile.ZIP_DEFLATED) as backup:
        for p, raw in originals:
            try:
                text = raw.decode('utf-8-sig')
            except UnicodeDecodeError:
                continue
            old = p.relative_to(ROOT).as_posix()
            new = translate(old)
            updated = rewrite(text, old, new)
            # PS5.1 must read Chinese paths with a BOM.
            encoded = updated.encode('utf-8-sig' if raw.startswith(b'\xef\xbb\xbf') or p.suffix == '.ps1' else 'utf-8')
            if raw != encoded:
                if not resuming:
                    backup.writestr(old, raw)
                edits.append((old, new, encoded, hashlib.sha256(raw).hexdigest()))
    # Asset/GUID baseline checks all files moved with Unity Assets; no asset transforms.
    asset_root = ROOT / ('projects/catch-big-goose-unity/Assets' if resuming else 'unity/Assets')
    assets = {'unity/Assets/' + p.relative_to(asset_root).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in asset_root.rglob('*') if p.is_file()}
    def move_tree(source, target):
        assert source.resolve().is_relative_to(ROOT) and target.resolve().is_relative_to(ROOT)
        if not target.exists():
            try:
                source.rename(target)
                return
            except PermissionError:
                if not source.is_dir():
                    raise
        # Windows directory watchers can prevent renaming an ancestor while allowing
        # the watched child itself to move. Move entries without copying asset bytes.
        if not source.is_dir() or (target.exists() and not target.is_dir()):
            raise FileExistsError(target)
        target.mkdir(exist_ok=True)
        for child in list(source.iterdir()):
            move_tree(child, target / child.name)
        source.rmdir()

    applied = []
    for old, new in PLANS:
        source = ROOT / translate(old, applied)
        target = ROOT / new
        if source == target or (not source.exists() and target.exists()):
            applied.append((old, new))
            continue
        assert source.resolve().is_relative_to(ROOT) and target.resolve().is_relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        move_tree(source, target)
        applied.append((old, new))
        (OUT / 'progress.json').write_text(json.dumps(applied, ensure_ascii=False, indent=2), 'utf-8')
    changed = []
    for old, new, data, sha in edits:
        path = ROOT / new
        path.write_bytes(data)
        changed.append(dict(source=old, target=new, beforeSha256=sha,
                            afterSha256=hashlib.sha256(data).hexdigest()))
    changed_paths = {x['source'] for x in changed}
    errors = []
    for old, sha in assets.items():
        p = ROOT / translate(old)
        if old not in changed_paths and hashlib.sha256(p.read_bytes()).hexdigest() != sha:
            errors.append(old)
    report.update(changedFiles=changed, unityAssetFilesChecked=len(assets), assetErrors=errors)
    (OUT / 'migration.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), 'utf-8')
    for name in ['references']:
        p = ROOT / name
        if p.is_dir() and not any(p.iterdir()):
            p.rmdir()
    print(json.dumps({'moves': len(applied), 'editedTextFiles': len(changed),
                      'unityAssetFilesChecked': len(assets), 'assetErrors': errors}, indent=2))
    if errors:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
