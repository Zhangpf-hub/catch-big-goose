import { Node, Color, UITransform } from 'cc';
import { Screen, ScreenViewport } from './UIRouter';
import { UIKit, UIColors } from './UIKit';

export interface OnboardingData {
    onDone: () => void;
}

/** 步骤卡尺寸；间距在 layout 里按剩余空间收缩，卡本身不缩。 */
const CARD_W = 612;
const CARD_H = 138;

/**
 * 首次启动引导：它是独立页面，不是盖在游戏上的说明弹窗。
 * 三步只回答开局前必须知道的事；首局里“指出可消物件”的动态教学仍由 GameManager 负责。
 *
 * 布局与首页同一套路数——固定头、固定尾、中间自适应。**这一条是必须的**：
 * 页面层只保证 1100 美术像素的可用高度（见 HudUI.sync 的 pageScaleInFrame），
 * 而这一页原先用的死坐标铺到了 -500，短屏上「开始探索」正好落在可视底边之下，
 * 于是首次启动的玩家看到的是一个没有按钮、走不下去的引导页。
 */
export class OnboardingScreen implements Screen {
    readonly name = 'onboarding';
    readonly artTop = 850;
    readonly dimWorld = true;

    private titleNode: Node | null = null;
    private subtitleNode: Node | null = null;
    private cards: Node[] = [];
    private hintNode: Node | null = null;
    private buttonNode: Node | null = null;

    constructor(private data: OnboardingData) {}

    build(root: Node) {
        UIKit.panel(root, 760, 1700, 0, new Color(76, 111, 74), 0, 0);
        UIKit.image(root, 'textures/challenge-map-bg/texture', 760, 1700, 0, 0, 118);
        const shade = UIKit.panel(root, 760, 1700, 0, new Color(31, 54, 42, 92), 0, 0);
        shade.setSiblingIndex(1);

        this.titleNode = UIKit.label(root, '抓住大鹅', 66, UIColors.cream, 0, 0).node;
        this.subtitleNode = UIKit.label(root, '一场从野餐篮开始的收集旅行', 24,
            new Color(242, 224, 174), 0, 0).node;

        const steps = [
            ['① 选一站', '沿地图向上探索，先选本局要挑战的场景'],
            ['② 定难度', '轻松、标准、大师，开始后本局不再更换'],
            ['③ 凑三个', '把相同物件放进七格，凑齐三个立即消除'],
        ] as const;
        this.cards = steps.map(([title, note]) => {
            const row = UIKit.panel(root, CARD_W, CARD_H, 28, new Color(255, 244, 214, 244),
                0, 0, new Color(187, 130, 66), 4);
            UIKit.label(row, title, 32, UIColors.text, -254, 24, true);
            UIKit.label(row, note, 21, UIColors.textSoft, -254, -26, true);
            return row;
        });

        this.hintNode = UIKit.label(root, '准备好了吗？地图会随着旅程不断向上延伸', 22,
            new Color(245, 229, 190), 0, 0).node;
        this.buttonNode = UIKit.primaryButton(root, '开始探索', 0, 0, this.data.onDone);

        // 与首页一致：build 后先按标准竖屏摆一次，首个 sync 再用真实窗口尺寸覆盖。
        this.layout({ topY: this.artTop, bottomY: -430, width: 720, height: 1280 });
    }

    /** 头贴顶、尾贴底，三张卡在中间按剩余空间分布。 */
    layout(viewport: ScreenViewport) {
        this.place(this.titleNode, 0, viewport.topY - 364);
        this.place(this.subtitleNode, 0, viewport.topY - 420);

        // 先把尾部钉死：按钮永远完整露出，底边留 38 的呼吸位。
        const buttonY = viewport.bottomY + 38 + this.height(this.buttonNode) / 2;
        const hintY = buttonY + 92;
        this.place(this.buttonNode, 0, buttonY);
        this.place(this.hintNode, 0, hintY);

        // 中段拿头尾之间剩下的高度。间距可以压到 6，卡片本身不缩——
        // 缩卡会让三行说明文字跟着变挤，那比间距紧更难读。
        const bandTop = viewport.topY - 460;
        const bandBottom = hintY + 40;
        const slack = (bandTop - bandBottom - CARD_H * this.cards.length) / (this.cards.length - 1);
        const gap = Math.min(36, Math.max(6, slack));
        const step = CARD_H + gap;
        const firstY = bandTop - CARD_H / 2;
        this.cards.forEach((card, i) => this.place(card, 0, firstY - i * step));
    }

    private place(node: Node | null, x: number, y: number) {
        if (node?.isValid) node.setPosition(x, y, 0);
    }

    private height(node: Node | null): number {
        return node?.isValid ? (node.getComponent(UITransform)?.height ?? 0) : 0;
    }
}
