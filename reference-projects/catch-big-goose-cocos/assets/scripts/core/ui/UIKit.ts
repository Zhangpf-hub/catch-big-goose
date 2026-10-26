import {
    Node, Layers, Label, Color, UITransform, Graphics, tween, v3, Font,
    resources, SpriteFrame, Sprite, Texture2D, assetManager, ImageAsset,
} from 'cc';
import { NodeEventType } from 'cc';
import { Telemetry } from '../Telemetry';

/**
 * 页面的绘制原语：面板、文字、卡片、按钮。
 *
 * 存在的理由是「后面会有很多页面」——每个页面各画各的，配色和圆角很快就会飘。
 * 这里把工程既有的视觉语言固定成一组动词，新页面只调用、不自创。
 *
 * 配色取自 HudUI 里已在用的那套，不是新设计：
 *   奶油面 255,244,214 ／ 金描边 196,130,64 ／ 标题橙 240,150,26
 *   文字棕 102,57,28 ／ 弱化棕 158,122,82 ／ 强调金 255,207,55
 */
export const UIColors = {
    cream: new Color(255, 244, 214),
    creamCard: new Color(250, 238, 210),
    creamLocked: new Color(238, 226, 202),
    gold: new Color(240, 150, 26),
    goldFill: new Color(255, 207, 55),
    edge: new Color(196, 130, 64),
    edgeSoft: new Color(198, 168, 120),
    text: new Color(102, 57, 28),
    textSoft: new Color(158, 122, 82),
    textLocked: new Color(176, 156, 128),
    green: new Color(52, 148, 68),
    starOff: new Color(224, 203, 160),
    parchment: new Color(244, 224, 174),
    mapGreen: new Color(86, 137, 73),
    mapBlue: new Color(83, 167, 178),
    wood: new Color(96, 52, 27),
} as const;

export class UIKit {
    /** 同一切图在一页会被多个站点复用；共享在途 Promise，避免 CDN 故障时同时打出十几次请求。 */
    private static textureLoads = new Map<string, Promise<Texture2D | null>>();
    /** 远程图与本地兜底按同一逻辑键缓存，预加载后页面创建不会再次等待网络。 */
    private static imageLoads = new Map<string, Promise<Texture2D | null>>();
    private static fallbackWarned = new Set<string>();

    private static loadTexture(path: string): Promise<Texture2D | null> {
        const cached = UIKit.textureLoads.get(path);
        if (cached) return cached;
        const task = new Promise<Texture2D | null>((resolve) => {
            if (/^https?:\/\//.test(path)) {
                assetManager.loadRemote<ImageAsset>(path, (err, imageAsset) => {
                    if (err || !imageAsset) { resolve(null); return; }
                    const texture = new Texture2D();
                    texture.image = imageAsset;
                    resolve(texture);
                });
            } else {
                resources.load(path, Texture2D, (err, texture) => resolve(err || !texture ? null : texture));
            }
        });
        UIKit.textureLoads.set(path, task);
        // 失败不做永久负缓存：当前页使用 fallback，之后重进页面仍可再试 CDN。
        void task.then(texture => { if (!texture) UIKit.textureLoads.delete(path); });
        return task;
    }

    private static resolveImageTexture(resourcePath: string | { remote: string; fallback: string }): Promise<Texture2D | null> {
        const key = typeof resourcePath === 'string' ? resourcePath : resourcePath.remote;
        const cached = UIKit.imageLoads.get(key);
        if (cached) return cached;
        const fallbackPath = typeof resourcePath === 'string' ? null : resourcePath.fallback;
        const task = UIKit.loadTexture(key).then(async texture => {
            if (texture || !fallbackPath) return texture;
            const fallback = await UIKit.loadTexture(fallbackPath);
            if (fallback && !UIKit.fallbackWarned.has(key)) {
                UIKit.fallbackWarned.add(key);
                console.warn(`[UIKit] 远程图片失败，已使用本地降级：${key}`);
                Telemetry.track('remote_asset_fallback', { asset: key.split('/').pop() ?? 'unknown' });
            }
            return fallback;
        });
        UIKit.imageLoads.set(key, task);
        void task.then(texture => { if (!texture) UIKit.imageLoads.delete(key); });
        return task;
    }

    static async preloadImages(
        resources: ReadonlyArray<string | { remote: string; fallback: string }>,
        onProgress?: (completed: number, total: number, failed: number) => void,
    ): Promise<number> {
        let completed = 0;
        let failed = 0;
        onProgress?.(0, resources.length, 0);
        await Promise.all(resources.map(async resource => {
            const texture = await UIKit.resolveImageTexture(resource);
            if (!texture) failed += 1;
            completed += 1;
            onProgress?.(completed, resources.length, failed);
        }));
        return failed;
    }

    /**
     * 资源图的统一加载入口。页面先搭好结构，图片异步回来后再出现；加载失败保留页面底色，
     * 不让一个美术资源 404 把首次启动卡成空白页。
     *
     * `resourcePath` 传 http(s) 开头的地址即走远程加载（见 RemoteTextures）：
     * 少数超大切图放 CDN 不进包，其余仍走 resources/。两条路径拿到 Texture2D 后
     * 的处理完全一致，调用方不需要知道图从哪来。
     */
    static image(parent: Node, resourcePath: string | { remote: string; fallback: string }, w: number, h: number,
        x: number, y: number, opacity = 255, tint?: Color): Node {
        const n = new Node('image');
        n.layer = Layers.Enum.UI_2D;
        n.setParent(parent);
        n.setPosition(x, y, 0);
        n.addComponent(UITransform).setContentSize(w, h);
        const apply = (texture: Texture2D) => {
            if (!n.isValid) return;
            // 工程图片统一按 Texture2D 导入（没有 SpriteFrame 子资源），页面层在运行时包装。
            const frame = new SpriteFrame();
            frame.texture = texture;
            const sprite = n.addComponent(Sprite);
            // Sprite 默认以 RAW 模式接收首张纹理，会把节点偷偷改回图片原始像素尺寸；
            // 先切 CUSTOM、赋帧后再恢复设计尺寸，才能让 853px 稿件严格落在 720 美术宽度上。
            // 响应式页面可能在纹理回来前已经改过节点尺寸；先记住当前布局结果，避免
            // 异步回调又把短屏控件恢复成 build 时的默认大小。
            const transform = n.getComponent(UITransform);
            const targetW = transform?.width ?? w;
            const targetH = transform?.height ?? h;
            sprite.sizeMode = Sprite.SizeMode.CUSTOM;
            sprite.spriteFrame = frame;
            transform?.setContentSize(targetW, targetH);
            // tint 是乘法叠色，只能压暗不能提亮：用它把「非当前项」调灰，
            // 让保持原色的当前项自己跳出来，比给当前项加特效省一张图。
            const t = tint ?? Color.WHITE;
            sprite.color = new Color(t.r, t.g, t.b, opacity);
        };
        // 与启动预加载共用解析缓存；节点创建时拿到的已是远程图或本地兜底的最终纹理。
        void UIKit.resolveImageTexture(resourcePath).then(texture => { if (texture) apply(texture); });
        return n;
    }

    /**
     * 透明点击区只负责交互，不再用临时色块破坏设计稿切图。
     * 视觉资产与触控热区分离后，后续替换贴图不会影响路由和业务回调。
     */
    static hitArea(parent: Node, w: number, h: number, x: number, y: number,
        onTap: () => void): Node {
        const n = new Node('hitArea');
        n.layer = Layers.Enum.UI_2D;
        n.setParent(parent);
        n.setPosition(x, y, 0);
        n.addComponent(UITransform).setContentSize(w, h);
        n.on(NodeEventType.TOUCH_END, onTap);
        return n;
    }

    /** 圆角矩形。所有面板与卡片的底座。 */
    static panel(parent: Node, w: number, h: number, r: number, fill: Color,
        x: number, y: number, stroke?: Color, strokeW = 0): Node {
        const n = new Node('panel');
        n.layer = Layers.Enum.UI_2D;
        n.setParent(parent);
        n.addComponent(UITransform).setContentSize(w, h);
        n.setPosition(x, y, 0);
        const g = n.addComponent(Graphics);
        const rr = Math.min(r, w / 2, h / 2);
        g.roundRect(-w / 2, -h / 2, w, h, rr);
        g.fillColor = fill;
        g.fill();
        if (stroke && strokeW > 0) {
            g.lineWidth = strokeW;
            g.strokeColor = stroke;
            g.stroke();
        }
        return n;
    }

    /**
     * 选中态的暖金辉光，垫在美术切图**之下**，只从切图轮廓四周透出来。
     *
     * 为什么不是「一层实心 + 描边」：Graphics 没有模糊也没有阴影，硬边压在手绘底图上
     * 会读成贴纸；这里用三层逐级放大、逐级变淡的圆角块手工羽化。w≈h 时是圆形光晕，
     * 扁矩形时是胶囊——站点圆章和难度名牌共用这一个原语，选中语言才是同一套。
     *
     * spread 是最外圈探出切图轮廓的距离：浅色羊皮纸控制台上 22 就够看，
     * 压在满是绿地和石径的地图插画上要给到 38 才不会被背景吃掉。
     */
    static glow(parent: Node, w: number, h: number, x: number, y: number,
        spread = 22, color = new Color(255, 206, 96)): Node {
        const n = new Node('selectGlow');
        n.layer = Layers.Enum.UI_2D;
        n.setParent(parent);
        n.setPosition(x, y, 0);
        n.addComponent(UITransform).setContentSize(w + spread, h + spread);
        ([[1, 34], [0.55, 66], [0.18, 104]] as const).forEach(([k, alpha]) => {
            const pad = spread * k;
            UIKit.panel(n, w + pad, h + pad, (Math.min(w, h) + pad) / 2,
                new Color(color.r, color.g, color.b, alpha), 0, 0);
        });
        return n;
    }

    /**
     * 文字。
     *
     * anchorLeft 是必要的：Label 默认以自身中心为锚点，长短不一的文字左边缘对不齐，
     * 长文本还会溢出卡片（踩过：难度行的「N 种」挂到框外）。
     */
    static label(parent: Node, text: string, size: number, color: Color,
        x: number, y: number, anchorLeft = false): Label {
        const n = new Node('lbl');
        n.layer = Layers.Enum.UI_2D;
        n.setParent(parent);
        n.setPosition(x, y, 0);
        const l = n.addComponent(Label);
        l.string = text;
        l.fontSize = size;
        l.lineHeight = size * 1.25;
        l.color = color;
        l.overflow = Label.Overflow.NONE;
        if (anchorLeft) {
            l.horizontalAlign = Label.HorizontalAlign.LEFT;
            n.getComponent(UITransform)?.setAnchorPoint(0, 0.5);
        }
        return l;
    }

    static title(parent: Node, text: string, x: number, y: number) {
        return UIKit.label(parent, text, 62, UIColors.gold, x, y);
    }

    static caption(parent: Node, text: string, x: number, y: number) {
        return UIKit.label(parent, text, 21, UIColors.textSoft, x, y);
    }

    /** 分区小标题（「选择场景」这类）。 */
    static section(parent: Node, text: string, x: number, y: number) {
        return UIKit.label(parent, text, 22, UIColors.textSoft, x, y, true);
    }

    static footer(parent: Node, text: string, x: number, y: number) {
        return UIKit.label(parent, text, 20, UIColors.textSoft, x, y);
    }

    /** 可选卡片。selected 描金加粗，locked 压暗且不描边。 */
    static card(parent: Node, w: number, h: number, x: number, y: number,
        selected: boolean, unlocked = true): Node {
        const fill = unlocked ? UIColors.creamCard : UIColors.creamLocked;
        return UIKit.panel(parent, w, h, 20, fill, x, y,
            selected ? UIColors.gold : UIColors.edgeSoft, selected ? 6 : 3);
    }

    /** 场景卡左侧的两条主色预览。 */
    static swatch(card: Node, a: Color, b: Color, x: number) {
        UIKit.panel(card, 48, 66, 12, a, x, 0, new Color(255, 255, 255, 120), 2);
        UIKit.panel(card, 24, 66, 8, b, x + 40, 0);
    }

    static cardTitle(card: Node, text: string, x: number) {
        return UIKit.label(card, text, 26, UIColors.text, x, 18, true);
    }

    static cardNote(card: Node, text: string, color: Color, x: number) {
        return UIKit.label(card, text, 18, color, x, -18, true);
    }

    static rowTitle(card: Node, text: string, x: number, y: number, unlocked: boolean) {
        return UIKit.label(card, text, 27, unlocked ? UIColors.text : UIColors.textLocked, x, y, true);
    }

    static rowNote(card: Node, text: string, x: number, y: number) {
        return UIKit.label(card, text, 18, UIColors.textSoft, x, y, true);
    }

    /** 三颗星：亮星 = 已达成。同时兼作解锁指示（全灰 = 没通关过）。 */
    static stars(card: Node, filled: number, x: number, y = 0, size = 26, gap = 32) {
        for (let i = 0; i < 3; i++) {
            UIKit.label(card, '★', size,
                i < filled ? UIColors.gold : UIColors.starOff, x + i * gap, y);
        }
    }

    /** 主按钮：下沉阴影 + 按压回弹，与工程既有按钮同款手感。 */
    static primaryButton(parent: Node, text: string, x: number, y: number, onTap: () => void): Node {
        const hit = new Node('btn');
        hit.layer = Layers.Enum.UI_2D;
        hit.setParent(parent);
        hit.setPosition(x, y, 0);
        const w = 360, h = 96;
        hit.addComponent(UITransform).setContentSize(w, h);
        UIKit.panel(hit, w, h, 24, UIColors.edge, 0, -6);
        const face = UIKit.panel(hit, w, h, 24, UIColors.goldFill, 0, 0, UIColors.edge, 5);
        UIKit.label(face, text, 36, UIColors.text, 0, 0);
        UIKit.tap(hit, onTap);
        return hit;
    }

    /** 小型圆键，供整页导航使用；不借用游玩 HUD，避免页面之间互相持有节点。 */
    static roundButton(parent: Node, text: string, x: number, y: number, onTap: () => void): Node {
        const hit = UIKit.panel(parent, 64, 64, 32, UIColors.cream, x, y, UIColors.edge, 4);
        UIKit.label(hit, text, 27, UIColors.text, 0, 1);
        UIKit.tap(hit, onTap);
        return hit;
    }

    /** 按下缩一点、松手弹回。所有可点元素共用，保证手感一致。 */
    static tap(node: Node, onTap: () => void) {
        node.on(NodeEventType.TOUCH_START, () => {
            tween(node).stop();
            tween(node).to(0.06, { scale: v3(0.96, 0.96, 1) }).start();
        });
        node.on(NodeEventType.TOUCH_END, () => {
            tween(node).to(0.08, { scale: v3(1, 1, 1) }, { easing: 'backOut' }).start();
            onTap();
        });
        node.on(NodeEventType.TOUCH_CANCEL, () => {
            tween(node).to(0.08, { scale: v3(1, 1, 1) }, { easing: 'backOut' }).start();
        });
    }
}

void Font;
