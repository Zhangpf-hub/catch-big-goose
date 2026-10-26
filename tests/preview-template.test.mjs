import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { join } from 'node:path';
import { root } from '../tools/cocos-paths.mjs';

test('编辑器预览包含与发布模板完全一致的 Jolt 胶水', () => {
  const preview = readFileSync(join(root, 'reference-projects/catch-big-goose-cocos/preview-template/jolt-glue.js'));
  const release = readFileSync(join(root, 'reference-projects/catch-big-goose-cocos/build-templates/web-mobile/jolt-glue.js'));
  const digest = content => createHash('sha256').update(content).digest('hex');
  assert.ok(preview.length > 1024 * 1024);
  assert.equal(digest(preview), digest(release));
  assert.ok(preview.toString('utf8').trimEnd().endsWith('export default Jolt;'));
});
