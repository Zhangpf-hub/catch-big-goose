"""Independently compare shipped stage contracts with the frozen source table."""
from pathlib import Path
import json,hashlib,sys
ROOT=Path(__file__).resolve().parents[2];RES=ROOT/'projects/catch-big-goose-unity/Assets/Resources';WORK=ROOT/'work/two-stage-20261025'
if '--project' in sys.argv:RES=Path(sys.argv[sys.argv.index('--project')+1])/'Assets/Resources'
def read(p):return json.loads(p.read_text('utf-8-sig'))
replacement_file=RES/'Data/model-replacements.json'
replacements=read(replacement_file)['replacements'] if replacement_file.exists() else []
def mid(n,theme_id):
    original='ref_'+n.lower()
    return next((r['replacement'] for r in replacements if r['theme']==theme_id and r['source']==original),original)
table=read(ROOT/'competitor-analysis/artifacts/competitor-config-trace/serialized-verified/LevelData.json')['dataArray'];catalog=read(RES/'Data/theme-rounds.json')['profiles'];themes=read(RES/'Data/themes.json')['themes']
bindings={'breakfast':(8,'MainLevel'),'barbecue':(5,'MainLevel'),'countryside':(1,'MainLevel'),'grocery':(4,'MainLevel'),'toys':(19181,'GooseToysSpLevel')};checked=[]
for theme in themes:
    index,mode=bindings[theme['id']]
    second=[r for r in table if (r['_index'],r['_gametype'],r['_level'])==(index,mode,2)]
    assert theme['items']==[mid(n,theme['id']) for n in second[0]['_namelist']],theme['id']
    for stage in [1,2]:
        p=next(p for p in catalog if p['themeId']==theme['id'] and p['stage']==stage)
        if theme['id']=='toys' and stage==1:
            assert p['custom'] and p['seconds']==0 and p['targetItem']=='ref_goose_gtnumberblock' and p['targetCount']==3
            assert p['pileLayers']==[dict(normalCount=12,kinds=2,sourceHeight=6,candidateItems=['ref_gtcrocodile','ref_gtdinosaur'],candidateWeights=[1,1])]
        else:
            rows=[r for r in table if (r['_index'],r['_gametype'],r['_level'])==(index,mode,stage)];head=rows[0];names=head['_namelist'];targets=[names[i-1] for i in head['_wintype']]
            assert not p['custom'] and (p['sourceIndex'],p['sourceMode'],p['sourceLevel'])==(index,mode,stage)
            assert p['seconds']==head['_limittime'][0] and p['targetCount']==sum(head['_wincount'])
            assert p['targetItem']==(mid(targets[0],theme['id']) if targets else '')
            assert len(p['pileLayers'])==len(rows)
            for source,layer in zip(rows,p['pileLayers']):
                assert (layer['normalCount'],layer['kinds'],layer['sourceHeight'])==(source['_sumcount'],source['_typecount'],source['_height'])
                candidate=[names[i-1] for i in source['_cancreatetype']] if source['_cancreatetype'] else [n for n in names if n not in targets]
                assert layer['candidateItems']==[mid(n,theme['id']) for n in candidate]
                weightNames=names if len(head['_othertypeweight'])==len(names) else [n for n in names if n not in targets]
                assert layer['candidateWeights']==[head['_othertypeweight'][weightNames.index(n)] for n in candidate]
        checked.append(dict(theme=theme['id'],stage=stage,total=sum(x['normalCount'] for x in p['pileLayers'])+p['targetCount'],custom=p['custom']))
    for id in theme['items']:
        for path in [RES/'Models'/id/(id+'.fbx'),RES/'Icons'/(id+'.png'),RES/'Physics'/(id+'.asset')]:assert path.is_file(),path
contracts=read(RES/'Data/reference-material-models.json')['models']
assert {r['id'] for r in contracts}=={id for t in themes for id in t['items'] if id.startswith('ref_')}
provenance=read(RES/'Data/competitor-models.json')['models'];assert len(provenance)==116
for p in provenance:
    source=ROOT/p['sourceJson']
    if not source.exists():source=Path(str(source).replace('references\\competitor-goose','reference-projects\\competitor-goose').replace('references/competitor-goose','reference-projects/competitor-goose'))
    assert hashlib.sha256(source.read_bytes()).hexdigest()==p['sourceSha256']
report=dict(passed=True,source='Frozen 402 LevelData; explicit own-model substitutions; no account AB/hotfix applied',models=len(provenance),materials=sum(m['materials'] for m in contracts),profiles=checked,authoredReplacements=replacements)
output=Path(sys.argv[sys.argv.index('--output')+1]) if '--output' in sys.argv else WORK/'source-verification.json'
output.parent.mkdir(parents=True,exist_ok=True);output.write_text(json.dumps(report,ensure_ascii=False,indent=2),'utf8');print(json.dumps(report,ensure_ascii=False))
