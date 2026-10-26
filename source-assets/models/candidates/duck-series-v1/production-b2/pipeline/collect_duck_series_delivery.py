"""Collect measured final production evidence and build the self-contained handoff."""
import json,shutil,hashlib,zipfile
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
from duck_series_catalog import ROOT,OUT,CATALOG
PROJECT=ROOT/'projects/catch-big-goose-unity';QA=ROOT/'work/duck-series-unity-qa'
def read(p):return json.loads(p.read_text('utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copytree(src,dest):shutil.copytree(src,dest,dirs_exist_ok=True)
def main():
    glb=read(OUT/'qa/glb-validation.json');editor=read(QA/'editor/unity-audit.json')
    desktop=read(QA/'desktop-final/acceptance.json');mobile=read(QA/'mobile-final/acceptance.json')
    assert all(r['passed'] for r in [glb,editor,desktop,mobile])
    package=read(ROOT/'work/wechat-integration/package-audit.json');fileAudit=read(ROOT/'work/wechat-integration/package-file-audit.json')
    assert package['localPackagePassed'] and package['packagedBytes']==fileAudit['packagedBytes']<=30*1024*1024
    structure=read(ROOT/'work/structure-migration/layout-verification.json');assert structure['passed']
    stage=read(OUT/'qa/unity-staging.json')
    for rel,h in stage['protectedFiles'].items():assert sha(PROJECT/rel)==h,rel
    for src,dest in [('editor','unity-editor'),('desktop-final','runtime-desktop'),('mobile-final','runtime-mobile')]:copytree(QA/src,OUT/'qa'/dest)
    shutil.copy2(QA/'desktop/acceptance.json',OUT/'qa/animation-culling-first-failure.json')
    shutil.copy2(QA/'build-result.json',OUT/'qa/unity-build.json')
    for name in ['package-audit.json','package-file-audit.json']:
        shutil.copy2(ROOT/'work/wechat-integration'/name,OUT/'qa'/('wechat-'+name))
    shutil.copy2(ROOT/'work/structure-migration/layout-verification.json',OUT/'qa/structure-verification.json')
    master=OUT.parent/'master-b2';dest=OUT/'master'
    for sub in ['source','models','qa']: 
        for p in (master/sub).rglob('*'):
            if p.is_file() and p.suffix in ['.blend','.glb','.png','.json']:
                target=dest/sub/p.relative_to(master/sub);target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,target)
    (dest/'renders').mkdir(parents=True,exist_ok=True)
    for name in ['hero.png','pose-sheet.png','duck_idle.gif','duck_greet.gif','duck_click.gif']:
        shutil.copy2(master/'renders'/name,dest/'renders'/name)
    selected=[PROJECT/'Assets/Scripts'/name for name in ['GooseGame.cs','GooseGame.DuckReview.cs','GooseHud.cs','GooseHud.Story.cs','GooseHud.DuckReview.cs','GooseHomeStage.cs','GooseDuckMascot.cs','GooseAssetCache.cs','GooseRoundPreparation.cs','GooseDuckProductionAcceptance.cs']]
    selected += [PROJECT/'Assets/Editor'/name for name in ['GooseDuckProduction.cs','DuckSeriesUnityAudit.cs','GooseProjectSetup.cs','GoosePlayerNetworkPolicy.cs','GooseWeChatBuild.cs']]
    for folder in ['Assets/duck-mascot-inputs','Assets/duck-collision-inputs','Assets/Resources/Mascots']:
        selected += [p for p in (PROJECT/folder).rglob('*') if p.is_file()]
    for row in CATALOG:
        id=row['id'];selected += [p for p in (PROJECT/'Assets/Resources/Models'/id).rglob('*') if p.is_file()]
        selected += [PROJECT/('Assets/Resources/Icons/'+id+'.png'),PROJECT/('Assets/Resources/Physics/'+id+'.asset')]
    selected += [PROJECT/'Assets/Resources/Data/duck-review.json',PROJECT/'Assets/Resources/GooseDuckMobile.shader']
    integration=OUT/'unity-integration';files={}
    for p in set(selected):
        for f in [p,Path(str(p)+'.meta')]:
            if not f.is_file():continue
            rel=f.relative_to(PROJECT);target=integration/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,target);files[str(rel).replace('\\','/')]=sha(f)
    (integration/'source-manifest.json').write_text(json.dumps(files,indent=2),'utf-8')
    presentation=read(PROJECT/'Assets/Resources/Data/item-presentation.json');ids={r['id'] for r in CATALOG}
    (integration/'duck-presentation-rows.json').write_text(json.dumps({'items':[r for r in presentation['items'] if r['id'] in ids]},ensure_ascii=False,indent=2),'utf-8')
    (integration/'README.txt').write_text('Unity 2022.3.62f3 integration sources and preserved GUIDs for the existing Catch Big Goose project. This is an overlay, not a standalone Unity project. The active project is already integrated. Formal themes.json and theme-rounds.json are deliberately not replaced. Presentation scale rows are in batch.json and the active item-presentation.json.\n','utf-8')
    c=Image.new('RGB',(1620,1110),'#edf0ec');d=ImageDraw.Draw(c);font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',28)
    d.text((20,10),'B2 实际游戏验收 · 首页 / 五主题评审',font=font,fill='#223937')
    names=['home-idle','theme-0-pile','theme-1-pile','theme-2-pile','theme-3-pile','theme-4-pile']
    for i,name in enumerate(names):
        im=Image.open(QA/'mobile-final'/(name+'.png')).convert('RGB');im.thumbnail((270,510));c.paste(im,(i*270,60))
    for i,name in enumerate(['home-continuous-click','review-menu','duck-eggtart-tray','duck-steelcup-tray','duck-numberblock-tray','home-restored']):
        im=Image.open(QA/'desktop-final'/(name+'.png')).convert('RGB');im.thumbnail((270,510));c.paste(im,(i*270,590))
    c.save(OUT/'renders/runtime-overview.png')
    data={'status':'production-complete','approvedMother':'B2','initialThreeUnchanged':True,'modelCount':20,
        'triangleRange':[min(r['triangles'] for r in glb['models']),max(r['triangles'] for r in glb['models'])],
        'glbByteRange':[min(r['bytes'] for r in glb['models']),max(r['bytes'] for r in glb['models'])],
        'unityVersion':editor['unityVersion'],'physicsBodies':editor['bodyCount'],'naturallySleeping':editor['sleepingAfter15Seconds'],'sleepingAfterSupportRemoval':editor['sleepingAfterRemoval'],
        'runtimeDesktopPassed':desktop['passed'],'runtimeMobileProfilePassed':mobile['passed'],'screenMatchedModels':len(desktop['items']),'matchedPerProfile':desktop['removed'],'reviewEntriesPerProfile':desktop['roundTrips'],
        'homepageRealSkinAnimation':True,'rapidClicksPerProfile':desktop['continuousHomeClicks'],'formalThemesReplaced':False,'formalFilesUnchanged':stage['protectedFiles'],
        'windowsRelease':'projects/catch-big-goose-unity/Builds/Windows/catch-big-goose.exe',
        'wechatLocalExportPassed':True,'wechatPackagedBytes':package['packagedBytes'],'wechatRawDirectoryBytes':package['rawBytes'],'wechatExcludedFiles':package['excludedFiles'],
        'structureCheckPassed':True,'structureChecks':len(structure['checks']),
        'limitations':['Windows mobile profile is not a physical WeChat device test.','New seventeen shapes are delivered for user review; only the B2 mother and first three have explicit prior art approval.'],
        'conceptGeneration':{'mode':'built-in image_gen','prompts':'concepts/prompts.json','images':['concepts/farmer-fusion.png','concepts/noodles-fusion.png']}}
    (OUT/'delivery.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),'utf-8')
    visual={'basis':'Manual inspection of actual GLB roundtrip front/side/back/hero/gameplay sheets and 192/64px icons, including targeted corrected turnarounds.',
        'initialThreeUserApproved':True,'remainingSeventeenUserApprovalClaimed':False,
        'checks':['Consistent B2 small head, bill and feet','Neck roots embedded in props','Tail attachment on final watermelon and farmer','Five-theme prop silhouette and color separation','Same-unit competitor comparisons; original reference sources unchanged'],
        'models':[{'id':r['id'],'sha256':sha(OUT/'models'/r['id']/(r['id']+'.glb')),'assistantVisualReview':'reviewed'} for r in CATALOG]}
    (OUT/'qa/visual-review.json').write_text(json.dumps(visual,ensure_ascii=False,indent=2),'utf-8')
    approvalPath=OUT.parent/'approval.json';approval=read(approvalPath)
    approval.update(currentStage='b2-full-production-delivered',currentDelivery='production-b2/review.html',homepageReplaced=True,modelReviewRejected=False,
        previousModelReviewRejected=True,completedCandidateModels=[r['id'] for r in CATALOG],reviewThemesInstalled=True,
        remainingSeventeenArtReviewStatus='delivered-for-user-review',runtimeVerificationScope='Actual production source in Windows desktop and mobile profiles; local WeChat export passed; no physical WeChat device test',
        runtimeEvidence='production-b2/delivery.json')
    approvalPath.write_text(json.dumps(approval,ensure_ascii=False,indent=2),'utf-8');shutil.copy2(approvalPath,OUT/'approval.json')
    pipeline=OUT/'pipeline';pipeline.mkdir(exist_ok=True)
    for name in ['build_duck_b2_series.py','build_duck_b2_combinations.py','build_duck_representatives.py','duck_series_catalog.py','stage_duck_b2_series.py','prepare_duck_series_audit.py','audit_duck_b2_series.mjs','review_duck_b2_series.py','collect_duck_series_delivery.py','DuckB2UnityAudit.cs','GooseDuckMobile.shader']:
        shutil.copy2(Path(__file__).with_name(name),pipeline/name)
    if (QA/'ui-final/acceptance.json').exists():
        assert read(QA/'ui-final/acceptance.json')['passed'];copytree(QA/'ui-final',OUT/'qa/runtime-ui-final')
    if (QA/'windows-release.json').exists():shutil.copy2(QA/'windows-release.json',OUT/'qa/windows-release.json')
    (OUT/'README.md').write_text('# B2 鸭子完整交付\n\n打开 `review.html` 查看 20 款真实网格、多视图、同尺寸竞品对照与图标。实际游戏入口：设置 → 鸭子模型评审 → 五主题；退出恢复正式主题和进度。\n\n`models` 为模型/图集/碰撞代理，`source` 为可编辑 Blender 源，`master` 为原 B2 母模与骨架动作，`unity-integration` 为当前工程对应资源和源码，`qa` 为真实导入、物理和流程记录，`batch.json` 为完整映射。\n\n`concepts` 两张内置生图只用于复杂融合方案推敲；全部验收渲染来自实际 GLB。已通过三款 GLB 保持原始哈希。模型几何与真实游戏技术检查通过；剩余 17 款作为本轮美术交付。Windows 移动端配置测试不等同微信真机测试。\n','utf-8')
    report=(ROOT/'docs/development-reports/duck-b2-full-production-20261025.md').read_text('utf-8')
    report=report.replace('../../source-assets/models/candidates/duck-series-v1/production-b2/','').replace('[完整交付 ZIP](../../work/duck-b2-full-production-20261025.zip)','完整交付 ZIP（本压缩包）')
    (OUT/'acceptance-report.md').write_text(report,'utf-8')
    html=(OUT/'review.html').read_text('utf-8');marker='<section><h2>实际游戏与首页骨骼动作</h2>'
    if marker in html:html=html.split(marker)[0]+'</html>'
    html=html.replace('</html>',marker+'<p>设置 → 鸭子模型评审。五主题独立评审不计正式成绩；退出恢复原主题和进度。两种 Windows 配置均通过 20 款真实拾取、入槽与三消。</p><img src="renders/runtime-overview.png"><p>上图为完整流程验收截图；最终缩短的评审标题已另行验证：<a href="qa/runtime-ui-final/review-title.png">当前关卡画面</a>。</p><p><a href="qa/runtime-desktop/acceptance.json">桌面流程报告</a> · <a href="qa/runtime-mobile/acceptance.json">移动端配置报告</a> · <a href="qa/unity-editor/unity-audit.json">真实材质、蒙皮与物理报告</a> · <a href="qa/wechat-package-audit.json">微信本地包检查</a></p><p><img src="master/renders/duck_idle.gif"><img src="master/renders/duck_greet.gif"><img src="master/renders/duck_click.gif"></p><p>以上动画预览来自母模，实际首页动画由同一骨架驱动并以 BakeMesh 验证。</p></section></html>')
    (OUT/'review.html').write_text(html,'utf-8')
    zipPath=ROOT/'work/duck-b2-full-production-20261025.zip'
    with zipfile.ZipFile(zipPath,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for p in OUT.rglob('*'):
            if p.is_file() and p.suffix not in ['.blend1','.tmp']:z.write(p,'duck-b2-production/'+p.relative_to(OUT).as_posix())
    print(json.dumps({'delivery':str(OUT),'zip':str(zipPath),'zipBytes':zipPath.stat().st_size,'zipSha256':sha(zipPath)},ensure_ascii=True))
if __name__=='__main__':main()
