"""Archive only completed R2 runs and verify stock/weight preservation."""
import hashlib,json,re,shutil,xml.etree.ElementTree as ET
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'work/scale-alignment-20261024'
OUT=ROOT/'竞品分析/证据/2026-10-24-场景物件比例修正'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):
    p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def copy(p,q):
    q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
def main():
    render={key:read(WORK/key/'proportions.json') for key in ['render-563','render-393','render-short']}
    experience=read(WORK/'experience/experience.json');reference=read(WORK/'reference/experience.json')
    algorithm=read(WORK/'algorithm/algorithm-acceptance.json');interaction=read(WORK/'interaction/interaction.json')
    tests=ET.parse(WORK/'edit-tests-delivery.xml').getroot().attrib
    audit=read(ROOT/'work/wechat-integration/package-audit.json')
    assert all(x['passed'] and len(x['rows'])==7 and not x['errors'] for x in render.values())
    assert experience['passed'] and len(experience['rounds'])==15 and all(x['result']=='win' and x['failedClicks']==0 and x['outOfBounds']==0 for x in experience['rounds'])
    assert reference['passed'] and len(reference['rounds'])==2 and all(x['result']=='win' and x['failedClicks']==0 and x['outOfBounds']==0 for x in reference['rounds'])
    assert algorithm['passed'] and len(algorithm['checks'])==132 and interaction['passed'] and len(interaction['checks'])==60
    assert tests['result']=='Passed' and audit['localPackagePassed']
    before=WORK/'before-sources/Assets/Resources/Data';current=ROOT/'unity/Assets/Resources/Data'
    def non_shape(theme):return {k:v for k,v in theme.items() if k not in ['halfX','halfZ']}
    assert [non_shape(t) for t in read(before/'themes.json')['themes']]==[non_shape(t) for t in read(current/'themes.json')['themes']]
    same_files=['core-rounds.json','pile-algorithms.json','level-tuning.json','item-presentation.json','reference-lab.json']
    assert all(sha(before/name)==sha(current/name) for name in same_files)
    frozen_data={name:sha(current/name) for name in same_files}
    # Freeze current implementation with paths that can also be compared to the workspace.
    source_map=[]
    for base in ['Assets/Scripts','Assets/Editor','Assets/Tests/Editor','Assets/Resources/Data']:
        for p in (ROOT/'unity'/base).rglob('*'):
            if p.is_file() and p.suffix in ['.cs','.json']:
                q=OUT/'delivery-sources'/p.relative_to(ROOT/'unity');copy(p,q)
                source_map.append(dict(current=p.relative_to(ROOT).as_posix(),snapshot=q.relative_to(OUT).as_posix(),sha256=sha(p)))
    save(OUT/'source-map.json',source_map)
    for name in ['render-563','render-393','render-short','experience','reference','algorithm','interaction','before-sources']:
        for p in (WORK/name).rglob('*'):
            if p.is_file():copy(p,OUT/name/p.relative_to(WORK/name))
    for name in ['competitor-reference.png','competitor-camera-transforms.json','screenshot-measurements.json','build-delivery.log','edit-tests-delivery.xml','edit-tests-delivery.log',
                 'render-563.log','render-393.log','render-short.log','experience.log','reference.log','algorithm.log','interaction.log']:
        copy(WORK/name,OUT/name)
    # Keep rejected initial layout reports/photos separate from the final results.
    for p in (WORK/'iteration-1').rglob('*'):
        if p.is_file() and p.suffix in ['.json','.png','.log']:copy(p,OUT/'rejected-initial-layout'/p.relative_to(WORK/'iteration-1'))
    for name in ['package-audit.json','font-subset.json','unity-wechat-build.log']:
        copy(ROOT/'work/wechat-integration'/name,OUT/'wechat'/name)
    package=ROOT/'unity/Builds/WeChat/minigame'
    exports=[dict(path=p.relative_to(package).as_posix(),bytes=p.stat().st_size,sha256=sha(p)) for p in sorted(package.rglob('*')) if p.is_file() and p.suffix!='.meta']
    save(OUT/'wechat/exported-files.json',exports)
    for name in ['game.js','game.json','project.config.json']:
        copy(package/name,OUT/'wechat'/name)
    copy(ROOT/'work/interaction-20261024/competitor-main/j43536.annotated.wat',OUT/'competitor-GetObjSize.wat')
    summary=dict(build='20261024-R2',passed=True,iPhoneAcceptancePassed=None,scope='Completed native forced-mobile functional/projection tests and local export; not phone performance.',
                 editTests=int(tests['passed']),algorithmChecks=len(algorithm['checks']),interactionChecks=len(interaction['checks']),ownWins=len(experience['rounds']),referenceWins=len(reference['rounds']),
                 projectionScenes=sum(len(x['rows']) for x in render.values()),projectionSizes={k:[v['width'],v['height']] for k,v in render.items()},
                 unchangedStockAndWeights=True,unchangedDataSha256=frozen_data,wechatRawBytes=audit['rawBytes'],wechatRawMiB=audit['rawMiB'],javascriptFiles=audit['javascriptFiles'],
                 nativePlayerSha256=sha(ROOT/'unity/Builds/ScaleAligned/CatchGoose.exe'),
                 packageIds=re.findall(r'(?:DATA|CODE)_FILE_MD5:.*',(package/'game.js').read_text('utf-8-sig')))
    save(OUT/'验证汇总.json',summary)
    a,b=render['render-563']['rows'],render['render-393']['rows']
    section=['本轮最终结果：**21 项编辑测试、132 项算法、60 项交互通过；正式五主题 15/15 局及玩具 2/2 局通关，失败点击和落底越界均为 0。** 单局采用正常动画、可见射线候选和加速测试时间，仍不是人工胜率。',
             '', '三个实际窗口尺寸各 7 场，共 **21 场投影检查**通过；可见物件中心出视口为 0，初始物理越界为 0。初始检查不等于整局所有轮廓像素都不被彼此遮挡。',
             '', '| 场景 | 563×1000 可见数 | AABB 最长边中位数／屏宽 | 393×852 可见数 | AABB 最长边中位数／屏宽 |', '| --- | ---: | ---: | ---: | ---: |']
    for x,y in zip(a,b):section.append(f"| {x['theme']} · {x['stock']} | {x['visible']} | {x['medianLongEdgeRatio']:.1%} | {y['visible']} | {y['medianLongEdgeRatio']:.1%} |")
    section += ['', '短屏 600×960 的 7 场也通过；完整每件投影框和视口、相机位置在 `render-short/proportions.json`。上表 AABB 比例不能当成原始竞品物件真实轮廓比例。',
                '', f"微信完整重建与本地审计通过：{audit['rawBytes']:,} 字节（{audit['rawMiB']} MiB），{audit['javascriptFiles']} 个 JS 文件语法检查通过。未生成新的手机验收结论。来源与交付源码、原图、全部运行报告、旧版及当前包哈希见[本轮证据](证据/2026-10-24-场景物件比例修正/验证汇总.json)。"]
    doc=ROOT/'竞品分析/22-场景与物件占屏比例修正.md'
    text=re.sub(r'<!-- r2-results-start -->.*?<!-- r2-results-end -->','<!-- r2-results-start -->\n'+'\n'.join(section)+'\n<!-- r2-results-end -->',doc.read_text('utf-8'),flags=re.S)
    doc.write_text(text,encoding='utf-8')
    for p in [doc,ROOT/'tools/competitor/read_scene_proportions.py',ROOT/'tools/unity/archive_scale_alignment.py',ROOT/'tools/unity/verify_scale_alignment.py',ROOT/'unity/README.md',ROOT/'unity/WECHAT.md']:
        copy(p,OUT/'documents-and-tools'/p.name)
    manifest=[dict(path=p.relative_to(OUT).as_posix(),bytes=p.stat().st_size,sha256=sha(p)) for p in sorted(OUT.rglob('*')) if p.is_file() and p.name!='文件校验.json']
    save(OUT/'文件校验.json',manifest)
    print(json.dumps(dict(summary,files=len(manifest)),ensure_ascii=False))
if __name__=='__main__':main()
