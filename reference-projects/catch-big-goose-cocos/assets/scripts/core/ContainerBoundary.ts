import { v3, Vec3 } from 'cc';

/**
 * 通用容器边界（承载物边界）。
 *
 * 目的：不同场景的容器造型不同——篮 / 盒 / 柜是矩形，锅 / 碗 / 圆筐 / 煎盘是圆形。
 * 历史代码把矩形边界硬编码在多处，换成圆容器就会漏。这里把它抽象成一个
 * {@link BoundaryShape}，三个环节统一调用：
 *   1. buildWallSpecs —— 物理围栏（矩形 4 面 / 圆形环段）；
 *   2. seedPoint + usableArea —— 投放铺点与件的大小反解，随容器自适应；
 *   3. respawn —— 「移出」道具把件退回堆中时的落点。
 *
 * 换 Jolt 之后这个类瘦了一圈：逃逸判定（isEscaped）、越界拉回（clampPointToWall）、
 * 视觉外轮廓兜底（clampAabb）三个方法连同调用方 PilePatrol 一起删除了——它们都是
 * 「物理不收敛所以脚本硬掰」的产物。曲面容器的分层环墙剖面（profile）也删了，
 * 碗改用模型网格做碰撞（见 SceneSkin.meshCollider）。
 */

/** 承载物在 XZ 平面上的可容纳区域（Y 向上）。以后要长条 / 椭圆再加 kind 即可。 */
export type BoundaryShape =
    | { kind: 'rect'; cx: number; cz: number; halfX: number; halfZ: number }
    | { kind: 'circle'; cx: number; cz: number; radius: number };

/** 一段隐形围栏的描述，交给 GameManager 变成 BoxCollider。yawDeg 用于圆环切向段。 */
export interface WallSpec {
    name: string;
    pos: Vec3;
    size: Vec3;
    yawDeg: number;
}

/**
 * 一个容器的完整边界定义。
 * wall  = 投放铺点与件的大小反解所用的形状，通常紧贴可见容器内壁；
 *         非 meshCollider 皮肤下它同时是物理围栏。
 * clamp = 比 wall 大一圈的外圈。meshCollider 皮肤（碗）用它建安全网围栏——
 *         真正的碰撞由模型网格承担，安全网只在网格异步加载完成前兜底。
 */
export interface BoundaryDef {
    wall: BoundaryShape;
    clamp: BoundaryShape;
}

export class ContainerBoundary {
    readonly wall: BoundaryShape;
    readonly clamp: BoundaryShape;

    constructor(def: BoundaryDef) {
        this.wall = def.wall;
        this.clamp = def.clamp;
    }

    get centerX(): number { return this.wall.cx; }
    get centerZ(): number { return this.wall.cz; }

    /**
     * 形状内的均匀铺点：把两个 [0,1) 的低差异样本映射到「墙内收 inset」的区域里。
     *
     * 这是「铺满筐底」与「堆成一根柱子」的分界。历史实现是极坐标小圆盘，
     * 矩形容器的四角永远撒不到点，物件只能往中间摞——2.70×2.84 的筐底配上
     * 半径 0.72 的种子盘，24 件就能叠到 y=4.7（筐沿 ~1.0）。
     * 矩形分支直接线性映射（四角也能落到），圆形分支的半径必须过 sqrt，
     * 否则面积不等概率、点全挤在圆心。
     */
    seedPoint(u1: number, u2: number, inset: number): { x: number; z: number } {
        const s = this.wall;
        if (s.kind === 'rect') {
            const hx = Math.max(0.05, s.halfX - inset);
            const hz = Math.max(0.05, s.halfZ - inset);
            return { x: s.cx + (u1 * 2 - 1) * hx, z: s.cz + (u2 * 2 - 1) * hz };
        }
        const r = Math.max(0.05, s.radius - inset) * Math.sqrt(u1);
        const a = u2 * Math.PI * 2;
        return { x: s.cx + Math.cos(a) * r, z: s.cz + Math.sin(a) * r };
    }

    /** 墙内收 inset 后的可用底面积。投放侧用它估「一层放得下几件」。 */
    usableArea(inset: number): number {
        const s = this.wall;
        if (s.kind === 'rect') {
            return Math.max(0.01, (s.halfX - inset) * 2) * Math.max(0.01, (s.halfZ - inset) * 2);
        }
        // 圆容器（碗）取 wall.radius 作为**整堆的代表半径**，而不是碗底那个小半径。
        // 实测 bowl_jade 的内壁是随高度张开的：y=0 处 0.98、y=0.6 处 1.48、碗沿 1.78。
        // 按碗底 0.98 反解，件会缩到 0.61，太小；按碗沿 1.78 反解又会溢出。
        // 现值 1.65 落在两者之间，实测 36 件堆顶 1.31（碗沿 1.43）、最远径向 1.49，
        // 恰好填到沿口且贴着壁——改之前请先复现这组数。
        const r = Math.max(0.01, s.radius - inset);
        return Math.PI * r * r;
    }

    /**
     * 物理围栏墙段。矩形 = 前后左右 4 面厚墙；圆形 = 一圈相互重叠的切向薄墙近似圆壁。
     * @param height 墙高（竖向覆盖）
     * @param y      墙体中心 Y
     * @param thickness 墙厚（沿法向），下探到台面以下杜绝隧穿
     */
    buildWallSpecs(height: number, y: number, thickness: number): WallSpec[] {
        const s = this.wall;
        const WT = thickness;
        if (s.kind === 'rect') {
            const spanX = s.halfX * 2 + WT * 2;
            return [
                { name: 'fenceN', pos: v3(s.cx, y, s.cz - s.halfZ - WT / 2), size: v3(spanX, height, WT), yawDeg: 0 },
                { name: 'fenceS', pos: v3(s.cx, y, s.cz + s.halfZ + WT / 2), size: v3(spanX, height, WT), yawDeg: 0 },
                { name: 'fenceW', pos: v3(s.cx - s.halfX - WT / 2, y, s.cz), size: v3(WT, height, s.halfZ * 2), yawDeg: 0 },
                { name: 'fenceE', pos: v3(s.cx + s.halfX + WT / 2, y, s.cz), size: v3(WT, height, s.halfZ * 2), yawDeg: 0 },
            ];
        }
        // 圆壁：N 段薄墙沿半径 (radius + WT/2) 均布，内壁恰好落在 radius 上。
        // 段长 = 弧长 × 重叠系数，宁可相邻重叠也不留缝（缝会漏物件）。
        // 段数随半径自适应：半径越大越多段，逼近真圆——减小"多边形外凸"(内壁弦
        // 在段间凸出真圆之外，物件可被顶到弦外)与段间楔出缝。下限 28 保底。
        return this.ringSpecs(s.radius, height, y, WT, '');
    }

    /**
     * 容器内的重新投放点（「移出」道具把槽里的件退回堆中时用）。
     * 矩形取内区、圆形取内盘，配合抬高的 y 重新倒入。
     */
    respawn(rand: () => number): { x: number; z: number } {
        const s = this.wall;
        if (s.kind === 'rect') {
            // 系数 1.04 / 0.85 使默认矩形复刻历史落点范围（±1.4 / ±1.2）。
            return {
                x: s.cx + (rand() - 0.5) * s.halfX * 1.04,
                z: s.cz + (rand() - 0.5) * s.halfZ * 0.85,
            };
        }
        const a = rand() * Math.PI * 2;
        const r = rand() * s.radius * 0.5;
        return { x: s.cx + Math.cos(a) * r, z: s.cz + Math.sin(a) * r };
    }

    /** 一圈切向环段。 */
    private ringSpecs(radius: number, height: number, y: number, WT: number,
        tag: string): WallSpec[] {
        const s = this.wall as { cx: number; cz: number };
        const N = Math.max(28, Math.ceil(radius * 22));
        const ringR = radius + WT / 2;
        // 重叠系数按**内壁**(半径 s.radius)处的弧长算，保证连内壁接缝都相互重叠、
        // 不给小件留缝；旧版按 ringR(外圈)算，内壁处重叠偏小仍可能被薄片钻缝。
        const segLen = (2 * Math.PI * radius / N) * 1.8;
        const specs: WallSpec[] = [];
        for (let i = 0; i < N; i++) {
            const theta = (i / N) * Math.PI * 2;
            const cos = Math.cos(theta);
            const sin = Math.sin(theta);
            specs.push({
                name: `fenceRing${tag}_${i}`,
                pos: v3(s.cx + cos * ringR, y, s.cz + sin * ringR),
                // 盒体 length(局部 X) 对齐切向，depth(局部 Z) 沿半径向内。
                // 绕 Y 旋转 φ 时局部 X→(cosφ,0,-sinφ)，令其等于切向(-sinθ,cosθ) 解得 φ=-(θ+90°)。
                size: v3(segLen, height, WT),
                yawDeg: -(theta * 180 / Math.PI + 90),
            });
        }
        return specs;
    }
}
