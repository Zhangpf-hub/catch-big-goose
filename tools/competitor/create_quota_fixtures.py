"""Fixtures from actual rows and the interpreted CreateLevel L33 quota formula.

These are deliberately not labelled as full original-WASM execution. Candidate
types are fixed in source order for the fixture; AB and network offsets are zero.
"""
import json
import math
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'competitor-analysis/artifacts/competitor-config-trace/serialized-verified'
OUTPUT = ROOT / 'competitor-analysis/artifacts/competitor-20261023-tests'


def f32(value):
    return struct.unpack('<f', struct.pack('<f', value))[0]


def main():
    rows = json.loads((SOURCE / 'LevelData.json').read_text(encoding='utf-8'))['dataArray']
    fixtures = []
    for index, row in enumerate(rows):
        weights = row['_othertypeweight']
        groups = max(1, row['_sumcount'] // 3)
        selected_count = min(len(weights), row['_typecount'], groups)
        if selected_count < 1:
            continue
        selected = weights[:selected_count]
        total = 0.0
        for value in selected:
            total = f32(total + value)
        if total <= 0 or any(not math.isfinite(w) or w < 0 for w in selected):
            continue
        counts, remaining = [], groups
        for weight in selected[:-1]:
            count = round(f32(f32(float(groups) * weight) / total))
            counts.append(count)
            remaining -= count
        counts.append(remaining)
        if remaining < 0:
            continue  # The production over-allocation guard is tested separately.
        fixtures.append((str(index), str(groups), ';'.join(str(w) for w in selected), ';'.join(str(n) for n in counts)))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    (OUTPUT / 'source-group-quotas.csv').write_text('\n'.join(','.join(c) for c in fixtures) + '\n', encoding='utf-8')
    (OUTPUT / 'source-group-quotas-scope.json').write_text(json.dumps({
        'fixtures': len(fixtures), 'sourceTableRows': len(rows),
        'scope': 'Interpreted WAT quota formula with real serialized weights; fixed first-N selected types, zero AB/hotfix offsets; not the actual random type selection or full CreateLevel execution.'
    }, indent=2) + '\n', encoding='utf-8')
    print('WAT-derived real-row quota fixtures:', len(fixtures))


if __name__ == '__main__':
    main()
