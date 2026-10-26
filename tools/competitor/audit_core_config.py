"""Compare selected core profiles against complete multi-row level budgets."""
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'competitor-analysis/artifacts/competitor-runtime-trace'
def read(path): return json.loads(path.read_text('utf-8-sig'))
def dump(path,data):path.write_text(json.dumps(data,ensure_ascii=False,indent=2),'utf-8')

def main():
    table=read(ROOT/'competitor-analysis/artifacts/competitor-config-trace/serialized-verified/LevelData.json')['dataArray']
    catalog=read(ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data/core-rounds.json')
    result=[]
    for profile,(mode,level) in zip(catalog['profiles'],[('MainLevel',1),('OneScreenBattle',1),('MainLevel',2)]):
        rows=[r for r in table if r['_index']==5 and r['_gametype']==mode and r['_level']==level]
        assert len(rows)==len(profile['pileLayers'])
        for r,l in zip(rows,profile['pileLayers']):
            assert (r['_sumcount'],r['_typecount'],r['_height'])==(l['normalCount'],l['kinds'],l['sourceHeight'])
        targets=sum(rows[0]['_wincount'])
        assert targets==profile['targetCount']
        assert profile['seconds']==rows[0]['_limittime'][0]
        result.append(dict(profile=profile['id'],mode=mode,index=5,level=level,layerCount=len(rows),
                           normalBudget=sum(r['_sumcount'] for r in rows),targetBudget=targets,
                           total=sum(r['_sumcount'] for r in rows)+targets,seconds=profile['seconds'],
                           layers=[{k:r[k] for k in ['_sumcount','_typecount','_height','_limitheight','_limittime','_wincount']} for r in rows]))
    # CDN comparison distinguishes exact JSON representation from meaningful values.
    bundle=read(ROOT/'competitor-analysis/artifacts/competitor-config-trace/serialized-verified/ABTestData.json')['dataArray']
    cdn=read(WORK/'public-config/ABTestData.config');by={r['FeatureKey']:r for r in cdn}
    fields={'_featurekey':'FeatureKey','_isopen':'IsOpen','_forkkeylist':'ForkKeyList','_forkweightlist':'ForkWeightList',
            '_tempint':'TempInt','_tempfloat':'TempFloat','_tempstring':'TempString'}
    differences=[dict(key=r['_featurekey'],field=k,bundled=r[k],cdn=by.get(r['_featurekey'],{}).get(v))
                 for r in bundle for k,v in fields.items() if (r[k] or '')!=(by.get(r['_featurekey'],{}).get(v) or '')]
    localhotfix=read(WORK/'runtime-objects/HotFixScriptable-810.json')['data']
    remotehotfix=read(WORK/'public-config/HotFixLevelHard.txt')
    comparison=dict(bundledRows=len(bundle),cdnRows=len(cdn),nullAndEmptyStringComparedEqual=True,
                    differences=differences,hotfixRows=len(remotehotfix),hotfixEqualsBundled=localhotfix==remotehotfix,
                    relevant=[r for r in cdn if r['FeatureKey'] in ['ABEasySpLevel','ABDaliyLevelSimple','ABDaliyLevelSimple2']])
    dump(WORK/'public-config/comparison.json',comparison)
    dump(WORK/'core-configuration-audit.json',dict(passed=True,profiles=result,
        limits=['Raw configured kind counts match source, runtime clamps them to our available models',
                'Difficulty labels map three source archetypes into our single-player UI; not original progression',
                'Source heights are retained; actual spawning uses our scale, clear-drop and density adapter',
                'No AB reduction is applied without explicit own configuration; source weight arrays are not mapped to unrelated items']))
    print(json.dumps(dict(profiles=[dict(id=r['profile'],total=r['total']) for r in result],cdnDifferences=len(differences),hotfixEqualsBundled=comparison['hotfixEqualsBundled'])))

if __name__=='__main__':main()
