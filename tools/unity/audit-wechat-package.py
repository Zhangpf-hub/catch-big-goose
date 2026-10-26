"""Inspect the actual exported package; report account/device gates separately."""
import hashlib, json, re, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PACKAGE = ROOT / 'builds/catch-big-goose-wechat'
if '--package' in sys.argv: PACKAGE=Path(sys.argv[sys.argv.index('--package')+1])
NODE = 'D:/开发/微信web开发者工具/node.exe'

def main():
    errors, checks = [], []
    def check(ok, description):
        (checks if ok else errors).append(description)
    project = json.loads((PACKAGE / 'project.config.json').read_text(encoding='utf-8-sig'))
    game = json.loads((PACKAGE / 'game.json').read_text(encoding='utf-8-sig'))
    check(project.get('compileType') == 'game', 'WeChat mini-game project type')
    check(project.get('setting', {}).get('es6') is True, 'ES module transpilation enabled for WeChat runtime')
    check(len(list(PACKAGE.rglob('project.config.json'))) == 1, 'No nested duplicate WeChat project in package')
    namespace = (PACKAGE / 'unity-namespace.js').read_text(encoding='utf-8-sig')
    check(re.search(r'\buseBrotliMT:\s*false\b', namespace) is not None, 'Release uses single-thread Brotli compression and decoder')
    manager_app_id = re.search(r"\bAPPID:\s*'([^']*)'", (PACKAGE / 'game.js').read_text(encoding='utf-8-sig'))
    check(manager_app_id is not None and manager_app_id.group(1) == project['appid'], 'Project AppID matches Unity runtime manager configuration')
    check(game['deviceOrientation'] == 'portrait', 'Portrait screen configuration')
    packages = {p['name']: p['root'] for p in game['subpackages']}
    check(all(p in packages for p in ['wasmcode', 'data-package', 'goose-media']), 'Wasm, first data and on-demand media subpackages')
    check(any((PACKAGE / packages['wasmcode']).glob('*.wasm.br')), 'Compiled compressed Wasm exists')
    check(any((PACKAGE / packages['data-package']).glob('*.bin.br')), 'First game resources bundled without CDN')
    launch=(PACKAGE/'game.js').read_text(encoding='utf-8-sig')
    for field,folder,suffix in [('DATA_FILE_MD5','data-package','.webgl.data.unityweb.bin.br'),('CODE_FILE_MD5','wasmcode','.webgl.wasm.code.unityweb.wasm.br')]:
        active=re.search(field+r"\s*:\s*['\"]([0-9a-f]{16,64})['\"]",launch)
        payloads=list((PACKAGE/packages[folder]).glob('*.br'))
        check(active is not None and len(payloads)==1 and payloads[0].name==active.group(1)+suffix,'Only the active '+folder+' payload remains physically in export')
    files = [p for p in PACKAGE.rglob('*') if p.is_file() and p.suffix != '.meta']
    total = sum(p.stat().st_size for p in files)
    excluded = []
    for file in files:
        relative=file.relative_to(PACKAGE).as_posix()
        for rule in project.get('packOptions',{}).get('ignore',[]):
            kind,value=rule['type'],rule['value'].strip('/')
            if not value or kind not in ('suffix','file','folder'):
                raise ValueError('Unsupported package ignore rule: '+str(rule))
            if (kind=='suffix' and relative.endswith(value)) or (kind=='file' and relative==value) or (kind=='folder' and (relative==value or relative.startswith(value+'/'))):
                excluded.append({'path':relative,'bytes':file.stat().st_size});break
    packaged=total-sum(row['bytes'] for row in excluded)
    check(packaged <= 30 * 1024 * 1024 - 512 * 1024, 'Published local files remain within 29.5 MiB release budget (512 KiB reserved for DevTools compilation)')
    check(project.get('setting', {}).get('uploadWithSourceMap') is False, 'Release uploads omit diagnostic source maps')
    videos = json.loads((PACKAGE / 'media/manifest.json').read_text(encoding='utf-8'))
    excluded_paths={row['path'] for row in excluded}
    required_payloads=[]
    for field,folder,suffix in [('DATA_FILE_MD5','data-package','.webgl.data.unityweb.bin.br'),('CODE_FILE_MD5','wasmcode','.webgl.wasm.code.unityweb.wasm.br')]:
        active=re.search(field+r"\s*:\s*['\"]([0-9a-f]{16,64})['\"]",launch)
        if active:required_payloads.append(packages[folder].strip('/')+'/'+active.group(1)+suffix)
    required_payloads.extend('media/'+row['name'] for row in videos['files'])
    check(not (set(required_payloads)&excluded_paths),'Active Wasm, data and both videos are included in upload')
    check(len(videos['files']) == 2, 'Both full mobile clips included')
    for file in videos['files']:
        actual = PACKAGE / 'media' / file['name']
        check(actual.stat().st_size == file['bytes'] and hashlib.sha256(actual.read_bytes()).hexdigest() == file['sha256'], 'Video package integrity: ' + file['name'])
        check(hashlib.sha256((ROOT / 'source-assets/videos' / file['name']).read_bytes()).hexdigest() == file['sourceSha256'], 'Source video preserved: ' + file['name'])
    scripts = list(PACKAGE.rglob('*.js'))
    for script in scripts:
        result = subprocess.run([NODE, '--input-type=module', '--check'], input=script.read_text(encoding='utf-8-sig'),
                                text=True, capture_output=True, encoding='utf-8')
        if result.returncode: errors.append(str(script.relative_to(PACKAGE)) + ': ' + result.stderr[:300])
    check(not any(': ' in item and '.js:' in item for item in errors), f'Exported JavaScript syntax checked ({len(scripts)} files)')
    font = json.loads((ROOT / 'work/wechat-integration/font-subset.json').read_text(encoding='utf-8'))
    check(hashlib.sha256((ROOT / font['target']).read_bytes()).hexdigest() == font['targetSha256'], 'Subset UI font integrity')
    report = dict(localPackagePassed=not errors, appId=project['appid'], ownAppIdConfigured=project['appid'] != 'touristappid',
        rawBytes=total, rawMiB=round(total / 1048576, 2), packagedBytes=packaged, packagedMiB=round(packaged/1048576,2), localBudgetBytes=30*1024*1024-512*1024, devToolsReserveBytes=512*1024, platformMaximumBytes=30*1024*1024, platformPreviewRequired=True, excludedFiles=excluded, javascriptFiles=len(scripts), checks=checks, errors=errors,
        accountTypeVerifiedByThisAudit=False, developerToolsRuntimePassed=None, iPhoneAcceptancePassed=None,
        scope='local_exported_files_only', runtimeEvidence='work/wechat-integration/simulator-acceptance.json',
        pending=['Verify registered mini-game account type and UnityPlugin permissions', 'Run actual mini-game simulator acceptance', 'Scan real preview QR with iPhone and finish device checks'])
    report_path=Path(sys.argv[sys.argv.index('--output')+1]) if '--output' in sys.argv else ROOT / 'work/wechat-integration/package-audit.json'
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if errors: raise SystemExit(1)

if __name__ == '__main__': main()
