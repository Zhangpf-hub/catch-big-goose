import assert from 'node:assert/strict';
import test from 'node:test';
import { loadCore, plain } from './helpers/load-core.mjs';

test('损坏或非对象成绩存档不阻断读取、写入和旧版迁移', () => {
  for (const value of ['broken', 'null', '42', 'true', '"text"', '[]']) {
    const { SaveData, storage } = loadCore('SaveData');
    storage.set('goose_best_v2', value);
    assert.deepEqual(plain(SaveData.getBest('fruit')), {});
    const best = { 0: { stars: 3, progress: 100, score: 800 } };
    assert.doesNotThrow(() => SaveData.setBest('fruit', best));
    assert.deepEqual(plain(SaveData.getBest('fruit')), best);
  }
});

test('成绩过滤非法星数与进度，保留其他有效关卡和旧版无分数字段', () => {
  const { SaveData, storage } = loadCore('SaveData');
  storage.set('goose_best_v2', JSON.stringify({ fruit: {
    0: { stars: 3, progress: 100 },
    1: { stars: -1, progress: 50 },
    2: { stars: 2, progress: 101 },
    3: { stars: 2, progress: 70, score: 'broken' },
    4: null,
  } }));
  assert.deepEqual(plain(SaveData.getBest('fruit')), {
    0: { stars: 3, progress: 100 }, 3: { stars: 2, progress: 70 },
  });
});

test('旧成绩只迁移到首个主题，随后按主题隔离', () => {
  const { SaveData, storage } = loadCore('SaveData');
  const old = { 0: { stars: 1, progress: 55 } };
  storage.set('goose_best_v1', JSON.stringify(old));
  assert.deepEqual(plain(SaveData.getBest('fruit')), old);
  assert.deepEqual(plain(SaveData.getBest('farm')), {});
  SaveData.setBest('farm', { 1: { stars: 3, progress: 100, score: 1000 } });
  assert.deepEqual(plain(SaveData.getBest('fruit')), old);
  assert.equal(SaveData.getBest('farm')[1].score, 1000);
});

test('每日次数和关卡索引拒绝负数、小数、字符串与非有限值', () => {
  const { SaveData, storage } = loadCore('SaveData');
  for (const value of ['-1', '0.5', '"2"', '1e400', 'null']) {
    storage.set('goose_level_v1', `{"date":"${SaveData.todayKey()}","index":${value}}`);
    storage.set('goose_daily_v1', `{"date":"${SaveData.todayKey()}","left":${value}}`);
    assert.equal(SaveData.getLevel(), null);
    assert.equal(SaveData.getDaily(3), 3);
  }
  SaveData.setDaily(0);
  SaveData.setLevel(2);
  assert.equal(SaveData.getDaily(3), 0);
  assert.equal(SaveData.getLevel(), 2);
  storage.set('goose_daily_v1', '{"date":"2000-1-1","left":0}');
  assert.equal(SaveData.getDaily(3), 3);
});

test('道具逐项容错，不让字符串拼接、负库存或额外字段进入玩法', () => {
  const { SaveData, storage } = loadCore('SaveData');
  const fallback = { remove: 0, magnet: 0, shuffle: 1 };
  storage.set('goose_props_v1', '{"remove":4,"magnet":"5","shuffle":-1,"extra":99}');
  assert.deepEqual(plain(SaveData.getProps(fallback)), { remove: 4, magnet: 0, shuffle: 1 });
  assert.deepEqual(fallback, { remove: 0, magnet: 0, shuffle: 1 });
  storage.set('goose_props_v1', '[]');
  assert.deepEqual(plain(SaveData.getProps(fallback)), fallback);
});

test('浏览器禁用存储时读取和写入都安全降级', () => {
  const { SaveData } = loadCore('SaveData', { cc: { sys: { localStorage: {
    getItem() { throw new Error('blocked'); }, setItem() { throw new Error('blocked'); },
  } } } });
  assert.equal(SaveData.getDaily(3), 3);
  assert.equal(SaveData.getLevel(), null);
  assert.deepEqual(plain(SaveData.getBest('fruit')), {});
  assert.doesNotThrow(() => SaveData.setBest('fruit', { 0: { stars: 3, progress: 100 } }));
});

test('GM 默认关闭，只接受明确开启值且开关独立持久化', () => {
  const { SaveData, storage } = loadCore('SaveData');
  assert.equal(SaveData.getGM(), false);
  SaveData.setGM(true);
  assert.equal(SaveData.getGM(), true);
  assert.equal(storage.get('goose_gm_v1'), '1');
  SaveData.setGM(false);
  assert.equal(SaveData.getGM(), false);
  storage.set('goose_gm_v1', 'unexpected');
  assert.equal(SaveData.getGM(), false);
});
