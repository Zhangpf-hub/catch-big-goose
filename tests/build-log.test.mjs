import assert from 'node:assert/strict';
import test from 'node:test';
import { inspectBuildLog } from '../tools/cocos-build-log.mjs';

const timeout = '[information] Query information: Error: GET Timeout: https://creator-api.cocos.com/information_url';
const cache = 'Error: Init information cache failed!';
const start = 'Start enter command build with options {"platform":"web-mobile"}';

test('资讯接口的明确启动超时只作为警告，不阻断本地构建', () => {
  assert.deepEqual(inspectBuildLog([timeout, cache, start].join('\r\n')), {
    errors: [], startupWarnings: [timeout, cache],
  });
});

test('启动阶段其他错误及构建阶段错误仍然失败', () => {
  const unexpected = 'Error: Failed to import scene';
  assert.deepEqual(inspectBuildLog([unexpected, start, timeout, cache].join('\n')).errors,
    [unexpected, timeout, cache]);
});

test('缺少构建开始标记时不豁免资讯错误', () => {
  assert.deepEqual(inspectBuildLog([timeout, cache].join('\n')).errors, [timeout, cache]);
});
