"""Compile explicitly bound source rows into per-theme two-stage definitions."""
import json,hashlib,shutil,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];WORK=ROOT/'work/two-stage-20261025';RES=ROOT/'projects/catch-big-goose-unity/Assets/Resources'
def read(p):return json.loads(p.read_text('utf-8-sig'))
def save(p,x):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n','utf8')
replacement_file=RES/'Data/model-replacements.json'
replacements=read(replacement_file)['replacements'] if replacement_file.exists() else []
def mid(n,theme_id):
    original='ref_'+n.lower()
    return next((r['replacement'] for r in replacements if r['theme']==theme_id and r['source']==original),original)
profiles=read(WORK/'source-profiles.json');themes=read(RES/'Data/themes.json')['themes'];by={t['id']:t for t in themes};rounds=[];audit=[]
for profile in profiles:
    theme=by[profile['theme']];full=profile['stages'][1]['rows'][0]
    theme['items']=[mid(n,theme['id']) for n in full['_namelist']];theme['coreGroupWeights']=full['_othertypeweight'];assert len(theme['items'])==len(theme['coreGroupWeights'])
    for stage in profile['stages']:
        first=stage['rows'][0];names=first['_namelist'];targets=[names[i-1] for i in first['_wintype']];layers=[]
        for row in stage['rows']:
            candidate=[names[i-1] for i in row['_cancreatetype']] if row['_cancreatetype'] else [n for n in names if n not in targets]
            ordinary=[n for n in names if n not in targets];weights=first['_othertypeweight'];weightNames=names if len(weights)==len(names) else ordinary
            assert len(weights)==len(weightNames),(theme['id'],stage['stage'])
            weightsBy=dict(zip(weightNames,weights));assert all(n in weightsBy for n in candidate)
            assert len(candidate)>=row['_typecount'],(theme['id'],len(candidate),row['_typecount'])
            layers.append(dict(normalCount=row['_sumcount'],kinds=row['_typecount'],sourceHeight=row['_height'],candidateItems=[mid(n,theme['id']) for n in candidate],candidateWeights=[weightsBy[n] for n in candidate]))
        assert len(targets)<=1
        entry=dict(themeId=theme['id'],stage=stage['stage'],sourceIndex=stage['sourceIndex'],sourceMode=stage['sourceMode'],sourceLevel=stage['stage'],custom=stage['custom'],seconds=first['_limittime'][0],targetCount=sum(first['_wincount']),targetItem=mid(targets[0],theme['id']) if targets else '',layers=1.2 if stage['stage']==1 else 5.0,pileLayers=layers,sourceScene=first['_sceneobj'],sourceSceneSize=first['_scenesize'],sourceLimitHeight=first['_limitheight'])
        rounds.append(entry);audit.append(dict(theme=theme['id'],stage=entry['stage'],total=sum(l['normalCount'] for l in layers)+entry['targetCount'],types=len(theme['items']),layerTypes=[l['kinds'] for l in layers],custom=entry['custom']))
    theme['coreWeightEvidence']='Explicit source binding; production quotas reside in theme-rounds, no fuzzy lookup.'
    # Keep the project's newer per-theme live container/scene presentation.
    # Source scene models are independently used for upper-counter dressing.
    if not theme.get('container','').startswith('round_'):
        theme['container']='scene_'+theme['id'];theme['circular']=theme['id']=='breakfast';theme['halfX']=theme['halfZ']=1.72;theme['background']='story-scenes/'+theme['id']+'-ground' if (RES/'Textures/story-scenes'/(theme['id']+'-ground.png')).exists() else 'mobile-ui/market-courtyard'
save(WORK/'themes-candidate.json',dict(themes=themes));save(WORK/'theme-rounds-candidate.json',dict(version=1,profiles=rounds))
save(WORK/'configuration-audit.json',dict(sourceSha256=hashlib.sha256((ROOT/'competitor-analysis/artifacts/competitor-config-trace/serialized-verified/LevelData.json').read_bytes()).hexdigest(),profiles=audit,defaults='Frozen 402 rows; no account AB or network hotfix; source units explicitly adapted.'))
if '--stage' in sys.argv:
    backup=ROOT/'projects/catch-big-goose-unity/SourceAssets/BeforeTwoStage-20261025/Data';backup.mkdir(parents=True,exist_ok=True)
    for name in ['themes.json','core-rounds.json','item-presentation.json']:
        if not (backup/name).exists():shutil.copy2(RES/'Data'/name,backup/name)
    for name in ['themes','theme-rounds']:shutil.copy2(WORK/(name+'-candidate.json'),RES/'Data'/(name+'.json'))
    batch=read(ROOT/'source-assets/models/candidates/two-stage-models-20261025/batch.json');byModel={m['id']:m for m in batch};provenance=[]
    for theme in themes:
        for id in theme['items']:
            source_id=next((r['source'] for r in replacements if r['theme']==theme['id'] and r['replacement']==id),id)
            source=Path(byModel[source_id]['sourceJson'])
            if not source.is_absolute():source=ROOT/source
            if not source.exists():source=Path(str(source).replace('references\\competitor-goose','reference-projects\\competitor-goose').replace('references/competitor-goose','reference-projects/competitor-goose'))
            data=read(source)
            provenance.append(dict(id=source_id,theme=theme['id'],sourceId=data['id'],prefab=data['prefab'],bundle=data['bundle'],sourceJson=source.relative_to(ROOT).as_posix(),sourceSha256=byModel[source_id]['sourceSha256'],poseBaked=(source.parent/'source-pose.json').exists()))
    assert len(provenance)==116
    save(RES/'Data/competitor-models.json',dict(date='2026-10-25',scope='Complete two-stage candidate pools; 116 unique source models; source prefab poses baked for gameplay.',models=provenance))
print(json.dumps(audit,ensure_ascii=False))
