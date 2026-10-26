import { sys } from 'cc';

/** score 为后加字段，旧存档没有 → 读取方按 0 处理。 */
export interface BestRecord { stars: number; progress: number; score?: number; }

/**
 * 本地存档 I/O。
 *
 * 只负责读写与容错，不碰 UI、不做业务判断——每个方法在存储不可用/内容损坏时
 * 都回落到调用方给的默认值，因此上层无需再包 try/catch。
 * 全部存档键集中在此，新增存档项也只改这一个文件。
 */
export class SaveData {
    private static readonly LEVEL = 'goose_level_v1';
    private static readonly DAILY = 'goose_daily_v1';
    private static readonly BEST_LEGACY = 'goose_best_v1';
    private static readonly BEST = 'goose_best_v2';
    private static readonly SKIN = 'goose_skin_v1';
    private static readonly THEME = 'goose_theme_v1';
    private static readonly PROP = 'goose_props_v1';
    private static readonly PROPGIFT = 'goose_propgift_v1';
    private static readonly SOUND = 'goose_sound_v1';
    private static readonly GM = 'goose_gm_v1';
    private static readonly TAUGHT = 'goose_taught_v1';
    private static readonly ONBOARDED = 'goose_onboarded_v1';

    private static read(key: string): string | null {
        try { return sys.localStorage.getItem(key); } catch { return null; }
    }

    private static write(key: string, value: string): void {
        try { sys.localStorage.setItem(key, value); } catch { /* 存储不可用则仅本局生效 */ }
    }

    private static readObject(key: string): Record<string, unknown> {
        try {
            const value: unknown = JSON.parse(SaveData.read(key) ?? '');
            return SaveData.isObject(value) ? value : {};
        } catch { return {}; }
    }

    private static isObject(value: unknown): value is Record<string, unknown> {
        return typeof value === 'object' && value !== null && !Array.isArray(value);
    }

    private static isCount(value: unknown): value is number {
        return typeof value === 'number' && Number.isSafeInteger(value) && value >= 0;
    }

    /** JSON 能解析不代表结构正确；坏记录逐条丢弃，保留其他关卡的有效成绩。 */
    private static cleanBest(value: unknown): Record<number, BestRecord> {
        const best: Record<number, BestRecord> = {};
        if (!SaveData.isObject(value)) return best;
        for (const key of Object.keys(value)) {
            const record = value[key];
            if (!/^(0|[1-9]\d*)$/.test(key) || !SaveData.isCount(Number(key))
                || !SaveData.isObject(record)
                || !SaveData.isCount(record.stars) || record.stars > 3
                || typeof record.progress !== 'number' || !Number.isFinite(record.progress)
                || record.progress < 0 || record.progress > 100) continue;
            best[Number(key)] = { stars: record.stars, progress: record.progress };
            if (SaveData.isCount(record.score)) best[Number(key)].score = record.score;
        }
        return best;
    }

    private static readBest(): Record<string, Record<number, BestRecord>> {
        const all: Record<string, Record<number, BestRecord>> = Object.create(null);
        const raw = SaveData.readObject(SaveData.BEST);
        for (const theme of Object.keys(raw)) {
            if (SaveData.isObject(raw[theme])) all[theme] = SaveData.cleanBest(raw[theme]);
        }
        return all;
    }

    /** 当天日期键，用于每日免费次数的跨天重置。 */
    static todayKey(): string {
        const d = new Date();
        return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`;
    }

    /**
     * 关卡进度按天作用域：只有当天存过的进度才沿用，跨天自动回落 null
     * → 上层从第 1 关重开。配合「每天固定场景 + 3 关阶梯」的每日挑战循环。
     * 兼容旧版纯数字存档（解析为 number，无 date 字段 → 视为非今天 → 重开）。
     */
    static getLevel(): number | null {
        const raw = SaveData.readObject(SaveData.LEVEL);
        return raw.date === SaveData.todayKey() && SaveData.isCount(raw.index)
            ? raw.index : null;
    }
    static setLevel(index: number): void {
        SaveData.write(SaveData.LEVEL, JSON.stringify({ date: SaveData.todayKey(), index }));
    }

    /** 仅当存档日期是今天才沿用剩余次数，否则回落 fallback（跨天自动重置）。 */
    static getDaily(fallback: number): number {
        const raw = SaveData.readObject(SaveData.DAILY);
        return raw.date === SaveData.todayKey() && SaveData.isCount(raw.left)
            ? raw.left : fallback;
    }
    static setDaily(left: number): void {
        SaveData.write(SaveData.DAILY, JSON.stringify({ date: SaveData.todayKey(), left }));
    }

    static getBest(themeId: string): Record<number, BestRecord> {
        const all = SaveData.readBest();
        if (all[themeId]) return all[themeId];

        // v1 只按难度存成绩，四个主题会互相覆盖。升级时把旧成绩归到玩家当前主题，
        // 既不丢历史数据，也不把一张地图的纪录复制成四张地图都已通关。
        const legacy = SaveData.cleanBest(SaveData.readObject(SaveData.BEST_LEGACY));
        if (Object.keys(all).length === 0 && Object.keys(legacy).length > 0) {
            all[themeId] = legacy;
            SaveData.write(SaveData.BEST, JSON.stringify(all));
            return legacy;
        }
        return {};
    }
    static setBest(themeId: string, best: Record<number, BestRecord>): void {
        const all = SaveData.readBest();
        all[themeId] = SaveData.cleanBest(best);
        SaveData.write(SaveData.BEST, JSON.stringify(all));
    }

    static getSkin(): string | null {
        return SaveData.read(SaveData.SKIN);
    }
    static setSkin(id: string): void {
        SaveData.write(SaveData.SKIN, id);
    }

    /**
     * 玩家手动选定的场景主题 id（null = 跟随每日轮播）。
     *
     * 主题决定**物件族**（水果摊 / 古玩铺），皮肤只决定外观。历史实现里主题按日期锁定、
     * 换肤面板又只改视觉，于是能切出「翡翠碗装水果」这种不搭的组合，玩家也没法主动
     * 选想玩的那一族。这里让选择可持久化，见 LevelConfig.getActiveTheme。
     */
    static getTheme(): string | null {
        return SaveData.read(SaveData.THEME);
    }
    static setTheme(id: string | null): void {
        if (id === null) SaveData.write(SaveData.THEME, '');
        else SaveData.write(SaveData.THEME, id);
    }

    static getProps<K extends string>(fallback: Record<K, number>): Record<K, number> {
        const raw = SaveData.readObject(SaveData.PROP);
        const counts = { ...fallback };
        for (const key of Object.keys(fallback) as K[]) {
            const value = raw[key];
            if (SaveData.isCount(value)) counts[key] = value;
        }
        return counts;
    }
    static setProps(counts: unknown): void {
        SaveData.write(SaveData.PROP, JSON.stringify(counts));
    }

    /**
     * 音效开关。未存过按关闭处理（首次进入静音）。
     * 网页打开就外放是移动端浏览器最招人烦的行为之一，而且 iOS/Chrome 的自动播放策略
     * 本就要求先有用户手势；默认静音后由玩家在暂停菜单里主动打开。
     */
    static getSound(): boolean {
        return SaveData.read(SaveData.SOUND) === '1';
    }
    static setSound(on: boolean): void {
        SaveData.write(SaveData.SOUND, on ? '1' : '0');
    }

    static getGM(): boolean {
        return SaveData.read(SaveData.GM) === '1';
    }
    static setGM(on: boolean): void {
        SaveData.write(SaveData.GM, on ? '1' : '0');
    }

    /** 新手引导：是否已看过一次玩法说明（永久，不跨天重置）。 */
    static taught(): boolean {
        return SaveData.read(SaveData.TAUGHT) === '1';
    }
    static markTaught(): void {
        SaveData.write(SaveData.TAUGHT, '1');
    }

    /** 首次启动的整页引导与首局中的动态提示是两件事，不能共用 TAUGHT。 */
    static onboarded(): boolean {
        return SaveData.read(SaveData.ONBOARDED) === '1';
    }
    static markOnboarded(): void {
        SaveData.write(SaveData.ONBOARDED, '1');
    }

    /** 每日道具礼包：今天是否已领取（跨天自动重置）。 */
    static claimedPropGiftToday(): boolean {
        return SaveData.read(SaveData.PROPGIFT) === SaveData.todayKey();
    }
    static markPropGift(): void {
        SaveData.write(SaveData.PROPGIFT, SaveData.todayKey());
    }
}
