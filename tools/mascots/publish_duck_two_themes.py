"""Apply the explicit eight-model rollout without changing stock or tuning."""
import json,hashlib,copy,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
DATA=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data'
OUT=ROOT/'work/duck-live-two-themes'
def read(p):return json.loads(p.read_text('utf-8-sig'))
def write(p,v):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n','utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    rows=read(DATA/'model-replacements.json')['replacements'];mappings={}
    for row in rows:mappings.setdefault(row['theme'],{})[row['source']]=row['replacement']
    assert set(mappings)=={'breakfast','barbecue'} and all(len(m)==4 for m in mappings.values())
    for row in rows:
        id=row['replacement'];res=DATA.parent
        for f in [res/'Models'/id/(id+'.fbx'),res/'Models'/id/'duck-mobile.mat',res/'Icons'/(id+'.png'),res/'Physics'/(id+'.asset')]:assert f.is_file(),f
    before={name:read(DATA/name) for name in ['themes.json','theme-rounds.json']};after=copy.deepcopy(before)
    for name,value in before.items():
        backup=OUT/'before'/name
        if not backup.exists():write(backup,value)
    for theme in after['themes.json']['themes']:
        mapping=mappings.get(theme['id'],{});theme['items']=[mapping.get(id,id) for id in theme['items']]
    for profile in after['theme-rounds.json']['profiles']:
        mapping=mappings.get(profile['themeId'],{});profile['targetItem']=mapping.get(profile['targetItem'],profile['targetItem'])
        for layer in profile['pileLayers']:layer['candidateItems']=[mapping.get(id,id) for id in layer['candidateItems']]
    # Reverse replacement must recover every original field, including counts,
    # weights, targets, background/container and the three unaffected themes.
    check=copy.deepcopy(after)
    for theme in check['themes.json']['themes']:
        inverse={v:k for k,v in mappings.get(theme['id'],{}).items()};theme['items']=[inverse.get(id,id) for id in theme['items']]
    for profile in check['theme-rounds.json']['profiles']:
        inverse={v:k for k,v in mappings.get(profile['themeId'],{}).items()};profile['targetItem']=inverse.get(profile['targetItem'],profile['targetItem'])
        for layer in profile['pileLayers']:layer['candidateItems']=[inverse.get(id,id) for id in layer['candidateItems']]
    for name in before:
        baseline=read(OUT/'before'/name);assert check[name]==baseline,name
        write(DATA/name,after[name])
    layouts=DATA/'prepared-layouts.json';old=read(layouts);backup=OUT/'before/prepared-layouts.json'
    if not backup.exists():write(backup,old)
    old['layouts']=[r for r in old['layouts'] if r['theme'] not in mappings or not any(p['id'] in mappings[r['theme']] for p in r['items'])]
    write(layouts,old)
    write(OUT/'rollout.json',{'replacements':rows,'themes':list(mappings),'onlyModelIdentifiersChanged':True,
        'preserved':['counts','weights','seconds','layer kinds','backgrounds','containers','other three themes'],
        'configHashes':{name:sha(DATA/name) for name in after},'retainedOtherLayouts':len(old['layouts'])})
    print('Published 8 model substitutions in breakfast/barbecue; removed stale goose layouts')
if __name__=='__main__':main()
