"""Archive current R4 inputs and collected evidence without claiming device QA."""
from pathlib import Path
import datetime,hashlib,json,shutil
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'work/r4-interaction-20261025/delivery'
OUT.mkdir(parents=True,exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(name,obj):
    (OUT/name).write_text(json.dumps(obj,ensure_ascii=False,indent=2),encoding='utf-8')
selected=[]
for directory in ['projects/catch-big-goose-unity/Assets/Scripts','projects/catch-big-goose-unity/Assets/Tests','projects/catch-big-goose-unity/Assets/Editor','projects/catch-big-goose-unity/Assets/Resources/Data','projects/catch-big-goose-unity/ProjectSettings']:
    selected.extend(p for p in (ROOT/directory).rglob('*') if p.is_file() and p.suffix in ['.cs','.json','.asset','.meta'])
for theme in ['breakfast','barbecue','countryside','toys','grocery']:
    selected.extend(p for p in (ROOT/'projects/catch-big-goose-unity/Assets/Resources/Models'/('round_'+theme+'_r4')).rglob('*') if p.is_file())
    selected.extend((ROOT/'projects/catch-big-goose-unity/Assets/Resources/Textures/mobile-ui/themes').glob(theme+'-r4.png*'))
for folder in ['projects/catch-big-goose-unity/Packages','projects/catch-big-goose-unity/Assets/Plugins/WebGL']:
    selected.extend(p for p in (ROOT/folder).rglob('*') if p.is_file() and p.suffix in ['.json','.jslib','.meta'])
selected.extend((ROOT/'projects/catch-big-goose-unity/Assets/Resources').glob('*.shader*'))
selected.extend((ROOT/'tools/unity').glob('*r4*'))
for rel in ['projects/catch-big-goose-unity/ProjectSettings/ProjectVersion.txt','tools/unity/build-wechat.ps1','tools/unity/audit-wechat-package.py','tools/unity/check-wechat-media.mjs','docs/development-reports/26-预加载连续消除与圆筐物理.md']:
    selected.append(ROOT/rel)
for rel in ['source-assets/models/candidates/r4-scenes-20261025/backgrounds/manifest.json','source-assets/models/candidates/r4-scenes-20261025/backgrounds/prompts.json','source-assets/models/candidates/r4-scenes-20261025/containers/validation.json']:
    selected.append(ROOT/rel)
entries=[]
for p in sorted(set(selected)):
    rel=p.relative_to(ROOT);dest=OUT/'sources'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
    entries.append(dict(path=rel.as_posix(),sha256=sha(p),bytes=p.stat().st_size))
save('source-map.json',dict(build='20261025-R4',timestamp=datetime.datetime.now().astimezone().isoformat(),files=entries))
resources=ROOT/'projects/catch-big-goose-unity/Assets/Resources'
save('resource-inputs.json',dict(files=[dict(path=p.relative_to(ROOT).as_posix(),sha256=sha(p),bytes=p.stat().st_size) for p in sorted(resources.rglob('*')) if p.is_file() and p.suffix!='.meta']))
builds=[]
for directory in ['projects/catch-big-goose-unity/Builds/R4QA20','work/r4-interaction-20261025/release-windows-floor','work/r4-interaction-20261025/release-wechat-floor']:
    d=ROOT/directory
    if d.exists():builds.append(dict(root=directory,files=[dict(path=p.relative_to(d).as_posix(),sha256=sha(p),bytes=p.stat().st_size) for p in sorted(d.rglob('*')) if p.is_file() and p.suffix!='.meta']))
save('build-files.json',dict(timestamp=datetime.datetime.now().astimezone().isoformat(),builds=builds,scope='File hashes only; build success and source correspondence require matching logs.'))
for rel in ['floor-final-50/r4-acceptance.json','floor-final-50/summary.json','floor-final-50/player.log','endgame-floor/r4-acceptance.json','endgame-floor/summary.json','ui-floor/ui-acceptance.json','interaction-floor/interaction.json','editmode-floor.xml','editmode-floor.log','build-qa20.log','build-windows-floor.log','perf-single-player/r4-acceptance.json','perf-single-player/summary.json','baseline-comparison.json','final-floor-audit.json','requirement-audit.json','delivery-summary.json']:
    src=OUT.parent/rel
    if src.exists():dest=OUT/'reports'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dest)
summary=json.loads((OUT.parent/'delivery-summary.json').read_text(encoding='utf-8'))
save('status.json',dict(build='20261025-R4',complete=False,physicalPhoneVerified=False,nativeDoesNotProvePhone=True,sourceFiles=len(entries),native50=summary['native50'],unit=summary['unit'],ui=summary['ui'],interaction=summary['interaction'],endgame=summary['endgame'],simulator=summary.get('simulator',{}),remaining=summary['outstanding']))
for name,src in [('package-audit.json',ROOT/'work/wechat-integration/package-audit.json'),('media-bridge-tests.json',ROOT/'work/wechat-integration/media-bridge-tests.json'),('wechat-build.log',ROOT/'work/wechat-integration/unity-wechat-build.log')]:
    if src.exists():shutil.copy2(src,OUT/name)
for folder in ['videos','wechat']:
    src=OUT.parent/folder
    if src.exists():shutil.copytree(src,OUT/folder,dirs_exist_ok=True)
print(json.dumps(dict(output=str(OUT),sourceFiles=len(entries),buildRoots=[x['root'] for x in builds]),ensure_ascii=False))
