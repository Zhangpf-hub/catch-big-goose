"""程序化生成「水果摊」场景的低模物件（Blender 4.5，headless）。

设计目标：一眼可辨、颜色高对比、风格统一、低面数（≤2k 三角）、纯色不透明材质。
每件归一化到最大边 = 1.0 并居中到原点，与既有管线（process_new.py）一致，
物理与拾取沿用现有约定，无需改玩法层。

用法：
  & "C:\\Program Files\\Blender Foundation\\Blender 4.5\\blender.exe" ^
     --background --python scripts\\gen_fruits.py
直接稳定覆盖 resources/models；改动后用 render_model_audit.py 生成统一视角对比图。
"""
import bpy, os, math, bmesh, sys
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = str(ROOT / "reference-projects/catch-big-goose-cocos/assets/resources/models")
os.makedirs(OUT, exist_ok=True)

# ---- 调色板（Principled Base Color，线性值；渲染后可再微调）----
C = {
    "apple_red":   (0.62, 0.03, 0.03, 1),
    "apple_blush": (0.92, 0.10, 0.035, 1),
    "leaf":        (0.13, 0.42, 0.09, 1),
    "stem_brown":  (0.24, 0.13, 0.05, 1),
    "banana":      (0.86, 0.66, 0.03, 1),
    "banana_light":(1.00, 0.84, 0.16, 1),
    "banana_tip":  (0.20, 0.15, 0.04, 1),
    "orange":      (0.85, 0.28, 0.01, 1),
    "orange_light":(1.00, 0.47, 0.025, 1),
    "grape":       (0.26, 0.07, 0.40, 1),
    "straw_red":   (0.70, 0.04, 0.08, 1),
    "straw_seed":  (0.90, 0.82, 0.30, 1),
    "pear":        (0.52, 0.60, 0.07, 1),
    "pear_light":  (0.72, 0.77, 0.16, 1),
    "lemon":       (0.90, 0.78, 0.04, 1),
    "cherry":      (0.45, 0.01, 0.06, 1),
}


def wipe():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for c in (bpy.data.meshes, bpy.data.materials, bpy.data.metaballs,
              bpy.data.curves, bpy.data.images):
        for b in list(c):
            try:
                c.remove(b)
            except Exception:
                pass


def mat(name, color, metallic=0.0, roughness=0.55):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes.get("Principled BSDF")
    b.inputs["Base Color"].default_value = color
    b.inputs["Metallic"].default_value = metallic
    b.inputs["Roughness"].default_value = roughness
    return m


def uv_sphere(seg=24, ring=14, r=1.0):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=ring, radius=r)
    o = bpy.context.active_object
    bpy.ops.object.shade_smooth()
    return o


def apply_all(o):
    bpy.context.view_layer.objects.active = o
    for m in list(o.modifiers):
        bpy.ops.object.modifier_apply(modifier=m.name)


def join(objs, name):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    o = bpy.context.active_object
    o.name = name
    return o


def normalize_export(o, name):
    """居中 + 最大边=1.0，导出 GLB。"""
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    o.location = (0, 0, 0)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    lo = Vector((min(v.co[i] for v in o.data.vertices) for i in range(3)))
    hi = Vector((max(v.co[i] for v in o.data.vertices) for i in range(3)))
    center = (lo + hi) / 2
    maxd = max(hi - lo) or 1.0
    s = 1.0 / maxd
    o.scale = (s, s, s)
    o.location = (-center.x * s, -center.y * s, -center.z * s)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, name + ".glb"),
                              export_format='GLB', use_selection=True)
    print("BUILT", name, "faces=", len(o.data.polygons))


def apply_hierarchy(objects, parents):
    """按 sculpt-spec 的 componentTree 建父子节点树。

    导出前必须建好层级，否则 GLB 里所有部件都是并列根节点：
    父件一动，子件留在原地。序列帧动画靠的就是「转父件带动子件」，
    扁平结构等于不能做动作。

    必须在归一化的 transform_apply 之后调用：先建父子再 apply，
    父件的变换会二次叠加到子件上。此刻各对象变换已是单位阵、
    几何位于世界坐标，所以取父件世界矩阵的逆做 parent inverse，子件不会跳位。
    """
    by_name = {o.name: o for o in objects}
    for child_name, parent_name in parents.items():
        child = by_name.get(child_name)
        parent = by_name.get(parent_name)
        if child is None or parent is None:
            raise SystemExit(
                "层级声明与实际部件对不上: %s -> %s；现有部件 %s"
                % (child_name, parent_name, sorted(by_name)))
        child.parent = parent
        child.matrix_parent_inverse = parent.matrix_world.inverted()
    bpy.context.view_layer.update()


def normalize_export_parts(objects, name, parents=None):
    """多部件模型统一归一化后导出，保留部件名供 Cocos 侧完整遍历 MeshRenderer。

    parents 是 {子部件名: 父部件名}，镜像该模型 sculpt-spec.json 的 componentTree。
    """
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:
        o.select_set(True)
        bpy.context.view_layer.objects.active = o
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    lo = Vector((1e9, 1e9, 1e9))
    hi = Vector((-1e9, -1e9, -1e9))
    for o in objects:
        for corner in o.bound_box:
            point = o.matrix_world @ Vector(corner)
            lo = Vector(min(lo[i], point[i]) for i in range(3))
            hi = Vector(max(hi[i], point[i]) for i in range(3))
    center = (lo + hi) / 2
    scale = 1.0 / (max(hi - lo) or 1.0)

    # 归一化必须对整套部件使用同一个中心和比例，否则果梗/叶片会在导出时与果体脱节。
    for o in objects:
        o.location = (o.location - center) * scale
        o.scale = (scale, scale, scale)
        bpy.context.view_layer.objects.active = o
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    if parents:
        apply_hierarchy(objects, parents)

    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, name + ".glb"),
                              export_format='GLB', use_selection=True)
    faces = sum(len(o.data.polygons) for o in objects if o.type == 'MESH')
    nested = sum(1 for o in objects if o.parent in objects)
    print("BUILT", name, "parts=", [o.name for o in objects], "faces=", faces,
          "nested=", nested)


def add_stem_leaf(top_z, m_stem, m_leaf, stem_r=0.06, stem_h=0.28, leaf=True):
    parts = []
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=stem_r, depth=stem_h,
                                         location=(0, 0, top_z + stem_h * 0.4))
    st = bpy.context.active_object
    bpy.ops.object.shade_smooth()
    st.rotation_euler = (math.radians(8), 0, 0)
    st.data.materials.append(m_stem)
    parts.append(st)
    if leaf:
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.16,
                                               location=(0.16, 0, top_z + stem_h * 0.5))
        lf = bpy.context.active_object
        lf.scale = (1.1, 0.5, 0.12)
        bpy.ops.object.shade_smooth()
        lf.data.materials.append(m_leaf)
        parts.append(lf)
    return parts


# ---------------- 各水果 ----------------

def make_apple():
    def smoothstep(edge0, edge1, value):
        t = min(1.0, max(0.0, (value - edge0) / (edge1 - edge0)))
        return t * t * (3.0 - 2.0 * t)

    skin = mat("apple_skin", (0.42, 0.018, 0.014, 1), roughness=0.46)
    lenticel_mat = mat("apple_lenticel", (0.35, 0.04, 0.025, 1), roughness=0.64)
    stem_mat = mat("apple_stem", (0.18, 0.07, 0.025, 1), roughness=0.70)
    stem_cut_mat = mat("apple_stem_cut", (0.38, 0.18, 0.07, 1), roughness=0.58)
    leaf_mat = mat("apple_leaf", (0.07, 0.22, 0.015, 1), roughness=0.57)
    leaf_vein_mat = mat("apple_leaf_vein", (0.16, 0.32, 0.025, 1), roughness=0.50)

    # 果皮保持单一连续材质，让五瓣起伏由真实几何和光照表达；避免分面配色或后台贴图写入造成黑块。

    def deform_body(point):
        """按设计稿连续雕出肩部、顶窝和收窄底部，避免继续从球体上贴装饰补形。"""
        x, y, z0 = point
        theta = math.atan2(y, x)
        radial_xy = math.sqrt(x * x + y * y)
        shoulder = math.exp(-((z0 - 0.28) / 0.48) ** 2)
        lower_taper = 1.0 - 0.16 * max(0.0, -z0)
        lobe_weight = 0.025 + 0.035 * max(0.0, z0) + 0.015 * max(0.0, -z0)
        lobe = 1.0 + math.cos(theta * 5.0 + 0.18) * lobe_weight
        asymmetry = 1.0 + 0.018 * math.sin(theta + 0.7) + 0.01 * z0
        x *= 0.86 * (1.0 + shoulder * 0.07) * lower_taper * lobe * asymmetry
        y *= 0.80 * (1.0 + shoulder * 0.055) * lower_taper * lobe
        z = z0 * 0.86

        # 顶窝必须是真实凹面而不是深色贴片；中心压低，五瓣肩部仍保持较高轮廓。
        if z0 > 0.48:
            top_weight = smoothstep(0.48, 0.94, z0)
            cavity = 0.27 * math.exp(-((radial_xy / 0.34) ** 2)) * top_weight
            z -= cavity

        # 底部中央略抬、五个外侧接触点略低，既呈现花萼感又保留稳定落地面。
        if z0 < -0.70:
            base_weight = smoothstep(-0.70, -0.98, z0)
            foot = -0.76 - 0.055 * (0.5 + 0.5 * math.cos(theta * 5.0 + 0.18)) * min(1.0, radial_xy / 0.45)
            z = z * (1.0 - base_weight) + foot * base_weight
        return Vector((x, y, z))

    body = uv_sphere(36, 22)
    body.name = "fruit-body"
    for vertex in body.data.vertices:
        vertex.co = deform_body(vertex.co)
    body.data.update()
    body.data.materials.append(skin)
    for poly in body.data.polygons:
        poly.use_smooth = True

    # 果皮斑点浅埋进表面，只打断高光；不能像旧版测试方案那样悬浮成凸钉。
    speckles = []
    speckle_layout = [
        (-132, 0.34), (-116, 0.12), (-102, -0.18), (-84, 0.40), (-70, 0.02),
        (-54, -0.34), (-38, 0.22), (-20, -0.08), (8, 0.30), (28, -0.26),
    ]
    for angle_deg, z0 in speckle_layout:
        theta = math.radians(angle_deg)
        ring = math.sqrt(max(0.0, 1.0 - z0 * z0))
        surface = deform_body(Vector((math.cos(theta) * ring, math.sin(theta) * ring, z0)))
        normal = surface.normalized()
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0, location=surface * 0.994)
        spot = bpy.context.active_object
        spot.name = "lenticel"
        spot.scale = (0.016, 0.016, 0.005)
        spot.rotation_mode = 'QUATERNION'
        spot.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(normal)
        spot.data.materials.append(lenticel_mat)
        speckles.append(spot)
    body = join([body] + speckles, "fruit-body")

    # 弯曲渐细果梗从顶窝内部起步，连接前提由重叠量保证，避免中间悬空。
    stem_curve = bpy.data.curves.new("appleStemCurve", 'CURVE')
    stem_curve.dimensions = '3D'
    stem_curve.bevel_depth = 0.085
    stem_curve.bevel_resolution = 2
    stem_curve.resolution_u = 4
    stem_curve.fill_mode = 'FULL'
    stem_curve.use_fill_caps = True
    spline = stem_curve.splines.new('BEZIER')
    spline.bezier_points.add(3)
    stem_points = [
        ((0.00, 0.00, 0.60), 1.08),
        ((-0.01, -0.01, 0.76), 1.00),
        ((0.02, 0.00, 0.92), 0.82),
        ((0.08, 0.02, 1.06), 0.64),
    ]
    for point, (co, radius) in zip(spline.bezier_points, stem_points):
        point.co = co
        point.radius = radius
        point.handle_left_type = point.handle_right_type = 'AUTO'
    stem = bpy.data.objects.new("stem", stem_curve)
    bpy.context.scene.collection.objects.link(stem)
    stem.data.materials.append(stem_mat)
    bpy.context.view_layer.objects.active = stem
    stem.select_set(True)
    bpy.ops.object.convert(target='MESH')
    stem = bpy.context.active_object
    for poly in stem.data.polygons:
        poly.use_smooth = True

    tangent = Vector((0.06, 0.02, 0.14)).normalized()
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.057, depth=0.028,
                                         location=(0.08, 0.02, 1.06))
    stem_cap = bpy.context.active_object
    stem_cap.name = "faceted-cut-top"
    stem_cap.rotation_mode = 'QUATERNION'
    stem_cap.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(tangent)
    stem_cap.data.materials.append(stem_cut_mat)
    stem = join([stem, stem_cap], "stem")

    # 叶片使用三列截面形成真实中折，再固化厚度；从任意角度看都不是一张平面卡片。
    path = [
        (0.04, 0.82, 0.025), (0.16, 0.90, 0.10), (0.31, 0.96, 0.16),
        (0.47, 0.97, 0.15), (0.62, 0.92, 0.095), (0.75, 0.84, 0.016),
    ]
    leaf_vertices = []
    for x, z, width in path:
        leaf_vertices.extend([
            (x, -width - 0.035, z - 0.018),
            (x, -0.035, z + 0.035),
            (x, width - 0.035, z - 0.018),
        ])
    leaf_faces = []
    for i in range(len(path) - 1):
        a = i * 3
        b = (i + 1) * 3
        leaf_faces.extend([(a, b, b + 1, a + 1), (a + 1, b + 1, b + 2, a + 2)])
    leaf_mesh = bpy.data.meshes.new("appleLeafMesh")
    leaf_mesh.from_pydata(leaf_vertices, [], leaf_faces)
    leaf_mesh.update()
    leaf = bpy.data.objects.new("leaf", leaf_mesh)
    bpy.context.scene.collection.objects.link(leaf)
    leaf.data.materials.append(leaf_mat)
    for poly in leaf.data.polygons:
        poly.use_smooth = True
    solidify = leaf.modifiers.new("leafThickness", 'SOLIDIFY')
    solidify.thickness = 0.035
    solidify.offset = 0.0
    bevel = leaf.modifiers.new("leafEdgeSoftness", 'BEVEL')
    bevel.width = 0.012
    bevel.segments = 2
    apply_all(leaf)

    vein_curve = bpy.data.curves.new("appleLeafVein", 'CURVE')
    vein_curve.dimensions = '3D'
    vein_curve.bevel_depth = 0.014
    vein_curve.bevel_resolution = 2
    vein_curve.resolution_u = 3
    vein_spline = vein_curve.splines.new('BEZIER')
    vein_spline.bezier_points.add(len(path) - 1)
    for point, (x, z, _width) in zip(vein_spline.bezier_points, path):
        point.co = (x, -0.052, z + 0.048)
        point.radius = max(0.25, 1.0 - x * 0.85)
        point.handle_left_type = point.handle_right_type = 'AUTO'
    vein = bpy.data.objects.new("leaf-midrib", vein_curve)
    bpy.context.scene.collection.objects.link(vein)
    vein.data.materials.append(leaf_vein_mat)
    bpy.context.view_layer.objects.active = vein
    vein.select_set(True)
    bpy.ops.object.convert(target='MESH')
    leaf = join([leaf, bpy.context.active_object], "leaf")

    # apple-sculpt-spec.json 的 componentTree 里 stem/leaf 的 parent 都写成 root，
    # 但同一条目的 attachment.parentSocket 分别是 crown-socket（在果体上）和
    # stem-base-socket（在果柄上）——真实连接关系是 果体 → 果柄 → 叶片。
    # parent 字段是扁平默认值（confidence 0.5），这里按 socket 建实际层级，
    # 否则转果体时果柄和叶子会留在原地。
    normalize_export_parts([body, stem, leaf], "apple",
                           parents={"stem": "fruit-body", "leaf": "stem"})


def make_banana():
    # 用弯曲曲线 + 圆管倒角 + 逐点半径，稳定得到两头尖的香蕉，弧面平躺于 XY。
    cu = bpy.data.curves.new("bananaC", 'CURVE')
    cu.dimensions = '3D'
    cu.bevel_depth = 0.30
    cu.bevel_resolution = 6
    cu.resolution_u = 6
    sp = cu.splines.new('BEZIER')
    sp.bezier_points.add(4)  # 共 5 点
    arc = [(-1.5, -0.55), (-0.85, 0.1), (0.0, 0.32), (0.85, 0.1), (1.5, -0.55)]
    rad = [0.05, 0.85, 1.0, 0.85, 0.05]  # 两端收成尖
    for i, ((x, y), r) in enumerate(zip(arc, rad)):
        bp = sp.bezier_points[i]
        bp.co = (x, y, 0)
        bp.handle_left_type = bp.handle_right_type = 'AUTO'
        bp.radius = r
    ob = bpy.data.objects.new("banana", cu)
    bpy.context.scene.collection.objects.link(ob)
    bpy.context.view_layer.objects.active = ob
    ob.select_set(True)
    bpy.ops.object.convert(target='MESH')
    ob = bpy.context.active_object
    bpy.ops.object.shade_smooth()
    ob.data.materials.append(mat("banana", C["banana"], roughness=0.45))
    parts = [ob]
    tip_mat = mat("banana_tip", C["banana_tip"], roughness=0.72)
    for x, y, tilt in [(-1.51, -0.56, -22), (1.51, -0.56, 22)]:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=0.13,
                                             location=(x, y, 0))
        tip = bpy.context.active_object
        tip.scale = (0.55, 0.45, 0.48)
        tip.rotation_euler.z = math.radians(tilt)
        tip.data.materials.append(tip_mat)
        bpy.ops.object.shade_smooth()
        parts.append(tip)
    # A thin warm ridge catches light in the game camera and prevents the fruit reading as one flat tube.
    ridge_curve = bpy.data.curves.new("bananaHighlight", 'CURVE')
    ridge_curve.dimensions = '3D'; ridge_curve.bevel_depth = 0.035; ridge_curve.bevel_resolution = 2
    ridge = ridge_curve.splines.new('BEZIER'); ridge.bezier_points.add(2)
    for point, co in zip(ridge.bezier_points, [(-0.92, 0.08, 0.25), (0, 0.34, 0.30), (0.92, 0.08, 0.25)]):
        point.co = co; point.handle_left_type = point.handle_right_type = 'AUTO'
    ridge_obj = bpy.data.objects.new("banana_highlight", ridge_curve)
    bpy.context.scene.collection.objects.link(ridge_obj)
    ridge_obj.data.materials.append(mat("banana_light", C["banana_light"], roughness=0.38))
    bpy.context.view_layer.objects.active = ridge_obj; ridge_obj.select_set(True)
    bpy.ops.object.convert(target='MESH'); parts.append(bpy.context.active_object)
    normalize_export(join(parts, "banana"), "banana")


def make_orange():
    o = uv_sphere(28, 18)
    o.scale = (1.0, 1.0, 0.94)
    apply_all(o)
    bm = bmesh.new(); bm.from_mesh(o.data)
    for v in bm.verts:
        angle = math.atan2(v.co.y, v.co.x)
        radial = 1.0 + 0.025 * math.cos(angle * 7.0) * (1.0 - abs(v.co.z))
        v.co.x *= radial; v.co.y *= radial
        if v.co.z > 0.78:
            v.co.z -= (v.co.z - 0.78) * 0.8
    bm.to_mesh(o.data); bm.free()
    o.data.materials.append(mat("orange", C["orange"], roughness=0.5))
    parts = [o] + add_stem_leaf(0.91, mat("ostem", C["stem_brown"], roughness=0.7),
                                mat("oleaf", C["leaf"], roughness=0.5), stem_r=0.05,
                                stem_h=0.22, leaf=True)
    # Sparse recessed-colour pores survive icon downsampling and break the old plastic-ball read.
    pore_mat = mat("orange_pore", (0.58, 0.13, 0.004, 1), roughness=0.68)
    for z, count, phase in [(-0.34, 5, 0.25), (0.08, 6, 0.0), (0.42, 4, 0.5)]:
        ring_r = math.sqrt(max(0.0, 1.0 - (z / 0.94) ** 2)) * 0.985
        for i in range(count):
            a = (i + phase) * math.tau / count
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.038,
                location=(math.cos(a) * ring_r, math.sin(a) * ring_r, z))
            pore = bpy.context.active_object
            pore.data.materials.append(pore_mat)
            parts.append(pore)
    o = join(parts, "orange")
    normalize_export(o, "orange")


def make_grape():
    m = bpy.data.metaballs.new("gm")
    m.resolution = 0.16; m.threshold = 0.6
    ob = bpy.data.objects.new("grapes", m)
    bpy.context.scene.collection.objects.link(ob)
    # 三角锥状串
    rows = [(-0.0, 1.7, 3), (-0.0, 1.05, 0), (0.0, 0.45, 0), (0.0, -0.1, 0)]
    layout = [
        (0, 1.75, 0), (0.42, 1.15, 0), (-0.42, 1.15, 0), (0, 1.15, 0.42),
        (0.55, 0.45, 0), (-0.55, 0.45, 0), (0, 0.45, 0.55), (0, 0.45, -0.5),
        (0.3, -0.2, 0.3), (-0.3, -0.2, -0.2), (0, -0.75, 0),
    ]
    for (x, z, y) in layout:
        e = m.elements.new()
        e.co = (x, y, z); e.radius = 0.62
    bpy.context.view_layer.objects.active = ob
    ob.select_set(True)
    bpy.ops.object.convert(target='MESH')
    ob = bpy.context.active_object
    bpy.ops.object.shade_smooth()
    ob.data.materials.append(mat("grape", C["grape"], roughness=0.3))
    parts = [ob] + add_stem_leaf(1.9, mat("gstem", C["stem_brown"]),
                                 mat("gleaf", C["leaf"]), stem_h=0.4, leaf=True)
    ob = join(parts, "grape")
    normalize_export(ob, "grape")


def make_strawberry():
    o = uv_sphere(26, 18)
    apply_all(o)
    bm = bmesh.new(); bm.from_mesh(o.data)
    for v in bm.verts:
        z = v.co.z  # -1..1
        # 归一化高度 0(底)..1(顶)，横向按二次曲线收窄成明显锥形
        h = (z + 1.0) / 2.0
        # Classic strawberry profile: narrow tip, broad shoulder, then the sphere's own top taper.
        # The older model used a near-zero bottom multiplier and became a needle; this keeps the
        # lower third rounded while preserving a clearly vertical silhouette.
        f = 0.18 + 1.00 * h ** 0.70
        # Keep the shoulder broad but make the whole berry distinctly taller than it is wide.
        # At the game's near-top-down angle this is the difference between "strawberry" and
        # "small tomato", especially once the green calyx is visible.
        v.co.x *= f * 0.84; v.co.y *= f * 0.84
        # Bottom remains pointed but no longer needle-like; top is compressed under the calyx.
        if z < 0:
            v.co.z = z * 1.58
        else:
            v.co.z = z * 0.84
    bm.to_mesh(o.data); bm.free()
    o.data.materials.append(mat("straw", C["straw_red"], roughness=0.3))
    # 绿萼：顶部一圈明显小叶 + 短梗
    leaves = []
    leaf_mat = mat("strawberry_leaf", C["leaf"], roughness=0.52)
    for i in range(6):
        a = i / 6 * math.tau
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.34,
            location=(math.cos(a) * 0.34, math.sin(a) * 0.34, 0.82))
        lf = bpy.context.active_object
        lf.scale = (1.0, 0.42, 0.14)
        lf.rotation_euler = (0, math.radians(48), a)
        bpy.ops.object.shade_smooth()
        lf.data.materials.append(leaf_mat)
        leaves.append(lf)
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.06, depth=0.3,
                                        location=(0, 0, 1.0))
    stem = bpy.context.active_object
    bpy.ops.object.shade_smooth()
    stem.data.materials.append(leaf_mat)
    leaves.append(stem)
    seed_mat = mat("strawberry_seed", C["straw_seed"], roughness=0.62)
    seeds = []
    # Place small seeds on the calculated body surface.  Computing the radius from the exact body
    # profile keeps them half-embedded instead of floating when the silhouette is tuned later.
    for z, count, phase in [(-0.62, 5, 0.0), (-0.24, 7, 0.5), (0.20, 6, 0.0)]:
        original_z = z / (1.58 if z < 0 else 0.84)
        h = (original_z + 1.0) * 0.5
        profile = (0.18 + 1.00 * h ** 0.70) * 0.84
        surface_radius = math.sqrt(max(0.0, 1.0 - original_z * original_z)) * profile
        for i in range(count):
            angle = (i + phase) / count * math.tau
            center_radius = surface_radius + 0.025
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.055,
                location=(math.cos(angle) * center_radius, math.sin(angle) * center_radius, z))
            seed = bpy.context.active_object
            seed.scale = (0.72, 0.72, 1.22)
            seed.data.materials.append(seed_mat)
            seeds.append(seed)
    o = join([o] + leaves + seeds, "strawberry")
    normalize_export(o, "strawberry")


def make_pear():
    ob = uv_sphere(28, 20)
    bm = bmesh.new(); bm.from_mesh(ob.data)
    for v in bm.verts:
        z = v.co.z
        # One continuous skin replaces the old three-lump metaball silhouette.
        radial = 0.80 - 0.30 * z + 0.12 * (1.0 - z * z)
        v.co.x *= radial; v.co.y *= radial
        v.co.z *= 1.22
        if z < -0.78:
            v.co.z += (-0.78 - z) * 0.28
    bm.to_mesh(ob.data); bm.free()
    ob.data.materials.append(mat("pear", C["pear"], roughness=0.4))
    parts = [ob] + add_stem_leaf(1.35, mat("pstem", C["stem_brown"]),
                                 mat("pleaf", C["leaf"]), stem_h=0.32, leaf=True)
    blush = uv_sphere(14, 8, r=1.0)
    blush.location = (0.46, -0.72, -0.22)
    blush.scale = (0.22, 0.065, 0.28)
    blush.rotation_euler.z = math.radians(-58 - 90)
    blush.data.materials.append(mat("pear_blush", C["pear_light"], roughness=0.46))
    parts.append(blush)
    ob = join(parts, "pear")
    normalize_export(ob, "pear")


def make_lemon():
    o = uv_sphere(26, 16)
    o.scale = (1.5, 0.92, 0.92)
    apply_all(o)
    bm = bmesh.new(); bm.from_mesh(o.data)
    for v in bm.verts:
        t = abs(v.co.x) / 1.5
        if t > 0.7:  # 两端小尖
            v.co.x *= 1.0 + (t - 0.7) * 0.8
    bm.to_mesh(o.data); bm.free()
    o.data.materials.append(mat("lemon", C["lemon"], roughness=0.5))
    leaf = mat("lemon_leaf", C["leaf"], roughness=0.5)
    parts = [o]
    tip_mat = mat("lemon_tip", (0.72, 0.58, 0.025, 1), roughness=0.64)
    for x in (-1.55, 1.55):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.12,
                                              location=(x, 0, 0))
        tip = bpy.context.active_object
        tip.scale = (0.78, 0.82, 0.82)
        tip.data.materials.append(tip_mat)
        parts.append(tip)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.25,
                                          location=(-0.72, 0.02, 0.82))
    lf = bpy.context.active_object
    lf.scale = (1.1, 0.48, 0.12); lf.rotation_euler.z = math.radians(-25)
    lf.data.materials.append(leaf); bpy.ops.object.shade_smooth(); parts.append(lf)
    normalize_export(join(parts, "lemon"), "lemon")


def make_cherry():
    balls = []
    for dx in (-0.62, 0.62):
        s = uv_sphere(22, 14, r=0.9)
        s.location = (dx, 0, -0.4)
        apply_all(s)
        s.data.materials.append(mat("cher", C["cherry"], roughness=0.28))
        balls.append(s)
    stems = []
    for dx, bend in ((-0.62, -1), (0.62, 1)):
        bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.05, depth=1.5,
            location=(dx * 0.5, 0, 0.7))
        st = bpy.context.active_object
        st.rotation_euler = (0, math.radians(20 * bend), 0)
        bpy.ops.object.shade_smooth()
        st.data.materials.append(mat("cstem%d" % bend, C["leaf"]))
        stems.append(st)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.22,
                                          location=(0, 0.04, 1.34))
    leaf = bpy.context.active_object
    leaf.scale = (1.5, 0.55, 0.12); leaf.rotation_euler.z = math.radians(18)
    leaf.data.materials.append(mat("cherry_leaf", C["leaf"], roughness=0.5))
    bpy.ops.object.shade_smooth()
    o = join(balls + stems + [leaf], "cherry")
    normalize_export(o, "cherry")


BUILDERS = [make_apple, make_banana, make_orange, make_grape,
            make_strawberry, make_pear, make_lemon, make_cherry]

requested = set()
if "--" in sys.argv:
    requested = {name.strip() for name in sys.argv[sys.argv.index("--") + 1:] if name.strip()}
for fn in BUILDERS:
    model_name = fn.__name__.removeprefix("make_")
    if requested and model_name not in requested:
        continue
    wipe()
    fn()

print("ALL DONE ->", OUT)
