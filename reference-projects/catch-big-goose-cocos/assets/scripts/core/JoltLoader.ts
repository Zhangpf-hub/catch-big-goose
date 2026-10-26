import type JoltNS from 'jolt-physics';

/**
 * Jolt 的加载入口（Cocos 侧唯一一处碰到胶水脚本的地方）。
 *
 * 胶水脚本**不进 Cocos 的构建管线**：它由 tools/art/gen-jolt-glue.mjs 生成到
 * game/build-templates/web-mobile/jolt-glue.js，构建时原样拷到产物根目录，
 * 运行时用**原生** ESM 动态 import 拉进来。三条理由，每条都是实测撞过的墙：
 *
 *   1. 直接 `import 'jolt-physics'`：胶水里有段 Node 兼容分支 `await import("node:module")`，
 *      浏览器永远走不到，但 Cocos 的打包器会静态解析并去磁盘上找 "node:module"，
 *      构建挂在「打包脚本」阶段。Cocos 3.8 没有 external / alias 之类的逃生口。
 *   2. 把胶水拷进 assets/ 当 .js：Cocos 按 CJS 处理，`export default` 直接报
 *      "Unexpected export statement in CJS module"。
 *   3. 改成 .ts 放 assets/：打包能过，但 Babel 会按项目 target 改写它（本工程还开着
 *      polyfills.asyncFunctions，async 要降级成 regenerator）。3MB 的 emscripten 胶水
 *      经不起这种改写——运行时引擎初始化停在加载项目脚本那步，不报错也不继续
 *      （cc.game._inited 一直是 false）。
 *
 * 用 `new Function` 造动态 import，是为了让说明符对打包器**不可见**：Cocos 的 web-mobile
 * 产物是 SystemJS 格式，写成普通 `import(url)` 会被转成 `System.import(url)`，走进
 * import-map 解析而不是原生 ESM，加载不到根目录那个文件。
 *
 * 类型仍从 node_modules 的 d.ts 取，与运行时分开来源：`npm i jolt-physics` 升版本时类型
 * 自动跟上，同时提醒——升完必须重跑 `node tools/art/gen-jolt-glue.mjs`，否则运行时还是旧的。
 */
export type JoltAPI = typeof JoltNS;

/** 绕开打包器的原生动态 import。 */
const nativeImport = new Function('u', 'return import(u)') as
    (u: string) => Promise<{ default: () => Promise<JoltAPI> }>;

let cached: Promise<JoltAPI> | null = null;

/** 加载并实例化 Jolt wasm。重复调用复用同一个实例（wasm 实例化开销不小）。 */
export function loadJolt(): Promise<JoltAPI> {
    if (!cached) {
        const url = new URL('jolt-glue.js', location.href).href;
        cached = nativeImport(url).then(m => m.default()).catch(e => {
            // 失败不能缓存成永久 rejected Promise：启动页的“重新加载”会整页刷新，但本局内
            // 的自动重试与测试注入也必须能重新发起请求，而不是立刻拿到同一个旧错误。
            cached = null;
            // 这里最常见的死法是 404：构建若开了 md5Cache，产物根目录的文件会被改名成
            // jolt-glue.<hash>.js，而这个路径是写死的。**构建请勿开 md5Cache**——
            // 缓存问题用开发服务器的 no-store 头解决，见 tools/serve.py。
            throw new Error(`Jolt 胶水加载失败（${url}）。`
                + `编辑器预览请检查 preview-template/jolt-glue.js，发布包请检查根目录同名文件；`
                + `缺失时运行 node tools/art/gen-jolt-glue.mjs，随后刷新预览或重新构建；`
                + `若构建开了 md5Cache，文件也会被改名，请关掉它。原始错误：${e}`);
        });
    }
    return cached;
}
