"""Verify the complete surface matrix and bind the actual QA/export file sets."""
import argparse
import hashlib
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'work/mobile-surface-performance-20261026'
PROJECT = Path(json.loads((ROOT / 'workspace.json').read_text('utf-8-sig'))['paths']['unity'])
SNAPSHOT = WORK / 'build-workspace' / PROJECT


def read(path):
    return json.loads(path.read_text('utf-8-sig'))


def sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def files(directory):
    return {p.relative_to(directory).as_posix(): dict(bytes=p.stat().st_size, sha256=sha(p))
            for p in sorted(directory.rglob('*')) if p.is_file()}


def runtime_inputs(project):
    result = {}
    for prefix in ('Assets/Scripts', 'Assets/Resources/Data', 'Assets/Plugins/WebGL'):
        for path in sorted((project / prefix).rglob('*')):
            if path.is_file() and path.suffix in ('.cs', '.json', '.asmdef', '.jslib'):
                result[path.relative_to(project).as_posix()] = sha(path)
    for path in (project / 'Assets/Resources').rglob('*'):
        if path.suffix in ('.shader', '.cginc'):
            result[path.relative_to(project).as_posix()] = sha(path)
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--matrix', default='matrix-final-shake5-r2')
    parser.add_argument('--require-wechat', action='store_true')
    args = parser.parse_args()
    report_path = WORK / args.matrix / 'surface-acceptance.json'
    matrix = read(report_path)
    assert matrix['completed'] and matrix['passed'] and not matrix['errors'], 'Matrix is incomplete or failed'
    themes = [t['id'] for t in read(SNAPSHOT / 'Assets/Resources/Data/themes.json')['themes']]
    assert len(themes) == 5
    stocks = (300, 71, 70, 69, 18, 3)
    for theme in themes:
        for stock in stocks:
            rows = [r for r in matrix['rows'] if r['theme'] == theme and r['stock'] == stock]
            expected = {'idle', 'sensor', 'sensor-moderate'} if stock == 300 else {'idle', 'button'}
            operations = {r['operation'] for r in rows}
            assert expected <= operations, (theme, stock, 'missing operation', operations)
            assert 'shuffle' in operations or 'shuffle-unavailable-single' in operations, (theme, stock, 'missing shuffle result')
            assert all(r['lowerViolations'] == 0 for r in rows), (theme, stock, 'lower support moved')
    assert len(matrix['rows']) == 95, 'Expected all five themes, six stocks and both phone amplitudes'
    tests = ET.parse(WORK / 'editmode.xml').getroot()
    assert tests.attrib['failed'] == '0' and int(tests.attrib['passed']) >= 64, 'Edit tests did not pass'
    build = re.search(r'BuildId\s*=\s*"([^"]+)"', (SNAPSHOT / 'Assets/Scripts/GooseRuntimePerformance.cs').read_text('utf-8-sig')).group(1)
    assert matrix['build'] == build
    snapshot_inputs = runtime_inputs(SNAPSHOT)
    current_inputs = runtime_inputs(ROOT / PROJECT)
    differences = [name for name in sorted(snapshot_inputs.keys() | current_inputs.keys())
                   if snapshot_inputs.get(name) != current_inputs.get(name)]
    summary = dict(build=build, nativeMatrixPassed=True, matrix=str(report_path.relative_to(ROOT)),
                   matrixSha256=sha(report_path), checks=len(matrix['checks']), rows=len(matrix['rows']),
                   editorTests=int(tests.attrib['passed']), currentRuntimeMatchesTestedSnapshot=not differences,
                   currentRuntimeDifferences=differences, testedRuntimeInputs=snapshot_inputs,
                   phoneAcceptancePassed=False,
                   phoneScope='iPhone 15 Pro selected. User reported improved responsiveness before SHAKE5; current-build sustained FPS and physical shake pending.',
                   nativeScope=matrix['scope'], qaPlayer=files(WORK / 'player'))
    export = WORK / 'build-workspace/builds/catch-big-goose-wechat'
    if args.require_wechat:
        assert (export / 'game.js').is_file() and (export / 'wasmcode').is_dir(), 'Current snapshot WebGL export missing'
        summary['wechatFiles'] = files(export)
        summary['liveWechatFiles'] = files(ROOT / 'builds/catch-big-goose-wechat')
        summary['liveWechatMatchesTestedExport'] = summary['wechatFiles'] == summary['liveWechatFiles']
    idle = [r for r in matrix['rows'] if r['operation'] == 'idle']
    summary['idle300'] = [{key: r[key] for key in ('theme', 'modelSize', 'surface', 'visible', 'renderers', 'dynamicBodies', 'awake', 'depthRefreshMs', 'p95ms')}
                          for r in idle if r['stock'] == 300]
    summary['maxPlanningSliceMs'] = max(r['shuffleMaxSliceMs'] for r in matrix['rows'])
    summary['lowerViolations'] = sum(r['lowerViolations'] for r in matrix['rows'])
    (WORK / 'delivery-verification.json').write_text(json.dumps(summary, ensure_ascii=False, indent=2), 'utf-8')
    print(json.dumps({key: summary[key] for key in ('build', 'nativeMatrixPassed', 'checks', 'rows', 'editorTests',
                                                  'currentRuntimeMatchesTestedSnapshot', 'lowerViolations', 'phoneAcceptancePassed')}, ensure_ascii=False))


if __name__ == '__main__':
    main()
