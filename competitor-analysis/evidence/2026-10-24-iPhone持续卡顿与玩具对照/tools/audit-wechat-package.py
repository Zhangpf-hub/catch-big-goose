"""Inspect the actual exported package; report account/device gates separately."""
import hashlib, json, re, subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PACKAGE = ROOT / 'unity/Builds/WeChat/minigame'
NODE = 'D:/开发/微信web开发者工具/node.exe'

def main():
    errors, checks = [], []
    def check(ok, description):
        (checks if ok else errors).append(description)
    project = json.loads((PACKAGE / 'project.config.json').read_text(encoding='utf-8-sig'))
    game = json.loads((PACKAGE / 'game.json').read_text(encoding='utf-8-sig'))
    check(project.get('compileType') == 'game', 'WeChat mini-game project type')
    check(project.get('setting', {}).get('es6') is True, 'ES module transpilation enabled for WeChat runtime')
    manager_app_id = re.search(r"\bAPPID:\s*'([^']*)'", (PACKAGE / 'game.js').read_text(encoding='utf-8-sig'))
    check(manager_app_id is not None and manager_app_id.group(1) == project['appid'], 'Project AppID matches Unity runtime manager configuration')
    check(game['deviceOrientation'] == 'portrait', 'Portrait screen configuration')
    packages = {p['name']: p['root'] for p in game['subpackages']}
    check(all(p in packages for p in ['wasmcode', 'data-package', 'goose-media']), 'Wasm, first data and on-demand media subpackages')
    check(any((PACKAGE / packages['wasmcode']).glob('*.wasm.br')), 'Compiled compressed Wasm exists')
    check(any((PACKAGE / packages['data-package']).glob('*.bin.br')), 'First game resources bundled without CDN')
    total = sum(p.stat().st_size for p in PACKAGE.rglob('*') if p.is_file() and p.suffix != '.meta')
    check(total <= 30 * 1024 * 1024, 'Raw project file total within conservative 30 MiB budget')
    videos = json.loads((PACKAGE / 'media/manifest.json').read_text(encoding='utf-8'))
    check(len(videos['files']) == 2, 'Both full mobile clips included')
    for file in videos['files']:
        actual = PACKAGE / 'media' / file['name']
        check(actual.stat().st_size == file['bytes'] and hashlib.sha256(actual.read_bytes()).hexdigest() == file['sha256'], 'Video package integrity: ' + file['name'])
        check(hashlib.sha256((ROOT / 'video' / file['name']).read_bytes()).hexdigest() == file['sourceSha256'], 'Source video preserved: ' + file['name'])
    scripts = list(PACKAGE.rglob('*.js'))
    for script in scripts:
        result = subprocess.run([NODE, '--input-type=module', '--check'], input=script.read_text(encoding='utf-8-sig'),
                                text=True, capture_output=True, encoding='utf-8')
        if result.returncode: errors.append(str(script.relative_to(PACKAGE)) + ': ' + result.stderr[:300])
    check(not any(': ' in item and '.js:' in item for item in errors), f'Exported JavaScript syntax checked ({len(scripts)} files)')
    font = json.loads((ROOT / 'work/wechat-integration/font-subset.json').read_text(encoding='utf-8'))
    check(hashlib.sha256((ROOT / font['target']).read_bytes()).hexdigest() == font['targetSha256'], 'Subset UI font integrity')
    report = dict(localPackagePassed=not errors, appId=project['appid'], ownAppIdConfigured=project['appid'] != 'touristappid',
        rawBytes=total, rawMiB=round(total / 1048576, 2), javascriptFiles=len(scripts), checks=checks, errors=errors,
        accountTypeVerifiedByThisAudit=False, developerToolsRuntimePassed=None, iPhoneAcceptancePassed=None,
        scope='local_exported_files_only', runtimeEvidence='work/wechat-integration/simulator-acceptance.json',
        pending=['Verify registered mini-game account type and UnityPlugin permissions', 'Run actual mini-game simulator acceptance', 'Scan real preview QR with iPhone and finish device checks'])
    (ROOT / 'work/wechat-integration/package-audit.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if errors: raise SystemExit(1)

if __name__ == '__main__': main()
