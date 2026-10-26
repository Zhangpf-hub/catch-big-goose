const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const output = path.join(root, 'source-assets/models/candidates/electronics-v2/qa/runtime');
const URL = process.env.GAME_URL || 'http://127.0.0.1:5185/';
const IDS = ['phone','laptop','camera','headphones','handheld','speaker','mouse','smartwatch','radio'];
const results = [];
fs.mkdirSync(output, { recursive: true });

async function uiPoint(page, expression) {
  return page.evaluate(expression => {
    const node = new Function(`return (${expression})`)();
    const camera = cc.director.getScene().getComponentsInChildren(cc.Camera)
      .find(c => c.enabledInHierarchy && (c.visibility & node.layer));
    const p = camera.worldToScreen(node.worldPosition);
    const canvas = document.querySelector('canvas'), r = canvas.getBoundingClientRect();
    return { x: r.x+p.x/canvas.width*r.width, y: r.y+(canvas.height-p.y)/canvas.height*r.height };
  }, expression);
}

(async () => {
  const browser = await chromium.launch({ headless: true,
    executablePath: process.env.BROWSER_EXECUTABLE || 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
  try {
    for (const [width, height] of [[390,844],[347,603],[1280,720]]) {
      for (let level = 0; level < 3; level++) {
        const context = await browser.newContext({ viewport: { width, height } });
        await context.addInitScript(() => {
          localStorage.setItem('goose_onboarded_v1', '1');
          localStorage.setItem('goose_taught_v1', '1');
          localStorage.setItem('goose_theme_v1', 'electronics');
          const d = new Date();
          localStorage.setItem('goose_level_v1', JSON.stringify({date:`${d.getFullYear()}-${d.getMonth()+1}-${d.getDate()}`,index:0}));
        });
        const page = await context.newPage();
        const errors = [];
        page.on('pageerror', e => errors.push(e.message));
        page.on('response', r => { if(r.url().startsWith(URL) && r.status()>=400) errors.push(`${r.status()} ${r.url()}`); });
        try {
          await page.goto(URL);
          await page.waitForFunction(() => {
            const gm = globalThis.cc?.director?.getScene()?.getComponentsInChildren('GameManager')[0];
            if (gm?.hud?.router?.activeName !== 'home') return false;
            globalThis.qaGame = gm; return true;
          }, null, { timeout: 45000 });
          const home = await page.evaluate(() => ({
            nodes: qaGame.hud.homeScreen.mapStations.map(n => n.name),
            maps: qaGame.hud.homeScreen.data.maps.map(m => ({id:m.id,selected:m.selected,playable:m.playable})),
          }));
          assert.equal(home.nodes.length, 5);
          assert(home.nodes.includes('mapStation-electronics'));
          assert(home.maps.find(m => m.id === 'electronics').playable);
          // Tap the new station itself, through its actual screen hit area.
          const station = await uiPoint(page, "qaGame.hud.homeScreen.mapStations.find(n=>n.name==='mapStation-electronics')");
          await page.mouse.click(station.x, station.y);
          await page.waitForTimeout(350);
          const difficulty = await uiPoint(page, `qaGame.hud.homeScreen.difficultyHits[${level}]`);
          await page.mouse.click(difficulty.x, difficulty.y);
          await page.waitForTimeout(200);
          assert.equal(await page.evaluate(() => qaGame.levelIndex), level);
          if (width === 390 && level === 0) await page.screenshot({ path: path.join(output, 'home-electronics.png') });
          const cta = await uiPoint(page, 'qaGame.hud.homeScreen.ctaHit');
          await page.mouse.click(cta.x, cta.y);
          const expected = [48,54,81][level], golden = level > 0 ? 1 : 0;
          await page.waitForFunction(({expected,golden}) => qaGame.playing && qaGame.totalCount === expected
            && qaGame.node.getComponentsInChildren('ItemTag').length === expected+golden,
            {expected,golden}, {timeout:30000});
          await page.waitForTimeout(4000);
          const initial = await page.evaluate(() => {
            const tags = qaGame.node.getComponentsInChildren('ItemTag'), wall = qaGame.boundary.wall;
            return { physics: qaGame.jolt.isReady, total:qaGame.totalCount, tags:tags.length,
              ids:[...new Set(tags.filter(t=>!t.golden).map(t=>t.id))],
              frozen:tags.filter(t=>t.frozen).length,
              renderers:tags.filter(t=>!t.golden).map(t=>({id:t.id,
                names:t.node.getComponentsInChildren('cc.MeshRenderer').map(m=>m.node.name)})),
              container:qaGame.sceneRoot.getComponentsInChildren('cc.MeshRenderer').map(m=>m.node.name),
              contained:tags.every(t=>{const p=t.node.worldPosition;return [p.x,p.y,p.z].every(Number.isFinite)
                && p.y>-.5 && Math.abs(p.x-wall.cx)<wall.halfX+.35 && Math.abs(p.z-wall.cz)<wall.halfZ+.35;}) };
          });
          assert(initial.physics && initial.contained, JSON.stringify(initial));
          for(const id of IDS.slice(0,[4,6,9][level])) assert(initial.ids.includes(id), `Missing ${id}`);
          assert(initial.container.includes('tray_electronics'));
          assert.equal(initial.frozen,[0,4,7][level]);
          if(width===390) await page.screenshot({path:path.join(output,`level-${level+1}-playing.png`)});
          const target = await page.evaluate(() => {
            const canvas=document.querySelector('canvas'),r=canvas.getBoundingClientRect();
            for(const t of qaGame.node.getComponentsInChildren('ItemTag').filter(t=>!t.frozen&&!t.golden)) {
              const p=qaGame.cam.worldToScreen(t.node.worldPosition);
              for(const dx of [0,-8,8,-16,16]) for(const dy of [0,-8,8,-16,16]) {
                if(qaGame.hitTestAt(p.x+dx,p.y+dy)!==t) continue;
                return {id:t.id,x:r.x+(p.x+dx)/canvas.width*r.width,y:r.y+(canvas.height-p.y-dy)/canvas.height*r.height};
              }
            }
          });
          assert(target, 'No exposed touch target');
          await page.mouse.click(target.x,target.y);
          await page.waitForFunction(id=>qaGame.tray.count===1&&qaGame.tray.entries[0].id===id,target.id);
          const slot = await page.evaluate(()=>qaGame.tray.entries[0].node.getComponentsInChildren('cc.MeshRenderer').map(m=>m.node.name));
          assert(slot.includes(target.id));
          if(width===390) await page.screenshot({path:path.join(output,`level-${level+1}-slot.png`)});
          const frozenBefore = await page.evaluate(() => {
            let tag=qaGame.frozenTags[0];
            if(!tag) {
              tag=qaGame.node.getComponentsInChildren('ItemTag').find(t=>!t.picked&&!t.golden);
              tag.frozen=true;qaGame.addIceShell(tag.node,tag);qaGame.frozenTags.push(tag);
            }
            const before=qaGame.tray.count;
            qaGame.pick(tag.node,tag);
            if(tag.picked||qaGame.tray.count!==before) throw new Error('Frozen object was pickable');
            return qaGame.frozenTags.length;
          });
          const removed = await page.evaluate(()=>qaGame.removedCount);
          for(let i=0;i<2;i++) {
            await page.evaluate(id=>{
              const t=qaGame.node.getComponentsInChildren('ItemTag').find(t=>t.id===id&&!t.picked&&!t.frozen&&!t.golden);
              if(!t) throw new Error('Missing match partner');
              qaGame.pick(t.node,t);
            },target.id);
            await page.waitForTimeout(500);
          }
          await page.waitForTimeout(600);
          const matched=await page.evaluate(()=>({removed:qaGame.removedCount,tray:qaGame.tray.count,
            frozen:qaGame.frozenTags.filter(t=>t.frozen).length,score:qaGame.score}));
          assert.equal(matched.removed,removed+3);assert.equal(matched.tray,0);
          assert(matched.frozen<frozenBefore);
          if(width===390) await page.screenshot({path:path.join(output,`level-${level+1}-matched.png`)});
          assert.deepEqual(errors,[]);
          results.push({width,height,level:level+1,status:'passed',home,initial,clickedId:target.id,slot,matched,errors});
          console.log(`PASS electronics level ${level+1} ${width}x${height}: map, difficulty, assets, containment, click, tray, ice, match`);
        } catch(error) {
          await page.screenshot({path:path.join(output,`FAIL-${width}-${level+1}.png`)}).catch(()=>{});
          results.push({width,height,level:level+1,status:'failed',message:error.message,errors});
          throw error;
        } finally {await context.close();}
      }
    }
  } finally {
    fs.writeFileSync(path.join(output,'results.json'),JSON.stringify(results,null,2));
    await browser.close();
  }
})().catch(e=>{console.error(e);process.exitCode=1;});
