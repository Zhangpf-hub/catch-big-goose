/**
 * 从 node_modules 生成一份**浏览器专用**的 Jolt 胶水脚本，供 Cocos 的 assets 直接 import。
 *
 * 为什么要生成而不是直接 import 'jolt-physics'：
 *
 *   jolt-physics 的三个入口（wasm-compat / wasm / asm）在开头都有同一段 Node 兼容分支：
 *       var aa = globalThis.process?.versions?.node && globalThis.process?.type != "renderer";
 *       if (aa) { let {createRequire:a} = await import("node:module"); var ba = a(import.meta.url) }
 *   浏览器里 aa 恒为 false、这段是死代码，但它是**静态可见的** import 说明符。
 *   vite 会自动把 node: 协议的内建模块 externalize 掉，Cocos 的打包器不会——它当成
 *   文件去磁盘上找，于是构建挂在「打包脚本」阶段：
 *       Could not load node:module ... ENOENT: no such file or directory, open 'node:module'
 *   而 Cocos 3.8 的构建管线没有暴露 external / alias 之类的逃生口。
 *
 * 选 wasm-compat 而不是 wasm 入口：前者把 .wasm 以 base64 内联在 JS 里，不需要额外托管
 * 二进制文件，正好绕开 Cocos 资源管线对 .wasm 的处理（它会当成未知资源或做 md5 改名，
 * 而胶水脚本是按相对路径 fetch 的，改名就找不到了）。代价是体积略大、少了流式编译。
 *
 * 为什么产物放 build-templates 而不是 assets：
 *
 *   放进 assets 就会被 Cocos 的脚本管线接管，而那条管线会用 Babel 按项目 target 做转换
 *   （本工程还开着 polyfills.asyncFunctions，async 函数要降级成 regenerator）。3MB 的
 *   emscripten 胶水经不起这种改写——实测构建能过，但运行时引擎初始化停在加载项目脚本那步、
 *   不报错也不继续（cc.game._inited 一直是 false）。
 *   另外 assets 下的 .js 会被当成 CJS，`export default` 直接报 "Unexpected export statement
 *   in CJS module"；改成 .ts 能过打包，但就落进上面那个 Babel 陷阱。
 *
 *   build-templates/<平台>/ 的内容是**原样拷贝**到构建产物根目录的，不进任何管线。
 *   配合 JoltLoader 里的原生动态 import（见那边的说明），胶水完全不受 Cocos 影响，
 *   还顺带从主包里挪了出去、变成按需加载。
 *
 * 改动只有两处，都在上面那段死代码里，不触碰任何实际执行路径：
 *   1. 去掉 `await import("node:module")`；
 *   2. `import.meta.url` → 空串（Cocos 的输出格式不保证支持 import.meta）。
 * 脚本跑完会自检：产物里不能再出现 node: 说明符或 import.meta，且必须仍以默认导出结尾。
 *
 * 用法（升级 jolt-physics 之后必须重跑）：
 *   node tools/art/gen-jolt-glue.mjs
 */

import { readFileSync, writeFileSync, mkdirSync, copyFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const repo = join(here, '..');
const SRC = join(repo, 'reference-projects/catch-big-goose-cocos/node_modules/jolt-physics/dist/jolt-physics.wasm-compat.js');
const OUT_DIR = join(repo, 'reference-projects/catch-big-goose-cocos/build-templates/web-mobile');
const OUT = join(OUT_DIR, 'jolt-glue.js');

let code = readFileSync(SRC, 'utf8');
const before = code.length;

// 1) 干掉 Node 分支里的动态 import。整个 if 块是死代码，把绑定换成 null 即可保持语法完整。
const nodeImport = /let\s*\{\s*createRequire\s*:\s*(\w+)\s*\}\s*=\s*await\s+import\("node:module"\)/;
if (!nodeImport.test(code)) {
    console.error('❌ 没找到 createRequire 那段 Node 分支——jolt-physics 的胶水结构变了，'
        + '请重新核对本脚本的假设，不要盲目放行。');
    process.exit(1);
}
code = code.replace(nodeImport, 'let $1=null');

// 2) import.meta.url → ""。它只在上面那段 Node 分支和一个被 try/catch 包住的
//    new URL(".", da) 里用到，浏览器路径不依赖它。
code = code.replaceAll('import.meta.url', '""');

const banner = `// ⚠️ 本文件由 tools/art/gen-jolt-glue.mjs 从 node_modules/jolt-physics 生成，**请勿手改**。
// 源：jolt-physics/dist/jolt-physics.wasm-compat.js（wasm 以 base64 内联，无需额外托管 .wasm）
// 改动：剥掉 Node 兼容分支里的 await import("node:module") 与 import.meta.url，
//       否则 Cocos 的打包器会试图去磁盘上找 "node:module" 并直接构建失败。
// 升级 jolt-physics 后重跑：node tools/art/gen-jolt-glue.mjs

`;

// 自检：宁可构建前失败，也不要让一个偷偷坏掉的胶水进到运行时。
// 只查**打包器能静态看到**的说明符：import("node:x") 与 from "node:x"。
// 剩下的 "node:fs" / "node:path" / "node:url" 是那段死代码里传给 createRequire 结果的
// 字符串**参数**（ba("node:fs")），rollup 根本不会去解析它们，留着无害——一并删反而
// 要动执行路径、徒增出错面。
const staticNodeImport = /(?:\bimport\s*\(\s*|\bfrom\s*)["']node:[a-z]+["']/;
const checks = [
    ['仍含静态 node: import', staticNodeImport.test(code)],
    ['仍含 import.meta', code.includes('import.meta')],
    ['缺少默认导出', !code.trimEnd().endsWith('export default Jolt;')],
];
const failed = checks.filter(([, bad]) => bad).map(([name]) => name);
if (failed.length) {
    console.error(`❌ 自检不通过：${failed.join('、')}`);
    process.exit(1);
}

mkdirSync(OUT_DIR, { recursive: true });
writeFileSync(OUT, banner + code);
const previewDirectory = join(repo, 'reference-projects/catch-big-goose-cocos/preview-template');
mkdirSync(previewDirectory, { recursive: true });
copyFileSync(OUT, join(previewDirectory, 'jolt-glue.js'));
console.log(`✅ 生成 reference-projects/catch-big-goose-cocos/build-templates/web-mobile/jolt-glue.js（${(before / 1048576).toFixed(2)} MB）`);
console.log('✅ 已同步到 reference-projects/catch-big-goose-cocos/preview-template/jolt-glue.js，支持编辑器浏览器预览');
