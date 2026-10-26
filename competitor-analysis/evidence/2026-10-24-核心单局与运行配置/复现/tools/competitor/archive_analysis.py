"""Archive reviewable evidence, history and the tested source without modifying originals."""
import hashlib
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / '竞品分析'
EVIDENCE = DEST / '证据' / '2026-10-22-生成与深度'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def copy(source, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)


def main():
    history = DEST / '历史'
    for source, name in [
        (ROOT / 'references/competitor-goose/2026-10-22/evidence/竞品分析.md', '2026-10-21-初始报告.md'),
        (ROOT / '开发计划/竞品对齐与算法复核_20261022.md', '2026-10-22-首轮对齐.md'),
    ]:
        target = history / name
        if not target.exists():
            copy(source, target)

    recovered = ROOT / 'work/competitor-deep'
    for source in recovered.iterdir():
        if source.suffix in {'.wat', '.wasm', '.watfrag', '.json'}:
            copy(source, EVIDENCE / '方法体' / source.name)
    validation = ROOT / 'work/competitor-algorithm-tests'
    for name in ['isolated-original.wasm', 'original-cases.csv', 'original-weight-traces.csv',
                 'wasm-probe.json', 'policy-tests.json', 'unity-editmode-results.xml',
                 'algorithm-acceptance.json', 'algorithm-player.log']:
        copy(validation / name, EVIDENCE / '验证' / name)
    for name in ['recovery.json', 'package-inventory.json']:
        copy(ROOT / 'references/competitor-goose/2026-10-22/algorithm' / name,
             EVIDENCE / '来源' / name)

    build = ROOT / 'unity/Builds/AlgorithmQA'
    copy(build / 'source-hashes.tsv', EVIDENCE / '验证' / 'source-hashes.tsv')
    matches = []
    for row in (build / 'source-hashes.tsv').read_text(encoding='utf-8-sig').splitlines():
        name, expected = row.replace('\\t', '\t').split('\t')
        source = ROOT / 'unity/Assets/Scripts' / name
        actual = digest(source)
        if expected != actual:
            raise RuntimeError(f'Tested source differs from current source: {name}')
        copy(source, EVIDENCE / 'Unity源码快照' / name)
        matches.append({'file': name, 'sha256': actual, 'matchesTestedBuild': True})
    for path in ['unity/Assets/Resources/Data/pile-algorithms.json',
                 'unity/Assets/Tests/Editor/GooseDepthIntegrationTests.cs',
                 'unity/Assets/Editor/GooseAlgorithmBuild.cs', 'tests/competitor/PolicyTests.cs',
                 'tools/competitor/probe_original_algorithms.mjs',
                 'tools/competitor/validate_recovered.mjs', 'tools/competitor/recover_methods.py',
                 'tools/competitor/archive_analysis.py',
                 'tools/competitor/run_policy_tests.ps1', 'tools/competitor/run_unity_algorithm_tests.ps1']:
        copy(ROOT / path, EVIDENCE / '复现源码' / path)

    methods = json.loads((recovered / 'method-map.json').read_text(encoding='utf-8'))
    test = json.loads((validation / 'algorithm-acceptance.json').read_text(encoding='utf-8'))
    edit = ET.parse(validation / 'unity-editmode-results.xml').getroot()
    report = {
        'archivedAtUtc': datetime.now(timezone.utc).isoformat(),
        'sampleDate': '2026-10-22', 'appId': 'wxb98ac240fd74b0e3', 'localPackageVersion': '401',
        'compiledMethodCount': len(methods),
        'methodModule': json.loads((recovered / 'selected-validation.json').read_text(encoding='utf-8')),
        'originalWasmProbe': json.loads((validation / 'wasm-probe.json').read_text(encoding='utf-8')),
        'policyTests': json.loads((validation / 'policy-tests.json').read_text(encoding='utf-8')),
        'unityEditMode': {'result': edit.attrib['result'], 'passed': int(edit.attrib['passed']), 'failed': int(edit.attrib['failed']), 'endTimeUtc': edit.attrib['end-time']},
        'unityRuntime': {'passed': test['passed'], 'checks': len(test['checks']), 'errors': test['errors'], 'unityVersion': test['unityVersion']},
        'testedRuntimeSource': matches,
        'playerExeSha256': digest(build / 'CatchGooseAlgorithmQA.exe'),
        'limits': ['Not original C# source', 'Five isolated original helper bodies are executed with host adapters',
                   'No complete competitor game execution or configuration equivalence',
                   'Headless Unity physics QA is not visual, mouse/touch or mobile performance acceptance']
    }
    (EVIDENCE / '验证汇总.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    rows = []
    for source in sorted(EVIDENCE.rglob('*')):
        if source.is_file() and source.name != '文件校验.json':
            rows.append({'path': source.relative_to(EVIDENCE).as_posix(), 'bytes': source.stat().st_size, 'sha256': digest(source)})
    (EVIDENCE / '文件校验.json').write_text(json.dumps(rows, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'Archived {len(rows)} files; {len(matches)} runtime source hashes match the tested build.')


if __name__ == '__main__':
    main()
