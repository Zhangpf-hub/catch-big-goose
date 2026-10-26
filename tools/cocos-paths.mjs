import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const version = JSON.parse(readFileSync(join(root, 'reference-projects/catch-big-goose-cocos/package.json'), 'utf8')).creator.version;

export function findCreator() {
  const candidates = process.env.COCOS_CREATOR ? [process.env.COCOS_CREATOR] : [
    join(process.env.ProgramData || 'C:/ProgramData', 'cocos/editors/Creator', version, 'CocosCreator.exe'),
    `/Applications/Cocos/Creator/${version}/CocosCreator.app/Contents/MacOS/CocosCreator`,
  ];
  const path = candidates.find(path => existsSync(path));
  if (!path) throw new Error(`找不到 Cocos Creator ${version}；请设置 COCOS_CREATOR 为编辑器可执行文件的完整路径。`);
  return resolve(path);
}

export function findTypeScript() {
  if (process.env.TSC_PATH) {
    const path = resolve(process.env.TSC_PATH);
    if (!existsSync(path)) throw new Error(`TSC_PATH 不存在：${path}`);
    return path;
  }
  const local = join(root, 'node_modules/typescript/lib/tsc.js');
  if (existsSync(local)) return local;
  const creator = findCreator();
  const resources = process.platform === 'darwin'
    ? resolve(dirname(creator), '../Resources') : join(dirname(creator), 'resources');
  const path = join(resources, 'app.asar.unpacked/node_modules/typescript/lib/tsc.js');
  if (!existsSync(path)) throw new Error(`找不到 TypeScript：${path}；请设置 TSC_PATH。`);
  return path;
}
