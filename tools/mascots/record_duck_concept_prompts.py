"""Recover this task's two actual built-in generation calls for the delivery record."""
import json
from pathlib import Path
from duck_series_catalog import OUT
log=Path('C:/Users/123/.codex/sessions/2026/10/25/rollout-2026-10-25T19-38-45-01a172db-1e1c-7cb2-9fab-67e2f22fc9b7.jsonl')
calls=[]
with log.open('r',encoding='utf-8') as f:
    for line in f:
        if 'image_gen__imagegen' not in line:continue
        row=json.loads(line);p=row.get('payload',{})
        if p.get('type')=='custom_tool_call' and p.get('name')=='exec':
            source=p.get('input','')
            if source.lstrip().startswith('// @exec:') and 'tools.image_gen__imagegen({' in source and ('farmer' in source.lower() or 'noodles' in source.lower()):
                calls.append({'timestamp':row.get('timestamp'),'callId':p.get('call_id'),'actualToolCallSource':source})
assert len(calls)==2,len(calls)
(OUT/'concepts/prompts.json').write_text(json.dumps({'mode':'built-in image_gen','calls':calls,'outputs':['farmer-fusion.png','noodles-fusion.png'],'purpose':'Fusion concept guidance only. Production review images come from actual GLB renders.'},ensure_ascii=False,indent=2),'utf-8')
print('Recorded',len(calls),'actual concept prompts')
