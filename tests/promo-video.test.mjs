import assert from 'node:assert/strict';
import test from 'node:test';
import { loadCore, plain } from './helpers/load-core.mjs';
import { promoFiles } from '../tools/sync-promo-videos.mjs';

function playerFixture() {
  const nodes = [];
  const timers = new Map();
  class Element extends EventTarget {
    style = {};
    currentTime = 0;
    duration = 4;
    seeking = false;
    children = [];
    setAttribute() {}
    removeAttribute() {}
    append(...children) { this.children.push(...children); }
    appendChild(child) { this.children.push(child); }
    remove() { this.removed = true; }
    play() { this.paused = false; return Promise.resolve(); }
    pause() { this.paused = true; }
    load() {}
    fire(name) { this.dispatchEvent(new Event(name)); }
  }
  const document = new Element();
  document.body = new Element();
  document.baseURI = 'https://game.example/subfolder/index.html';
  document.hidden = false;
  document.createElement = tag => {
    const node = new Element();
    node.tag = tag;
    nodes.push(node);
    return node;
  };
  const { PromoVideo, PROMO_FILES } = loadCore('PromoVideo', { globals: {
    document, URL,
    setTimeout: callback => { const token = {}; timers.set(token, callback); return token; },
    clearTimeout: token => timers.delete(token),
  } });
  const player = new PromoVideo();
  return {
    player, document, nodes, timers, files: plain(PROMO_FILES),
    video: () => nodes.findLast(node => node.tag === 'video'),
    complete: () => {
      const video = nodes.findLast(node => node.tag === 'video');
      for (let second = 1; second <= 4; second++) {
        video.currentTime = second;
        video.fire('timeupdate');
      }
      video.fire('ended');
    },
  };
}

test('宣传片完整观看只完成一次，清理视频、遮罩和计时器', async () => {
  const fixture = playerFixture();
  assert.deepEqual(fixture.files, promoFiles);
  const result = fixture.player.play('获得随机道具');
  assert.equal(fixture.player.active, true);
  assert.equal(fixture.document.body.children[0].children[0].textContent, '关闭宣传片');
  assert.equal(fixture.document.body.children[0].children[1].textContent, '完整观看获得随机道具');
  assert.ok(promoFiles.some(name => fixture.video().src === `https://game.example/subfolder/video/${name}`));
  fixture.complete();
  fixture.video().fire('error');
  fixture.player.close();
  assert.equal(await result, 'completed');
  assert.equal(fixture.player.active, false);
  assert.equal(fixture.timers.size, 0);
  assert.equal(fixture.document.body.children[0].removed, true);
});

test('提前关闭不奖励，旧完成回调不污染下一次播放', async () => {
  const fixture = playerFixture();
  const first = fixture.player.play('获得随机道具');
  const oldVideo = fixture.video();
  fixture.player.close();
  assert.equal(await first, 'closed');
  const next = fixture.player.play('复活');
  oldVideo.fire('ended');
  assert.equal(fixture.player.active, true);
  fixture.complete();
  assert.equal(await next, 'completed');
});

test('重复请求不创建第二个播放器，快进和伪完成不奖励', async () => {
  const fixture = playerFixture();
  const first = fixture.player.play('复活');
  assert.equal(await fixture.player.play('复活'), 'error');
  assert.equal(fixture.nodes.filter(node => node.tag === 'video').length, 1);
  fixture.video().currentTime = 4;
  fixture.video().fire('seeking');
  assert.equal(fixture.video().currentTime, 0);
  fixture.video().fire('ended');
  assert.equal(await first, 'error');
});

test('播放错误与加载超时退出，不产生完成结果', async () => {
  for (const expected of ['error', 'timeout']) {
    const fixture = playerFixture();
    const result = fixture.player.play('复活');
    if (expected === 'error') fixture.video().fire('error');
    else [...fixture.timers.values()][0]();
    assert.equal(await result, expected);
    assert.equal(fixture.player.active, false);
    assert.equal(fixture.timers.size, 0);
  }
});

test('切后台暂停并停止加载超时，返回手动继续', async () => {
  const fixture = playerFixture();
  const result = fixture.player.play('复活');
  fixture.document.hidden = true;
  fixture.document.fire('visibilitychange');
  assert.equal(fixture.video().paused, true);
  assert.equal(fixture.timers.size, 0);
  fixture.complete();
  assert.equal(fixture.player.active, true);
  fixture.document.hidden = false;
  fixture.document.fire('visibilitychange');
  const resume = fixture.nodes.filter(node => node.tag === 'button')[1];
  assert.equal(resume.hidden, false);
  resume.onclick();
  fixture.complete();
  assert.equal(await result, 'completed');
});

test('浏览器禁止自动播放时允许手动重试，随后正常完成', async () => {
  const fixture = playerFixture();
  const create = fixture.document.createElement;
  fixture.document.createElement = tag => {
    const element = create(tag);
    if (tag === 'video') element.play = () => Promise.reject(new Error('gesture required'));
    return element;
  };
  const result = fixture.player.play('复活');
  await Promise.resolve();
  const resume = fixture.nodes.filter(node => node.tag === 'button')[1];
  assert.equal(resume.hidden, false);
  fixture.video().play = () => Promise.resolve();
  resume.onclick();
  fixture.complete();
  assert.equal(await result, 'completed');
});

function gameFixture() {
  const events = [];
  const modules = Object.fromEntries([
    'DebugViz', 'SceneSkin', 'ContainerBoundary', 'SlotTray', 'ItemTag', 'PrefabCache',
    'JoltWorld', 'HudUI', 'SceneBackground', 'AudioMan', 'ui/UIKit', 'ui/HomeScreen', 'PromoVideo',
  ].map(name => [`./${name}`, {}]));
  modules['./Telemetry'] = { Telemetry: { track: (...args) => events.push(args) } };
  modules['./SaveData'] = { SaveData: { setLevel() {} } };
  modules['./LevelConfig'] = { LEVELS: [{ timeSec: 100 }], getActiveTheme: () => ({ id: 'fruit' }) };
  const director = { paused: false, isPaused() { return this.paused; }, pause() { this.paused = true; }, resume() { this.paused = false; } };
  const { GameManager } = loadCore('GameManager', {
    modules, globals: { performance, console: { log() {} } },
    cc: {
      Component: class {}, Camera: class {}, Label: class {}, director,
      _decorator: { ccclass: () => value => value, property: (...args) => args.length === 1 ? () => {} : undefined },
    },
  });
  const calls = [];
  const hud = new Proxy({}, { get: (target, key) => (...args) => { calls.push([key, ...args]); } });
  const game = Object.assign(Object.create(GameManager.prototype), {
    playing: true, paused: false, isValid: true, roundId: 'round-one', roundStartedAt: performance.now(),
    level: { timeSec: 100 }, levelIndex: 0, timeLeft: 50.05, promoShown: false,
    timeoutOffered: false, timeoutOfferOpen: false, rescueUsed: false,
    interactionLocked: false, score: 0, removedCount: 0, totalCount: 9, combo: 0, idleTime: 0,
    best: {}, tray: { count: 0 }, hud, audio: { setSuspended() {}, play() {} },
    promoVideo: { active: false, close() {}, play: async () => 'completed' },
    syncFrostMarks() {}, stepPhysics() {}, updateCombo() {}, updateHud() {},
    grantProps: reward => calls.push(['grantProps', plain(reward)]),
    recordBest: () => false, scheduleOnce: callback => callback(),
  });
  return { game, calls, director, events };
}

test('普通对局每局道具各一份，旧累计库存不进入新对局', () => {
  const { game, calls } = gameFixture();
  delete game.grantProps;
  game.propCounts = { remove: 12, magnet: 7, shuffle: 0 };
  game.resetProps();
  assert.deepEqual(plain(game.propCounts), { remove: 1, magnet: 1, shuffle: 1 });
  game.grantProps({ shuffle: 1 });
  assert.equal(game.propCounts.shuffle, 2);
  game.nextRoundBonus = { remove: 1, magnet: 1 };
  game.resetProps();
  assert.deepEqual(plain(game.propCounts), { remove: 2, magnet: 2, shuffle: 1 });
  game.resetProps();
  assert.deepEqual(plain(game.propCounts), { remove: 1, magnet: 1, shuffle: 1 });
  assert.equal(calls.filter(call => call[0] === 'setPropCount').length, 12);
});

test('普通通关奖励仅下一局领取一次，GM 通关不奖励', () => {
  const { game, calls } = gameFixture();
  game.removedCount = game.totalCount;
  game.gameOver(true);
  assert.deepEqual(plain(game.nextRoundBonus), { remove: 1, magnet: 1, shuffle: 1 });
  assert.equal(calls.find(call => call[0] === 'showResult')[1].rewardCount, 3);
  game.resetProps();
  assert.deepEqual(plain(game.propCounts), { remove: 2, magnet: 2, shuffle: 2 });
  game.resetProps();
  assert.deepEqual(plain(game.propCounts), { remove: 1, magnet: 1, shuffle: 1 });

  const gm = gameFixture().game;
  gm.gmUsedThisRound = true;
  gm.removedCount = gm.totalCount;
  gm.gameOver(true);
  assert.equal(gm.nextRoundBonus, undefined);
});

test('半程只出现一次大鹅，暂停和视频期间不消耗倒计时', () => {
  const { game, calls } = gameFixture();
  game.update(0.1);
  game.update(0.1);
  assert.equal(calls.filter(call => call[0] === 'showPromoGoose').length, 1);
  const timeLeft = game.timeLeft;
  game.paused = true;
  game.update(0.1);
  game.paused = false;
  game.promoVideo.active = true;
  game.update(0.1);
  assert.equal(game.timeLeft, timeLeft);
});

test('大鹅完整观看发一个随机道具，关闭或出错均不发奖', async () => {
  for (const result of ['completed', 'closed', 'error', 'timeout']) {
    const { game, calls, director } = gameFixture();
    game.promoVideo.play = async () => {
      assert.equal(game.paused, true);
      assert.equal(director.paused, true);
      return result;
    };
    await game.watchGoosePromo();
    const grants = calls.filter(call => call[0] === 'grantProps');
    assert.equal(grants.length, result === 'completed' ? 1 : 0);
    if (grants.length) {
      const reward = grants[0][1];
      assert.equal(Object.values(reward).reduce((total, count) => total + count, 0), 1);
      assert.ok(['remove', 'magnet', 'shuffle'].includes(Object.keys(reward)[0]));
    }
    assert.equal(game.paused, false);
    assert.equal(director.paused, false);
  }
});

test('首次超时先提示不结算，完成视频加60秒，再次超时直接结算', async () => {
  const { game, calls, events } = gameFixture();
  game.timeLeft = 0;
  game.gameOver(false, '时间到');
  assert.equal(game.timeoutOfferOpen, true);
  assert.equal(game.paused, true);
  assert.equal(calls.filter(call => call[0] === 'grantProps').length, 0);
  assert.equal(events.filter(event => event[0] === 'round_end').length, 0);
  await game.watchRevivePromo();
  assert.equal(game.timeLeft, 60);
  assert.equal(game.playing, true);
  assert.equal(game.paused, false);
  game.timeLeft = 0;
  game.gameOver(false, '时间到');
  assert.equal(game.playing, false);
  assert.equal(calls.filter(call => call[0] === 'showTimeoutOffer').length, 1);
  const result = calls.find(call => call[0] === 'showResult')[1];
  assert.equal(result.rescueText, '');
  assert.equal(events.filter(event => event[0] === 'round_end').length, 1);
});

test('复活视频中途关闭可重试或放弃，不加时也不重复结算', async () => {
  const { game, calls, events } = gameFixture();
  game.timeLeft = 0;
  game.gameOver(false, '时间到');
  game.promoVideo.play = async () => 'closed';
  await game.watchRevivePromo();
  assert.equal(game.timeLeft, 0);
  assert.equal(game.paused, true);
  const offer = calls.filter(call => call[0] === 'showTimeoutOffer').at(-1);
  offer[3]();
  offer[3]();
  assert.equal(game.playing, false);
  assert.equal(events.filter(event => event[0] === 'round_end').length, 1);
});

test('旧对局或已销毁场景的完成回调不发奖，播放器异常会恢复引擎', async () => {
  for (const change of ['round', 'destroy', 'error']) {
    const { game, calls, director } = gameFixture();
    game.promoVideo.play = async () => {
      if (change === 'round') game.roundId = 'round-two';
      if (change === 'destroy') game.isValid = false;
      if (change === 'error') throw new Error('video failed');
      return 'completed';
    };
    await game.watchGoosePromo();
    assert.equal(calls.filter(call => call[0] === 'grantProps').length, 0);
    assert.equal(director.paused, false);
  }
});
