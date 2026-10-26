import { Prefab, resources, assetManager } from 'cc';
import { MODEL_PREFAB_UUID } from './ModelManifest';

/**
 * glb 预制体加载与缓存。
 *
 * glb 是容器资源，其中 Prefab 子资源的路径随导入设置不同而不同，因此按候选路径逐一尝试，
 * 全部失败再退回 ModelManifest 里记录的 uuid 直载。加载过的预制体按 id 缓存复用。
 */
export class PrefabCache {
    private cache = new Map<string, Prefab>();
    private loading = new Map<string, Promise<void>>();

    get(id: string): Prefab | undefined {
        return this.cache.get(id);
    }

    has(id: string): boolean {
        return this.cache.has(id);
    }

    /** 批量加载并缓存；已缓存的 id 自动跳过。 */
    async loadAll(ids: string[]): Promise<string[]> {
        const requested = Array.from(new Set(ids));
        await Promise.all(requested
            .filter(id => !this.cache.has(id))
            .map(id => this.load(id)));
        // 失败项显式交给玩法层。过去这里返回 void，玩法层会静默跳过缺失模型，
        // 关卡件数随网络/资源错误缩水，玩家甚至可能拿到一个“更容易”的坏关卡。
        return requested.filter(id => !this.cache.has(id));
    }

    /** 重叠的批次共享在途加载；失败后移除 Promise，下次重试仍会发起真实请求。 */
    private load(id: string): Promise<void> {
        const existing = this.loading.get(id);
        if (existing) return existing;
        const task = PrefabCache.loadOne(id).then(prefab => {
            if (prefab) this.cache.set(id, prefab);
        }).then(
            () => { this.loading.delete(id); },
            error => { this.loading.delete(id); throw error; },
        );
        this.loading.set(id, task);
        return task;
    }

    /** 单个 glb 预制体：先试路径，再退回 uuid。失败返回 null（调用方决定降级策略）。 */
    static loadOne(id: string): Promise<Prefab | null> {
        const candidates = [
            `models/${id}/${id}`,   // glb 容器内的同名 prefab 子资源
            `models/${id}`,         // 直接按路径
        ];
        return new Promise((resolve) => {
            const tryAt = (i: number) => {
                if (i >= candidates.length) {
                    // 路径都不行 → 按 meta 里的 uuid 直载（ModelManifest 自动生成）
                    const uuid = MODEL_PREFAB_UUID[id];
                    if (!uuid) {
                        console.error(`[PrefabCache] 加载模型失败：${id}（路径已试 ${candidates.join(' | ')}，且无 uuid 记录）`);
                        resolve(null);
                        return;
                    }
                    assetManager.loadAny({ uuid }, (err: Error | null, prefab: Prefab) => {
                        if (err || !prefab) {
                            console.error(`[PrefabCache] 加载模型失败：${id}（路径与 uuid 均失败）`, err);
                            resolve(null);
                        } else {
                            console.log(`[PrefabCache] 模型 ${id} 通过 uuid 加载成功`);
                            resolve(prefab);
                        }
                    });
                    return;
                }
                resources.load(candidates[i], Prefab, (err, prefab) => {
                    if (err || !prefab) { tryAt(i + 1); return; }
                    console.log(`[PrefabCache] 模型 ${id} 加载成功，路径：${candidates[i]}`);
                    resolve(prefab);
                });
            };
            tryAt(0);
        });
    }
}
