"""Archive this round without altering previous evidence or personal storage."""
import datetime
import hashlib
import json
import shutil
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'competitor-analysis/artifacts/competitor-runtime-trace'
DEST=ROOT/'competitor-analysis/evidence/2026-10-24-核心单局与运行配置'
REF=ROOT/'reference-projects/competitor-goose/2026-10-23-skinned'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text('utf-8-sig'))
def dump(p,data):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(data,ensure_ascii=False,indent=2),'utf-8')
def copy(p,target):
    dst=DEST/target;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)

def main():
    for module in ['primary','secondary']:
        folder=WORK/f'{module}-methods'
        for p in folder.iterdir():
            if p.is_file() and p.suffix in ['.json','.wat','.watfrag','.wasm']:
                copy(p,Path('方法')/module/p.name)
    for name in ['constant-table-call-edges.json','patch-slot-identification.json','bundled-server-config.json',
                 'GetHotFixData-sret.watfrag','core-configuration-audit.json','tray-transform-evidence.json']:
        copy(WORK/name,Path('追踪')/name)
    for p in (WORK/'public-config').iterdir():
        if p.is_file():copy(p,Path('公开配置')/p.name)
    for name in ['ABTestData','GameToolData']:
        for suffix in ['.json','-schema.json']:
            copy(ROOT/'competitor-analysis/artifacts/competitor-config-trace/serialized-verified'/(name+suffix),Path('包内配置')/(name+suffix))
    for name in ['HotFixScriptable-810.json','HotFixScriptable-810.bin','index.json']:
        copy(WORK/'runtime-objects'/name,Path('包内配置')/name)
    tests=WORK/'tests'
    runtime=read(tests/'algorithm-acceptance.json')
    if not runtime['passed']:raise RuntimeError('Latest runtime acceptance failed')
    hashes=read(tests/'tested-source-hashes.json')
    for name,value in hashes.items():
        if sha(ROOT/'projects/catch-big-goose-unity/Assets/Scripts'/name)!=value:raise RuntimeError('Changed since tested build: '+name)
    for p in (tests/'tested-runtime-sources').iterdir():
        copy(p,Path('测试源码快照')/p.name)
    for name in ['pile-algorithms.json','level-tuning.json','core-rounds.json']:
        if sha(ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data'/name)!=sha(tests/'tested-runtime-sources'/name):
            raise RuntimeError('Configuration changed since build: '+name)
    for p in tests.iterdir():
        if p.is_file() and p.suffix in ['.json','.xml','.csv','.wasm','.log']:
            copy(p,Path('验证')/p.name)
    visual=WORK/'visual'
    if (visual/'algorithm-acceptance.json').exists():
        v=read(visual/'algorithm-acceptance.json')
        if not v['passed']:raise RuntimeError('Visual run failed')
        for p in visual.iterdir():
            if p.suffix in ['.json','.png','.log']:copy(p,Path('画面')/p.name)
        for name in ['algorithm-acceptance.json','core-2.png','visual-player.log']:
            copy(visual/'hidden-window-black'/name,Path('画面/无效隐藏窗口截图')/name)
    for p in (ROOT/'tools/competitor').iterdir():
        if p.suffix in ['.py','.mjs','.ps1']:copy(p,Path('复现/tools/competitor')/p.name)
    for name in ['tests/competitor/PolicyTests.cs','projects/catch-big-goose-unity/Assets/Tests/Editor/GooseCoreRoundTests.cs',
                 'projects/catch-big-goose-unity/Assets/Editor/GooseAlgorithmBuild.cs']:
        copy(ROOT/name,Path('复现')/name)
    edit=ET.parse(tests/'unity-editmode-results.xml').getroot()
    if edit.attrib['failed']!='0':raise RuntimeError('Editor tests failed')
    modules=[]
    for name in ['primary','secondary']:
        entries=read(WORK/f'{name}-methods/method-map.json')
        modules.append(dict(module=name,mappedEntries=len(entries),uniqueBodies=len({e['wasmSymbol'] for e in entries})))
    snapshot=ROOT/'competitor-analysis/artifacts/competitor-config-trace/source/6f7a2014e3c0092b.webgl.data.unityweb.bin'
    summary=dict(archivedAtUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(),packageVersion='402',
        snapshotSha256=sha(snapshot),moduleCoverage=modules,
        constantTableCallSites=len(read(WORK/'constant-table-call-edges.json')),
        publicConfig=read(WORK/'public-config/comparison.json'),coreConfig=read(WORK/'core-configuration-audit.json'),
        originalRuntimeConfigProbe=read(tests/'runtime-config-probe.json'),productionPolicy=read(tests/'policy-tests.json'),
        unityEditMode=dict(passed=int(edit.attrib['passed']),failed=int(edit.attrib['failed']),endTime=edit.attrib['end-time']),
        unityRuntime=dict(passed=runtime['passed'],checks=len(runtime['checks']),errors=runtime['errors']),
        unityVisual=dict(checks=len(read(visual/'algorithm-acceptance.json')['checks']),review=read(visual/'visual-review.json')),
        runtimeSources=hashes,referenceModels=len(read(REF/'manifest.json')['models']),
        referenceExport=read(REF/'export-verification.json')['passed'],referenceGltf=read(REF/'gltf-validation.json')['passed'],
        exclusions=['Personal MMKV and logs are not archived',
            'Public CDN values are not proof of account assignments or loaded runtime state',
            'Source heights, asset count caps, RNG, collision placement and UI feedback remain project adaptations',
            'Headless acceptance is not equivalent to mobile performance or user difficulty measurements',
            'Reference GLBs are static prefab pose bakes without playable animation'])
    dump(DEST/'验证汇总.json',summary)
    for folder in [REF,DEST]:
        integrity=[dict(path=p.relative_to(folder).as_posix(),bytes=p.stat().st_size,sha256=sha(p))
                   for p in sorted(folder.rglob('*')) if p.is_file() and p.name!='文件校验.json']
        dump(folder/'文件校验.json',integrity)
    print(json.dumps(dict(archivedFiles=len(integrity),runtimeChecks=len(runtime['checks']),sourceFiles=len(hashes))))

if __name__=='__main__':main()
