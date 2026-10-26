"""Locked B2 production roster. No aliases silently substitute a requested item."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'source-assets/models/candidates/duck-series-v1/production-b2'
APPROVED=ROOT/'source-assets/models/candidates/duck-series-v1/model-review-b2'
ROWS=[
 ('breakfast','鸡蛋饼鸭','eggpancake','EggPancake','金黄折饼；白色蛋面；橙黄蛋黄','颈穿出折饼上沿，脚承托下缘'),
 ('breakfast','蛋挞鸭','eggtart','EggTart','波浪挞边；黄色蛋心；浅盘背面','已通过原件'),
 ('breakfast','小米饼鸭','milletcake','MilletCake','金黄圆饼；格状烙痕；浅褐芝麻点','颈穿出圆饼顶侧，脚贴饼底'),
 ('breakfast','馒头鸭','steamedbread','BFSteamedBread','奶油白蓬松圆体；顶部褶纹；平底','鸭身藏入馒头，颈穿出顶部'),
 ('barbecue','茄子鸭','eggplant','Eggplant','紫色长果；绿色萼片；弯曲短柄','颈由果实肩侧穿出，果体细长'),
 ('barbecue','青椒鸭','greenpepper','GreenPepper','三瓣青绿果体；凹顶；弯柄','颈穿出侧瓣上方'),
 ('barbecue','煎饼鸭','pancake','Pancake','三层薄饼；金黄边缘；焦色烙点','鸭身藏在薄饼层里，颈从上层探出'),
 ('barbecue','土豆鸭','potato','Potato','浅棕不规则椭圆；深色芽眼；宽钝两端','颈穿出土豆肩部，脚靠拢'),
 ('courtyard','番茄鸭','tomato','Tomato','红色分瓣圆果；绿色星状萼；短柄','颈穿出萼片一侧'),
 ('courtyard','钢杯鸭','steelcup','SteelCup','开口钢杯；卷边；弧形提手','已通过原件'),
 ('courtyard','农夫鸭','farmer','Farmer','宽草帽檐；拱形帽冠；深棕帽带','草帽包住身体，细颈从前檐探出'),
 ('courtyard','西瓜鸭','watermelon','Watermelon','绿色弧形瓜皮；红色切面；黑籽','颈穿出瓜瓤顶侧，脚贴平切底边'),
 ('toys','数字积木鸭','numberblock','GTNumberBlock','红方块；绿色数字1；背部连接钮','已通过原件'),
 ('toys','悠悠球鸭','yoyo','GTYoYo','双蓝色轮盘；中央轴缝；黄色中心圈','颈从轮盘间隙穿出，脚贴轮盘底部'),
 ('toys','打孔器鸭','craftpunch','GTCraftPunch','蓝色底座；粉色压柄；金属压柱与进纸口','颈从压柄尾部探出'),
 ('toys','胶囊笔鸭','capsulepen','GTCapsulePen','长胶囊笔身；双色笔帽；锥形笔尖','细颈从笔身上部穿出，小脚承托横放笔身'),
 ('grocery','辣椒酱鸭','chilisauce','ChiliSauce','红褐酱罐；深色旋盖；奶油标签与辣椒标志','颈穿出罐肩，标签正面完整'),
 ('grocery','可乐杯鸭','colacup','ColaCup','红色锥杯；白色杯盖；弯折吸管','颈从杯盖侧口探出'),
 ('grocery','鸡蛋鸭','egg','Egg','乳白破蛋壳；不规则裂口；内侧蛋黄','鸭身包在蛋壳里，颈从裂口探出'),
 ('grocery','面条鸭','noodles','Noodles','红色面杯；盘曲面条；掀开杯盖','细颈从杯中面条间探出'),
]
THEME_NAMES={'breakfast':'早餐铺','barbecue':'烧烤摊','courtyard':'乡村小院','toys':'童年玩具','grocery':'杂货铺'}
CATALOG=[]
for theme,name,key,ref,features,connection in ROWS:
    candidates=list((ROOT/'reference-projects/competitor-goose').glob('*/models/Goose_'+ref+'/Goose_'+ref+'.glb'))
    assert candidates,ref
    source=sorted(candidates,reverse=True)[0]
    CATALOG.append({'id':'duck-'+key,'key':key,'theme':theme,'themeName':THEME_NAMES[theme],'name':name,
        'reference':str(source.relative_to(ROOT)).replace('\\','/'),'features':features.split('；'),'connection':connection,
        'targetTriangles':[2000,4000],'maximumTriangles':6000,'headSource':'Locked B2 mother mesh; no regeneration'})
BY_ID={r['id']:r for r in CATALOG}
IDS=list(BY_ID)
APPROVED_IDS=['duck-eggtart','duck-steelcup','duck-numberblock']
NEW_IDS=[id for id in IDS if id not in APPROVED_IDS]
