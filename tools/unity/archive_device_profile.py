"""Freeze the R1 delivery evidence, not intermediate final-* experiments."""
import csv
import hashlib
import json
import re
import shutil
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'work/device-profile-20261024'
CANDIDATES = ROOT / 'source-assets/models/candidates/mobile-runtime-20261024'
OUT = ROOT / 'competitor-analysis/evidence/2026-10-24-iPhone持续卡顿与玩具对照'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')


def copy(source, target):
    assert source.is_file(), source
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    snapshots = []
    for directory in ['Assets/Scripts', 'Assets/Editor', 'Assets/Tests/Editor', 'Assets/Resources/Data', 'Assets/Resources/Shaders']:
        for source in (ROOT / 'projects/catch-big-goose-unity' / directory).rglob('*'):
            if not source.is_file() or source.suffix not in {'.cs', '.json', '.shader'}:
                continue
            rel = source.relative_to(ROOT / 'projects/catch-big-goose-unity')
            target = OUT / 'delivery-sources' / rel
            copy(source, target)
            snapshots.append(dict(current=str(source.relative_to(ROOT)).replace('\\', '/'), snapshot=str(target.relative_to(OUT)).replace('\\', '/'), sha256=sha(source)))
    source = ROOT / 'projects/catch-big-goose-unity/Assets/Resources/GooseItemMobile.shader'
    target = OUT / 'delivery-sources/Assets/Resources/GooseItemMobile.shader'
    copy(source, target)
    snapshots.append(dict(current=str(source.relative_to(ROOT)).replace('\\', '/'), snapshot=str(target.relative_to(OUT)).replace('\\', '/'), sha256=sha(source)))
    save(OUT / 'source-map.json', snapshots)
    for name in ['baseline-assets.json', 'asset-audit.json', 'competitor-iphone-screenshot.png', 'competitor-time-physics.json',
                 'mobile-batch.json', 'model-staging.json', 'edit-tests.xml', 'edit-tests.log', 'delivery-build.log',
                 'delivery-render.log', 'delivery-experience.log', 'delivery-reference.log', 'delivery-algorithm.log', 'delivery-interaction.log']:
        copy(WORK / name, OUT / name)
    for folder in ['baseline-sources', 'baseline-render', 'delivery-render', 'delivery-experience', 'delivery-reference', 'delivery-algorithm', 'delivery-interaction']:
        for source in (WORK / folder).rglob('*'):
            if source.is_file():
                copy(source, OUT / folder / source.relative_to(WORK / folder))
    copy(ROOT / 'work/interaction-20261024/competitor-main/j43536.annotated.wat', OUT / 'competitor-GetObjSize.wat')
    for name in ['batch-results.json', 'validation.json', 'visual-render.json']:
        copy(CANDIDATES / name, OUT / 'candidates' / name)
    for name in ['package-audit.json', 'font-subset.json', 'unity-wechat-build.log', 'devtools-open.log']:
        copy(ROOT / 'work/wechat-integration' / name, OUT / 'wechat' / name)
    package = ROOT / 'builds/catch-big-goose-wechat'
    for name in ['game.js', 'game.json', 'project.config.json', 'check-version.js']:
        copy(package / name, OUT / 'wechat' / name)
    package_files = [dict(path=str(p.relative_to(package)).replace('\\', '/'), bytes=p.stat().st_size, sha256=sha(p))
                     for p in sorted(package.rglob('*')) if p.is_file() and p.suffix != '.meta']
    save(OUT / 'wechat/exported-files.json', package_files)
    runtime_files = []
    for directory in ['Models', 'Physics', 'ContainerPhysics', 'Icons']:
        base = ROOT / 'projects/catch-big-goose-unity/Assets/Resources' / directory
        for p in sorted(base.rglob('*')):
            if p.is_file() and p.suffix != '.meta':
                runtime_files.append(dict(path=str(p.relative_to(ROOT)).replace('\\', '/'), bytes=p.stat().st_size, sha256=sha(p)))
    save(OUT / 'runtime-resource-files.json', runtime_files)

    metrics = read(CANDIDATES / 'batch-results.json')
    scales = {x['id']: x['scale'] for x in read(ROOT / 'projects/catch-big-goose-unity/Assets/Resources/Data/item-presentation.json')['items']}
    csv_rows, source_files = [], []
    for row in metrics:
        model_id = row['id']
        current = CANDIDATES / model_id
        copy(current / 'metrics.json', OUT / 'candidates' / model_id / 'metrics.json')
        for name in ['three-quarter.png', 'icon-64.png']:
            copy(current / name, OUT / 'candidates' / model_id / name)
        for p in current.iterdir():
            if p.is_file():
                source_files.append(dict(path=str(p.relative_to(ROOT)).replace('\\', '/'), sha256=sha(p)))
        csv_rows.append(dict(id=model_id, reference=row.get('reference', False), source=row['source'],
                             sourceTriangles=row['sourceTriangles'], triangles=row['triangles'], materials=row['materials'],
                             relativeScale=scales.get(model_id, 1), pipelineVersion=row['pipelineVersion']))
    save(OUT / 'candidate-file-hashes.json', source_files)
    with (OUT / 'model-budget.csv').open('w', encoding='utf-8-sig', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=list(csv_rows[0])); writer.writeheader(); writer.writerows(csv_rows)
    # Original input integrity is recorded independently of the runtime conversions.
    inputs = []
    for base in [ROOT / 'projects/catch-big-goose-unity/SourceAssets/MobileBaseline-20261024', ROOT / 'reference-projects/competitor-goose/2026-10-23']:
        for p in sorted(base.rglob('*')):
            if p.is_file():
                inputs.append(dict(path=str(p.relative_to(ROOT)).replace('\\', '/'), sha256=sha(p)))
    save(OUT / 'original-input-hashes.json', inputs)

    sys.path.insert(0, 'C:/Users/123/.codex/visualizations/2026/10/21/01a15f1e-af66-7022-bd6a-105254709b3b/competitor-goose/deps')
    from PIL import Image, ImageDraw
    toys = [x for x in metrics if x.get('reference')]
    sheet = Image.new('RGB', (7*192, 3*222), '#eeeeee'); draw = ImageDraw.Draw(sheet)
    for i, row in enumerate(toys):
        image = Image.open(CANDIDATES / row['id'] / 'three-quarter.png').convert('RGB').resize((192, 192))
        x, y = (i%7)*192, (i//7)*222; sheet.paste(image, (x,y))
        draw.text((x+4,y+194), row['id'].removeprefix('ref_gt'), fill='black')
        draw.text((x+4,y+208), f"{row['triangles']} tris / x{scales[row['id']]:.2f}", fill='black')
    sheet.save(OUT / 'toy-contact-sheet.jpg', quality=90)
    lines = ['# 21A · 移动模型与玩具资源清单', '', '本表由实际候选 metrics 与运行尺寸配置生成。来源为提取资源或归档自有 FBX；参考尺寸倍率是项目适配，非竞品实际运行参数。',
             '', '普通物件单网格／单材质且 ≤4,000 三角形；静态容器的渲染面数单列，不套用该预算。全部 60 件的机器表见 [model-budget.csv](../../competitor-analysis/evidence/2026-10-24-iPhone持续卡顿与玩具对照/model-budget.csv)。',
             '', '## 21 件竞品静态玩具', '', '| Unity ID | 原三角形 | 当前三角形 | 尺寸倍率 | 来源 |', '| --- | ---: | ---: | ---: | --- |']
    for row in csv_rows:
        if not row['reference']: continue
        src = Path(row['source']).relative_to(ROOT).as_posix()
        lines.append(f"| {row['id']} | {row['sourceTriangles']:,} | {row['triangles']:,} | {row['relativeScale']:.2f} | [{Path(src).stem}](../../{src}) |")
    lines += ['', '![21 件参考玩具的候选四分之三视角](../../competitor-analysis/evidence/2026-10-24-iPhone持续卡顿与玩具对照/toy-contact-sheet.jpg)',
              '', '## 自有候选转换', '', '| ID | 原 Blender 三角形 | 当前三角形 |', '| --- | ---: | ---: |']
    for row in csv_rows:
        if not row['reference']: lines.append(f"| {row['id']} | {row['sourceTriangles']:,} | {row['triangles']:,} |")
    lines += ['', 'Blender 源三角形与 Unity 导入审计可能因退化面剔除等略有差异（例如玉玺 19,904／19,528）；前后成本比较以第 21 章 Unity 实际导入值为准。未进入本表的简单自有物件继续使用原模型；不能误称只剩 60 件运行资源。',
              '', '四视图／GLB 回读／图标位于 `source-assets/models/candidates/mobile-runtime-20261024/<id>/`；源哈希、候选哈希、运行资源哈希均单独归档。当前仅为明确请求的本地对照关接入，原提取目录未被替换。']
    (ROOT / 'docs/development-reports/21A-移动模型与玩具资源清单.md').write_text('\n'.join(lines)+'\n', encoding='utf-8')

    tests = ET.parse(WORK / 'edit-tests.xml').getroot().attrib
    algorithm = read(WORK / 'delivery-algorithm/algorithm-acceptance.json')
    interaction = read(WORK / 'delivery-interaction/interaction.json')
    experience = read(WORK / 'delivery-experience/experience.json')
    reference = read(WORK / 'delivery-reference/experience.json')
    render = read(WORK / 'delivery-render/device-benchmark.json')
    validation = read(CANDIDATES / 'validation.json')
    audit = read(OUT / 'wechat/package-audit.json')
    passed = all([tests['result']=='Passed', algorithm['passed'], interaction['passed'], experience['passed'], reference['passed'], render['passed'], validation['passed'], audit['localPackagePassed']])
    assert passed and len(experience['rounds'])==15 and len(reference['rounds'])==2
    summary = dict(build='20261024-R1', passed=passed, phone='iPhone 15 Pro', iPhoneAcceptancePassed=None,
                   scope='Native forced-mobile structural/functional acceptance and local WeChat export. No connected phone measurement.',
                   editTests=int(tests['passed']), algorithmChecks=len(algorithm['checks']), interactionChecks=len(interaction['checks']),
                   ownRounds=len(experience['rounds']), referenceRounds=len(reference['rounds']), structuralRows=len(render['rows']),
                   candidateModels=len(validation['models']), fourViewModels=len(read(CANDIDATES/'visual-render.json')),
                   devtoolsAutoOpenPassed=False, devtoolsError='TypeError: d.on is not a function (code 10)', newPreviewQrGenerated=False,
                   wechatRawBytes=audit['rawBytes'], wechatRawMiB=audit['rawMiB'], javascriptFiles=audit['javascriptFiles'],
                   currentGameJs=re.findall(r'(?:DATA|CODE)_FILE_MD5:.*', (package/'game.js').read_text(encoding='utf-8-sig')),
                   baseline=read(WORK/'baseline-assets.json')['rounds'], delivery=read(WORK/'asset-audit.json')['rounds'],
                   rejected=['optimized-render-1','final-render','final-sources'], currentArtifacts='delivery-* only',
                   nativePlayerSha256=sha(ROOT/'projects/catch-big-goose-unity/Builds/DeviceOptimized/CatchGoose.exe'))
    save(OUT / '验证汇总.json', summary)
    # Freeze docs and tooling too; stable filenames make re-running idempotent.
    for source in (ROOT/'tools/unity').glob('*.py'):
        if any(term in source.name for term in ['mobile', 'material_atlas', 'device_profile', 'wechat-package']):
            copy(source, OUT/'tools'/source.name)
    for source in [ROOT/'tools/unity/validate_mobile_candidates.mjs', ROOT/'tools/competitor/read_time_settings.py',
                   ROOT/'docs/development-reports/21-iPhone持续卡顿与玩具对照.md', ROOT/'docs/development-reports/21A-移动模型与玩具资源清单.md',
                   ROOT/'projects/catch-big-goose-unity/README.md', ROOT/'projects/catch-big-goose-unity/WECHAT.md']:
        copy(source, OUT/'documents-and-tools'/source.name)
    manifest = [dict(path=str(p.relative_to(OUT)).replace('\\','/'), bytes=p.stat().st_size, sha256=sha(p))
                for p in sorted(OUT.rglob('*')) if p.is_file() and p.name != '文件校验.json']
    save(OUT/'文件校验.json', manifest)
    print(json.dumps(dict(passed=passed, archivedFiles=len(manifest), sourceFiles=len(snapshots), output=str(OUT)), ensure_ascii=False))


if __name__ == '__main__':
    main()
