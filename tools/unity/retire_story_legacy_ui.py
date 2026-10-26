"""Archive obsolete scene illustrations after checking all live source/config references."""
from pathlib import Path
import json,shutil,hashlib
ROOT=Path(__file__).resolve().parents[2];RES=(ROOT/'projects/catch-big-goose-unity/Assets/Resources').resolve();DEST=(ROOT/'projects/catch-big-goose-unity/SourceAssets/BeforeTwoStage-20261025/retired-ui').resolve()
files=['Textures/mobile-ui/market-table.png','Textures/mobile-ui/goose-hero.png']
files+=['Textures/'+n for n in ['bg_dessert.jpg','bg_electronics.jpg','bg_farm.jpg','bg_jade.jpg','bg_redwood.jpg']]
sources=list((ROOT/'projects/catch-big-goose-unity/Assets/Scripts').glob('*.cs'))+list((RES/'Data').glob('*.json'))+list((ROOT/'projects/catch-big-goose-unity/Assets/Scenes').glob('*.unity'))
text='\n'.join(p.read_text('utf-8-sig') for p in sources);moved=[]
for relative in files:
    p=(RES/relative).resolve();target=(DEST/relative).resolve();assert p.is_relative_to(RES) and target.is_relative_to(DEST)
    if not p.exists():continue
    assert p.stem not in text,(p,'path reference remains')
    meta=Path(str(p)+'.meta')
    if meta.exists():
        guid=next(l.split(':',1)[1].strip() for l in meta.read_text('utf8').splitlines() if l.startswith('guid:'))
        assert guid not in text,(p,'GUID reference remains')
    for src,dst in [(p,target),(meta,Path(str(target)+'.meta'))]:
        if not src.exists():continue
        assert not dst.exists(),dst;dst.parent.mkdir(parents=True,exist_ok=True)
        moved.append(dict(source=str(src.relative_to(ROOT)),destination=str(dst.relative_to(ROOT)),bytes=src.stat().st_size,sha256=hashlib.sha256(src.read_bytes()).hexdigest()))
        shutil.move(str(src),str(dst))
report=DEST/'manifest.json';old=json.loads(report.read_text('utf8')) if report.exists() else []
report.parent.mkdir(parents=True,exist_ok=True);report.write_text(json.dumps(old+moved,ensure_ascii=False,indent=2),'utf8')
print('Archived unused UI assets:',len(moved),'paths,',sum(x['bytes'] for x in moved),'bytes; metadata retained.')
