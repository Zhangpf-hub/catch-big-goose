"""Summarise actual R4 evidence, keeping unfinished/device gates explicit."""
from pathlib import Path
import json,statistics,html,math,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[2];WORK=ROOT/'work/r4-interaction-20261025'
def read(rel):
    p=WORK/rel;return json.loads(p.read_text(encoding='utf-8-sig')) if p.exists() else {}
r=read('floor-final-50/r4-acceptance.json');rows=r.get('rounds',[])
def stat(key,items=rows):
    a=sorted(x[key] for x in items)
    return dict(min=min(a),median=statistics.median(a),p95=a[max(0,math.ceil(len(a)*.95)-1)],max=max(a)) if a else None
end=read('endgame-floor/r4-acceptance.json');ui=read('ui-floor/ui-acceptance.json');inter=read('interaction-floor/interaction.json')
xml=WORK/'editmode-floor.xml';unit=ET.parse(xml).getroot().attrib if xml.exists() else {}
sim=read('wechat/simulator-touch/touch-acceptance.json')
outstanding=['Physical phone cold startup, touch chain, accelerometer and sustained frame/memory acceptance']
if not sim.get('touchSuitePassed'):
    outstanding.append('Current WeChat simulator touch walkthrough pending')
if sim and not sim.get('sensorAcceptancePassed'):
    outstanding.append('WeChat accelerometer rejected by account privacy declaration: '+sim.get('sensorBlocker','unverified'))
summary=dict(build='20261025-R4',complete=False,phonePassed=False,percentileMethod='nearest rank across case samples',
    native50=dict(passed=len(rows)==50 and r.get('passed') is True,rounds=len(rows),checks=len(r.get('checks',[])),errors=r.get('errors',[])),
    firstMs=stat('firstMs'),interactiveMs=stat('interactiveMs'),preparationMs=stat('prepareMs'),frameP95Ms=stat('frameP95Ms'),allocationBytes=stat('allocatedBytes'),
    challengeExposed=stat('accessible',[x for x in rows if x['stage']==2]),
    endgame=dict(passed=end.get('passed'),rounds=len(end.get('rounds',[])),checks=len(end.get('checks',[])),errors=end.get('errors',[])),
    ui=dict(passed=ui.get('passed'),checks=len(ui.get('checks',[])),errors=ui.get('errors',[])),
    interaction=dict(passed=inter.get('passed'),checks=len(inter.get('checks',[])),errors=inter.get('errors',[])),unit=unit,
    simulator=dict(touchSuitePassed=sim.get('touchSuitePassed',False),sensorAcceptancePassed=sim.get('sensorAcceptancePassed',False),persistenceRestartVerified=sim.get('persistenceRestartVerified',False),coverage=sim.get('coverage'),report='wechat/simulator-touch/touch-acceptance.json'),
    outstanding=outstanding,
    limits=['Native forced-mobile measurements, not phone FPS','Warm opening starts after preparation Ready; separate background preparation duration reported','Late fixture controls inventory through production animations, not a human win rate','Exposed counts use actual screen rays; five-to-six is a tuning target, not a whitelist'])
(WORK/'delivery-summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
cards=[]
for tid,title in [('breakfast','早餐铺'),('barbecue','烧烤摊'),('countryside','乡村小院'),('toys','童年玩具'),('grocery','杂货铺')]:
    pics=[]
    for suffix,label in [('opening','开局'),('contracted','缩筐后')]:
        p=WORK/'floor-final-50'/(tid+'-stage2-'+suffix+'.png')
        if not p.exists() and suffix=='opening':p=WORK/'endgame-floor'/(tid+'-stage2-opening.png')
        if p.exists():pics.append('<figure><img loading="lazy" src="'+html.escape(p.relative_to(WORK).as_posix())+'"><figcaption>'+label+'</figcaption></figure>')
    cards.append('<section><h2>'+title+'</h2><div class="images">'+''.join(pics)+'</div></section>')
page='''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>R4 实际运行记录</title>
<style>body{font:16px system-ui,sans-serif;background:#f4eee2;color:#3d3026;margin:32px auto;max-width:1160px;padding:0 18px}h1{font-size:26px}p{line-height:1.7}section{background:#fffaf0;border-radius:16px;padding:20px;margin:24px 0}.images{display:flex;gap:20px;flex-wrap:wrap}figure{margin:0;max-width:390px;flex:1;min-width:240px}img{width:100%;height:auto;border-radius:12px}figcaption{padding:8px}a{color:#68543c}pre{white-space:pre-wrap;font:13px ui-monospace,monospace;background:#fff;padding:18px;border-radius:12px}video{width:min(100%,390px)}</style>
<h1>R4 · 两关、五主题背景与圆筐</h1><p>以下为实际原生开发包画面。预加载、独立三消批次、真实物理摇动、圆筐收缩与末期俯视已接入。真机触控、传感器和持续性能仍待验证；本页不把电脑结果当作手机验收。</p>'''
page+='<p>本轮回归：'+str(len(rows))+'/50 局；错误 '+str(len(r.get('errors',[])))+'。<a href="wechat/r4-floor-preview.png">微信体验码</a> · <a href="delivery-summary.json">完整数值及待验项目</a></p>'
if sim:
    page+='<section><h2>微信模拟器实际触控</h2><p>五主题入门关与早餐 300 件挑战已经实际点击验证。连续拾取、道具、结算跨关、暂停恢复及重启存档通过。手机摇动入口被微信账号隐私声明错误拒绝，传感器验收未通过。</p><p><a href="wechat/simulator-touch/README.md">详细验收记录及处理步骤</a> · <a href="wechat/simulator-touch/touch-acceptance.json">逐项记录</a></p></section>'
page+=''.join(cards)+'<section><h2>实际录制</h2><p>PNG 写入时间恢复播放时长，无音轨。R3 为同库存早餐开局对照；R4 最新录像为乡村主题，不能把跨主题录像当成严格性能对比。数据对照见 JSON。录像不用于性能结论。</p><div class="images"><figure><video controls preload="metadata" src="videos/r3-opening.mp4"></video><figcaption>R3 早餐开局记录</figcaption></figure><figure><video controls preload="metadata" src="videos/r4-floor-challenge.mp4"></video><figcaption>R4 最新版开局、连消、摇动与收缩</figcaption></figure></div></section>'
page+='<details><summary>验证数值与边界</summary><pre>'+html.escape(json.dumps(summary,ensure_ascii=False,indent=2))+'</pre></details></html>'
(WORK/'review.html').write_text(page,encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False,indent=2))
