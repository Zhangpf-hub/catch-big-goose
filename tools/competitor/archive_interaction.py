"""Freeze interaction evidence only after complete production-path acceptance."""
import hashlib
import json
import re
import shutil
import statistics
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'work/interaction-20261024'
ANALYSIS = ROOT / 'competitor-analysis'
DEST = ANALYSIS / 'evidence/2026-10-24-拾取与逐层出场'


def analysis_document(name):
    """Resolve current project reports separately from competitor research."""
    report = ROOT / 'docs/development-reports' / name
    return report if report.exists() else ROOT / 'competitor-analysis' / name

def read(p): return json.loads(p.read_text('utf-8-sig'))
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')
def copy(src, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    if src.is_dir(): shutil.copytree(src, target, dirs_exist_ok=True, ignore=shutil.ignore_patterns('__pycache__'))
    else: shutil.copy2(src, target)

def main():
    interaction = read(WORK/'visual-final/interaction.json')
    algorithm = read(WORK/'algorithm-final/algorithm-acceptance.json')
    experience = read(WORK/'experience-final/experience.json')
    performance = read(WORK/'performance-isolated/performance.json')
    package = read(ROOT/'work/wechat-integration/package-audit.json')
    tests = ET.parse(WORK/'edit-tests.xml').getroot()
    assert all(r['passed'] for r in [interaction, algorithm, experience, performance])
    assert len(experience['rounds']) == 20 and all(r['result']=='win' for r in experience['rounds'])
    assert len(performance['samples']) == 10 and package['localPackagePassed']
    assert tests.attrib['result'] == 'Passed'
    # The independent player builder recorded hashes of the core runtime sources.
    for line in (ROOT/'projects/catch-big-goose-unity/Builds/PerformanceQA/source-hashes.tsv').read_text('utf-8-sig').splitlines():
        name, digest = line.split('\t')
        assert sha(ROOT/'projects/catch-big-goose-unity/Assets/Scripts'/name) == digest, name
    for folder in ['competitor-main','competitor-secondary','competitor-dispatch','competitor-pick-chain',
                   'competitor-pick-chain-secondary','competitor-vector3-abi','serialized','visual-final',
                   'algorithm-final','experience-final','performance-isolated']:
        copy(WORK/folder, DEST/folder)
    for name in ['build-3.log','interaction-final.log','algorithm-final.log','experience-final.log',
                 'performance-isolated.log','edit-tests.xml','edit-tests.log']:
        copy(WORK/name, DEST/name)
    for folder in ['visual','visual-2','performance']:
        copy(WORK/folder, DEST/'中间验证'/folder)
    for name in ['interaction.log','interaction-2.log','performance.log','build.log','build-2.log']:
        copy(WORK/name, DEST/'中间验证'/name)
    copy(ROOT/'work/wechat-integration/package-audit.json',DEST/'微信/package-audit.json')
    copy(ROOT/'work/wechat-integration/unity-wechat-build.log',DEST/'微信/build.log')
    copy(ROOT/'builds/catch-big-goose-wechat/game.js',DEST/'微信/game.js')
    copy(ROOT/'projects/catch-big-goose-unity/Builds/PerformanceQA/source-hashes.tsv',DEST/'构建/core-source-hashes.tsv')
    for src in (ROOT/'projects/catch-big-goose-unity/Assets/Scripts').glob('*.cs'): copy(src,DEST/'源码/Scripts'/src.name)
    for src in (ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data').glob('*.json'): copy(src,DEST/'源码/Data'/src.name)
    for name in ['recover_methods.py','trace_interaction_assets.py','archive_interaction.py','verify_interaction.py']:
        copy(ROOT/'tools/competitor'/name,DEST/'工具'/name)
    copy(ROOT/'competitor-analysis/artifacts/competitor-config-trace/serialized-verified/LevelManager.json',DEST/'serialized/LevelManager.json')
    samples = performance['samples']
    summary = {
        'date':'2026-10-24', 'scope':'Frozen competitor 402 static bodies/resources; own Unity runtime tests and local Release export',
        'interactionChecks':len(interaction['checks']), 'algorithmChecks':len(algorithm['checks']),
        'editMode':dict(tests.attrib), 'experienceRounds':len(experience['rounds']),
        'experienceWins':sum(r['result']=='win' for r in experience['rounds']),
        'failedClicks':sum(r['failedClicks'] for r in experience['rounds']),
        'outOfBounds':sum(r['outOfBounds'] for r in experience['rounds']),
        'performanceScope':'Windows headless, forced mobile profile, isolated from other QA players/builds; not phone FPS',
        'performanceSamples':len(samples),
        'coldSpawnSecondsMean':statistics.mean(s['spawnSeconds'] for s in samples if not s['warm']),
        'warmSpawnSecondsMean':statistics.mean(s['spawnSeconds'] for s in samples if s['warm']),
        'largestFrameMs':max(s['frameMaxMs'] for s in samples),
        'package':package,
        'intermediateEvidence':'visual first run failed layer order and pause; corrected second run passed; final adds hidden settling and exact weighted timing. Concurrent performance retained, excluded from isolated timing.',
        'wechatDeveloperToolsRuntimePassed':None, 'phonePerformancePassed':None,
    }
    gamejs=(ROOT/'builds/catch-big-goose-wechat/game.js').read_text('utf-8')
    summary['wechatHashes']=dict(re.findall(r"(CODE_FILE_MD5|DATA_FILE_MD5):\s*'([^']+)'",gamejs))
    summary['frozenInputHashes'] = {str(p.relative_to(ROOT)).replace('\\','/'):sha(p) for p in [
        ROOT/'competitor-analysis/artifacts/competitor-config-trace/main-402.wat', ROOT/'competitor-analysis/artifacts/competitor-config-trace/secondary-402.wat',
        ROOT/'competitor-analysis/artifacts/competitor-config-trace/dumper/script.json', ROOT/'competitor-analysis/artifacts/competitor-config-trace/dumper/dump.cs',
        ROOT/'competitor-analysis/artifacts/competitor-config-trace/source/6f7a2014e3c0092b.webgl.data.unityweb.bin']}
    write(DEST/'验证汇总.json',summary)
    chapter=ROOT / 'docs/development-reports/20-拾取入槽与逐层出场.md'
    content=chapter.read_text('utf-8')
    old='最终数值在归档时填写；进行中的部分样本不算整组通过。'
    text=(f'本轮 Unity 编辑测试 {tests.attrib["passed"]}/{tests.attrib["total"]}、交互验收 {len(interaction["checks"])} 项、'
          f'算法回归 {len(algorithm["checks"])} 项通过；生产动画路径的可见策略完整单局 {len(experience["rounds"])}/20 通关，'
          '失效点击和掉出库存均为 0。这是自有自动策略，不代表人工或竞品胜率。'
          f'微信 Release 本地包检查通过，原始文件总量 {package["rawMiB"]:.2f} MiB；模拟器和手机仍未验证。\n\n'
          f'另按五主题分别冷／重复开局完成 10 组独立桌面移动档采样，库存均为 300、掉出均为 0。'
          f'完整准备＋出场平均冷 {summary["coldSpawnSecondsMean"]:.2f} 秒、重复 {summary["warmSpawnSecondsMean"]:.2f} 秒；'
          f'最长采样帧 {summary["largestFrameMs"]:.2f} ms。该结果不是手机 FPS，也不能直接与并行构建时的数据比较。'
          '层序呈现与隐藏稳定使准备／出场等待增加，未把它计作加载提速。')
    if old in content: chapter.write_text(content.replace(old,text),encoding='utf-8')
    for name in ['README.md','15-三消单局核心算法与调优.md','17-微信进局性能与竞品优化.md',chapter.name]:
        copy(analysis_document(name),DEST/'文档'/name)
    paths=[p for p in DEST.rglob('*') if p.is_file() and p.name!='文件校验.json']
    write(DEST/'文件校验.json',{'algorithm':'SHA-256','files':[
        {'path':p.relative_to(DEST).as_posix(),'bytes':p.stat().st_size,'sha256':sha(p)} for p in sorted(paths)]})
    print(json.dumps({'files':len(paths),'summary':str(DEST/'验证汇总.json')},ensure_ascii=False))

if __name__=='__main__': main()
