import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { runInNewContext } from 'node:vm';
import { findTypeScript, root } from '../../tools/cocos-paths.mjs';

const require = createRequire(import.meta.url);
const ts = require(join(dirname(findTypeScript()), 'typescript.js'));

// 运行真实 TypeScript 模块，仅替换 Cocos 的平台接口；不依赖编辑器或浏览器启动。
export function loadCore(name, { cc = {}, globals = {}, storage = new Map(), modules = {} } = {}) {
  const exports = {};
  const source = readFileSync(join(root, 'reference-projects/catch-big-goose-cocos/assets/scripts/core', `${name}.ts`), 'utf8');
  const { outputText } = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2017 },
  });
  runInNewContext(outputText, {
    exports,
    require: id => {
      if (id === 'cc') return {
        sys: { localStorage: {
          getItem: key => storage.get(key) ?? null,
          setItem: (key, value) => storage.set(key, value),
        } },
        ...cc,
      };
      if (id === './ModelManifest') return { MODEL_PREFAB_UUID: {} };
      if (Object.hasOwn(modules, id)) return modules[id];
      throw new Error(`Unexpected import: ${id}`);
    },
    console, setTimeout, clearTimeout, AbortController,
    ...globals,
  }, { filename: `${name}.ts` });
  return { ...exports, storage };
}

export const plain = value => JSON.parse(JSON.stringify(value));
