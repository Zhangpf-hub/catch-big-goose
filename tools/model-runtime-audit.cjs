// Usage: PLAYWRIGHT_MODULE=playwright node tools/model-runtime-audit.cjs
// Runs against the release preview; controlled ice setup only affects the isolated test browser.
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const results = [];

(async () => {
  const browser = await chromium.launch({
    headless: true,
    executablePath: process.env.BROWSER_EXECUTABLE || undefined,
  });
  try {
    for (const [theme, id, parts] of [
      ['fruit', 'banana', ['curved-peel', 'stem', 'stem-cut', 'blossom-tip']],
      ['farm', 'corn', ['cob-core', 'kernel-rows', 'folded-husks', 'husk-veins', 'cut-stalk']],
    ]) for (const [width, height] of [[390, 844], [347, 603], [1280, 720]]) {
      const context = await browser.newContext({ viewport: { width, height } });
      await context.addInitScript(theme => {
        localStorage.setItem('goose_onboarded_v1', '1');
        localStorage.setItem('goose_taught_v1', '1');
        localStorage.setItem('goose_theme_v1', theme);
        const d = new Date();
        localStorage.setItem('goose_level_v1', JSON.stringify({ date: `${d.getFullYear()}-${d.getMonth()+1}-${d.getDate()}`, index: 0 }));
      }, theme);
      const page = await context.newPage();
      const errors = [];
      page.on('pageerror', error => errors.push(error.message));
      page.on('console', message => { if (message.type() === 'error') errors.push(message.text()); });
      page.on('response', response => { if (response.status() >= 400) errors.push(`${response.status()} ${response.url()}`); });
      await page.goto(process.env.GAME_URL || 'http://127.0.0.1:5185/');
      await page.waitForFunction(() => {
        const gm = globalThis.cc?.director?.getScene()?.getComponentsInChildren('GameManager')[0];
        if (gm?.hud?.router?.activeName !== 'home') return false;
        globalThis.qaGame = gm;
        return true;
      }, null, { timeout: 30000 });
      await page.waitForTimeout(400);
      if (width === 390 && theme === 'fruit') {
        fs.mkdirSync(path.join(root, 'audit'), { recursive: true });
        await page.screenshot({ path: path.join(root, 'work/audits/reference-home.png') });
      }
      const cta = await page.evaluate(() => {
        const n = qaGame.hud.homeScreen.ctaHit;
        const camera = cc.director.getScene().getComponentsInChildren(cc.Camera).find(c => c.enabledInHierarchy && (c.visibility & n.layer));
        const p = camera.worldToScreen(n.worldPosition);
        const canvas = document.querySelector('canvas'), r = canvas.getBoundingClientRect();
        return { x: r.x+p.x/canvas.width*r.width, y: r.y+(canvas.height-p.y)/canvas.height*r.height };
      });
      await page.mouse.click(cta.x, cta.y);
      await page.waitForFunction(() => qaGame.playing && qaGame.totalCount > 0 && qaGame.node.getComponentsInChildren('ItemTag').length === qaGame.totalCount, null, { timeout: 30000 });
      await page.waitForTimeout(2500);
      const initial = await page.evaluate(id => {
        const tags = qaGame.node.getComponentsInChildren('ItemTag');
        const target = tags.find(t => t.id === id);
        const renderers = target.node.getComponentsInChildren('cc.MeshRenderer');
        const wall = qaGame.boundary.wall;
        return {
          physics: qaGame.jolt.isReady,
          total: tags.length,
          parts: renderers.map(m => m.node.name),
          containerParts: qaGame.sceneRoot.getComponentsInChildren('cc.MeshRenderer').map(m => m.node.name),
          contained: tags.every(t => {
            const p = t.node.worldPosition;
            return [p.x,p.y,p.z].every(Number.isFinite) && p.y > -.5 && Math.abs(p.x-wall.cx) < wall.halfX+.25 && Math.abs(p.z-wall.cz) < wall.halfZ+.25;
          }),
        };
      }, id);
      assert(initial.physics && initial.contained);
      for (const part of parts) assert(initial.parts.includes(part), `Runtime missing ${id}/${part}: ${JSON.stringify(initial)}`);
      if (theme === 'fruit') for (const part of ['wooden-shell', 'rolled-rim', 'woven-floor', 'brass-fasteners']) assert(initial.containerParts.includes(part), `Runtime missing basket/${part}`);
      const dirs = [path.join(root, 'work/audits/model-quality', `${id}-v2`, 'in-game')];
      if (theme === 'fruit') dirs.push(path.join(root, 'work/audits/model-quality/basket_redwood-v2/in-game'));
      async function screenshot(stage) {
        if (width !== 390) return;
        for (const dir of dirs) {
          fs.mkdirSync(dir, { recursive: true });
          await page.screenshot({ path: path.join(dir, `${stage}.png`) });
        }
      }
      await screenshot('playing');
      const click = await page.evaluate(id => {
        const canvas = document.querySelector('canvas'), rect = canvas.getBoundingClientRect();
        for (const t of qaGame.node.getComponentsInChildren('ItemTag').filter(t => t.id === id && !t.frozen)) {
          const p = qaGame.cam.worldToScreen(t.node.worldPosition);
          for (const dx of [0,-8,8,-16,16]) for (const dy of [0,-8,8,-16,16]) {
            if (qaGame.hitTestAt(p.x+dx, p.y+dy) !== t) continue;
            return { x: rect.x+(p.x+dx)/canvas.width*rect.width, y: rect.y+(canvas.height-p.y-dy)/canvas.height*rect.height };
          }
        }
        return null;
      }, id);
      assert(click, `No exposed ${id} found`);
      await page.mouse.click(click.x, click.y);
      await page.waitForFunction(id => qaGame.tray.entries.length === 1 && qaGame.tray.entries[0].id === id, id);
      await page.waitForTimeout(500);
      const slotParts = await page.evaluate(() => qaGame.tray.entries[0].node.getComponentsInChildren('cc.MeshRenderer').map(m => m.node.name));
      for (const part of parts) assert(slotParts.includes(part), `Slot missing ${part}`);
      await screenshot('slot');

      // Freeze one additional instance to cover new bounds, shell, rejection, and thaw on match.
      assert.equal(await page.evaluate(id => {
        const tag = qaGame.node.getComponentsInChildren('ItemTag').find(t => t.id === id && !t.picked);
        globalThis.qaFrozen = tag;
        tag.frozen = true;
        qaGame.addIceShell(tag.node, tag);
        qaGame.frozenTags.push(tag);
        qaGame.pick(tag.node, tag);
        return !tag.picked && !!tag.iceNode && qaGame.tray.count === 1;
      }, id), true);
      await page.waitForTimeout(250);
      await screenshot('frozen');
      const beforeRemoved = await page.evaluate(() => qaGame.removedCount);
      for (let n=0; n<2; n++) {
        await page.evaluate(id => {
          const t = qaGame.node.getComponentsInChildren('ItemTag').find(t => t.id === id && !t.picked && !t.frozen);
          if (!t) throw new Error('Missing match partner');
          qaGame.pick(t.node, t);
        }, id);
        await page.waitForTimeout(450);
      }
      await page.waitForTimeout(400);
      const final = await page.evaluate(() => ({ removed: qaGame.removedCount, tray: qaGame.tray.count, thawed: !qaFrozen.frozen && !qaFrozen.iceNode, valid: qaFrozen.node.isValid, score: qaGame.score }));
      assert.equal(final.removed, beforeRemoved+3);
      assert.equal(final.tray, 0);
      assert(final.thawed && final.valid);
      await screenshot('matched');
      assert.deepEqual(errors, []);
      results.push({ theme, id, width, height, initial, slotParts, final, errors, status: 'passed' });
      console.log(`PASS ${id} ${width}x${height}: new meshes, containment, mouse pick, slot, controlled ice, match and thaw`);
      await context.close();
    }
  } finally {
    const dir = path.join(root, 'work/audits/runtime');
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, 'model-refresh.json'), JSON.stringify(results, null, 2));
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode=1; });
