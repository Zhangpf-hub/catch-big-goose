import json,statistics,sys,math
from pathlib import Path
p=Path(sys.argv[1]);r=json.loads(p.read_text(encoding='utf-8-sig'));rows=r.get('rounds',[])
def stats(key,items):
    a=sorted(x[key] for x in items)
    return dict(min=min(a),median=statistics.median(a),p95=a[max(0,math.ceil(len(a)*.95)-1)],max=max(a)) if a else None
summary=dict(source=str(p),passed=r.get('passed'),checks=len(r.get('checks',[])),errors=r.get('errors',[]),rounds=len(rows),
    firstMs=stats('firstMs',rows),interactiveMs=stats('interactiveMs',rows),frameP95Ms=stats('frameP95Ms',rows),
    exposedByStage={str(stage):stats('accessible',[x for x in rows if x['stage']==stage]) for stage in [1,2]},
    allocationBytes=stats('allocatedBytes',[x for x in rows if 'allocatedBytes' in x]),
    percentileMethod='nearest rank across case samples',scope='Native forced-mobile, current report scope only. Not phone FPS or sensor evidence.')
p.with_name('summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(summary,ensure_ascii=False,indent=2))
