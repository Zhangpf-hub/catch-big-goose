"""Archive the 2026-10-23 configuration/mode evidence and tested Unity sources."""
import hashlib
import json
import shutil
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TRACE = ROOT / 'competitor-analysis/artifacts/competitor-config-trace'
TESTS = ROOT / 'competitor-analysis/artifacts/competitor-20261023-tests'
DEST = ROOT / 'competitor-analysis/evidence/2026-10-23-配置与模式'
REFERENCE = ROOT / 'reference-projects/competitor-goose/2026-10-23'


def sha(file):
    return hashlib.sha256(file.read_bytes()).hexdigest()


def copy(source, relative):
    target = DEST / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)


def dump(file, data):
    file.parent.mkdir(parents=True, exist_ok=True)
    file.write_text(json.dumps(data, ensure_ascii=True, indent=2) + '\n', encoding='utf-8')


def main():
    methods = TRACE / 'methods'
    for source in methods.iterdir():
        if source.suffix in {'.wat', '.watfrag', '.wasm', '.json'}:
            copy(source, Path('方法与调用图') / source.name)
    tables = ['LevelData', 'EndlessLevelData', 'LevelABData', 'LevelDetailData', 'LevelInfoData',
              'LongLevelData', 'MainLevelUpgradedData', 'PVPLevelData', 'PVPLevelRuleData',
              'SeasonLevelData', 'SeasonLevelSpModeData', 'SpLevelData', 'ActivityLevelData',
              'NewYearLevelData', 'DailyChallengeData']
    for table in tables:
        for suffix in ['.json', '-schema.json']:
            copy(TRACE / 'serialized-verified' / (table + suffix), Path('关卡配置') / (table + suffix))
        for source in (TRACE / 'serialized-verified/raw').glob(table + '-*.bin'):
            copy(source, Path('关卡配置/raw') / source.name)
    copy(TRACE / 'serialized-verified/index.json', '关卡配置/读取校验索引.json')
    manager = json.loads((TRACE / 'serialized-verified/LevelManager.json').read_text(encoding='utf-8'))
    keys = ['_rigidDepth', '_visibleMinHeight', '_visibleMaxHeight', '_minVisibleY', '_maxOnceTouchHeight',
            '_maxPhysicObjCount', '_maxCreateInterval', '_frameMaxCreateCount', '_createGrowSpeed',
            '_physicCreateTime', '_physicMaxCreateInterval', '_physicFrameCreateCount', '_physicCreateGrowSpeed',
            '_isUseRealPhysicSpace', '_physicOverlapSpeed', '_gravitySpeed', '_layerMinDistance']
    dump(DEST / '关卡配置/LevelManager-depth.json', {key: manager[key] for key in keys})
    copy(TRACE / 'serialized-verified/LevelManager-layout.txt', '关卡配置/LevelManager-layout.txt')
    copy(TRACE / 'serialized-verified/raw/LevelManager-896.bin', '关卡配置/raw/LevelManager-896.bin')
    copy(TRACE / 'packages-402/packages.json', '来源/packages-402.json')
    snapshot = next((TRACE / 'source').glob('*.webgl.data.unityweb.bin'))
    packages = json.loads((TRACE / 'packages-402/packages.json').read_text(encoding='utf-8'))
    dump(DEST / '来源/版本与来源.json', {
        'packageVersion': '402', 'snapshotFile': snapshot.name, 'snapshotBytes': snapshot.stat().st_size,
        'snapshotSha256': sha(snapshot), 'metadataSha256': sha(TRACE / 'source/global-metadata.dat'),
        'wasm': [entry['wasm'] for package in packages for entry in package['entries'] if entry.get('wasm')],
        'previousPackageVersion': '401', 'relation': 'Metadata hash unchanged; code/data package hashes differ. This round uses a fresh 402 WAT and pointer mapping.',
        'localSourceSnapshot': str(snapshot.relative_to(ROOT))
    })
    for source in TESTS.iterdir():
        if source.suffix in {'.json', '.xml', '.csv', '.wasm'}:
            copy(source, Path('验证') / source.name)
    for name in ['algorithm-player.log']:
        copy(TESTS / name, Path('验证') / name)
    runtime_snapshots = TESTS / 'tested-runtime-sources'
    for source in runtime_snapshots.iterdir():
        copy(source, Path('完整运行源码快照') / source.name)
    all_runtime_hashes = json.loads((TESTS / 'tested-source-hashes.json').read_text(encoding='utf-8-sig'))
    for name, expected in all_runtime_hashes.items():
        if sha(ROOT / 'projects/catch-big-goose-unity/Assets/Scripts' / name) != expected:
            raise RuntimeError('Runtime dependency changed after tested build: ' + name)
    build = ROOT / 'projects/catch-big-goose-unity/Builds/AlgorithmQA'
    source_matches = []
    copy(build / 'source-hashes.tsv', '验证/source-hashes.tsv')
    for line in (build / 'source-hashes.tsv').read_text(encoding='utf-8-sig').splitlines():
        name, expected = line.replace('\\t', '\t').split('\t')
        source = ROOT / 'projects/catch-big-goose-unity/Assets/Scripts' / name
        actual = sha(source)
        if expected != actual:
            raise RuntimeError('Source changed after tested build: ' + name)
        copy(source, Path('Unity源码快照') / name)
        source_matches.append({'file': name, 'sha256': actual, 'matchesTestedBuild': True})
    for source in (ROOT / 'tools/competitor').iterdir():
        if source.suffix in {'.py', '.mjs', '.ps1'}:
            copy(source, Path('复现源码/tools/competitor') / source.name)
    for name in ['tests/competitor/PolicyTests.cs', 'projects/catch-big-goose-unity/Assets/Resources/Data/pile-algorithms.json',
                 'projects/catch-big-goose-unity/Assets/Tests/Editor/GooseDepthIntegrationTests.cs', 'projects/catch-big-goose-unity/Assets/Editor/GooseAlgorithmBuild.cs']:
        copy(ROOT / name, Path('复现源码') / name)

    table_index = json.loads((TRACE / 'serialized-verified/index.json').read_text(encoding='utf-8'))
    test = json.loads((TESTS / 'algorithm-acceptance.json').read_text(encoding='utf-8'))
    edit = ET.parse(TESTS / 'unity-editmode-results.xml').getroot()
    mapping = json.loads((methods / 'method-map.json').read_text(encoding='utf-8'))
    manifest = json.loads((REFERENCE / 'manifest.json').read_text(encoding='utf-8'))
    model_checks = json.loads((REFERENCE / 'gltf-validation.json').read_text(encoding='utf-8'))
    if not test['passed'] or not model_checks['passed'] or table_index['failures']:
        raise RuntimeError('Required evidence contains a failure')
    summary = {
        'archivedAtUtc': datetime.now(timezone.utc).isoformat(), 'packageVersion': '402',
        'mappedMethodEntries': len(mapping), 'uniqueCompiledBodies': len({m['wasmSymbol'] for m in mapping}),
        'rejectedEntries': len(json.loads((methods / 'rejected-methods.json').read_text(encoding='utf-8'))),
        'serializedObjectsDecoded': len(table_index['objects']), 'serializedTableByteRoundTrips': sum(bool(o.get('byteExactRoundTrip')) for o in table_index['objects']),
        'levelRows': 1129, 'endlessRows': 966,
        'originalWasmProbe': json.loads((TESTS / 'wasm-probe.json').read_text(encoding='utf-8')),
        'modePolicyProbe': json.loads((TESTS / 'mode-policy-probe.json').read_text(encoding='utf-8')),
        'policyTests': json.loads((TESTS / 'policy-tests.json').read_text(encoding='utf-8')),
        'unityEditMode': {'passed': int(edit.attrib['passed']), 'failed': int(edit.attrib['failed']), 'endTimeUtc': edit.attrib['end-time']},
        'unityRuntime': {'passed': test['passed'], 'checks': len(test['checks']), 'unityVersion': test['unityVersion'], 'errors': test['errors']},
        'testedSources': source_matches,
        'allRuntimeSourceHashes': all_runtime_hashes,
        'models': {'newStaticReferences': len(manifest['models']), 'skinnedSkipped': len(manifest['skipped']), 'gltfValidationPassed': model_checks['passed']},
        'limits': ['Serialized scene/config values are not post-network runtime values',
                   '344 method mappings share 251 bodies; not 344 independent functions or complete semantic interpretations',
                   'Mode helper execution is not complete mode initialization or play',
                   'Quota fixtures interpret source WAT; full original CreateLevel is not executed',
                   'Unity headless QA does not verify rendering, human input, mobile performance or shipping builds',
                   'Reference alpha is a PBR approximation; source Toon/MatCap shaders are not reproduced']
    }
    dump(DEST / '验证汇总.json', summary)
    # Model manifest is separate, so large visual sources are not duplicated here.
    model_integrity = [{'path': p.relative_to(REFERENCE).as_posix(), 'bytes': p.stat().st_size, 'sha256': sha(p)}
                       for p in sorted(REFERENCE.rglob('*')) if p.is_file() and p.name != '文件校验.json']
    dump(REFERENCE / '文件校验.json', model_integrity)
    integrity = [{'path': p.relative_to(DEST).as_posix(), 'bytes': p.stat().st_size, 'sha256': sha(p)}
                 for p in sorted(DEST.rglob('*')) if p.is_file() and p.name != '文件校验.json']
    dump(DEST / '文件校验.json', integrity)
    print('Archived', len(integrity), 'evidence files;', len(model_integrity), 'reference files;', len(source_matches), 'tested runtime source hashes match.')


if __name__ == '__main__':
    main()
