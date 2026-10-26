"""Verify the complete surface matrix and bind the actual QA/export file sets."""
import argparse
import hashlib
import json
import math
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


def build_inputs(project):
    return {prefix + '/' + name: row for prefix in ('Assets', 'Packages', 'ProjectSettings')
            for name, row in files(project / prefix).items()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--matrix', default='matrix-release-shake6')
    parser.add_argument('--require-wechat', action='store_true')
    parser.add_argument('--require-published', action='store_true')
    parser.add_argument('--capture-inputs', action='store_true')
    parser.add_argument('--capture-native-inputs', action='store_true')
    args = parser.parse_args()
    if args.capture_inputs:
        original = build_inputs(ROOT / PROJECT)
        copied = build_inputs(SNAPSHOT)
        assert original == copied, 'Copied snapshot differs from the live source inputs'
        (WORK / 'source-inputs.json').write_text(json.dumps(original, ensure_ascii=False, indent=2), 'utf-8')
        print(json.dumps(dict(sourceInputFiles=len(original), copiedSnapshotMatches=True)))
        return
    if args.capture_native_inputs:
        (WORK / 'native-build-inputs.json').write_text(json.dumps(build_inputs(SNAPSHOT), ensure_ascii=False, indent=2), 'utf-8')
        print('Recorded native snapshot build inputs')
        return
    report_path = WORK / args.matrix / 'surface-acceptance.json'
    assert args.matrix.startswith('matrix-'), 'Matrix run name must start with matrix-'
    run_name = args.matrix[len('matrix-'):]
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
    assert tests.attrib['failed'] == '0' and int(tests.attrib['passed']) >= 66, 'Edit tests did not pass'
    build = re.search(r'BuildId\s*=\s*"([^"]+)"', (SNAPSHOT / 'Assets/Scripts/GooseRuntimePerformance.cs').read_text('utf-8-sig')).group(1)
    platform = read(WORK / 'platform-retry-validation.json')
    assert platform['passed'] and platform['callbackChecks'] >= 27
    assert platform['sourceSha256'].lower() == sha(SNAPSHOT / 'Assets/Scripts/GooseWeChatPlatform.cs'), 'Platform callback validation is stale'
    assert matrix['build'] == build
    snapshot_inputs = runtime_inputs(SNAPSHOT)
    current_inputs = runtime_inputs(ROOT / PROJECT)
    player_files = files(WORK / 'player')
    def bind_run(directory):
        manifest = read(directory / 'player-files.json')
        actual = {row['path']: dict(bytes=row['bytes'], sha256=row['sha256']) for row in manifest}
        assert actual == player_files, f'{directory.name} used a different QA player'
    bind_run(report_path.parent)
    fallback_dir = WORK / ('fallback-0-' + run_name)
    fallback = read(fallback_dir / 'surface-acceptance.json')
    assert fallback['completed'] and fallback['passed'] and not fallback['errors'], 'Pinned/free/single fixtures failed'
    assert fallback['build'] == build
    assert {'fixture-pinned-three', 'fixture-free-three', 'fixture-pinned-single'} <= {r['operation'] for r in fallback['rows']}
    if build.endswith('SHAKE7'):
        assert {'fixture-actual-tilted-steamer-single', 'fixture-actual-max-unique-single', 'fixture-actual-max-raw-single'} <= {r['operation'] for r in fallback['rows']}, 'Actual convex and vertex-budget regressions are missing'
        assert 'same-frame containment corrects both actual and rendered centers within the original policy' in fallback['checks']
    bind_run(fallback_dir)
    clip_dir = WORK / ('clip-0-' + run_name)
    clip = read(clip_dir / 'surface-acceptance.json')
    assert clip['completed'] and clip['passed'] and not clip['errors'] and clip['build'] == build
    assert len(clip['clipFrames']) == 33, 'Production camera capture incomplete'
    assert (clip_dir / 'clip-before.png').is_file()
    assert all((clip_dir / frame['file']).is_file() for frame in clip['clipFrames']), 'Camera pixels missing'
    bind_run(clip_dir)
    toss_proofs = []
    if build.endswith('SHAKE7'):
        interrupt_dir = WORK / ('interrupt-' + run_name)
        interrupt = read(interrupt_dir / 'surface-acceptance.json')
        assert interrupt['completed'] and interrupt['passed'] and not interrupt['errors'] and interrupt['build'] == build
        assert len([c for c in interrupt['checks'] if c == 'home interrupts a genuinely active paid shuffle rather than an unavailable operation']) == 5
        bind_run(interrupt_dir)
        for theme, stock in ((0, 300), (1, 18), (0, 3)):
            directory = WORK / f'toss-{theme}-stock-{stock}-{run_name}'
            result = read(directory / 'surface-acceptance.json')
            assert result['completed'] and result['passed'] and not result['errors'] and result['build'] == build
            assert len(result['clipFrames']) == 33 and (directory / 'clip-before.png').is_file()
            assert all((directory / frame['file']).is_file() for frame in result['clipFrames'])
            assert len(result['rows']) == 1
            row = result['rows'][0]
            required = max(1, math.ceil(row['surface'] * .6))
            assert row['motionMode'] == 'controlled-pan-toss' and row['tossCompleted'] and not row['tossFailure']
            assert row['controlledTossObserved'] and row['jointEnough'] >= required and row['visibleArcEnough'] >= required
            assert len(row['tossTargets']) == row['surface']
            assert sum(t['airborneFlip'] and t['maxRise'] >= .6 * row['itemScale'] and t['maxTurn'] >= 75
                       for t in row['tossTargets']) >= required
            assert sum(t['peakXZ'] >= .18 * row['itemScale'] and t['peakXZPixels'] >= 15
                       for t in row['tossTargets']) >= required
            assert not row['lowerViolations'] and not row['tossFloorViolations'] and not row['tossBoundaryViolations']
            assert not row['fallbackAttempted']
            bind_run(directory)
            toss_proofs.append(dict(directory=directory.name, sha256=sha(directory / 'surface-acceptance.json'),
                                    targets=row['surface'], airborneFlip=row['jointEnough'], visibleArc=row['visibleArcEnough']))
    regressions = {}
    for name, filename, minimum in (('interaction', 'interaction.json', 61), ('selection', 'acceptance.json', 122)):
        directory = WORK / (name + '-' + run_name)
        result = read(directory / filename)
        assert result['passed'] and not result['errors'] and len(result['checks']) >= minimum, name + ' regression failed'
        bind_run(directory)
        regressions[name] = dict(checks=len(result['checks']), sha256=sha(directory / filename))
    differences = [name for name in sorted(snapshot_inputs.keys() | current_inputs.keys())
                   if snapshot_inputs.get(name) != current_inputs.get(name)]
    source_inputs = read(WORK / 'source-inputs.json')
    live_inputs = build_inputs(ROOT / PROJECT)
    input_differences = [name for name in sorted(source_inputs.keys() | live_inputs.keys())
                         if source_inputs.get(name) != live_inputs.get(name)]
    native_inputs = read(WORK / 'native-build-inputs.json')
    verification_inputs = build_inputs(SNAPSHOT)
    export_stage_changes = [name for name in sorted(native_inputs.keys() | verification_inputs.keys())
                            if native_inputs.get(name) != verification_inputs.get(name)]
    summary = dict(build=build, nativeMatrixPassed=True, matrix=str(report_path.relative_to(ROOT)),
                   matrixSha256=sha(report_path), checks=len(matrix['checks']), rows=len(matrix['rows']),
                   editorTests=int(tests.attrib['passed']), currentRuntimeMatchesTestedSnapshot=not differences,
                   currentRuntimeDifferences=differences, testedRuntimeInputs=snapshot_inputs,
                   currentBuildInputsMatchCopiedSource=not input_differences,
                   currentBuildInputDifferences=input_differences,
                   copiedSourceInputManifestSha256=sha(WORK / 'source-inputs.json'),
                   nativeBuildInputManifestSha256=sha(WORK / 'native-build-inputs.json'),
                   snapshotBuildInputsAtVerification=verification_inputs,
                   snapshotInputChangesAfterNativeBuild=export_stage_changes,
                   phoneAcceptancePassed=False,
                   phoneScope='iPhone 15 Pro selected. User previously reported improved responsiveness; current SHAKE7 physical shake and sustained device FPS remain unverified.',
                   nativeScope=matrix['scope'], qaPlayer=player_files, regressions=regressions,
                   platformValidationSha256=sha(WORK / 'platform-retry-validation.json'),
                   fallbackReportSha256=sha(fallback_dir / 'surface-acceptance.json'),
                   cameraReportSha256=sha(clip_dir / 'surface-acceptance.json'), panTossProofs=toss_proofs)
    export = WORK / 'build-workspace/builds/catch-big-goose-wechat'
    if args.require_wechat or args.require_published:
        assert not differences, 'Live runtime source changed since the tested snapshot'
        assert not input_differences, 'Live build inputs changed since copying the tested source'
        assert (export / 'game.js').is_file() and (export / 'wasmcode').is_dir(), 'Current snapshot WebGL export missing'
        summary['wechatFiles'] = files(export)
        summary['liveWechatFiles'] = files(ROOT / 'builds/catch-big-goose-wechat')
        summary['liveWechatMatchesTestedExport'] = summary['wechatFiles'] == summary['liveWechatFiles']
        if args.require_published:
            assert summary['liveWechatMatchesTestedExport'], 'Published package differs from the tested export'
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
