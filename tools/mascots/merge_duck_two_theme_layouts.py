"""Merge four newly simulated layouts, preserving the other six verbatim as data."""
import json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];DATA=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data';OUT=ROOT/'work/duck-live-two-themes'
def read(p):return json.loads(p.read_text('utf-8-sig'))
def main():
    source=Path(sys.argv[1]) if len(sys.argv)>1 else OUT/'cold-mobile/prepared-layouts.json'
    evidence=read(source.parent/'acceptance.json');assert evidence['passed']
    fresh=read(source)['layouts'];assert {(r['theme'],r['stage']) for r in fresh}=={(t,s) for t in ['breakfast','barbecue'] for s in [0,1]}
    themes={r['id']:r for r in read(DATA/'themes.json')['themes']}
    for row in fresh:
        assert len(row['items'])==(15 if row['stage']==0 else 300)
        assert all(p['id'] in themes[row['theme']]['items'] and not p['id'].startswith('ref_goose_') for p in row['items'])
    current=read(DATA/'prepared-layouts.json');other=[r for r in current['layouts'] if r['theme'] not in ['breakfast','barbecue']]
    baseline=[r for r in read(OUT/'before/prepared-layouts.json')['layouts'] if r['theme'] not in ['breakfast','barbecue']]
    assert other==baseline
    current['layouts']=fresh+other;assert len(current['layouts'])==10
    (DATA/'prepared-layouts.json').write_text(json.dumps(current,ensure_ascii=False,separators=(',',':')),'utf-8')
    (OUT/'layout-update.json').write_text(json.dumps({'passed':True,'newLayouts':len(fresh),'unchangedOtherLayouts':len(other),'source':str(source)},ensure_ascii=False,indent=2),'utf-8')
    print('Merged four duck layouts; preserved six unrelated layouts')
if __name__=='__main__':main()
