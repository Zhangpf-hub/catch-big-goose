const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const root=path.resolve(__dirname,'..');
const out=path.join(root,'source-assets/models/candidates/electronics-v2/qa/runtime');

(async()=>{
 const browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
 try{
  const context=await browser.newContext({viewport:{width:390,height:844}});
  await context.addInitScript(()=>{
   localStorage.setItem('goose_onboarded_v1','1');localStorage.setItem('goose_taught_v1','1');
   localStorage.setItem('goose_theme_v1','fruit');
   localStorage.setItem('goose_best_v2',JSON.stringify({fruit:{0:{stars:2,progress:100,score:1234}}}));
   const d=new Date();localStorage.setItem('goose_level_v1',JSON.stringify({date:`${d.getFullYear()}-${d.getMonth()+1}-${d.getDate()}`,index:0}));
  });
  const page=await context.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('http://127.0.0.1:5185/');
  await page.waitForFunction(()=>{const g=globalThis.cc?.director?.getScene()?.getComponentsInChildren('GameManager')[0];
    if(g?.hud?.router?.activeName!=='home')return false;globalThis.qaGame=g;return true;});
  async function point(expression){return page.evaluate(expression=>{const n=new Function(`return (${expression})`)();
   const c=cc.director.getScene().getComponentsInChildren(cc.Camera).find(c=>c.enabledInHierarchy&&(c.visibility&n.layer));
   const p=c.worldToScreen(n.worldPosition),a=document.querySelector('canvas'),r=a.getBoundingClientRect();
   return{x:r.x+p.x/a.width*r.width,y:r.y+(a.height-p.y)/a.height*r.height};},expression);}
  const viewport=await point('qaGame.hud.homeScreen.mapViewport');
  await page.mouse.move(viewport.x,viewport.y);
  const before=await page.evaluate(()=>qaGame.hud.homeScreen.scrollY);
  await page.mouse.wheel(0,250);await page.waitForTimeout(80);
  const after=await page.evaluate(()=>qaGame.hud.homeScreen.scrollY);
  const direction=after<before?250:-250;
  for(let i=0;i<22;i++){await page.mouse.wheel(0,direction);await page.waitForTimeout(50);}
  const station=await point("qaGame.hud.homeScreen.mapStations.find(n=>n.name==='mapStation-electronics')");
  assert(station.y>140&&station.y<570,JSON.stringify(station));
  await page.mouse.click(station.x,station.y);
  await page.waitForFunction(()=>localStorage.getItem('goose_theme_v1')==='electronics'&&qaGame.level.items[0]==='phone');
  await page.screenshot({path:path.join(out,'navigation-selected-electronics.png')});
  const difficulty=await point('qaGame.hud.homeScreen.difficultyHits[0]');await page.mouse.click(difficulty.x,difficulty.y);
  const cta=await point('qaGame.hud.homeScreen.ctaHit');await page.mouse.click(cta.x,cta.y);
  await page.waitForFunction(()=>qaGame.playing&&qaGame.node.getComponentsInChildren('ItemTag').length===48);
  await page.waitForTimeout(3000);
  for(let i=0;i<48;i++){
   await page.evaluate(()=>{
    if(!qaGame.playing)throw new Error('Round ended before all matches');
    const entries=qaGame.tray.entries;const id=entries.length?entries[0].id:null;
    const t=qaGame.node.getComponentsInChildren('ItemTag').find(t=>!t.picked&&!t.frozen&&!t.golden&&(!id||t.id===id));
    if(!t)throw new Error('Could not complete a full match');qaGame.pick(t.node,t);
   });
   await page.waitForTimeout(430);
  }
  await page.waitForTimeout(1300);
  const final=await page.evaluate(()=>({playing:qaGame.playing,removed:qaGame.removedCount,total:qaGame.totalCount,
   levelIndex:qaGame.levelIndex,best:JSON.parse(localStorage.getItem('goose_best_v2')),score:qaGame.score}));
  assert.equal(final.playing,false);assert.equal(final.removed,48);assert.equal(final.levelIndex,1);
  assert(final.best.electronics[0].score>0);assert.equal(final.best.fruit[0].score,1234);assert.deepEqual(errors,[]);
  await page.screenshot({path:path.join(out,'victory-electronics.png')});
  fs.writeFileSync(path.join(out,'navigation-victory.json'),JSON.stringify({status:'passed',mapSelection:'real wheel scroll and mouse click from fruit to electronics',final,errors},null,2));
  console.log('PASS: fifth map station selected from fruit, full 48-item clear, victory, next level and per-theme score isolation');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
