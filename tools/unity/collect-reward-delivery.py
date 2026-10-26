"""Freeze delivered files and evidence without modifying reference inputs."""
import hashlib
import json
import xml.etree.ElementTree as ET
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'work/video-rewards-20261025'
PROJECT = ROOT / 'projects/catch-big-goose-unity'
FROZEN = WORK / 'build-workspace/projects/catch-big-goose-unity'

def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def relative(path):
    return path.relative_to(ROOT).as_posix()

def main():
    runtime = read(WORK / 'runtime-integrated/acceptance.json')
    editor = ET.parse(WORK / 'editmode-integrated-results.xml').getroot().attrib
    package = read(WORK / 'wechat-package-audit.json')
    media = read(WORK / 'media-bridge-tests.json')
    native = read(WORK / 'native-video-bridge-tests.json')
    assert runtime['passed'] and editor['result'] == 'Passed' and package['localPackagePassed']
    assert media['passed'] and native['passed']
    windows = PROJECT / 'Builds/Windows'
    archive = WORK / 'catch-big-goose-video-rewards-windows.zip'
    with ZipFile(archive, 'w', ZIP_DEFLATED, compresslevel=5) as bundle:
        for file in sorted(windows.rglob('*')):
            if file.is_file():
                bundle.write(file, 'catch-big-goose/' + file.relative_to(windows).as_posix())
    wechat = ROOT / 'builds/catch-big-goose-wechat'
    preserved = read(WORK / 'preserved-legacy-export.json')
    config = read(wechat / 'project.config.json')
    for old in preserved:
        assert dict(type='file', value=old['path']) in config['packOptions']['ignore']
    assert sum(p.stat().st_size for p in wechat.rglob('*') if p.is_file() and p.suffix != '.meta') == package['rawBytes']
    wechat_archive = WORK / 'catch-big-goose-video-rewards-wechat.zip'
    legacy_paths = {old['path'] for old in preserved}
    with ZipFile(wechat_archive, 'w', ZIP_DEFLATED, compresslevel=5) as bundle:
        for file in sorted(wechat.rglob('*')):
            if file.is_file() and file.relative_to(wechat).as_posix() not in legacy_paths:
                bundle.write(file, 'catch-big-goose-wechat/' + file.relative_to(wechat).as_posix())
    frozen = {}
    changed = []
    for folder in ['Assets/Scripts', 'Assets/Resources/Data', 'Assets/Resources/Textures/reward-truck']:
        for file in sorted((FROZEN / folder).glob('*')):
            if not file.is_file() or file.suffix == '.meta':
                continue
            key = file.relative_to(FROZEN).as_posix()
            frozen[key] = sha(file)
            current = PROJECT / key
            if not current.exists() or sha(current) != frozen[key]:
                changed.append(key)
    (WORK / 'final-build-sources.json').write_text(json.dumps(frozen, indent=2), encoding='utf-8')
    targets = [archive, wechat_archive, windows / 'catch-big-goose.exe', windows / 'catch-big-goose_Data/Managed/CatchGoose.Runtime.dll',
               WORK / 'runtime-integrated/reward-flow-demo.mp4', WORK / 'runtime-integrated/truck-pass-demo.mp4',
               WORK / 'runtime-integrated/sale-demo.mp4', WORK / 'runtime-integrated/tray-revive-demo.mp4',
               WORK / 'runtime-integrated/timeout-revive-demo.mp4']
    report = dict(passed=True, unity='2022.3.62f3',
                  verification=dict(editorPassed=int(editor['passed']), editorFailed=int(editor['failed']),
                                    runtimePassed=len(runtime['checks']), runtimeErrors=runtime['errors'],
                                    completedActualVideos=runtime['completedVideos'], cancelledActualVideos=runtime['cancelledVideos'],
                                    mediaChecks=len(media['checks']), nativeVideoChecks=len(native['checks']),
                                    packageChecks=len(package['checks']), javascriptFiles=package['javascriptFiles'],
                                    packagedBytes=package['packagedBytes'], maximumBytes=30 * 1024 * 1024,
                                    localBudgetBytes=package.get('localBudgetBytes', 29 * 1024 * 1024),
                                    devToolsReserveBytes=package.get('devToolsReserveBytes', 1024 * 1024),
                                    physicalWeChatDeviceVerified=False),
                  artifacts=[dict(path=relative(file), bytes=file.stat().st_size, sha256=sha(file)) for file in targets],
                  currentWeChatProject='builds/catch-big-goose-wechat',
                  preservedLegacyExportFiles=preserved,
                  sourceSnapshot='work/video-rewards-20261025/final-build-sources.json',
                  concurrentSourceDifferences=changed,
                  sourceScope='Frozen WebGL build input; concurrent non-reward work remains in main workspace and is not reverted',
                  imageTool='built-in image_gen', imagePrompts='source-assets/ui/reward-truck-v1/prompts.json',
                  evidence=dict(runtime='work/video-rewards-20261025/runtime-integrated/acceptance.json',
                                editor='work/video-rewards-20261025/editmode-integrated-results.xml',
                                package='work/video-rewards-20261025/wechat-package-audit.json',
                                screenshots=['truck-360x640.png', 'truck-390x844.png', 'truck-430x932.png', 'truck-safe-area.png'],
                                recordings='Actual Unity renders, real elapsed timestamps, full videos, silent capture; checkpoint wait shortened in QA only'),
                  notes=['Original reference data and frozen evidence were not edited.',
                         'Windows QA uses local-only PlayerConnection; no firewall permission was requested.',
                         'No online upload or publication was performed.'])
    (WORK / 'delivery.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps(dict(passed=True, verification=report['verification'], artifacts=len(targets)), ensure_ascii=False))

if __name__ == '__main__':
    main()
