import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const source = fs.readFileSync(path.join(root, 'projects/catch-big-goose-unity/Assets/Plugins/WebGL/GooseWeChatMedia.jslib'), 'utf8');
const checks = [];
function run(options = {}) {
  const library = {}, replies = [], reads = [], writes = [];
  const fileSystem = {
    readFileSync(name) {
      reads.push(name);
      if (options.badManifest) throw Error('manifest missing');
      if (name.endsWith('manifest.json')) return JSON.stringify({ files: [{ name: 'clip.mp4', sha256: 'abc123', bytes:3 }] });
      throw Error('Video bytes must not be read into JS memory');
    },
    mkdirSync() {},
    accessSync() { if (!options.cached) throw Error('not cached'); },
    statSync() { return {size:options.badSize?1:3}; },
    unlinkSync(name) { reads.push('remove-invalid:'+name); },
    copyFile(request) {
      writes.push(request);
      assert.equal(request.srcPath,'media/clip.mp4');assert.equal(request.destPath,'wxfile://usr/goose-media/abc123.mp4');
      if (options.writeFail) request.fail({ errMsg: 'disk full' }); else request.success();
    }
  };
  const context = {
    LibraryManager: { library }, mergeInto: Object.assign,
    UTF8ToString: () => 'GooseGame',
    SendMessage: (receiver, method, payload) => replies.push({ receiver, method, ...JSON.parse(payload) }),
  };
  if (!options.noWx) context.wx = {
    env: { USER_DATA_PATH: 'wxfile://usr' }, getFileSystemManager: () => fileSystem,
    loadSubpackage(request) {
      assert.equal(request.name, 'goose-media');
      if (options.loadFail) request.fail({ errMsg: 'offline' }); else request.success();
    }
  };
  vm.runInNewContext(source, context);
  library.GoosePrepareWechatVideo(options.index ?? 0, 17, 0);
  assert.equal(replies.length, 1);
  assert.equal(replies[0].requestId, 17);
  assert.equal(replies[0].receiver, 'GooseGame');
  return { reply: replies[0], reads, writes };
}
let result = run();
assert.equal(result.reply.path, 'wxfile://usr/goose-media/abc123.mp4');
assert.equal(result.reply.error, ''); assert.equal(result.writes.length, 1);
checks.push('Native file copy caches video without reading MP4 bytes into JS');
result = run({ cached: true }); assert.equal(result.writes.length, 0); assert.equal(result.reads.length, 1);
checks.push('Content-hash cache reused without copying video again');
result=run({cached:true,badSize:true});assert.equal(result.writes.length,1);checks.push('Partial cached files are replaced before decoding');
for (const [options, expected] of [
  [{ loadFail: true }, 'offline'], [{ writeFail: true }, 'disk full'],
  [{ badManifest: true }, 'manifest missing'], [{ index: 2 }, 'Video index missing'],
  [{ noWx: true }, 'Not running in WeChat']
]) {
  result = run(options); assert.equal(result.reply.path, ''); assert.ok(result.reply.error.includes(expected));
  checks.push('Failure returns no playable path: ' + expected);
}
const report = { passed: true, scope: 'Local bridge unit tests with mocked WeChat filesystem; not device acceptance', checks };
fs.writeFileSync(path.join(root, 'work/wechat-integration/media-bridge-tests.json'), JSON.stringify(report, null, 2));
console.log(`${checks.length} WeChat media bridge checks passed`);
