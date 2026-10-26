"""Move replaced ordinary props out of Resources, with explicit path checks."""
from pathlib import Path
import json,shutil,re
ROOT=Path(__file__).resolve().parents[2]
RES=(ROOT/'projects/catch-big-goose-unity/Assets/Resources').resolve()
ARCHIVE=(ROOT/'projects/catch-big-goose-unity/SourceAssets/BeforeCompetitorReplacement-20261025').resolve()
old=json.loads((ARCHIVE/'Data/themes.json').read_text(encoding='utf8'))['themes']
new=json.loads((RES/'Data/themes.json').read_text(encoding='utf8'))['themes']
keep={i for t in new for i in t['items']}|{t['container'] for t in new}|{'goose','shiba','giraffe'}
retired=[]
for id in sorted({i for t in old for i in t['items']}-keep):
    assert re.fullmatch('[a-z0-9_]+',id),id
    for kind,suffix in [('Models',''),('Icons','.png'),('Physics','.asset')]:
        source=(RES/kind/(id+suffix)).resolve()
        destination=(ARCHIVE/'retired-runtime'/kind/(id+suffix)).resolve()
        assert source.is_relative_to(RES) and destination.is_relative_to(ARCHIVE)
        for a,b in [(source,destination),(Path(str(source)+'.meta'),Path(str(destination)+'.meta'))]:
            if not a.exists():continue
            assert not b.exists(),b
            b.parent.mkdir(parents=True,exist_ok=True);shutil.move(str(a),str(b))
            retired.append({'from':str(a.relative_to(ROOT)),'to':str(b.relative_to(ROOT))})
report=ARCHIVE/'retired-assets.json'
previous=json.loads(report.read_text(encoding='utf8')) if report.exists() else []
report.write_text(json.dumps(previous+retired,ensure_ascii=False,indent=2),encoding='utf8')
print('Retired',len(retired),'asset paths outside Resources; original copies and metadata retained.')
