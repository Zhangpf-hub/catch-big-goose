"""Copy validated candidates to Cocos' non-resources pool; never fabricate .meta files."""
import argparse
import hashlib
import json
import shutil
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--project', type=Path, required=True)
parser.add_argument('--candidate', type=Path, required=True)
parser.add_argument('--replace', action='store_true', help='Update differing candidate files while preserving existing .meta UUIDs')
args = parser.parse_args()
batch = args.candidate.resolve()
audit = json.loads((batch / 'qa/asset-audit.json').read_text(encoding='utf-8'))
icons = json.loads((batch / 'qa/icon-audit.json').read_text(encoding='utf-8'))
assert audit['physics']['containmentPassed'] and not audit['physics']['warnings']
assert all(x['transparentMarginPassed'] for x in icons)
destination = args.project.resolve() / 'reference-projects/catch-big-goose-cocos/assets/models-pool/electronics'
pending = []
for row in audit['models']:
    assert row['validatorErrors'] == 0 and row['validatorWarnings'] == 0 and row['convexHullPassed']
    model_id = row['id']
    assert model_id in {'phone', 'laptop', 'camera', 'headphones', 'handheld', 'speaker', 'mouse', 'smartwatch', 'radio'}
    source = batch / 'models' / f'{model_id}.glb'
    assert hashlib.sha256(source.read_bytes()).hexdigest() == row['sha256'], f'Stale GLB audit: {model_id}'
    for source, target in [(source, destination / source.name),
                           (batch / 'icons' / f'{model_id}.png', destination / 'icons' / f'{model_id}.png')]:
        if target.exists() and target.read_bytes() != source.read_bytes() and not args.replace:
            raise SystemExit(f'Refusing to replace differing candidate without --replace: {target}')
        pending.append((source, target))
for source, target in pending:
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)
print(f'Staged {len(audit["models"])} validated models and icons at {destination}; Creator generates new .meta files.')
