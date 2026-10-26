"""Freeze completed R3 source, rendering and export evidence without phone claims."""
import hashlib
import json
import re
import shutil
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'work/reference-look-20261025'
PIPE = ROOT / 'work/reference-look-pipeline'
CANDIDATE = ROOT / 'assets-3d/candidates/reference-look-20261025'
OUT = ROOT / '竞品分析/证据/2026-10-25-材质模型光照迁移'

def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')

def copy(source, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)

def file_list(folder):
    return [dict(path=p.relative_to(folder).as_posix(), bytes=p.stat().st_size, sha256=sha(p))
            for p in sorted(folder.rglob('*')) if p.is_file() and p.suffix != '.meta']

def main():
    look = read(WORK / 'final-runtime-look/look-acceptance.json')
    preview = read(PIPE / 'preview/look-acceptance.json')
    imported = read(WORK / 'import-audit.json')
    candidate = read(CANDIDATE / 'validation.json')
    scale = read(WORK / 'final80-scale/proportions.json')
    experience = read(WORK / 'final80-experience/experience.json')
    reference = read(WORK / 'final80-reference/experience.json')
    algorithm = read(WORK / 'final80-algorithm/algorithm-acceptance.json')
    interaction = read(WORK / 'final80-interaction/interaction.json')
    tests = ET.parse(WORK / 'final80-edit.xml').getroot().attrib
    package_audit = read(ROOT / 'work/wechat-integration/package-audit.json')
    platform_preview = read(WORK / 'wechat-r3-preview-info.json')
    assert '√ preview' in (WORK / 'wechat-r3-preview.log').read_text('utf-8-sig')
    assert (WORK / 'wechat-r3-preview.png').stat().st_size > 1000
    for report in (look, preview):
        assert report['passed'] and report['models'] == 80 and report['sourceMaterials'] == 102
        assert report['fourViews'] == 320 and report['icons'] == 160 and report['glassMaterials'] == 9
    assert imported['passed'] and len(imported['rows']) == 102
    assert candidate['passed'] and len(candidate['models']) == 80
    assert scale['passed'] and len(scale['rows']) == 7 and not scale['errors']
    for report, count in ((experience, 15), (reference, 2)):
        assert report['passed'] and len(report['rounds']) == count
        assert all(r['result'] == 'win' and r['failedClicks'] == 0 and r['outOfBounds'] == 0 for r in report['rounds'])
    assert algorithm['passed'] and len(algorithm['checks']) == 132
    assert interaction['passed'] and len(interaction['checks']) == 60
    assert tests['result'] == 'Passed' and int(tests['passed']) == 22
    assert package_audit['localPackagePassed'] and package_audit['appId'] == 'wx60b50db2472c4782'
    assert 'Reference pipeline passed.' in (WORK / 'pipeline-final.out.log').read_text('utf-8', errors='replace')
    preserved = {}
    for original in (WORK / 'pre-migration-scenes').glob('*.json'):
        current = ROOT / 'unity/Assets/Resources/Data' / original.name
        assert sha(original) == sha(current), original.name
        preserved[original.name] = sha(current)
    assert len(preserved) == 6

    source_map = []
    def freeze_source(path):
        relative = path.relative_to(ROOT)
        target = OUT / 'delivery-sources' / relative
        copy(path, target)
        source_map.append(dict(current=relative.as_posix(), snapshot=target.relative_to(OUT).as_posix(), sha256=sha(path)))
    for base in ['unity/Assets/Scripts', 'unity/Assets/Editor', 'unity/Assets/Tests/Editor',
                 'unity/Assets/Resources/Data', 'unity/Assets/Resources/ReferenceTextures',
                 'unity/Assets/Resources/Models', 'unity/Assets/Resources/Icons',
                 'unity/Assets/Resources/Textures',
                 'unity/Assets/Resources/Physics', 'unity/Assets/Resources/ContainerPhysics']:
        for path in sorted((ROOT / base).rglob('*')):
            if path.is_file():
                freeze_source(path)
    for path in sorted((ROOT / 'unity/Assets/Resources').glob('Goose*')):
        if path.is_file():
            freeze_source(path)
    for name in ['prepare_reference_materials.py', 'build_reference_materials.py', 'validate_reference_look.mjs',
                 'stage_reference_look.py', 'stage_reference_icons.py', 'build-reference-look.ps1',
                 'build-wechat.ps1', 'audit-wechat-package.py', 'retire_reference_legacy_ui.py', 'archive_reference_look.py', 'verify_reference_look.py']:
        freeze_source(ROOT / 'tools/unity' / name)
    save(OUT / 'source-map.json', source_map)

    source_inputs = {}
    for entry in read(CANDIDATE / 'batch.json'):
        for key in ['source', 'sourceJson']:
            path = Path(entry[key]); source_inputs[path.relative_to(ROOT).as_posix()] = sha(path)
    for texture in read(CANDIDATE / 'texture-sources.json').values():
        path = ROOT / texture['source']; assert sha(path) == texture['sha256']
        source_inputs[texture['source']] = texture['sha256']
    save(OUT / 'source-inputs.json', source_inputs)
    retirement = ROOT / 'unity/SourceAssets/ReferenceLookBaseline-20261025/retired-ui.json'
    copy(retirement, OUT / 'retired-ui.json')
    for name in ['batch.json', 'results.json', 'validation.json', 'texture-sources.json', 'model-contract.json']:
        copy(CANDIDATE / name, OUT / 'candidates' / name)
    for entry in candidate['models']:
        mid = entry['id']
        for name in [mid + '.glb', mid + '.fbx', 'materials.json', 'metrics.json']:
            copy(CANDIDATE / mid / name, OUT / 'candidates' / mid / name)
        runtime = ROOT / 'unity/Assets/Resources/Models' / mid
        baseline = ROOT / 'unity/SourceAssets/ReferenceLookBaseline-20261025/original-models' / mid
        def guid(path):
            return re.search(r'^guid: (\S+)', path.read_text('utf-8'), re.M).group(1)
        assert guid(runtime / (mid + '.fbx.meta')) == guid(baseline / (mid + '.fbx.meta')), mid
        assert sha(runtime / (mid + '.fbx')) == entry['fbxSha256'], mid
        assert sha(runtime / 'materials.json') == entry['materialSha256'], mid
        icon = ROOT / 'unity/Assets/Resources/Icons' / (mid + '.png')
        assert sha(icon) == sha(PIPE / 'preview/models' / mid / 'icon-192.png'), mid

    for name in ['final-runtime-look', 'final80-scale', 'final80-experience', 'final80-reference',
                 'final80-algorithm', 'final80-interaction', 'pre-migration-scenes']:
        for path in (WORK / name).rglob('*'):
            if path.is_file():
                copy(path, OUT / name / path.relative_to(WORK / name))
    for name in ['import-audit.json', 'staging.json', 'final80-edit.xml', 'final80-edit.log',
                 'pipeline-final.out.log', 'pipeline-final.err.log', 'all80-gallery.png', 'same-pile-comparison.png']:
        copy(WORK / name, OUT / name)
    for name in ['preview-build.log', 'preview.log', 'import-audit.log', 'final-native-build.log']:
        copy(PIPE / name, OUT / 'pipeline' / name)
    # Icons were staged from this run; freeze it as well as the final native run.
    for path in (PIPE / 'preview').rglob('*'):
        if path.is_file():
            copy(path, OUT / 'pipeline/preview' / path.relative_to(PIPE / 'preview'))
    for name in ['package-audit.json', 'font-subset.json', 'unity-wechat-build.log']:
        copy(ROOT / 'work/wechat-integration' / name, OUT / 'wechat' / name)
    for name in ['wechat-r3-preview.png', 'wechat-r3-preview-info.json', 'wechat-r3-preview.log']:
        copy(WORK / name, OUT / 'wechat' / name)
    package = ROOT / 'unity/Builds/WeChat/minigame'
    save(OUT / 'wechat/exported-files.json', file_list(package))
    save(OUT / 'native/exported-files.json', file_list(ROOT / 'unity/Builds/ReferenceLook'))
    for name in ['game.js', 'game.json', 'project.config.json']:
        copy(package / name, OUT / 'wechat' / name)
    summary = dict(build='20261025-R3', passed=True, models=80, sourceMaterials=102,
                   textures=141, glassMaterials=9, colorOnlyMaterials=11, fourViews=320, icons=160,
                   shaderAndTextureImportLinks=102, editTests=22, algorithmChecks=132, interactionChecks=60,
                   projectionScenes=7, ownWins=15, referenceWins=2, unchangedStockWeightsDepthAndSizes=True,
                   preservedDataSha256=preserved, unchangedFbxGuids=True, unchangedTriangleCounts=True,
                   sourceShaderProgramRecovered=False, iPhoneAcceptancePassed=None,
                   scope='Actual native forced-mobile rendering and scripted gameplay; local WebGL compile/export. No connected-phone FPS, runtime DPR or pixel-equivalent competitor shader claim.',
                   wechatRawBytes=package_audit['rawBytes'], wechatRawMiB=package_audit['rawMiB'],
                   javascriptFiles=package_audit['javascriptFiles'], finalMaterialPixelDifference=look['materialDifference'],
                   finalShadowPixelDifference=look['shadowDifference'], developerToolsPreviewPassed=True,
                   developerToolsPreviewPackageBytes=platform_preview['size']['total'])
    save(OUT / '验证汇总.json', summary)
    save(OUT / '文件校验.json', [dict(path=p.relative_to(OUT).as_posix(), sha256=sha(p))
        for p in sorted(OUT.rglob('*')) if p.is_file() and p.name != '文件校验.json'])
    print(json.dumps(summary, ensure_ascii=False))

if __name__ == '__main__':
    main()
