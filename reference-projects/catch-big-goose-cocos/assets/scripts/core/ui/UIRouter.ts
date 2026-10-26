import { Node, Layers, UITransform, UIOpacity, tween, v3, Vec3, Color, Graphics } from 'cc';

/** 页面在 720 宽美术坐标中的真实可视范围。 */
export interface ScreenViewport {
    topY: number;
    bottomY: number;
    width: number;
    height: number;
}

/**
 * 页面路由：整屏页面之间的切换，取代「一切都是盖在游戏上的弹窗」。
 *
 * 为什么要它：开始页原本是个 modal，盖在游玩场景上，于是「首页」和「对局中」共用一套
 * 状态，谁负责关谁全靠调用方自觉——实测 hideHome 在 GameManager 里一次都没被调用过，
 * 重开时新一局的堆就倒在首页底下。页面一多这种耦合会指数级恶化。
 *
 * 这里的模型很小，但边界清楚：
 *   - 一次只有一个**活动页**（栈顶）。切换 = 旧页退场 + 新页入场，两者都走同一套动画。
 *   - 页面自己只管画内容（{@link Screen.build}），不管什么时候被显示、被谁替换。
 *   - 路由不碰 3D 世界。「首页要不要看得见游戏场景」由页面自己声明 {@link Screen.dimWorld}。
 *
 * 刻意**没做**的事：路由参数、历史记录、深链接。现在只有三个页面，加了也没人用；
 * 等真有需要再补，别提前造框架。
 */

/** 一个整屏页面。实现方只需要在 build 里往 root 上画东西。 */
export interface Screen {
    /** 页面标识，用于避免重复入栈与调试。 */
    readonly name: string;
    /** 页面美术的可见顶边坐标；用于宽屏下从顶部起绘并把超长内容裁在底部。 */
    readonly artTop?: number;
    /**
     * 是否压暗背后的 3D 世界。首页需要（让 UI 成为焦点），游玩页不需要。
     * 不做成「隐藏世界」是因为首页背后那锅物件仍在物理里落定，藏了反而看不出加载完没有。
     */
    readonly dimWorld?: boolean;
    /** 把页面内容画到 root 上。root 是 720×1280 的整屏节点，坐标以屏心为原点。 */
    build(root: Node): void;
    /**
     * 窗口尺寸变化后的页面布局入口。长地图页用它固定头尾、把剩余高度交给地图视口；
     * 普通页面不实现即可继续沿用自己的固定坐标。
     */
    layout?(viewport: ScreenViewport): void;
    /** 页面退场前的清理（解绑外部监听等）。纯节点内容不用管，路由会整棵销毁。 */
    dispose?(): void;
}

/** 页面切换动画的时长。够快不拖沓，又能让人看出发生了页面级的变化。 */
const FADE = 0.18;

export class UIRouter {
    /** 页面挂在这个节点下，与 HUD 的常驻内容平级。 */
    private readonly host: Node;
    private readonly size: { w: number; h: number };
    private current: { screen: Screen; node: Node } | null = null;
    /** 压暗世界的遮罩，按当前页的 dimWorld 显隐。 */
    private dim: Node | null = null;

    constructor(host: Node, w = 720, h = 1280) {
        this.host = host;
        this.size = { w, h };
    }

    /** 当前活动页的名字（没有则 null）。 */
    get activeName(): string | null {
        return this.current?.screen.name ?? null;
    }

    /** 当前页面真正的美术顶边；不同页面可保留各自的顶部出血。 */
    get activeArtTop(): number {
        return this.current?.screen.artTop ?? 850;
    }

    /**
     * 把真实可视范围交给活动页。路由只做坐标换算，不理解“地图”或“控制台”；
     * 页面据此决定哪些区域固定、哪些区域裁切，避免再用悬浮按钮遮挡正文。
     */
    layoutVisibleArea(bottomY: number) {
        const current = this.current;
        if (!current) return;
        const topY = current.screen.artTop ?? 850;
        current.screen.layout?.({
            topY,
            bottomY,
            width: this.size.w,
            height: topY - bottomY,
        });
    }

    /**
     * 切到某个页面。同名页重复调用会**重建**——页面内容依赖外部状态（选中的场景、
     * 难度、成绩），重建比让每个页面各自实现 refresh 简单得多，代价只是几十个节点。
     */
    go(screen: Screen) {
        const old = this.current;

        const node = new Node(`screen:${screen.name}`);
        node.layer = Layers.Enum.UI_2D;
        node.setParent(this.host);
        node.addComponent(UITransform).setContentSize(this.size.w, this.size.h);
        this.ensureDim(screen.dimWorld === true, node);
        screen.build(node);
        this.current = { screen, node };

        // 入场：轻微上浮 + 淡入。比直接出现更容易读成"换了一页"。
        node.setScale(1, 1, 1);
        node.setPosition(0, -18, 0);
        tween(node).to(FADE, { position: v3(0, 0, 0) }, { easing: 'quadOut' }).start();
        this.fade(node, 0, 1);

        if (old) {
            old.screen.dispose?.();
            this.fade(old.node, 1, 0, () => old.node.isValid && old.node.destroy());
        }
    }

    /** 清空当前页（回到纯游玩视图）。 */
    clear() {
        const old = this.current;
        this.current = null;
        if (!old) return;
        old.screen.dispose?.();
        this.fade(old.node, 1, 0, () => old.node.isValid && old.node.destroy());
        if (this.dim?.isValid) {
            const d = this.dim;
            this.dim = null;
            this.fade(d, 1, 0, () => d.isValid && d.destroy());
        }
    }

    /** 压暗层：整屏半透明黑，挂在页面之下、世界之上。 */
    private ensureDim(want: boolean, below: Node) {
        if (!want) {
            if (this.dim?.isValid) { this.dim.destroy(); this.dim = null; }
            return;
        }
        if (this.dim?.isValid) {
            // 重建同一页时新节点会追加到末尾；若把遮罩移动到新页的旧下标，节点重排后
            // 遮罩反而会跑到页面上方，整页看起来像被禁用。screenLayer 只承载页面，固定 0 最稳。
            this.dim.setSiblingIndex(0);
            return;
        }
        const d = new Node('screenDim');
        d.layer = Layers.Enum.UI_2D;
        d.setParent(this.host);
        // 给足余量：横屏或异形屏下 720×1280 之外仍要盖住。
        d.addComponent(UITransform).setContentSize(2400, 3200);
        const g = d.addComponent(Graphics);
        g.fillColor = new Color(18, 10, 6, 168);
        g.rect(-1200, -1600, 2400, 3200);
        g.fill();
        d.setSiblingIndex(0);
        this.dim = d;
        this.fade(d, 0, 1);
    }

    /**
     * 整棵子树淡入淡出。
     *
     * 用 UIOpacity 而不是逐节点切 active：后者是闪现不是淡出。UIOpacity 在 Cocos 3.x
     * 里会沿渲染层级向下相乘，挂在页面根上就够了，子节点一个都不用碰。
     */
    private fade(root: Node, from: number, to: number, onDone?: () => void) {
        const op = root.getComponent(UIOpacity) ?? root.addComponent(UIOpacity);
        op.opacity = Math.round(from * 255);
        tween(op)
            .to(FADE, { opacity: Math.round(to * 255) }, { easing: 'quadOut' })
            .call(() => onDone?.())
            .start();
    }
}

void Vec3;
