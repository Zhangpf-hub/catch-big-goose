"""Archive unused pre-market UI outside Resources, retaining original bytes/GUIDs."""
import hashlib
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'unity/Assets/Resources/Textures/challenge-ui'
TARGET = ROOT / 'unity/SourceAssets/ReferenceLookBaseline-20261025/retired-ui/challenge-ui'
MANIFEST = ROOT / 'unity/SourceAssets/ReferenceLookBaseline-20261025/retired-ui.json'

assert SOURCE.resolve().is_relative_to((ROOT / 'unity/Assets/Resources/Textures').resolve())
assert TARGET.resolve().is_relative_to((ROOT / 'unity/SourceAssets/ReferenceLookBaseline-20261025').resolve())
if SOURCE.exists():
    # This folder belongs to the superseded challenge-map interface. Dynamic
    # loads and serialized references must remain absent before moving it.
    guids = [p.read_text('utf-8').split('guid: ')[1].splitlines()[0] for p in SOURCE.glob('*.meta')]
    for folder in ['Scripts', 'Editor', 'Scenes']:
        for path in (ROOT / 'unity/Assets' / folder).rglob('*'):
            if path.is_file() and path.suffix in ['.cs', '.unity', '.prefab', '.asset']:
                text = path.read_text('utf-8-sig', errors='replace')
                assert 'challenge-ui/' not in text, path
                assert not any(guid in text for guid in guids), path
    assert not TARGET.exists(), 'Archive already exists: inspect before replacing it'
    rows = [dict(original=p.relative_to(ROOT).as_posix(), archived=(TARGET / p.name).relative_to(ROOT).as_posix(),
                 bytes=p.stat().st_size, sha256=hashlib.sha256(p.read_bytes()).hexdigest())
            for p in sorted(SOURCE.iterdir()) if p.is_file()]
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(SOURCE), str(TARGET))
    folder_meta = Path(str(SOURCE) + '.meta')
    if folder_meta.exists():
        shutil.move(str(folder_meta), str(TARGET) + '.meta')
    MANIFEST.write_text(json.dumps(dict(reason='No current code/scene references; superseded challenge UI excluded from Resources.', files=rows),
                                   ensure_ascii=False, indent=2), encoding='utf-8')
report = json.loads(MANIFEST.read_text('utf-8'))
for row in report['files']:
    assert hashlib.sha256((ROOT / row['archived']).read_bytes()).hexdigest() == row['sha256']
print(json.dumps(dict(archivedFiles=len(report['files']), bytes=sum(x['bytes'] for x in report['files']),
                      scope='Unused old UI only; current market UI, models, source textures and full clips retained.')))
