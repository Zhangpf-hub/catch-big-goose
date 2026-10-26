// Build a snapshot when the user's open Creator owns the source project's logs/cache.
import fs from 'node:fs';
import path from 'node:path';
import { randomUUID } from 'node:crypto';
import { spawn } from 'node:child_process';
import { root, findCreator } from './cocos-paths.mjs';
import { inspectBuildLog } from './cocos-build-log.mjs';
import { syncPromoVideos, promoFiles } from './sync-promo-videos.mjs';

const source = path.join(root, 'reference-projects/catch-big-goose-cocos');
const stage = path.join(root, 'work/electronics-build-20261021');
const build = path.join(stage, 'build/web-mobile');
const live = path.join(source, 'build/web-mobile');
for (const directory of [stage, build, live]) {
  const relative = path.relative(root, path.resolve(directory));
  if (relative.startsWith('..') || path.isAbsolute(relative)) throw new Error('Build path escaped project');
}
fs.mkdirSync(stage, { recursive: true });
for (const entry of ['assets', 'settings', 'build-templates', 'preview-template']) {
  fs.cpSync(path.join(source, entry), path.join(stage, entry), { recursive: true, force: true,
    filter: item => path.basename(item) !== 'video' });
}
for (const entry of ['tsconfig.json', 'tsconfig.check.json', 'package.json', 'package-lock.json']) {
  fs.copyFileSync(path.join(source, entry), path.join(stage, entry));
}
const manifest = JSON.parse(fs.readFileSync(path.join(stage, 'package.json'), 'utf8'));
manifest.uuid = randomUUID();
fs.writeFileSync(path.join(stage, 'package.json'), JSON.stringify(manifest, null, 2));
if (!fs.existsSync(path.join(stage, 'node_modules'))) fs.symlinkSync(path.join(source, 'node_modules'), path.join(stage, 'node_modules'), 'junction');
const logPath = path.join(stage, 'build.log');
const fd = fs.openSync(logPath, 'w');
console.log('Building isolated snapshot; the open source editor stays available.');
const status = await new Promise((resolve, reject) => {
  const child = spawn(findCreator(), ['--project', stage, '--build',
    'platform=web-mobile;debug=false;sourceMaps=false;md5Cache=false;nativeCodeBundleMode=wasm;buildPath=project://build;outputName=web-mobile'],
    { cwd: root, windowsHide: true, stdio: ['ignore', fd, fd] });
  child.once('error', reject); child.once('close', resolve);
});
fs.closeSync(fd);
const log = fs.readFileSync(logPath, 'utf8');
const { errors } = inspectBuildLog(log);
if (![0, 36].includes(status) || !log.includes('build Task (web-mobile) Finished') || errors.length) {
  throw new Error(`Isolated build failed (${status}): ${errors.join('\n')}\n${logPath}`);
}
if (!fs.readFileSync(path.join(build, 'assets/main/index.js'), 'utf8').includes('数码工坊')) throw new Error('Theme missing from built game');
for (const flag of ['"debug":false', '"sourceMaps":false', '"nativeCodeBundleMode":"wasm"', '"md5Cache":false']) {
  if (!log.includes(flag)) throw new Error(`Missing build setting ${flag}`);
}
let bytes = 0;
function walk(directory) {
  for (const file of fs.readdirSync(directory, { withFileTypes: true })) {
    const target = path.join(directory, file.name);
    if (file.isDirectory()) walk(target);
    else if (!promoFiles.includes(file.name)) {
      if (file.name.endsWith('.map')) throw new Error('Release contains source maps');
      bytes += fs.statSync(target).size;
    }
  }
}
walk(build);
if (bytes > 20 * 1024 * 1024) throw new Error(`Release ${(bytes / 1024 / 1024).toFixed(3)} MiB exceeds 20 MiB`);
syncPromoVideos(build);
// A verified snapshot replaces only this project's generated release directory.
if (path.resolve(live) !== path.join(root, 'reference-projects/catch-big-goose-cocos/build/web-mobile')) throw new Error('Unexpected release path');
fs.rmSync(live, { recursive: true, force: true });
fs.cpSync(build, live, { recursive: true });
fs.writeFileSync(path.join(root, 'source-assets/models/candidates/electronics-v2/qa/build.json'),
  JSON.stringify({ status: 'passed', bytes, mib: bytes / 1024 / 1024, creatorExitCode: status,
    isolatedSnapshot: true, logPath, theme: 'electronics', sourceEditorUnchanged: true }, null, 2));
console.log(`PASS release ${(bytes / 1024 / 1024).toFixed(3)} MiB; published to local preview.`);
