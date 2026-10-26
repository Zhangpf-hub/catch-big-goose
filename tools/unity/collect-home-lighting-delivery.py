"""Freeze and verify HOME2/SHAKE3 source inputs, native evidence and WeChat output.

Run after the real builds/QA/preview. --verify never replaces archived evidence.
"""
import argparse
import datetime
import hashlib
import json
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'work/home-lighting-shake-20261025'
PROJECT = ROOT / 'projects/catch-big-goose-unity'
BUILD = '20261025-HOME2-SHAKE3'


def sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def write(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')


def relative(path):
    return path.relative_to(ROOT).as_posix()


def freeze(name, paths):
    archive = WORK / (name + '.zip')
    manifest = WORK / (name + '-files.json')
    if archive.exists() or manifest.exists():
        raise RuntimeError('Archive already exists; use --verify: ' + name)
    files = sorted({p for base in paths for p in (base.rglob('*') if base.is_dir() else [base]) if p.is_file()})
    rows = []
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=4) as output:
        for path in files:
            name_in_zip = relative(path)
            rows.append(dict(path=name_in_zip, bytes=path.stat().st_size, sha256=sha(path)))
            output.write(path, name_in_zip)
    write(manifest, rows)
    print('Frozen ' + name + ': ' + str(len(rows)) + ' files', flush=True)
    return dict(archive=relative(archive), sha256=sha(archive), bytes=archive.stat().st_size,
                manifest=relative(manifest), manifestSha256=sha(manifest), files=len(rows))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--verify', action='store_true')
    args = parser.parse_args()
    if args.verify:
        delivery = json.loads((WORK / 'delivery.json').read_text('utf-8'))
        errors = []
        for group, entry in delivery['archives'].items():
            archive, manifest = ROOT / entry['archive'], ROOT / entry['manifest']
            if sha(archive) != entry['sha256'] or sha(manifest) != entry['manifestSha256']:
                errors.append(group + ': archive/manifest changed')
                continue
            with zipfile.ZipFile(archive) as frozen:
                for row in json.loads(manifest.read_text('utf-8')):
                    if hashlib.sha256(frozen.read(row['path'])).hexdigest() != row['sha256']:
                        errors.append('Frozen bytes differ: ' + row['path'])
                    current = ROOT / row['path']
                    if not current.is_file() or sha(current) != row['sha256']:
                        errors.append('Active bytes differ: ' + row['path'])
        print(json.dumps(dict(passed=not errors, errors=errors), ensure_ascii=False, indent=2))
        if errors:
            raise SystemExit(1)
        return

    errors, runtime = [], {}
    reports = dict(home='delivery-home/acceptance.json', shake='delivery-shake/acceptance.json',
                   story='delivery-story/story-acceptance.json', interaction='interaction-final/interaction.json',
                   video='video-final/home-gm-video-acceptance.json', session='session-final/session-acceptance.json')
    for label, name in reports.items():
        report = json.loads((WORK / name).read_text('utf-8-sig'))
        if not report.get('passed') or report.get('errors'):
            errors.append(label + ': QA failed')
        complete = dict(home=len(list((WORK / 'delivery-home').glob('*-home-*.png'))) == 15,
                        shake=len(report.get('shakes', [])) == 30,
                        story=report.get('rounds') == 10,
                        interaction=len(report.get('checks', [])) >= 60,
                        video=report.get('completedVideos') == 2 and report.get('cancelledVideos') == 7,
                        session=len(report.get('openings', [])) == 10 and len(report.get('phases', [])) == 20 and len(report.get('floors', [])) == 5)
        if not complete[label]:
            errors.append(label + ': incomplete evidence')
        runtime[label] = dict(file=relative(WORK / name), sha256=sha(WORK / name),
                              passed=report.get('passed'), checks=len(report['checks']))
        if label == 'shake':
            runtime[label]['rows'] = len(report['shakes'])
            runtime[label]['protectedHideViolations'] = sum(row['hideViolations'] for row in report['shakes'])
        if label == 'video':
            runtime[label].update(completed=report['completedVideos'], cancelled=report['cancelledVideos'])
        if label == 'session':
            runtime[label].update(openings=len(report['openings']), phases=len(report['phases']))
    tests = ET.parse(WORK / 'edit-final.xml').getroot().attrib
    if tests['result'] != 'Passed' or tests['failed'] != '0':
        errors.append('EditMode tests failed')
    table = json.loads((ROOT / 'source-assets/models/candidates/home-table-lighting-20261025/validation.json').read_text('utf-8'))
    surfaces = json.loads((ROOT / 'source-assets/models/candidates/round-surfaces-20261025/validation.json').read_text('utf-8'))
    if not table['passed'] or not surfaces['passed']:
        errors.append('Candidate validation failed')
    table_root = ROOT / 'source-assets/models/candidates/home-table-lighting-20261025'
    for name, digest in table['files'].items():
        if name != 'validation.json' and sha(table_root / name) != digest:
            errors.append('Table candidate changed: ' + name)
    unchanged_data = {}
    for name in ['core-rounds.json', 'theme-rounds.json', 'themes.json', 'pile-algorithms.json',
                 'level-tuning.json', 'prepared-layouts.json', 'item-presentation.json']:
        old = WORK / 'before/Assets/Resources/Data' / name
        current = PROJECT / 'Assets/Resources/Data' / name
        unchanged_data[name] = sha(current)
        if sha(old) != sha(current):
            errors.append('Inventory/weight/layout data changed: ' + name)
    for model in surfaces['models']:
        candidate = ROOT / 'source-assets/models/candidates/round-surfaces-20261025' / model['id']
        for name, digest in model['files'].items():
            if sha(candidate / name) != digest:
                errors.append('Container candidate changed: ' + model['id'] + '/' + name)
        old = PROJECT / 'SourceAssets/before-home-lighting-shake-20261025' / model['id'] / (model['id'] + '.fbx.meta')
        current = PROJECT / 'Assets/Resources/Models' / model['id'] / (model['id'] + '.fbx.meta')
        guid = lambda p: next(line for line in p.read_text('utf-8-sig').splitlines() if line.startswith('guid:'))
        if guid(old) != guid(current):
            errors.append('Container GUID changed: ' + model['id'])
    provenance = json.loads((WORK / 'sources-before-shadow-budget/physics-source-provenance.json').read_text('utf-8-sig'))
    for row in provenance['scripts']:
        if sha(ROOT / row['path']) != row['sha256']:
            errors.append('Gameplay QA source changed after testing: ' + row['path'])
    physics_assembly = WORK / 'physics-qa/catch-big-goose_Data/Managed/CatchGoose.Runtime.dll'
    if sha(physics_assembly) != provenance['qaAssemblySha256']:
        errors.append('Physics QA binary differs from tested source snapshot')
    old_home = (WORK / 'sources-before-shadow-budget/GooseHomeStage.cs').read_text('utf-8-sig')
    current_home = (PROJECT / 'Assets/Scripts/GooseHomeStage.cs').read_text('utf-8-sig')
    if old_home.replace('key.shadows=LightShadows.Soft;', 'key.shadows=LightShadows.Soft;key.shadowCustomResolution=1024;') != current_home:
        errors.append('Home production changes exceed explicit shadow resolution')
    old_lighting = (WORK / 'sources-before-shadow-budget/GooseReferenceLighting.cs').read_text('utf-8-sig')
    current_lighting = (PROJECT / 'Assets/Scripts/GooseReferenceLighting.cs').read_text('utf-8-sig')
    comment = '                // Built-in "No Cascades" uses one unsplit map. The home light\n                // explicitly requests 1024 rather than a viewport-sized map.\n'
    normalized = current_lighting.replace(comment, '').replace('shadowCascades=0;QualitySettings.shadowDistance=12;', 'shadowCascades=1;QualitySettings.shadowDistance=12;')
    if normalized != old_lighting:
        errors.append('Lighting changes exceed home-only unsplit map')
    assembly = PROJECT / 'Builds/Windows/catch-big-goose_Data/Managed/CatchGoose.Runtime.dll'
    code = assembly.read_bytes()
    if BUILD.encode('utf-16le') not in code:
        errors.append('Release build identity missing')
    if any(name in code for name in [b'GooseHomeShakeAcceptance', b'GooseSessionAcceptance', b'GooseHomeGmVideoAcceptance']):
        errors.append('Release contains QA classes')
    boot = (PROJECT / 'Builds/home-lighting-shake-qa/catch-big-goose_Data/boot.config').read_text('utf-8-sig')
    if 'player-connection-multicast=0' not in boot or 'player-connection-listen-address=127.0.0.1' not in boot:
        errors.append('QA local network policy missing')
    package = json.loads((WORK / 'wechat-package-audit.json').read_text('utf-8'))
    if not package['localPackagePassed']:
        errors.append('WeChat package audit failed')
    preview = WORK / 'home2-shake3-preview.png'
    if not preview.is_file() or preview.stat().st_size < 1000:
        errors.append('New preview QR missing')
    publication = json.loads((WORK / 'preview-publication.json').read_text('utf-8'))
    if not publication['platformPreviewPassed'] or sha(preview) != publication['qrSha256']:
        errors.append('Final platform preview identity missing')
    for row in publication['files']:
        if sha(ROOT / row['path']) != row['sha256']:
            errors.append('Package changed after preview: ' + row['path'])
    if errors:
        raise RuntimeError('\n'.join(errors))
    print('Required QA, release identity, GUIDs and package checks passed; freezing artifacts.', flush=True)
    inputs = [PROJECT / folder for folder in ['Assets', 'Packages', 'ProjectSettings']]
    inputs += [ROOT / 'workspace.json', ROOT / 'tools/unity', ROOT / 'skills/match3-model-pipeline',
               PROJECT / 'SourceAssets/before-home-lighting-shake-20261025',
               WORK / 'sources-before-shadow-budget',
               ROOT / 'source-assets/models/candidates/home-table-lighting-20261025',
               ROOT / 'source-assets/models/candidates/round-surfaces-20261025']
    evidence = [WORK / name for name in reports.values()] + [WORK / 'edit-final.xml', WORK / 'wechat-package-audit.json',
                preview, WORK / 'home2-shake3-preview-info.json', ROOT / 'work/r4-interaction-20261025/competitor']
    evidence += [ROOT / 'docs/development-reports/38-首页桌子光照与表层摇动稳定性.md',
                 ROOT / 'competitor-analysis/20-表层摇动与显隐冲突.md',
                 WORK / 'home-fifteen-views.jpg', WORK / 'home-lighting-ab.jpg', WORK / 'table-four-views.jpg',
                 WORK / 'round-surface-contact.jpg',
                 WORK / 'build-delivery.log', WORK / 'wechat-build.log', WORK / 'acceptance-final.out.log',
                 WORK / 'session-run.out.log', WORK / 'session-run.err.log',
                 WORK / 'shadow-budget.out.log', WORK / 'shadow-budget.err.log', WORK / 'finish-shadow-budget.ps1',
                 WORK / 'visual-qa.out.log', WORK / 'visual-qa.err.log', WORK / 'finish-visual-qa.ps1',
                 WORK / 'build-visual-qa.log', WORK / 'preview-cli.log', WORK / 'preview-publication.json', WORK / 'record-preview.py',
                 WORK / 'make-contact-sheets.py', WORK / 'run-final-acceptance.ps1', WORK / 'run-final-session.ps1']
    evidence += [WORK / (name + '.log') for name in ['delivery-home', 'delivery-shake', 'delivery-story',
                 'interaction-final', 'video-final', 'session-final']]
    evidence += [WORK / name for name in ['delivery-home', 'delivery-shake', 'session-final', 'video-final', 'interaction-final', 'delivery-story']]
    archives = dict(source=freeze('source-inputs', inputs), evidence=freeze('runtime-evidence', evidence),
                    windows=freeze('windows-release', [PROJECT / 'Builds/Windows']),
                    qa=freeze('windows-qa', [PROJECT / 'Builds/home-lighting-shake-qa']),
                    physicsQa=freeze('windows-physics-qa', [WORK / 'physics-qa']),
                    wechat=freeze('wechat-release', [ROOT / 'builds/catch-big-goose-wechat']))
    report = dict(build=BUILD, timestamp=datetime.datetime.now().astimezone().isoformat(),
                  passed=True, scope='Implementation and local/native/platform-preview acceptance; phone performance pending.',
                  unity='2022.3.62f3', runtime=runtime, editModeTests=int(tests['passed']),
                  rawWechatBytes=package['rawBytes'], appId=package['appId'],
                  platformPreviewBytes=publication['platformBytes'],
                  model=dict(triangles=1496, materials=2, maxTexture=256, diameter=4.6, glbRoundtrip=True,
                             gltfErrors=0, gltfWarnings=0, containerGuidsPreserved=True),
                  dpr=2, msaa=2, iphone15ProPerformancePassed=None,
                  unchangedGameData=unchanged_data,
                  qaProvenance=dict(homeAndVideo='Final explicit 1024 home shadow configuration',
                                    gameplayAndPhysics='Earlier full native QA; only home shadow configuration/QA capture wait changed afterward. All other script hashes verified unchanged.',
                                    physicsAssemblySha256=provenance['qaAssemblySha256']),
                  pending=['iPhone 15 Pro: sustained 30 FPS, thermal behavior, sensor force and visual quality on current QR.'],
                  archives=archives, errors=[])
    write(WORK / 'delivery.json', report)
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
