import { SaveData } from './SaveData';
/**
 * 关卡与场景配置。
 *
 * 设计：一个「场景主题」= 一套皮肤（SceneSkin）+ 一族物件（family）。
 * 每天按日期轮播一个主题（全服同一天同场景，天然可上好友榜）。
 * 当天固定 3 关阶梯，物件从该主题的 family 派生：
 *   第 1 关·送温暖(4 种) → 第 2 关·正常(6 种) → 第 3 关·地狱(9 种)。
 * 物件颜色对比逐关降低（先纯色强对比，再引入同色系靠形状区分），配合密度/时限收紧难度。
 */

export interface LevelDef {
    /** 参与本关的物件 id（对应 resources/models/ 下的 glb 文件名） */
    items: string[];
    /** 每种物件的组数（1 组 = 3 个） */
    groupsPerItem: number;
    /** 时限（秒） */
    timeSec: number;
    /** 目标堆叠层数；提高遮挡而不改变三消组的完整性。 */
    pileLayers?: number;
    /** 初始条件种子：同一关重试保持物件顺序、投放点、旋转和初速度一致 */
    seed: number;
    /**
     * 障碍物（石头）数量。默认 0。石头可拾取、占 1 格但无法三消（≤2 个永远配不齐），
     * 不计入胜利判定 → 误拿即长期占格，只能靠「移出」道具清掉，制造真实残局/爆槽风险。
     */
    distractors?: number;
    /**
     * 是否在堆底藏一只**金鹅**（彩蛋）。默认 false。
     *
     * 它不参与三消、不计入胜利判定、点到也不占暂存格——直接消失并即时给奖励。
     * 这三条是设计上的硬要求：金鹅只有一只，若进了槽就永远配不齐，
     * 彩蛋反而变成占格惩罚，玩家学会的会是"别碰那只鹅"。
     *
     * 投放时插在队列最前 → 落在堆的最底层，要挖开上面的件才见得到，
     * 这正是"藏"的含义。第 1 关是教学关，不放。
     */
    goldenGoose?: boolean;
    /**
     * 初始**冰封**的件数。默认 0。冰封件点不动，要靠完成三消逐个化开。
     *
     * 两条硬性约束保证它**不可能造成死局**（否则就是把随机挫败塞给玩家）：
     *   1. 每种物件最多冰封 1 个 —— 任何一组都至少留 2 个可拿，不会整组锁死；
     *   2. checkDeadlock 发现无解时优先把冰层全化开，而不是判负（见 GameManager）。
     * 石头与金鹅不参与冰封：前者本来就是负担，后者是奖励，冻上都只会添堵。
     */
    frozen?: number;
}

/** 障碍物 id（对应 resources/models/rock.glb）；跨主题通用，不属于任何物件族。 */
export const DISTRACTOR_ID = 'rock';

/** 场景主题：皮肤 + 物件族。family 顺序即难度引入顺序（前 4 个为强对比上手件）。 */
export interface Theme {
    id: string;
    /** 显示名 */
    name: string;
    /** 对应 SceneSkin.id（决定背景与置物容器外观） */
    skinId: string;
    /**
     * 物件族（该场景专属模型 id）。至少 9 种以喂满第 3 关。
     * 排序讲究：slice(0,4) 必须颜色两两分明；后段可引入同色系提升辨识难度。
     */
    family: string[];
}

/**
 * 挑战地图上的路线节点。玩法主题与地图展示刻意分开：前者决定实际加载哪些模型，
 * 后者只决定首页路线怎么排、能不能进入。以后追加新站时，只需先加一个路线节点；
 * 模型齐备后再补 themeId 即可开放，不需要改页面代码。
 */
export interface ChallengeMapDef {
    id: string;
    name: string;
    /** 对应 THEMES.id；缺省表示只展示预告、暂不可进入。 */
    themeId?: string;
    /** 节点在路线上的横向偏移，纵向位置按数组顺序自动向上延伸。 */
    routeX: number;
    /** 首页节点上的一句场景提示。 */
    tagline: string;
}

/** 数组顺序就是旅行路线从下到上的顺序，追加地图只需继续 push。 */
export const CHALLENGE_MAPS: ChallengeMapDef[] = [
    { id: 'fruit', name: '水果篮', themeId: 'fruit', routeX: -148, tagline: '阳光野餐 · 缤纷水果' },
    { id: 'antique', name: '古玩铺', themeId: 'antique', routeX: 150, tagline: '月色小铺 · 翡翠珍玩' },
    { id: 'farm', name: '池塘农场', themeId: 'farm', routeX: -126, tagline: '晨光池畔 · 丰收派对' },
    { id: 'dessert', name: '甜品小镇', themeId: 'dessert', routeX: 136, tagline: '金色午后 · 甜蜜巡游' },
    { id: 'electronics', name: '数码工坊', themeId: 'electronics', routeX: -138, tagline: '灵感工作台 · 数码寻宝' },
];

/**
 * 全部场景主题。追加一个主题即自动进入每日轮播，无需改玩法层。
 */
export const THEMES: Theme[] = [
    {
        id: 'fruit', name: '水果摊', skinId: 'redwood',
        // slice(0,4)=红/黄/紫/橙 四色分明；后段草莓(红)柠檬(黄)与前段同色系，靠形状区分。
        family: ['apple', 'banana', 'grape', 'orange',
                 'strawberry', 'lemon', 'pear', 'cherry', 'goose'],
    },
    {
        id: 'antique', name: '古玩铺', skinId: 'jade',
        /**
         * 古玩件天生同色（多数挤在 132~151° 的翡翠绿），所以这一族靠「明度 + 形状」
         * 拉开，而不是靠色相：
         *   slice(0,4) 金薄片(铜钱) / 紫珠环(手串) / 浅绿多面体(宝石) / 深绿葫芦
         *     —— 四者颜色两两分明，且形状分属盘、环、晶、瓶，俯视轮廓也互不相似；
         *   第 5~6 件是同色系的两个环（玉镯纯浅绿、扳指绿环带金内圈），靠内圈区分；
         *   后段加入方形玉玺与细长如意，最终压轴放吉祥物大鹅。
         *
         * 删过四件，都是**模型本身不合格**，不是配色问题：
         *   pingankou 与干扰物 rock 同为无彩灰（饱和度 0.02 / 0.01），只差明度，堆里易误拿；
         *   （jingling 曾是另一个候选，但属宝可梦商标件，已从仓库删除，见 CREDITS.md。）
         *   baicai 的网格是互不相连的叶片碎片（5000 面却有 8633 顶点），减面必穿洞，原版
         *     本身也只是团碎绿片；
         *   pixiu 与 yuanbao 同属那批 Tripo 低质产物：貔貅俯视是一团深绿碎块、看不出是兽，
         *     元宝其实是「盛着金块的托盘」、换任何角度都不像元宝。
         *   候选池里的 yushi / mile 与 pixiu 同批，一样糊，补不了位；只有 banzhi（扳指）
         *     干净，提上来补一个，所以是删二补一。
         *
         * 2026-08-11 用 Blender 程序化新建 yuxi / ruyi 补齐两种，不复用上述低质候选；
         * 本族现有完整 9 件，第 3 关与其他主题一致为 54 个可消件 + 2 块石头。
         */
        family: ['tongqian', 'bracelet', 'baoshi', 'hulu',
                 'yuzhuo', 'banzhi', 'yuxi', 'ruyi', 'goose'],
    },
    {
        id: 'farm', name: '池塘农场', skinId: 'picnic',
        /**
         * 前四件严格按橙 / 黄 / 紫 / 绿分色，并分别用长锥、长椭球、葫芦形、动物轮廓，
         * 保证教学关在密堆俯视下也不会误认。后五件开始复用橙黄与圆形轮廓，逐步要求
         * 玩家结合形状判断；第 3 关刚好吃满 9 种，不再出现古玩铺只有 7 种的梯度塌陷。
         */
        family: ['carrot', 'corn', 'eggplant', 'frog',
                 'pumpkin', 'mushroom', 'koi', 'lotus', 'duck'],
    },
    {
        id: 'dessert', name: '甜品小镇', skinId: 'dessert',
        /**
         * 教学关用粉色高筒 / 棕色圆环 / 薄荷三角 / 紫色圆饼建立四种强轮廓；
         * 后段加入同为米黄色的曲奇、蛋糕、布丁、可颂，靠形状而非色相提升辨识难度。
         */
        family: ['cupcake', 'donut', 'icecream', 'macaron',
                 'cookie', 'cake_slice', 'candy', 'pudding', 'croissant'],
    },
    {
        id: 'electronics', name: '数码工坊', skinId: 'electronics',
        // 前四种以珊瑚红长条、薄荷绿折角、金黄圆镜头、紫色拱形建立辨识。
        family: ['phone', 'laptop', 'camera', 'headphones',
                 'handheld', 'speaker', 'mouse', 'smartwatch', 'radio'],
    },
];

/** 按日期取模选当天主题（UTC 天数；全服一致）。玩家未手动选主题时用它。 */
export function activeThemeIndex(): number {
    const day = Math.floor(Date.now() / 86400000);
    return ((day % THEMES.length) + THEMES.length) % THEMES.length;
}

/**
 * 当前主题：玩家手动选过就用他选的，否则跟随每日轮播。
 *
 * 主题决定**物件族**，皮肤只决定外观。两者过去是分开的：主题按日期锁死、换肤面板
 * 只改视觉，于是能切出「翡翠碗装水果」这种不搭的组合，玩家也没法主动挑想玩的那一族。
 * 现在主题可选且持久化，选主题会连带把皮肤换成它配套的那套（见 GameManager.applyTheme）。
 */
export function getActiveTheme(): Theme {
    const saved = SaveData.getTheme();
    if (saved) {
        const hit = THEMES.find(t => t.id === saved);
        if (hit) return hit;
    }
    return THEMES[activeThemeIndex()];
}

/**
 * 从物件族派生 3 关阶梯。
 * 保持每类件数为三的倍数，挑战关通过种类、堆叠深度与时限增加决策压力。
 */
export function buildLevels(family: string[]): LevelDef[] {
    const pick = (n: number) => family.slice(0, Math.min(n, family.length));
    return [
        // 第 1 关：4 种 × 4 组，避免少件时开口大片见底；不引入障碍物。
        { items: pick(4), groupsPerItem: 4, timeSec: 255, seed: 104729 },
        // 第 2 关：增加品类、总件数与冰封遮挡，不靠无法三消的石头制造死局。
        { items: pick(6), groupsPerItem: 3, timeSec: 210, seed: 130363, pileLayers: 3.4,
          goldenGoose: true, frozen: 4 },
        // 第 3 关：81 件 / 165s，深层遮挡与九种物件叠加。
        { items: pick(9), groupsPerItem: 3, timeSec: 165, seed: 155921, pileLayers: 3.9,
          goldenGoose: true, frozen: 7 },
    ];
}

/**
 * 当前主题的 3 关。模块加载时按当前主题算一次，玩家切主题后由 {@link refreshLevels}
 * **原地**重建——必须原地改而不是重新赋值，因为 GameManager 直接持有这个数组引用，
 * 换成新数组的话它那边还指着旧的，切完主题物件族不变、只有皮肤变了。
 */
export const LEVELS: LevelDef[] = buildLevels(getActiveTheme().family);

/** 切主题后重建关卡表。调用方负责重开当前关（物件族变了，堆必须重新投放）。 */
export function refreshLevels(): void {
    const next = buildLevels(getActiveTheme().family);
    LEVELS.length = 0;
    LEVELS.push(...next);
}

/** 校验：每关物件总数必须是 3 的倍数（groupsPerItem 保证了这一点，这里防御性再查一遍） */
export function validateLevel(def: LevelDef): boolean {
    return (def.items.length * def.groupsPerItem * 3) % 3 === 0
        && Number.isInteger(def.seed) && def.seed > 0;
}
