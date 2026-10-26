import {
    _decorator, Component, Node, Camera, Label, instantiate,
    MeshRenderer,
    input, Input, EventTouch, tween, Tween, v3, Vec3, Quat, Mat4, geometry, screen,
    Layers, Color, Material, utils, primitives, director,
} from 'cc';
import { DebugViz } from './DebugViz';
import {
    LEVELS, LevelDef, getActiveTheme, refreshLevels, THEMES, CHALLENGE_MAPS, DISTRACTOR_ID,
} from './LevelConfig';
import { SceneSkin, getSkin, DEFAULT_SKIN_ID } from './SceneSkin';
import { ContainerBoundary, BoundaryDef } from './ContainerBoundary';
import { SlotTray, TRAY_CAPACITY } from './SlotTray';
import { ItemTag } from './ItemTag';
import { PrefabCache } from './PrefabCache';
import { JoltWorld, extractHullPoints, ProxyShape } from './JoltWorld';
import { SaveData, BestRecord } from './SaveData';
import { HudUI, PropKind } from './HudUI';
import { SceneBackground } from './SceneBackground';
import { AudioMan } from './AudioMan';
import { Telemetry } from './Telemetry';
import { UIKit } from './ui/UIKit';
import { HOME_PRELOAD_IMAGES } from './ui/HomeScreen';
import { PromoVideo, PromoResult } from './PromoVideo';

const { ccclass, property } = _decorator;

/** 判负原因。'无解' = 盒中剩余物件配不出任何一组三消，继续点也只是等超时。 */
type LoseReason = '' | '槽位已满' | '时间到' | '无解';

/**
 * M1 核心玩法总控。
 * 场景要求（编辑器内手动搭）：
 * - Main Camera：position (0, 9, 9)，rotation (-45, 0, 0)，挂到 cam 属性
 * - Directional Light：默认即可
 * - 空节点 GameRoot：挂本脚本
 * - Canvas 下三个 Label：progressLabel / timerLabel / msgLabel（可选，不挂也能跑，信息走 console）
 * 模型放 assets/resources/models/*.glb
 */
@ccclass('GameManager')
export class GameManager extends Component {
    @property(Camera) cam: Camera = null!;
    @property(Label) progressLabel: Label | null = null;
    @property(Label) timerLabel: Label | null = null;
    @property(Label) msgLabel: Label | null = null;

    /** 关卡序号（0 起） */
    @property levelIndex = 1;

    private tray = new SlotTray();
    private level!: LevelDef;
    private timeLeft = 0;
    private totalCount = 0;
    private removedCount = 0;
    private playing = false;
    private paused = false;
    private promoVideo = new PromoVideo();
    private promoShown = false;
    private timeoutOffered = false;
    private timeoutOfferOpen = false;
    private static readonly REVIVE_SECONDS = 60;
    /** 选皮面板打开前的暂停状态，关闭时原样恢复（不覆盖玩家的手动暂停）。 */
    private overlayPrevPaused = false;
    private prefabs = new PrefabCache();
    private hud: HudUI | null = null;
    private background: SceneBackground | null = null;
    private audio: AudioMan | null = null;
    /** 物理世界（Jolt）。全工程唯一一处物理入口，玩法层不直接碰 Jolt 类型。 */
    private jolt = new JoltWorld();
    /** 启动门闩：主页与“开始挑战”必须等同一份 Jolt 初始化结果，禁止无物理开局。 */
    private physicsReady: Promise<boolean> | null = null;
    /** 固定步长累加器。渲染帧长喂进来，按 FIXED_STEP 整步消费，余量交给渲染插值。 */
    private physAccum = 0;
    /** 存档键与读写容错集中在 SaveData；这里只保留业务默认值。 */
    private static readonly DAILY_FREE = 3;
    /** 当前场景皮肤 id。所有 3D 容器/背景视觉从此皮肤取色。 */
    private skinId = DEFAULT_SKIN_ID;
    /** 场景视觉 + 隐形围栏的容器节点，换肤时整体销毁重建（物件在 this.node 上，不受影响）。 */
    private sceneRoot: Node | null = null;
    /** 每关每轮只能救一次,防止无限续命。 */
    private rescueUsed = false;
    private gmEnabled = false;
    private gmUsedThisRound = false;
    private loseReason: LoseReason = '';
    private dailyLeft = GameManager.DAILY_FREE;
    /** 判负缓冲和自动吸取期间锁住手动输入，保证槽位状态原子化。 */
    private interactionLocked = false;
    /** 当前主题的各关历史最佳:{ [levelIndex]: { stars, progress, score } } */
    private best: Record<number, BestRecord> = {};
    /**
     * 当前仍冰封的件。缓存成列表而不是每帧 getComponentsInChildren——
     * 雪花标记要逐帧跟位置（件会因下方被拿走而沉降），56 件的组件遍历每帧做一次不划算。
     */
    private frozenTags: ItemTag[] = [];
    /** 上一帧是否画着雪花：用来在列表清空的那一帧补一次清除调用。 */
    private frostMarksShown = false;
    /** 本局是否已经提示过冰封机制。同石头，只说一次。 */
    private frozenWarned = false;
    /** 本局是否已经提示过石头。石头是唯一「拿了就亏」的物件,但只提示一次,别唠叨。 */
    private rockWarned = false;

    // ===== 得分与连击 =====
    /** 本局得分。每次三消入账,连击越长单次入账越多。 */
    private score = 0;
    /** 本局开始时刻，只用于统计局长，不参与玩法计时。 */
    private roundStartedAt = 0;
    /** 一次开局的匿名关联键；救场前后的两次结算用它归为同一局。 */
    private roundId = '';
    /** 当前连击数(连续三消,中断即归零)。 */
    private combo = 0;
    /** 上次三消的时刻(秒),用于判断是否还在连击窗口内。 */
    private lastMatchAt = -99;
    /** 单次三消基础分。 */
    private static readonly SCORE_BASE = 100;
    /** 连击窗口(秒):在此窗口内再次三消即累加连击。 */
    private static readonly COMBO_WINDOW = 4.5;
    /** 连击倍率上限,防止后期一路滚雪球。 */
    private static readonly COMBO_MAX_MULT = 5;
    /** 胜利时每剩 1 秒折算的奖励分。让「快速通关」比「压哨通关」值钱,三星局之间也分得出高下。 */
    private static readonly TIME_BONUS_PER_SEC = 2;

    // ===== 提示与紧迫感 =====
    /** GM 模式下距上次有效操作的时间(秒)。 */
    private idleTime = 0;
    /** 发呆多久后给提示(秒)。 */
    private static readonly HINT_IDLE = 6;
    /** 剩余时间低于此值(秒)进入读秒紧张态。 */
    private static readonly URGENT_SEC = 15;

    /**
     * 手机屏幕内的真实物理盒边界。
     * 正交相机在 390×844 下横向约可见 ±1.96；左右内壁为 ±1.35，
     * 与可见木框内沿对齐，并给密集堆叠留出足够空间，避免刚体长期互相挤压。
     * Z 方向与可见木盒的后沿(-2.38)和前沿(0.63)对齐。
     */
    private static readonly FENCE_HALF_X = 1.35;
    private static readonly FENCE_CENTER_Z = -0.88;
    private static readonly FENCE_HALF_Z = 1.42;
    /**
     * 调试开关：把隐形围栏 / 地板顶面 / boundary 形状渲成半透明盒叠在容器上，
     * 用来对齐物理容纳与视觉容器（穿模排查）。发布前保持 false。
     */
    private static readonly DEBUG_FENCE = false;
    /** 模型外轮廓允许占用的最终可见范围（不是节点中心范围）。 */
    private static readonly VISIBLE_HALF_X = 1.70;
    private static readonly VISIBLE_MIN_Z = -2.25;
    private static readonly VISIBLE_MAX_Z = 0.48;
    /**
     * 当前容器边界。buildBox 时按皮肤重建：矩形容器用默认边界（与上面常量一字不差），
     * 圆锅/圆碗等在皮肤里声明 boundary 即整体切换。围栏、逃逸、视觉兜底、投放全走它。
     */
    private boundary: ContainerBoundary = GameManager.makeBoundary(undefined);
    /** 本关物件基准缩放:少件关卡放大物件,保证盒子饱满、目标好点。 */
    private itemScale = 0.46;

    // ===== 堆叠投放旋钮(具名化,便于后续调参) =====
    /**
     * 基础堆叠层数；挑战关可通过 level.pileLayers 增加遮挡。
     * 缩放按目标层数、容器面积和件数反解；件数增加时必须同步加深目标层数，
     * 否则缩放变小，开口仍然大片见底。
     */
    private static readonly PILE_TARGET_LAYERS = 3.1;
    /**
     * 缩放兜底区间：少件关卡不能出现难以点选的巨件，多件关卡也不能缩成小豆子。
     */
    private static readonly PILE_ITEM_MIN = 0.30;
    private static readonly PILE_ITEM_MAX = 0.80;
    /** 单件外接盒宽 ÷ itemScale。实测五档缩放下比值稳定在 1.24~1.31,取中值。
     *  用来定铺点内缩量(inset),保证外接盒不越过筐壁。 */
    private static readonly PILE_ITEM_WIDTH_K = 1.28;
    /**
     * 单件**实际占地**宽 ÷ itemScale:碰撞盒尺度,决定一层塞得下几件。
     *
     * 比外接盒宽(1.28)小,因为外接盒是轴对齐外框,件随机朝向时外框比件本身胖约四分之一。
     * 注意别拿"俯视像素占地"来标定这个值——那个数(约 0.70)算的是**可见轮廓**,
     * 而挡住彼此的是碰撞盒;按可见轮廓算会把每层容量高估一倍多,堆照样长成柱子。
     */
    private static readonly PILE_ITEM_SPAN_K = 1.02;
    /** 一层的堆积效率:方格铺满是 1,实际有间隙与朝向差异,取 0.85。调大 = 每层塞更多件、堆更矮更挤。 */
    private static readonly PILE_PACK = 0.85;
    /** 上层略向内收；内缩过大会让开口边缘见底、中央堆成柱。 */
    private static readonly PILE_LAYER_INSET = 0.025;
    /**
     * 投放高度(件的出生 y,另加 idx%5 的 0.22 阶梯错开)。
     *
     * **这是"堆积效果不行"的真正旋钮**,原先硬编码 4.2 埋在 spawnItems 里。
     * 4.2 的问题不在观感而在物理:低阻尼(0.06)下自由落体到 y=0 的落地速度约 9m/s,
     * 单件下落耗时 0.93s,而投放间隔只有 0.05s —— **空中长期有约 18 件同时在飞**。
     * 它们边落边互撞,把已铺好的层撞散、彼此架桥,于是 pileSeedPoint 精心算出的
     * 1.9 层落定后变成实际约 5 层:实测第 1 关 y 中位 1.91、最高 3.03,而碗沿只有
     * 1.43 —— 一半件堆在碗沿之上,俯视投影缩在中间,这正是"覆盖率 55% 封顶"的来源
     * (堆往上长而不往外铺,不是筐底填不满)。件是被"砸"进去的,不是"放"进去的。
     *
     * 压到容器沿略上方:落差只剩零点几,件贴着堆顶落定,空中同时在飞的件数随下落
     * 时间平方根下降。观感上仍是从容器上方倒入(沿口以上即可),但不再需要"抬到
     * 可视区外"——那点戏剧性换来的是整堆失控。
     *
     * 取 2.6 而不是更低:实测(古玩铺第 1 关 36 件,玉碗沿 y=1.43)
     *   4.2 → y 最低 1.55 / 中位 2.95 / 最高 3.96  整堆悬在碗上方,一件都没进碗
     *   2.6 → y 最低 0.20 / 中位 0.84 / 最高 1.58  铺满碗底,堆顶微冒沿口
     *   2.0 → y 最低 0.05 / 中位 0.85 / 最高 1.79
     *   1.6 → y 最低 0.04 / 中位 0.77 / 最高 1.93
     * 比 2.0/1.6 反而更矮更实:2.6 落下的那点动能正好把件挤进缝隙压平,
     * 再低则件几乎在堆顶生成、直接架上去。存在最优区间,2.6 在里面。
     */
    private static readonly PILE_SPAWN_Y = 2.6;
    /** 金鹅彩蛋复用大鹅模型，只改材质与尺寸（见 paintGolden）。 */
    private static readonly GOLDEN_ID = 'goose';
    /** 金鹅奖励：加时（秒）。取 20——够抢救一次开局失速，又不足以把一关白送。 */
    private static readonly GOLDEN_BONUS_SEC = 20;
    /** 金鹅奖励：加分。与一次 3 连击的量级相当，让"挖到"这件事值回挖它花的时间。 */
    private static readonly GOLDEN_BONUS_SCORE = 300;
    /** 每完成一次三消化开几件。1 件 = 冰封 5 件需 5 次三消，正好摊在一关里。 */
    private static readonly THAW_PER_MATCH = 1;
    /** 逐件投放间隔(秒/件):越小灌入越快、总时长越短,但同时在场刚体更多、穿插更深。
     *  0.03→0.05:同帧在场的动态刚体更少,求解器有余量把相邻件分开,少锁死互插。 */
    private static readonly SPAWN_INTERVAL = 0.06;
    /** 兜底强制冻结延迟(末件投放后再等这么久整堆硬冻)。巡检自锁通常早已完成,这里只兜底。 */
    private static readonly SETTLE_BACKSTOP = 1.0;
    /**
     * 逐件定时硬冻:每件 spawn 后经过此时长(落体~0.6s + 短沉降)即无条件冻成 KINEMATIC。
     * 关键:高频挤压抖动在 0.15s 巡检下会混叠、检测抓不住,而"到点直接冻"不依赖检测——
     * 无论它抖得多凶,到点即锁。每件各自计时 → 早落的物件不必陪着整堆抖一整个投放期。
     * 调大 = 给沉降更多时间(更可能落到位,但抖动窗口更长);调小 = 更早锁死(抖动窗口更短)。
     */
    private static readonly SPAWN_FREEZE_DELAY = 0.9;
    /** 出生缩放弹大("从小变大"):spawn 时缩放起始比例(相对目标),越小弹得越夸张。 */
    private static readonly SPAWN_POP_FROM = 0.16;
    /**
     * 弹大总时长(秒)。0.15s 在手机上通常只跨 9 帧，又和同时发生的下落重叠，体感近似闪现；
     * 拉到 0.28s 并做“过冲 → 回弹 → 落稳”三段，仍短于主要接触阶段，不会改动物理代理。
     */
    private static readonly SPAWN_POP_TIME = 0.28;
    /**
     * 圆形/环形物件:用圆柱碰撞体而非方盒。方盒的四个空角埋在堆里会被邻居深插 → 求解器狂弹 →
     * 高速抖(尤以手串等环形最明显)。圆柱无角、贴合圆盘轮廓,密堆时接触干净、抖动大减。
     * 非圆形物件(鹅/佛像/葫芦等)仍用方盒。
     */
    private static readonly ROUND_ITEMS = new Set([
        'banzhi', 'bracelet', 'tongqian', 'yuzhuo',
        // 农场主题的圆盘/球形件用圆柱代理，密堆时避免方盒空角互插后持续弹跳。
        'pumpkin', 'mushroom', 'lotus',
        // 甜品主题的圆饼/杯状件同理；细长糖果和三角蛋糕仍保留方盒轮廓。
        'cupcake', 'donut', 'macaron', 'cookie', 'pudding',
    ]);
    /**
     * 最大边统一归一化只能保证“最长尺寸相同”，不能保证俯视面积相同。香蕉、胡萝卜、
     * 如意等细长件因此会比球形件少占很多像素，在手机上既显小又难点。这里只给轮廓偏细
     * 的模型做温和补偿；缩放同时用于视觉和 Jolt 代理，不制造点击错位。
     * 纸杯换为原始模型中的小视图后，最长边从旧主模型的 0.796 缩至 0.286。
     * 因此按 2.78 倍还原至旧最大纸杯的实际尺寸，而不是只做观感补偿。
     */
    private static readonly ITEM_SCALE_MULTIPLIER: Readonly<Record<string, number>> = {
        banana: 1.08,
        grape: 1.05,
        lemon: 1.04,
        pear: 1.05,
        goose: 1.06,
        ruyi: 1.08,
        carrot: 1.08,
        corn: 1.05,
        eggplant: 1.04,
        frog: 1.07,
        koi: 1.06,
        duck: 1.07,
        cupcake: 2.78,
        icecream: 1.06,
        cake_slice: 1.05,
        candy: 1.08,
        croissant: 1.06,
    };
    /**
     * 这些模型的主要识别特征在侧面。GLB 的本地 Y 为竖轴，若沿用默认 ±32° 小倾角，
     * 近正俯视相机看到的往往只是果蒂或圆形顶面。范围为相对竖直方向的倾角（度），
     * 让它们以自然侧躺姿态落下，同时保留 12° 的随机滚转避免机械排布。
     */
    private static readonly SIDE_PROFILE_TILT: Readonly<Record<string, readonly [number, number]>> = {
        strawberry: [34, 52],
        pear: [46, 68],
        carrot: [62, 78],
        corn: [56, 74],
        eggplant: [48, 68],
        // 角色按设计稿改为直立正脸造型，温和倾斜可同时看到表情、腹部和脚掌。
        frog: [28, 42],
        duck: [28, 42],
        icecream: [46, 66],
    };
    /** 重力。数值与旧实现一致，只是从 PhysicsSystem 挪到了 JoltWorld。 */
    private static readonly GRAVITY_Y = -12;
    /** 固定物理步长。必须是 60Hz 的整数分之一，见 initPhysics 的说明。 */
    private static readonly FIXED_STEP = 1 / 120;
    /** 单帧最多推几步：切后台回来时别把几秒欠账一次性喂给物理（会直接炸堆）。 */
    private static readonly MAX_STEPS_PER_FRAME = 8;
    /** 接触材质：高摩擦 + 少量回弹，落地有轻微弹跳的实感又不会滚得到处都是。 */
    private static readonly PILE_FRICTION = 1.25;
    private static readonly PILE_RESTITUTION = 0.08;
    /** 只服务于初始堆叠的确定性随机流，不受巡逻、道具等运行时随机行为干扰。 */
    private levelRandomState = 1;

    onLoad() {
        Telemetry.init();
        Telemetry.track('app_boot');
        // 物理由 Jolt 接管（见 JoltWorld 的类注释与 lab/ 的同场对比）。Cocos 内置的
        // ammo/Bullet 在本玩法的密堆下永不收敛——36 件跑满 45 仿真秒一件都不休眠，
        // 正式工程历史上那三层脚本兜底（0.9s 定时硬冻、PilePatrol 两条冻结判据、
        // constrainVisualInside 位置改写）都是在给这个擦屁股，现已连同本段配置一起删除。
        //
        // wasm 是异步加载的：init 完成前 buildBox 建的围栏会被丢掉，所以要等它。
        // 期间玩家看到的是加载页，没有可交互内容，等待无感。
        this.physicsReady = this.initPhysics();
        // 皮肤要在建盒之前定好。每天固定一个场景：皮肤跟随当天主题（getActiveTheme），
        // 不再由玩家自选决定「场景身份」；HUD 换肤面板仅作背景微调，不改物件族。
        this.skinId = getSkin(getActiveTheme().skinId).id;
        input.on(Input.EventType.TOUCH_START, this.onTouch, this);
    }

    /**
     * 起物理世界，就绪后再建容器。
     *
     * 固定步长 1/120 的理由没变，只是从 Cocos 的配置挪到了自己的累加器（见 update）：
     * 步长必须是 60Hz 渲染帧的整数分之一。1/90 会让每帧交替推进 1/2 个物理步，
     * 表现为沉降阶段全体物件毫米级高频颤动。1/120 = 每帧恰好 2 步。
     * 与旧实现的关键差别是**现在有渲染插值**（JoltWorld.syncNodes），混叠不再靠步长凑。
     */
    private async initPhysics(): Promise<boolean> {
        try {
            await this.jolt.init(GameManager.GRAVITY_Y);
        } catch (e) {
            // **必须炸得很响**：物理起不来时游戏照样能跑完整个流程，物件停在投放点不动、
            // 消除也不会塌，看着像"堆积效果变差"而不是"物理没了"。
            // 踩过一次：构建开了 md5Cache，把 jolt-glue.js 改成了 jolt-glue.<hash>.js，
            // 加载器按固定路径取 → 404 → 这里静默失败，一路跑到用户手里。
            console.error('[GameManager] ❌ 物理初始化失败，游戏将没有任何物理效果', e);
            Telemetry.error('physics_init', e);
            return false;
        }
        if (!this.node.isValid) return false;   // 等待期间场景已被换掉
        this.buildBox();
        Telemetry.track('physics_ready');
        return true;
    }

    onDestroy() {
        this.promoVideo.close();
        this.hud?.hidePromoGoose();
        input.off(Input.EventType.TOUCH_START, this.onTouch, this);
    }

    async start() {
        if (!this.cam) {
            this.cam = this.node.scene.getComponentInChildren(Camera)!;
            console.log('[GameManager] cam 属性未接线，自动使用场景相机');
        }
        console.log('[GameManager] 相机 world=', this.cam?.node.worldPosition.toString());
        // 全屏 2D 背景垫在最底层：主相机改为只清深度并叠在背景之上（priority 高于背景相机）。
        // 只画 DEFAULT 层，杜绝把 UI_3D 背景 Sprite 或 UI_2D 的 HUD 一起画进 3D 视图。
        this.background = new SceneBackground(this.node.scene);
        const initSkin = this.currentSkin();
        this.background.setBackdrop(initSkin.backdropTex, initSkin.backdrop);
        if (this.cam) {
            this.cam.visibility = Layers.Enum.DEFAULT;
            this.cam.clearFlags = Camera.ClearFlag.DEPTH_ONLY;
            this.cam.priority = 1;
            console.log('[GameManager] 相机 visibility=', this.cam.visibility.toString(2));
        }
        this.forceLayer(this.node);
        // HUD（纯代码占位版）
        this.hud = new HudUI(this.node.scene, kind => this.useProp(kind), () => this.togglePause(),
            open => this.setOverlayPause(open),
            () => this.toggleSound());
        this.timerLabel = this.hud.timerLabel;
        this.progressLabel = this.hud.progressLabel;
        this.msgLabel = this.hud.msgLabel;
        this.audio = new AudioMan(this.node.scene);
        // AudioMan 晚于 HUD 建，声音键先按静音画；这里用存档里的真实状态补一次。
        this.hud.setSoundOn(this.audio.soundOn);
        this.gmEnabled = SaveData.getGM();
        this.resetProps();
        // 关卡进度本地存储:上次通到第几关,这次直接从那关开始。
        const savedLevel = SaveData.getLevel();
        if (savedLevel !== null) {
            this.levelIndex = Math.max(0, Math.min(savedLevel, LEVELS.length - 1));
        }
        this.level = LEVELS[Math.min(this.levelIndex, LEVELS.length - 1)];
        this.timeLeft = this.level.timeSec;
        this.hud.setLevel(this.levelIndex + 1);
        this.loadDaily();
        this.loadBest();
        // 首页期间计时牌先显示本关时限，别停在 0:00。
        this.updateHud();
        // Jolt 是玩法的硬依赖。加载页只有在它成功建好世界与容器后才能撤掉；否则慢网设备
        // 可能先点进关卡，spawn 安全空转后得到一堆没有刚体、永远不下落的物件。
        const physicsOk = await (this.physicsReady ?? (this.physicsReady = this.initPhysics()));
        if (!physicsOk) {
            (globalThis as any).__gooseBoot?.fail('物理引擎加载失败，请重新加载');
            return;
        }
        // 首页节点会同步创建，先把切图解析到 Texture 缓存，避免进度条结束后逐块补图。
        const startupImages = initSkin.backdropTex
            ? [...HOME_PRELOAD_IMAGES, `textures/${initSkin.backdropTex}/texture`]
            : HOME_PRELOAD_IMAGES;
        await UIKit.preloadImages(startupImages, (completed, total, failed) => {
            const ratio = completed / Math.max(total, 1);
            const suffix = failed > 0 ? `（${failed} 项使用降级）` : '';
            (globalThis as any).__gooseBoot?.to(74 + ratio * 22, `正在加载界面资源…${suffix}`);
        });
        if (!this.node.isValid) return;
        // 首次启动先走独立引导页；完成后才进入挑战路线。两者都是真页面，不和游玩 HUD 共存。
        if (SaveData.onboarded()) this.showHome();
        else this.hud.showOnboarding({
            onDone: () => {
                SaveData.markOnboarded();
                this.showHome();
            },
        });
        // 首屏加载页到此撤除：首页已经画完且可点。物件模型不在这一步加载——
        // 它们等玩家点「开始挑战」才按关卡拉取（startInitialRound），不该拖长首屏。
        (globalThis as any).__gooseBoot?.done();
    }

    /**
     * 开始页：选场景 + 选难度 + 开始。场景在这里定死，进局后不可改（见 HudUI.showHome）。
     *
     * 难度「先解锁再自选」：第 1 关恒开放，之后每一关要前一关有过成绩才解锁。
     * 这样既保留三关阶梯，又让打过的档位可以直接重玩。
     */
    /** 首页成绩行：三处（进页、切地图、切难度）都要用同一份口径，别各写一遍。 */
    private bestTextOf(index: number) {
        const best = this.best[index];
        return best
            ? `最佳 ${'★'.repeat(best.stars) || '—'} ${best.score ?? 0} 分`
            : '本关暂无成绩';
    }

    private showHome() {
        Telemetry.track('home_view', { theme: getActiveTheme().id, level: this.levelIndex + 1 });
        const best = this.best;
        this.hud?.showHome({
            // 路线节点来自独立配置，预告地图可以先显示、等模型齐备后再补 themeId 开放。
            maps: CHALLENGE_MAPS.map(m => ({
                id: m.id,
                name: m.name,
                tagline: m.tagline,
                routeX: m.routeX,
                playable: !!m.themeId && THEMES.some(t => t.id === m.themeId),
                selected: m.themeId === getActiveTheme().id,
            })),
            levels: LEVELS.map((lv, i) => {
                const count = lv.items.length * lv.groupsPerItem * 3 + (lv.distractors ?? 0);
                const rock = lv.distractors ? ` · 石头 ${lv.distractors}` : '';
                return {
                    text: GameManager.LEVEL_NAMES[i] ?? `第 ${i + 1} 关`,
                    detail: `${lv.items.length} 种 · ${count} 件 · ${GameManager.clock(lv.timeSec)}${rock}`,
                    stars: best[i]?.stars ?? 0,
                    // 开局页的职责就是让玩家自主选难度，三档始终可选；成绩只影响星级展示。
                    unlocked: true,
                    selected: i === this.levelIndex,
                };
            }),
            dailyText: `今日剩余 ${this.dailyLeft}/${GameManager.DAILY_FREE}`,
            bestText: this.bestTextOf(this.levelIndex),
            soundOn: this.audio?.soundOn ?? false,
            gmOn: this.gmEnabled,
            onPickMap: id => {
                const map = CHALLENGE_MAPS.find(m => m.id === id);
                if (!map?.themeId) return;
                this.applyTheme(map.themeId, false); // 还在路线页挑地图，不入局
                Telemetry.track('theme_select', { theme: map.themeId });
                // 地图背景和控制台都不需要重建；整页重画会叠加按压缩放与路由淡入，
                // 形成用户看到的“点一下闪一下”。只刷新站点层和当前主题成绩。
                this.hud?.selectHomeMap(id, this.bestTextOf(this.levelIndex));
            },
            onPickLevel: i => {
                this.levelIndex = i;
                this.level = LEVELS[i];
                Telemetry.track('level_select', { level: i + 1, theme: getActiveTheme().id });
                // 首页切难度发生在 spawn 之前，但计时与关卡牌是独立缓存状态；只换 level
                // 会让大师配置实际倒出 56 件，HUD 却仍显示上一局的“第 2 关 / 3:30”。
                // 在用户选择这一刻同步重置，首页摘要与进局后的运行状态才是同一份关卡。
                this.timeLeft = this.level.timeSec;
                this.hud?.setLevel(this.levelIndex + 1);
                this.updateHud();
                // 和选地图同理：整页重建会把地图和控制台一起闪掉，反而看不清换了哪一档。
                this.hud?.selectHomeLevel(i, this.bestTextOf(i));
            },
            onToggleSound: () => this.toggleSound(),
            onToggleGM: () => this.toggleGM(),
            onStart: () => {
                // 页面必须在这里显式收起：它不再是弹窗，不会因为按了按钮就自己消失。
                // beginRound 只管开局，关页面是路由的事——两者分开才不会像旧实现那样
                // 依赖"谁按的谁负责关"。
                this.hud?.hideHome();
                void this.beginRound();
            },
        });
    }

    /** 展示名称与挑战页设计稿保持一致，玩法参数仍由 LevelConfig 独立控制。 */
    private static readonly LEVEL_NAMES = ['轻松', '标准', '大师'];

    /** 秒数 → m:ss。 */
    private static clock(sec: number): string {
        const m = Math.floor(sec / 60);
        const s = Math.floor(sec % 60);
        return `${m}:${s.toString().padStart(2, '0')}`;
    }

    /**
     * 每日次数门：有次数返回 true；没有则弹补充入口，玩家确认后重跑 next。
     * H5 无激励视频，这里是无门槛续次——次数只当节奏提示，不当付费墙。
     * 此入口的位置为将来接广告预留：届时只需把 onAction 换成广告回调。
     */
    private ensureDaily(next: () => void): boolean {
        if (this.dailyLeft > 0) return true;
        this.hud?.showNotice('今日次数用完', '每天可免费挑战 3 次\n想接着玩就再续一次吧',
            '再续一次', () => {
                this.dailyLeft++;
                this.saveDaily();
                this.hud?.hideResult();
                next();
            });
        return false;
    }

    /** 从首页进入本关：过次数门 → 生成物件；GM 首局可提前亮一次提示。 */
    private async beginRound() {
        if (!this.ensureDaily(() => void this.beginRound())) return;
        // BGM 起播点必须挂在用户手势上（点「开始挑战」），否则被浏览器自动播放策略拦掉。
        // 声音默认关闭，所以这里通常什么都不会响，直到玩家在暂停菜单里打开。
        this.audio?.startBgm();
        if (!await this.startInitialRound()) return;
        if (!this.gmEnabled || SaveData.taught()) return;
        // 第一次玩：等堆叠落定后主动指一组可消的物件，比任何文字都直观。
        SaveData.markTaught();
        this.scheduleOnce(() => { if (this.gmEnabled) this.showHint(); }, 2.2);
    }

    /** 本关需加载的 prefab id：物件族 +（有障碍物时）石头 +（有彩蛋时）金鹅。 */
    private levelPrefabIds(level = this.level): string[] {
        const ids = level.distractors ? [...level.items, DISTRACTOR_ID] : [...level.items];
        // 金鹅用的 goose 模型不一定在本关的 items 里——水果族的 goose 排在第 9 位，
        // 只有第 3 关 pick(9) 才含它。不显式补进来，第 2 关的 prefabs.get('goose')
        // 就是 undefined，金鹅会**静默**不生成（没有报错，只是彩蛋消失）。
        if (level.goldenGoose && !ids.includes(GameManager.GOLDEN_ID)) {
            ids.push(GameManager.GOLDEN_ID);
        }
        return ids;
    }

    /** 首次进入关卡的统一入口：确认有次数后再扣减、加载和生成。 */
    private async startInitialRound(): Promise<boolean> {
        if (!await this.loadLevelAssets(this.level, () => void this.beginRound())) return false;
        // 这个入口也会在“退出本局 → 返回地图 → 再次出发”时复用，不能只依赖构造初值。
        // 上一局的救场、提示和连击状态必须在生成新堆前归零，避免重进后继承半局状态。
        this.rescueUsed = false;
        this.gmUsedThisRound = this.gmEnabled;
        this.loseReason = '';
        this.rockWarned = false;
        this.frozenWarned = false;
        this.frozenTags = [];
        this.frostMarksShown = false;
        this.interactionLocked = false;
        this.score = 0;
        this.combo = 0;
        this.lastMatchAt = -99;
        this.idleTime = 0;
        this.physAccum = 0;
        this.hud?.clearFrostMarks();
        this.hud?.setCombo(0, 0);
        this.hud?.setScore(0);
        this.consumeDaily();
        this.resetProps();
        this.spawnItems();
        this.playing = true;
        this.trackRoundStart();
        this.updateHud();
        return true;
    }

    private trackRoundStart() {
        this.promoVideo.close();
        this.audio?.setSuspended(false);
        this.promoShown = false;
        this.timeoutOffered = false;
        this.timeoutOfferOpen = false;
        this.hud?.hidePromoGoose();
        this.roundStartedAt = performance.now();
        this.roundId = `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;
        Telemetry.track('round_start', {
            roundId: this.roundId,
            theme: getActiveTheme().id,
            level: this.levelIndex + 1,
            itemCount: this.totalCount,
            dailyLeft: this.dailyLeft,
            gm: this.gmEnabled,
        });
    }

    /**
     * 正式开局前的资源门禁。任何一个物件缺失都会破坏“三的倍数”与难度口径，
     * 因此不能像旧版那样跳过缺件继续生成；保留当前页面并给玩家一次明确的重试入口。
     */
    private async loadLevelAssets(level: LevelDef, retry: () => void): Promise<boolean> {
        const missing = await this.prefabs.loadAll(this.levelPrefabIds(level));
        if (missing.length === 0) return true;
        console.error(`[GameManager] 关卡资源不完整：${missing.join(', ')}`);
        Telemetry.track('asset_load_failed', {
            theme: getActiveTheme().id, level: this.levelIndex + 1, missing: missing.join(','),
        });
        this.hud?.showNotice('资源加载失败', '部分物件没有加载成功\n请检查网络后重新加载',
            '重新加载', () => {
                this.hud?.hideResult();
                retry();
            });
        return false;
    }

    // ---------- 每日次数 / 最好成绩 ----------

    private loadDaily() {
        this.dailyLeft = SaveData.getDaily(GameManager.DAILY_FREE);
        this.hud?.setDaily(this.dailyLeft);
    }

    private saveDaily() {
        SaveData.setDaily(this.dailyLeft);
        this.hud?.setDaily(this.dailyLeft);
    }

    private consumeDaily() {
        this.dailyLeft = Math.max(0, this.dailyLeft - 1);
        this.saveDaily();
    }

    private loadBest() {
        this.best = SaveData.getBest(getActiveTheme().id);
    }

    /**
     * 记录本关成绩,返回是否刷新纪录。
     * 以得分为首要排序：得分包含完成度（每消一组必得分）又区分连击水平，比单看完成度更细。
     */
    private recordBest(lvl: number, stars: number, progress: number, score: number): boolean {
        const prev = this.best[lvl];
        const prevScore = prev?.score ?? 0;
        const better = !prev || score > prevScore
            || (score === prevScore && progress > prev.progress);
        if (better) {
            this.best[lvl] = { stars, progress, score };
            SaveData.setBest(getActiveTheme().id, this.best);
        }
        return better && !!prev; // 首次成绩不算"刷新纪录"
    }

    /**
     * 固定步长推进物理，再按余量做渲染插值。
     *
     * 插值那一步不是锦上添花：固定 1/120 配 60Hz 渲染是 2:1 采样，不插值就是逐帧抖
     * ——本工程为这个坑付过一次代价。旧实现没有插值，只能靠"步长必须整除帧长"来回避，
     * 于是步长一改就抖；现在插值兜住了混叠，步长成了纯粹的精度旋钮。
     */
    private stepPhysics(frameDt: number) {
        if (!this.jolt.isReady) return;
        const STEP = GameManager.FIXED_STEP;
        this.physAccum += frameDt;
        let steps = 0;
        while (this.physAccum >= STEP && steps < GameManager.MAX_STEPS_PER_FRAME) {
            this.jolt.step(STEP);
            this.physAccum -= STEP;
            steps++;
        }
        // 欠账超过上限就丢弃，别攒着——攒下来的步数会在之后某一帧集中爆发。
        if (this.physAccum > STEP * GameManager.MAX_STEPS_PER_FRAME) this.physAccum = 0;
        this.jolt.syncNodes(this.physAccum / STEP);
    }

    /** 递归把节点树全部放进 DEFAULT 渲染层（代码创建的节点 layer 可能为 0 → 任何相机都不画） */
    private forceLayer(n: Node) {
        n.layer = Layers.Enum.DEFAULT;
        for (const c of n.children) this.forceLayer(c);
    }

    update(dt: number) {
        if (this.promoVideo.active) return;
        this.background?.sync();
        this.hud?.sync();
        this.syncFrostMarks();
        // 手机切后台/浏览器标签页恢复时可能一次传入数百秒 dt；游戏计时应近似暂停，
        // 不能因为系统挂起而瞬间耗尽。
        const frameDt = Math.min(dt, 0.1);
        // 物理**不受暂停与胜负影响**地推进到收敛：暂停时堆本来就该停在原地，而 Jolt
        // 休眠后步进几乎零成本；结算画面里堆还在缓慢落定也属正常观感。放在 playing
        // 判定之前，是为了让开局倾倒能在弹窗期间就跑完。
        this.stepPhysics(frameDt);
        if (!this.playing || this.paused) return;
        this.hud?.advancePromoGoose(frameDt);
        this.timeLeft -= frameDt;
        if (!this.promoShown && this.timeLeft > 0 && this.timeLeft <= this.level.timeSec / 2) {
            this.promoShown = true;
            this.hud?.showPromoGoose(() => void this.watchGoosePromo());
        }
        if (this.timeLeft <= 0) {
            this.timeLeft = 0;
            this.gameOver(false, '时间到');
            this.updateHud();
            return;
        }
        // 发呆到点就指一组可消的物件：卡在"看不出还能点什么"是这类玩法最常见的弃局原因。
        this.idleTime += frameDt;
        if (this.gmEnabled && this.idleTime >= GameManager.HINT_IDLE) {
            this.idleTime = 0;
            this.showHint();
        }
        this.hud?.setTimeUrgent(this.timeLeft <= GameManager.URGENT_SEC);
        this.updateCombo();
        this.updateHud();
    }

    /** 把连击窗口的剩余比例喂给 HUD 的连击牌；窗口走完即断连。 */
    private updateCombo() {
        if (this.combo <= 0) { this.hud?.setCombo(0, 0); return; }
        const elapsed = performance.now() / 1000 - this.lastMatchAt;
        const remain = 1 - elapsed / GameManager.COMBO_WINDOW;
        if (remain <= 0) this.combo = 0;
        this.hud?.setCombo(this.combo, Math.max(0, remain));
    }

    // ---------- 提示 ----------

    /**
     * 找一组"现在点下去就能消"的物件：优先补齐槽内已有的类别（步数最少），
     * 其次退回盒中任意凑得出 3 个的类别。石头不参与（它永远配不齐）。
     */
    private findHintGroup(): Node[] {
        // 冰封件点不动，不能算进"可用"，否则会指出一组玩家根本拿不到的件。
        const boxItems = this.node.getComponentsInChildren(ItemTag)
            .filter(t => !t.picked && t.node.isValid && t.id !== DISTRACTOR_ID && !t.frozen);
        const availOf = (id: string) => boxItems.filter(t => t.id === id).length;
        const free = TRAY_CAPACITY - this.tray.count;

        let target: { id: string; need: number } | null = null;
        for (const [id, have] of this.tray.countById()) {
            const need = 3 - have;
            if (need <= 0 || need > free || availOf(id) < need) continue;
            if (!target || need < target.need) target = { id, need };
        }
        if (!target && free >= 3) {
            const id = boxItems.find(t => availOf(t.id) >= 3)?.id;
            if (id) target = { id, need: 3 };
        }
        if (!target) return [];
        // 越靠上的越容易点到，优先指这些。
        return boxItems.filter(t => t.id === target!.id)
            .sort((a, b) => b.node.worldPosition.y - a.node.worldPosition.y)
            .slice(0, target.need)
            .map(t => t.node);
    }

    /** 把提示组的世界坐标换成屏幕坐标交给 HUD 画呼吸光环（不碰 3D 物件本身）。 */
    private showHint() {
        if (!this.playing || this.paused || !this.cam) return;
        const nodes = this.findHintGroup();
        if (nodes.length === 0) {
            // 一组都凑不齐 = 槽位余量不够，指一下「移出」，别让玩家干瞪眼等超时。
            if (this.tray.count > 0) this.hud?.nudgeProp('remove');
            return;
        }
        const sp = v3();
        this.hud?.showHint(nodes.map(n => {
            this.cam.worldToScreen(n.worldPosition, sp);
            return sp.clone();
        }));
    }

    /**
     * 残局判定：把槽位余量和盒中存量算在一起，已经配不出任何一组三消。
     * 此前这种局面只能靠玩家自己发现，然后要么把七格填满、要么干等倒计时归零——
     * 两种结局都让人觉得是游戏卡住了，而不是自己输了。
     */
    private checkDeadlock() {
        if (!this.playing || this.paused || this.interactionLocked) return;
        if (this.removedCount >= this.totalCount) return;
        if (this.findHintGroup().length > 0) return;
        // 冰封件挡住了所有可消组 → 全部化开，而不是判负。
        // 这是"冰封绝不制造死局"的最后一道保险：解冻本身依赖三消，
        // 一旦玩家凑不出任何一组就再也化不开冰，那才是真锁死。
        const thawed = this.thawAll();
        if (thawed > 0) {
            this.hud?.toast(`冰层化开了 ${thawed} 件`);
            return;
        }
        // 还有「移出」道具 = 这是解得开的残局，指一下就够，不替玩家判负。
        if (this.gmEnabled || this.propCounts.remove > 0) {
            this.hud?.nudgeProp('remove');
            this.hud?.toast('没有能凑齐的组合了，用「移出」腾格');
            return;
        }
        this.gameOver(false, '无解');
    }

    /** 槽内该类物件刚好攒到 2 件 → 闪一下这两格（重算下标，避免连点后指错格）。 */
    private flashNearMatch(id: string) {
        const idx: number[] = [];
        this.tray.entries.forEach((e, i) => { if (e.id === id) idx.push(i); });
        if (idx.length === 2) this.hud?.markNearMatch(idx);
    }

    // ---------- 场景搭建 ----------

    /** 当前皮肤配置。 */
    private currentSkin(): SceneSkin {
        return getSkin(this.skinId);
    }

    /**
     * 换肤：持久化选择并原地重建场景视觉 + 围栏。物件在 this.node 上、与 sceneRoot 平级，
     * 不受重建影响；围栏几何各皮肤一致，重建后物件贴靠关系不变。
     */
    /**
     * 切换场景主题：一次换齐**物件族 + 皮肤 + 容器**，并重开当前关。
     *
     * 与 {@link applySkin} 的区别是它改的是玩什么，不只是长什么样。历史实现里主题按
     * 日期锁定、换肤面板只改视觉，于是能切出「翡翠碗装水果」这种不搭的组合。
     *
     * 必须重开关卡：物件族变了，堆里那批旧模型既不属于新主题、也凑不出新的三消组。
     * 重开走 resetLevel，它会清掉旧刚体（clearBodies）并按新 LEVELS 重新投放。
     */
    applyTheme(themeId: string, restart = true) {
        if (getActiveTheme().id === themeId) return;
        SaveData.setTheme(themeId);
        refreshLevels();                       // 先重建关卡表，下面才拿得到新物件族
        this.applySkin(getActiveTheme().skinId);
        // 场景与难度是两个独立选择，切地图不能偷偷把玩家选好的难度改回轻松。
        this.level = LEVELS[this.levelIndex] ?? LEVELS[0];
        this.loadBest();                       // 成绩按主题分开存，换主题要重新读
        // restart=false 用于开始页：那里只是在挑场景，还没入局，不该把物件倒出来。
        if (restart) void this.resetLevel();
        else this.updateHud();
    }

    applySkin(id: string) {
        if (id === this.skinId && this.sceneRoot?.isValid) return;
        this.skinId = getSkin(id).id;
        SaveData.setSkin(this.skinId);
        if (this.sceneRoot?.isValid) this.sceneRoot.destroy();
        this.sceneRoot = null;
        this.buildBox();
        const skin = this.currentSkin();
        this.background?.setBackdrop(skin.backdropTex, skin.backdrop);
        this.audio?.play('prop');
    }

    /**
     * 由皮肤的边界声明构造容器边界；未声明则回落到默认矩形（与本类常量一字不差，
     * 保证现有 6 套矩形皮肤的围栏 / 逃逸 / 视觉兜底行为完全不变）。
     */
    private static makeBoundary(def: BoundaryDef | undefined): ContainerBoundary {
        if (def) return new ContainerBoundary(def);
        return new ContainerBoundary({
            wall: {
                kind: 'rect', cx: 0,
                cz: GameManager.FENCE_CENTER_Z,
                halfX: GameManager.FENCE_HALF_X,
                halfZ: GameManager.FENCE_HALF_Z,
            },
            clamp: {
                kind: 'rect', cx: 0,
                cz: (GameManager.VISIBLE_MIN_Z + GameManager.VISIBLE_MAX_Z) / 2,
                halfX: GameManager.VISIBLE_HALF_X,
                halfZ: (GameManager.VISIBLE_MAX_Z - GameManager.VISIBLE_MIN_Z) / 2,
            },
        });
    }

    private buildBox() {
        // 容器视觉与围栏统一挂在可重建的 SceneRoot 下，换肤时整体替换。
        const root = new Node('SceneRoot');
        root.setParent(this.node);
        this.sceneRoot = root;

        const skin = this.currentSkin();
        // 边界随皮肤重建：矩形皮肤得到与常量一字不差的默认边界；圆锅/圆碗皮肤声明
        // boundary 后，围栏 / 逃逸 / 视觉兜底 / 投放种子全部按该形状生效，物品不出界。
        this.boundary = GameManager.makeBoundary(skin.boundary);
        // 换肤会重建整个容器：旧的静态体必须先清掉，否则新旧围栏叠在一起，
        // 物件会被卡在两层墙之间。动态件不受影响，贴靠关系保持不变。
        this.jolt.clearStatics();
        // 但必须把动态件全部唤醒：围栏几何变了，休眠中的刚体不会自己发现自己卡在新墙里。
        // 矩形筐的角落距碗心 1.96、碗壁半径只有 1.65——落在角上的件换肤后就在墙外，
        // 不唤醒就永远停在那儿，看着像穿模。
        this.jolt.wakeAll();

        // 碰撞地基顶面保持 y=0，厚地基防止高速物件穿底。
        // 物理底板始终居中覆盖整个围栏，与视觉完全解耦。
        this.makeInvisibleWall('basketFloorCollider', v3(0, -2.25, -0.88), v3(4.1, 4.5, 4.15));

        // 隐形围栏（只有碰撞体，无渲染）：厚 1.2、下探到台面以下，杜绝高速隧穿和底缝钻出。
        // 墙段由当前边界生成——矩形出 4 面厚墙（与旧硬编码等价），圆形出一圈切向环段。
        const WH = 7, WT = 1.2, WY = WH / 2 - 1; // 竖向覆盖 -1 ~ 6
        // meshCollider 皮肤（碗这类曲面容器）的围栏退化成**外圈安全网**：真正的碰撞由
        // 模型网格承担（见 loadContainerModel 末尾），但那是异步加载的，加载完成前得有
        // 东西兜住物件。安全网按 clamp 半径建，比碗口还大一圈，正常游戏中碰不到。
        const fenceShape = skin.meshCollider ? this.boundary.clamp : this.boundary.wall;
        const wallSpecs = new ContainerBoundary({ wall: fenceShape, clamp: fenceShape })
            .buildWallSpecs(WH, WY, WT);
        for (const w of wallSpecs) {
            this.makeInvisibleWall(w.name, w.pos, w.size, w.yawDeg);
        }

        // 调试：把物理容纳画出来叠在容器上，用于对齐视觉容器、排查穿模。
        if (GameManager.DEBUG_FENCE) {
            // 围栏墙段：青色半透明，直接勾出 boundary 的 XZ 形状（矩形 4 面 / 圆形环段）。
            for (const w of wallSpecs) {
                DebugViz.box(root, `dbg_${w.name}`, w.pos, w.size, w.yawDeg, new Color(0, 200, 255, 70));
            }
            // 物理静止面（地板顶面 y=0，始终是那块矩形底板）：物件实际停靠的高度。
            // 薄黄片，用来比对容器可见内底是否与之齐平（不齐 = 悬空或陷底穿模）。
            DebugViz.box(root, 'dbg_restPlane',
                v3(0, 0, -0.88), v3(4.1, 0.02, 4.15),
                0, new Color(255, 220, 0, 80));
        }

        // 背景改由 SceneBackground 的全屏 2D Sprite 承接（skin.backdrop/backdropTex），
        // 这里不再铺 3D 大地板与柜框——正交相机下那块 44×44 平面只框得住中心纯色区，
        // 会把整屏背景图四周的装饰全裁掉，正是之前"背景完全不对"的根因。

        // 代码新建的节点 layer 可能为 0（任何相机都不画）；运行时换肤走这里，
        // start() 的整树 forceLayer 不会再触发，必须自己把新场景放进 DEFAULT 渲染层。
        this.forceLayer(root);

        // 方案 B：中央置物筐用 3D 模型。异步加载后摆到容器中央、按开口缩放定位。
        // 捕获当前 root，加载期间若又换肤（root 被销毁）则丢弃结果。
        if (skin.containerModel) this.loadContainerModel(skin.containerModel, root);

        // 七格收集区属于屏幕 HUD，由 HudUI 负责；世界空间只保留可替换的 3D 容器。
    }

    /** 置物筐外观：目标水平占地（世界单位，整宽），略大于物件散布范围（±VISIBLE_HALF_X）。 */
    private static readonly CONTAINER_SPAN = 4.0;
    /** 置物筐底部相对台面(y=0)的落点：负值让筐壁从台面下升起，内底约与物件停靠面齐平。 */
    private static readonly CONTAINER_BOTTOM_Y = -0.35;

    /**
     * 加载并摆放中央 3D 置物筐（skin.containerModel）。
     * 纯外观：不挂刚体/碰撞，物理仍由隐形围栏约束。摆放：水平居中于 boundary 中心，
     * 按最大水平边缩放到 CONTAINER_SPAN，底部坐到 CONTAINER_BOTTOM_Y。
     * 缩放/落点最终需按截图微调这两个常量。
     */
    private async loadContainerModel(id: string, root: Node) {
        const prefab = await PrefabCache.loadOne(id);
        // 加载期间换肤：root 已被销毁或已不是当前 sceneRoot，丢弃。
        if (!prefab || !root.isValid || root !== this.sceneRoot) return;

        const n = instantiate(prefab);
        n.setParent(root);
        n.setScale(1, 1, 1);
        n.setPosition(0, 0, 0);
        this.forceLayer(n);
        n.updateWorldTransform();

        // 量原始局部包围盒（未缩放），据此求居中缩放与落点。
        const b = this.measureLocalAabb(n);
        if (!b) { console.warn(`[GameManager] 置物筐 ${id} 无网格包围盒，按原样摆放`); return; }
        const w = b.max.x - b.min.x, d = b.max.z - b.min.z, h = b.max.y - b.min.y;
        // 带外置把手的容器会扩大 AABB，但把手不属于可玩内区；允许皮肤声明更大的视觉宽度，
        // 保证内盘仍与固定物理边界对齐。未知/旧皮肤继续使用 4.0，玩法尺寸不受影响。
        const visualSpan = this.currentSkin().containerSpan ?? GameManager.CONTAINER_SPAN;
        const s = visualSpan / Math.max(w, d, 1e-3);
        n.setScale(s, s, s);

        // 缩放后，把模型自身中心平移到 boundary 中心，底部坐到 CONTAINER_BOTTOM_Y。
        const cx = (b.min.x + b.max.x) * 0.5, cz = (b.min.z + b.max.z) * 0.5;
        n.setPosition(
            this.boundary.centerX - cx * s,
            GameManager.CONTAINER_BOTTOM_Y - b.min.y * s,
            this.boundary.centerZ - cz * s,
        );

        // 容器是环境陈设：不投阴影（避免自遮挡怪影），只接收物件阴影。
        for (const mr of n.getComponentsInChildren(MeshRenderer)) {
            mr.shadowCastingMode = MeshRenderer.ShadowCastingMode.OFF;
        }
        console.log(`[GameManager] 置物筐 ${id} 就位：原始尺寸 w=${w.toFixed(2)} d=${d.toFixed(2)} h=${h.toFixed(2)}，缩放=${s.toFixed(3)}`);

        // 曲面容器：拿模型自己的网格做静态碰撞体，取代拼出来的环墙。
        // 必须放在缩放与落点都定好之后——顶点是按节点世界变换烘进去的。
        if (this.currentSkin().meshCollider) {
            const tris = this.jolt.addStaticMesh(n,
                GameManager.PILE_FRICTION, GameManager.PILE_RESTITUTION);
            if (tris > 0) {
                // 网格就位后唤醒全部动态件：它们可能正落在旧安全网与新碗壁之间。
                this.jolt.wakeAll();
                console.log(`[GameManager] ${id} 网格碰撞体就位：${tris} 三角形`);
            } else {
                console.warn(`[GameManager] ${id} 读不出网格，仍靠围栏安全网约束`);
            }
        }
    }

    /** 量节点下所有 Mesh 的局部包围盒（root 局部空间）。无网格返回 null。 */
    private measureLocalAabb(root: Node): { min: Vec3; max: Vec3 } | null {
        root.updateWorldTransform();
        const min = v3(Infinity, Infinity, Infinity);
        const max = v3(-Infinity, -Infinity, -Infinity);
        const invRoot = new Mat4();
        const meshToRoot = new Mat4();
        const corner = v3(), point = v3();
        Mat4.invert(invRoot, root.worldMatrix);
        let has = false;
        for (const renderer of root.getComponentsInChildren(MeshRenderer)) {
            const mn = renderer.mesh?.struct.minPosition, mx = renderer.mesh?.struct.maxPosition;
            if (!mn || !mx) continue;
            Mat4.multiply(meshToRoot, invRoot, renderer.node.worldMatrix);
            for (let mask = 0; mask < 8; mask++) {
                corner.set(mask & 1 ? mx.x : mn.x, mask & 2 ? mx.y : mn.y, mask & 4 ? mx.z : mn.z);
                Vec3.transformMat4(point, corner, meshToRoot);
                Vec3.min(min, min, point);
                Vec3.max(max, max, point);
                has = true;
            }
        }
        return has ? { min, max } : null;
    }

    /**
     * 只有物理没有外观的围栏；yawDeg 用于圆容器的切向环段（矩形墙传 0）。
     *
     * 不再建 Cocos 节点：围栏纯粹是物理实体，没有渲染内容也不需要被射线打到
     * （Jolt 的拾取只收动态层）。直接进 Jolt 的静态层，换肤时 clearStatics 整体重建。
     */
    private makeInvisibleWall(_name: string, pos: Vec3, size: Vec3, yawDeg = 0) {
        this.jolt.addStaticBox(pos, size, yawDeg,
            GameManager.PILE_FRICTION, GameManager.PILE_RESTITUTION);
    }

    // ---------- 物件加载与生成 ----------

    /** 整数散列 → [0,1)。给铺点做确定性抖动：同一 index 永远同一个值，
     *  所以投放与「打乱」两条路径互不干扰，也不吃 levelRandom 的调用顺序。 */
    private static hash01(n: number): number {
        let h = Math.imul(n ^ 0x9e3779b9, 0x85ebca6b);
        h = Math.imul(h ^ (h >>> 13), 0xc2b2ae35);
        return ((h ^ (h >>> 16)) >>> 0) / 4294967296;
    }

    private static gcd(a: number, b: number): number {
        while (b) { const t = a % b; a = b; b = t; }
        return a;
    }

    /**
     * 投放落点（投放与"打乱"共用，两处必须同形，否则打乱一次堆形就变了）。
     *
     * 历史实现是「极坐标小圆盘 + 半径随进度扩大」，两个毛病叠在一起：
     * 盘是圆的而筐底是方的（四角撒不到点）、盘还只有半径 0.72 而筐内半宽 1.35。
     * 结果所有件都往中间同一小片地方落，而每件 spawn 后 0.9s 就硬冻、来不及滚开，
     * 于是必然长成一根柱子——实测第 1 关 24 件顶到 y=4.65、第 3 关 56 件顶到 y=5.53
     * （筐沿 y≈1.0），筐的外圈整整一圈是空的。
     * 正交俯视相机下高度不改变投影大小，柱子在截图上和摊平的堆长得一样，
     * 只有读 y 坐标才看得出来。**改这个函数务必同时量 y 分布与筐内像素覆盖率。**
     *
     * 现在按「一层一层铺」：先按单件占地算出一层放得下几件，同层的点按分格抖动
     * 铺满整个容器形状（矩形连四角都铺到），下一层错半格、并向内收 PILE_LAYER_INSET
     * 形成自然坡度。件数少就只铺一层，多了自然叠高。
     *
     * 层内用「分格 + 格内抖动」而不是低差异序列：一层只有十来个点，Halton 那种
     * 序列在这个量级上仍会留下整片空斑（实测第 2 关有一块 1791 采样格的裸底）；
     * 分格采样对固定点数给出硬保证——每格必有一点，空斑不可能大过一格。
     */
    private pileSeedPoint(index: number): { x: number; z: number } {
        // 内缩小于外接盒半宽，靠真实碰撞约束边缘，避免堆体落定后只剩中央一团。
        const w = this.itemScale * GameManager.PILE_ITEM_WIDTH_K;
        const span = this.itemScale * GameManager.PILE_ITEM_SPAN_K;
        const perLayer = Math.max(4, Math.floor(
            this.boundary.usableArea(0) / (span * span) * GameManager.PILE_PACK));
        const layer = Math.floor(index / perLayer);
        const j = index % perLayer;

        // 网格按容器长宽比开方，格子尽量接近正方形（细长格会让件排成行列）。
        const s = this.boundary.wall;
        const aspect = s.kind === 'rect' ? s.halfX / Math.max(0.01, s.halfZ) : 1;
        const cols = Math.max(1, Math.round(Math.sqrt(perLayer * aspect)));
        const rows = Math.max(1, Math.ceil(perLayer / cols));
        // 格子数常比点数多，多出来的空格必须**散开**：按与格数互质的步长跳着取，
        // 否则空格永远集中在最后一行，那一侧就固定裸着一条。
        const cells = rows * cols;
        let stride = Math.max(1, Math.round(cells * 0.618));
        while (GameManager.gcd(stride, cells) !== 1) stride++;
        const cell = (j * stride + layer * 3) % cells;
        // 上层整体错半格：件落进下层的凹处（砌砖式），既不叠成柱，也少悬空。
        const half = layer % 2 ? 0.5 : 0;
        const u1 = ((cell % cols) + 0.15 + 0.7 * GameManager.hash01(index * 2 + 1) + half) / cols;
        const u2 = (Math.floor(cell / cols) + 0.15 + 0.7 * GameManager.hash01(index * 2 + 2)) / rows;
        const edgeInset = s.kind === 'rect' ? w * 0.15 : w * 0.35;
        return this.boundary.seedPoint(u1 % 1, u2 % 1,
            edgeInset + layer * GameManager.PILE_LAYER_INSET);
    }

    private spawnItems() {
        this.levelRandomState = this.level.seed >>> 0 || 1;
        const queue: string[] = [];
        for (const id of this.level.items) {
            const prefab = this.prefabs.get(id);
            if (!prefab) continue;
            const count = this.level.groupsPerItem * 3;
            for (let i = 0; i < count; i++) queue.push(id);
        }
        this.shuffleInPlace(queue, () => this.levelRandom());
        // 胜利判定只算正常物件：石头无法三消，不能计入 totalCount，否则 removedCount 永远追不上。
        this.totalCount = queue.length;
        // 混入障碍物（石头）：一起投放但不计胜利。≤2 个永不配齐 → 占格残局风险。
        // push 后整队再洗一次，让石头散落堆中而非全压在最外圈。
        const nRock = this.level.distractors ?? 0;
        if (nRock > 0 && this.prefabs.get(DISTRACTOR_ID)) {
            for (let i = 0; i < nRock; i++) queue.push(DISTRACTOR_ID);
            this.shuffleInPlace(queue, () => this.levelRandom());
        }
        // 金鹅彩蛋：**unshift 而不是 push**，它必须第一个投放才会落在堆的最底层
        // （pileSeedPoint 按 index 分层，index 0 就是第 0 层）。放在这里而不是更早，
        // 是为了不被上面那次 shuffle 打散位置，也不影响已定好的 totalCount——
        // 金鹅不计入胜利判定，挖不到它照样能通关。
        const wantGolden = !!this.level.goldenGoose && !!this.prefabs.get(GameManager.GOLDEN_ID);
        if (wantGolden) queue.unshift(GameManager.GOLDEN_ID);
        // 件的大小由「铺满筐底 PILE_TARGET_LAYERS 层」反解：N 件均分筐底面积，
        // 每件分到 area/N × 层数，开方即占地宽，除以占地宽系数得缩放。
        // 于是换容器（圆碗 vs 方筐）、改件数都不用再手调缩放，满度自动一致。
        this.itemScale = Math.min(GameManager.PILE_ITEM_MAX, Math.max(GameManager.PILE_ITEM_MIN,
            Math.sqrt((this.level.pileLayers ?? GameManager.PILE_TARGET_LAYERS) * this.boundary.usableArea(0)
                / Math.max(1, queue.length)) / GameManager.PILE_ITEM_SPAN_K));

        // 选出要冰封的件：**每种物件最多 1 个**，从每种里各取一个候选再随机挑 N 种。
        // 这条约束就是"冰封不会锁死任何一组"的来源——每组至少还剩 2 个可拿。
        // 石头（本来就是负担）与金鹅（是奖励）都不参与。
        const frozenIdx = new Set<number>();
        const nFrozen = this.level.frozen ?? 0;
        if (nFrozen > 0) {
            // 每种取**最后**一次出现的位置，而不是第一次：queue 的下标就是投放顺序，
            // 前部落在堆底。取第一次出现会把冰封件全埋进底层，玩家整局看不到几个蓝的，
            // 机制就没了体感。取最后一次 → 落在上层 → 开局就看得见"有几件冻着"。
            const lastIdx = new Map<string, number>();
            queue.forEach((id, i) => {
                if (id === DISTRACTOR_ID || (wantGolden && i === 0)) return;
                lastIdx.set(id, i);
            });
            // 用 forEach 收集而不是 [...lastIdx.values()]：本项目的 TS 编译目标会把
            // 展开运算符降级成 [].concat(iterator)，而 concat **不展开迭代器**——
            // 它把整个 MapIterator 当成单个元素塞进数组，于是 cands 里是个对象而不是
            // 下标，frozenIdx.has(index) 永远 false，冰封**静默**失效且不报错。
            const cands: number[] = [];
            lastIdx.forEach(i => cands.push(i));
            this.shuffleInPlace(cands, () => this.levelRandom());
            for (const i of cands.slice(0, nFrozen)) frozenIdx.add(i);
        }

        queue.forEach((id, index) => {
            const prefab = this.prefabs.get(id)!;
            const idx = index + 1;
            // 逐件投放保留真实碰撞过程，同时避免同一帧生成几十个刚体导致求解器爆开。
            const delay = idx * GameManager.SPAWN_INTERVAL;
            this.scheduleOnce(() => {
                const n = instantiate(prefab);
                n.setParent(this.node);
                this.forceLayer(n);
                // 按容器形状铺点，靠物理碰撞形成多层堆叠。
                const seed = this.pileSeedPoint(index);
                // 生成点在容器沿略上方（见 PILE_SPAWN_Y）：件贴着堆顶落定而不是从高处砸下。
                n.setPosition(
                    seed.x + (this.levelRandom() - 0.5) * 0.12,
                    GameManager.PILE_SPAWN_Y + (idx % 5) * 0.22,
                    seed.z + (this.levelRandom() - 0.5) * 0.08,
                );
                // 参考录屏中单件约为篮宽的 1/6；66 件时形成紧凑但不过高的堆。
                // 根节点直接给最终缩放：它的位姿归物理管，弹大动画改由视觉子树承担
                // （见下方 tween），否则 syncNodes 每帧都会把缩放外的改动一并冲掉。
                const baseScale = this.itemScale + (idx % 4) * 0.012;
                const scale = baseScale * (GameManager.ITEM_SCALE_MULTIPLIER[id] ?? 1);
                n.setScale(scale, scale, scale);

                const tag = n.addComponent(ItemTag);
                tag.id = id;
                // 队首那一只（且本关开了彩蛋）就是金鹅：染金 + 略放大，挖出来时一眼认得出。
                if (wantGolden && index === 0) {
                    tag.golden = true;
                    GameManager.paintGolden(n);
                } else if (frozenIdx.has(index)) {
                    tag.frozen = true;   // 冰壳在碰撞体设定之后再加，见下方
                }
                // 视觉归心 + 量出碰撞代理。必须在加冰壳**之前**：冰壳是子节点上的
                // MeshRenderer，先加会把包围盒撑大 18%，代理跟着变大，冰封件之间
                // 凭空多出一圈间隙。
                const shape = this.centerVisualAndMakeShape(n, id, scale);
                if (tag.frozen) {
                    this.addIceShell(n, tag);
                    this.frozenTags.push(tag);
                }
                this.setNaturalRotation(n, id, () => this.levelRandom());

                // 薄片(铜钱/玉环/平安扣等)只给绕竖轴的自转(改朝向、仍拍平落),
                // 大幅收窄横轴翻滚——否则它们在半空翻立起来边缘着地、圆柱立着打滚,
                // 是这类物件抖动/蹭墙/堆乱的主因。非薄片保留全向翻滚的自然感。
                const tumble = GameManager.ROUND_ITEMS.has(id) ? 0.25 : 1.2;
                const key = this.jolt.spawn(n, {
                    shape,
                    mass: 0.85 + (idx % 3) * 0.1,
                    // 低阻尼 = 真实自由落体。旧值 0.92/0.97 像掉进糖浆，
                    // 下落绵软且落地后长时间蠕动，是"摔落不真实"的直接原因。
                    linearDamping: 0.06,
                    angularDamping: 0.3,
                    friction: GameManager.PILE_FRICTION,
                    restitution: GameManager.PILE_RESTITUTION,
                    useCCD: true,
                    position: n.worldPosition.clone(),
                    rotation: n.worldRotation.clone(),
                    linearVelocity: v3(
                        (this.levelRandom() - 0.5) * 0.2,
                        -2.6,
                        (this.levelRandom() - 0.5) * 0.2,
                    ),
                    angularVelocity: v3(
                        (this.levelRandom() - 0.5) * tumble,
                        (this.levelRandom() - 0.5) * 1.2,
                        (this.levelRandom() - 0.5) * tumble,
                    ),
                });
                tag.bodyKey = key;

                // 弹大动画只作用于**视觉子树**，不是根节点——根节点的位姿现在归物理管，
                // 缩放它会被下一帧的 syncNodes 冲掉。碰撞代理按最终尺寸一次建好、不随
                // 弹大变化：弹大全程 0.15s 在半空无接触段，代理略大于视觉不会推挤邻居。
                for (const child of n.children) {
                    child.setScale(GameManager.SPAWN_POP_FROM, GameManager.SPAWN_POP_FROM, GameManager.SPAWN_POP_FROM);
                    // 三段弹性出现比一次 backOut 更容易在密堆里看见：先略微超过最终尺寸，
                    // 再收一下并落稳。只缩放视觉子树，Jolt 碰撞体始终保持最终尺寸。
                    tween(child)
                        .to(GameManager.SPAWN_POP_TIME * 0.55, { scale: v3(1.10, 1.10, 1.10) },
                            { easing: 'backOut' })
                        .to(GameManager.SPAWN_POP_TIME * 0.22, { scale: v3(0.96, 0.96, 0.96) },
                            { easing: 'quadInOut' })
                        .to(GameManager.SPAWN_POP_TIME * 0.23, { scale: v3(1, 1, 1) },
                            { easing: 'sineOut' })
                        .start();
                }
                // 物件投平面阴影
                for (const mr of n.getComponentsInChildren(MeshRenderer)) {
                    mr.shadowCastingMode = MeshRenderer.ShadowCastingMode.ON;
                }
                // 这里**没有**定时硬冻了。物件停下来的唯一途径是 Jolt 自己的休眠——
                // 那正是这次换引擎买到的东西，别再往回加任何脚本冻结。
            }, delay);
        });
        // 这里原本有一次"整堆定时锁死"的兜底。Jolt 下不需要也不允许：堆自己会在
        // 约 1.5s 内落定并休眠（实验数据见 lab/results/poc-b-jolt.json）。
        console.log(`[GameManager] 关卡 ${this.levelIndex + 1}：生成 ${this.totalCount} 个物件，seed=${this.level.seed}`);
    }

    /**
     * GLB 场景根节点经常保留 DCC 中的平移（部分模型偏移超过 2 个世界单位）。
     * 旧实现把碰撞盒固定放在 Prefab 根节点，视觉模型却在旁边，物理上没有真正包住模型。
     * 这里读取所有 Mesh 的局部包围盒，统一把视觉内容移回根节点中心，再按真实尺寸生成碰撞盒。
     */
    private centerVisualAndMakeShape(root: Node, id: string, scale: number): ProxyShape {
        // 刚实例化并 setPosition/setScale 的节点，worldMatrix 可能仍是上一帧缓存。
        // 若直接求 bounds，会把“生成落点”误算进模型自身偏移，再次平移视觉子树，
        // 结果就是碰撞体分散在篮底、所有可见模型却挤到同一侧，看起来严重穿模。
        root.updateWorldTransform();
        const renderers = root.getComponentsInChildren(MeshRenderer);
        const min = v3(Infinity, Infinity, Infinity);
        const max = v3(-Infinity, -Infinity, -Infinity);
        const invRoot = new Mat4();
        const meshToRoot = new Mat4();
        const corner = v3();
        const point = v3();

        Mat4.invert(invRoot, root.worldMatrix);
        let hasBounds = false;
        for (const renderer of renderers) {
            const meshMin = renderer.mesh?.struct.minPosition;
            const meshMax = renderer.mesh?.struct.maxPosition;
            if (!meshMin || !meshMax) continue;
            Mat4.multiply(meshToRoot, invRoot, renderer.node.worldMatrix);
            for (let mask = 0; mask < 8; mask++) {
                corner.set(
                    mask & 1 ? meshMax.x : meshMin.x,
                    mask & 2 ? meshMax.y : meshMin.y,
                    mask & 4 ? meshMax.z : meshMin.z,
                );
                Vec3.transformMat4(point, corner, meshToRoot);
                Vec3.min(min, min, point);
                Vec3.max(max, max, point);
                hasBounds = true;
            }
        }

        if (!hasBounds) {
            // 资源尚未提供 bounds 时使用保守尺寸，仍比原先 0.75³ 更不容易露出模型。
            return { kind: 'box', half: v3(0.525 * scale, 0.525 * scale, 0.525 * scale) };
        }

        const center = v3(
            (min.x + max.x) * 0.5,
            (min.y + max.y) * 0.5,
            (min.z + max.z) * 0.5,
        );
        // GLB prefab 的根通常只是容器，整体平移其一级子树即可保留模型内部结构。
        for (const child of root.children) {
            child.setPosition(
                child.position.x - center.x,
                child.position.y - center.y,
                child.position.z - center.z,
            );
        }
        root.updateWorldTransform();

        // 薄片/环形件仍用圆柱：它们本来就是回转体，圆柱比凸包更便宜也更贴合，
        // 而且能保住"拍平落、不立起来打滚"的手感（凸包会把边缘棱角还原出来）。
        if (GameManager.ROUND_ITEMS.has(id)) {
            const ex = (max.x - min.x) * scale;
            const ey = (max.y - min.y) * scale;
            const ez = (max.z - min.z) * scale;
            return { kind: 'cylinder', halfHeight: ey / 2, radius: Math.max(ex, ez) / 2 };
        }

        // 其余一律凸包。这是 lab 里最关键的一条发现：碰撞代理才是堆型的决定因素，
        // 换凸包后三套引擎的堆顶都从 2.8~3.5 掉到 1.3~1.5、筐内覆盖率从 78% 涨到 87%。
        // 方盒把水果撑成方块、互相架桥垒成柱，正是旧版"堆得像塔"的根因。
        // 点集在 JoltWorld 里按方向分格抽稀到约 100 点，与 lab/poc-b-jolt 逐行一致。
        const pts = extractHullPoints(root, scale);
        if (pts.length >= 12) return { kind: 'hull', points: pts };
        // 网格读不出顶点（压缩格式/无 position 属性）时退回方盒，别让物件没有碰撞体。
        return {
            kind: 'box',
            half: v3((max.x - min.x) * scale / 2, (max.y - min.y) * scale / 2, (max.z - min.z) * scale / 2),
        };
    }

    /**
     * 把一只普通大鹅染成金鹅：材质转金 + 略放大。
     *
     * 必须走 materialInstance（`mr.material` 的 getter 会自动实例化）而不是
     * sharedMaterial——glb 里同一份材质被这一关所有大鹅共用，改 shared 会把
     * 普通鹅一起染金。属性名按 builtin-standard / builtin-unlit 两套都试一遍：
     * 不同 glb 导出的 shader 不一定相同，试错比假定安全。
     */
    private static paintGolden(root: Node) {
        const gold = new Color(255, 205, 74);
        for (const mr of root.getComponentsInChildren(MeshRenderer)) {
            const count = mr.sharedMaterials.length || 1;
            for (let i = 0; i < count; i++) {
                const mat = mr.getMaterialInstance(i);
                if (!mat) continue;
                for (const prop of ['albedo', 'mainColor', 'diffuseColor']) {
                    try { mat.setProperty(prop, gold); } catch { /* 该 shader 无此属性 */ }
                }
                try { mat.setProperty('emissive', new Color(120, 82, 12)); } catch { /* 同上 */ }
            }
        }
        const s = root.scale;
        root.setScale(s.x * 1.18, s.y * 1.18, s.z * 1.18);
    }

    /**
     * 冰封外观：**物件保持原色**，外面套一层半透明冰块 + 几粒霜晶。
     *
     * 上一版是把物件本身染成冰蓝，那条路走不通：albedo 与贴图**相乘**，
     * 红苹果乘冰蓝变紫、橙子变蓝，每件冻结后颜色都不一样，读作"另一种水果"
     * 而不是"同一种状态"；而且认不出被冻的原本是什么，玩家没法规划先消哪组。
     * 套壳则两全：里面还是原来那颗，外面统一是冰。
     *
     * 透明材质沿用 DebugViz 那套（builtin-unlit + technique 1 + 带 alpha 的
     * mainColor）——那是本仓已验证可用的唯一透明渲染路径，不必再赌别的 effect
     * 在引擎裁剪后还在不在。
     */
    private addIceShell(root: Node, tag: ItemTag) {
        const b = this.measureLocalAabb(root);
        if (!b) return;
        // 用**球**而不是立方体：俯视 45° 下立方体的大平面读作"包装盒"，还把物件挡住了；
        // 球贴合物件轮廓、边缘圆润，半透明时更像裹了一层冰。
        // 半径按包围盒最长边的一半略放，保证细长件（香蕉、玉镯）也整个裹进去。
        // 系数 1.12 → 1.34：想让"冻住了"更醒目时，**放大壳比提 alpha 划算**。
        // 超出物件轮廓的那一圈是纯壳色、不叠在物件上，包裹感增强而遮挡不增加；
        // 一味提 alpha 则会把物件冲淡（实测 a128 时紫手串已发白）。
        // 但也不能再大：实测 1.4 倍时壳会罩住**相邻**物件，反而分不清冻的是哪一件。
        const r = Math.max(b.max.x - b.min.x, b.max.y - b.min.y, b.max.z - b.min.z) * 0.5 * 1.34;
        const ice = new Node('ice');
        ice.setParent(root);
        ice.layer = root.layer;          // 与物件同层，否则相机剔除掉、整块壳看不见
        ice.setPosition((b.min.x + b.max.x) / 2, (b.min.y + b.max.y) / 2, (b.min.z + b.max.z) / 2);
        const mr = ice.addComponent(MeshRenderer);
        mr.mesh = utils.createMesh(primitives.sphere(r, { segments: 16 }));
        mr.setSharedMaterial(GameManager.iceMat(), 0);
        mr.shadowCastingMode = MeshRenderer.ShadowCastingMode.OFF;

        // 曾经在里面再套一颗 0.82 倍的实心球做边缘轮廓，效果是有，但两层 alpha
        // 叠起来有效不透明度接近 0.7，物件被盖得认不出是什么——而"认得出被冻的是啥"
        // 恰恰是玩家规划先消哪组的前提。识别度现在交给 HUD 的雪花标记，
        // 冰壳只保留一层很淡的体积暗示。
        tag.iceNode = ice;
    }

    /**
     * 冰壳材质：builtin-standard 的 transparent technique。
     *
     * 不用 DebugViz 那套 builtin-unlit——unlit 无光照，渲出来是一片**平的白雾**，
     * 读作"蒙了层塑料膜"而不是冰。冰的识别几乎全靠高光，所以必须要 PBR：
     * roughness 压到 0.10 得到锐利高光，metallic 给 0.25 让它有点"硬"，
     * 一点点冷 emissive 让背光面也不至于死黑。
     * （已实测 builtin-standard technique 1 在本项目的引擎裁剪下可用。）
     */
    private static _iceMat: Material | null = null;
    private static iceMat(): Material {
        if (!GameManager._iceMat) {
            const m = new Material();
            m.initialize({ effectName: 'builtin-standard', technique: 1 });
            // alpha 取 88：这层壳的职责是"一眼看出这件点不动"，不是营造冰的质感
        // （质感交给 HUD 那片雪花）。三档实测（第 3 关，玉碗）：
        //   58  几乎看不见，等于没有"不可点击"的提示
        //   88  蒙上一层看得出来，但配 1.12 倍的小壳仍不够醒目
        //   100 配 1.34 倍的壳，轮廓清晰、物件仍可辨  ← 取这档
        //   128 深色件（貔貅、葡萄、紫手串）开始被冲淡，回到"认不出是什么"的老问题
        m.setProperty('albedo', new Color(150, 208, 245, 100));
            try { m.setProperty('roughness', 0.10); } catch { /* 属性名随版本 */ }
            try { m.setProperty('metallic', 0.25); } catch { /* 同上 */ }
            try { m.setProperty('emissive', new Color(26, 62, 92)); } catch { /* 同上 */ }
            GameManager._iceMat = m;
        }
        return GameManager._iceMat;
    }

    /** 霜晶材质：更实更亮的冰渣，压在冰壳棱上提供颗粒感。 */
    private static _frostMat: Material | null = null;
    private static frostMat(): Material {
        if (!GameManager._frostMat) {
            const m = new Material();
            m.initialize({ effectName: 'builtin-standard', technique: 1 });
            m.setProperty('albedo', new Color(196, 234, 255, 92));
            try { m.setProperty('roughness', 0.08); } catch { /* 同上 */ }
            try { m.setProperty('metallic', 0.15); } catch { /* 同上 */ }
            GameManager._frostMat = m;
        }
        return GameManager._frostMat;
    }

    /** 解冻单件：冰壳缩没并销毁，物件本身不用动（它一直是原色）。 */
    private thawItem(tag: ItemTag) {
        if (!tag.frozen || !tag.node.isValid) return;
        tag.frozen = false;
        const at = this.frozenTags.indexOf(tag);
        if (at >= 0) this.frozenTags.splice(at, 1);
        // 在雪花原地炸一簇雪屑。必须**在这里**取屏幕坐标——下一帧 syncFrostMarks
        // 就会把这枚标记销毁，那时再算位置已经没有依据了。
        if (this.cam && tag.node.isValid) {
            const sp = v3();
            this.cam.worldToScreen(tag.node.worldPosition, sp);
            this.hud?.frostBreak(sp);
        }
        const ice = tag.iceNode;
        tag.iceNode = null;
        if (ice && ice.isValid) {
            tween(ice)
                .to(0.18, { scale: v3(0.01, 0.01, 0.01) }, { easing: 'backIn' })
                .call(() => ice.isValid && ice.destroy())
                .start();
        }
        const s = tag.node.scale.clone();
        Tween.stopAllByTarget(tag.node);
        tween(tag.node)
            .to(0.12, { scale: v3(s.x * 1.22, s.y * 1.22, s.z * 1.22) }, { easing: 'quadOut' })
            .to(0.14, { scale: s }, { easing: 'backOut' })
            .start();
    }

    /**
     * 把冰封件的屏幕坐标推给 HUD 画雪花。每帧调用——件会因下方被拿走而沉降，
     * 标记必须跟着走，否则会飘在空处。
     * 列表空时也要调一次（传空数组），否则最后一片雪花在解冻后留在屏幕上。
     */
    private syncFrostMarks() {
        if (!this.hud || !this.cam) return;
        // 退出、重开会先销毁物件节点；即使调用方漏清数组，也不能让失效 Component
        // 在 update 中每帧抛错。这里同步修剪残留引用，保证 HUD 和玩法循环继续运行。
        this.frozenTags = this.frozenTags.filter(t =>
            !!t && t.isValid && !!t.node && t.node.isValid && !t.picked && t.frozen);
        if (!this.frozenTags.length) {
            if (this.frostMarksShown) {
                this.hud.setFrostMarks([]);
                this.frostMarksShown = false;
            }
            return;
        }
        const marks: { key: string; screenPos: Vec3 }[] = [];
        for (const t of this.frozenTags) {
            const sp = v3();
            this.cam.worldToScreen(t.node.worldPosition, sp);
            marks.push({ key: t.node.uuid, screenPos: sp });
        }
        this.hud.setFrostMarks(marks);
        this.frostMarksShown = true;
    }

    /** 化开离 center 最近的 n 件冰封物件；返回实际化开的数量。 */
    private thawNearest(center: Vec3, n: number): number {
        const frozen = this.node.getComponentsInChildren(ItemTag)
            .filter(t => t.frozen && !t.picked && t.node.isValid);
        if (!frozen.length) return 0;
        frozen.sort((a, b) =>
            Vec3.squaredDistance(a.node.worldPosition, center)
            - Vec3.squaredDistance(b.node.worldPosition, center));
        const hit = frozen.slice(0, n);
        for (const t of hit) this.thawItem(t);
        return hit.length;
    }

    /** 化开场上全部冰封件；返回数量。残局保险用（见 checkDeadlock）。 */
    private thawAll(): number {
        const frozen = this.node.getComponentsInChildren(ItemTag)
            .filter(t => t.frozen && !t.picked && t.node.isValid);
        for (const t of frozen) this.thawItem(t);
        return frozen.length;
    }

    /** 按模型轮廓设定初始倾斜：薄片拍平，细长竖向件侧躺，其余保留自然随机姿态。 */
    private setNaturalRotation(node: Node, id: string, random: () => number = Math.random) {
        const q = new Quat();
        const sideRange = GameManager.SIDE_PROFILE_TILT[id];
        if (sideRange) {
            const magnitude = sideRange[0] + random() * (sideRange[1] - sideRange[0]);
            const signedTilt = (random() < 0.5 ? -1 : 1) * magnitude;
            Quat.fromEuler(q, signedTilt, random() * 360, (random() - 0.5) * 24);
            node.setRotation(q);
            return;
        }
        // 圆盘/环形件起始更贴近水平：配合下落只保留竖轴自转，落下即拍平叠摞，
        // 不会立起来边缘着地。这里统一复用 ROUND_ITEMS，避免新增主题模型时漏维护两张表。
        const tilt = GameManager.ROUND_ITEMS.has(id) ? 12 : 32;
        Quat.fromEuler(
            q,
            (random() - 0.5) * tilt * 2,
            random() * 360,
            (random() - 0.5) * tilt * 2,
        );
        node.setRotation(q);
    }

    /** xorshift32：轻量、跨平台一致，足够生成可复现的关卡初始布局。 */
    private levelRandom(): number {
        let x = this.levelRandomState | 0;
        x ^= x << 13;
        x ^= x >>> 17;
        x ^= x << 5;
        this.levelRandomState = x >>> 0;
        return this.levelRandomState / 0x100000000;
    }

    private shuffleInPlace<T>(items: T[], random: () => number = Math.random) {
        for (let i = items.length - 1; i > 0; i--) {
            const j = Math.floor(random() * (i + 1));
            [items[i], items[j]] = [items[j], items[i]];
        }
    }

    // ---------- 拾取与三消 ----------

    private onTouch(e: EventTouch) {
        if (!this.playing || this.paused || this.interactionLocked || !this.cam) return;
        const p = e.getLocation();
        if (this.hud?.hitsPromoGoose(p)) return;
        // getLocation / screenPointToRay / worldToScreen 三者同为**帧缓冲物理像素**，
        // 所以这里的阈值也必须用物理像素的 screen.windowSize（不是 view.getVisibleSize()）。
        if (p.y < screen.windowSize.height * 0.2) return; // 2D 收集区 + 道具栏，不穿透拾取
        const tag = this.hitTestAt(p.x, p.y);
        if (tag) this.pick(tag.node, tag);
    }

    /**
     * 双通道命中检测（供 onTouch 与自动化测试共用）。入参为**帧缓冲物理像素**，
     * 与 EventTouch.getLocation / camera.worldToScreen 同一套坐标。
     * 1) 穿透式物理射线，全命中里取最近的可拾取物件（隐形围栏不遮挡）
     * 2) 射线漏检时按屏幕距离就近吸附（物理体和渲染体错位/物件极薄时的兜底）
     */
    hitTestAt(x: number, y: number): ItemTag | null {
        if (!this.cam) return null;
        const ray = new geometry.Ray();
        this.cam.screenPointToRay(x, y, ray);
        let bestTag: ItemTag | null = null;
        // Jolt 的射线只收动态层且**只回最近一次命中**（围栏、地板在静态层，天然不遮挡），
        // 所以不再需要旧实现那套"遍历全部命中挑最近"的循环。
        const key = this.jolt.raycast(ray);
        if (key > 0) {
            const t = this.tagByBodyKey(key);
            if (t && !t.picked) bestTag = t;
        }
        if (!bestTag) {
            const thresh = screen.windowSize.width * 0.06;
            let bestPx = thresh;
            const sp = v3();
            for (const t of this.node.getComponentsInChildren(ItemTag)) {
                if (t.picked || !t.node.isValid) continue;
                this.cam.worldToScreen(t.node.worldPosition, sp);
                const d = Math.hypot(sp.x - x, sp.y - y);
                if (d < bestPx) { bestPx = d; bestTag = t; }
            }
        }
        return bestTag;
    }

    /** 由物理侧的 bodyKey 反查回玩法侧的 ItemTag（射线命中只拿得到 key）。 */
    private tagByBodyKey(key: number): ItemTag | null {
        for (const t of this.node.getComponentsInChildren(ItemTag)) {
            if (t.bodyKey === key && t.node.isValid) return t;
        }
        return null;
    }

    private pick(node: Node, tag: ItemTag) {
        // 冰封件点不动。拦截必须在 tag.picked = true **之前**——一旦置位，
        // 这件就被后续所有查询（可消组、残局检测、胜利判定）当成已拿走了。
        if (tag.frozen) {
            this.audio?.play('drop', 0.4);
            const s = node.scale.clone();
            Tween.stopAllByTarget(node);
            tween(node)
                .to(0.07, { scale: v3(s.x * 0.9, s.y * 0.9, s.z * 0.9) }, { easing: 'quadOut' })
                .to(0.1, { scale: s }, { easing: 'backOut' })
                .start();
            if (!this.frozenWarned) {
                this.frozenWarned = true;
                this.hud?.toast('冰封的物件要消除一组才能化开');
            }
            return;
        }
        tag.picked = true;
        // 有操作就重新计发呆时长，并撤掉还亮着的提示环。
        this.idleTime = 0;
        this.hud?.clearHint();
        const removedPos = node.worldPosition.clone();
        const screenPos = v3();
        this.cam.worldToScreen(node.worldPosition, screenPos);
        // 退出物理，位姿交给 Tween 接管（飞进暂存槽的那段动画）。
        // remove 内部会唤醒周围一圈，失去支撑的邻居随即自然塌落。
        this.jolt.remove(tag.bodyKey);
        tag.bodyKey = -1;

        // 金鹅走完全另一条路：不进暂存槽、不参与三消、不计完成度，就地结算奖励后消失。
        // 进槽是绝对不能做的——它只有一只，永远配不齐，彩蛋会变成"占掉一格"的惩罚。
        if (tag.golden) {
            this.collectGolden(node, removedPos, screenPos);
            return;
        }

        const { matched, full, index } = this.tray.add(tag.id, node);
        // 摘件后除了唤醒接触岛，再给最近几件一个很小的真实冲量。仅 Activate 在平铺容器里
        // 往往没有可见位移，玩家会误以为碰撞效果消失；冲量会经过 Jolt 接触求解传递，
        // 读作相邻物件被碰开，而不是旧版直接改 Transform 的假晃动。三消成立时稍加强。
        this.jolt.kickAround(removedPos, this.itemScale * 2.75, matched ? 1.15 : 0.82, matched ? 7 : 5);
        this.audio?.play(tag.id === 'goose' ? 'honk' : 'pick');
        this.hud?.pickBurst(screenPos);
        // 抓到吉祥物大鹅时给一句台词——游戏叫《抓住大鹅》，它不该跟一颗苹果一个待遇。
        if (tag.id === 'goose') this.hud?.speechPop(screenPos, '嘎——!');
        // 石头永远凑不齐，拿一块就等于永久少一格。首页那行警告开局就翻篇了，
        // 真正踩坑的这一刻必须当场说清楚，否则玩家只会以为自己运气差。
        if (tag.id === DISTRACTOR_ID && !this.rockWarned) {
            this.rockWarned = true;
            this.hud?.toast('石头凑不成三个，会一直占着格子');
        }
        this.hud?.captureModel(node, screenPos, index);
        this.reflowTray();
        // 不再额外 wakeAll：kickAround 只取 5 个近邻（三消时 7 个），避免整堆重启成地震。
        void removedPos;
        this.scheduleOnce(() => this.audio?.play('drop', 0.5), 0.3);

        if (matched) {
            // 飞入动画结束后再消除
            this.scheduleOnce(() => {
                for (const e of matched) {
                    Tween.stopAllByTarget(e.node);
                    this.hud?.matchBurst(e.node);
                    this.hud?.releaseModel(e.node);
                    tween(e.node)
                        .to(0.2, { scale: v3(0.05, 0.05, 0.05) }, { easing: 'backIn' })
                        .call(() => e.node.destroy())
                        .start();
                }
                this.removedCount += 3;
                this.addMatchScore();
                // 每消一组化开最近的一件：解冻速度与推进速度挂钩，玩家能预期。
                this.thawNearest(removedPos, GameManager.THAW_PER_MATCH);
                // 音量随连击递增：引擎的 playOneShot 不支持变调，用响度给「连着消」一个听得见的正反馈。
                // 放在 addMatchScore 之后，this.combo 才是这一次消除后的连击数。
                this.audio?.play('match', Math.min(1, 0.72 + this.combo * 0.07));
                this.reflowTray();
                this.updateHud();
                if (this.removedCount >= this.totalCount) {
                    this.gameOver(true, '全部消除！');
                    return;
                }
                this.checkDeadlock();
            }, 0.35);
        } else if (full) {
            // 数据层已经满 7 格，立即锁住输入；否则 0.4s 动画窗口内的连点会塞入第 8 格。
            this.interactionLocked = true;
            this.scheduleOnce(() => this.gameOver(false, '槽位已满'), 0.4);
        } else {
            // 图标飞完再闪那两格，否则玩家看到的是空框在亮。
            if ((this.tray.countById().get(tag.id) ?? 0) === 2) {
                this.scheduleOnce(() => this.flashNearMatch(tag.id), 0.3);
            }
            this.checkDeadlock();
        }
    }

    /**
     * 金鹅结算：加时 + 加分 + 一件随机道具，物件原地放大消失。
     *
     * 三样奖励都给而不是只给一样，是因为这只鹅平均要挖掉大半堆才见得到——
     * 到手时通常已是后半局，单给分数感知太弱，单给道具又可能是玩家不缺的那个。
     * 加时最直接（救回挖它花掉的时间），分数兑现"值得挖"，道具供本局继续使用。
     */
    private collectGolden(node: Node, worldPos: Vec3, screenPos: Vec3) {
        this.timeLeft += GameManager.GOLDEN_BONUS_SEC;
        this.score += GameManager.GOLDEN_BONUS_SCORE;
        const kinds: PropKind[] = ['remove', 'magnet', 'shuffle'];
        this.grantProps({ [kinds[Math.floor(Math.random() * kinds.length)]]: 1 });

        this.audio?.play('honk');
        this.hud?.pickBurst(screenPos);
        this.hud?.speechPop(screenPos, '金鹅！+20 秒');
        this.hud?.toast(`挖到金鹅：+${GameManager.GOLDEN_BONUS_SEC} 秒 +${GameManager.GOLDEN_BONUS_SCORE} 分 +1 道具`);
        this.updateHud();

        // 原地放大再消失（而不是飞向槽位）——它没有归宿，视觉上必须和"收进槽"区分开。
        tween(node)
            .to(0.22, { scale: v3(node.scale.x * 1.5, node.scale.y * 1.5, node.scale.z * 1.5) },
                { easing: 'backOut' })
            .to(0.16, { scale: v3(0.05, 0.05, 0.05) }, { easing: 'quadIn' })
            .call(() => node.isValid && node.destroy())
            .start();

        // 它原先垫在堆底，拿走后上面那摞会跟着塌一下——这已由 pick() 里的
        // JoltWorld.remove 按接触岛唤醒完成，不必也不该在这儿再唤醒一次（会变成整堆重启）。
        void worldPos;
    }

    /**
     * 三消结算得分：连击窗口内连续消除叠加倍率（上限 COMBO_MAX_MULT），
     * 断了就从 1 倍重来。奖励"看准了连着消"，但不给额外时间，不动既定难度曲线。
     */
    private addMatchScore() {
        const now = performance.now() / 1000;
        this.combo = now - this.lastMatchAt <= GameManager.COMBO_WINDOW ? this.combo + 1 : 1;
        this.lastMatchAt = now;
        const gain = GameManager.SCORE_BASE * Math.min(this.combo, GameManager.COMBO_MAX_MULT);
        this.score += gain;
        this.hud?.setScore(this.score);
        this.hud?.comboPop(this.combo, gain);
    }

    // ---------- 道具 ----------

    // 每局各有一次基础道具；旧版累计库存不再带入对局。
    private propCounts: Record<PropKind, number> = { remove: 1, magnet: 1, shuffle: 1 };
    private nextRoundBonus: Partial<Record<PropKind, number>> = {};
    private static readonly PROP_NAMES: Record<PropKind, string> = { remove: '移出', magnet: '凑齐', shuffle: '打乱' };

    private resetProps() {
        this.propCounts = {
            remove: 1 + (this.nextRoundBonus?.remove ?? 0),
            magnet: 1 + (this.nextRoundBonus?.magnet ?? 0),
            shuffle: 1 + (this.nextRoundBonus?.shuffle ?? 0),
        };
        this.nextRoundBonus = {};
        this.refreshPropHud();
    }

    /** 本局额外道具来自金鹅和宣传片。 */
    private grantProps(delta: Partial<Record<PropKind, number>>) {
        for (const k of ['remove', 'magnet', 'shuffle'] as PropKind[]) {
            this.propCounts[k] += delta[k] ?? 0;
        }
        this.refreshPropHud();
    }

    private refreshPropHud() {
        if (!this.hud) return;
        for (const k of ['remove', 'magnet', 'shuffle'] as PropKind[]) {
            this.hud.setPropCount(k, GameManager.PROP_NAMES[k], this.propCounts[k], this.gmEnabled);
        }
    }

    useProp(kind: PropKind) {
        if (!this.playing || this.paused || this.interactionLocked) return;
        this.idleTime = 0;
        this.hud?.clearHint();
        if (!this.gmEnabled && this.propCounts[kind] <= 0) {
            this.hud?.toast(`${GameManager.PROP_NAMES[kind]}已用完`);
            return;
        }
        let used = false;
        if (kind === 'remove') used = this.propRemove();
        else if (kind === 'magnet') used = this.propMagnet();
        else used = this.propShuffle();
        if (used) {
            this.audio?.play(kind === 'shuffle' ? 'shuffle' : 'prop');
            if (!this.gmEnabled) {
                this.propCounts[kind]--;
                this.refreshPropHud();
            }
            Telemetry.track('prop_use', {
                roundId: this.roundId, kind, level: this.levelIndex + 1, progress: this.progress,
                gm: this.gmEnabled,
            });
        }
    }

    /** 移出：槽头 3 个物件放回盒子 */
    private propRemove(): boolean {
        const back = this.tray.takeFront(3);
        if (back.length === 0) return false;
        this.returnItemsToPile(back);
        return true;
    }

    /** 把若干槽内物件放回 3D 堆(道具"移出"与失败救场共用)。 */
    private returnItemsToPile(back: { id: string; node: Node }[]) {
        back.forEach((e, i) => {
            const tag = e.node.getComponent(ItemTag)!;
            this.hud?.releaseModel(e.node);
            e.node.setParent(this.node);
            this.forceLayer(e.node);
            e.node.active = true;
            tag.picked = false;
            tag.stillTicks = 0;
            tag.anchorY = -99;
            // 落点走通用边界的回收点：矩形/圆形容器都能保证落在承载物内，逐件抬高错开。
            const rp = this.boundary.respawn(Math.random);
            e.node.setWorldPosition(rp.x, 1.3 + i * 0.5, rp.z);
            e.node.setScale(this.itemScale, this.itemScale, this.itemScale);
            this.setNaturalRotation(e.node, tag.id);
            // 被拾取时刚体已经销毁（见 removeItem），放回堆里等于重新投一件。
            // 碰撞代理就地重算：视觉子树还在、且已归心，centerVisualAndMakeShape 是
            // 幂等的（再算一次 center≈0、不会二次平移）。只有 ≤3 件，重算凸包开销可忽略。
            tag.bodyKey = this.jolt.spawn(e.node, {
                shape: this.centerVisualAndMakeShape(e.node, tag.id, this.itemScale),
                mass: 0.9,
                linearDamping: 0.06,
                angularDamping: 0.3,
                friction: GameManager.PILE_FRICTION,
                restitution: GameManager.PILE_RESTITUTION,
                useCCD: true,
                position: e.node.worldPosition.clone(),
                rotation: e.node.worldRotation.clone(),
                linearVelocity: v3(0, -1.2, 0),
                angularVelocity: v3(),
            });
        });
        this.reflowTray();
    }

    /** 凑齐：自动吸取盒中物件补全一组三消（优先补槽内已有的类别） */
    private propMagnet(): boolean {
        const counts = this.tray.countById();
        const boxItems = this.node.getComponentsInChildren(ItemTag).filter(t => !t.picked && t.node.isValid);
        const availOf = (id: string) => boxItems.filter(t => t.id === id).length;

        let target: string | null = null;
        let bestHave = -1;
        for (const [id, have] of counts) {
            const need = 3 - have;
            if (need <= 0) continue;
            // 槽位余量必须装得下补齐所需数量（否则会触发爆满失败）
            if (availOf(id) >= need && this.tray.count + need <= TRAY_CAPACITY && have > bestHave) {
                bestHave = have;
                target = id;
            }
        }
        if (!target && this.tray.count + 3 <= TRAY_CAPACITY) {
            target = boxItems.find(t => availOf(t.id) >= 3)?.id ?? null;
        }
        if (!target) return false;

        const need = 3 - (counts.get(target) ?? 0);
        const picks = boxItems.filter(t => t.id === target).slice(0, need);
        // 自动吸取是一个完整事务，期间禁止手点或再次使用道具改变已校验过的槽位余量。
        this.interactionLocked = true;
        picks.forEach((t, i) => this.scheduleOnce(() => {
            if (this.playing && t.node.isValid && !t.picked) this.pick(t.node, t);
        }, i * 0.18));
        this.scheduleOnce(() => {
            this.interactionLocked = false;
            // 磁铁可能刚好吸走最后一组可消物件，事务解锁后补一次残局判定。
            this.checkDeadlock();
        }, picks.length * 0.18 + 0.4);
        return true;
    }

    /** 打乱：盒中剩余物件重新抛起洗一遍 */
    private propShuffle(): boolean {
        const boxItems = this.node.getComponentsInChildren(ItemTag).filter(t => !t.picked && t.node.isValid);
        if (boxItems.length === 0) return false;
        this.shuffleInPlace(boxItems);
        // 这里的投放高度 1.55 **故意低于**开局的 PILE_SPAWN_Y(2.6)，别去"对齐"两者：
        // 打乱是原地洗牌，容器里还堆着旧的一堆（顶约 1.2），件只需从旧堆顶略上方落下；
        // 2.6 那个值是为空容器算的，用在这儿就变成从高处砸。实测第 1 关打乱后堆顶 med：
        //   1.55 + i%6×0.1（现行，同帧）        1.71   ← 最好
        //   2.6  + i%5×0.22（逐件错开投放）      2.04   先重投的件落在没抬走的旧堆上垫高
        //   2.6  + layer×0.6（同帧、按层抬高）   2.65   落差更大，砸得更散
        // 同帧整队重置也是必需的——逐件会让容器迟迟清不空，就是上面第二行那个结果。
        for (const [i, t] of boxItems.entries()) {
            // 重洗与投放共用落点函数，打乱后堆形与开局同构（否则用一次道具堆就变样）。
            // 已消掉一些件时 boxItems 变少，层数自动跟着降，不会在半空留出悬着的上层。
            const seed = this.pileSeedPoint(i);
            const pos = v3(
                seed.x + (Math.random() - 0.5) * 0.1,
                1.55 + (i % 6) * 0.1,
                seed.z + (Math.random() - 0.5) * 0.06);
            this.setNaturalRotation(t.node, t.id);
            // 打乱是一次超自然的重新发牌，不是物理过程，所以走 teleport 直接改刚体位姿
            // ——这是全工程唯一允许脚本改写动态刚体位置的地方，见 JoltWorld.teleport。
            // 节点位姿不用自己写：teleport 之后由 syncNodes 统一同步过去。
            this.jolt.teleport(t.bodyKey, pos, t.node.worldRotation,
                v3((Math.random() - 0.5) * 0.4, -1.2, (Math.random() - 0.5) * 0.4));
        }
        return true;
    }

    /** 槽中所有物件按当前顺序补位（含飞入中的） */
    private reflowTray() {
        this.tray.entries.forEach((e, i) => {
            this.hud?.moveModelToSlot(e.node, i);
        });
        this.hud?.setTrayCount(this.tray.count);
    }

    // ---------- 结算与 HUD ----------

    private get progress(): number {
        return this.totalCount === 0 ? 0 : Math.round((this.removedCount / this.totalCount) * 100);
    }

    private gameOver(win: boolean, reason: LoseReason | '全部消除！') {
        if (!this.playing) return;
        if (this.timeoutOfferOpen) return;
        if (!win && reason === '时间到' && !this.timeoutOffered) {
            this.timeoutOffered = true;
            this.timeoutOfferOpen = true;
            this.paused = true;
            this.hud?.hidePromoGoose();
            this.showTimeoutOffer();
            return;
        }
        this.hud?.hidePromoGoose();
        this.playing = false;
        this.interactionLocked = false;
        this.paused = false;
        this.combo = 0;
        this.hud?.setCombo(0, 0);
        this.hud?.setPaused(false);
        this.hud?.hidePauseMenu();
        this.hud?.clearHint();
        this.hud?.setTimeUrgent(false);
        this.loseReason = win ? '' : reason as LoseReason;
        this.audio?.play(win ? 'win' : 'lose');
        // 通关此前只有一个弹窗弹出来，画面上没有任何「成了」的反馈；先撒金屑再结算。
        if (win) this.hud?.winCelebrate();
        // 剩余时间折成奖励分：结算面板会单列一行说明它的来源。
        const timeBonus = win ? Math.round(this.timeLeft) * GameManager.TIME_BONUS_PER_SEC : 0;
        if (timeBonus > 0) {
            this.score += timeBonus;
            this.hud?.setScore(this.score);
        }
        const stars = this.progress >= 100 ? 3 : this.progress >= 70 ? 2 : this.progress >= 50 ? 1 : 0;
        // 星级奖励仅下一局生效一次，不再积成跨局无限增长的库存。
        if (win && !this.gmUsedThisRound) {
            this.nextRoundBonus = {
                remove: stars >= 1 ? 1 : 0,
                magnet: stars >= 2 ? 1 : 0,
                shuffle: stars >= 3 ? 1 : 0,
            };
        }
        Telemetry.track('round_end', {
            roundId: this.roundId,
            theme: getActiveTheme().id,
            level: this.levelIndex + 1,
            win,
            reason: win ? 'win' : reason,
            progress: this.progress,
            score: this.score,
            stars,
            durationSec: Math.round((performance.now() - this.roundStartedAt) / 1000),
            rescueUsed: this.rescueUsed,
            gm: this.gmUsedThisRound,
        });
        console.log(`[GameManager] ${win ? '胜利' : `失败（${reason}）`} 完成度 ${this.progress}%`);

        const finishedLevel = this.levelIndex;
        // 先取旧纪录再写入，否则展示的"历史最佳"会变成刚打完的这一局。
        const prevBest = this.best[finishedLevel];
        const newRecord = !this.gmUsedThisRound
            && this.recordBest(finishedLevel, stars, this.progress, this.score);

        // 胜利推进关卡并持久化；最后一关通关后停在最后一关反复挑战。
        const wasLast = this.levelIndex >= LEVELS.length - 1;
        if (win && !wasLast) {
            this.levelIndex++;
            SaveData.setLevel(this.levelIndex);
        }
        const actionText = win ? (wasLast ? '再来一局' : '下一关') : '再试一次';
        const canRescue = !win && !this.rescueUsed
            && this.loseReason !== '时间到' && this.tray.count >= 3;
        const loseSubtitle: Record<Exclude<LoseReason, ''>, string> = {
            '槽位已满': '七格被塞满了',
            '时间到': '时间到了',
            '无解': '剩下的物件配不出三个了',
        };
        const subtitle = !win && this.loseReason !== '' ? loseSubtitle[this.loseReason]
            : this.gmUsedThisRound ? 'GM 辅助 · 不计成绩' : '';
        // 给消除动画/星星心理预期留 0.6 秒再弹结算。
        // 原地重置而不重载场景——loadScene 后自定义管线的主相机会停止渲染。
        this.scheduleOnce(() => {
            this.hud?.showResult({
                win, stars, progress: this.progress, score: this.score,
                rewardCount: win && !this.gmUsedThisRound ? stars : 0, actionText,
                subtitle,
                timeBonus,
                bestText: prevBest
                    ? `历史最佳 ${'★'.repeat(prevBest.stars) || '—'} ${prevBest.progress}% · ${prevBest.score ?? 0} 分`
                    : '',
                newRecord,
                rescueText: canRescue ? '救一下:退回 3 件' : '',
                onRescue: canRescue ? () => this.rescue() : undefined,
                onAction: () => this.resetLevel(),
            });
        }, 0.6);
    }

    private rescue() {
        if (this.rescueUsed || this.playing || this.loseReason === '时间到') return;
        this.rescueUsed = true;
        Telemetry.track('rescue_use', {
            roundId: this.roundId, reason: this.loseReason, level: this.levelIndex + 1,
        });
        this.interactionLocked = false;
        this.hud?.hideResult();
        this.audio?.play('prop');
        const back = this.tray.takeFront(3);
        this.returnItemsToPile(back);
        this.playing = true;
        this.updateHud();
    }

    /** 原地开始 levelIndex 指向的关卡（重试当前关或进入下一关） */
    private async resetLevel() {
        // 开始页可能还开着（重开、救场、跳关都会走到这里，它们不经过「开始挑战」按钮）。
        // 不关掉的话新一局的堆就倒在首页底下，玩家看不见也点不到。
        this.hud?.hideHome();
        if (!this.ensureDaily(() => void this.resetLevel())) return;
        const nextLevel = LEVELS[Math.min(this.levelIndex, LEVELS.length - 1)];
        if (!await this.loadLevelAssets(nextLevel, () => void this.resetLevel())) return;
        this.consumeDaily();
        this.rescueUsed = false;
        this.gmUsedThisRound = this.gmEnabled;
        this.loseReason = '';
        this.rockWarned = false;
        this.frozenWarned = false;
        this.frozenTags = [];
        this.frostMarksShown = false;
        this.hud?.clearFrostMarks();
        this.interactionLocked = false;
        this.hud?.hideResult();
        this.hud?.hidePauseMenu();
        this.hud?.clearHint();
        // 新一局重置得分与连击（历史最佳已在上一局结算时落盘）。
        this.score = 0;
        this.combo = 0;
        this.lastMatchAt = -99;
        this.idleTime = 0;
        this.hud?.setScore(0);
        for (const e of this.tray.entries) {
            if (e.node.isValid) e.node.destroy();
        }
        for (const t of this.node.getComponentsInChildren(ItemTag)) {
            if (t.node.isValid) t.node.destroy();
        }
        // 销毁节点**不会**连带销毁刚体：节点归 Cocos，刚体归 Jolt，两边只靠 bodyKey 相连。
        // 漏掉这一步，上一关的刚体会全部留在物理世界里变成看不见的幽灵堆，
        // 新一关的物件落下来会砸在半空——而且画面上什么都看不到，极难排查。
        this.jolt.clearBodies();
        this.tray.clear();
        this.hud?.setTrayCount(0);
        this.hud?.clearCapturedModels();
        this.removedCount = 0;
        this.level = nextLevel;
        this.timeLeft = this.level.timeSec;
        this.hud?.setLevel(this.levelIndex + 1);
        if (this.msgLabel) this.msgLabel.string = '';
        if (this.hud) this.hud.subMsgLabel.string = '';
        this.resetProps();
        this.spawnItems();
        this.paused = false;
        this.hud?.setPaused(false);
        this.playing = true;
        this.trackRoundStart();
        this.updateHud();
    }

    private toggleGM(): boolean {
        this.gmEnabled = !this.gmEnabled;
        SaveData.setGM(this.gmEnabled);
        if (this.gmEnabled && this.playing) this.gmUsedThisRound = true;
        this.idleTime = 0;
        this.hud?.clearHint();
        this.refreshPropHud();
        return this.gmEnabled;
    }

    /** 暂停键打开设置与关卡操作。 */
    private togglePause() {
        if (this.promoVideo.active || this.timeoutOfferOpen) return;
        if (!this.playing) return;
        if (this.paused) { this.resumeFromPause(); return; }
        this.paused = true;
        this.hud?.setPaused(true);
        this.hud?.clearHint();
        this.hud?.showPauseMenu({
            soundOn: this.audio?.soundOn ?? true,
            gmOn: this.gmEnabled,
            onResume: () => this.resumeFromPause(),
            onRestart: () => {
                this.resumeFromPause();
                void this.resetLevel();
            },
            onExit: () => this.exitRoundToHome(),
            onToggleSound: () => this.toggleSound(),
            onToggleGM: () => this.toggleGM(),
        });
    }

    /**
     * 主动退出不会结算成绩，也不会再次扣除挑战次数；但必须销毁节点和 Jolt 刚体两份状态，
     * 否则返回首页后再次开局会撞上上一局遗留的“幽灵物件”。
     */
    private exitRoundToHome() {
        this.promoVideo.close();
        this.hud?.hidePromoGoose();
        Telemetry.track('round_exit', {
            roundId: this.roundId,
            theme: getActiveTheme().id,
            level: this.levelIndex + 1,
            progress: this.progress,
            durationSec: Math.round((performance.now() - this.roundStartedAt) / 1000),
        });
        this.playing = false;
        this.paused = false;
        this.interactionLocked = false;
        this.combo = 0;
        this.score = 0;
        this.removedCount = 0;

        this.hud?.hidePauseMenu();
        this.hud?.setPaused(false);
        this.hud?.setCombo(0, 0);
        this.hud?.setScore(0);
        this.hud?.setTimeUrgent(false);
        this.hud?.clearHint();
        // 冰封引用属于本局状态，必须在销毁物件前一起清空；否则返回地图再入局时，
        // update 会访问上一局已经销毁的 ItemTag，导致后续 HUD（含底部置物区）停止同步。
        this.frozenTags = [];
        this.frostMarksShown = false;
        this.hud?.clearFrostMarks();

        for (const e of this.tray.entries) {
            if (e.node.isValid) e.node.destroy();
        }
        for (const t of this.node.getComponentsInChildren(ItemTag)) {
            if (t.node.isValid) t.node.destroy();
        }
        this.jolt.clearBodies();
        this.tray.clear();
        this.hud?.setTrayCount(0);
        this.hud?.clearCapturedModels();

        this.timeLeft = this.level.timeSec;
        this.updateHud();
        this.showHome();
    }

    /** 声音开关的唯一入口：HUD 声音键和暂停菜单都走这里，图标才不会和实际状态脱节。 */
    private toggleSound(): boolean {
        const on = this.audio?.toggleSound() ?? false;
        this.hud?.setSoundOn(on);
        Telemetry.track('sound_toggle', { on });
        return on;
    }

    private resumeFromPause() {
        this.hud?.hidePauseMenu();
        this.paused = false;
        this.idleTime = 0;
        this.hud?.setPaused(false);
    }

    /**
     * 选皮面板期间挂起计时与物理巡检，关闭后恢复到打开前的状态。
     * 不动 HUD 暂停键图标/文案：面板有全屏遮罩，期间它们本就被盖住。
     */
    private setOverlayPause(open: boolean) {
        if (!this.playing) return;
        if (open) {
            this.overlayPrevPaused = this.paused;
            this.paused = true;
        } else {
            this.paused = this.overlayPrevPaused;
        }
    }

    private async watchPromo(rewardText: string): Promise<PromoResult | null> {
        if (this.promoVideo.active) return null;
        const roundId = this.roundId;
        const wasPaused = this.paused;
        this.paused = true;
        this.audio?.setSuspended(true);
        const engineWasPaused = director.isPaused();
        director.pause();
        let result: PromoResult;
        try {
            result = await this.promoVideo.play(rewardText);
        } catch {
            this.promoVideo.close();
            result = 'error';
        } finally {
            if (!engineWasPaused) director.resume();
        }
        if (!this.isValid || this.roundId !== roundId) return null;
        this.paused = wasPaused;
        this.audio?.setSuspended(false);
        this.idleTime = 0;
        this.lastMatchAt = -99;
        if (result === 'error' || result === 'timeout') this.hud?.toast('宣传片加载失败，请稍后重试');
        return result;
    }

    private async watchGoosePromo() {
        if (!this.playing || this.paused || this.interactionLocked || this.promoVideo.active) return;
        this.hud?.hidePromoGoose();
        const result = await this.watchPromo('获得 1 个随机道具');
        if (result !== 'completed' || !this.playing) return;
        const kinds: PropKind[] = ['remove', 'magnet', 'shuffle'];
        const kind = kinds[Math.floor(Math.random() * kinds.length)];
        this.grantProps({ [kind]: 1 });
        this.audio?.play('prop');
        this.hud?.toast(`获得${GameManager.PROP_NAMES[kind]} ×1`);
    }

    private showTimeoutOffer() {
        this.hud?.showTimeoutOffer(GameManager.REVIVE_SECONDS,
            () => void this.watchRevivePromo(), () => {
                if (this.promoVideo.active || !this.timeoutOfferOpen) return;
                this.timeoutOfferOpen = false;
                this.hud?.hideResult();
                this.paused = false;
                this.gameOver(false, '时间到');
            });
    }

    private async watchRevivePromo() {
        if (!this.timeoutOfferOpen || this.promoVideo.active) return;
        const result = await this.watchPromo(`复活并增加 ${GameManager.REVIVE_SECONDS} 秒`);
        if (result === null || !this.timeoutOfferOpen) return;
        if (result !== 'completed') {
            this.showTimeoutOffer();
            return;
        }
        this.timeoutOfferOpen = false;
        this.timeLeft += GameManager.REVIVE_SECONDS;
        this.paused = false;
        this.interactionLocked = false;
        this.hud?.hideResult();
        this.hud?.setTimeUrgent(false);
        this.updateHud();
        this.hud?.toast(`复活成功，增加 ${GameManager.REVIVE_SECONDS} 秒`);
    }

    private updateHud() {
        if (this.hud) this.hud.setProgress(this.progress);
        else if (this.progressLabel) this.progressLabel.string = `完成度 ${this.progress}%`;
        if (this.timerLabel) {
            const m = Math.floor(this.timeLeft / 60);
            const s = Math.floor(this.timeLeft % 60);
            this.timerLabel.string = `${m}:${s.toString().padStart(2, '0')}`;
        }
    }
}
