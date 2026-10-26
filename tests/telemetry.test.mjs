import assert from 'node:assert/strict';
import test from 'node:test';
import { loadCore } from './helpers/load-core.mjs';

function harness(extraGlobals = {}) {
  const requests = [];
  const result = loadCore('Telemetry', { globals: {
    __GOOSE_CONFIG: { telemetryEndpoint: 'https://example.invalid/events' },
    fetch: (_url, options) => new Promise((resolve, reject) => requests.push({ options, resolve, reject })),
    ...extraGlobals,
  } });
  return { ...result, requests, queue: () => JSON.parse(result.storage.get('goose_telemetry_v1') || '[]') };
}

test('上报期间新增事件保留；只删除本次已确认发送的事件', async () => {
  const { Telemetry, requests, queue } = harness();
  Telemetry.track('before');
  const sending = Telemetry.flush();
  Telemetry.track('during');
  await Telemetry.flush();
  assert.equal(requests.length, 1);
  requests[0].resolve({ ok: true });
  await sending;
  assert.deepEqual(queue().map(e => e.name), ['during']);
  const next = Telemetry.flush();
  requests[1].resolve({ ok: true });
  await next;
  assert.deepEqual(queue(), []);
});

test('发送期间队列溢出仍保留最新 200 条，旧请求成功不能清空新批次', async () => {
  const { Telemetry, requests, queue } = harness();
  Telemetry.track('old');
  const sending = Telemetry.flush();
  for (let i = 0; i < 205; i++) Telemetry.track('new', { i });
  requests[0].resolve({ ok: true });
  await sending;
  assert.equal(queue().length, 200);
  assert.equal(queue()[0].props.i, 5);
  assert.equal(queue()[199].props.i, 204);
});

test('网络异常和非 2xx 响应保留队列，并允许下一次重试', async () => {
  const { Telemetry, requests, queue } = harness();
  Telemetry.track('pending');
  for (let i = 0; i < 2; i++) {
    const sending = Telemetry.flush();
    if (i === 0) requests[i].reject(new Error('offline'));
    else requests[i].resolve({ ok: false });
    await sending;
    assert.equal(queue().length, 1);
  }
  const sending = Telemetry.flush();
  requests[2].resolve({ ok: true });
  await sending;
  assert.equal(queue().length, 0);
});

test('默认不上报，历史队列可发送且线上事件格式不增加内部字段', async () => {
  const { Telemetry, requests, storage } = harness({ __GOOSE_CONFIG: {} });
  for (let i = 0; i < 12; i++) Telemetry.track('local');
  await Telemetry.flush();
  assert.equal(requests.length, 0);
  const active = harness();
  active.storage.set('goose_telemetry_v1', JSON.stringify(
    JSON.parse(storage.get('goose_telemetry_v1')).map(({ queueId, ...event }) => event)));
  const sending = active.Telemetry.flush();
  const event = JSON.parse(active.requests[0].options.body).events[0];
  assert.deepEqual(Object.keys(event).sort(), ['at', 'name', 'props', 'sessionId']);
  active.requests[0].resolve({ ok: true });
  await sending;
  assert.equal(active.queue().length, 0);
});
