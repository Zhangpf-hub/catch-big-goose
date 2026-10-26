import { Color } from 'cc';
import { BoundaryDef } from './ContainerBoundary';

/**
 * 场景皮肤（换肤只换外观，不改玩法与物理边界）。
 *
 * 一套皮肤 = 一张整屏背景图（SceneBackground 等比铺满）+ 一个中央置物筐 3D 模型。
 * 换肤时销毁并按新皮肤重建 SceneRoot 即可。
 */

export interface SceneSkin {
    id: string;
    /** 选皮面板显示名。 */
    name: string;
    /** 选皮面板预览用的两个代表色（面色 + 描边色）。 */
    swatch: [Color, Color];
    /** 背景 Sprite 的叠加色，通常留白（255,255,255）不改变贴图本色。 */
    backdrop: Color;
    /** 背景贴图名（resources/textures/<tex>/texture）。 */
    backdropTex?: string;
    /**
     * 中央置物筐 3D 模型 id（resources/models/<id>.glb）。加载后摆到容器中央并按开口缩放。
     * 留空则中央无可见容器（模型尚未就绪的皮肤），物件仍由隐形围栏约束。
     */
    containerModel?: string;
    /**
     * 容器含外置把手/耳朵时的视觉总宽；缺省 4.0。只影响模型显示缩放，不改物理边界。
     * 设计稿若把装饰伸到可玩内区之外，需要同步放大视觉总宽，避免按完整 AABB 缩放后
     * 反而把内盘压小，出现物件落在盘沿外的错觉。
     */
    containerSpan?: number;
    /**
     * 承载物边界（换成圆锅/圆碗/圆筐等造型时声明）。留空 = 沿用默认矩形边界。
     * 声明后物理围栏、逃逸判定、视觉兜底、投放种子全部按该形状生效，物品不会离开容器。
     * 需与 containerModel 的开口对齐。
     */
    boundary?: BoundaryDef;
    /**
     * 用 {@link containerModel} 的真实网格做碰撞（Jolt 静态三角网格），而不是拿
     * {@link BoundaryDef.profile} 拼环墙。曲面容器（碗、锅）应当开启。
     *
     * 环墙是 Bullet 时代的妥协：那时拿不出凹形静态体，只能用几十段竖直圆筒逼近碗壁，
     * 代价是分层处有台阶、接触法线在层间跳变、静态体上百个，物件在低处还会站到壁外。
     * Jolt 的 MeshShape 直接吃三角汤，凹形无碍，且只是**一个** shape。
     *
     * 开启后 boundary 仍然要配：逃逸判定、投放铺点、视觉兜底都还走它，
     * 只有「物理围栏」这一项换成网格。围栏则退化成 clamp 半径上的一圈安全网，
     * 正常游戏中物件碰不到它，只在模型异步加载完成前兜底。
     */
    meshCollider?: boolean;
}

/**
 * 场景皮肤。背景图为「不带置物筐」的纯场景（四周陈设 + 中央留空），由 SceneBackground
 * 全屏等比铺满、不变形、随设备自适应；中央置物筐是独立的 3D 模型（containerModel），
 * 按皮肤加载并自动缩放到 CONTAINER_SPAN，隐形物理围栏保证物件精确落在筐内。
 */
const WHITE = () => new Color(255, 255, 255);

export const SKINS: SceneSkin[] = [
    {
        id: 'redwood', name: '深红木',
        swatch: [new Color(151, 78, 50), new Color(198, 156, 92)],
        backdrop: WHITE(),
        backdropTex: 'bg_redwood',
        containerModel: 'basket_redwood',
    },
    {
        id: 'jade', name: '翡翠青玉',
        swatch: [new Color(120, 178, 150), new Color(214, 178, 98)],
        // 唯一一个不用纯白 backdrop 的皮肤：bg_jade 画的是满屏翡翠件（弥勒/玉镯/葫芦），
        // 与古玩铺主题的物件同色同形，原亮度下背景里的装饰件看着就像能点的目标。
        // 压到 55% 亮度把背景推到后景，前景物件由 3D 光照亮，对比自然拉开。
        backdrop: new Color(140, 145, 142),
        backdropTex: 'bg_jade',
        containerModel: 'bowl_jade',
        // 碗是曲面容器：碰撞交给模型网格本身，不再拼环墙（见 meshCollider 说明）。
        meshCollider: true,
        // 碰撞已交给模型网格（meshCollider），这里的 wall 只用于投放铺点与件的大小反解，
        // clamp 用于建外圈安全网。圆心沿用默认矩形中心 (0,-0.88)。
        // wall.radius=1.65 的依据见 ContainerBoundary.usableArea 的注释（实测碗沿 1.78）。
        boundary: {
            wall: { kind: 'circle', cx: 0, cz: -0.88, radius: 1.65 },
            clamp: { kind: 'circle', cx: 0, cz: -0.88, radius: 1.85 },
        },
    },
    {
        id: 'picnic', name: '户外野餐',
        swatch: [new Color(198, 158, 108), new Color(120, 150, 78)],
        backdrop: WHITE(),
        // 池塘农场背景由原创概念图切为 720×1280；中央刻意留空，3D 篮筐和物件不会
        // 与背景里的装饰物争夺“可点击”语义。低矮藤编篮沿用默认矩形边界。
        backdropTex: 'bg_farm',
        containerModel: 'basket_farm',
    },
    {
        id: 'dessert', name: '甜品小镇',
        // 取自 tray_dessert 贴图的两个主色：草莓粉褶边 + 奶油白盘身。
        // 原来的金褐 (202,154,82) 对应旧模型的金边与金把手，新盘没有金色了。
        swatch: [new Color(224, 144, 144), new Color(224, 208, 192)],
        // 场景图的中央鹅卵石广场承接独立陶瓷托盘，建筑与甜品造型只围在四周；
        // 这样背景保持主题感，又不会在可点击区域制造真假甜点混淆。
        backdrop: WHITE(),
        backdropTex: 'bg_dessert',
        containerModel: 'tray_dessert',
    },
    {
        id: 'electronics', name: '数码工坊',
        swatch: [new Color(95, 181, 204), new Color(194, 237, 214)],
        backdrop: WHITE(),
        backdropTex: 'bg_electronics',
        containerModel: 'tray_electronics',
        boundary: {
            wall: { kind: 'rect', cx: 0, cz: -0.88, halfX: 1.63, halfZ: 1.63 },
            clamp: { kind: 'rect', cx: 0, cz: -0.88, halfX: 1.73, halfZ: 1.73 },
        },
    },
];

export const DEFAULT_SKIN_ID = 'redwood';

/** 按 id 取皮肤，未知 id 回落到默认皮肤（存档损坏/旧版本兼容）。 */
export function getSkin(id: string | null | undefined): SceneSkin {
    return SKINS.find(s => s.id === id) ?? SKINS[0];
}
