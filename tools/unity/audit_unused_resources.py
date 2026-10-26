"""Resolve live model IDs and serialized GUID references before resource cleanup."""
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
PROJECT=ROOT/'projects/catch-big-goose-unity'
ASSETS=PROJECT/'Assets'
OUT=ROOT/'work/resource-cleanup-20261026'


def build_plan():
    resources=ASSETS/'Resources'
    data=resources/'Data'
    themes=json.loads((data/'themes.json').read_text(encoding='utf8'))['themes']
    review=json.loads((data/'duck-review.json').read_text(encoding='utf8'))['themes']
    reference=json.loads((data/'reference-lab.json').read_text(encoding='utf8'))['theme']
    required={'goose','home-table','scene_breakfast','scene_toys','scene_grocery'}
    containers=set()
    for theme in themes+review+[reference]:
        required.update(theme['items']);required.add(theme['container']);containers.add(theme['container'])
        if theme.get('icon'):required.add(theme['icon'])
    models={p.name for p in (resources/'Models').iterdir() if p.is_dir()}
    unused=sorted(models-required)
    candidates=[]
    def include(path,reason):
        if path.exists():candidates.append({'path':path.relative_to(PROJECT).as_posix(),'reason':reason})
    for item in unused:include(resources/'Models'/item,'Absent from formal/review/reference catalogs and live scene dressing')
    for folder,keep in [('Icons',required),('Physics',required),('ContainerPhysics',containers)]:
        for path in (resources/folder).glob('*'):
            if path.is_file() and path.suffix!='.meta' and path.stem not in keep:
                include(path,'No live '+folder+' lookup for model '+path.stem)
    for path in ['Resources/Mascots/ShibaHome.prefab','Mascots/Shiba','Mascots/Giraffe','retired-mascots','Resources/Audio/honk.wav']:
        include(ASSETS/path,'Replaced legacy mascot or sound; no production loader remains')
    for path in (ASSETS/'MobileContact').glob('*'):
        if path.is_file() and path.suffix!='.meta' and path.stem not in containers:
            include(path,'Obsolete container collision authoring input')
    for path in ['Editor/GooseWeChatLegacyResources.cs','Editor/GiraffeModelSetup.cs','Editor/ShibaModelSetup.cs',
                 'Scripts/GiraffeMascot.cs','Scripts/ShibaMascot.cs','Scripts/GiraffeModelAcceptance.cs','Scripts/ShibaModelAcceptance.cs']:
        include(ASSETS/path,'Obsolete legacy-only builder/test/component')
    selected=set()
    for candidate in candidates:
        path=PROJECT/candidate['path']
        selected.update(p for p in path.rglob('*') if p.is_file()) if path.is_dir() else selected.add(path)
        meta=Path(str(path)+'.meta')
        if meta.exists():selected.add(meta)
    used_guids=set();metadata=[]
    text_suffixes={'.prefab','.mat','.asset','.unity','.controller','.overridecontroller','.json','.meta'}
    for path in ASSETS.rglob('*'):
        if not path.is_file() or path in selected or path.suffix not in text_suffixes:continue
        text=path.read_text(encoding='utf8',errors='ignore')
        if path.suffix=='.meta':text=re.sub(r'(?m)^guid: [0-9a-f]{32}\r?\n','',text)
        used_guids.update(re.findall(r'guid:\s*([0-9a-f]{32})',text))
        if path.suffix=='.json':metadata.append(text)
    named_text='\n'.join(metadata)
    for path in (resources/'ReferenceTextures').glob('*.png'):
        meta=Path(str(path)+'.meta');match=re.search(r'^guid: ([0-9a-f]{32})',meta.read_text(encoding='utf8'),re.M)
        if match and match[1] not in used_guids and path.stem not in named_text:
            include(path,'No surviving serialized GUID or material-metadata texture reference')
            selected.add(path);selected.add(meta)
    guids={}
    for path in selected:
        if path.suffix=='.meta':
            match=re.search(r'^guid: ([0-9a-f]{32})',path.read_text(encoding='utf8',errors='ignore'),re.M)
            if match:guids[match[1]]=str(path.relative_to(PROJECT))
    blocked=[]
    for path in ASSETS.rglob('*'):
        if not path.is_file() or path in selected or path.suffix=='.cs':continue
        if path.suffix.lower() not in text_suffixes:continue
        text=path.read_text(encoding='utf8',errors='ignore')
        if path.suffix=='.meta':text=re.sub(r'(?m)^guid: [0-9a-f]{32}\r?\n','',text)
        for guid in set(re.findall(r'guid:\s*([0-9a-f]{32})',text))&guids.keys():
            blocked.append({'referrer':path.relative_to(PROJECT).as_posix(),'target':guids[guid]})
    for candidate in candidates:
        path=PROJECT/candidate['path']
        files=list(path.rglob('*')) if path.is_dir() else [path]
        candidate['sourceBytes']=sum(p.stat().st_size for p in files if p.is_file())
    return dict(requiredModelIds=sorted(required),unusedModelIds=unused,candidates=candidates,
                candidateCount=len(candidates),sourceBytes=sum(p.stat().st_size for p in selected),
                serializedReferenceBlockers=blocked)


if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    plan=build_plan()
    name='post-cleanup-audit.json' if (OUT/'deleted-resources.json').exists() else 'cleanup-plan.json'
    (OUT/name).write_text(json.dumps(plan,ensure_ascii=False,indent=2),encoding='utf8')
    print(json.dumps({k:plan[k] for k in ['unusedModelIds','candidateCount','sourceBytes','serializedReferenceBlockers']},ensure_ascii=False,indent=2))
