"""Freeze read-only appearance findings without changing the R2 runtime."""
import hashlib,json,re,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'work/appearance-analysis-20261025'
OUT=ROOT/'competitor-analysis/evidence/2026-10-25-清晰度光照与材质'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(p,q):q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
def save(p,x):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
for p in WORK.rglob('*'):
    if p.is_file():copy(p,OUT/'audit'/p.relative_to(WORK))
sources=['projects/catch-big-goose-unity/Assets/Resources/GooseItemMobile.shader','projects/catch-big-goose-unity/Assets/Scripts/GooseAssetCache.cs','projects/catch-big-goose-unity/Assets/Scripts/GooseRuntimePerformance.cs',
         'projects/catch-big-goose-unity/Assets/Scripts/GooseGame.cs','projects/catch-big-goose-unity/Assets/Editor/GooseAssetImporter.cs','projects/catch-big-goose-unity/Assets/Editor/GooseWeChatBuild.cs','projects/catch-big-goose-unity/Assets/Editor/GooseProjectSetup.cs',
         'projects/catch-big-goose-unity/ProjectSettings/QualitySettings.asset','builds/catch-big-goose-wechat/check-version.js',
         'tools/unity/build_material_atlas.py','tools/unity/bake_mobile_models.py',
         'reference-projects/competitor-goose/2026-10-23/models/GTCrocodile/source.json','reference-projects/competitor-goose/2026-10-23/models/GTWaterGame/source.json',
         'tools/competitor/audit_render_appearance.py','tools/competitor/archive_appearance.py']
source_map=[]
for name in sources:
    p=ROOT/name;q=OUT/'sources'/name;copy(p,q);source_map.append(dict(current=name,snapshot=q.relative_to(OUT).as_posix(),sha256=sha(p)))
save(OUT/'source-map.json',source_map)
copy(ROOT/'reference-projects/competitor-goose/2026-10-23/models/GTCrocodile/tex_1218480915622659578.png',OUT/'competitor-crocodile-matcap.png')
copy(ROOT/'work/scale-alignment-20261024/competitor-reference.png',OUT/'competitor-user-screenshot.png')
copy(ROOT/'work/scale-alignment-20261024/render-563/farm-300.png',OUT/'R2-farm-300.png')
copy(ROOT/'work/scale-alignment-20261024/render-563/reference_toys-126.png',OUT/'R2-reference-toys-126.png')
copy(ROOT/'competitor-analysis/artifacts/competitor-package-analysis/__WITHOUT_MULTI_PLUGINCODE__/15-game.js',OUT/'competitor-401-startup.js')
doc=ROOT/'docs/development-reports/23-清晰度光照与材质差距.md';copy(doc,OUT/'23-清晰度光照与材质差距.md')
summary=json.loads((WORK/'summary.json').read_text('utf-8'))
summary.update(analysisDate='2026-10-25',runtimeBuild='20261024-R2',productionRenderingChanged=False,iPhoneMeasured=False,
               shaderFormulaFullyRecovered=False,shaderReadErrors=len(json.loads((WORK/'shader-export-errors.json').read_text('utf-8'))),
               atlasModels=len(json.loads((WORK/'current-atlas-audit.json').read_text('utf-8'))),
               currentIOSDevicePixelRatio=1.5,currentMobileAA=0,currentMobileShadows=False,
               currentShaderFeatures=['base texture','tint','vertex diffuse','fixed fill','alpha forced to one'],
               scope='Read-only material/light/atlas/source and export audit. Stored settings are not competitor runtime values. No phone capture or rendering correction claimed.')
save(OUT/'验证汇总.json',summary)
manifest=[dict(path=p.relative_to(OUT).as_posix(),sha256=sha(p),bytes=p.stat().st_size) for p in sorted(OUT.rglob('*')) if p.is_file() and p.name!='文件校验.json']
save(OUT/'文件校验.json',manifest)
errors=[]
for x in manifest:
    if sha(OUT/x['path'])!=x['sha256']:errors.append(x['path'])
for x in source_map:
    if sha(ROOT/x['current'])!=x['sha256']:errors.append(x['current'])
for link in re.findall(r'\]\(([^)]+)\)',doc.read_text('utf-8')):
    if not link.startswith(('http:','https:','#')) and not (doc.parent/link.split('#')[0]).exists():errors.append('doc link: '+link)
print(json.dumps(dict(archiveVerified=not errors,files=len(manifest),materials=summary['materials'],toySampleMaterials=summary['toySampleMaterials'],atlasModels=summary['atlasModels'],errors=errors),ensure_ascii=False))
if errors:raise SystemExit(1)
