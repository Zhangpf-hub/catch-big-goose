"""Generate v2 antique-theme GLB candidates with Blender 4.5.

Single-model example:

  blender --background --python tools/art/gen_antique_theme_v2.py -- tongqian

Candidates are intentionally written outside Cocos resources. Promote a GLB only after the
fixed-camera, side, and back audit views pass.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT = ROOT / "source-assets/models/candidates/v2"


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials):
        for datablock in list(datablocks):
            datablocks.remove(datablock)


def material(name: str, color: tuple[float, float, float, float], *, metalness: float,
             roughness: float) -> bpy.types.Material:
    result = bpy.data.materials.new(name)
    result.use_nodes = True
    principled = result.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Base Color"].default_value = color
    principled.inputs["Metallic"].default_value = metalness
    principled.inputs["Roughness"].default_value = roughness
    return result


def apply_modifiers(obj: bpy.types.Object) -> None:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    for modifier in list(obj.modifiers):
        bpy.ops.object.modifier_apply(modifier=modifier.name)


def join(objects: list[bpy.types.Object], name: str) -> bpy.types.Object:
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.join()
    objects[0].name = name
    return objects[0]


def bevel(obj: bpy.types.Object, width: float, segments: int = 2) -> None:
    modifier = obj.modifiers.new("edge-softness", "BEVEL")
    modifier.width = width
    modifier.segments = segments
    modifier.limit_method = "ANGLE"
    apply_modifiers(obj)


def curve_stroke(name: str, points: list[tuple[float, float]], z: float,
                 radius: float, mat: bpy.types.Material) -> bpy.types.Object:
    curve = bpy.data.curves.new(name, "CURVE")
    curve.dimensions = "3D"
    curve.resolution_u = 2
    curve.bevel_depth = radius
    curve.bevel_resolution = 2
    curve.resolution_u = 2
    spline = curve.splines.new("POLY")
    spline.points.add(len(points) - 1)
    for point, (x, y) in zip(spline.points, points):
        point.co = (x, y, z, 1.0)
    obj = bpy.data.objects.new(name, curve)
    bpy.context.scene.collection.objects.link(obj)
    obj.data.materials.append(mat)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    return bpy.context.active_object


def curve_stroke_3d(name: str, points: list[tuple[float, float, float]], radius: float,
                    mat: bpy.types.Material) -> bpy.types.Object:
    """在任意曲面方向生成粗线浮雕，适合无法投影到统一 XY 平面的装饰路径。"""
    curve = bpy.data.curves.new(name, "CURVE")
    curve.dimensions = "3D"
    curve.resolution_u = 2
    curve.bevel_depth = radius
    curve.bevel_resolution = 2
    spline = curve.splines.new("POLY")
    spline.points.add(len(points) - 1)
    for point, (x, y, z) in zip(spline.points, points):
        point.co = (x, y, z, 1.0)
    obj = bpy.data.objects.new(name, curve)
    bpy.context.scene.collection.objects.link(obj)
    obj.data.materials.append(mat)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    return bpy.context.active_object


def apply_hierarchy(objects: list[bpy.types.Object], parents: dict[str, str]) -> None:
    """按 sculpt-spec 的 componentTree 建父子节点树。

    导出前必须建好层级，否则 GLB 里所有部件都是并列根节点：
    父件一动，子件留在原地。序列帧动画靠的就是「转父件带动子件」
    （转大臂要带着小臂和手走），所以扁平结构等于不能做动作。

    必须在归一化的 transform_apply 之后调用：先建父子再 apply，
    父件的变换会二次叠加到子件上。此刻各对象变换已是单位阵、
    几何位于世界坐标，所以取父件世界矩阵的逆做 parent inverse，
    子件不会跳位。
    """
    by_name = {obj.name: obj for obj in objects}
    for child_name, parent_name in parents.items():
        child = by_name.get(child_name)
        parent = by_name.get(parent_name)
        if child is None or parent is None:
            raise SystemExit(
                f"层级声明与实际部件对不上: {child_name} -> {parent_name}；"
                f"现有部件 {sorted(by_name)}")
        child.parent = parent
        child.matrix_parent_inverse = parent.matrix_world.inverted()
    bpy.context.view_layer.update()


def normalize_export_parts(objects: list[bpy.types.Object], name: str, output: Path,
                           parents: dict[str, str] | None = None) -> None:
    """整套部件共享中心与比例，避免候选导出后凸缘、钱文和主体相互错位。

    parents 是 {子部件名: 父部件名}，镜像该模型 sculpt-spec.json 的 componentTree。
    """
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    low = Vector((1e9, 1e9, 1e9))
    high = Vector((-1e9, -1e9, -1e9))
    for obj in objects:
        for corner in obj.bound_box:
            point = obj.matrix_world @ Vector(corner)
            low = Vector(min(low[i], point[i]) for i in range(3))
            high = Vector(max(high[i], point[i]) for i in range(3))
    center = (low + high) * 0.5
    scale = 1.0 / (max(high - low) or 1.0)

    for obj in objects:
        obj.location = (obj.location - center) * scale
        obj.scale = (scale, scale, scale)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    if parents:
        apply_hierarchy(objects, parents)

    output.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.export_scene.gltf(
        filepath=str(output / f"{name}.glb"),
        export_format="GLB",
        use_selection=True,
    )
    triangles = sum(len(poly.vertices) - 2 for obj in objects for poly in obj.data.polygons)
    nested = sum(1 for obj in objects if obj.parent in objects)
    print("BUILT", name, "parts=", [obj.name for obj in objects],
          "triangles=", triangles, "nested=", nested)


def make_tongqian(output: Path) -> None:
    # 古玩铺环境反射较弱，高金属度会把铜色压成近黑；让漫反射主导颜色，凸缘仍保留金属高光。
    bronze = material("tongqian_bronze", (0.58, 0.26, 0.055, 1), metalness=0.45,
                      roughness=0.46)
    worn = material("tongqian_worn_edges", (0.86, 0.50, 0.12, 1), metalness=0.52,
                    roughness=0.36)
    dark = material("tongqian_recess", (0.28, 0.11, 0.03, 1), metalness=0.34,
                    roughness=0.66)
    patina = material("tongqian_patina", (0.045, 0.20, 0.14, 1), metalness=0.32,
                      roughness=0.76)

    # 先用真正的布尔开孔建立连续方孔隧道；旧模型的问题正是把中心顶点压低成漏斗。
    bpy.ops.mesh.primitive_cylinder_add(vertices=64, radius=1.0, depth=0.12)
    body = bpy.context.active_object
    body.name = "coin-body"
    body.data.materials.append(dark)
    bevel(body, 0.025, 3)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0))
    cutter = bpy.context.active_object
    cutter.name = "square-hole-cutter"
    cutter.scale = (0.43, 0.43, 0.40)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel(cutter, 0.035, 3)
    boolean = body.modifiers.new("true-square-through-hole", "BOOLEAN")
    boolean.operation = "DIFFERENCE"
    boolean.solver = "EXACT"
    boolean.object = cutter
    apply_modifiers(body)
    bpy.data.objects.remove(cutter, do_unlink=True)
    for polygon in body.data.polygons:
        polygon.use_smooth = True

    # 外缘使用圆管凸起控制高光，内方框由四条带倒角的实体梁构成，中心负空间始终保持开放。
    bpy.ops.mesh.primitive_torus_add(major_radius=0.87, minor_radius=0.075,
                                     major_segments=64, minor_segments=8,
                                     location=(0, 0, 0.072))
    outer_rim = bpy.context.active_object
    outer_rim.name = "outer-rim"
    outer_rim.data.materials.append(worn)
    for polygon in outer_rim.data.polygons:
        polygon.use_smooth = True

    square_parts = []
    rail_specs = [
        ((0, 0.275, 0.084), (0.56, 0.085, 0.085)),
        ((0, -0.275, 0.084), (0.56, 0.085, 0.085)),
        ((0.275, 0, 0.084), (0.085, 0.56, 0.085)),
        ((-0.275, 0, 0.084), (0.085, 0.56, 0.085)),
    ]
    for index, (location, scale) in enumerate(rail_specs):
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
        rail = bpy.context.active_object
        rail.name = f"inner-rim-{index}"
        rail.scale = scale
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        rail.data.materials.append(worn)
        bevel(rail, 0.035, 3)
        square_parts.append(rail)
    inner_rim = join(square_parts, "inner-rim")

    # 四向钱文采用原创的宽笔画浮雕，不使用可读历史文字；粗线在手机俯视画面中比细刻纹稳定。
    strokes = []
    stroke_sets = [
        [(-0.19, 0.54), (0.19, 0.54)], [(0, 0.54), (0, 0.73)],
        [(-0.16, 0.70), (0, 0.80), (0.16, 0.70)],
        [(-0.19, -0.54), (0.19, -0.54)], [(0, -0.54), (0, -0.76)],
        [(-0.17, -0.70), (0, -0.80), (0.17, -0.70)],
        [(-0.55, 0.18), (-0.73, 0.18), (-0.73, 0), (-0.55, 0), (-0.55, -0.18), (-0.73, -0.18)],
        [(0.55, 0.18), (0.73, 0.18), (0.73, 0), (0.55, 0), (0.55, -0.18), (0.73, -0.18)],
    ]
    for index, points in enumerate(stroke_sets):
        strokes.append(curve_stroke(f"glyph-stroke-{index}", points, 0.135, 0.045, bronze))
    glyphs = join(strokes, "glyph-system")

    # 绿锈只放在少量凹槽接触点，提供年代感但不把整枚铜钱染绿。
    patina_parts = []
    for index, (x, y, sx, sy) in enumerate([
        (-0.56, 0.29, 0.13, 0.025), (0.57, -0.30, 0.11, 0.022),
        (-0.29, -0.50, 0.09, 0.02), (0.31, 0.51, 0.08, 0.02),
    ]):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=6, radius=1.0,
                                             location=(x, y, 0.071))
        spot = bpy.context.active_object
        spot.name = f"patina-{index}"
        spot.scale = (sx, sy, 0.008)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        spot.data.materials.append(patina)
        patina_parts.append(spot)
    patina_marks = join(patina_parts, "patina-marks")

    # tongqian-sculpt-spec.json 里四个宏部件都直挂 root，没有嵌套关系，
    # 铜钱本身也没有可活动的部位，因此不传 parents（保持扁平是符合规格的，不是漏掉）。
    normalize_export_parts([body, outer_rim, inner_rim, glyphs, patina_marks], "tongqian", output)


def make_bracelet(output: Path) -> None:
    # 紫晶、鎏金和浅玉必须在古玩铺偏绿环境光下仍能分区，因此不用过高金属度或透明材质。
    amethyst = material("bracelet_amethyst", (0.30, 0.07, 0.50, 1), metalness=0.04,
                        roughness=0.30)
    amethyst_light = material("bracelet_amethyst_highlight", (0.50, 0.16, 0.72, 1),
                              metalness=0.03, roughness=0.25)
    antique_gold = material("bracelet_antique_gold", (0.82, 0.43, 0.075, 1),
                            metalness=0.48, roughness=0.34)
    gold_shadow = material("bracelet_gold_recess", (0.28, 0.095, 0.018, 1),
                           metalness=0.25, roughness=0.58)
    cord_mat = material("bracelet_wine_cord", (0.18, 0.012, 0.035, 1), metalness=0.0,
                        roughness=0.78)
    jade = material("bracelet_pale_jade", (0.50, 0.79, 0.61, 1), metalness=0.0,
                    roughness=0.38)

    # 绳体先建立完整闭环，珠粒之间保留少量间隙，避免旧模型缩小时重新融合成一圈球形噪点。
    bpy.ops.mesh.primitive_torus_add(major_radius=1.23, minor_radius=0.045,
                                     major_segments=48, minor_segments=6)
    cord = bpy.context.active_object
    cord.name = "elastic-cord"
    cord.data.materials.append(cord_mat)
    for polygon in cord.data.polygons:
        polygon.use_smooth = True

    beads = []
    spacers = []
    ring_radius = 1.23
    spacer_slots = {4, 8, 12}
    for index in range(16):
        angle = -math.pi / 2 + index * math.tau / 16
        x, y = ring_radius * math.cos(angle), ring_radius * math.sin(angle)
        if index == 0:
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.34,
                                                  location=(x, y, 0.015))
            focal = bpy.context.active_object
            focal.name = "focal-gold-bead"
            focal.scale = (1.08, 0.94, 0.92)
            bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
            focal.data.materials.append(antique_gold)
            beads.append(focal)
        elif index in spacer_slots:
            bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=0.15,
                                                 location=(x, y, 0))
            spacer = bpy.context.active_object
            spacer.name = f"gold-spacer-{index}"
            # 隔珠沿圆周方向略扁，正面仍保留足够的金色面积作为节奏点。
            spacer.scale = (0.78 + 0.20 * abs(math.cos(angle)),
                            0.78 + 0.20 * abs(math.sin(angle)), 0.82)
            bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
            spacer.data.materials.append(antique_gold)
            spacers.append(spacer)
        else:
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.285,
                                                  location=(x, y, 0))
            bead = bpy.context.active_object
            bead.name = f"amethyst-bead-{index:02d}"
            # 固定序列的微小比例差制造天然珠感，同时保证每次生成完全可复现。
            scale_variation = (0.97, 1.035, 1.0, 1.055, 0.985)[index % 5]
            bead.scale = (scale_variation, 1.0 / scale_variation, 0.96 + (index % 3) * 0.025)
            bead.rotation_euler[2] = index * 0.41
            bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
            bead.data.materials.append(amethyst_light if index in {2, 7, 13} else amethyst)
            beads.append(bead)

    # 主珠用原创对称云纹形成明确朝向；采用实体粗线，俯视缩小后仍可见，而非依赖法线贴图。
    motif_strokes = []
    motif_sets = [
        [(-0.21, -1.23), (-0.10, -1.14), (0.0, -1.20), (0.10, -1.14), (0.21, -1.23)],
        [(-0.18, -1.31), (-0.08, -1.25), (0.0, -1.30), (0.08, -1.25), (0.18, -1.31)],
        [(0.0, -1.08), (0.0, -1.38)],
    ]
    for index, points in enumerate(motif_sets):
        motif_strokes.append(curve_stroke(f"focal-cloud-{index}", points, 0.315, 0.025,
                                          gold_shadow))
    focal_motif = join(motif_strokes, "focal-cloud-relief")

    # 连接环和浅玉坠打破完美圆环轮廓，让手串在散落、旋转时仍有稳定的上下方向。
    bpy.ops.mesh.primitive_torus_add(major_radius=0.115, minor_radius=0.030,
                                     major_segments=20, minor_segments=6,
                                     location=(0, -1.60, 0.0))
    charm_loop = bpy.context.active_object
    charm_loop.name = "charm-loop"
    charm_loop.data.materials.append(antique_gold)

    bpy.ops.mesh.primitive_cone_add(vertices=16, radius1=0.11, radius2=0.065, depth=0.14,
                                    location=(0, -1.73, 0.0), rotation=(math.pi / 2, 0, 0))
    charm_cap = bpy.context.active_object
    charm_cap.name = "charm-cap"
    charm_cap.data.materials.append(antique_gold)
    bevel(charm_cap, 0.015, 2)

    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.25,
                                          location=(0, -1.94, -0.005))
    charm = bpy.context.active_object
    charm.name = "pale-jade-charm"
    charm.scale = (0.70, 1.08, 0.44)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    charm.data.materials.append(jade)

    normalize_export_parts(
        [cord, join(beads, "bead-system"), join(spacers, "spacer-system"), focal_motif,
         charm_loop, charm_cap, charm],
        "bracelet",
        output,
        # 镜像 bracelet-sculpt-spec.json：charm-loop 挂在 focal-bead 上，
        # jade-charm 再挂在 charm-loop 上。这样晃动挂坠时环和玉牌会跟着走。
        parents={
            "charm-loop": "focal-cloud-relief",
            "charm-cap": "charm-loop",
            "pale-jade-charm": "charm-loop",
        },
    )


def make_baoshi(output: Path) -> None:
    # 透明宝石在 Cocos 密堆环境里容易消失，使用不透明深绿基色配合多层切面明度模拟翡翠通透感。
    emerald_deep = material("baoshi_emerald_deep", (0.008, 0.075, 0.022, 1), metalness=0.02,
                            roughness=0.28)
    emerald_mid = material("baoshi_emerald_mid", (0.015, 0.20, 0.055, 1), metalness=0.015,
                           roughness=0.24)
    emerald_light = material("baoshi_emerald_highlight", (0.055, 0.39, 0.12, 1), metalness=0.01,
                             roughness=0.20)
    antique_gold = material("baoshi_antique_gold", (0.47, 0.20, 0.025, 1), metalness=0.46,
                            roughness=0.36)
    gold_recess = material("baoshi_gold_recess", (0.11, 0.025, 0.004, 1), metalness=0.20,
                           roughness=0.62)

    # 主石使用桌面、冠部、腰棱、亭部四级截面；宽桌面和深亭部比单个规则多面体更像切割宝石。
    sides = 8
    vertices = [(0.0, 0.0, 0.44)]
    levels = [
        (0.62, 0.44),
        (0.88, 0.18),
        (0.92, 0.02),
        (0.70, -0.34),
    ]
    for radius, z in levels:
        for index in range(sides):
            angle = math.pi / 8 + index * math.tau / sides
            vertices.append((radius * math.cos(angle), radius * math.sin(angle), z))
    vertices.append((0.0, 0.0, -0.48))
    bottom_index = len(vertices) - 1

    faces = []
    material_indices = []
    for index in range(sides):
        nxt = (index + 1) % sides
        faces.append((0, 1 + index, 1 + nxt))
        # 桌面必须是一整块稳定深绿，亮度变化只发生在外围冠部，避免重新读成廉价彩色三角块。
        material_indices.append(0)
    for level_index in range(len(levels) - 1):
        start = 1 + level_index * sides
        next_start = start + sides
        for index in range(sides):
            nxt = (index + 1) % sides
            faces.extend([(start + index, next_start + index, next_start + nxt),
                          (start + index, next_start + nxt, start + nxt)])
            if level_index == 0:
                material_indices.extend([2 if index in {1, 2} else 1] * 2)
            elif level_index == 1:
                material_indices.extend([1] * 2)
            else:
                material_indices.extend([0] * 2)
    last_start = 1 + (len(levels) - 1) * sides
    for index in range(sides):
        nxt = (index + 1) % sides
        faces.append((last_start + index, bottom_index, last_start + nxt))
        material_indices.append(0)

    mesh = bpy.data.meshes.new("octagonal-cut-jade-mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    gem = bpy.data.objects.new("octagonal-cut-jade", mesh)
    bpy.context.scene.collection.objects.link(gem)
    for mat in (emerald_deep, emerald_mid, emerald_light):
        mesh.materials.append(mat)
    for polygon, mat_index in zip(mesh.polygons, material_indices):
        polygon.material_index = mat_index

    # 深色八角托底只从腰棱外侧露出，提供古玩镶嵌结构而不会把物件误读成戒指。
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.04, depth=0.20,
                                        location=(0, 0, -0.20), rotation=(0, 0, math.pi / 8))
    base = bpy.context.active_object
    base.name = "octagonal-setting-base"
    base.data.materials.append(gold_recess)
    bevel(base, 0.045, 2)

    bpy.ops.mesh.primitive_torus_add(major_radius=0.945, minor_radius=0.075,
                                     major_segments=8, minor_segments=6,
                                     location=(0, 0, 0.055), rotation=(0, 0, math.pi / 8))
    bezel = bpy.context.active_object
    bezel.name = "raised-gold-bezel"
    bezel.data.materials.append(antique_gold)

    # 四爪沿对角线跨过腰棱并与托底重叠，避免只放四个悬浮金块的常见错误。
    prongs = []
    for index, angle in enumerate([math.pi / 4, 3 * math.pi / 4, 5 * math.pi / 4,
                                   7 * math.pi / 4]):
        radius = 0.82
        bpy.ops.mesh.primitive_cube_add(size=1.0,
                                        location=(radius * math.cos(angle),
                                                  radius * math.sin(angle), 0.20),
                                        rotation=(0, 0, angle))
        prong = bpy.context.active_object
        prong.name = f"protective-prong-{index}"
        prong.scale = (0.18, 0.34, 0.24)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        bevel(prong, 0.06, 3)
        prong.data.materials.append(antique_gold)
        prongs.append(prong)

    # 八枚低矮莲瓣位于托座外壁，侧视提供节奏；高度受控，不遮挡主石桌面。
    lotus_panels = []
    for index in range(sides):
        angle = index * math.tau / sides
        radius = 0.94
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0,
                                              location=(radius * math.cos(angle),
                                                        radius * math.sin(angle), -0.11))
        panel = bpy.context.active_object
        panel.name = f"lotus-panel-{index}"
        panel.scale = (0.16, 0.30, 0.075)
        panel.rotation_euler[2] = angle
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
        panel.data.materials.append(antique_gold)
        lotus_panels.append(panel)

    normalize_export_parts(
        [gem, base, bezel, join(prongs, "protective-prong-system"),
         join(lotus_panels, "lotus-setting-panels")],
        "baoshi",
        output,
        # 镜像 baoshi-sculpt-spec.json：bezel / prong-system / lotus-panels
        # 都挂在 setting-base 下，宝石本身按 spec 留在根层。
        parents={
            "raised-gold-bezel": "octagonal-setting-base",
            "protective-prong-system": "octagonal-setting-base",
            "lotus-setting-panels": "octagonal-setting-base",
        },
    )


def make_hulu(output: Path) -> None:
    # 旧版用三段扇形材质制造明暗，随机旋转后深棕扇区会整块朝向镜头，游戏里近乎发黑。
    # 改为连续蜜蜡纹理：保留明暗变化，但把最低明度抬高，并让色带跨面平滑流动。
    amber = bpy.data.materials.new("hulu_sunlit_honey_amber")
    amber.use_nodes = True
    amber_principled = amber.node_tree.nodes.get("Principled BSDF")
    amber_principled.inputs["Metallic"].default_value = 0.0
    amber_principled.inputs["Roughness"].default_value = 0.24
    if "Coat Weight" in amber_principled.inputs:
        amber_principled.inputs["Coat Weight"].default_value = 0.18
        amber_principled.inputs["Coat Roughness"].default_value = 0.16

    texture_width = 512
    texture_height = 256
    amber_image = bpy.data.images.new("hulu_continuous_honey_wax",
                                      width=texture_width, height=texture_height)
    amber_pixels = []
    amber_shadow = Vector((0.62, 0.24, 0.025))
    amber_base = Vector((0.95, 0.50, 0.080))
    amber_highlight = Vector((1.00, 0.74, 0.19))
    for y in range(texture_height):
        v = y / (texture_height - 1)
        for x in range(texture_width):
            u = x / (texture_width - 1)
            theta = u * math.tau
            flowing = (0.52 * math.sin(theta * 2.0 + v * 4.2)
                       + 0.24 * math.sin(theta * 5.0 - v * 7.0)
                       + 0.10 * math.cos(theta * 11.0 + v * 13.0))
            amount = 0.5 + 0.5 * max(-1.0, min(1.0, flowing))
            color = amber_shadow.lerp(amber_base, min(1.0, amount * 1.45))
            color = color.lerp(amber_highlight, max(0.0, amount - 0.58) * 1.45)
            # 小幅乳蜡颗粒只打散纯色，不生成会在缩略图里变脏的黑斑。
            wax = 0.018 * math.sin(theta * 19.0 + v * 31.0) * math.sin(theta * 7.0 - v * 17.0)
            amber_pixels.extend((max(0.0, min(1.0, color.x + wax)),
                                 max(0.0, min(1.0, color.y + wax)),
                                 max(0.0, min(1.0, color.z + wax)), 1.0))
    amber_image.pixels.foreach_set(amber_pixels)
    amber_image.pack()
    amber_texture = amber.node_tree.nodes.new("ShaderNodeTexImage")
    amber_texture.image = amber_image
    amber_texture.interpolation = "Linear"
    amber_texture.extension = "REPEAT"
    amber.node_tree.links.new(amber_texture.outputs["Color"],
                              amber_principled.inputs["Base Color"])

    amber_relief = material("hulu_golden_cloud_relief", (0.96, 0.52, 0.060, 1), metalness=0.12,
                            roughness=0.25)
    antique_gold = material("hulu_antique_gold", (0.78, 0.40, 0.060, 1), metalness=0.46,
                            roughness=0.32)
    vermilion = material("hulu_vermilion_cord", (0.76, 0.025, 0.008, 1), metalness=0.0,
                         roughness=0.58)
    cord_shadow = material("hulu_cord_shadow", (0.32, 0.008, 0.004, 1), metalness=0.0,
                           roughness=0.74)

    # 一张连续旋转曲面连接双肚与短腰；轮廓宽高接近，避免旧模型的两球拼接和前稿的细长瓶形。
    segments = 48
    profile = [
        (0.28, -1.45), (0.68, -1.35), (0.92, -1.05), (0.99, -0.68),
        (0.90, -0.32), (0.68, -0.08), (0.38, 0.10),  # 下肚纵向拉满，保持宽而不扁。
        (0.43, 0.18), (0.57, 0.37), (0.64, 0.60), (0.55, 0.84),
        (0.36, 1.04), (0.24, 1.13),
    ]
    vertices = []
    for ring_index, (radius, z) in enumerate(profile):
        for index in range(segments):
            angle = index * math.tau / segments
            # 八向极浅起伏打散完美球面高光，同时不把主体变成南瓜。
            rib = 1.0 + 0.018 * math.cos(8 * angle) * (0.35 if ring_index == 5 else 1.0)
            vertices.append((radius * rib * math.cos(angle),
                             radius * rib * math.sin(angle), z))
    faces = []
    for ring_index in range(len(profile) - 1):
        start = ring_index * segments
        next_start = start + segments
        for index in range(segments):
            nxt = (index + 1) % segments
            faces.extend([(start + index, next_start + index, next_start + nxt),
                          (start + index, next_start + nxt, start + nxt)])
    mesh = bpy.data.meshes.new("continuous-plump-gourd-mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    uv_layer = mesh.uv_layers.new(name="continuous-honey-wax-uv")
    ring_count = len(profile)
    for polygon in mesh.polygons:
        raw_uvs = []
        for loop_index in polygon.loop_indices:
            vertex_index = mesh.loops[loop_index].vertex_index
            raw_uvs.append(((vertex_index % segments) / segments,
                            (vertex_index // segments) / (ring_count - 1)))
        crosses_seam = max(uv[0] for uv in raw_uvs) - min(uv[0] for uv in raw_uvs) > 0.5
        for loop_index, (u, v) in zip(polygon.loop_indices, raw_uvs):
            uv_layer.data[loop_index].uv = (u + 1.0 if crosses_seam and u < 0.5 else u, v)
    body = bpy.data.objects.new("continuous-plump-amber-body", mesh)
    bpy.context.scene.collection.objects.link(body)
    mesh.materials.append(amber)
    for polygon in mesh.polygons:
        polygon.use_smooth = True

    # 稳定底面用一块低矮圆片封口，物理落地时不会依赖尖点或悬空装饰。
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.30, depth=0.035,
                                        location=(0, 0, -1.445))
    base = bpy.context.active_object
    base.name = "stable-amber-foot"
    base.data.materials.append(amber)
    bevel(base, 0.018, 2)

    # 颈口只保留细金环，拒绝前稿的厚重金属腰带和笼架。
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.31, depth=0.10,
                                        location=(0, 0, 1.14))
    neck_cap = bpy.context.active_object
    neck_cap.name = "thin-gold-neck-cap"
    neck_cap.data.materials.append(antique_gold)
    bevel(neck_cap, 0.035, 3)

    # 游戏相机近俯视，纯几何腰谷会被上肚遮住；细腰箍只强调分界，不做厚重金属腰带。
    bpy.ops.mesh.primitive_torus_add(major_radius=0.42, minor_radius=0.035,
                                     major_segments=36, minor_segments=6,
                                     location=(0, 0, 0.105))
    waist_ring = bpy.context.active_object
    waist_ring.name = "thin-gold-waist-ring"
    waist_ring.data.materials.append(antique_gold)

    # 短绳环紧贴主体，长度不会主导归一化尺寸，也不会把现有方盒碰撞代理拉成细长尾巴。
    bpy.ops.mesh.primitive_torus_add(major_radius=0.18, minor_radius=0.042,
                                     major_segments=28, minor_segments=7,
                                     location=(0, 0, 1.36), rotation=(math.pi / 2, 0, 0))
    cord_loop = bpy.context.active_object
    cord_loop.name = "compact-red-cord-loop"
    cord_loop.data.materials.append(vermilion)

    knot_parts = []
    for index, (x, z, scale_x) in enumerate([
        (-0.12, 1.22, 0.12), (0.12, 1.22, 0.12), (0.0, 1.28, 0.14), (0.0, 1.18, 0.13),
    ]):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0,
                                              location=(x, -0.015, z))
        knot = bpy.context.active_object
        knot.name = f"cord-knot-{index}"
        knot.scale = (scale_x, 0.075, 0.085)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        knot.data.materials.append(vermilion if index % 2 == 0 else cord_shadow)
        knot_parts.append(knot)
    knot_system = join(knot_parts, "compact-red-knot")

    # 同材质宽云纹使用实体粗线；路径贴近下肚正面，随机旋转时也至少保留一段可见浮雕。
    cloud_strokes = []
    cloud_paths_xz = [
        [(-0.68, -0.47), (-0.56, -0.31), (-0.37, -0.30), (-0.28, -0.44),
         (-0.38, -0.55), (-0.53, -0.50)],
        [(-0.28, -0.44), (-0.08, -0.29), (0.12, -0.36), (0.18, -0.50),
         (0.05, -0.59), (-0.11, -0.53)],
        [(0.16, -0.49), (0.35, -0.35), (0.57, -0.39), (0.67, -0.52)],
    ]
    for quarter in range(4):
        rotation = quarter * math.pi / 2
        cos_rotation = math.cos(rotation)
        sin_rotation = math.sin(rotation)
        for index, path in enumerate(cloud_paths_xz):
            points = []
            for x, z in path:
                # 下肚截面近似椭圆，先贴到正面，再绕四面复制；随机旋转时云纹不会整组消失。
                section_radius = 0.98
                y = -math.sqrt(max(0.01, section_radius ** 2 - x ** 2)) - 0.018
                points.append((x * cos_rotation - y * sin_rotation,
                               x * sin_rotation + y * cos_rotation, z))
            cloud_strokes.append(curve_stroke_3d(
                f"amber-cloud-{quarter}-{index}", points, 0.032, amber_relief))
    cloud_relief = join(cloud_strokes, "broad-amber-cloud-relief")

    normalize_export_parts(
        [body, base, neck_cap, waist_ring, cord_loop, knot_system, cloud_relief],
        "hulu",
        output,
    )


def make_yuzhuo(output: Path) -> None:
    # 首版用分面材质模拟飘花，边界会读成马赛克；改用嵌入 GLB 的连续纹理，让色根跨面平滑流动。
    jade = bpy.data.materials.new("yuzhuo_continuous_jade_marbling")
    jade.use_nodes = True
    jade_principled = jade.node_tree.nodes.get("Principled BSDF")
    jade_principled.inputs["Metallic"].default_value = 0.0
    jade_principled.inputs["Roughness"].default_value = 0.24

    texture_width = 512
    texture_height = 256
    jade_image = bpy.data.images.new("yuzhuo_white_emerald_marbling",
                                     width=texture_width, height=texture_height)
    pixels = []

    def smoothstep(edge0: float, edge1: float, value: float) -> float:
        amount = max(0.0, min(1.0, (value - edge0) / (edge1 - edge0)))
        return amount * amount * (3.0 - 2.0 * amount)

    cream_rgb = Vector((0.78, 0.75, 0.61))
    pale_rgb = Vector((0.40, 0.55, 0.29))
    emerald_rgb = Vector((0.055, 0.29, 0.070))
    for y in range(texture_height):
        phi = y * math.tau / texture_height
        for x in range(texture_width):
            theta = x * math.tau / texture_width
            broad = (0.58 * math.sin(2 * theta + 0.35)
                     + 0.30 * math.sin(5 * theta - 0.9)
                     + 0.14 * math.cos(3 * phi - theta))
            flowing = (broad + 0.12 * math.sin(13 * theta + 1.7 * math.sin(2 * phi))
                       + 0.07 * math.sin(23 * theta - 3 * phi))
            pale_amount = smoothstep(-0.18, 0.22, flowing)
            deep_amount = smoothstep(0.34, 0.78, flowing)
            color = cream_rgb.lerp(pale_rgb, pale_amount)
            color = color.lerp(emerald_rgb, deep_amount * 0.88)

            # 不叠加深色细线：在游戏缩略图里它会被误读为裂纹；只用连续色根表达天然玉纹。
            # 轻微乳白颗粒打散纯色，但幅度受控，不生成首版那种像素块。
            grain = 0.018 * math.sin(31 * theta + 17 * phi) * math.sin(19 * theta - 13 * phi)
            pixels.extend((max(0.0, min(1.0, color.x + grain)),
                           max(0.0, min(1.0, color.y + grain)),
                           max(0.0, min(1.0, color.z + grain)), 1.0))
    jade_image.pixels.foreach_set(pixels)
    jade_image.pack()
    texture_node = jade.node_tree.nodes.new("ShaderNodeTexImage")
    texture_node.image = jade_image
    texture_node.interpolation = "Linear"
    texture_node.extension = "REPEAT"
    jade.node_tree.links.new(texture_node.outputs["Color"], jade_principled.inputs["Base Color"])

    antique_gold = material("yuzhuo_antique_gold", (0.23, 0.058, 0.003, 1), metalness=0.52,
                            roughness=0.38)
    gold_highlight = material("yuzhuo_worn_gold_edge", (0.46, 0.17, 0.010, 1), metalness=0.58,
                             roughness=0.29)

    # 主环必须保持真正正圆；天然感只交给玉色纹理，避免几何起伏在固定机位下读成椭圆或变形。
    major_segments = 64
    minor_segments = 16
    vertices = []
    for major_index in range(major_segments):
        theta = major_index * math.tau / major_segments
        major_radius = 1.0
        tube_radius = 0.25
        for minor_index in range(minor_segments):
            phi = minor_index * math.tau / minor_segments
            polished = 1.0
            local_radius = tube_radius * polished
            vertices.append(((major_radius + local_radius * math.cos(phi)) * math.cos(theta),
                             (major_radius + local_radius * math.cos(phi)) * math.sin(theta),
                             local_radius * math.sin(phi)))

    faces = []
    for major_index in range(major_segments):
        next_major = (major_index + 1) % major_segments
        for minor_index in range(minor_segments):
            next_minor = (minor_index + 1) % minor_segments
            a = major_index * minor_segments + minor_index
            b = next_major * minor_segments + minor_index
            c = next_major * minor_segments + next_minor
            d = major_index * minor_segments + next_minor
            faces.extend([(a, b, c), (a, c, d)])

    mesh = bpy.data.meshes.new("hand-polished-jade-bangle-mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    uv_layer = mesh.uv_layers.new(name="continuous-marble-uv")
    for polygon in mesh.polygons:
        raw_uvs = []
        for loop_index in polygon.loop_indices:
            vertex_index = mesh.loops[loop_index].vertex_index
            raw_uvs.append((vertex_index // minor_segments / major_segments,
                            vertex_index % minor_segments / minor_segments))
        seam_u = max(uv[0] for uv in raw_uvs) - min(uv[0] for uv in raw_uvs) > 0.5
        seam_v = max(uv[1] for uv in raw_uvs) - min(uv[1] for uv in raw_uvs) > 0.5
        for loop_index, (u, v) in zip(polygon.loop_indices, raw_uvs):
            uv_layer.data[loop_index].uv = ((u + 1.0 if seam_u and u < 0.5 else u),
                                            (v + 1.0 if seam_v and v < 0.5 else v))
    body = bpy.data.objects.new("plump-white-and-emerald-jade-bangle", mesh)
    bpy.context.scene.collection.objects.link(body)
    mesh.materials.append(jade)
    for polygon in mesh.polygons:
        polygon.use_smooth = True

    # 金缮环真正包住圆条截面，不用悬浮贴片；位置偏左上，固定俯视与随机旋转都能形成识别点。
    clasp_theta = math.radians(148)
    clasp_center = Vector((math.cos(clasp_theta), math.sin(clasp_theta), 0.0))
    tangent = Vector((-math.sin(clasp_theta), math.cos(clasp_theta), 0.0))
    bpy.ops.mesh.primitive_torus_add(major_radius=0.30, minor_radius=0.026,
                                     major_segments=28, minor_segments=6,
                                     location=clasp_center)
    collar = bpy.context.active_object
    collar.name = "gold-repair-collar"
    collar.rotation_mode = "QUATERNION"
    collar.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(tangent)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    collar.data.materials.append(antique_gold)

    # 四瓣云扣由一组相互重叠的低矮实体构成，并增加较小亮边层，避免三瓣布局读成蝴蝶结。
    cloud_parts = []
    cloud_highlights = []
    radial = Vector((math.cos(clasp_theta), math.sin(clasp_theta), 0.0))
    plaque_center = clasp_center + radial * 0.04 + Vector((0, 0, 0.295))
    for index, (along_tangent, along_radial, sx, sy) in enumerate([
        (-0.115, 0.0, 0.16, 0.14), (0.115, 0.0, 0.16, 0.14),
        (0.0, 0.09, 0.17, 0.15), (0.0, -0.085, 0.17, 0.15),
    ]):
        location = plaque_center + tangent * along_tangent + radial * along_radial
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0, location=location)
        lobe = bpy.context.active_object
        lobe.name = f"cloud-clasp-lobe-{index}"
        lobe.scale = (sx, sy, 0.045)
        lobe.rotation_euler[2] = clasp_theta
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
        lobe.data.materials.append(antique_gold)
        cloud_parts.append(lobe)

        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0,
                                              location=location + Vector((0, 0, 0.035)))
        highlight = bpy.context.active_object
        highlight.name = f"cloud-clasp-highlight-{index}"
        highlight.scale = (sx * 0.52, sy * 0.52, 0.020)
        highlight.rotation_euler[2] = clasp_theta
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
        highlight.data.materials.append(gold_highlight)
        cloud_highlights.append(highlight)

    normalize_export_parts(
        [body, collar, join(cloud_parts, "four-lobed-cloud-clasp"),
         join(cloud_highlights, "worn-cloud-clasp-highlight")],
        "yuzhuo",
        output,
    )


def make_banzhi(output: Path) -> None:
    # 浅青蓝玉、乳白云雾和蜜糖皮色写入同一张连续贴图，避免古玩铺连续出现深绿色单色块。
    jade = bpy.data.materials.new("banzhi_celadon_honey_jade")
    jade.use_nodes = True
    principled = jade.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Metallic"].default_value = 0.0
    principled.inputs["Roughness"].default_value = 0.34
    # 玉的“润”来自浅层散射而非镜面清漆；少量次表面让背光边缘泛白，同时避免塑料高光。
    if "Subsurface Weight" in principled.inputs:
        principled.inputs["Subsurface Weight"].default_value = 0.16
        principled.inputs["Subsurface Radius"].default_value = (0.72, 1.0, 0.86)
        principled.inputs["Subsurface Scale"].default_value = 0.11
    if "Coat Weight" in principled.inputs:
        principled.inputs["Coat Weight"].default_value = 0.07
        principled.inputs["Coat Roughness"].default_value = 0.24
    width, height = 512, 256
    image = bpy.data.images.new("banzhi_celadon_honey_texture", width=width, height=height)
    rough_image = bpy.data.images.new("banzhi_jade_roughness", width=width, height=height)
    normal_image = bpy.data.images.new("banzhi_jade_micro_normal", width=width, height=height)
    aqua = Vector((0.48, 0.78, 0.73))
    cream = Vector((0.79, 0.90, 0.84))
    turquoise = Vector((0.12, 0.55, 0.51))
    honey = Vector((0.82, 0.48, 0.13))
    pixels = []
    rough_pixels = []
    normal_pixels = []

    def ss(a: float, b: float, value: float) -> float:
        amount = max(0.0, min(1.0, (value - a) / (b - a)))
        return amount * amount * (3.0 - 2.0 * amount)

    def stone_field(u: float, v: float) -> float:
        """多频低振幅场模拟棉絮和色根；只影响表面响应，不生成会读成裂纹的深色线。"""
        return (0.50
                + 0.23 * math.sin(math.tau * (2.1 * u + 0.28 * math.sin(math.tau * v)))
                + 0.13 * math.sin(math.tau * (5.2 * u - 1.7 * v + 0.1 * math.sin(math.tau * 3 * u)))
                + 0.08 * math.sin(math.tau * (11 * u + 7 * v)))

    for y in range(height):
        v = y / (height - 1)
        for x in range(width):
            u = x / width
            field = stone_field(u, v)
            cloudy = ss(0.38, 0.68, field) * (0.45 + 0.25 * math.sin(math.tau * 3 * v) ** 2)
            color = aqua.lerp(cream, cloudy)
            teal_field = 0.5 + 0.5 * math.sin(math.tau * (3.1 * u - 0.8 * v + 0.13 * field))
            teal = ss(0.62, 0.90, teal_field)
            color = color.lerp(turquoise, teal * 0.20)
            # 糖色是侧面局部沁色而不是整圈深色底座：用环向软遮罩切断连续色带，保持玉体轻盈。
            patch_center = 0.13
            circular_distance = abs(((u - patch_center + 0.5) % 1.0) - 0.5)
            side_patch = 1.0 - ss(0.14, 0.32, circular_distance)
            honey_line = 0.42 + 0.08 * math.sin(math.tau * (1.3 * u + 0.12))
            vertical_patch = ss(0.12, 0.24, v) * (1.0 - ss(honey_line, honey_line + 0.13, v))
            honey_mask = side_patch * vertical_patch
            color = color.lerp(honey, honey_mask * 0.72)
            # 斜口是最强识别面，保持明确浅青而不是过曝乳白。
            color = color.lerp(aqua, ss(0.78, 1.0, v) * 0.34)
            grain = 0.022 * math.sin(math.tau * (17 * u + 11 * v)) * math.sin(math.tau * (9 * u - 13 * v))
            pixels.extend((max(0.0, min(1.0, color.x + grain)),
                           max(0.0, min(1.0, color.y + grain)),
                           max(0.0, min(1.0, color.z + grain)), 1.0))
            roughness = 0.30 + 0.10 * (1.0 - ss(0.34, 0.75, field)) + 0.06 * honey_mask
            rough_pixels.extend((roughness, roughness, roughness, 1.0))
            du = (stone_field(u + 1.0 / width, v) - stone_field(u - 1.0 / width, v)) * 2.2
            dv = (stone_field(u, v + 1.0 / height) - stone_field(u, v - 1.0 / height)) * 2.2
            normal = Vector((-du, -dv, 1.0)).normalized()
            normal_pixels.extend((normal.x * 0.5 + 0.5, normal.y * 0.5 + 0.5,
                                  normal.z * 0.5 + 0.5, 1.0))
    image.pixels.foreach_set(pixels)
    rough_image.pixels.foreach_set(rough_pixels)
    normal_image.pixels.foreach_set(normal_pixels)
    image.pack()
    rough_image.pack()
    normal_image.pack()
    tex = jade.node_tree.nodes.new("ShaderNodeTexImage")
    tex.image = image
    tex.interpolation = "Linear"
    tex.extension = "REPEAT"
    jade.node_tree.links.new(tex.outputs["Color"], principled.inputs["Base Color"])
    # 游戏固定顶光会让厚戒体下缘失去全部色相；复用玉色贴图作极弱自发光，仅托起暗部，模拟透光而非发光体。
    if "Emission Color" in principled.inputs:
        jade.node_tree.links.new(tex.outputs["Color"], principled.inputs["Emission Color"])
        principled.inputs["Emission Strength"].default_value = 0.12
    rough_tex = jade.node_tree.nodes.new("ShaderNodeTexImage")
    rough_tex.image = rough_image
    rough_tex.image.colorspace_settings.name = "Non-Color"
    rough_tex.interpolation = "Linear"
    jade.node_tree.links.new(rough_tex.outputs["Color"], principled.inputs["Roughness"])
    normal_tex = jade.node_tree.nodes.new("ShaderNodeTexImage")
    normal_tex.image = normal_image
    normal_tex.image.colorspace_settings.name = "Non-Color"
    normal_tex.interpolation = "Linear"
    normal_map = jade.node_tree.nodes.new("ShaderNodeNormalMap")
    normal_map.inputs["Strength"].default_value = 0.12
    jade.node_tree.links.new(normal_tex.outputs["Color"], normal_map.inputs["Color"])
    jade.node_tree.links.new(normal_map.outputs["Normal"], principled.inputs["Normal"])

    relief_jade = material("banzhi_turquoise_relief", (0.055, 0.37, 0.34, 1), metalness=0.0,
                           roughness=0.34)
    gold = material("banzhi_warm_gold_liner", (0.72, 0.52, 0.24, 1), metalness=0.34,
                    roughness=0.52)
    worn_gold = material("banzhi_worn_gold_accents", (0.73, 0.40, 0.055, 1), metalness=0.56,
                         roughness=0.32)

    segments = 64
    vertices = []
    for index in range(segments):
        theta = index * math.tau / segments
        top_z = 0.54 + 0.14 * math.cos(theta)
        vertices.extend([
            (0.79 * math.cos(theta), 0.79 * math.sin(theta), -0.64),
            (0.86 * math.cos(theta), 0.86 * math.sin(theta), top_z),
            (0.47 * math.cos(theta), 0.47 * math.sin(theta), -0.60),
            (0.50 * math.cos(theta), 0.50 * math.sin(theta), top_z - 0.055),
        ])
    faces = []
    for index in range(segments):
        nxt = (index + 1) % segments
        a, b, c, d = index * 4, index * 4 + 1, index * 4 + 2, index * 4 + 3
        na, nb, nc, nd = nxt * 4, nxt * 4 + 1, nxt * 4 + 2, nxt * 4 + 3
        faces.extend([(a, na, nb), (a, nb, b), (c, d, nd), (c, nd, nc),
                      (b, nb, nd), (b, nd, d), (a, c, nc), (a, nc, na)])
    mesh = bpy.data.meshes.new("sloped-open-thumb-ring-mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    uv_layer = mesh.uv_layers.new(name="banzhi-wrapped-uv")
    for polygon in mesh.polygons:
        raw = []
        for loop_index in polygon.loop_indices:
            vertex_index = mesh.loops[loop_index].vertex_index
            u = (vertex_index // 4) / segments
            kind = vertex_index % 4
            v = 0.0 if kind in {0, 2} else 1.0
            raw.append((u, v))
        seam = max(u for u, _ in raw) - min(u for u, _ in raw) > 0.5
        for loop_index, (u, v) in zip(polygon.loop_indices, raw):
            uv_layer.data[loop_index].uv = (u + 1.0 if seam and u < 0.5 else u, v)
    body = bpy.data.objects.new("celadon-sloped-thumb-ring-body", mesh)
    bpy.context.scene.collection.objects.link(body)
    mesh.materials.append(jade)
    for polygon in mesh.polygons:
        polygon.use_smooth = True

    # 金内衬只覆盖内壁和开口薄缘，保留真实通孔，不用封口圆片制造假洞。
    liner_vertices = []
    for index in range(segments):
        theta = index * math.tau / segments
        top_z = 0.54 + 0.14 * math.cos(theta) - 0.065
        liner_vertices.extend([(0.465 * math.cos(theta), 0.465 * math.sin(theta), -0.57),
                               (0.465 * math.cos(theta), 0.465 * math.sin(theta), top_z),
                               (0.505 * math.cos(theta), 0.505 * math.sin(theta), top_z)])
    liner_faces = []
    for index in range(segments):
        nxt = (index + 1) % segments
        a, b, c = index * 3, index * 3 + 1, index * 3 + 2
        na, nb, nc = nxt * 3, nxt * 3 + 1, nxt * 3 + 2
        liner_faces.extend([(a, b, nb), (a, nb, na), (b, c, nc), (b, nc, nb)])
    liner_mesh = bpy.data.meshes.new("open-gold-liner-mesh")
    liner_mesh.from_pydata(liner_vertices, [], liner_faces)
    liner_mesh.update()
    liner = bpy.data.objects.new("warm-gold-inner-liner", liner_mesh)
    bpy.context.scene.collection.objects.link(liner)
    liner_mesh.materials.append(gold)
    for polygon in liner_mesh.polygons:
        polygon.use_smooth = True

    # 山云纹贴合面向游戏相机的外壁；粗玉色主线保证缩略图可读，金色只磨亮山脊高边。
    relief_paths = [
        [(-0.58, -0.16), (-0.34, 0.09), (-0.16, -0.05)],
        [(-0.20, -0.02), (0.02, 0.27), (0.25, -0.03)],
        [(0.18, -0.02), (0.40, 0.16), (0.60, -0.10)],
        [(-0.62, -0.25), (-0.48, -0.15), (-0.34, -0.24), (-0.20, -0.15), (-0.05, -0.26)],
        [(-0.05, -0.28), (0.12, -0.17), (0.28, -0.27), (0.44, -0.17), (0.62, -0.25)],
    ]
    # 两朵卷云用收缩螺旋而不是折线，和上方三座山峰形成明确的山云层级。
    for center_x in (-0.38, 0.38):
        spiral = []
        for step in range(13):
            angle = step * math.tau / 5.8
            radius = 0.15 * (1.0 - step / 16.0)
            spiral.append((center_x + radius * math.cos(angle),
                           -0.20 + radius * 0.62 * math.sin(angle)))
        relief_paths.append(spiral)
    relief_parts = []
    camera_radial = Vector((0.59, -0.81, 0.0))
    camera_tangent = Vector((0.81, 0.59, 0.0))
    for index, path in enumerate(relief_paths):
        points = []
        for x, z in path:
            position = camera_radial * (math.sqrt(max(0.01, 0.81 ** 2 - x ** 2)) + 0.022)
            position += camera_tangent * x
            points.append((position.x, position.y, z))
        relief_parts.append(curve_stroke_3d(f"mountain-cloud-relief-{index}", points, 0.044,
                                            relief_jade))
    gold_paths = [relief_paths[0], relief_paths[1], relief_paths[2]]
    gold_parts = []
    for index, path in enumerate(gold_paths):
        points = []
        for x, z in path:
            position = camera_radial * (math.sqrt(max(0.01, 0.81 ** 2 - x ** 2)) + 0.068)
            position += camera_tangent * x
            points.append((position.x, position.y, z + 0.012))
        gold_parts.append(curve_stroke_3d(f"worn-gold-ridge-{index}", points, 0.013,
                                          worn_gold))

    normalize_export_parts(
        [body, liner, join(relief_parts, "broad-mountain-cloud-relief"),
         join(gold_parts, "restrained-worn-gold-ridges")],
        "banzhi",
        output,
    )


def make_yuxi(output: Path) -> None:
    # 玉玺采用暖白、朱砂、古金三段配色，与前一件浅青玉扳指拉开明度和色相差异。
    ivory = material("yuxi_warm_white_nephrite", (0.78, 0.69, 0.49, 1), metalness=0.0,
                     roughness=0.31)
    ivory_light = material("yuxi_milky_jade_highlight", (0.96, 0.86, 0.65, 1), metalness=0.0,
                           roughness=0.27)
    cinnabar = material("yuxi_cinnabar_carving", (0.58, 0.055, 0.018, 1), metalness=0.0,
                        roughness=0.48)
    gold = material("yuxi_antique_champagne_gold", (0.65, 0.34, 0.065, 1), metalness=0.46,
                    roughness=0.40)
    dark_gold = material("yuxi_gold_recess", (0.28, 0.095, 0.012, 1), metalness=0.30,
                         roughness=0.58)

    def rounded_cube(name: str, location: tuple[float, float, float],
                     scale: tuple[float, float, float], mat: bpy.types.Material,
                     bevel_width: float) -> bpy.types.Object:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
        obj = bpy.context.active_object
        obj.name = name
        obj.scale = scale
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        obj.data.materials.append(mat)
        # 主体需要圆润三段倒角；微型回纹只用单段，避免几十个小块无意义推高移动端面数。
        bevel(obj, bevel_width, 3 if bevel_width >= 0.03 else 1)
        return obj

    def jade_blob(name: str, location: tuple[float, float, float],
                  scale: tuple[float, float, float], mat: bpy.types.Material = ivory,
                  subdivisions: int = 2, rotation_z: float = 0.0) -> bpy.types.Object:
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1.0,
                                              location=location)
        obj = bpy.context.active_object
        obj.name = name
        obj.scale = scale
        obj.rotation_euler[2] = rotation_z
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
        obj.data.materials.append(mat)
        for polygon in obj.data.polygons:
            polygon.use_smooth = True
        return obj

    # 方印主体以一体圆角厚块为主，肩台和朱砂印面提供清晰的上下方向。
    body = rounded_cube("warm-white-jade-seal-body", (0, 0, 0), (0.92, 0.92, 0.80),
                        ivory, 0.12)
    shoulder = rounded_cube("raised-jade-shoulder", (0, 0, 0.45), (0.72, 0.72, 0.10),
                            ivory_light, 0.055)
    stamp_face = rounded_cube("cinnabar-stamp-face", (0, 0, -0.425), (0.82, 0.82, 0.045),
                              cinnabar, 0.035)

    # 朱砂回纹带采用短实体块构成，不依赖不可读的小字；四面旋转后仍然保持印章识别。
    band_parts = []
    for side in range(4):
        angle = side * math.pi / 2
        outward = Vector((math.cos(angle), math.sin(angle), 0))
        tangent = Vector((-math.sin(angle), math.cos(angle), 0))
        for slot in range(-2, 3):
            center = outward * 0.47 + tangent * (slot * 0.17)
            part = rounded_cube(f"cinnabar-meander-{side}-{slot}",
                                (center.x, center.y, -0.01 + 0.045 * ((slot + side) % 2)),
                                (0.018 if side % 2 == 0 else 0.11,
                                 0.11 if side % 2 == 0 else 0.018, 0.045), cinnabar, 0.012)
            band_parts.append(part)
        upper = rounded_cube(f"cinnabar-band-upper-{side}",
                             (outward.x * 0.47, outward.y * 0.47, 0.10),
                             (0.018 if side % 2 == 0 else 0.82,
                              0.82 if side % 2 == 0 else 0.018, 0.018), cinnabar, 0.008)
        lower = rounded_cube(f"cinnabar-band-lower-{side}",
                             (outward.x * 0.47, outward.y * 0.47, -0.12),
                             (0.018 if side % 2 == 0 else 0.82,
                              0.82 if side % 2 == 0 else 0.018, 0.018), cinnabar, 0.008)
        band_parts.extend([upper, lower])

    # 瑞兽沿画面横向伏卧，直接用头、颈、胸、背、臀的连续比例建立侧影，不再用圆壳代替身体。
    camera_front = Vector((0.59, -0.81, 0))
    screen_axis = Vector((0.81, 0.59, 0))
    beast_forward = -screen_axis
    beast_side = camera_front
    beast_angle = math.atan2(beast_forward.y, beast_forward.x)
    beast_parts = [
        jade_blob("guardian-arched-torso", (0.04, 0, 0.79), (0.43, 0.23, 0.21), ivory,
                  2, beast_angle),
        jade_blob("guardian-raised-chest", tuple(beast_forward * 0.20 + Vector((0, 0, 0.82))),
                  (0.19, 0.18, 0.28), ivory_light, 2, beast_angle),
        jade_blob("guardian-rear-haunch", tuple(-beast_forward * 0.25 + Vector((0, 0, 0.74))),
                  (0.24, 0.21, 0.23), ivory, 2, beast_angle),
    ]
    head_center = beast_forward * 0.38 + Vector((0, 0, 0.99))
    beast_parts.append(jade_blob("guardian-dragon-head", tuple(head_center), (0.25, 0.18, 0.19),
                                 ivory_light, 2, beast_angle))
    snout_center = head_center + beast_forward * 0.20 + Vector((0, 0, -0.035))
    beast_parts.append(jade_blob("guardian-long-snout", tuple(snout_center), (0.18, 0.12, 0.085),
                                 ivory_light, 1, beast_angle))
    jaw_center = snout_center - Vector((0, 0, 0.082)) - beast_forward * 0.01
    beast_parts.append(jade_blob("guardian-lower-jaw", tuple(jaw_center), (0.15, 0.105, 0.06),
                                 ivory, 1, beast_angle))

    # 鬃瓣沿后脑到肩部形成连续锯齿剪影，保留参考稿最重要的龙首层次。
    for index in range(7):
        mane_pos = head_center - beast_forward * (0.10 + index * 0.045)
        mane_pos += beast_side * 0.015 + Vector((0, 0, 0.15 - index * 0.035))
        beast_parts.append(jade_blob(f"guardian-mane-lobe-{index}", tuple(mane_pos),
                                     (0.105, 0.065, 0.12), ivory_light, 1, beast_angle))

    # 四足分出远近层，近侧两足再加三趾，保证不是身体下方四颗散球。
    for forward_index, along in enumerate((0.22, -0.24)):
        for side_index, lateral in enumerate((-0.15, 0.19)):
            pos = beast_forward * along + beast_side * lateral + Vector((0, 0, 0.60))
            paw_scale = (0.17, 0.105, 0.10) if lateral > 0 else (0.14, 0.085, 0.085)
            beast_parts.append(jade_blob(f"guardian-paw-{forward_index}-{side_index}", tuple(pos),
                                         paw_scale, ivory_light if lateral > 0 else ivory, 1,
                                         beast_angle))
            if lateral > 0:
                for toe in (-1, 0, 1):
                    toe_pos = pos + beast_forward * 0.10 + beast_side * (toe * 0.032)
                    beast_parts.append(jade_blob(f"guardian-toe-{forward_index}-{toe}", tuple(toe_pos),
                                                 (0.045, 0.03, 0.035), ivory_light, 1,
                                                 beast_angle))

    horn_parts = []
    for sign in (-1, 1):
        base = head_center + beast_side * (0.085 * sign) + Vector((0, 0, 0.13))
        horn_path = []
        for step in range(9):
            t = step / 8
            point = base - beast_forward * (0.30 * t)
            point += beast_side * (0.055 * sign * t)
            point.z += 0.16 * math.sin(math.pi * t) + 0.04 * t
            horn_path.append(tuple(point))
        horn_parts.append(curve_stroke_3d(
            f"guardian-swept-horn-{sign}",
            horn_path,
            0.032, ivory_light))

    # 大卷尾位于侧影后端并在竖直平面内盘卷，正面机位不会再被身体遮没。
    rear = -beast_forward * 0.37 + beast_side * 0.04 + Vector((0, 0, 0.76))
    tail_points = []
    for step in range(17):
        angle = step * math.tau / 7.0
        radius = 0.25 * (1.0 - step / 21.0)
        point = rear + beast_forward * (radius * math.cos(angle))
        point.z += 0.05 + radius * math.sin(angle)
        tail_points.append(tuple(point))
    horn_parts.append(curve_stroke_3d("guardian-large-curled-tail", tail_points, 0.05,
                                      ivory_light))
    # 可见侧的卷鬃、背脊和肩胛云纹用实体浅浮雕建立雕刻层次，不能只靠一块光滑椭球冒充瑞兽。
    visible_surface = beast_side * 0.205
    crest_points = []
    for step in range(9):
        t = step / 8
        point = beast_forward * (0.22 - 0.48 * t) + visible_surface
        point.z = 0.96 - 0.17 * t + 0.055 * math.sin(math.pi * t)
        crest_points.append(tuple(point))
    horn_parts.append(curve_stroke_3d("guardian-back-crest", crest_points, 0.023, gold))
    for index, (along, height, radius) in enumerate(((0.18, 0.85, 0.105),
                                                     (-0.10, 0.80, 0.12),
                                                     (-0.28, 0.77, 0.09))):
        spiral = []
        center = beast_forward * along + visible_surface + Vector((0, 0, height))
        for step in range(13):
            angle = step * math.tau / 5.8
            current_radius = radius * (1.0 - step / 16.0)
            point = center + beast_forward * (current_radius * math.cos(angle))
            point.z += current_radius * 0.72 * math.sin(angle)
            spiral.append(tuple(point))
        horn_parts.append(curve_stroke_3d(f"guardian-carved-cloud-{index}", spiral, 0.018,
                                          ivory_light))
    for index, lift in enumerate((-0.075, 0.0, 0.075)):
        beard_start = jaw_center + beast_side * 0.115 - beast_forward * 0.02 + Vector((0, 0, lift))
        beard_path = [tuple(beard_start),
                      tuple(beard_start - beast_forward * 0.09 - Vector((0, 0, 0.08))),
                      tuple(beard_start - beast_forward * 0.17 + Vector((0, 0, -0.035 + lift * 0.2)))]
        horn_parts.append(curve_stroke_3d(f"guardian-beard-lock-{index}", beard_path, 0.017,
                                          ivory_light))

    # 眉脊、眼、鼻、嘴和双须集中在可见侧面，少量深金线定义龙首而不制造玩具红眼。
    eye_parts = []
    visible_side = beast_side * 0.185
    eye_pos = head_center + beast_forward * 0.10 + visible_side + Vector((0, 0, 0.045))
    eye_parts.append(jade_blob("guardian-visible-eye", tuple(eye_pos), (0.034, 0.026, 0.032),
                               cinnabar, 1))
    brow_start = eye_pos - beast_forward * 0.08 + Vector((0, 0, 0.045))
    brow_end = eye_pos + beast_forward * 0.09 + Vector((0, 0, 0.025))
    eye_parts.append(curve_stroke_3d("guardian-brow-ridge", [tuple(brow_start), tuple(brow_end)],
                                     0.018, gold))
    nose_pos = snout_center + beast_forward * 0.16 + beast_side * 0.115 + Vector((0, 0, 0.005))
    eye_parts.append(jade_blob("guardian-nose", tuple(nose_pos), (0.026, 0.022, 0.022),
                               dark_gold, 1))
    mouth_start = jaw_center + beast_forward * 0.01 + beast_side * 0.12
    mouth_end = mouth_start + beast_forward * 0.11
    eye_parts.append(curve_stroke_3d("guardian-mouth-line", [tuple(mouth_start), tuple(mouth_end)],
                                     0.012, dark_gold))
    for whisker_index, lift in enumerate((0.025, -0.025)):
        start = snout_center + beast_forward * 0.08 + beast_side * 0.115 + Vector((0, 0, lift))
        eye_parts.append(curve_stroke_3d(
            f"guardian-whisker-{whisker_index}",
            [tuple(start), tuple(start + beast_forward * 0.16 + Vector((0, 0, lift * 1.4))),
             tuple(start + beast_forward * 0.25 + Vector((0, 0, lift * 0.4)))],
            0.009, gold))

    # 云座以连续金色方环和四个卷云节点承托兽钮，控制金色面积避免喧宾夺主。
    collar_parts = []
    ring_path = [(-0.36, -0.36), (0.36, -0.36), (0.36, 0.36), (-0.36, 0.36), (-0.36, -0.36)]
    collar_parts.append(curve_stroke("gold-cloud-collar-ring", ring_path, 0.535, 0.045, gold))
    for corner_x, corner_y in ((-0.3, -0.3), (0.3, -0.3), (0.3, 0.3), (-0.3, 0.3)):
        spiral = []
        for step in range(11):
            angle = step * math.tau / 5.2
            radius = 0.13 * (1.0 - step / 14.0)
            spiral.append((corner_x + radius * math.cos(angle),
                           corner_y + radius * math.sin(angle)))
        collar_parts.append(curve_stroke(f"gold-cloud-curl-{corner_x}-{corner_y}",
                                         spiral, 0.55, 0.036, dark_gold))

    beast_body = join(beast_parts, "warm-jade-guardian-beast")
    # 头颈胸背和四足先体素融合成连续玉雕，再减面回到移动端预算；避免球体交界线破坏雕塑感。
    bpy.context.view_layer.objects.active = beast_body
    beast_body.select_set(True)
    beast_body.data.remesh_voxel_size = 0.022
    bpy.ops.object.voxel_remesh()
    decimate = beast_body.modifiers.new("mobile-sculpt-decimation", "DECIMATE")
    decimate.ratio = 0.36
    apply_modifiers(beast_body)
    for polygon in beast_body.data.polygons:
        polygon.use_smooth = True

    normalize_export_parts(
        [body, shoulder, stamp_face, join(band_parts, "cinnabar-meander-band"),
         beast_body,
         join(horn_parts, "guardian-horns-and-tail"), join(eye_parts, "cinnabar-eyes"),
         join(collar_parts, "antique-gold-cloud-collar")],
        "yuxi",
        output,
    )


def make_yuxi_from_scan(output: Path) -> None:
    """Build the yuxi around the licensed, game-optimized guardian-lion scan."""
    jade = material("yuxi_honey_yellow_nephrite", (0.52, 0.30, 0.070, 1), metalness=0.0,
                    roughness=0.28)
    pale_jade = material("yuxi_light_honey_jade", (0.80, 0.55, 0.22, 1),
                         metalness=0.0, roughness=0.25)
    lion_jade = material("yuxi_warm_ivory_lion", (0.91, 0.75, 0.47, 1),
                         metalness=0.0, roughness=0.23)
    cinnabar = material("yuxi_cinnabar_inlay", (0.68, 0.025, 0.006, 1), metalness=0.0,
                        roughness=0.40)
    gold = material("yuxi_antique_champagne_gold", (0.70, 0.31, 0.045, 1), metalness=0.48,
                    roughness=0.38)

    # 玉面需要有柔和清漆高光，但不能使用透明混合；透明材质会在 Cocos 排序时产生黑边。
    for jade_material in (jade, pale_jade, lion_jade):
        principled = jade_material.node_tree.nodes.get("Principled BSDF")
        if "Coat Weight" in principled.inputs:
            principled.inputs["Coat Weight"].default_value = 0.20
            principled.inputs["Coat Roughness"].default_value = 0.17

    def rounded_cube(name: str, location: tuple[float, float, float],
                     dimensions: tuple[float, float, float], mat: bpy.types.Material,
                     bevel_width: float, segments: int = 3) -> bpy.types.Object:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
        obj = bpy.context.active_object
        obj.name = name
        obj.scale = dimensions
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        obj.data.materials.append(mat)
        bevel(obj, bevel_width, segments)
        return obj

    body = rounded_cube("warm-nephrite-seal-body", (0, 0, 0), (0.92, 0.92, 0.80),
                        jade, 0.105)
    shoulder = rounded_cube("milky-jade-raised-shoulder", (0, 0, 0.45),
                            (0.90, 0.90, 0.10), pale_jade, 0.045)
    stamp_face = rounded_cube("cinnabar-stamp-face", (0, 0, -0.425),
                              (0.82, 0.82, 0.045), cinnabar, 0.028, 2)

    # 四面朱砂回纹只承担远景识别，不用细小文字，避免缩小时变成暗噪点。
    band_parts: list[bpy.types.Object] = []
    for side in range(4):
        angle = side * math.pi / 2
        outward = Vector((math.cos(angle), math.sin(angle), 0))
        tangent = Vector((-math.sin(angle), math.cos(angle), 0))
        for slot in range(-2, 3):
            center = outward * 0.47 + tangent * (slot * 0.17)
            band_parts.append(rounded_cube(
                f"cinnabar-meander-{side}-{slot}",
                (center.x, center.y, -0.015 + 0.045 * ((slot + side) % 2)),
                (0.018 if side % 2 == 0 else 0.11,
                 0.11 if side % 2 == 0 else 0.018, 0.045),
                cinnabar, 0.010, 1,
            ))
        for z in (-0.12, 0.10):
            band_parts.append(rounded_cube(
                f"cinnabar-band-{side}-{z}",
                (outward.x * 0.47, outward.y * 0.47, z),
                (0.018 if side % 2 == 0 else 0.82,
                 0.82 if side % 2 == 0 else 0.018, 0.018),
                cinnabar, 0.007, 1,
            ))

    collar = rounded_cube("antique-gold-guardian-collar", (0, 0, 0.515),
                          (0.88, 0.88, 0.060), gold, 0.035)

    source = ROOT / "source-assets/models/processed/yuxi/yuxi.glb"
    if not source.exists():
        raise FileNotFoundError(
            f"Prepared guardian source missing: {source}. Run prepare_yuxi_guardian_source.py first."
        )
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=str(source))
    imported = [obj for obj in bpy.context.scene.objects if obj not in before]
    lion_meshes = [obj for obj in imported if obj.type == "MESH"]
    if len(lion_meshes) != 1:
        raise RuntimeError(f"Expected one prepared guardian mesh, found {len(lion_meshes)}")
    lion = lion_meshes[0]
    world_matrix = lion.matrix_world.copy()
    lion.parent = None
    lion.matrix_world = world_matrix
    lion.name = "licensed-warm-jade-guardian-lion"
    lion.scale = (1.22, 1.22, 1.22)
    lion.location.z = 0.545
    bpy.ops.object.select_all(action="DESELECT")
    lion.select_set(True)
    bpy.context.view_layer.objects.active = lion
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    lion.data.materials.clear()
    lion.data.materials.append(lion_jade)
    lion.data.materials.append(gold)
    # 扫描件自带的双层方座正好承担参考图中的鎏金云座；按局部高度分材质，
    # 保留狮子本体为暖玉，同时避免额外几何与原底座穿插。
    for polygon in lion.data.polygons:
        polygon.material_index = 1 if polygon.center.z < 0.34 else 0

    normalize_export_parts(
        [body, shoulder, stamp_face, join(band_parts, "cinnabar-meander-band"),
         collar, lion],
        "yuxi",
        output,
    )


def make_ruyi(output: Path) -> None:
    """Build a continuous pale-lilac ruyi with a readable enamel cloud head."""
    lilac = material("ruyi_pale_lilac_jade", (0.64, 0.47, 0.78, 1), metalness=0.0,
                     roughness=0.27)
    lilac_light = material("ruyi_milky_lilac_highlight", (0.82, 0.69, 0.90, 1),
                           metalness=0.0, roughness=0.23)
    peacock = material("ruyi_peacock_blue_enamel", (0.015, 0.36, 0.43, 1),
                       metalness=0.06, roughness=0.20)
    gold = material("ruyi_warm_antique_gold", (0.78, 0.39, 0.065, 1), metalness=0.52,
                    roughness=0.35)
    cinnabar = material("ruyi_cinnabar_tassel_knot", (0.72, 0.025, 0.012, 1),
                        metalness=0.0, roughness=0.38)
    for polished in (lilac, lilac_light, peacock):
        principled = polished.node_tree.nodes.get("Principled BSDF")
        if "Coat Weight" in principled.inputs:
            principled.inputs["Coat Weight"].default_value = 0.18
            principled.inputs["Coat Roughness"].default_value = 0.14

    # 淡紫玉不能只靠一个纯色球面高光；嵌入低对比连续玉纹，让柄身转动时仍有温润层次，
    # 同时避免深色裂纹在手机缩略图里读成黑线。
    texture_width, texture_height = 256, 64
    jade_image = bpy.data.images.new("ruyi_continuous_lilac_jade", width=texture_width,
                                     height=texture_height)
    jade_pixels: list[float] = []
    deep_lilac = Vector((0.48, 0.30, 0.62))
    milk_lilac = Vector((0.78, 0.63, 0.86))
    for y in range(texture_height):
        v = y / (texture_height - 1)
        for x in range(texture_width):
            u = x / (texture_width - 1)
            wave = 0.5 + 0.5 * math.sin((u * 3.1 + 0.12 * math.sin(v * math.tau * 2.0)) * math.tau)
            cloud = 0.5 + 0.5 * math.sin((u * 1.25 - v * 0.72) * math.tau + 0.7)
            blend = 0.27 + wave * 0.25 + cloud * 0.16
            color = deep_lilac.lerp(milk_lilac, blend)
            grain = 0.015 * math.sin((u * 41.0 + v * 17.0) * math.tau)
            jade_pixels.extend((max(0.0, min(1.0, color.x + grain)),
                                max(0.0, min(1.0, color.y + grain)),
                                max(0.0, min(1.0, color.z + grain)), 1.0))
    jade_image.pixels.foreach_set(jade_pixels)
    jade_image.pack()
    lilac_nodes = lilac.node_tree.nodes
    lilac_links = lilac.node_tree.links
    jade_texture = lilac_nodes.new("ShaderNodeTexImage")
    jade_texture.image = jade_image
    jade_texture.interpolation = "Linear"
    jade_texture.extension = "REPEAT"
    lilac_links.new(jade_texture.outputs["Color"], lilac_nodes.get("Principled BSDF").inputs["Base Color"])

    def bezier_tube(name: str, points: list[tuple[float, float, float]], radius: float,
                    mat: bpy.types.Material, resolution: int = 4) -> bpy.types.Object:
        curve = bpy.data.curves.new(name, "CURVE")
        curve.dimensions = "3D"
        curve.resolution_u = resolution
        curve.bevel_depth = radius
        curve.bevel_resolution = 3
        spline = curve.splines.new("BEZIER")
        spline.bezier_points.add(len(points) - 1)
        for point, coordinates in zip(spline.bezier_points, points):
            point.co = coordinates
            point.handle_left_type = "AUTO"
            point.handle_right_type = "AUTO"
        obj = bpy.data.objects.new(name, curve)
        bpy.context.scene.collection.objects.link(obj)
        obj.data.materials.append(mat)
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        bpy.ops.object.convert(target="MESH")
        return bpy.context.active_object

    def prism(name: str, outline: list[tuple[float, float]], z: float, depth: float,
              mat: bpy.types.Material, bevel_width: float) -> bpy.types.Object:
        count = len(outline)
        vertices = [(x, y, z - depth * 0.5) for x, y in outline]
        vertices += [(x, y, z + depth * 0.5) for x, y in outline]
        faces: list[tuple[int, ...]] = [tuple(reversed(range(count))), tuple(range(count, count * 2))]
        faces.extend((i, (i + 1) % count, (i + 1) % count + count, i + count)
                     for i in range(count))
        mesh = bpy.data.meshes.new(f"{name}-mesh")
        mesh.from_pydata(vertices, [], faces)
        mesh.update()
        obj = bpy.data.objects.new(name, mesh)
        bpy.context.scene.collection.objects.link(obj)
        obj.data.materials.append(mat)
        bevel(obj, bevel_width, 3)
        for polygon in obj.data.polygons:
            polygon.use_smooth = True
        return obj

    # 旧版六颗椭球串成柄，旋转时缝隙和节段非常明显；单根自动贝塞尔管保证轮廓与高光连续。
    handle_path = [
        (-0.84, -0.38, 0.00), (-0.60, -0.30, 0.015), (-0.34, -0.22, 0.025),
        (-0.08, -0.13, 0.035), (0.14, -0.02, 0.045), (0.32, 0.16, 0.05),
    ]
    handle = bezier_tube("continuous-s-curve-jade-handle", handle_path, 0.105, lilac)
    # 孔雀蓝脊线嵌在柄的上表面，既强化长向走势，也让缩略图不再只剩一条浅色细棍。
    spine_path = [(x, y, z + 0.088) for x, y, z in handle_path[1:-1]]
    spine = bezier_tube("peacock-enamel-handle-inlay", spine_path, 0.027, peacock, 3)
    # 孔雀蓝脊线两侧各加一根细金丝，三色长向结构在密堆俯视下比孤立色线更精致、更稳定。
    gold_rails = join([
        bezier_tube("gold-filigree-rail-upper", [(x, y + 0.038, z + 0.006)
                    for x, y, z in spine_path], 0.010, gold, 3),
        bezier_tube("gold-filigree-rail-lower", [(x, y - 0.038, z + 0.006)
                    for x, y, z in spine_path], 0.010, gold, 3),
    ], "twin-gold-handle-rails")

    handle_pearl_parts = []
    for index, (x, y, z) in enumerate((spine_path[0], spine_path[1], spine_path[-1])):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=6, radius=1.0,
                                             location=(x, y, z + 0.018))
        pearl = bpy.context.active_object
        pearl.name = f"gold-handle-pearl-{index}"
        pearl.scale = (0.033, 0.033, 0.020)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        pearl.data.materials.append(gold)
        handle_pearl_parts.append(pearl)
    handle_pearls = join(handle_pearl_parts, "three-gold-handle-pearls")

    cloud = [
        (0.24, 0.16), (0.35, 0.10), (0.48, 0.15), (0.56, 0.27),
        (0.63, 0.18), (0.73, 0.11), (0.87, 0.12), (0.99, 0.22),
        (1.04, 0.36), (1.00, 0.49), (0.89, 0.58), (0.77, 0.58),
        (0.73, 0.72), (0.65, 0.82), (0.56, 0.87), (0.47, 0.82),
        (0.39, 0.72), (0.36, 0.59), (0.24, 0.58), (0.15, 0.50),
        (0.11, 0.37), (0.15, 0.25),
    ]
    cloud_body = prism("single-silhouette-three-lobe-cloud-head", cloud, 0.02, 0.16,
                       lilac_light, 0.045)
    # 不再把外轮廓等比缩小成一整块蓝色贴片；三枚独立珐琅叶瓣由金丝分隔，形成掐丝层次。
    enamel_panels = [
        [(0.25, 0.33), (0.35, 0.24), (0.47, 0.29), (0.51, 0.41),
         (0.44, 0.51), (0.31, 0.49), (0.23, 0.41)],
        [(0.67, 0.31), (0.78, 0.22), (0.91, 0.26), (0.96, 0.38),
         (0.89, 0.49), (0.76, 0.50), (0.67, 0.42)],
        [(0.45, 0.55), (0.48, 0.69), (0.56, 0.78), (0.64, 0.69),
         (0.68, 0.55), (0.60, 0.48), (0.52, 0.48)],
    ]
    enamel_parts = []
    panel_border_parts = []
    for index, panel in enumerate(enamel_panels):
        enamel_parts.append(prism(f"peacock-enamel-petal-{index}", panel, 0.112, 0.045,
                                  peacock, 0.023))
        panel_border_parts.append(curve_stroke(f"gold-cloisonne-wire-{index}",
                                  panel + [panel[0]], 0.151, 0.014, gold))
    enamel = join(enamel_parts, "three-peacock-enamel-petals")
    panel_borders = join(panel_border_parts, "three-gold-cloisonne-wires")
    gold_border = curve_stroke("continuous-gold-cloud-border", cloud + [cloud[0]],
                               0.118, 0.026, gold)

    # 三条粗金线对应传统如意的卷云骨架；避免细纹在手机画面中缩成暗噪点。
    gold_curls = join([
        curve_stroke("gold-curl-left", [(0.28, 0.42), (0.39, 0.34), (0.49, 0.43)],
                     0.151, 0.021, gold),
        curve_stroke("gold-curl-right", [(0.92, 0.42), (0.81, 0.34), (0.69, 0.43)],
                     0.151, 0.021, gold),
        curve_stroke("gold-curl-crown", [(0.47, 0.58), (0.56, 0.73), (0.65, 0.58)],
                     0.151, 0.021, gold),
    ], "three-gold-cloud-curls")
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=10, radius=1.0,
                                         location=(0.58, 0.45, 0.18))
    center_boss = bpy.context.active_object
    center_boss.name = "warm-gold-cloud-boss"
    center_boss.scale = (0.095, 0.095, 0.055)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    center_boss.data.materials.append(gold)

    # 尾端用金帽、朱砂结和三束孔雀蓝短穗建立方向，穗根埋入结内，防止运行时看成悬浮线条。
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=10, radius=1.0,
                                         location=(-0.91, -0.40, 0.0))
    tail_cap = bpy.context.active_object
    tail_cap.name = "antique-gold-tail-cap"
    tail_cap.scale = (0.15, 0.135, 0.115)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    tail_cap.data.materials.append(gold)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=1.0,
                                         location=(-1.035, -0.43, 0.0))
    knot = bpy.context.active_object
    knot.name = "cinnabar-tassel-knot"
    knot.scale = (0.09, 0.08, 0.075)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    knot.data.materials.append(cinnabar)

    knot_loops = join([
        bezier_tube("cinnabar-knot-loop-upper", [(-1.02, -0.42, 0.03),
                    (-1.07, -0.35, 0.035), (-1.12, -0.42, 0.02)], 0.021, cinnabar, 3),
        bezier_tube("cinnabar-knot-loop-lower", [(-1.02, -0.44, 0.025),
                    (-1.07, -0.51, 0.03), (-1.12, -0.44, 0.015)], 0.021, cinnabar, 3),
    ], "woven-cinnabar-knot-loops")
    tassels = join([
        bezier_tube(f"peacock-tassel-{index}", [(-1.08, -0.43 + offset, 0.0),
                     (-1.20, -0.47 + offset * 1.35, -0.018),
                     (-1.31 - abs(offset) * 0.35, -0.43 + offset * 1.85, -0.035)],
                    0.017, peacock, 2)
        for index, offset in enumerate((-0.065, -0.032, 0.0, 0.032, 0.065))
    ], "five-peacock-tassels")

    normalize_export_parts(
        [handle, spine, gold_rails, handle_pearls, cloud_body, enamel, panel_borders,
         gold_border, gold_curls, center_boss, tail_cap, knot, knot_loops, tassels],
        "ruyi",
        output,
    )


BUILDERS = {
    "tongqian": make_tongqian,
    "bracelet": make_bracelet,
    "baoshi": make_baoshi,
    "hulu": make_hulu,
    "yuzhuo": make_yuzhuo,
    "banzhi": make_banzhi,
    "yuxi": make_yuxi_from_scan,
    "ruyi": make_ruyi,
}


def main() -> None:
    requested = [arg for arg in sys.argv[sys.argv.index("--") + 1:] if arg] if "--" in sys.argv else []
    names = requested or list(BUILDERS)
    unknown = [name for name in names if name not in BUILDERS]
    if unknown:
        raise SystemExit(f"Unknown antique v2 model(s): {', '.join(unknown)}")
    for name in names:
        clear_scene()
        BUILDERS[name](DEFAULT_OUTPUT)


if __name__ == "__main__":
    main()
