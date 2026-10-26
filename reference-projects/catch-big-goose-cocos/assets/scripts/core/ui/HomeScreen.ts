import {
    Node, Color, Layers, UITransform, NodeEventType, Mask, EventTouch, EventMouse, Label, Graphics,
    UIOpacity, tween, Tween, v3,
} from 'cc';
import { Screen, ScreenViewport } from './UIRouter';
import { UIKit, UIColors } from './UIKit';
import { RemoteTextures } from './RemoteTextures';

export interface MapChoice {
    id: string;
    name: string;
    tagline: string;
    routeX: number;
    selected: boolean;
    playable: boolean;
}

export interface HomeData {
    maps: MapChoice[];
    levels: { text: string; detail: string; stars: number; unlocked: boolean; selected: boolean }[];
    dailyText: string;
    bestText: string;
    soundOn: boolean;
    gmOn: boolean;
    onPickMap: (id: string) => void;
    onPickLevel: (index: number) => void;
    onToggleSound: () => boolean;
    onToggleGM: () => boolean;
    onStart: () => void;
}

const HEADER_H = 173;
const MAP_ART_H = 2160;

/**
 * 三档难度是三张独立生成的切图，画布高度（368/334/322）和内部元素大小都对不齐。
 * 旧实现把三张统统拉成 600×170：easy 被压扁 7.6%、master 被拉高 5.6%，
 * 于是每次换难度整条难度条都在缩放跳动——用户看到的「页面闪动」有一半来自这里。
 *
 * 这里改成按各自比例铺开，再用 midY（切图里未选中档位的内容中心）把三张对到同一条
 * 基线上。切换时三张预加载切图同步显隐，不再交叉淡入或重建节点。
 */
const DIFFICULTY_ART = [
    { path: 'textures/challenge-ui/difficulty-easy-clean/texture', w: 1200, h: 368, midY: 198.5 },
    { path: 'textures/challenge-ui/difficulty-normal-clean/texture', w: 1200, h: 334, midY: 177.5 },
    { path: 'textures/challenge-ui/difficulty-master-clean/texture', w: 1200, h: 322, midY: 168.5 },
];
/** 难度条显示宽度，以及三档圆章在这个宽度下的中心 x——由切图量出，别再手调。 */
const DIFFICULTY_W = 600;
const DIFFICULTY_XS = [-242, 0, 242];
/**
 * 难度条中心在控制台里的基线，以及选中托底相对它的位置和尺寸（贴着切图里的名牌胶囊）。
 * 切图坐标 y 向下增大、UI 坐标 y 向上为正，凡是从切图量来的偏移都要翻号再用。
 */
const DIFFICULTY_Y = 108;
const PLATE = { y: -45, w: 132, h: 62 };
/** 未选中/未开放站点整体退后一级；选中项不再通过缩放改变占位。 */
const STATION_IDLE_OPACITY = 190;
const STATION_LOCKED_OPACITY = 145;

const MAP_STATIONS: Record<string, {
    y: number;
    icon: string;
    edge: Color;
}> = {
    fruit: {
        y: -840, icon: 'textures/challenge-ui/station-medallion-fruit-v4/texture',
        edge: new Color(99, 157, 67),
    },
    antique: {
        y: -420, icon: 'textures/challenge-ui/station-medallion-antique-v4/texture',
        edge: new Color(57, 133, 91),
    },
    farm: {
        y: 0, icon: 'textures/challenge-ui/station-medallion-farm-v4/texture',
        edge: new Color(92, 156, 76),
    },
    dessert: {
        y: 420, icon: 'textures/challenge-ui/station-medallion-dessert-v4/texture',
        edge: new Color(211, 111, 101),
    },
    electronics: {
        y: 840, icon: 'textures/challenge-ui/station-medallion-electronics/texture',
        edge: new Color(54, 133, 165),
    },
};

/** 首页会立即出现的全部切图；加载页只能在这些纹理均已解析后撤掉。 */
export const HOME_PRELOAD_IMAGES = [
    // 新用户先看到引导页，老用户直接到路线页，两条启动分支必须使用同一门闩。
    'textures/challenge-map-bg/texture',
    'textures/challenge-ui/header-reference/texture',
    'textures/challenge-ui/map-continuous-v2/texture',
    'textures/challenge-ui/control-deck-bg/texture',
    'textures/challenge-ui/summary-frame-blank/texture',
    ...DIFFICULTY_ART.map(art => art.path),
    'textures/challenge-ui/cta-button-clean/texture',
    ...Object.values(MAP_STATIONS).map(station => station.icon),
    RemoteTextures.stationFrame,
    RemoteTextures.selectionBadge,
] as const;

/**
 * 挑战首页：顶部品牌、滚动地图、底部挑战控制台是三个独立区域。
 *
 * 关键约束：短屏只能压缩/裁切地图，摘要、难度、提示、开始按钮和次数必须作为一个
 * 完整控制台固定在可视底部。后续地图按两站一段向上追加，页面本身不需要改布局。
 */
export class HomeScreen implements Screen {
    readonly name = 'home';
    readonly artTop = 778.5;
    readonly dimWorld = true;

    private root: Node | null = null;
    private mapViewport: Node | null = null;
    private mapContent: Node | null = null;
    private controlDeck: Node | null = null;
    private deckBg: Node | null = null;
    private summaryFrame: Node | null = null;
    private summaryLabel: Label | null = null;
    private difficultyArts: Node[] = [];
    private selectPlate: Node | null = null;
    private difficultyBadge: Node | null = null;
    private difficultyHits: Node[] = [];
    private selectedLevel = 0;
    private deckScale = 1;
    private lockNote: Node | null = null;
    private ctaArt: Node | null = null;
    private ctaHit: Node | null = null;
    private footerLabel: Label | null = null;
    private soundStateArt: Node | null = null;
    private mapStations: Node[] = [];

    private contentBottom = -MAP_ART_H / 2;
    private contentTop = MAP_ART_H / 2;
    private scrollY = 0;
    private minScroll = 0;
    private maxScroll = 0;
    private userScrolled = false;
    private mapDragging = false;
    private dragDistance = 0;
    private visibleBottom = -779.5;

    constructor(private data: HomeData) {}

    build(root: Node) {
        this.root = root;
        // 超高底色覆盖所有可见比例，宽屏两侧由路由层的暗木背景自然留空。
        UIKit.panel(root, 760, 3600, 0, new Color(71, 39, 23), 0, this.artTop - 1800);

        this.buildMapViewport(root);
        this.buildControlDeck(root);

        // 标题与右上控制固定在最上层，地图滚动不会把设置和声音带走。
        UIKit.image(root, 'textures/challenge-ui/header-reference/texture', 720, HEADER_H,
            0, this.artTop - HEADER_H / 2);
        UIKit.hitArea(root, 68, 76, 244, this.artTop - 62.5, () => this.showSettings());
        this.soundStateArt = this.buildSoundState(root);
        UIKit.hitArea(root, 76, 76, 310, this.artTop - 62.5, () => {
            this.data.soundOn = this.data.onToggleSound();
            this.drawSoundState();
            this.showSoundToast(this.data.soundOn);
        });

        // build 后立刻给一份标准竖屏布局；首个 sync 会用真实窗口尺寸覆盖它。
        this.layout({ topY: this.artTop, bottomY: -779.5, width: 720, height: 1558 });
    }

    /** 固定头尾，把剩余高度全部交给可裁切地图。 */
    layout(viewport: ScreenViewport) {
        this.visibleBottom = viewport.bottomY;
        // 控制台始终保留完整的信息层级；短屏只裁地图，不能再拿底部次数换空间。
        const deckH = this.clamp(500 + (viewport.height - 1100) * 0.04, 500, 530);
        const deckCenter = viewport.bottomY + deckH / 2;
        this.place(this.controlDeck, 720, deckH, 0, deckCenter);
        this.place(this.deckBg, 720, deckH, 0, 0);
        this.layoutDeck(deckH);

        const mapTop = viewport.topY - HEADER_H;
        // 木框顶边向地图压 8px，形成“地图插在控制台后面”的层次，同时不盖住地图节点。
        const mapBottom = viewport.bottomY + deckH - 8;
        const mapH = Math.max(360, mapTop - mapBottom);
        this.place(this.mapViewport, 720, mapH, 0, (mapTop + mapBottom) / 2);
        this.updateScrollBounds(mapH);
    }

    private buildMapViewport(root: Node) {
        const viewport = new Node('mapViewport');
        viewport.layer = Layers.Enum.UI_2D;
        viewport.setParent(root);
        // build 阶段先给标准竖屏高度，layout 随后会用真实窗口覆盖；不能误用长卷自身高度，
        // 否则首帧遮罩会把整张地图当作可视区闪出来。
        viewport.addComponent(UITransform).setContentSize(720, 912);
        viewport.addComponent(Mask).type = Mask.Type.GRAPHICS_RECT;
        this.mapViewport = viewport;

        const content = new Node('mapScrollContent');
        content.layer = Layers.Enum.UI_2D;
        content.setParent(viewport);
        this.mapContent = content;

        // 四站共用一张连续长卷。旧实现把首章图和扩展图上下硬拼，图内自带的桌布、海岸线
        // 和纸张边缘会横穿地图；站点越往上，断层越明显。长卷只保留最外层羊皮纸边框，
        // 河流与石径从水果篮一直连续到甜品小镇，不再依赖任何可见接缝。
        UIKit.image(content, 'textures/challenge-ui/map-continuous-v2/texture',
            720, MAP_ART_H, 0, 0);

        this.buildMapStations();

        this.contentTop = MAP_ART_H / 2;
        this.contentBottom = -MAP_ART_H / 2;
        content.addComponent(UITransform).setContentSize(720, this.contentTop - this.contentBottom);

        const onDragStart = () => {
            this.mapDragging = false;
            this.dragDistance = 0;
            // 上一次选站的缓动滚动还没走完就上手拖，两边会各自 setPosition 互相拉扯。
            Tween.stopAllByTarget(content);
        };
        const onDragMove = (event: EventTouch) => {
            const delta = event.getUIDelta();
            this.dragDistance += Math.abs(delta.y);
            if (this.dragDistance > 8) this.mapDragging = true;
            this.userScrolled = true;
            this.scrollY = this.clamp(this.scrollY + delta.y, this.minScroll, this.maxScroll);
            this.mapContent?.setPosition(0, this.scrollY, 0);
        };
        const onDragEnd = () => { this.mapDragging = false; };

        // 地图内部有站点热区和多张 Sprite。使用捕获阶段监听，保证从插画或站点上起手都能拖动，
        // 不会因为子节点成为触摸目标而丢掉 MOVE；桌面端同时支持滚轮查看长地图。
        viewport.on(NodeEventType.TOUCH_START, onDragStart, this, true);
        viewport.on(NodeEventType.TOUCH_MOVE, onDragMove, this, true);
        viewport.on(NodeEventType.TOUCH_END, onDragEnd, this, true);
        viewport.on(NodeEventType.TOUCH_CANCEL, onDragEnd, this, true);
        viewport.on(NodeEventType.MOUSE_WHEEL, (event: EventMouse) => {
            const direction = Math.sign(event.getScrollY());
            if (!direction) return;
            this.userScrolled = true;
            this.scrollY = this.clamp(this.scrollY - direction * 96, this.minScroll, this.maxScroll);
            this.mapContent?.setPosition(0, this.scrollY, 0);
        }, this, true);
    }

    /** 顶部声音键直接呈现当前状态：开启只显示绿点，静音显示红色斜杠和红点。 */
    private buildSoundState(root: Node) {
        const state = new Node('homeSoundState');
        state.layer = Layers.Enum.UI_2D;
        state.setParent(root);
        state.setPosition(310, this.artTop - 62.5, 0);
        state.addComponent(UITransform).setContentSize(76, 76);
        state.addComponent(Graphics);
        this.soundStateArt = state;
        this.drawSoundState();
        return state;
    }

    private drawSoundState() {
        const graphics = this.soundStateArt?.getComponent(Graphics);
        if (!graphics) return;
        graphics.clear();

        if (this.data.soundOn) {
            graphics.fillColor = new Color(74, 157, 67);
        } else {
            // 先画浅色垫线再画红色斜杠，压在深色扬声器上仍然清楚。
            graphics.lineWidth = 11;
            graphics.strokeColor = new Color(255, 239, 196);
            graphics.moveTo(-17, 18);
            graphics.lineTo(19, -18);
            graphics.stroke();
            graphics.lineWidth = 7;
            graphics.strokeColor = new Color(181, 63, 43);
            graphics.moveTo(-17, 18);
            graphics.lineTo(19, -18);
            graphics.stroke();
            graphics.fillColor = new Color(190, 66, 45);
        }
        graphics.circle(25, -25, 8);
        graphics.fill();
        graphics.lineWidth = 3;
        graphics.strokeColor = new Color(255, 239, 196);
        graphics.stroke();
    }

    private buildControlDeck(root: Node) {
        const deck = new Node('challengeControlDeck');
        deck.layer = Layers.Enum.UI_2D;
        deck.setParent(root);
        deck.addComponent(UITransform).setContentSize(720, 430);
        this.controlDeck = deck;

        this.deckBg = UIKit.image(deck, 'textures/challenge-ui/control-deck-bg/texture',
            720, 430, 0, 0);
        this.summaryFrame = UIKit.image(deck, 'textures/challenge-ui/summary-frame-blank/texture',
            620, 78, 0, 166);

        this.selectedLevel = Math.max(0, this.data.levels.findIndex(l => l.selected));
        this.summaryLabel = UIKit.label(deck, this.summaryTextOf(this.selectedLevel),
            25, new Color(116, 73, 42), 0, 166);

        // 选中档位的辉光垫在难度切图之下，只从名牌胶囊四周透出来。不叠在切图之上：
        // 三张切图各自烘焙了选中态，再盖一层实心色块会和它们打架。
        this.selectPlate = UIKit.glow(deck, PLATE.w, PLATE.h, 0, 0);

        // 三档切图全部建好、只靠透明度切换。换难度时若临时新建节点，纹理回调要等下一帧，
        // 中间会露出一帧空白——那一帧就是「闪」。
        this.difficultyArts = DIFFICULTY_ART.map((art, i) => {
            const node = UIKit.image(deck, art.path, DIFFICULTY_W, art.h * (DIFFICULTY_W / art.w),
                0, DIFFICULTY_Y);
            node.addComponent(UIOpacity).opacity = i === this.selectedLevel ? 255 : 0;
            return node;
        });
        // 勾章必须在三张难度切图之后创建，才能稳定压在当前档位右上角。
        this.difficultyBadge = UIKit.image(deck,
            RemoteTextures.selectionBadge, 68, 68, 0, 0);

        this.data.levels.forEach((lv, i) => {
            const hit = UIKit.hitArea(deck, 190, 150, DIFFICULTY_XS[i], DIFFICULTY_Y, () => {
                if (!this.mapDragging && lv.unlocked) this.data.onPickLevel(i);
            });
            this.difficultyHits.push(hit);
        });

        // 提示文字不用再烘焙进带图标的切图，避免小屏缩放后图标和文案互相挤压。
        this.lockNote = UIKit.label(deck, '出发后地图与难度固定', 20,
            new Color(116, 73, 42), 0, -12).node;
        this.ctaArt = UIKit.image(deck, 'textures/challenge-ui/cta-button-clean/texture',
            520, 136, 0, -91);
        this.ctaHit = UIKit.hitArea(deck, 500, 112, 0, -91, this.data.onStart);

        this.footerLabel = UIKit.label(deck,
            `${this.data.dailyText}  ·  ${this.data.bestText}`,
            20, new Color(116, 73, 42), 0, -190);
    }

    private layoutDeck(deckH: number) {
        const s = this.clamp(deckH / 520, 0.96, 1.02);
        this.deckScale = s;
        this.place(this.summaryFrame, 620 * s, 78 * s, 0, 205 * s);
        if (this.summaryLabel) {
            this.summaryLabel.fontSize = Math.round(25 * s);
            this.summaryLabel.lineHeight = Math.round(31 * s);
            this.summaryLabel.node.setPosition(0, 205 * s, 0);
        }
        this.difficultyArts.forEach((node, i) => {
            const art = DIFFICULTY_ART[i];
            const k = DIFFICULTY_W / art.w;
            // 对齐的是内容中心而不是画布中心，三张画布高度不同才不会互相错位。
            this.place(node, DIFFICULTY_W * s, art.h * k * s, 0,
                (DIFFICULTY_Y + (art.midY - art.h / 2) * k) * s);
        });
        // 托底是 Graphics 画的固定路径，改 contentSize 不会重画，只能整体缩放。
        this.selectPlate?.setScale(s, s, 1);
        this.selectPlate?.setPosition(DIFFICULTY_XS[this.selectedLevel] * s,
            (DIFFICULTY_Y + PLATE.y) * s, 0);
        this.place(this.difficultyBadge, 68 * s, 68 * s,
            (DIFFICULTY_XS[this.selectedLevel] + 63) * s, (DIFFICULTY_Y + 50) * s);
        this.difficultyHits.forEach((hit, i) => this.place(hit, 190 * s, 150 * s,
            DIFFICULTY_XS[i] * s, DIFFICULTY_Y * s));
        this.place(this.lockNote, 340 * s, 48 * s, 0, -16 * s);
        this.place(this.ctaArt, 520 * s, 136 * s, 0, -112 * s);
        this.place(this.ctaHit, 500 * s, 112 * s, 0, -112 * s);
        if (this.footerLabel) {
            this.footerLabel.fontSize = Math.round(20 * s);
            this.footerLabel.lineHeight = Math.round(25 * s);
            this.footerLabel.node.setPosition(0, -187 * s, 0);
        }
    }

    /** 摘要行的文案只依赖静态关卡配置，页面自己就能算，不用为了换一行字重建整页。 */
    private summaryTextOf(index: number) {
        const level = this.data.levels[index];
        const detail = level?.detail.replace(/ · 石头 \d+/, '') ?? '';
        const compactDetail = detail.split(' · ').slice(1).join(' · ');
        return `${level?.text ?? '标准'}挑战 · ${compactDetail}`;
    }

    /**
     * 首页内切换难度：和 {@link selectMap} 一样只做局部更新。
     *
     * 旧链路是回 GameManager 再 showHome()，等于整页重建 + 路由淡入淡出，点一下难度
     * 连地图带控制台一起闪一次——切换本身反而看不清楚。这里只换三张切图的透明度、
     * 挪一下选中托底、刷新摘要与成绩行。
     */
    selectLevel(index: number, bestText: string) {
        if (!this.controlDeck?.isValid || !this.data.levels[index]) return;
        if (index === this.selectedLevel) return;
        this.data.levels.forEach((lv, i) => { lv.selected = i === index; });
        this.selectedLevel = index;

        this.data.bestText = bestText;
        if (this.footerLabel) {
            this.footerLabel.string = `${this.data.dailyText}  ·  ${bestText}`;
        }
        if (this.summaryLabel) this.summaryLabel.string = this.summaryTextOf(index);

        // 三张纹理在进入首页时已经全部加载；切换时同步改透明度，不做交叉淡入，
        // 避免两个完整难度条短暂叠在一起产生“整页闪了一下”的错觉。
        this.difficultyArts.forEach((node, i) => {
            const op = node.getComponent(UIOpacity) ?? node.addComponent(UIOpacity);
            Tween.stopAllByTarget(op);
            op.opacity = i === index ? 255 : 0;
        });

        const s = this.deckScale;
        const plate = this.selectPlate;
        if (plate?.isValid) {
            // 选中托底与勾章直接落位，不缩放、不弹跳；静止状态本身就必须足够清楚。
            Tween.stopAllByTarget(plate);
            plate.setPosition(DIFFICULTY_XS[index] * s, (DIFFICULTY_Y + PLATE.y) * s, 0);
            plate.setScale(s, s, 1);
        }
        this.place(this.difficultyBadge, 68 * s, 68 * s,
            (DIFFICULTY_XS[index] + 63) * s, (DIFFICULTY_Y + 50) * s);
    }

    /** 设置使用首页自己的浮层；卡片始终取当前可视范围中心，不受长地图滚动影响。 */
    private showSettings() {
        const root = this.root;
        if (!root) return;
        root.getChildByName('homeSettings')?.destroy();
        const overlay = new Node('homeSettings');
        overlay.layer = Layers.Enum.UI_2D;
        overlay.setParent(root);
        const overlayH = this.artTop - this.visibleBottom + 300;
        const centerY = (this.artTop + this.visibleBottom) / 2;
        overlay.addComponent(UITransform).setContentSize(720, overlayH);
        overlay.setPosition(0, centerY, 0);

        const mask = UIKit.panel(overlay, 720, overlayH, 0, new Color(20, 12, 8, 170), 0, 0);
        mask.on(NodeEventType.TOUCH_END, () => overlay.isValid && overlay.destroy());

        const card = UIKit.panel(overlay, 500, 440, 32, UIColors.cream, 0, 0,
            UIColors.edge, 6);
        UIKit.label(card, '设 置', 44, UIColors.gold, 0, 158);
        const sound = UIKit.panel(card, 360, 82, 22, new Color(238, 220, 188), 0, 66,
            UIColors.edgeSoft, 3);
        const soundLabel = UIKit.label(sound, `声音  ${this.data.soundOn ? '开' : '关'}`,
            28, UIColors.text, 0, 0);
        UIKit.tap(sound, () => {
            this.data.soundOn = this.data.onToggleSound();
            soundLabel.string = `声音  ${this.data.soundOn ? '开' : '关'}`;
            this.drawSoundState();
        });
        const gmRow = UIKit.panel(card, 360, 82, 22, new Color(238, 220, 188), 0, -38,
            UIColors.edgeSoft, 3);
        UIKit.label(gmRow, 'GM 模式', 26, UIColors.text, -145, 0, true);
        const track = UIKit.panel(gmRow, 92, 48, 24, new Color(152, 155, 149), 112, 0);
        const knob = UIKit.panel(track, 38, 38, 19, UIColors.cream, -21, 0);
        const trackGraphic = track.getComponent(Graphics)!;
        const paintGM = () => {
            trackGraphic.clear();
            trackGraphic.roundRect(-46, -24, 92, 48, 24);
            trackGraphic.fillColor = this.data.gmOn ? new Color(57, 139, 100) : new Color(152, 155, 149);
            trackGraphic.fill();
            knob.setPosition(this.data.gmOn ? 21 : -21, 0, 0);
        };
        paintGM();
        UIKit.tap(gmRow, () => {
            this.data.gmOn = this.data.onToggleGM();
            paintGM();
        });
        const close = UIKit.panel(card, 260, 72, 20, UIColors.goldFill, 0, -158,
            UIColors.edge, 4);
        UIKit.label(close, '关闭', 28, UIColors.text, 0, 0);
        UIKit.tap(close, () => overlay.isValid && overlay.destroy());
    }

    private showSoundToast(on: boolean) {
        const root = this.root;
        if (!root) return;
        root.getChildByName('soundToast')?.destroy();
        const toast = UIKit.panel(root, 250, 66, 24, new Color(48, 29, 18, 230),
            0, this.artTop - HEADER_H - 40, UIColors.edge, 3);
        toast.name = 'soundToast';
        UIKit.label(toast, on ? '声音已开启' : '声音已关闭', 24, UIColors.cream, 0, 0);
        setTimeout(() => toast.isValid && toast.destroy(), 1200);
    }

    private tapMap(id: string) {
        if (this.mapDragging || this.dragDistance > 8) return;
        this.data.onPickMap(id);
    }

    /**
     * 首页内切换地图只更新四个站点，不再让路由销毁并淡入整页。
     * 旧链路会同时触发 UIKit.tap 缩放和 UIRouter 0→1 淡入，视觉上就是点击后白闪一下。
     */
    selectMap(id: string, bestText: string) {
        if (!this.mapContent?.isValid) return;
        let changed = false;
        this.data.maps.forEach(map => {
            const next = map.id === id;
            changed ||= map.selected !== next;
            map.selected = next;
        });
        if (!changed) return;

        this.data.bestText = bestText;
        if (this.footerLabel) {
            this.footerLabel.string = `${this.data.dailyText}  ·  ${bestText}`;
        }
        // 不销毁重建四个站点：即使纹理已缓存，重新挂 Sprite 仍可能空一帧。
        // 只切换常驻勾章、金圈和整体层级，选中反馈立即出现且地图不会闪。
        this.refreshMapStationStates();

        // 选中后平稳把目标放回视口中心；只改地图内容位置，不做页面级淡入淡出。
        const station = MAP_STATIONS[id];
        if (station) {
            this.scrollY = this.clamp(-station.y + 34, this.minScroll, this.maxScroll);
            // 瞬移会让整张地图跳一下，读起来又像闪；缓动过去顺带交代了「去了哪一站」。
            Tween.stopAllByTarget(this.mapContent);
            tween(this.mapContent)
                .to(0.28, { position: v3(0, this.scrollY, 0) }, { easing: 'quadOut' })
                .start();
        }
    }

    private buildMapStations() {
        const content = this.mapContent;
        if (!content?.isValid) return;
        this.mapStations.forEach(node => node.isValid && node.destroy());
        this.mapStations = [];
        this.data.maps.forEach((map, index) => {
            const station = MAP_STATIONS[map.id];
            if (!station) return;
            this.mapStations.push(this.buildMapNode(content, map, map.routeX, station.y, index));
        });
    }

    /** 更新现有站点状态，不重建节点和纹理。 */
    private refreshMapStationStates() {
        this.mapStations.forEach((node, index) => {
            const map = this.data.maps[index];
            if (!map || !node.isValid) return;
            const selected = map.selected;
            const opacity = node.getComponent(UIOpacity) ?? node.addComponent(UIOpacity);
            opacity.opacity = !map.playable ? STATION_LOCKED_OPACITY
                : (selected ? 255 : STATION_IDLE_OPACITY);
            const ring = node.getChildByName('selectedRing');
            if (ring) ring.active = selected;
            const badge = node.getChildByName('selectedBadge');
            if (badge) badge.active = selected;
        });
    }

    private updateScrollBounds(viewportH: number) {
        this.minScroll = viewportH / 2 - this.contentTop;
        this.maxScroll = -viewportH / 2 - this.contentBottom;
        if (this.minScroll > this.maxScroll) {
            const middle = (this.minScroll + this.maxScroll) / 2;
            this.minScroll = middle;
            this.maxScroll = middle;
        }
        if (!this.userScrolled) {
            const selectedIndex = this.data.maps.findIndex(m => m.selected);
            // 选中站点始终回到地图视口的视觉中心；站点坐标只维护在 MAP_STATIONS，
            // 避免背景、点击区与自动滚动各存一套魔法数字，改图后再次错位。
            const selectedId = this.data.maps[selectedIndex]?.id;
            const target = -(MAP_STATIONS[selectedId]?.y ?? MAP_STATIONS.fruit.y) + 34;
            this.scrollY = this.clamp(target, this.minScroll, this.maxScroll);
        } else {
            this.scrollY = this.clamp(this.scrollY, this.minScroll, this.maxScroll);
        }
        this.mapContent?.setPosition(0, this.scrollY, 0);
    }

    private buildMapNode(parent: Node, map: MapChoice, x: number, y: number, index: number): Node {
        const station = MAP_STATIONS[map.id] ?? MAP_STATIONS.fruit;
        const selected = map.selected;
        const stationRoot = new Node(`mapStation-${map.id}`);
        stationRoot.layer = Layers.Enum.UI_2D;
        stationRoot.setParent(parent);
        stationRoot.setPosition(x, y, 0);
        stationRoot.addComponent(UITransform).setContentSize(336, 252);

        // 四站共用木金底座，圆章内直接放完整主题画芯。画芯已在资源阶段裁成同直径透明圆，
        // 这里保持相同尺寸和中心点，避免换站时因缩放差异产生跳闪。
        // 圆章内芯在美术稿里是 459px 直径、中心 (721.5, 371)，换算到 330×247 的显示尺寸
        // 就是直径 105、中心 (0, 39)；画芯与选中光圈都按这组数字对齐，不能再各写一套。
        // 选中项保持原尺寸，未选中项只整体退后；尺寸不变就不会在点击时产生跳闪。
        const stationOpacity = stationRoot.addComponent(UIOpacity);
        stationOpacity.opacity = !map.playable ? STATION_LOCKED_OPACITY
            : (selected ? 255 : STATION_IDLE_OPACITY);
        UIKit.image(stationRoot, RemoteTextures.stationFrame,
            330, 247, 0, 0);
        // 选中光圈必须画在底座之后：底座圆章内芯是不透明的羊皮纸面，先画就会被整块盖住，
        // 只剩超出木框的那一段露在画芯上方——旧实现（直径 178）漏出的就是这道半圈白弧。
        const selectedRing = UIKit.panel(stationRoot, 108, 108, 54,
            new Color(255, 210, 63, 65), 0, 39, new Color(255, 249, 206, 245), 5);
        selectedRing.name = 'selectedRing';
        selectedRing.active = selected;
        UIKit.image(stationRoot, station.icon, 98, 98, 0, 39,
            map.playable ? 255 : 118);
        // 手绘勾章是选中状态的主要识别信号，固定在圆章右上角，不依赖动画才能看见。
        const selectedBadge = UIKit.image(stationRoot,
            RemoteTextures.selectionBadge, 68, 68, 66, 82);
        selectedBadge.name = 'selectedBadge';
        selectedBadge.active = selected;

        // 左侧圆章已经烘焙在底座里，只叠站号；站号槽内芯中心在美术稿的 (224, 800.5)，
        // 对应显示坐标 (-114, -58.5)，照抄这组数字才能让数字落在圆心而不是压到左上边。
        // 标题区保持充足留白，不再额外套矩形描边。
        // 文字是 Label，不吃 Sprite 的叠色：底座压暗了字还留在原色，会浮在灰面上格外扎眼。
        // 未选中的站连字一起往后退，整块才是一个层次。
        UIKit.label(stationRoot, `${index + 1}`, 23,
            !map.playable ? UIColors.textLocked : station.edge,
            -114, -58.5);
        UIKit.label(stationRoot, map.name, 29,
            !map.playable ? UIColors.textLocked : UIColors.text,
            18, -43);
        UIKit.label(stationRoot, map.tagline, 16,
            UIColors.textSoft, 18, -78);
        if (map.playable) {
            // 地图节点不要复用 UIKit.tap：按下缩放会让整块底座闪一下，且与拖地图手势抢反馈。
            stationRoot.on(NodeEventType.TOUCH_END, () => this.tapMap(map.id));
        }
        return stationRoot;
    }

    private place(node: Node | null, w: number, h: number, x: number, y: number) {
        if (!node?.isValid) return;
        node.setPosition(x, y, 0);
        node.getComponent(UITransform)?.setContentSize(w, h);
    }

    private clamp(value: number, min: number, max: number) {
        return Math.max(min, Math.min(max, value));
    }

    dispose() {
        this.root = null;
        this.mapViewport = null;
        this.mapContent = null;
        this.mapStations = [];
        this.controlDeck = null;
        this.difficultyArts = [];
        this.selectPlate = null;
        this.difficultyBadge = null;
        this.soundStateArt = null;
    }
}
