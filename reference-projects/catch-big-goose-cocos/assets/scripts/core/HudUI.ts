import {
    Node, Scene, Camera, Canvas, Label, Layers, Color, UITransform, Sprite, SpriteFrame, Texture2D,
    NodeEventType, Widget, view, screen, Graphics, UIOpacity, resources,
    tween, v3, Vec2, Vec3, Tween,
} from 'cc';
import { UIRouter } from './ui/UIRouter';
import { HomeScreen, HomeData } from './ui/HomeScreen';
import { OnboardingScreen, OnboardingData } from './ui/OnboardingScreen';

export type PropKind = 'remove' | 'magnet' | 'shuffle';

/** UI 矢量图标种类（不依赖字体，见 HudUI.drawGlyph）。 */
type IconKind = PropKind | 'pause' | 'play' | 'palette' | 'star' | 'sound-on' | 'sound-off'
    | 'stopwatch' | 'snowflake';

type HorizontalAlign = { left?: number; right?: number; centerX?: boolean };

type TrayIconLayout = { offsetX: number; offsetY: number; contentW: number; contentH: number };

/**
 * 图标 PNG 都是 192×192，但 GLB 导出时模型在透明画布中的位置并不一致。
 * 这里记录实际非透明像素包围盒相对画布中心的偏移与尺寸，让“视觉内容”而不是 PNG 画布居中。
 * offsetY 使用图片坐标（向下为正），应用到 Cocos 节点时会反向换算。
 */
const TRAY_ICON_LAYOUT: Record<string, TrayIconLayout> = {
    banzhi: { offsetX: -0.5, offsetY: -0.5, contentW: 118, contentH: 108 },
    bracelet: { offsetX: -0.5, offsetY: -0.5, contentW: 118, contentH: 72 },
    carrot: { offsetX: 0, offsetY: 1.5, contentW: 52, contentH: 143 },
    goose: { offsetX: -10.5, offsetY: 12.5, contentW: 94, contentH: 102 },
    hulu: { offsetX: 0, offsetY: 5, contentW: 94, contentH: 134 },
    ruyi: { offsetX: -7.5, offsetY: 7, contentW: 149, contentH: 34 },
    tongqian: { offsetX: -0.5, offsetY: -0.5, contentW: 118, contentH: 66 },
    yuzhuo: { offsetX: -0.5, offsetY: -0.5, contentW: 118, contentH: 68 },
};

/**
 * 参考竞品重制的 HUD：顶部暂停/计时、轻量进度条、底部红木控制台、
 * 三枚镶金红木道具键。图标用 Graphics 矢量绘制（见 drawGlyph），不依赖字体。
 */
export class HudUI {
    /**
     * 全 HUD 统一配色：深墨绿面 + 细亮金边 + 近白文字（按设计稿）。
     *
     * 定成一组具名常量而不是散在构建代码里，是因为这几个值必须**一起**改：
     * 面色一变，金边和文字的明度都得跟着调，否则要么糊在一起要么刺眼。
     *
     * 为什么是墨绿而不是之前那版红木棕：红木面和背景（红木桌面 / 藤筐 / 野餐布）
     * 同色系，控件边界靠明度硬撑，换个皮肤就糊掉；墨绿近乎中性，压在任何背景上
     * 都退得干净，金边一挑就把控件轮廓立起来——这也是设计稿两张图（野餐布绿底、
     * 红木桌深底）能共用同一套 HUD 的原因。
     * 金取低饱和旧金而不是纯黄：纯黄在深墨上会跳成霓虹。
     */
    private static readonly INK_FACE = new Color(31, 38, 33);
    private static readonly INK_DEEP = new Color(20, 25, 21);
    private static readonly GOLD_EDGE = new Color(227, 195, 124);
    private static readonly INK_TEXT = new Color(240, 237, 226);
    private static readonly GOLD_TEXT = new Color(219, 188, 122);

    /**
     * 三枚道具键的图标色，按设计稿**保留三色**、不统一成金。
     *
     * 上一版把它们统一成金色，整排是安静了，但三个功能只剩轮廓可辨——道具是
     * 低频且要快速命中的操作，颜色是最快的索引。设计稿的做法是：面/边/字统一，
     * 只有图标留彩色，既不花又能一眼分辨。饱和度压到能在墨绿上站住又不刺眼。
     */
    private static readonly ICON_REMOVE = new Color(122, 198, 108);
    private static readonly ICON_MAGNET = new Color(233, 170, 66);
    private static readonly ICON_SHUFFLE = new Color(141, 126, 226);

    timerLabel!: Label;
    progressLabel!: Label;
    msgLabel!: Label;
    subMsgLabel!: Label;

    /** 冰封件头上的雪花标记，key = 物件节点 uuid。 */
    private frostMarks = new Map<string, Node>();

    private uiCam!: Camera;
    private canvasUT!: UITransform;
    private canvasNode!: Node;
    private contentRoot!: Node;
    /** 游玩期 HUD（计时/得分/七格槽/道具栏/左侧按钮）。整屏页面显示时整层隐藏。 */
    private gameLayer!: Node;
    /** 挑战开始等整屏页面单独缩放，避免较矮窗口裁掉长图的标题和底部操作区。 */
    private screenLayer!: Node;
    private contentUT!: UITransform;
    private uiScale = 1;
    private screenScale = 1;
    private screenOffsetY = 0;
    /** 当前首页实例；地图切换只刷新站点层，避免整页路由重建产生闪白。 */
    private homeScreen: HomeScreen | null = null;
    private progressFill!: UITransform;
    private trayDangerGlow!: Node;
    private trayDangerOpacity!: UIOpacity;
    private pauseIcon!: Graphics;
    /** 声音键图标；未传 onToggleSound 时不建按钮，保持 null。 */
    private soundIcon: Graphics | null = null;
    /** 道具栏总开关（关闭则完全隐藏道具 UI）。 */
    private static readonly SHOW_PROPS = true;
    private static readonly PROGRESS_W = 252;
    private static readonly TRAY_BOTTOM = 126;
    private static readonly TRAY_CENTER_Y = 169;
    private static readonly SLOT_STEP = 88;
    private propBadge: Record<PropKind, Label> = {} as Record<PropKind, Label>;
    private propOpacity: Record<PropKind, UIOpacity> = {} as Record<PropKind, UIOpacity>;
    private levelLabel!: Label;
    private dailyLabel!: Label;
    private scoreLabel!: Label;
    /** 七个槽位面板，按下标索引（同类将满时闪框用）。 */
    private slotNodes: Node[] = [];
    /** 连击牌：牌身 / 透明度 / 文案 / 倒计条，见 setCombo。 */
    private comboPill!: Node;
    private comboPillOpacity!: UIOpacity;
    private comboLabel!: Label;
    private comboBar!: Node;
    private comboShown = false;
    private toastRoot: Node | null = null;
    private promoGoose: Node | null = null;
    private promoWalkTime = 0;

    showPromoGoose(onTap: () => void) {
        this.hidePromoGoose();
        const root = new Node('PromoGoose');
        root.layer = Layers.Enum.UI_2D;
        root.setParent(this.gameLayer);
        root.addComponent(UITransform).setContentSize(270, 240);
        root.on(NodeEventType.TOUCH_END, onTap);
        this.promoGoose = root;
        this.promoWalkTime = 0;
        for (const offset of [-24, 32]) {
            const foot = new Node(`Foot${offset}`);
            foot.layer = Layers.Enum.UI_2D;
            foot.setParent(root);
            foot.setPosition(offset, -36);
            const pen = foot.addComponent(Graphics);
            pen.strokeColor = new Color(220, 126, 35);
            pen.lineWidth = 9;
            pen.moveTo(0, 0);
            pen.lineTo(-5, -25);
            pen.lineTo(-22, -25);
            pen.stroke();
        }
        const pen = root.addComponent(Graphics);
        pen.fillColor = new Color(255, 249, 230);
        pen.ellipse(10, -5, 72, 46);
        pen.fill();
        pen.roundRect(-73, -12, 33, 89, 16);
        pen.fill();
        pen.ellipse(-66, 74, 30, 25);
        pen.fill();
        pen.moveTo(67, 1);
        pen.lineTo(101, 27);
        pen.lineTo(76, -21);
        pen.fill();
        pen.fillColor = new Color(242, 159, 46);
        pen.moveTo(-87, 80);
        pen.lineTo(-123, 65);
        pen.lineTo(-86, 59);
        pen.fill();
        pen.fillColor = new Color(52, 39, 26);
        pen.circle(-75, 81, 4);
        pen.fill();
        pen.fillColor = new Color(214, 176, 111);
        pen.roundRect(-22, 13, 91, 63, 16);
        pen.fill();
        pen.strokeColor = new Color(136, 83, 43);
        pen.lineWidth = 6;
        pen.moveTo(-6, 18);
        pen.lineTo(-6, 73);
        pen.moveTo(51, 18);
        pen.lineTo(51, 73);
        pen.stroke();
        const kinds: PropKind[] = ['remove', 'magnet', 'shuffle'];
        const colors = [new Color(128, 203, 156), new Color(246, 181, 74), new Color(152, 186, 243)];
        kinds.forEach((kind, index) => {
            const badge = this.makePanelChild(root, 43, 48, 9, colors[index], -16 + index * 36, 80 + (index % 2) * 22,
                new Color(136, 83, 43), 3);
            badge.setRotationFromEuler(0, 0, 15 - index * 15);
            this.drawIcon(badge, kind, 30, new Color(82, 53, 26), 0, 0);
        });
        const caption = this.makePanelChild(root, 250, 42, 16, new Color(57, 39, 22, 245), 0, -99,
            new Color(240, 193, 94), 2);
        this.addLabel(caption, '点大鹅 · 看宣传片领道具', 18, new Color(255, 236, 192), 0, 0, true);
        this.advancePromoGoose(0);
    }

    advancePromoGoose(dt: number) {
        if (!this.promoGoose?.isValid) return;
        this.promoWalkTime += dt;
        if (this.promoWalkTime >= 14) { this.hidePromoGoose(); return; }
        const edge = this.contentUT.width / 2 + 155;
        this.promoGoose.setPosition(edge * (1 - this.promoWalkTime / 7), 30 + Math.abs(Math.sin(this.promoWalkTime * 9)) * 6);
        this.promoGoose.children.filter(child => child.name.startsWith('Foot')).forEach((foot, index) => {
            foot.setRotationFromEuler(0, 0, Math.sin(this.promoWalkTime * 9 + index * Math.PI) * 24);
        });
    }

    hitsPromoGoose(point: Vec2): boolean {
        return !!this.promoGoose?.isValid && !!this.promoGoose.getComponent(UITransform)?.hitTest(point);
    }

    hidePromoGoose() {
        if (this.promoGoose?.isValid) {
            this.promoGoose.active = false;
            this.promoGoose.destroy();
        }
        this.promoGoose = null;
    }
    /** 计时牌节点：进入读秒时整体脉冲，制造紧迫感。 */
    private timerPanel!: Node;
    private timerUrgent = false;
    private resultRoot: Node | null = null;
    private pauseRoot: Node | null = null;
    /** 页面路由。开始页等整屏页面走它，弹窗（暂停/结算/提示）仍走 makeModal。 */
    private router!: UIRouter;
    private hintRoot: Node | null = null;
    private comboPopRoot: Node | null = null;
    private capturedModels = new Map<Node, number>();
    private capturedIcons = new Map<Node, Node>();
    private onOverlayToggle?: (open: boolean) => void;

    constructor(scene: Scene, onProp: (kind: PropKind) => void, onPause?: () => void,
        onOverlayToggle?: (open: boolean) => void, onToggleSound?: () => boolean) {
        this.onOverlayToggle = onOverlayToggle;
        const canvasNode = new Node('HudCanvas');
        this.canvasNode = canvasNode;
        canvasNode.layer = Layers.Enum.UI_2D;
        canvasNode.setParent(scene);
        this.canvasUT = canvasNode.addComponent(UITransform);
        const canvas = canvasNode.addComponent(Canvas);

        const camNode = new Node('UICamera');
        camNode.layer = Layers.Enum.UI_2D;
        camNode.setParent(canvasNode);
        camNode.setPosition(0, 0, 1000);
        this.uiCam = camNode.addComponent(Camera);
        this.uiCam.projection = Camera.ProjectionType.ORTHO;
        this.uiCam.near = 1;
        this.uiCam.far = 2000;
        this.uiCam.clearFlags = Camera.ClearFlag.DEPTH_ONLY;
        this.uiCam.visibility = Layers.Enum.UI_2D;
        this.uiCam.priority = 10;
        canvas.cameraComponent = this.uiCam;

        // 以 720 宽的美术坐标继续排版，再整体缩放到手机可视宽度。
        // 这样 390px 手机不会裁掉七格收集区和左右道具按钮，同时保留现有视觉比例。
        this.contentRoot = new Node('HudContent');
        this.contentRoot.layer = Layers.Enum.UI_2D;
        this.contentRoot.setParent(canvasNode);
        this.contentUT = this.contentRoot.addComponent(UITransform);
        this.contentUT.setContentSize(720, 1280);

        // 内容根下再分两层，因为「开始页」这类整屏页面显示时，游玩 HUD（计时、七格槽、
        // 道具栏）必须整体隐藏——它们不属于那一页。分层之后切页面只是开关一个节点，
        // 不用逐个记住谁该显谁该藏。
        this.gameLayer = new Node('HudGame');
        this.gameLayer.layer = Layers.Enum.UI_2D;
        this.gameLayer.setParent(this.contentRoot);
        this.gameLayer.addComponent(UITransform).setContentSize(720, 1280);

        this.screenLayer = new Node('HudScreens');
        this.screenLayer.layer = Layers.Enum.UI_2D;
        this.screenLayer.setParent(this.contentRoot);
        this.screenLayer.addComponent(UITransform).setContentSize(720, 1280);
        this.router = new UIRouter(this.screenLayer, 720, 1280);

        const cream = new Color(255, 247, 218);

        // 左上三键：与道具键同一套墨绿面 + 细金边，图标近白。
        // 不再加共用托板——底部台面去掉后，这块半透明托板成了画面里唯一的"底板"，
        // 反而显脏；三枚键竖排本身已经读成一组。
        const dockFill = HudUI.INK_FACE;
        const DOCK_STEP = 76;

        const pause = this.makeDockButton(66, 66, 20, dockFill,
            { top: 24 }, { left: 24 }, () => onPause?.(), 4, 0.34, HudUI.GOLD_EDGE);
        this.pauseIcon = this.drawIcon(pause.face, 'pause', 33, cream, 0, 0);

        // 这里原本还有个换肤键。场景现在只在开始页选定、进局后不可改——它决定物件族，
        // 中途换等于换牌组，成绩也会失去可比性。入口已移到 showHome。

        // 声音键：默认静音。开关只放在暂停菜单里的话，多数玩家整局都不知道有声音，
        // 所以主界面必须有个看得见的入口。
        if (onToggleSound) {
            const sound = this.makeDockButton(66, 66, 20, dockFill,
                { top: 24 + DOCK_STEP }, { left: 24 },
                () => this.setSoundOn(onToggleSound()), 4, 0.34, HudUI.GOLD_EDGE);
            this.soundIcon = this.drawIcon(sound.face, 'sound-off', 33, cream, 0, 0);
        }

        // 计时牌和细进度条，缩小存在感，把视觉主舞台让给 3D 容器。
        const timerShadow = this.makePanel(190, 58, 27, new Color(14, 19, 16, 185), { top: 25 }, 0);
        timerShadow.setPosition(0, -5, 0);
        const timerPanel = this.makePanel(184, 54, 25,
            new Color(HudUI.INK_FACE.r, HudUI.INK_FACE.g, HudUI.INK_FACE.b, 236), { top: 22 }, 0,
            HudUI.GOLD_EDGE, 2);
        this.timerPanel = timerPanel;
        // 秒表图标 + 数字左右并排（设计稿）。牌宽 160 → 184 才容得下两者，
        // 否则数字被挤到贴边，读作"排版没对齐"。
        this.drawIcon(timerPanel, 'stopwatch', 31, HudUI.INK_TEXT, -49, 1);
        this.timerLabel = this.addLabel(timerPanel, '0:00', 34, HudUI.INK_TEXT, 17, 0, true);

        // 右上关卡标牌,与左上暂停键对称。
        const levelPanel = this.makePanel(112, 52, 16,
            new Color(HudUI.INK_FACE.r, HudUI.INK_FACE.g, HudUI.INK_FACE.b, 236), { top: 28 }, 0,
            HudUI.GOLD_EDGE, 2, { right: 23 });
        this.levelLabel = this.addLabel(levelPanel, '第 1 关', 24, HudUI.INK_TEXT, 0, 0, true);
        // 关卡标牌下的每日剩余次数。
        this.dailyLabel = this.addLabel(levelPanel, '今日 3/3', 16, HudUI.GOLD_TEXT, 0, -42, true);

        const W = HudUI.PROGRESS_W;
        const progPanel = this.makePanel(W, 24, 12,
            new Color(HudUI.INK_DEEP.r, HudUI.INK_DEEP.g, HudUI.INK_DEEP.b, 212), { top: 88 }, 0,
            new Color(HudUI.GOLD_EDGE.r, HudUI.GOLD_EDGE.g, HudUI.GOLD_EDGE.b, 195), 1.5);
        const fillNode = new Node('progressFill');
        fillNode.layer = Layers.Enum.UI_2D;
        fillNode.setParent(progPanel);
        this.progressFill = fillNode.addComponent(UITransform);
        this.progressFill.setAnchorPoint(0, 0.5);
        fillNode.setPosition(-W / 2 + 4, 0, 0);
        const fg = fillNode.addComponent(Graphics);
        // 锚点在左端，所以渐变整体右移半个宽度对齐
        const progFill = new Color(106, 205, 75, 255);
        HudUI.fillVGradient(fg, W - 8, 16, 8,
            HudUI.warm(HudUI.lighten(progFill, 0.34), 0.18),
            HudUI.cool(HudUI.darken(progFill, 0.22), 0.12), 8, (W - 8) / 2, 0);
        fillNode.setScale(0, 1);
        // 星级刻度：50% / 70% 两道浅色竖线，让玩家随时看清离下一颗星还差多少。
        const tickNode = new Node('progressTicks');
        tickNode.layer = Layers.Enum.UI_2D;
        tickNode.setParent(progPanel);
        const tg = tickNode.addComponent(Graphics);
        tg.strokeColor = new Color(255, 244, 214, 175);
        tg.lineWidth = 2;
        for (const p of [0.5, 0.7]) {
            const x = -W / 2 + 4 + (W - 8) * p;
            tg.moveTo(x, -7);
            tg.lineTo(x, 7);
        }
        tg.stroke();
        this.progressLabel = this.addLabel(progPanel, '0%', 17, cream, 0, 0, true);

        // 得分牌：与进度条同一行，贴在它左侧的空白带里（不与左上两枚圆键重叠）。
        const scorePanel = this.makePanel(130, 24, 12,
            new Color(HudUI.INK_DEEP.r, HudUI.INK_DEEP.g, HudUI.INK_DEEP.b, 212), { top: 88 }, 0,
            new Color(HudUI.GOLD_EDGE.r, HudUI.GOLD_EDGE.g, HudUI.GOLD_EDGE.b, 195), 1.5, { left: 96 });
        this.scoreLabel = this.addLabel(scorePanel, '得分 0', 18, HudUI.GOLD_TEXT, 0, 0, true);

        // 连击牌：贴在得分牌正下方，倍率 + 一条走完即断连的倒计条。
        // 连击是本作唯一的加分放大器，此前只在飘字里闪一下就没了，
        // 玩家既不知道自己正连着，也不知道还剩多久——等于把核心爽点藏起来了。
        // 连击牌保留暖橙描边：它是限时状态，需要从这套冷墨里跳出来才看得见。
        this.comboPill = this.makePanel(130, 26, 13, new Color(46, 26, 16, 230), { top: 120 }, 0,
            new Color(240, 150, 66), 2, { left: 96 });
        this.comboPillOpacity = this.comboPill.addComponent(UIOpacity);
        this.comboPillOpacity.opacity = 0;
        this.comboLabel = this.addLabel(this.comboPill, '连击 ×2', 15, new Color(255, 214, 76), 0, 3, true);
        const comboBar = new Node('comboBar');
        comboBar.layer = Layers.Enum.UI_2D;
        comboBar.setParent(this.comboPill);
        comboBar.addComponent(UITransform).setAnchorPoint(0, 0.5);
        comboBar.setPosition(-59, -9, 0);
        const cbg = comboBar.addComponent(Graphics);
        cbg.fillColor = new Color(255, 146, 62, 255);
        cbg.roundRect(0, -2, 118, 4, 2);
        cbg.fill();
        this.comboBar = comboBar;

        // 结算文案。
        this.msgLabel = this.makeFloatingLabel('', 48, new Color(255, 221, 91), { centerY: 92 });
        this.subMsgLabel = this.makeFloatingLabel('', 25, cream, { centerY: 30 });

        // 收集区是固定屏幕坐标的 2D HUD，不再跟随 3D 相机产生透视变形。
        // 模型稍后放入独立 UI_2D 三维层，仍保留真实 Mesh 和旋转，而不是截图/图标替代。
        // 5 格起显示的危险边缘放在槽位底层，不覆盖模型图标，也不增加额外文案干扰。
        this.trayDangerGlow = this.makePanel(682, 102, 24, new Color(244, 91, 48, 235),
            { bottom: HudUI.TRAY_BOTTOM - 11 }, 0);
        this.trayDangerOpacity = this.trayDangerGlow.addComponent(UIOpacity);
        this.trayDangerOpacity.opacity = 0;
        // 收集槽改走红木金调，与道具键同一材质语言。
        //
        // 旧配色是近白托盘(244,242,235) + 白描边 + 灰白槽，面积又大又亮，是整块 HUD 里
        // 最抢眼的东西——道具键再怎么收敛，视线也先被这条白带拽走，"高级感"无从谈起。
        // 槽位语义是**凹进去**的格子，所以比托盘面更深；深槽同时衬得住放进来的
        // 亮色物件缩略图（槽内柔光见 addSlotLight），对比比浅槽更强。
        this.makePanel(670, 90, 20, new Color(12, 16, 14, 230), { bottom: HudUI.TRAY_BOTTOM - 5 }, 0);
        const trayPanel = this.makePanel(654, 82, 18, HudUI.INK_FACE,
            { bottom: HudUI.TRAY_BOTTOM }, 0, HudUI.GOLD_EDGE, 2);
        for (let i = 0; i < 7; i++) {
            // 槽比托盘面更深，且**不描金边**：七道金框排一行会把托盘切成七块、
            // 抢掉外框那一圈金线的主次。只用一道极淡的亮边提示格子上沿。
            const slot = this.makePanelChild(trayPanel, 78, 64, 14, HudUI.INK_DEEP,
                (i - 3) * HudUI.SLOT_STEP, 0, new Color(150, 168, 152, 60), 1);
            this.addSlotLight(slot);
            this.slotNodes.push(slot);
        }

        // 道具栏受 SHOW_PROPS 总开关控制，当前开启。
        if (HudUI.SHOW_PROPS) {
        // 底部置物架承接三枚道具键，进入关卡后必须始终可见；两层木板分别提供投影和台面，
        // 避免按钮直接悬浮在地图背景上。它只托住道具栏，不上移遮挡七格收集槽。
        this.makePanel(760, 128, 28, new Color(52, 30, 22, 224), { bottom: -18 }, 0);
        this.makePanel(752, 120, 25, new Color(86, 50, 35, 246), { bottom: -12 }, 0,
            HudUI.GOLD_EDGE, 2);

        // 三枚道具键统一「深红木面 + 暖金图标」，靠**形状**区分功能，不靠颜色。
        //
        // 旧版是亮黄面(255,202,48) + 亮绿/品红/紫蓝三色图标：亮黄大面积高饱和本身就
        // 廉价，三个高饱和且互不相干的图标色又把一排键拆成三块花色，跟这游戏红木/
        // 翡翠古玩的底子完全脱节。现在整排同色同材质，只有轮廓不同，安静下来才显贵。
        // paintFace 的渐变/釉光/沿光全部由 fill 派生（lighten/warm(fill)），
        // 所以面色一换深，那套「糖果塑料通透感」自动跟着压暗成木器的哑光。
        const defs: Array<{
            kind: PropKind; text: string; color: Color; align: HorizontalAlign;
        }> = [
            { kind: 'remove', text: '移出', color: HudUI.ICON_REMOVE, align: { left: 24 } },
            { kind: 'magnet', text: '凑齐', color: HudUI.ICON_MAGNET, align: { centerX: true } },
            { kind: 'shuffle', text: '打乱', color: HudUI.ICON_SHUFFLE, align: { right: 24 } },
        ];

        defs.forEach(({ kind, text, color, align }) => {
            // gloss 0.30：釉光是给糖果塑料面做的，留在深木上就是一片假反光；
            // 压到三成只当木器的哑光反射，再高上半部就浮出一块塑料亮斑。
            const { face } = this.makeDockButton(184, 80, 20, HudUI.INK_FACE,
                { bottom: 20 }, align, () => onProp(kind), 5, 0.30, HudUI.GOLD_EDGE);
            this.propOpacity[kind] = face.addComponent(UIOpacity);
            // 44 而不是 40：设计稿里图标约占键高四成，40 只有三成三，显小。
            // 再大就会压到下面 y=-25 的文字（图标半高 ±17px，文字上边界 -14）。
            this.drawIcon(face, kind, 44, color, 0, 12);
            this.addLabel(face, text, 22, HudUI.INK_TEXT, 0, -25, true);

            // 角标：原先是暖红圆牌 + 奶白环，那抹高饱和红是整块 HUD 里最抢眼的东西，
            // 而它只承载「你还有几个」这条次要信息。改成墨底金环，退回信息该有的层级。
            // 数量为 0 时再由 setPropCount 转成灰调。
            const badge = new Node('badge');
            badge.layer = Layers.Enum.UI_2D;
            badge.setParent(face);
            badge.setPosition(77, 33, 0);
            badge.addComponent(UITransform).setContentSize(32, 32);
            // 红底白字（按设计稿）：墨绿面上唯一的暖色高饱和点，恰好落在角标这个
            // 「还剩几个」的读数上。环用更深的红而不是白——白环在墨面上会晃眼，
            // 且会和金边抢那一圈亮线。
            HudUI.paintBadge(badge.addComponent(Graphics), 16,
                new Color(212, 62, 52), new Color(138, 32, 26));
            this.propBadge[kind] = this.addLabel(badge, '0', 16, new Color(255, 252, 246), 0, 0, true);
        });
        } // if SHOW_PROPS

    }

    setLevel(n: number) {
        this.levelLabel.string = `第 ${n} 关`;
    }

    setDaily(left: number) {
        this.dailyLabel.string = `今日 ${left}/3`;
        this.dailyLabel.color = left > 0 ? new Color(233, 200, 156) : new Color(240, 120, 96);
    }

    /**
     * 3D 相机的屏幕坐标 → HudContent 内容坐标。
     *
     * 入参来自 camera.worldToScreen，单位是**帧缓冲物理像素**（dpr=2 的手机上是 780×1690）；
     * 而 HUD 这一层跑在 Canvas 的**逻辑像素**坐标系里（view.getVisibleSize()，390×845），
     * uiScale 也是按逻辑尺寸算出来的。所以必须先按两者之比降到逻辑像素再换算。
     *
     * 早先这里直接拿 screen.windowSize 当中心去减，等于把物理像素的偏移量当逻辑量用，
     * dpr=2 时整体放大一倍：提示环、拾取爆点、大鹅气泡、飞入槽位的起点全落到空地上。
     * dpr=1 时两套尺寸相等，所以在电脑浏览器上一直看不出问题。
     */
    private screenToContent(screenPos: Vec3): Vec3 {
        const win = screen.windowSize;
        const vis = view.getVisibleSize();
        const lx = win.width ? screenPos.x * vis.width / win.width : screenPos.x;
        const ly = win.height ? screenPos.y * vis.height / win.height : screenPos.y;
        return v3(
            (lx - vis.width / 2) / this.uiScale,
            (ly - vis.height / 2) / this.uiScale,
            1,
        );
    }

    /** 通用粒子爆点:count 个小圆从中心飞散渐隐 + 一个扩散圆环。 */
    private burstAt(pos: Vec3, color: Color, count: number, radius: number, dotR: number) {
        const root = new Node('burst');
        root.layer = Layers.Enum.UI_2D;
        root.setParent(this.gameLayer);
        root.setPosition(pos);

        const ring = new Node('ring');
        ring.layer = Layers.Enum.UI_2D;
        ring.setParent(root);
        const rg = ring.addComponent(Graphics);
        rg.lineWidth = 5;
        rg.strokeColor = new Color(color.r, color.g, color.b, 210);
        rg.circle(0, 0, radius * 0.4);
        rg.stroke();
        const ringOp = ring.addComponent(UIOpacity);
        tween(ring).to(0.3, { scale: v3(2.4, 2.4, 1) }, { easing: 'quadOut' }).start();
        tween(ringOp).to(0.3, { opacity: 0 }).start();

        for (let i = 0; i < count; i++) {
            const dot = new Node('dot');
            dot.layer = Layers.Enum.UI_2D;
            dot.setParent(root);
            const g = dot.addComponent(Graphics);
            g.fillColor = color;
            g.circle(0, 0, dotR * (0.7 + Math.random() * 0.6));
            g.fill();
            const ang = (i / count) * Math.PI * 2 + Math.random() * 0.5;
            const dist = radius * (0.75 + Math.random() * 0.5);
            const op = dot.addComponent(UIOpacity);
            tween(dot)
                .to(0.32 + Math.random() * 0.12, {
                    position: v3(Math.cos(ang) * dist, Math.sin(ang) * dist, 0),
                    scale: v3(0.3, 0.3, 1),
                }, { easing: 'quadOut' })
                .start();
            tween(op).delay(0.12).to(0.26, { opacity: 0 }).start();
        }
        // 粒子生命周期极短,统一 0.6s 后销毁根节点。
        tween(root).delay(0.6).call(() => root.destroy()).start();
    }

    /** 拾取瞬间的轻量白色爆点(3D 世界屏幕坐标)。 */
    pickBurst(screenPos: Vec3) {
        this.burstAt(this.screenToContent(screenPos), new Color(255, 246, 200, 255), 6, 44, 5);
    }

    /**
     * 胜利庆祝：屏幕上半区错开时间连撒几束金色粒子。
     * 通关此前只有一个弹窗弹出来，画面上没有任何"成了"的反馈。
     */
    winCelebrate() {
        const top = this.contentUT.height / 2;
        for (let i = 0; i < 8; i++) {
            const pos = v3((Math.random() - 0.5) * 600, top * (0.12 + Math.random() * 0.52), 0);
            const gold = i % 2 === 0;
            // 借一个空节点做定时器：粒子本身生命周期很短，必须错开撒才有"连绵"感。
            const timer = new Node('celebrate');
            timer.layer = Layers.Enum.UI_2D;
            timer.setParent(this.gameLayer);
            tween(timer).delay(i * 0.11).call(() => {
                this.burstAt(pos, gold ? new Color(255, 205, 64, 255) : new Color(255, 246, 200, 255),
                    12, 92, 8);
                timer.destroy();
            }).start();
        }
    }

    /** 三消时在对应槽位上的金色爆点。 */
    matchBurst(node: Node) {
        const icon = this.capturedIcons.get(node);
        if (!icon?.isValid) return;
        this.burstAt(icon.position.clone(), new Color(255, 205, 64, 255), 10, 64, 7);
    }

    /** 得分刷新：数字换新的同时弹一下，让加分被看见。 */
    setScore(score: number) {
        this.scoreLabel.string = `得分 ${score}`;
        const n = this.scoreLabel.node;
        Tween.stopAllByTarget(n);
        n.setScale(1, 1, 1);
        tween(n)
            .to(0.09, { scale: v3(1.2, 1.2, 1) }, { easing: 'quadOut' })
            .to(0.15, { scale: v3(1, 1, 1) }, { easing: 'backOut' })
            .start();
    }

    /**
     * 连击牌刷新（每帧调用）：combo ≥ 2 时亮牌，倒计条按 remain（0~1）收缩，走完即隐。
     * 只在显隐切换时做动画，中间帧仅改条长和文案，避免每帧 new Tween。
     */
    setCombo(combo: number, remain: number) {
        const show = combo >= 2 && remain > 0;
        if (show !== this.comboShown) {
            this.comboShown = show;
            Tween.stopAllByTarget(this.comboPillOpacity);
            tween(this.comboPillOpacity).to(show ? 0.1 : 0.2, { opacity: show ? 255 : 0 }).start();
            if (show) {
                Tween.stopAllByTarget(this.comboPill);
                this.comboPill.setScale(0.6, 0.6, 1);
                tween(this.comboPill).to(0.18, { scale: v3(1, 1, 1) }, { easing: 'backOut' }).start();
            }
        }
        if (!show) return;
        this.comboLabel.string = `连击 ×${combo}`;
        this.comboBar.setScale(Math.max(0, Math.min(1, remain)), 1, 1);
    }

    /**
     * 槽内已攒到同类 2 件时闪一下这两格。
     * 「还差一个就消了」是这类玩法最强的推进动力，但七格里两枚小图标很容易被漏看。
     */
    markNearMatch(indices: number[]) {
        for (const i of indices) {
            const slot = this.slotNodes[i];
            if (!slot?.isValid) continue;
            const ring = new Node('nearMatch');
            ring.layer = Layers.Enum.UI_2D;
            ring.setParent(slot);
            ring.setPosition(0, 0, 3);
            const g = ring.addComponent(Graphics);
            g.lineWidth = 5;
            g.strokeColor = new Color(255, 201, 40, 255);
            g.roundRect(-39, -32, 78, 64, 14);
            g.stroke();
            const op = ring.addComponent(UIOpacity);
            tween(op)
                .repeat(2, tween(op).to(0.3, { opacity: 70 }).to(0.22, { opacity: 255 }))
                .to(0.2, { opacity: 0 })
                .call(() => ring.destroy())
                .start();
        }
    }

    /** 收集区上方的一句轻提示（残局提醒等）：不带遮罩、不打断操作，自己淡出。 */
    toast(text: string) {
        if (this.toastRoot?.isValid) this.toastRoot.destroy();
        const root = new Node('toast');
        this.toastRoot = root;
        root.layer = Layers.Enum.UI_2D;
        root.setParent(this.gameLayer);
        root.setPosition(0, -this.contentUT.height / 2 + 336, 3);
        const op = root.addComponent(UIOpacity);

        const bar = this.makePanelChild(root, 520, 60, 22, new Color(46, 25, 14, 232), 0, 0,
            new Color(214, 106, 48), 3);
        this.addLabel(bar, text, 23, new Color(255, 226, 176), 0, 0, true);

        root.setScale(0.85, 0.85, 1);
        tween(root).to(0.18, { scale: v3(1, 1, 1) }, { easing: 'backOut' }).start();
        tween(op).delay(1.9).to(0.4, { opacity: 0 }).call(() => root.destroy()).start();
    }

    /**
     * 三消得分飘字：收集区正上方弹出 "+N"，连击 ≥2 时再补一行 "连击 ×N"。
     * 位置固定在槽位上方，与消除爆点同处一个视线焦点，不用来回找。
     */
    comboPop(combo: number, gain: number) {
        // 上一条还没飘完就来了新的（道具连消时常见）→ 直接替换，不叠字。
        if (this.comboPopRoot?.isValid) this.comboPopRoot.destroy();
        const root = new Node('comboPop');
        this.comboPopRoot = root;
        root.layer = Layers.Enum.UI_2D;
        root.setParent(this.gameLayer);
        root.setPosition(0, -this.contentUT.height / 2 + 262, 2);
        const op = root.addComponent(UIOpacity);

        // 缩放弹跳挂在子节点上，与根节点的上浮位移互不干扰。
        const inner = new Node('inner');
        inner.layer = Layers.Enum.UI_2D;
        inner.setParent(root);
        this.addLabel(inner, `+${gain}`, combo >= 2 ? 46 : 38, new Color(255, 214, 76), 0, 0, true);
        if (combo >= 2) {
            this.addLabel(inner, `连击 ×${combo}`, 26, new Color(255, 146, 62), 0, -38, true);
        }

        inner.setScale(0.5, 0.5, 1);
        tween(inner)
            .to(0.16, { scale: v3(1.12, 1.12, 1) }, { easing: 'backOut' })
            .to(0.1, { scale: v3(1, 1, 1) })
            .start();
        tween(root).delay(0.2).by(0.75, { position: v3(0, 78, 0) }, { easing: 'quadOut' }).start();
        tween(op).delay(0.55).to(0.42, { opacity: 0 }).start();
        tween(root).delay(1.05).call(() => root.destroy()).start();
    }

    // ---------- 提示与吉祥物 ----------

    /**
     * 在给定的屏幕坐标上打一组呼吸光环（玩家发呆时指出一组可消的物件）。
     * 只画 2D 环、不碰 3D 物件本身，避免动到已冻结的刚体。
     */
    showHint(screenPositions: Vec3[]) {
        this.clearHint();
        if (screenPositions.length === 0) return;
        const root = new Node('hint');
        root.layer = Layers.Enum.UI_2D;
        root.setParent(this.gameLayer);
        this.hintRoot = root;
        for (const sp of screenPositions) {
            const n = new Node('ring');
            n.layer = Layers.Enum.UI_2D;
            n.setParent(root);
            n.setPosition(this.screenToContent(sp));
            const g = n.addComponent(Graphics);
            g.lineWidth = 6;
            g.strokeColor = new Color(255, 238, 150, 255);
            g.circle(0, 0, 36);
            g.stroke();
            const op = n.addComponent(UIOpacity);
            tween(n).repeat(3, tween(n)
                .set({ scale: v3(0.75, 0.75, 1) })
                .to(0.62, { scale: v3(1.3, 1.3, 1) }, { easing: 'quadOut' })).start();
            tween(op).repeat(3, tween(op)
                .set({ opacity: 255 })
                .to(0.62, { opacity: 0 })).start();
        }
        tween(root).delay(1.95).call(() => this.clearHint()).start();
    }

    clearHint() {
        if (this.hintRoot?.isValid) this.hintRoot.destroy();
        this.hintRoot = null;
    }

    /**
     * 冰封标记：每个冰封件头上盖一片雪花。
     *
     * 按 key 做**增量**维护而不是每次清空重建：这个方法每帧都被调用，
     * 重建会让雪花的呼吸动画每帧从头开始（看着是死的），节点churn 也白费。
     * 传入列表里没有的 key 即已解冻/已拿走，销毁对应节点。
     */
    setFrostMarks(marks: { key: string; screenPos: Vec3 }[]) {
        const alive = new Set<string>();
        for (const { key, screenPos } of marks) {
            alive.add(key);
            let n = this.frostMarks.get(key);
            if (!n || !n.isValid) {
                n = new Node('frostMark');
                n.layer = Layers.Enum.UI_2D;
                n.setParent(this.gameLayer);

                // 三层叠出层次：深色底 → 浅冰蓝主体 → 亮白芯。
                // 单层纯白线条在堆里是"一枚贴上去的图标"，压在浅色物件（橙子、香蕉）
                // 上还会糊掉；底层那圈深色描边是它在任何底色上都立得住的关键。
                const layers: [number, Color][] = [
                    [62, new Color(120, 200, 240, 62)],   // 光晕：把它从杂乱堆面上托起来
                    [50, new Color(16, 48, 70, 215)],     // 深底：任何底色上都立得住
                    [42, new Color(156, 218, 248, 255)],  // 主体
                    [27, new Color(255, 255, 255, 255)],  // 亮芯
                ];
                for (const [size, color] of layers) {
                    const g = new Node('layer');
                    g.layer = Layers.Enum.UI_2D;
                    g.setParent(n);
                    HudUI.drawGlyph(g.addComponent(Graphics), 'snowflake', size, color);
                }

                // 自转而不是缩放呼吸：雪花自转是这个符号天然的运动，读作"结着冰"；
                // 缩放脉动更像在提示"点我"，和它表达的"点不动"正好相反。
                // 转一圈 9 秒——快到能察觉，慢到不抢视线。
                tween(n).repeatForever(
                    tween(n).by(9, { angle: -360 })
                ).start();
                this.frostMarks.set(key, n);
            }
            // 就盖在物件正中。试过偏到左上角当徽章，但堆是密集的，偏移后那片雪花
            // 会压在**相邻**物件上，看不出到底冻的是哪一件——归属不清比挡一点更糟。
            // 而且遮挡本来就不是雪花的问题：它是线框、中间是空的，压在物件上照样
            // 看得见底下的颜色和形状（当初"物件被盖住"说的是 3D 那层实心冰壳）。
            n.setPosition(this.screenToContent(screenPos));
        }
        for (const [key, n] of this.frostMarks) {
            if (alive.has(key)) continue;
            if (n.isValid) n.destroy();
            this.frostMarks.delete(key);
        }
    }

    clearFrostMarks() {
        for (const [, n] of this.frostMarks) if (n.isValid) n.destroy();
        this.frostMarks.clear();
    }

    /** 冰层化开：在该处炸开一小簇雪屑。给"化开"一个看得见的瞬间，而不是悄悄消失。 */
    frostBreak(screenPos: Vec3) {
        const root = new Node('frostBreak');
        root.layer = Layers.Enum.UI_2D;
        root.setParent(this.gameLayer);
        root.setPosition(this.screenToContent(screenPos));
        for (let i = 0; i < 7; i++) {
            const a = (Math.PI * 2 * i) / 7 + Math.random() * 0.5;
            const dist = 26 + Math.random() * 22;
            const n = new Node('shard');
            n.layer = Layers.Enum.UI_2D;
            n.setParent(root);
            HudUI.drawGlyph(n.addComponent(Graphics), 'snowflake', 13 + Math.random() * 7,
                new Color(226, 246, 255, 255));
            const op = n.addComponent(UIOpacity);
            tween(n)
                .to(0.44, { position: v3(Math.cos(a) * dist, Math.sin(a) * dist - 10, 0) },
                    { easing: 'quadOut' })
                .start();
            tween(n).to(0.44, { angle: (Math.random() - 0.5) * 300 }).start();
            tween(op).to(0.44, { opacity: 0 }, { easing: 'quadIn' }).start();
        }
        tween(root).delay(0.5).call(() => root.isValid && root.destroy()).start();
    }

    /**
     * 拾到大鹅时在拾取点弹一句吉祥物台词。
     * 游戏叫《抓住大鹅》，鹅是吉祥物也是最稀有的目标，抓到它该有点动静。
     */
    speechPop(screenPos: Vec3, text: string) {
        const root = new Node('speech');
        root.layer = Layers.Enum.UI_2D;
        root.setParent(this.gameLayer);
        root.setPosition(this.screenToContent(screenPos));
        const op = root.addComponent(UIOpacity);

        const bubble = this.makePanelChild(root, 112, 56, 20, new Color(255, 250, 232), 0, 46,
            new Color(196, 130, 64), 4);
        this.addLabel(bubble, text, 30, new Color(232, 122, 24), 0, 0, true);

        bubble.setScale(0.2, 0.2, 1);
        tween(bubble)
            .to(0.18, { scale: v3(1.15, 1.15, 1) }, { easing: 'backOut' })
            .to(0.1, { scale: v3(1, 1, 1) })
            .start();
        tween(root).delay(0.3).by(0.6, { position: v3(0, 52, 0) }, { easing: 'quadOut' }).start();
        tween(op).delay(0.6).to(0.35, { opacity: 0 }).start();
        tween(root).delay(1.0).call(() => root.destroy()).start();
    }

    /**
     * 轻晃某个道具按钮（当前一组都凑不齐时指向「移出」）。
     * 只是抖一下，不弹窗打断操作。
     */
    nudgeProp(kind: PropKind) {
        if (!HudUI.SHOW_PROPS) return;
        const btn = this.propOpacity[kind]?.node;
        if (!btn?.isValid) return;
        Tween.stopAllByTarget(btn);
        btn.setScale(1, 1, 1);
        tween(btn).repeat(3, tween(btn)
            .to(0.16, { scale: v3(1.12, 1.12, 1) }, { easing: 'quadOut' })
            .to(0.16, { scale: v3(1, 1, 1) }, { easing: 'quadIn' })).start();
    }

    /** 进入/退出读秒紧张态：计时数字转红并让整块牌子呼吸。 */
    setTimeUrgent(on: boolean) {
        if (on === this.timerUrgent) return;
        this.timerUrgent = on;
        this.timerLabel.color = on ? new Color(255, 106, 86) : new Color(255, 220, 87);
        Tween.stopAllByTarget(this.timerPanel);
        this.timerPanel.setScale(1, 1, 1);
        if (!on) return;
        tween(this.timerPanel)
            .repeatForever(tween(this.timerPanel)
                .to(0.4, { scale: v3(1.1, 1.1, 1) }, { easing: 'sineOut' })
                .to(0.4, { scale: v3(1, 1, 1) }, { easing: 'sineIn' }))
            .start();
    }

    // ---------- 弹窗骨架 ----------

    /**
     * 模态弹窗骨架：铺满屏幕、吞掉触摸的遮罩 + 缩放淡入的根节点。
     * onMaskTap 传入时点遮罩空白处触发（用于可点外关闭的面板）；不传即纯吞触摸。
     */
    private makeModal(name: string, onMaskTap?: () => void): Node {
        const root = new Node(name);
        root.layer = Layers.Enum.UI_2D;
        root.setParent(this.gameLayer);

        const mask = new Node('mask');
        mask.layer = Layers.Enum.UI_2D;
        mask.setParent(root);
        mask.addComponent(UITransform).setContentSize(2400, 3200);
        const mg = mask.addComponent(Graphics);
        mg.fillColor = new Color(20, 12, 8, 165);
        mg.rect(-1200, -1600, 2400, 3200);
        mg.fill();
        mask.on(NodeEventType.TOUCH_END, () => onMaskTap?.());

        root.setScale(0.7, 0.7, 1);
        const op = root.addComponent(UIOpacity);
        op.opacity = 0;
        tween(root).to(0.26, { scale: v3(1, 1, 1) }, { easing: 'backOut' }).start();
        tween(op).to(0.2, { opacity: 255 }).start();
        return root;
    }

    /**
     * 关闭弹窗：缩小淡出后销毁，避免面板"啪"地消失。
     * 调用方在调用后立刻把自己那个引用置空——淡出中的旧节点不该再被当成当前面板。
     */
    private dismissModal(root: Node | null) {
        if (!root?.isValid) return;
        Tween.stopAllByTarget(root);
        const op = root.getComponent(UIOpacity);
        if (op) tween(op).to(0.13, { opacity: 0 }).start();
        tween(root)
            .to(0.14, { scale: v3(0.86, 0.86, 1) }, { easing: 'quadIn' })
            .call(() => root.destroy())
            .start();
    }

    /**
     * 弹窗里的卡通立体按钮：投影 + 立体面 + 按下压进投影。
     * 结构与 makeDockButton 一致（hit 定位 / face 承载视觉），只是这里用绝对坐标而非 Widget。
     */
    private makeButton(parent: Node, text: string, w: number, h: number, x: number, y: number,
        fill: Color, onTap: () => void, fontSize = 27): { node: Node; label: Label } {
        const sink = 6;
        const hit = new Node('btn');
        hit.layer = Layers.Enum.UI_2D;
        hit.setParent(parent);
        hit.setPosition(x, y, 0);
        hit.addComponent(UITransform).setContentSize(w, h);

        const shadow = new Node('shadow');
        shadow.layer = Layers.Enum.UI_2D;
        shadow.setParent(hit);
        shadow.setPosition(0, -sink - 2, 0);
        HudUI.paintShadow(shadow.addComponent(Graphics), w, h, 20, fill);

        const face = new Node('face');
        face.layer = Layers.Enum.UI_2D;
        face.setParent(hit);
        face.addComponent(UITransform).setContentSize(w, h);
        HudUI.paintFace(face.addComponent(Graphics), w, h, 20, fill);

        // 文字跟着面一起下沉，否则按下时字会浮在按钮上方。
        const label = this.addLabel(face, text, fontSize, HudUI.darken(fill, 0.68), 0, 0, true);
        label.outlineColor = HudUI.lighten(fill, 0.55);
        this.bindPress(hit, face, onTap, sink);
        return { node: hit, label };
    }

    /** 轻量通知弹窗(每日次数用尽等):标题 + 正文 + 单按钮。 */
    showTimeoutOffer(seconds: number, onWatch: () => void, onDecline: () => void) {
        this.hideResult();
        const root = this.makeModal('timeoutOffer');
        this.resultRoot = root;
        const panel = this.makePanelChild(root, 548, 390, 30, new Color(255, 244, 214), 0, 0,
            new Color(196, 130, 64), 6);
        this.addLabel(panel, '时间到了，再试一把？', 34, new Color(240, 150, 26), 0, 131, true);
        const body = this.addLabel(panel, `完整观看宣传片即可复活\n剩余时间增加 ${seconds} 秒`, 23,
            new Color(102, 57, 28), 0, 45, true);
        body.horizontalAlign = Label.HorizontalAlign.CENTER;
        this.makeButton(panel, `看宣传片 +${seconds} 秒`, 360, 76, 0, -60,
            new Color(126, 217, 87), onWatch, 27);
        this.makeButton(panel, '放弃复活', 260, 60, 0, -145,
            new Color(226, 208, 180), onDecline, 23);
    }

    showNotice(title: string, body: string, actionText: string, onAction: () => void) {
        this.hideResult();
        const root = this.makeModal('resultRoot');
        this.resultRoot = root;

        this.makePanelChild(root, 520, 340, 34, new Color(52, 27, 15, 235), 0, -8);
        const panel = this.makePanelChild(root, 508, 330, 30, new Color(255, 244, 214), 0, 0,
            new Color(196, 130, 64), 6);
        this.addLabel(panel, title, 40, new Color(240, 150, 26), 0, 96, true);
        const bodyLabel = this.addLabel(panel, body, 24, new Color(102, 57, 28), 0, 10, true);
        bodyLabel.horizontalAlign = Label.HorizontalAlign.CENTER;

        this.makeButton(panel, actionText, 258, 80, 0, -92, new Color(255, 207, 55), onAction, 28);
    }

    // ---------- 首页 / 暂停菜单 ----------

    /**
     * 开始页。整屏页面，由 {@link UIRouter} 承载——不再是盖在游玩场景上的弹窗。
     * 页面内容见 {@link HomeScreen}，这里只负责把它交给路由。
     */
    showHome(data: HomeData) {
        this.gameLayer.active = false;
        this.homeScreen = new HomeScreen(data);
        this.router.go(this.homeScreen);
    }

    /** 首页内切换地图：保留背景、标题和控制台，只换四站选中状态。 */
    selectHomeMap(id: string, bestText: string) {
        this.homeScreen?.selectMap(id, bestText);
    }

    /** 首页内切换难度：同样只更新控制台，不重建整页。 */
    selectHomeLevel(index: number, bestText: string) {
        this.homeScreen?.selectLevel(index, bestText);
    }

    /** 首次启动引导同样走整屏路由，完成后由 GameManager 决定进入哪一页。 */
    showOnboarding(data: OnboardingData) {
        this.gameLayer.active = false;
        this.homeScreen = null;
        this.router.go(new OnboardingScreen(data));
    }

    /** 收起当前页面，回到纯游玩视图。 */
    hideHome() {
        this.homeScreen = null;
        this.router.clear();
        this.gameLayer.active = true;
    }

    /** 暂停设置：继续 / 重开 / 声音 / GM / 退出本局。 */
    showPauseMenu(opts: {
        soundOn: boolean; gmOn: boolean; onResume: () => void; onRestart: () => void;
        onExit: () => void; onToggleSound: () => boolean; onToggleGM: () => boolean;
    }) {
        this.hidePauseMenu();
        const root = this.makeModal('pauseRoot', () => opts.onResume());
        this.pauseRoot = root;

        const W = 500, H = 610;
        this.makePanelChild(root, W + 12, H + 12, 34, new Color(52, 27, 15, 235), 0, -8);
        const panel = this.makePanelChild(root, W, H, 30, new Color(255, 244, 214), 0, 0,
            new Color(196, 130, 64), 6);
        this.addLabel(panel, '设 置', 46, new Color(240, 150, 26), 0, H / 2 - 58, true);

        // 这个开关同时管音效与 BGM，写「音效」会让人以为背景音乐另有开关
        const soundText = (on: boolean) => `声音  ${on ? '开' : '关'}`;
        this.makeButton(panel, '继续游戏', 320, 84, 0, 148, new Color(126, 217, 87), () => opts.onResume(), 30);
        this.makeButton(panel, '重开本关', 320, 76, 0, 54, new Color(255, 207, 55), () => opts.onRestart());
        const sound = this.makeButton(panel, soundText(opts.soundOn), 320, 72, 0, -39,
            new Color(226, 208, 180), () => {
                sound.label.string = soundText(opts.onToggleSound());
            }, 25);

        const gmRow = new Node('gmToggle');
        gmRow.layer = Layers.Enum.UI_2D;
        gmRow.setParent(panel);
        gmRow.setPosition(0, -132, 0);
        gmRow.addComponent(UITransform).setContentSize(350, 70);
        this.addLabel(gmRow, 'GM 模式', 26, new Color(102, 57, 28), -101, 0, true);
        const track = new Node('track');
        track.layer = Layers.Enum.UI_2D;
        track.setParent(gmRow);
        track.setPosition(115, 0, 0);
        track.addComponent(UITransform).setContentSize(92, 48);
        const toggleGraphic = track.addComponent(Graphics);
        let gmOn = opts.gmOn;
        const paintToggle = () => {
            toggleGraphic.clear();
            toggleGraphic.fillColor = gmOn ? new Color(57, 139, 100) : new Color(152, 155, 149);
            toggleGraphic.roundRect(-46, -24, 92, 48, 24);
            toggleGraphic.fill();
            toggleGraphic.fillColor = new Color(255, 250, 237);
            toggleGraphic.circle(gmOn ? 21 : -21, 0, 19);
            toggleGraphic.fill();
        };
        paintToggle();
        gmRow.on(NodeEventType.TOUCH_END, () => {
            gmOn = opts.onToggleGM();
            paintToggle();
        });

        this.makeButton(panel, '退出本局', 320, 72, 0, -221,
            new Color(228, 150, 118), () => opts.onExit(), 26);
    }

    hidePauseMenu() {
        this.dismissModal(this.pauseRoot);
        this.pauseRoot = null;
    }

    /**
     * 结算弹窗:遮罩 + 面板 + 三星逐颗弹出 + 行动按钮。
     * 星星用 Graphics 矢量五角星,未获得的显示为灰色底星。
     */
    showResult(opts: {
        win: boolean; stars: number; progress: number; score: number;
        rewardCount: number; actionText: string; onAction: () => void;
        subtitle?: string; bestText?: string; newRecord?: boolean;
        timeBonus?: number; rescueText?: string; onRescue?: () => void;
    }) {
        this.hideResult();
        // 遮罩吞掉触摸,防止点到底下的 3D 区或道具按钮。
        const root = this.makeModal('resultRoot');
        this.resultRoot = root;

        this.makePanelChild(root, 560, 500, 34, new Color(52, 27, 15, 235), 0, -10);
        const panel = this.makePanelChild(root, 548, 490, 30, new Color(255, 244, 214), 0, 0,
            new Color(196, 130, 64), 6);

        const titleColor = opts.win ? new Color(240, 150, 26) : new Color(112, 120, 132);
        this.addLabel(panel, opts.win ? '胜 利 !' : '差一点…', 52, titleColor, 0, 182, true);
        // 失败时把原因写清楚（槽位已满 / 时间到），玩家才知道下一局该改什么。
        if (opts.subtitle) {
            this.addLabel(panel, opts.subtitle, 20, new Color(150, 116, 78), 0, 140, true);
        }

        // 三颗星:底星常驻,获得的金星延迟逐颗弹出。
        for (let i = 0; i < 3; i++) {
            const x = (i - 1) * 108;
            const y = i === 1 ? 96 : 76;
            this.drawIcon(panel, 'star', 66, new Color(205, 198, 182), x, y);
            if (i < opts.stars) {
                const star = this.drawIcon(panel, 'star', 66, new Color(255, 201, 40), x, y);
                star.node.setScale(0, 0, 1);
                tween(star.node)
                    .delay(0.35 + i * 0.28)
                    .to(0.3, { scale: v3(1.25, 1.25, 1) }, { easing: 'backOut' })
                    .to(0.12, { scale: v3(1, 1, 1) })
                    .start();
            }
        }

        // 成绩区逐行下排：胜利局的完成度必然是 100%，写出来纯属占位，
        // 把那一行让给「时间奖励」这类真正有信息量的内容。
        let y = opts.win ? 16 : 8;
        if (!opts.win) {
            this.addLabel(panel, `完成度 ${opts.progress}%`, 28, new Color(102, 57, 28), 0, y, true);
            y -= 42;
        }
        // 得分是本局的主成绩,字号压过完成度,并做一次数字滚动强调。
        const scoreShown = this.addLabel(panel, '得分 0', 36, new Color(240, 150, 26), 0, y, true);
        this.countUpScore(scoreShown, opts.score);
        y -= 42;
        if (opts.timeBonus) {
            this.addLabel(panel, `含时间奖励 +${opts.timeBonus}`, 21, new Color(214, 106, 48), 0, y, true);
            y -= 32;
        }
        if (opts.rewardCount > 0) {
            this.addLabel(panel, `获得 ${opts.rewardCount} 件道具奖励`, 23, new Color(52, 148, 68), 0, y, true);
            y -= 30;
        }
        if (opts.bestText) {
            this.addLabel(panel, opts.bestText, 20, new Color(158, 122, 82), 0, y, true);
        }
        if (opts.newRecord) {
            // 斜贴在星星右上角的"新纪录"角标。
            const badge = this.addLabel(panel, '新纪录!', 26, new Color(255, 82, 62), 168, 122, true);
            badge.node.setRotationFromEuler(0, 0, -14);
            badge.node.setScale(0, 0, 1);
            tween(badge.node)
                .delay(1.2)
                .to(0.24, { scale: v3(1.2, 1.2, 1) }, { easing: 'backOut' })
                .to(0.1, { scale: v3(1, 1, 1) })
                .start();
        }

        // 成绩文字最低到 y=-112；按钮顶边 -132 起，保留呼吸区，
        // 阴影底边距弹窗底部 29px，不会被面板裁切。
        if (opts.rescueText && opts.onRescue) {
            // 救场是主行动(绿),重试退居右侧。
            this.makeButton(panel, opts.rescueText, 246, 80, -128, -172, new Color(126, 217, 87), opts.onRescue);
            this.makeButton(panel, opts.actionText, 230, 80, 128, -172, new Color(255, 207, 55), opts.onAction);
        } else {
            this.makeButton(panel, opts.actionText, 258, 80, 0, -172, new Color(255, 207, 55), opts.onAction);
        }
    }

    /** 结算得分滚动:从 0 跳到最终分,让「这局打了多少」有个被读出来的过程。 */
    private countUpScore(label: Label, target: number) {
        if (target <= 0) { label.string = '得分 0'; return; }
        const steps = 18;
        for (let i = 1; i <= steps; i++) {
            tween(label.node)
                .delay(0.3 + i * 0.035)
                .call(() => {
                    if (!label.node.isValid) return;
                    label.string = `得分 ${Math.round(target * (i / steps))}`;
                })
                .start();
        }
    }

    hideResult() {
        this.dismissModal(this.resultRoot);
        this.resultRoot = null;
    }

    sync() {
        const s = view.getVisibleSize();
        if (s.width <= 0 || s.height <= 0) return;
        // HUD 使用 720x1280 安全画布。竖屏仍按宽度适配；横屏额外受高度约束，
        // 避免收集槽和道具栏占满半屏、遮住需要观察和点击的 3D 物件堆。
        const nextScale = Math.min(1, s.width / 720, s.height / 1280);
        let resized = false;
        if (Math.abs(this.canvasUT.height - s.height) > 0.5 || Math.abs(this.canvasUT.width - s.width) > 0.5) {
            this.canvasUT.setContentSize(s.width, s.height);
            resized = true;
        }
        if (Math.abs(this.uiCam.orthoHeight - s.height / 2) > 0.5) {
            this.uiCam.orthoHeight = s.height / 2;
        }
        if (Math.abs(this.uiScale - nextScale) > 0.001) {
            this.uiScale = nextScale;
            this.contentRoot.setScale(nextScale, nextScale, 1);
            resized = true;
        }
        // 横屏只缩放并居中完整的竖版操作带，不把左右 Widget 推到屏幕边缘。
        // 侧边空间保留为背景，核心信息、槽位和道具始终围绕 3D 木盒分布。
        const contentW = 720;
        const contentH = s.height / this.uiScale;
        if (Math.abs(this.contentUT.width - contentW) > 0.5 || Math.abs(this.contentUT.height - contentH) > 0.5) {
            this.contentUT.setContentSize(contentW, contentH);
            resized = true;
        }
        // 整屏页面按 720 宽的设计稿独立适配：宽度最多放大到原稿尺寸，超宽屏居中留空；
        // 高度不足时保持宽度比例并从顶部开始渲染，只允许底部自然裁切，避免后续内容露到两侧。
        const frame = view.getFrameSize();
        // 页面至少保留 1100 个美术像素的可用高度。竖屏仍由宽度决定；横屏/超宽屏则
        // 适当缩小整列并居中，左右留背景，避免固定头尾把中间地图挤成一条缝。
        const pageScaleInFrame = Math.min(1, frame.width / 720, frame.height / 1100);
        // FIXED_WIDTH 会让逻辑坐标宽度恒为 390；先还原 contentRoot 在浏览器里的实际比例，
        // 再反算页面层缩放，才能把“最大 720px”落实到真实窗口，而不是逻辑画布。
        const contentScaleInFrame = (frame.width / s.width) * this.uiScale;
        const nextScreenScale = pageScaleInFrame / contentScaleInFrame;
        const nextScreenOffsetY = contentH / 2 - nextScreenScale * this.router.activeArtTop;
        if (Math.abs(this.screenScale - nextScreenScale) > 0.001) {
            this.screenScale = nextScreenScale;
            this.screenLayer.setScale(nextScreenScale, nextScreenScale, 1);
            resized = true;
        }
        if (Math.abs(this.screenOffsetY - nextScreenOffsetY) > 0.5) {
            this.screenOffsetY = nextScreenOffsetY;
            this.screenLayer.setPosition(0, nextScreenOffsetY, 0);
            resized = true;
        }
        // 把页面在 720 美术坐标中的真实可视底边交给活动页。首页会固定完整控制台并
        // 将剩余空间用作地图裁切视口，不再额外覆盖一枚“短屏按钮”。
        const visibleBottomY = this.router.activeArtTop - frame.height / pageScaleInFrame;
        this.router.layoutVisibleArea(visibleBottomY);
        if (resized) {
            // Cocos Web 的降级编译不会正确展开 Map spread，使用 forEach 避免被转成 [].concat(map)。
            this.capturedModels.forEach((index, node) => {
                if (!node.isValid) this.capturedModels.delete(node);
                else {
                    const icon = this.capturedIcons.get(node);
                    if (icon?.isValid) icon.setPosition(this.slotIconPosition(index));
                }
            });
        }
    }

    /** 把 3D 模型的真实渲染缩略图飞入固定 2D 槽，避免手机多相机合成差异。 */
    captureModel(node: Node, screenPos: Vec3, index: number) {
        const iconNode = new Node(`tray-${node.name}`);
        iconNode.layer = Layers.Enum.UI_2D;
        iconNode.setParent(this.gameLayer);
        iconNode.addComponent(UITransform).setContentSize(78, 64);

        // Sprite 放在独立子节点上：父节点始终是槽位中心，子节点只负责修正素材透明边距。
        const visualNode = new Node('visual');
        visualNode.layer = Layers.Enum.UI_2D;
        visualNode.setParent(iconNode);
        const visualUT = visualNode.addComponent(UITransform);
        const sprite = visualNode.addComponent(Sprite);
        sprite.sizeMode = Sprite.SizeMode.CUSTOM;
        iconNode.setPosition(this.screenToContent(screenPos));
        iconNode.setScale(0.18, 0.18, 1);
        resources.load(`icons/${node.name}/texture`, Texture2D, (err, texture) => {
            if (!err && texture && iconNode.isValid) {
                const frame = new SpriteFrame();
                frame.texture = texture;
                sprite.spriteFrame = frame;

                const layout = TRAY_ICON_LAYOUT[node.name]
                    ?? { offsetX: 0, offsetY: 0, contentW: 150, contentH: 150 };
                // 每件物品的非透明内容等比装进 62×52 的安全区，避免宽扁模型或高模型碰到槽边。
                const fit = Math.min(62 / layout.contentW, 52 / layout.contentH);
                visualUT.setContentSize(texture.width * fit, texture.height * fit);
                visualNode.setPosition(-layout.offsetX * fit, layout.offsetY * fit, 0);
            }
        });
        node.active = false;
        this.capturedModels.set(node, index);
        this.capturedIcons.set(node, iconNode);
        tween(iconNode)
            .to(0.32, {
                position: this.slotIconPosition(index),
                scale: v3(1, 1, 1),
            }, { easing: 'quadOut' })
            .start();
    }

    moveModelToSlot(node: Node, index: number) {
        const icon = this.capturedIcons.get(node);
        if (!node.isValid || !icon?.isValid) return;
        this.capturedModels.set(node, index);
        tween(icon).to(0.22, { position: this.slotIconPosition(index) }, { easing: 'quadOut' }).start();
    }

    releaseModel(node: Node) {
        this.capturedModels.delete(node);
        const icon = this.capturedIcons.get(node);
        this.capturedIcons.delete(node);
        if (icon?.isValid) {
            Tween.stopAllByTarget(icon);
            tween(icon).to(0.14, { scale: v3(0.08, 0.08, 1) }, { easing: 'backIn' })
                .call(() => icon.destroy()).start();
        }
    }

    clearCapturedModels() {
        this.capturedModels.clear();
        for (const icon of this.capturedIcons.values()) if (icon.isValid) icon.destroy();
        this.capturedIcons.clear();
    }

    private slotIconPosition(index: number): Vec3 {
        // 槽位面板的 Widget 挂在固定 720×1280 的 gameLayer 上，图标也是它的子节点；
        // 这里过去误用会随设备纵横比变化的 contentRoot 高度，短屏时两套坐标系相差
        // 约 140 个美术像素，拾取图标就被推到下方“移出”按钮上。必须用共同父层高度。
        const gameHeight = this.gameLayer.getComponent(UITransform)?.height ?? 1280;
        return v3(
            (index - 3) * HudUI.SLOT_STEP,
            -gameHeight / 2 + HudUI.TRAY_CENTER_Y,
            1,
        );
    }

    setProgress(pct: number) {
        this.progressLabel.string = `${pct}%`;
        this.progressFill.node.setScale(Math.max(0, Math.min(1, pct / 100)), 1);
    }

    /** 5/6/7 格逐级增强橙红边缘，并在每次进入危险状态时轻微脉冲一次。 */
    setTrayCount(count: number) {
        const danger = Math.max(0, Math.min(3, count - 4));
        this.trayDangerOpacity.opacity = [0, 95, 175, 235][danger];
        Tween.stopAllByTarget(this.trayDangerGlow);
        this.trayDangerGlow.setScale(1, 1, 1);
        if (danger > 0) {
            tween(this.trayDangerGlow)
                .to(0.11, { scale: v3(1.025, 1.08, 1) }, { easing: 'quadOut' })
                .to(0.18, { scale: v3(1, 1, 1) }, { easing: 'sineOut' })
                .start();
        }
    }

    setPropCount(kind: PropKind, _text: string, count: number, unlimited = false) {
        if (!HudUI.SHOW_PROPS) return;
        const usable = unlimited || count > 0;
        // 普通模式显示库存；GM 模式用无限标记且保留道具键可用态。
        this.propBadge[kind].string = unlimited ? '∞' : `${count}`;
        this.propBadge[kind].color = usable ? new Color(255, 252, 246) : new Color(186, 176, 168);
        this.propOpacity[kind].opacity = usable ? 255 : 120;
    }

    setPaused(paused: boolean) {
        HudUI.drawGlyph(this.pauseIcon, paused ? 'play' : 'pause', 33, new Color(255, 247, 218));
    }

    /** 同步声音键图标。暂停菜单里的开关也会改状态，两处必须一起刷。 */
    setSoundOn(on: boolean) {
        if (!this.soundIcon) return;
        HudUI.drawGlyph(this.soundIcon, on ? 'sound-on' : 'sound-off', 33, new Color(255, 247, 218));
    }

    // ---------- 卡通立体按钮 ----------

    private static readonly WHITE = new Color(255, 255, 255);
    private static readonly BLACK = new Color(0, 0, 0);
    /** 打光用的两个偏色端：暖白（受光）与红棕（背光）。 */
    private static readonly SUN = new Color(255, 246, 214);
    private static readonly SHADE = new Color(86, 38, 20);

    /** 两色插值。按钮的高光/暗部/描边全部由基色推出，保证一颗按钮的各层同源不脏。 */
    private static mix(a: Color, b: Color, t: number): Color {
        return new Color(
            Math.round(a.r + (b.r - a.r) * t),
            Math.round(a.g + (b.g - a.g) * t),
            Math.round(a.b + (b.b - a.b) * t),
            a.a,
        );
    }

    private static lighten(c: Color, t: number): Color { return HudUI.mix(c, HudUI.WHITE, t); }
    private static darken(c: Color, t: number): Color { return HudUI.mix(c, HudUI.BLACK, t); }
    /** 变暖/变冷：受光面偏黄、背光面偏红棕，比单纯加白减黑更像被暖光照着的实物。 */
    private static warm(c: Color, t: number): Color { return HudUI.mix(c, HudUI.SUN, t); }
    private static cool(c: Color, t: number): Color { return HudUI.mix(c, HudUI.SHADE, t); }

    /**
     * 圆角矩形在高度 y 处的水平内缩量。用来把渐变条带裁进圆角轮廓里——
     * Graphics 没有裁剪区，只能逐条带自己算该行有多宽。
     */
    private static roundInset(y: number, hh: number, r: number): number {
        const d = Math.abs(y) - (hh - r);
        if (d <= 0) return 0;
        return r - Math.sqrt(Math.max(0, r * r - d * d));
    }

    /**
     * 竖向渐变填充。Graphics 没有渐变 API，这里按行切成若干条带逐条上色，
     * 条带宽度按圆角轮廓收缩，所以渐变不会溢出圆角。
     *
     * 底层先铺一整块 roundRect 保证外轮廓干净（条带边缘是逐行阶梯，靠得太近会毛），
     * 条带再整体内缩半像素叠上去。
     */
    private static fillVGradient(g: Graphics, w: number, h: number, r: number,
        top: Color, bottom: Color, steps?: number, cx = 0, cy = 0) {
        const hw = w / 2, hh = h / 2;
        g.fillColor = bottom;
        g.roundRect(cx - hw, cy - hh, w, h, r);
        g.fill();

        const n = steps ?? Math.max(10, Math.min(48, Math.round(h / 2)));
        const dy = h / n;
        for (let i = 0; i < n; i++) {
            const yTop = hh - i * dy, yBot = yTop - dy;
            // 取上下沿里更靠外的那条算内缩，条带才不会探出圆角
            const inset = Math.max(HudUI.roundInset(yTop, hh, r), HudUI.roundInset(yBot, hh, r)) + 0.5;
            const bw = w - inset * 2;
            if (bw <= 0) continue;
            g.fillColor = HudUI.mix(top, bottom, i / (n - 1));
            // 条带间多画半像素，消掉相邻条带之间的接缝
            g.rect(cx - hw + inset, cy + yBot - 0.5, bw, dy + 1);
            g.fill();
        }
    }

    /**
     * 沿圆角矩形轮廓铺一段折线路径（只铺路径，不 fill/stroke）。
     * side='top' 走「左上圆角 → 顶边 → 右上圆角」，'bottom' 走下沿对应的一段。
     *
     * 用折线而不是 Graphics.arc：arc 的 counterclockwise 语义是照 canvas 的 y 轴向下定的，
     * 搬到 y 轴向上的 UI 坐标里方向正好相反，两段 90° 弧逐点走反而不会画错边。
     */
    private static edgePath(g: Graphics, w: number, h: number, r: number, side: 'top' | 'bottom') {
        const hw = w / 2, hh = h / 2;
        const sy = side === 'top' ? 1 : -1;
        const a0 = Math.PI;
        const a1 = side === 'top' ? Math.PI / 2 : Math.PI * 1.5;
        const a2 = side === 'top' ? 0 : Math.PI * 2;
        const seg = 8;
        let started = false;
        const walk = (cx: number, from: number, to: number) => {
            for (let i = 0; i <= seg; i++) {
                const a = from + (to - from) * (i / seg);
                const x = cx + r * Math.cos(a);
                const y = sy * (hh - r) + r * Math.sin(a);
                if (!started) { g.moveTo(x, y); started = true; } else { g.lineTo(x, y); }
            }
        };
        walk(-hw + r, a0, a1);   // 左圆角
        walk(hw - r, a1, a2);    // 顺带把横边连上，再走右圆角
    }

    /**
     * 按钮落在台面上的软投影：一层实心 + 几层往外扩的淡边。
     *
     * 单块硬边纯色 roundRect 读作「同一张贴纸的重影」，怎么调面都救不回来立体感；
     * 边缘一化开，按钮才算真正压在台面上。
     */
    private static paintShadow(g: Graphics, w: number, h: number, r: number, fill: Color) {
        const c = HudUI.cool(HudUI.darken(fill, 0.68), 0.22);
        for (let i = 3; i >= 0; i--) {
            const sp = i * 1.8;
            g.fillColor = new Color(c.r, c.g, c.b, i === 0 ? 225 : 42);
            g.roundRect(-w / 2 - sp, -h / 2 - sp, w + sp * 2, h + sp * 2, r + sp);
            g.fill();
        }
    }

    /**
     * 画一张卡通立体按钮面。从下往上：
     * 竖向渐变的面 → 底部内阴影（面自身的厚度）→ 釉光 → 上沿亮线 + 下沿回光 → 一圈描边。
     *
     * 早先的版本是三块同源纯色硬叠，色阶断在两条水平线上，远看就是贴纸。
     * 现在渐变由 fillVGradient 逐行铺，受光端往暖白偏、背光端往红棕偏
     * （而不是简单加白减黑），糖果塑料的通透感基本来自这一步。
     */
    private static paintFace(g: Graphics, w: number, h: number, r: number, fill: Color,
        gloss = 1, edge?: Color) {
        g.clear();
        const hw = w / 2, hh = h / 2;

        // 1) 面：顶端受光偏暖白，底端背光偏红棕。
        //    渐变幅度跟 gloss 走：深墨面上 lighten 0.30 会把顶部提到灰绿(约 98,103,99)，
        //    整枚键读作"塑料灰"而不是墨玉。gloss 低时几乎平涂，只留一点点受光暗示。
        HudUI.fillVGradient(g, w, h, r,
            HudUI.warm(HudUI.lighten(fill, 0.06 + 0.24 * gloss), 0.22 * gloss),
            HudUI.cool(HudUI.darken(fill, 0.16), 0.18));

        // 2) 底部内阴影：面自己的厚度落在下沿。做窄做浅——道具键的文字压在这一带上，
        //    暗带一厚字就糊。
        //    做成 alpha 往上渐隐的暗雾，而不是一条实色带——实色带有明确上边界，
        //    在下沿看着像嵌了个小托盘。结构与下面的釉光对称，只是方向相反。
        const shadeH = Math.max(4, h * 0.18);
        const shadeC = HudUI.cool(HudUI.darken(fill, 0.42), 0.35);
        const sn = Math.max(8, Math.round(shadeH / 2));
        for (let i = 0; i < sn; i++) {
            const t = i / (sn - 1);                       // 0 = 贴着下沿
            const yBot = -hh + (shadeH * i) / sn;
            const yTop = yBot + shadeH / sn;
            const inset = Math.max(HudUI.roundInset(yTop, hh, r),
                HudUI.roundInset(yBot, hh, r)) + 1;
            const bw = w - inset * 2;
            if (bw <= 0) continue;
            g.fillColor = new Color(shadeC.r, shadeC.g, shadeC.b,
                Math.round(150 * (1 - t) * (1 - t)));
            g.rect(-w / 2 + inset, yBot - 0.5, bw, shadeH / sn + 1);
            g.fill();
        }

        // 3) 釉光：上半部一枚圆角胶囊，由外到内逐层缩小、逐层叠亮，边缘因此是化开的。
        //    上一版把它按行切成等宽横条，中段 alpha 还有四成却全宽平铺，
        //    左右各留下一条笔直的竖界——那两条直边就是「贴纸」的来源。
        //    内层同时往上顶一点，亮心才落在上沿附近而不是正中。
        //    宽高比要按面自己的比例给：早先写成「宽度减两个圆角」，
        //    66×66 的方键上只剩 20 宽 25 高，成了一枚竖着的蛋。
        const glossW = w * 0.74;
        const glossH = Math.min(h * 0.34, glossW * 0.52);
        const glossCY = hh - Math.max(3.5, r * 0.3) - glossH / 2;
        const gTop = HudUI.warm(HudUI.lighten(fill, 0.72), 0.34);
        // 层数少了每层的 alpha 台阶就看得见，釉光上会浮出一圈圈同心的圆角轮廓，
        // 像等高线；层薄一点多几层才化得开。
        const layers = 11;
        for (let i = 0; i < layers; i++) {
            const k = 1 - i * 0.072;
            const bw = glossW * k, bh = glossH * k;
            if (bw <= 0 || bh <= 0) continue;
            g.fillColor = new Color(gTop.r, gTop.g, gTop.b, Math.round(17 * gloss));
            g.roundRect(-bw / 2, glossCY - bh / 2 + (glossH - bh) * 0.42, bw, bh,
                Math.min(bh / 2, r));
            g.fill();
        }

        // 4) 上沿亮线 + 下沿回光。两条都只走圆角轮廓的一段，不绕圈——
        //    绕成一圈就是「回」字白边。下沿这条是台面反弹回来的光，压在内阴影之上，
        //    强度只有上沿的一半，缺了它下边缘会直接黑到描边上，像被切掉一刀。
        const rimIn = Math.max(2.5, Math.min(w, h) * 0.055);
        g.lineWidth = Math.max(1.6, Math.min(w, h) * 0.028);
        // 亮线强度同样跟 gloss 走：在深墨面上 lighten 0.85 是一道**灰白**线，
        // 它压在外圈金边的左上段上，把"镶金"那一圈直接盖断（放大截图可见）。
        const rimTop = HudUI.warm(HudUI.lighten(fill, 0.85), 0.3);
        g.strokeColor = new Color(rimTop.r, rimTop.g, rimTop.b, Math.round(195 * gloss));
        HudUI.edgePath(g, w - rimIn * 2, h - rimIn * 2, Math.max(1, r - rimIn), 'top');
        g.stroke();
        const rimBot = HudUI.warm(HudUI.lighten(fill, 0.4), 0.5);
        g.strokeColor = new Color(rimBot.r, rimBot.g, rimBot.b, Math.round(95 * gloss));
        HudUI.edgePath(g, w - rimIn * 2, h - rimIn * 2, Math.max(1, r - rimIn), 'bottom');
        g.stroke();

        // 5) 外描边：默认是偏红棕的一圈轮廓（卡通风压边）。
        //    传 edge 则改画一道细金线——深木面配暗棕边时按钮边界糊在台面里，
        //    "镶金木牌"这个观感全靠这条线立起来，所以它要细（1.8px）而不是粗描边。
        if (edge) {
            // 2.6px：1.8 在 dpr2 上被抗锯齿吃掉大半，远看那圈金线就没了。
            // 先压一道暗底边再叠金线，金色才不会直接虚在背景上（双层描边）。
            g.lineWidth = 2.6;
            g.strokeColor = new Color(10, 13, 11, 190);
            g.roundRect(-hw + 0.6, -hh + 0.6, w - 1.2, h - 1.2, r);
            g.stroke();
            g.lineWidth = 2.2;
            g.strokeColor = edge;
            g.roundRect(-hw + 1.5, -hh + 1.5, w - 3, h - 3, Math.max(1, r - 1));
            g.stroke();
        } else {
            g.lineWidth = Math.max(2.6, Math.min(w, h) * 0.048);
            g.strokeColor = HudUI.cool(HudUI.darken(fill, 0.52), 0.28);
            g.roundRect(-hw, -hh, w, h, r);
            g.stroke();
        }
    }

    /**
     * 按下反馈：按钮面往自己的投影里压下去，松手弹回。
     * 只缩放的话手感像“图片被捏了一下”；位移 + 缩放才读得出“按进去了”。
     * face 必须是不受 Widget 摆布的节点（Widget 每帧改写位置，位移会被顶掉）。
     */
    private bindPress(hit: Node, face: Node, onTap: () => void, sink: number) {
        const restore = () => {
            Tween.stopAllByTarget(face);
            tween(face)
                .to(0.12, { position: v3(0, 0, 0), scale: v3(1, 1, 1) }, { easing: 'backOut' })
                .start();
        };
        hit.on(NodeEventType.TOUCH_START, () => {
            Tween.stopAllByTarget(face);
            tween(face).to(0.06, { position: v3(0, -sink, 0), scale: v3(0.97, 0.97, 1) }).start();
        });
        hit.on(NodeEventType.TOUCH_END, () => { restore(); onTap(); });
        hit.on(NodeEventType.TOUCH_CANCEL, restore);
    }

    /**
     * 屏幕上固定位置的立体按钮（道具栏、左上角功能键）。
     * 外层只做 Widget 定位与触摸命中，内层 face 承载可动的按钮面 —— 分层是必须的，
     * 因为 Widget 的 ALWAYS 模式每帧重写外层位置，直接对外层做位移动画会被抹掉。
     * 返回 face 供调用方挂图标、文字与角标。
     */
    private makeDockButton(w: number, h: number, r: number, fill: Color,
        align: { top?: number; bottom?: number; centerY?: number }, halign: HorizontalAlign,
        onTap: () => void, sink = 5, gloss = 1, edge?: Color): { hit: Node; face: Node } {
        const hit = this.makePanel(w, h, r, new Color(0, 0, 0, 0), align, 0, undefined, 0, halign);

        // 投影不跟着按：它是按钮落在台面上的影子，面压下去时影子才显得是“陷进去”。
        const shadow = new Node('shadow');
        shadow.layer = Layers.Enum.UI_2D;
        shadow.setParent(hit);
        shadow.setPosition(0, -sink - 2, 0);
        HudUI.paintShadow(shadow.addComponent(Graphics), w, h, r, fill);

        const face = new Node('face');
        face.layer = Layers.Enum.UI_2D;
        face.setParent(hit);
        face.addComponent(UITransform).setContentSize(w, h);
        HudUI.paintFace(face.addComponent(Graphics), w, h, r, fill, gloss, edge);

        this.bindPress(hit, face, onTap, sink);
        return { hit, face };
    }

    private makePanel(w: number, h: number, r: number, fill: Color,
        align: { top?: number; bottom?: number; centerY?: number }, offsetX: number,
        stroke?: Color, strokeW = 0, halign?: HorizontalAlign): Node {
        const n = new Node('panel');
        n.layer = Layers.Enum.UI_2D;
        n.setParent(this.gameLayer);
        n.addComponent(UITransform).setContentSize(w, h);
        const g = n.addComponent(Graphics);
        HudUI.paintPanel(g, w, h, r, fill, stroke, strokeW);
        const wd = n.addComponent(Widget);
        wd.alignMode = Widget.AlignMode.ALWAYS;
        if (halign?.left !== undefined) { wd.isAlignLeft = true; wd.left = halign.left; }
        else if (halign?.right !== undefined) { wd.isAlignRight = true; wd.right = halign.right; }
        else { wd.isAlignHorizontalCenter = true; wd.horizontalCenter = offsetX; }
        if (align.top !== undefined) { wd.isAlignTop = true; wd.top = align.top; }
        else if (align.bottom !== undefined) { wd.isAlignBottom = true; wd.bottom = align.bottom; }
        else { wd.isAlignVerticalCenter = true; wd.verticalCenter = align.centerY ?? 0; }
        return n;
    }

    private makePanelChild(parent: Node, w: number, h: number, r: number, fill: Color,
        x: number, y: number, stroke?: Color, strokeW = 0): Node {
        const n = new Node('sub');
        n.layer = Layers.Enum.UI_2D;
        n.setParent(parent);
        n.addComponent(UITransform).setContentSize(w, h);
        n.setPosition(x, y, 0);
        HudUI.paintPanel(n.addComponent(Graphics), w, h, r, fill, stroke, strokeW);
        return n;
    }

    /**
     * 面板底：一层很浅的竖向渐变 + 上沿一道更亮的窄边。
     *
     * 按钮走 paintFace（强立体），面板只要「有厚度但不抢戏」——计时牌、进度槽、
     * 收集槽、桃木台面都过这里，做重了整个 HUD 会全是反光。
     * 全透明的 fill（dock 按钮的命中层用）直接跳过，别画出个看得见的框。
     */
    private static paintPanel(g: Graphics, w: number, h: number, r: number, fill: Color,
        stroke?: Color, strokeW = 0) {
        if (fill.a > 0) {
            // 条带之间要压半像素才不留缝，可底色一透明，压住的那半像素就叠了两遍，
            // 于是每条带边界都多出一道更实的横线——大面积半透明托板上一眼就是脏条纹。
            // 这类板子本来就只是垫底，直接铺平色。
            if (fill.a < 190) {
                g.fillColor = fill;
                g.roundRect(-w / 2, -h / 2, w, h, r);
                g.fill();
            } else {
                HudUI.fillVGradient(g, w, h, r,
                    HudUI.warm(HudUI.lighten(fill, 0.13), 0.10),
                    HudUI.cool(HudUI.darken(fill, 0.11), 0.10));
            }
            // 上沿高光：细条（进度条、连击条）加了显脏，整块大面板加了像贴了条胶带，
            // 都跳过。强度还要随底色变亮而衰减——深色牌子上那道亮边是质感，
            // 浅色底上同样一道就只是一片灰。
            const luma = (fill.r * 0.299 + fill.g * 0.587 + fill.b * 0.114) / 255;
            const k = Math.max(0, 0.62 - luma * 0.62);
            if (h >= 26 && h <= 150 && k > 0.05) {
                // 往金边色混一半、alpha 再打六折。
                // 原先是纯 lighten(fill) 的灰白条：墨绿底 luma 只有 0.14，k 算出来 0.53、
                // alpha 到 136，在收集槽托盘上沿糊出一道很实的灰白胶带（而设计稿那里
                // 只有金边）。混进金色后它与金边同色系，读作沿口的一道淡金反光。
                const base = HudUI.warm(HudUI.lighten(fill, 0.34), 0.2);
                const hi = HudUI.mix(base, HudUI.GOLD_EDGE, 0.45);
                g.fillColor = new Color(hi.r, hi.g, hi.b, Math.round(fill.a * k * 0.6));
                const inset = Math.max(2, r * 0.3);
                g.roundRect(-w / 2 + inset, h / 2 - Math.max(2, h * 0.09) - 2,
                    w - inset * 2, Math.max(2, h * 0.09), Math.max(1, r * 0.25));
                g.fill();
            }
        }
        if (stroke && strokeW > 0) {
            g.lineWidth = strokeW;
            g.strokeColor = stroke;
            g.roundRect(-w / 2, -h / 2, w, h, r);
            g.stroke();
        }
    }

    /**
     * 道具角标圆牌：同心圆逐层缩小上移，做出球面受光，外面套一圈奶白环 + 一圈暗边。
     *
     * 不能走 paintPanel——那套渐变是逐行横条带，铺到直径 38 的圆上，
     * 每条带的两端都停在自己那一行的圆弧上，边缘就成了一圈锯齿花边；
     * 顶部那道高光又是按矩形宽度画的，在圆的上沿左右各探出一只小尖角。
     */
    private static paintBadge(g: Graphics, r: number, fill: Color, ring: Color) {
        const dark = HudUI.darken(fill, 0.14);
        const lit = HudUI.warm(HudUI.lighten(fill, 0.5), 0.25);
        const n = 14;
        for (let i = 0; i < n; i++) {
            const t = i / (n - 1);
            // 半径线性收，颜色要到很靠里才亮起来。均匀插值时整枚牌被提亮成灰粉色，
            // 比原来那块纯色还闷——高光只该占顶上一小点，其余留在本色附近。
            g.fillColor = HudUI.mix(dark, lit, Math.pow(t, 2.4));
            g.circle(0, r * 0.34 * t, r * (1 - t * 0.88));
            g.fill();
        }
        g.lineWidth = Math.max(2.5, r * 0.2);
        g.strokeColor = ring;
        g.circle(0, 0, r - g.lineWidth / 2);
        g.stroke();
        // 外侧一圈暗边：奶白环直接压在金黄面上时两者明度太近，角标会糊进按钮里
        g.lineWidth = 2;
        const edge = HudUI.cool(HudUI.darken(fill, 0.5), 0.25);
        g.strokeColor = new Color(edge.r, edge.g, edge.b, 170);
        g.circle(0, 0, r);
        g.stroke();
    }

    /**
     * 槽内柔光：叠加数层半透明暖白圆，中心最亮向边缘衰减，模拟顶部聚光。
     * 光斑略偏上，物品图标随后置于其上，靠对比把偏暗的模型缩略图“提亮”。
     */
    private addSlotLight(slot: Node): void {
        const n = new Node('slotLight');
        n.layer = Layers.Enum.UI_2D;
        n.setParent(slot);
        n.setPosition(0, 5, 0);
        const g = n.addComponent(Graphics);
        // 极淡的冷白，且只有两层：暖金光在墨绿槽上会显出一圈圈同心的灰绿轮廓
        // （读作脏污/霉点），而槽里马上要放物件缩略图，柔光只需垫一点点。
        for (const [r, a] of [[30, 13], [18, 13]] as const) {
            g.fillColor = new Color(206, 214, 206, a);
            g.circle(0, 0, r);
            g.fill();
        }
    }

    private addLabel(parent: Node, text: string, size: number, color: Color,
        x = 0, y = 0, outline = false): Label {
        const n = new Node('lbl');
        n.layer = Layers.Enum.UI_2D;
        n.setParent(parent);
        n.setPosition(x, y, 0);
        const l = n.addComponent(Label);
        l.string = text;
        l.fontSize = size;
        l.lineHeight = size * 1.2;
        l.color = color;
        if (outline) {
            l.enableOutline = true;
            l.outlineColor = new Color(83, 47, 27, 230);
            l.outlineWidth = Math.max(1, Math.round(size * 0.06));
        }
        return l;
    }

    private drawIcon(parent: Node, kind: IconKind, size: number, color: Color, x = 0, y = 0): Graphics {
        const n = new Node('icon');
        n.layer = Layers.Enum.UI_2D;
        n.setParent(parent);
        n.setPosition(x, y, 0);
        const g = n.addComponent(Graphics);
        HudUI.drawGlyph(g, kind, size, color);
        return g;
    }

    /**
     * 用 Graphics 矢量绘制 UI 图标，取代 Font Awesome 图标字体。
     * 微信小游戏 canvas 对字体私有区(PUA)字形不渲染，字体图标在真机会整片消失，矢量则 100% 可靠。
     * 每个图标只用一次 fill 或一次 stroke（单色），与本文件既有 Graphics 用法一致，避免多色路径叠加。
     *
     * 全部图标画在同一套 24×24 网格上（U = size/24），视觉主体控制在 18×18 的内框里，
     * 线宽只有 STROKE（主干）和 HAIR（细节）两级。此前每枚图标各用一套比例，
     * 线宽从 0.06 到 0.19 不等，并排放在一行时轻重完全不匀。
     */
    private static drawGlyph(g: Graphics, kind: IconKind, size: number, color: Color): void {
        g.clear();
        const s = size;
        const U = s / 24;
        const STROKE = 3 * U, HAIR = 2 * U;
        g.fillColor = color;
        g.strokeColor = color;
        switch (kind) {
            case 'pause': {
                // 两根 4×16 的竖条，间距 3——比原来的 0.16s 细，和其余图标的重量对齐
                const bw = 4 * U, bh = 16 * U, gap = 1.5 * U;
                g.roundRect(-gap - bw, -bh / 2, bw, bh, bw * 0.35);
                g.roundRect(gap, -bh / 2, bw, bh, bw * 0.35);
                g.fill();
                break;
            }
            case 'play': {
                // 等高三角，视觉重心略右移，抵消三角形左重右轻的错觉
                const hh = 8.5 * U, w = 15 * U;
                g.moveTo(-w * 0.42, hh);
                g.lineTo(-w * 0.42, -hh);
                g.lineTo(w * 0.58, 0);
                g.close();
                g.fill();
                break;
            }
            case 'sound-on':
            case 'sound-off': {
                // 喇叭：方形箱体 + 外扩喇叭口。声波和叉也画成实心多边形而不是描边，
                // 整枚图标只走一次 fill——混用 fill/stroke 会把喇叭轮廓再描一遍。
                const bw = 3 * U, bh = 6 * U, mw = 5.5 * U, mh = 13 * U;
                const x0 = -9 * U;
                g.moveTo(x0, -bh / 2);
                g.lineTo(x0 + bw, -bh / 2);
                g.lineTo(x0 + bw + mw, -mh / 2);
                g.lineTo(x0 + bw + mw, mh / 2);
                g.lineTo(x0 + bw, bh / 2);
                g.lineTo(x0, bh / 2);
                g.close();
                const t = HAIR;
                if (kind === 'sound-on') {
                    // 两道 ">" 形声波，外圈更大。用折线而不是 arc：这个尺寸下
                    // 圆弧端点容易毛糙，折线反而更干净。
                    const d = 2.2 * U;
                    for (const [rx, ry] of [[2.6, 3.6], [6.2, 7.2]] as const) {
                        const x = rx * U, y = ry * U;
                        g.moveTo(x, -y);
                        g.lineTo(x + d, 0);
                        g.lineTo(x, y);
                        g.lineTo(x - t, y);
                        g.lineTo(x + d - t, 0);
                        g.lineTo(x - t, -y);
                        g.close();
                    }
                } else {
                    // 关闭态画一个叉，比「没有声波」更明确地表达静音。
                    // 两条 45° 斜杠各沿法线推半个线宽，凑成实心长方形。
                    const cx = 5.6 * U, r = 4 * U, u = t / (2 * Math.SQRT2);
                    for (const dir of [1, -1]) {
                        g.moveTo(cx - r + u * dir, -dir * r - u);
                        g.lineTo(cx + r + u * dir, dir * r - u);
                        g.lineTo(cx + r - u * dir, dir * r + u);
                        g.lineTo(cx - r - u * dir, -dir * r + u);
                        g.close();
                    }
                }
                g.fill();
                break;
            }
            case 'palette': {
                // 盘身大圈 + 拇指孔 + 三个颜料点，读作调色盘。
                // 颜料点改成实心：描边小圆在 32px 下只剩一圈灰边，糊成一团。
                g.lineWidth = STROKE;
                g.circle(0, 0, 9 * U);
                g.circle(3 * U, -3.4 * U, 2.4 * U);
                g.stroke();
                for (const [px, py] of [[-3.8, 2.4], [0.4, 4.8], [4.6, 1.2]] as const) {
                    g.circle(px * U, py * U, 1.5 * U);
                }
                g.fill();
                break;
            }
            case 'remove': {
                // 从槽口向上顶出的物件。
                //
                // 旧版只有一支光秃秃的上箭头——"向上"这个符号谁都在用（上传、升级、
                // 展开），读不出"把件从暂存槽里取出来"。补一只开口朝上的托槽当参照物，
                // 箭头从槽口探出去，语义才落地。
                // 箭头与杆一笔画成同一个多边形，避免两次 fill 在接缝处叠出深色。
                g.moveTo(0, 10 * U);
                g.lineTo(-6.4 * U, 3.2 * U);
                g.lineTo(-2.6 * U, 3.2 * U);
                g.lineTo(-2.6 * U, -2.2 * U);
                g.lineTo(2.6 * U, -2.2 * U);
                g.lineTo(2.6 * U, 3.2 * U);
                g.lineTo(6.4 * U, 3.2 * U);
                g.close();
                // 托槽：底 + 两片侧壁，开口朝上。不画成闭合方框——闭框读作"存进去"，
                // 缺口朝上才读作"从这儿拿出来"。
                g.roundRect(-8 * U, -9.4 * U, 16 * U, 3.2 * U, 1.3 * U);
                g.roundRect(-8 * U, -9.4 * U, 3 * U, 7.6 * U, 1.3 * U);
                g.roundRect(5 * U, -9.4 * U, 3 * U, 7.6 * U, 1.3 * U);
                g.fill();
                break;
            }
            case 'magnet': {
                // 马蹄磁铁，开口**朝下**，两枚极头与臂之间留出空隙。
                //
                // 旧版开口朝上、极靴又贴在臂的内侧末端与臂重合，轮廓合起来就是一个
                // 字母 U——画得再细也读不出磁铁。磁铁的识别全靠"两根臂 + 两枚更宽的
                // 极头"这个分段关系，单色下只能靠**留空隙**把极头从臂上断开来表达。
                const ro = 7.6 * U, ri = 3.9 * U;
                const armEnd = -4.2 * U;          // 臂向下收到这里
                const seg = 18;
                g.moveTo(-ro, armEnd);
                for (let i = 0; i <= seg; i++) {  // 外弧：走上半圈
                    const a = Math.PI - (Math.PI * i) / seg;
                    g.lineTo(Math.cos(a) * ro, Math.sin(a) * ro);
                }
                g.lineTo(ro, armEnd);
                g.lineTo(ri, armEnd);
                for (let i = seg; i >= 0; i--) {  // 内弧原路折回
                    const a = Math.PI - (Math.PI * i) / seg;
                    g.lineTo(Math.cos(a) * ri, Math.sin(a) * ri);
                }
                g.lineTo(-ri, armEnd);
                g.close();
                g.fill();
                // 两枚极头：比臂宽，且与臂末端隔开 1.2U 的空隙
                const poleW = (ro - ri) * 1.75, poleH = 3.9 * U;
                const armMid = (ro + ri) / 2;
                for (const sx of [-armMid, armMid]) {
                    g.roundRect(sx - poleW / 2, armEnd - 1.2 * U - poleH, poleW, poleH, 0.7 * U);
                }
                g.fill();
                break;
            }
            case 'shuffle': {
                // 通用 shuffle 符号：两条交叉的**弯**路径 + 右端箭头。
                //
                // 旧版是两条笔直的对角线交叉，那个形状读作"叉 / 关闭 / 错误"，
                // 而不是"重新洗一遍"。弯路径带出"两条线各自换到对方那一侧"的过程感，
                // 这正是打乱要表达的动作。
                // 线宽用 STROKE 而不是 HAIR：另外两枚道具图标是实心 fill，
                // 描边版在 40px 的实际显示尺寸下轻得多，三枚并排一眼就不匀。
                g.lineWidth = STROKE;
                const x0 = -9 * U, x1 = 5.6 * U, yy = 5 * U;
                // 下路：完整的一条，从左下走到右上
                g.moveTo(x0, -yy);
                g.bezierCurveTo(-3 * U, -yy, 1 * U, yy, x1, yy);
                // 上路：在交叉点处**断开**，让下路从缺口里穿过去。
                // 不留这个缺口时两条线在中点叠成一个实心结，整枚图标又读回"X / 关闭"；
                // 过桥缺口才让人看出是两条路径交错换位。交叉点由对称性落在
                // (-1.2U, 0)，缺口就开在它两侧各约 1.6U。
                // 两段的控制点不是手调的，是把整条曲线按 de Casteljau 在 t=0.40 / 0.60
                // 精确切开得到的——手给控制点时断口两侧不在同一条曲线走向上，
                // 右半段会读成一根独立的断线而不是"被挡住的那一段"。
                // 缺口实长 4.07U，配 3U 线宽两侧各余 0.5U；线宽改动时这两个 t 要一起调，
                // 缺口小于线宽就糊成实心结，大过两倍就读作断线。
                g.moveTo(x0, yy);
                g.bezierCurveTo(-6.6 * U, yy, -4.52 * U, 3.4 * U, -2.59 * U, 1.48 * U);
                g.moveTo(0.20 * U, -1.48 * U);
                g.bezierCurveTo(2.02 * U, -3.4 * U, 3.76 * U, -yy, x1, -yy);
                // 两枚箭头：开口朝左的 V，和路径同一次 stroke
                const a = 3.6 * U;
                g.moveTo(x1 - a, yy - a * 0.72); g.lineTo(x1, yy); g.lineTo(x1 - a, yy + a * 0.72);
                g.moveTo(x1 - a, -yy - a * 0.72); g.lineTo(x1, -yy); g.lineTo(x1 - a, -yy + a * 0.72);
                g.stroke();
                break;
            }
            case 'stopwatch': {
                // 表盘 + 顶部表冠 + 两根指针，整枚只走一次 stroke（同一线宽），
                // 与本文件其余图标"一次 fill 或一次 stroke"的约定一致。
                // 表盘半径压到 7.6U 而不是满 9U：顶上还要留表冠，否则整枚图标
                // 在 24 网格里顶出去，和相邻的数字基线对不齐。
                g.lineWidth = HAIR;
                const R = 7.6 * U, cy = -1.4 * U;
                g.circle(0, cy, R);
                // 表冠：一小段竖柄顶一道横帽
                const top = cy + R;
                g.moveTo(0, top);
                g.lineTo(0, top + 2.1 * U);
                g.moveTo(-2.5 * U, top + 2.1 * U);
                g.lineTo(2.5 * U, top + 2.1 * U);
                // 指针：12 点长针 + 3 点短针，读作"正在走"
                g.moveTo(0, cy);
                g.lineTo(0, cy + 4.6 * U);
                g.moveTo(0, cy);
                g.lineTo(3.4 * U, cy);
                g.stroke();
                break;
            }
            case 'snowflake': {
                // 六枝雪花：主枝 + 每枝两对小分叉，整枚一次 stroke。
                // 分叉必须有——只有六条直线时在小尺寸下读作星芒/太阳，
                // 分叉才是"雪花"的识别特征。
                g.lineWidth = HAIR;
                const R = 9.2 * U;
                for (let i = 0; i < 6; i++) {
                    const a = (Math.PI / 3) * i;
                    const cx = Math.cos(a), cy = Math.sin(a);
                    g.moveTo(0, 0);
                    g.lineTo(cx * R, cy * R);
                    for (const [at, len] of [[0.52, 0.30], [0.78, 0.22]] as const) {
                        const bx = cx * R * at, by = cy * R * at;
                        for (const da of [0.62, -0.62]) {
                            g.moveTo(bx, by);
                            g.lineTo(bx + Math.cos(a + da) * R * len,
                                     by + Math.sin(a + da) * R * len);
                        }
                    }
                }
                g.stroke();
                break;
            }
            case 'star': {
                const R = 9.5 * U, r = R * 0.46;
                for (let i = 0; i < 10; i++) {
                    const ang = Math.PI / 2 + i * Math.PI / 5;
                    const rad = i % 2 === 0 ? R : r;
                    if (i === 0) g.moveTo(Math.cos(ang) * rad, Math.sin(ang) * rad);
                    else g.lineTo(Math.cos(ang) * rad, Math.sin(ang) * rad);
                }
                g.close();
                g.fill();
                break;
            }
        }
    }

    private makeFloatingLabel(text: string, size: number, color: Color,
        align: { top?: number; bottom?: number; centerY?: number }): Label {
        const n = new Node('float');
        n.layer = Layers.Enum.UI_2D;
        n.setParent(this.gameLayer);
        const l = n.addComponent(Label);
        l.string = text;
        l.fontSize = size;
        l.lineHeight = size * 1.3;
        l.color = color;
        l.enableOutline = true;
        l.outlineColor = new Color(40, 24, 10, 255);
        l.outlineWidth = 4;
        const wd = n.addComponent(Widget);
        wd.alignMode = Widget.AlignMode.ALWAYS;
        wd.isAlignHorizontalCenter = true;
        wd.horizontalCenter = 0;
        if (align.top !== undefined) { wd.isAlignTop = true; wd.top = align.top; }
        else if (align.bottom !== undefined) { wd.isAlignBottom = true; wd.bottom = align.bottom; }
        else { wd.isAlignVerticalCenter = true; wd.verticalCenter = align.centerY ?? 0; }
        return l;
    }
}
