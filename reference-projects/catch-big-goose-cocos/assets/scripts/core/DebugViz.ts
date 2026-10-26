import { Node, MeshRenderer, Material, utils, primitives, Color, Vec3, Layers } from 'cc';

/**
 * 调试可视化：把「隐形物理容纳」渲成半透明盒，叠在可见容器上。
 *
 * 物件的物理约束（围栏 / 地板 / boundary 形状）本是不可见的，与视觉容器网格是两套系统。
 * 穿模的根源正是这两套错位。本模块把物理侧画出来，让「物理框和碗壁差多少」一眼可见，
 * 便于逐轮对齐调参。默认关闭（GameManager.DEBUG_FENCE），只在排查时打开，不进发布包体验。
 */
export class DebugViz {
    /** 同色材质复用，避免每段围栏各建一个。 */
    private static readonly mats = new Map<number, Material>();

    private static mat(color: Color): Material {
        const key = (color.r << 24) | (color.g << 16) | (color.b << 8) | color.a;
        let m = DebugViz.mats.get(key);
        if (!m) {
            m = new Material();
            // builtin-unlit 的 technique 1 = 透明；mainColor 带 alpha 即半透明叠加。
            m.initialize({ effectName: 'builtin-unlit', technique: 1 });
            m.setProperty('mainColor', color);
            DebugViz.mats.set(key, m);
        }
        return m;
    }

    /** 在 parent 下加一个半透明盒（尺寸/朝向与某个隐形碰撞体一致）。 */
    static box(parent: Node, name: string, pos: Vec3, size: Vec3, yawDeg: number, color: Color): Node {
        const n = new Node(name);
        n.setParent(parent);
        n.setPosition(pos);
        if (yawDeg) n.setRotationFromEuler(0, yawDeg, 0);
        n.layer = Layers.Enum.DEFAULT;
        const mr = n.addComponent(MeshRenderer);
        mr.mesh = utils.createMesh(primitives.box({ width: size.x, height: size.y, length: size.z }));
        mr.setSharedMaterial(DebugViz.mat(color), 0);
        mr.shadowCastingMode = MeshRenderer.ShadowCastingMode.OFF;
        return n;
    }
}
