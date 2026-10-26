import assert from 'node:assert/strict';
import test from 'node:test';
import { loadCore, plain } from './helpers/load-core.mjs';

test('重叠批次只加载同一模型一次，已缓存模型不重复加载', async () => {
  const requests = [];
  const { PrefabCache } = loadCore('PrefabCache', { cc: {
    Prefab: class {},
    resources: { load: (path, _type, callback) => requests.push({ path, callback }) },
  } });
  const cache = new PrefabCache();
  const first = cache.loadAll(['apple', 'apple']);
  const second = cache.loadAll(['apple', 'pear']);
  assert.equal(requests.length, 2);
  for (const request of requests) request.callback(null, { name: request.path });
  assert.deepEqual(plain(await first), []);
  assert.deepEqual(plain(await second), []);
  await cache.loadAll(['apple', 'pear']);
  assert.equal(requests.length, 2);
  assert.equal(cache.get('apple').name, 'models/apple/apple');
});

test('加载失败明确返回缺件，随后可重试成功', async () => {
  let failing = true;
  const { PrefabCache } = loadCore('PrefabCache', { cc: {
    Prefab: class {}, resources: { load: (_path, _type, callback) => {
      if (failing) callback(new Error('offline'));
      else callback(null, { name: 'apple' });
    } },
  }, globals: { console: { log() {}, error() {} } } });
  const cache = new PrefabCache();
  assert.deepEqual(plain(await cache.loadAll(['apple'])), ['apple']);
  assert.equal(cache.has('apple'), false);
  failing = false;
  assert.deepEqual(plain(await cache.loadAll(['apple'])), []);
  assert.equal(cache.has('apple'), true);
});
