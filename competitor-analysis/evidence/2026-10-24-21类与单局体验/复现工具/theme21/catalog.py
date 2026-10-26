"""Original model specifications. No competitor geometry or textures are used."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
BATCH = ROOT / 'assets-3d/candidates/themes-21-20261024'
# id, display name, main palette index, silhouette, three visible features.
GROUPS = {
 'fruit': [
  ('watermelon','西瓜',12,'长椭球','深浅瓜纹|短瓜蒂|完整厚瓜体'),
  ('pineapple','菠萝',2,'菱格筒体与叶冠','菱格果皮|放射叶冠|圆底果身'),
  ('peach','桃子',10,'带沟心形','双瓣果肉|纵向沟线|叶与短梗'),
  ('kiwi','猕猴桃',6,'厚切圆片','棕色外皮|绿色切面|放射黑籽'),
  ('mango','芒果',2,'弯曲肾形','偏心果腹|收尖果端|短叶梗'),
  ('coconut','椰子',6,'粗壳圆球','棕色厚壳|三个芽眼|浅色壳棱'),
  ('blueberry','蓝莓',4,'三连圆果','蓝紫果体|五瓣花萼|短枝相连'),
  ('dragonfruit','火龙果',10,'鳞片椭球','粉红果壳|绿色厚鳞片|两端收口'),
  ('avocado','牛油果',12,'梨形厚半果','绿色外皮|浅色切面|棕色大核'),
  ('pomegranate','石榴',0,'带冠圆球','红色果体|厚花冠|粗果皮棱'),
  ('persimmon','柿子',2,'扁方圆果','橙色四瓣|绿色大萼片|短果梗'),
  ('starfruit','杨桃',13,'五角厚柱','五条凸棱|五角端面|绿黄双色'),
 ],
 'antique': [
  ('jadevase','玉瓶',1,'窄颈鼓腹','厚瓶口|窄颈鼓腹|环形底足'),
  ('jadepeanut','玉花生',9,'双节荚形','双节轮廓|浅槽纹|厚吊环'),
  ('jadecarp','玉鲤鱼',1,'鱼形','立体鱼身|分叉尾鳍|眼与背鳍'),
  ('jadetiger','玉虎',2,'伏卧兽形','四肢与虎头|圆耳|背部深条纹'),
  ('jadetalisman','玉牌',1,'圆角长牌','穿绳孔环|厚牌体|金色凸纹'),
  ('goldring','金戒指',2,'环与宝石','厚金环|蓝色石座|凸起主石'),
  ('goldchime','金编钟',2,'悬钮钟形','厚钟身|顶端悬钮|底部钟唇'),
  ('jadechime','玉磬',1,'折角板形','折角主体|金色悬孔|厚实板面'),
  ('jadeleaf','玉叶',12,'尖椭叶形','叶片轮廓|中央叶脉|顶部吊环'),
  ('jadelock','长命锁',2,'圆肩锁形','左右锁肩|中央凸纹|厚悬挂环'),
  ('jadeteapot','玉壶',1,'壶体与嘴把','鼓腹壶身|弯壶嘴|壶把与壶盖'),
  ('jadebeads','玉珠串',1,'厚珠环','连续玉珠|金色隔珠|一枚垂坠珠'),
 ],
 'farm': [
  ('tomato','番茄',0,'扁圆果','红色果体|五瓣绿萼|短果梗'),
  ('potato','土豆',9,'不规则椭球','土黄色表皮|可见芽眼|偏心厚体'),
  ('cabbage','白菜',1,'抱叶椭球','层叠外叶|浅色菜心|厚白菜梗'),
  ('broccoli','西兰花',12,'树冠形','分枝菜梗|簇状花冠|大小花球'),
  ('bellpepper','甜椒',0,'三瓣鼓体','分瓣外形|弯绿梗|下端厚瓣'),
  ('cucumber','黄瓜',12,'长弯柱','收尖瓜头|浅色条棱|粗表皮颗粒'),
  ('onion','洋葱',3,'层纹水滴','紫色层纹|收束尖颈|白色根盘'),
  ('radish','白萝卜',7,'锥形粗根','白色粗根|厚绿叶束|短尾根'),
  ('garlic','蒜头',9,'多瓣球','六瓣蒜体|短蒜梗|扁根盘'),
  ('wateringcan','浇水壶',8,'壶嘴提把','大壶身|斜壶嘴与喷头|顶部厚提把'),
  ('egg','鸡蛋',9,'卵形与托圈','上下不同曲率|奶油色蛋壳|浅色厚底托'),
  ('shovel','小铲子',4,'铲面长柄','宽铲面|木色厚柄|环形握把'),
 ],
 'dessert': [
  ('chocolate','巧克力',6,'厚分格板','方块分格|厚底板|浅色包装角'),
  ('lollipop','棒棒糖',10,'圆糖长棒','厚圆糖盘|旋纹|粗糖棒'),
  ('popsicle','冰棍',8,'圆角冰体','上下双色冰体|厚木棒|三条压纹'),
  ('wafer','威化饼',9,'多层厚方片','棋盘纹面|三层夹心|棕色巧克力边'),
  ('swissroll','蛋糕卷',9,'横向圆卷','螺旋截面|厚奶油芯|金黄外皮'),
  ('eggtart','蛋挞',2,'碟状厚挞','折边挞皮|黄色蛋液面|棕色烘烤斑'),
  ('pancake','松饼',9,'三层圆饼','叠层厚饼|黄油块|浅棕糖浆圈'),
  ('pretzel','碱水结',6,'交叉双环','两大环孔|交叉厚面条|白色盐粒'),
  ('toast','吐司',9,'拱顶厚片','棕色厚边|奶油色内芯|圆拱顶'),
  ('dumpling','小笼包',9,'褶口圆包','鼓起厚包体|顶部褶口|底部蒸皮圈'),
  ('mooncake','月饼',2,'印花厚圆饼','齿状饼边|凸起圆纹|中央方印'),
  ('teacup','奶茶杯',10,'带盖杯形','锥形厚杯|双色封盖|粗吸管'),
 ],
 'electronics': [
  ('tablet','平板',14,'宽屏薄板','大屏边框|侧按键|背面镜头'),
  ('keyboard','键盘',1,'宽键盘板','多排大键帽|长空格|双色机壳'),
  ('monitor','显示器',8,'屏与支架','宽屏边框|厚立柱|平衡底座'),
  ('television','电视机',6,'带脚厚屏','圆角厚屏|两枚控制钮|左右底脚'),
  ('printer','打印机',7,'叠层箱形','进纸托盘|出纸口|实体纸张'),
  ('router','路由器',9,'箱体与双天线','厚箱体|两根粗天线|三枚状态灯'),
  ('usbdrive','U盘',10,'短棒接头','双色壳体|厚金属接头|挂绳孔环'),
  ('powerbank','充电宝',2,'厚圆角砖','厚机身|端口凸边|电量灯'),
  ('microphone','话筒',3,'圆头柄','金属网罩轮廓|收束握柄|底部开关'),
  ('gamepad','手柄',4,'双握持宽体','左右握柄|十字键|四枚按钮'),
  ('flashlight','手电筒',0,'扩口筒形','宽灯头|亮色灯面|防滑握柄'),
  ('alarmclock','闹钟',13,'双铃圆盘','钟面与粗指针|左右铃罩|两只底脚'),
 ]}

def specifications():
    rows=[]
    for theme,items in GROUPS.items():
        for id,name,color,silhouette,features in items:
            rows.append(dict(id=id,theme=theme,name=name,paletteIndex=color,silhouette=silhouette,
                             recognitionFeatures=features.split('|'),
                             connections='Closed solid parts assembled by contact or overlap; no floating accessories',
                             simplification='No text, branding, micro surface noise or internal mechanisms',
                             budget=dict(targetTriangles=[1000,4000],maxTriangles=6000,maxGlbBytes=262144,
                                         materials=1,texture=[64,64],normalizedLongestEdge=1,minThickness=.08)))
    return rows

if __name__=='__main__':
    p=ROOT/'assets-3d/specs/themes-21-20261024.json';p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(dict(purpose='Original Unity theme expansion, 12 new items per theme',models=specifications()),ensure_ascii=False,indent=2),'utf-8')
    print('Specified',len(specifications()),'original items')
