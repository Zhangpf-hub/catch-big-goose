import {
    Node, Scene, Camera, Canvas, Color, Layers, Sprite, SpriteFrame, Texture2D,
    UITransform, resources, view,
} from 'cc';

/**
 * 全屏 2D 场景背景：独立相机 + Canvas + Sprite，垫在 3D 容器与 HUD 之下。
 *
 * 背景图（bg_redwood 等）是竖屏整屏美术——四周画满玉器/瓷器装饰，中央画好配套置物筐
 * （方案 A）供游戏往里叠 3D 物件。它必须等比铺满屏幕，不能当 3D 地板贴图用：地板方案下
 * 正交相机只框得住那块 44×44 平面的中心一小块纯色区域，四周装饰全被裁到画面外。
 *
 * 三层相机合成（priority 小的先渲染）：
 * - BgCamera   priority -1，SOLID_COLOR 清屏并铺满背景 Sprite（只画 UI_3D 层）
 * - MainCam    DEPTH_ONLY，3D 容器/物件画在背景之上（只画 DEFAULT 层）
 * - UICamera   DEPTH_ONLY，HUD 画在最上（只画 UI_2D 层）
 * 三者可见层互不相交，避免同一元素被两台相机重复绘制。
 */
export class SceneBackground {
    private cam: Camera;
    private canvasUT: UITransform;
    private sprite: Sprite;
    private spriteUT: UITransform;
    private currentTex = '';
    private texW = 0;
    private texH = 0;

    constructor(scene: Scene) {
        const canvasNode = new Node('BgCanvas');
        canvasNode.layer = Layers.Enum.UI_3D;
        canvasNode.setParent(scene);
        this.canvasUT = canvasNode.addComponent(UITransform);
        const canvas = canvasNode.addComponent(Canvas);

        const camNode = new Node('BgCamera');
        camNode.layer = Layers.Enum.UI_3D;
        camNode.setParent(canvasNode);
        camNode.setPosition(0, 0, 1000);
        this.cam = camNode.addComponent(Camera);
        this.cam.projection = Camera.ProjectionType.ORTHO;
        this.cam.near = 1;
        this.cam.far = 2000;
        this.cam.clearFlags = Camera.ClearFlag.SOLID_COLOR;
        this.cam.clearColor = new Color(24, 16, 13, 255); // 贴图加载前/加载失败的兜底底色
        this.cam.visibility = Layers.Enum.UI_3D;
        this.cam.priority = -1; // 最先渲染：先清屏铺底，再让主相机与 HUD 相机叠在上面
        canvas.cameraComponent = this.cam;

        const spriteNode = new Node('bgSprite');
        spriteNode.layer = Layers.Enum.UI_3D;
        spriteNode.setParent(canvasNode);
        this.spriteUT = spriteNode.addComponent(UITransform);
        this.sprite = spriteNode.addComponent(Sprite);
        this.sprite.type = Sprite.Type.SIMPLE;
        this.sprite.sizeMode = Sprite.SizeMode.CUSTOM; // 尺寸由 applyCover() 按图片比例等比铺满，不拉伸

        this.sync();
    }

    /**
     * 换肤时刷新背景。tex 为空则清掉贴图只留底色；tint 作用在 Sprite 上，
     * 现有皮肤 backdrop 均为纯白（不染色），保留染色能力供后续皮肤微调。
     */
    setBackdrop(tex: string | undefined, tint: Color) {
        this.sprite.color = tint;
        if (!tex) {
            this.sprite.spriteFrame = null;
            this.currentTex = '';
            return;
        }
        if (tex === this.currentTex && this.sprite.spriteFrame) return;
        this.currentTex = tex;
        resources.load(`textures/${tex}/texture`, Texture2D, (err, texture) => {
            if (err || !texture) {
                console.warn('[SceneBackground] 背景贴图加载失败', tex, err);
                return;
            }
            if (this.currentTex !== tex) return; // 加载期间又换肤了，丢弃过期结果
            const frame = new SpriteFrame();
            frame.texture = texture;
            this.sprite.spriteFrame = frame;
            this.texW = texture.width;
            this.texH = texture.height;
            this.applyCover();
        });
    }

    /** 屏幕尺寸变化时保持等比铺满。 */
    sync() {
        const s = view.getVisibleSize();
        if (s.width <= 0 || s.height <= 0) return;
        if (Math.abs(this.canvasUT.width - s.width) > 0.5 || Math.abs(this.canvasUT.height - s.height) > 0.5) {
            this.canvasUT.setContentSize(s.width, s.height);
        }
        if (Math.abs(this.cam.orthoHeight - s.height / 2) > 0.5) {
            this.cam.orthoHeight = s.height / 2;
        }
        this.applyCover();
    }

    /**
     * 等比铺满（cover）：按图片原始比例放大到刚好盖满屏幕，长边溢出屏外由背景相机
     * 正交视锥自然裁掉——绝不拉伸变形。贴图未加载时先按屏幕尺寸兜底。
     */
    private applyCover() {
        const s = view.getVisibleSize();
        if (s.width <= 0 || s.height <= 0) return;
        let w = s.width, h = s.height;
        if (this.texW > 0 && this.texH > 0) {
            const scale = Math.max(s.width / this.texW, s.height / this.texH);
            w = this.texW * scale;
            h = this.texH * scale;
        }
        if (Math.abs(this.spriteUT.width - w) > 0.5 || Math.abs(this.spriteUT.height - h) > 0.5) {
            this.spriteUT.setContentSize(w, h);
        }
    }
}
