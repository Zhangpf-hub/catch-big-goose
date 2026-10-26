"""Recover source BaseTint and alpha labels for the runtime atlas, not source lighting."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'competitor-analysis/artifacts/competitor-replacement-20261025'
OUT=ROOT/'source-assets/models/candidates/competitor-runtime-20261025'
batch=json.loads((WORK/'batch.json').read_text(encoding='utf8'))
for item in batch:
    source=Path(item['source']).parent
    raw=json.loads((source/'source.json').read_text(encoding='utf8'))
    result=[]
    for m in raw['materials'].values():
        tint=m['colors'].get('_BaseTint') or m['colors'].get('_BaseColor') or m['colors'].get('_Color') or [1,1,1,1]
        color=list(tint[:3])+[1]
        texture=m['textures'].get('_BaseColor') or m['textures'].get('_MainTex')
        if m['floats'].get('_IsSingleColor',0)>0.5:texture=None
        # Single-pass mobile approximation: keep the cup label but flatten its
        # clear shell over the serialized yellow drink, instead of an opaque white shell.
        if item['id']=='ref_bfcornjuice' and 'Glass' in (m.get('shader') or ''):
            base=next(x for x in raw['materials'].values() if x['name']=='yumizhi')
            color=list(base['colors']['_BaseTint'][:3])+[1]
        result.append({'name':m['name'],'color':color,'texture':texture['file'] if texture else None,'alphaOverTint':True,
                       'sourceShader':m.get('shader'),'glassFlattened':'Glass' in (m.get('shader') or '')})
    file=OUT/item['id']/'runtime-material-input.json'
    file.write_text(json.dumps({'materials':result},ensure_ascii=False,indent=2),encoding='utf8')
    item['materialFile']=str(file);item['pipelineVersion']=8
(WORK/'batch.json').write_text(json.dumps(batch,ensure_ascii=False,indent=2),encoding='utf8')
print('Prepared source BaseTint and alpha-label bindings for',len(batch),'models')
