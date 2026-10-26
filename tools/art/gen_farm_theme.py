"""程序化生成「池塘农场」主题的 9 个物件、图标与藤编收获篮。

面向 Blender 4.x headless，所有随机因素固定，重复执行会稳定覆盖同名产物。
物件统一归一化到最大边 1.0；容器保留横纵比例，由游戏运行时按开口跨度缩放。

用法：
  /Applications/Blender.app/Contents/MacOS/Blender --background \
    --python tools/art/gen_farm_theme.py
"""
from __future__ import annotations

import math
import os
import sys
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[2]
MODELS = ROOT / "reference-projects/catch-big-goose-cocos/assets/resources/models"
ICONS = ROOT / "reference-projects/catch-big-goose-cocos/assets/resources/icons"

C = {
    "leaf": (0.10, 0.42, 0.11, 1),
    "leaf_light": (0.25, 0.62, 0.16, 1),
    "orange": (0.92, 0.28, 0.035, 1),
    "yellow": (0.96, 0.67, 0.05, 1),
    "purple": (0.29, 0.055, 0.42, 1),
    "frog": (0.24, 0.64, 0.16, 1),
    "cream": (0.88, 0.73, 0.48, 1),
    "red": (0.72, 0.045, 0.035, 1),
    "teal": (0.055, 0.43, 0.58, 1),
    "pink": (0.91, 0.32, 0.50, 1),
    "white": (0.96, 0.91, 0.78, 1),
    "black": (0.018, 0.022, 0.018, 1),
    "wood": (0.48, 0.23, 0.08, 1),
    "wicker": (0.72, 0.46, 0.18, 1),
    "wicker_light": (0.84, 0.63, 0.31, 1),
}


def wipe() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for collection in (bpy.data.meshes, bpy.data.materials, bpy.data.curves,
                       bpy.data.cameras, bpy.data.lights):
        for block in list(collection):
            try:
                collection.remove(block)
            except RuntimeError:
                pass


def material(name: str, color, roughness: float = 0.48):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = color
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Roughness"].default_value = roughness
    return mat


def apply(obj) -> None:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)


def sphere(name: str, loc, scale, mat, segments=20, rings=12):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings,
                                         location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    apply(obj)
    bpy.ops.object.shade_smooth()
    obj.data.materials.append(mat)
    return obj


def ico(name: str, loc, scale, mat, subdivisions=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1,
                                          location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    apply(obj)
    bpy.ops.object.shade_smooth()
    obj.data.materials.append(mat)
    return obj


def cylinder(name: str, loc, radius, depth, mat, vertices=12, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth,
                                        location=loc, rotation=rotation)
    obj = bpy.context.active_object
    obj.name = name
    obj.data.materials.append(mat)
    bpy.ops.object.shade_smooth()
    return obj


def cone(name: str, loc, r1, r2, depth, mat, vertices=12, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=r1, radius2=r2,
                                    depth=depth, location=loc, rotation=rotation)
    obj = bpy.context.active_object
    obj.name = name
    obj.data.materials.append(mat)
    bpy.ops.object.shade_smooth()
    return obj


def cube(name: str, loc, scale, mat, bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    apply(obj)
    if bevel:
        mod = obj.modifiers.new("soft_edges", "BEVEL")
        mod.width = bevel
        mod.segments = 2
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=mod.name)
        bpy.ops.object.shade_smooth()
    obj.data.materials.append(mat)
    return obj


def curve_tube(name: str, points, bevel: float, mat):
    """Small low-poly stroke for facial lines and decorative seams."""
    curve = bpy.data.curves.new(name + "Curve", "CURVE")
    curve.dimensions = "3D"
    curve.resolution_u = 2
    curve.bevel_depth = bevel
    curve.bevel_resolution = 1
    spline = curve.splines.new("BEZIER")
    spline.bezier_points.add(len(points) - 1)
    for point, co in zip(spline.bezier_points, points):
        point.co = co
        point.handle_left_type = point.handle_right_type = "AUTO"
    obj = bpy.data.objects.new(name, curve)
    bpy.context.scene.collection.objects.link(obj)
    obj.data.materials.append(mat)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    return bpy.context.active_object


def join(parts, name: str):
    bpy.ops.object.select_all(action="DESELECT")
    for part in parts:
        part.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    obj = bpy.context.active_object
    obj.name = name
    return obj


def normalize(obj) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    low = Vector((min(v.co[i] for v in obj.data.vertices) for i in range(3)))
    high = Vector((max(v.co[i] for v in obj.data.vertices) for i in range(3)))
    center = (low + high) * 0.5
    scale = 1.0 / (max(high - low) or 1.0)
    obj.scale = (scale,) * 3
    obj.location = -center * scale
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)


def export_glb(obj, name: str, normalize_item=True) -> None:
    if normalize_item:
        normalize(obj)
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    MODELS.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=str(MODELS / f"{name}.glb"),
                              export_format="GLB", use_selection=True)
    print("BUILT", name, "faces=", len(obj.data.polygons))


def look_at(obj, target=(0, 0, 0)) -> None:
    obj.rotation_euler = (Vector(target) - obj.location).to_track_quat("-Z", "Y").to_euler()


def render_icon(obj, name: str) -> None:
    scene = bpy.context.scene
    # Blender 5.2 把 Eevee 枚举名从 4.x 的 BLENDER_EEVEE_NEXT 改回 BLENDER_EEVEE。
    # 运行时按当前版本实际暴露的枚举选择，避免脚本在两代 Blender 间失效。
    engines = bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items.keys()
    scene.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in engines else "BLENDER_EEVEE"
    scene.render.resolution_x = 192
    scene.render.resolution_y = 192
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.view_settings.look = "AgX - Medium High Contrast"

    camera_data = bpy.data.cameras.new("IconCamera")
    camera = bpy.data.objects.new("IconCamera", camera_data)
    scene.collection.objects.link(camera)
    camera.location = (2.7, -4.2, 2.9)
    camera_data.type = "ORTHO"
    look_at(camera)
    scene.camera = camera

    camera_inv = camera.matrix_world.inverted()
    points = [camera_inv @ (obj.matrix_world @ Vector(corner)) for corner in obj.bound_box]
    width = max(p.x for p in points) - min(p.x for p in points)
    height = max(p.y for p in points) - min(p.y for p in points)
    camera_data.ortho_scale = max(width, height) * 1.28

    for index, (location, energy, size, color) in enumerate([
        ((3.5, -4.0, 5.5), 800, 4.0, (1.0, 0.86, 0.68)),
        ((-4.0, -1.0, 3.0), 500, 4.5, (0.62, 0.80, 1.0)),
        ((1.0, 4.0, 4.0), 550, 3.0, (0.76, 1.0, 0.82)),
    ]):
        data = bpy.data.lights.new(f"IconLight{index}", "AREA")
        data.energy = energy
        data.shape = "DISK"
        data.size = size
        data.color = color
        light = bpy.data.objects.new(f"IconLight{index}", data)
        scene.collection.objects.link(light)
        light.location = location
        look_at(light)

    ICONS.mkdir(parents=True, exist_ok=True)
    scene.render.filepath = str(ICONS / f"{name}.png")
    bpy.ops.render.render(write_still=True)
    print("ICON", name)


def carrot():
    orange = material("carrot_orange", C["orange"], 0.58)
    ridge = material("carrot_ridge", (1.0, 0.43, 0.07, 1), 0.54)
    green = material("carrot_leaf", C["leaf"], 0.62)
    parts = [cone("root", (0, 0, -0.18), 0.38, 0.08, 1.55, orange, 16)]
    # Four shallow growth rings break the old single-cone read without changing its proxy shape.
    for z, radius in [(-0.66, 0.325), (-0.38, 0.275), (-0.10, 0.220), (0.18, 0.165)]:
        bpy.ops.mesh.primitive_torus_add(major_radius=radius, minor_radius=0.022,
                                         major_segments=16, minor_segments=5,
                                         location=(0, 0, z))
        ring = bpy.context.active_object
        ring.name = "growth_ring"
        ring.data.materials.append(ridge)
        bpy.ops.object.shade_smooth()
        parts.append(ring)
    for angle in (-0.45, 0, 0.45):
        parts.append(cone("leaf", (math.sin(angle) * 0.16, 0, 0.78),
                          0.13, 0.025, 0.75, green, 8,
                          rotation=(0, angle, 0)))
    return join(parts, "carrot")


def corn():
    yellow = material("corn_kernel", (1.0, 0.64, 0.035, 1), 0.54)
    kernel_light = material("corn_kernel_light", (1.0, 0.82, 0.13, 1), 0.48)
    green = material("corn_husk", C["leaf"], 0.63)
    parts = [sphere("cob", (0, 0, 0.05), (0.48, 0.48, 1.05), yellow, 22, 14)]
    # Raised kernels create the familiar cob rhythm in top/side views.  Icospheres keep the added
    # detail under the mobile triangle budget while surviving downsampling better than a texture.
    for row, z in enumerate((-0.70, -0.47, -0.24, -0.01, 0.22, 0.45, 0.68)):
        for column in range(8):
            angle = (column + row * 0.5) * math.tau / 8
            kernel = ico("kernel", (math.cos(angle) * 0.465, math.sin(angle) * 0.465, z + 0.05),
                         (0.075, 0.075, 0.105), kernel_light, 1)
            parts.append(kernel)
    for side in (-1, 1):
        leaf = ico("husk", (0.34 * side, 0, -0.30), (0.22, 0.11, 0.95), green, 2)
        leaf.rotation_euler = (0, math.radians(18 * side), 0)
        parts.append(leaf)
    return join(parts, "corn")


def eggplant():
    purple = material("eggplant_purple", C["purple"], 0.32)
    purple_light = material("eggplant_highlight", (0.72, 0.38, 0.82, 1), 0.27)
    green = material("eggplant_calyx", C["leaf"], 0.58)
    parts = [sphere("body", (0, 0, -0.20), (0.58, 0.54, 1.05), purple, 24, 16)]
    for i in range(5):
        a = i * math.tau / 5
        leaf = ico("calyx", (math.cos(a) * 0.23, math.sin(a) * 0.23, 0.76),
                   (0.34, 0.13, 0.10), green, 1)
        leaf.rotation_euler = (0, 0, a)
        parts.append(leaf)
    parts.append(cylinder("stem", (0, 0, 1.02), 0.09, 0.42, green, 8,
                            rotation=(0, math.radians(-12), 0)))
    # One broad, almost flush highlight remains legible after the model is tilted in the basket.
    parts.append(sphere("skin_highlight", (-0.18, -0.515, 0.06),
                        (0.070, 0.018, 0.20), purple_light, 12, 8))
    return join(parts, "eggplant")


def frog():
    green = material("frog_green", (0.18, 0.60, 0.035, 1), 0.48)
    green_light = material("frog_muzzle", (0.34, 0.72, 0.08, 1), 0.50)
    green_dark = material("frog_spot", (0.075, 0.36, 0.018, 1), 0.58)
    cream = material("frog_belly", (0.92, 0.70, 0.16, 1), 0.60)
    eye_white = material("frog_eye_white", (0.98, 0.93, 0.75, 1), 0.38)
    iris = material("frog_iris", (0.34, 0.12, 0.025, 1), 0.28)
    pink = material("frog_cheek", (1.0, 0.44, 0.44, 1), 0.48)
    black = material("frog_eye", C["black"], 0.24)
    white = material("frog_eye_glint", C["white"], 0.26)
    # The concept sheet uses an upright pear body instead of the old wide, prone frog.  The head
    # overlaps the torso so it still feels compact when tumbling in the basket.
    parts = [sphere("body", (0, 0.10, -0.06), (0.53, 0.42, 0.65), green, 24, 16),
             sphere("head", (0, -0.17, 0.56), (0.61, 0.46, 0.43), green, 24, 16),
             sphere("muzzle", (0, -0.515, 0.47), (0.47, 0.070, 0.25), green_light, 18, 12),
             sphere("belly", (0, -0.345, -0.05), (0.33, 0.052, 0.47), cream, 18, 12)]
    for side in (-1, 1):
        # Green rims frame inset cream eyes; layered iris/pupil/glint avoids the old bead-eye look.
        parts.append(sphere("eye_rim", (0.27 * side, -0.47, 0.82),
                            (0.195, 0.115, 0.225), green_dark, 16, 10))
        parts.append(sphere("eye_white", (0.27 * side, -0.555, 0.82),
                            (0.142, 0.035, 0.174), eye_white, 16, 10))
        parts.append(sphere("iris", (0.27 * side, -0.590, 0.80),
                            (0.087, 0.018, 0.112), iris, 12, 8))
        parts.append(sphere("pupil", (0.27 * side, -0.607, 0.80),
                            (0.050, 0.010, 0.078), black, 12, 8))
        parts.append(sphere("eye_glint", (0.245 * side, -0.621, 0.855),
                            (0.024, 0.007, 0.031), white, 8, 5))
        parts.append(sphere("cheek", (0.41 * side, -0.590, 0.48),
                            (0.085, 0.018, 0.060), pink, 12, 8))
        parts.append(sphere("back_thigh", (0.48 * side, 0.12, -0.22),
                            (0.30, 0.27, 0.38), green, 18, 12))
        arm = sphere("front_arm", (0.30 * side, -0.41, -0.10),
                     (0.105, 0.075, 0.42), green_light, 14, 10)
        arm.rotation_euler.y = math.radians(7 * side)
        parts.append(arm)
        parts.append(sphere("front_palm", (0.31 * side, -0.47, -0.48),
                            (0.13, 0.11, 0.060), green_light, 12, 8))
        for toe in (-1, 0, 1):
            parts.append(sphere("front_toe",
                                (0.31 * side + toe * 0.055, -0.555, -0.52 + abs(toe) * 0.012),
                                (0.042, 0.105, 0.040), green_light, 10, 6))
        # Rear toes peek out beside the body and strengthen the seated silhouette.
        for toe in (-1, 0, 1):
            parts.append(sphere("rear_toe",
                                (0.49 * side + toe * 0.048, -0.17, -0.53 + abs(toe) * 0.012),
                                (0.044, 0.12, 0.040), green, 10, 6))
    for side in (-1, 1):
        for z, x_offset, size in [(0.12, 0.45, 0.055), (0.30, 0.49, 0.043),
                                  (-0.08, 0.46, 0.040)]:
            parts.append(sphere("side_spot", (x_offset * side, -0.18, z),
                                (size, 0.025, size * 0.86), green_dark, 10, 6))
    for side in (-1, 1):
        parts.append(sphere("nostril", (0.070 * side, -0.590, 0.57),
                            (0.018, 0.008, 0.016), green_dark, 8, 5))
    parts.append(curve_tube("smile", [(-0.24, -0.598, 0.44), (0, -0.645, 0.35),
                                       (0.24, -0.598, 0.44)], 0.013, green_dark))
    return join(parts, "frog")


def pumpkin():
    orange = material("pumpkin_orange", C["orange"], 0.60)
    orange_light = material("pumpkin_orange_light", (1.0, 0.38, 0.045, 1), 0.56)
    green = material("pumpkin_stem", C["leaf"], 0.66)
    parts = []
    for i in range(8):
        a = i * math.tau / 8
        parts.append(sphere("lobe", (math.cos(a) * 0.24, math.sin(a) * 0.24, 0),
                            (0.46, 0.46, 0.66), orange_light if i % 2 == 0 else orange, 18, 12))
    parts.append(cone("stem", (0, 0, 0.72), 0.13, 0.08, 0.42, green, 8))
    return join(parts, "pumpkin")


def mushroom():
    red = material("mushroom_red", C["red"], 0.48)
    cream = material("mushroom_cream", C["white"], 0.70)
    parts = [sphere("cap", (0, 0, 0.38), (0.82, 0.82, 0.42), red, 24, 14),
             cone("stem", (0, 0, -0.28), 0.28, 0.19, 0.95, cream, 14)]
    for x, y, s in [(-0.30, -0.22, 0.11), (0.28, -0.30, 0.13),
                    (0.02, 0.04, 0.09), (0.43, 0.10, 0.075), (-0.42, 0.22, 0.07)]:
        radial = min(0.98, (x * x + y * y) / (0.82 * 0.82))
        z = 0.38 + 0.42 * math.sqrt(1.0 - radial) + 0.018
        parts.append(sphere("spot", (x, y, z), (s, s, 0.045), cream, 12, 8))
    return join(parts, "mushroom")


def koi():
    white = material("koi_pearl", (0.96, 0.91, 0.72, 1), 0.44)
    orange = material("koi_orange", (0.86, 0.055, 0.012, 1), 0.40)
    gold = material("koi_scale", (1.0, 0.42, 0.025, 1), 0.48)
    fin_mat = material("koi_fin", (0.72, 0.025, 0.006, 1), 0.58)
    black = material("koi_eye", C["black"], 0.24)
    parts = [sphere("body", (0, 0, 0), (1.02, 0.43, 0.38), white, 24, 14),
             sphere("head_patch", (0.57, -0.34, 0.13), (0.35, 0.075, 0.25), orange, 14, 8),
             sphere("back_patch", (-0.20, -0.37, 0.16), (0.34, 0.060, 0.20), orange, 14, 8)]
    for side in (-1, 1):
        tail = ico("tail_lobe", (-1.02, 0.25 * side, 0), (0.48, 0.28, 0.095), fin_mat, 2)
        tail.rotation_euler.z = math.radians(25 * side)
        parts.append(tail)
        fin = ico("side_fin", (0.02, 0.40 * side, -0.01),
                  (0.38, 0.20, 0.065), fin_mat, 1)
        fin.rotation_euler.z = math.radians(18 * side)
        parts.append(fin)
    # A few raised golden scales provide rhythm without covering the pearl body.
    for x, y in [(-0.55, -0.38), (-0.30, -0.40), (-0.05, -0.41),
                 (0.20, -0.39), (-0.42, -0.34), (0.07, -0.36)]:
        parts.append(sphere("scale", (x, y, 0.08), (0.085, 0.026, 0.060), gold, 10, 6))
    parts.append(ico("dorsal_fin", (-0.18, 0, 0.38), (0.40, 0.075, 0.20), fin_mat, 1))
    parts.append(sphere("eye", (0.68, -0.405, 0.18), (0.073, 0.030, 0.073), black, 10, 6))
    parts.append(sphere("eye_glint", (0.70, -0.433, 0.205), (0.020, 0.009, 0.020), white, 8, 5))
    parts.append(curve_tube("mouth", [(0.92, -0.39, 0.00), (1.02, -0.405, -0.02)],
                            0.012, black))
    return join(parts, "koi")


def lotus():
    green = material("lotus_pad", (0.08, 0.38, 0.15, 1), 0.68)
    green_light = material("lotus_pad_vein", (0.22, 0.57, 0.21, 1), 0.64)
    deep = material("lotus_deep", (0.83, 0.16, 0.39, 1), 0.43)
    pink = material("lotus_pink", (0.98, 0.42, 0.62, 1), 0.44)
    pale = material("lotus_pale", (1.0, 0.72, 0.80, 1), 0.50)
    yellow = material("lotus_center", (1.0, 0.68, 0.035, 1), 0.58)
    yellow_light = material("lotus_stamen_tip", (1.0, 0.88, 0.24, 1), 0.48)
    parts = [sphere("lily_pad", (0.16, 0.14, -0.18), (0.88, 0.72, 0.070), green, 24, 10)]
    # A few broad veins keep the pad readable without competing with the blossom.
    for angle in (-42, -12, 20, 50):
        a = math.radians(angle)
        parts.append(curve_tube("pad_vein", [(0.08, 0.08, -0.105),
                                                (0.08 + math.cos(a) * 0.53,
                                                 0.08 + math.sin(a) * 0.43, -0.105)],
                                0.010, green_light))
    for ring, count, radius, scale, z, mat in [
        (0, 12, 0.55, (0.46, 0.16, 0.10), -0.01, deep),
        (1, 9, 0.37, (0.37, 0.135, 0.18), 0.11, pink),
        (2, 6, 0.21, (0.25, 0.105, 0.25), 0.24, pale),
    ]:
        for i in range(count):
            a = i * math.tau / count + ring * 0.25
            petal = ico("petal", (math.cos(a) * radius, math.sin(a) * radius, z),
                        scale, mat, 2)
            petal.rotation_euler.z = a
            parts.append(petal)
    # Keep the seed pod small and surround it with a dense stamen halo.  The old oversized pod and
    # three dots read as a cartoon face rather than a flower from the game camera.
    parts.append(sphere("seed_pod", (0, 0, 0.53), (0.135, 0.135, 0.085), yellow, 14, 8))
    for i in range(12):
        a = i * math.tau / 12
        radius = 0.19 if i % 2 else 0.22
        parts.append(cylinder("stamen", (math.cos(a) * radius, math.sin(a) * radius, 0.50),
                              0.018, 0.12, yellow, 6))
        parts.append(sphere("stamen_tip", (math.cos(a) * radius, math.sin(a) * radius, 0.575),
                            (0.032, 0.032, 0.025), yellow_light, 8, 5))
    return join(parts, "lotus")


def duck():
    yellow = material("duck_yellow", (0.96, 0.47, 0.008, 1), 0.48)
    yellow_light = material("duck_feather_light", (1.0, 0.68, 0.055, 1), 0.53)
    cream = material("duck_belly", (1.0, 0.78, 0.20, 1), 0.58)
    orange = material("duck_bill", (1.0, 0.25, 0.012, 1), 0.54)
    bill_dark = material("duck_bill_shadow", (0.82, 0.16, 0.008, 1), 0.60)
    eye_white = material("duck_eye_white", (1.0, 0.95, 0.80, 1), 0.36)
    iris = material("duck_iris", (0.32, 0.10, 0.018, 1), 0.28)
    black = material("duck_eye", C["black"], 0.24)
    white = material("duck_eye_glint", C["white"], 0.30)
    pink = material("duck_cheek", (1.0, 0.42, 0.32, 1), 0.48)
    # Upright pear body and separate round head follow the approved concept sheet.  This replaces
    # the old horizontal loaf silhouette that looked more like a chick-shaped bun than a duck.
    parts = [sphere("body", (0, 0.10, -0.08), (0.53, 0.43, 0.64), yellow, 24, 16),
             sphere("belly", (0, -0.355, -0.10), (0.34, 0.045, 0.41), cream, 18, 12),
             sphere("neck", (0, -0.02, 0.48), (0.36, 0.32, 0.29), yellow, 18, 12),
             sphere("head", (0, -0.13, 0.70), (0.49, 0.43, 0.47), yellow, 24, 16)]
    parts.append(sphere("bill_upper", (0, -0.575, 0.62),
                        (0.31, 0.16, 0.095), orange, 16, 10))
    parts.append(sphere("bill_lower", (0, -0.565, 0.55),
                        (0.255, 0.13, 0.060), bill_dark, 14, 8))
    for side in (-1, 1):
        parts.append(sphere("eye_white", (0.20 * side, -0.510, 0.78),
                            (0.135, 0.036, 0.165), eye_white, 16, 10))
        parts.append(sphere("iris", (0.20 * side, -0.545, 0.77),
                            (0.080, 0.018, 0.105), iris, 12, 8))
        parts.append(sphere("pupil", (0.20 * side, -0.562, 0.77),
                            (0.046, 0.010, 0.074), black, 12, 8))
        parts.append(sphere("eye_glint", (0.178 * side, -0.574, 0.823),
                            (0.022, 0.007, 0.029), white, 8, 5))
        parts.append(sphere("cheek", (0.34 * side, -0.535, 0.61),
                            (0.072, 0.016, 0.052), pink, 10, 6))
        parts.append(sphere("nostril", (0.085 * side, -0.720, 0.655),
                            (0.018, 0.008, 0.013), bill_dark, 8, 5))
        wing = ico("wing", (0.47 * side, 0.02, 0.04),
                   (0.235, 0.15, 0.38), yellow_light, 2)
        wing.rotation_euler.y = math.radians(-10 * side)
        parts.append(wing)
        for feather_index in range(3):
            feather = ico("wing_feather", (side * (0.49 + feather_index * 0.018),
                                             -0.145,
                                             0.04 - feather_index * 0.12),
                          (0.16 - feather_index * 0.014, 0.030, 0.095), yellow, 1)
            feather.rotation_euler.y = math.radians(side * (18 - feather_index * 4))
            parts.append(feather)
        # Broad palm plus three forward toes gives a readable webbed foot from the game camera.
        parts.append(sphere("foot_palm", (0.23 * side, -0.16, -0.61),
                            (0.22, 0.19, 0.060), orange, 12, 8))
        for toe in (-1, 0, 1):
            parts.append(sphere("webbed_toe",
                                (0.23 * side + toe * 0.065, -0.30 - abs(toe) * 0.012, -0.63),
                                (0.060, 0.17, 0.040), orange, 10, 6))
    for x, angle in [(-0.12, -15), (0.12, 15)]:
        tail = ico("tail_feather", (x, 0.48, 0.10), (0.18, 0.25, 0.10), yellow_light, 1)
        tail.rotation_euler.z = math.radians(angle)
        parts.append(tail)
    # Eyebrows and a curved beak seam carry the cheerful expression from the concept sheet.
    brow = material("duck_brow", (0.56, 0.14, 0.008, 1), 0.58)
    for side in (-1, 1):
        parts.append(curve_tube("eyebrow",
                                [(0.31 * side, -0.515, 0.94),
                                 (0.21 * side, -0.545, 0.975),
                                 (0.12 * side, -0.520, 0.95)], 0.011, brow))
    parts.append(curve_tube("beak_smile", [(-0.22, -0.700, 0.575),
                                             (0, -0.735, 0.535),
                                             (0.22, -0.700, 0.575)], 0.010, bill_dark))
    # Two simple tuft leaves preserve a clean silhouette at small icon size.
    for side in (-1, 1):
        tuft = ico("head_tuft", (0.055 * side, -0.04, 1.16),
                   (0.070, 0.16, 0.060), yellow_light, 1)
        tuft.rotation_euler.z = math.radians(24 * side)
        parts.append(tuft)
    return join(parts, "duck")


def harvest_basket():
    # 容器在游戏里只有约 320px 宽，精致感主要来自清楚的三层关系：深色内衬托住
    # 交错编织、立桩形成侧壁节奏、双层包边压住轮廓。不能靠贴满细线堆细节，缩小后会糊。
    shadow = material("basket_shadow", (0.24, 0.085, 0.025, 1), 0.82)
    dark = material("basket_dark", (0.43, 0.18, 0.045, 1), 0.72)
    wicker = material("basket_honey", (0.72, 0.38, 0.095, 1), 0.66)
    light = material("basket_straw", (0.92, 0.66, 0.27, 1), 0.62)
    parts = [
        cube("shadow_plinth", (0, 0, -0.20), (3.02, 2.68, 0.10), shadow, 0.16),
        cube("woven_liner", (0, 0, -0.075), (2.82, 2.48, 0.055), dark, 0.12),
    ]

    # 短藤片按经纬交替铺陈，和旧版贯穿整筐的横竖栅格不同；每格方向翻转后才会读成
    # 真正的压一挑一编织，而不是铁丝网。底面始终低于 y=0 的物理停靠面，不顶起物件。
    for row in range(-5, 6):
        for col in range(-6, 7):
            horizontal = (row + col) % 2 == 0
            sx, sy = (0.205, 0.105) if horizontal else (0.105, 0.205)
            parts.append(cube(
                "weave_tile",
                (col * 0.42, row * 0.42, 0.01 + (0.012 if horizontal else 0)),
                (sx, sy, 0.035),
                light if horizontal else wicker,
                0,
            ))

    # 四边立桩给侧壁真实高度，间距略宽于底部纹理，避免缩小后形成摩尔纹。
    for col in range(-6, 7):
        x = col * 0.43
        for y in (-2.55, 2.55):
            parts.append(cube("wall_stake", (x, y, 0.34), (0.075, 0.10, 0.38),
                              light if col % 2 else wicker, 0))
    for row in range(-5, 6):
        y = row * 0.44
        for x in (-2.90, 2.90):
            parts.append(cube("wall_stake", (x, y, 0.34), (0.10, 0.075, 0.38),
                              wicker if row % 2 else light, 0))

    # 下束带收住侧壁，顶部用深色承托 + 蜂蜜色包边形成厚实的手工篮沿。
    for z, thickness, mat in [
        (0.14, 0.095, dark),
        (0.66, 0.15, shadow),
        (0.72, 0.105, light),
    ]:
        parts.extend([
            cube("rim", (0, 2.66, z), (3.10, thickness, thickness), mat, 0.09),
            cube("rim", (0, -2.66, z), (3.10, thickness, thickness), mat, 0.09),
            cube("rim", (3.01, 0, z), (thickness, 2.55, thickness), mat, 0.09),
            cube("rim", (-3.01, 0, z), (thickness, 2.55, thickness), mat, 0.09),
        ])

    # 四角包柱遮住四组直条的拼缝，也让外轮廓在农场浅色背景上保持完整。
    for x in (-3.00, 3.00):
        for y in (-2.65, 2.65):
            parts.append(cylinder("corner_wrap", (x, y, 0.34), 0.16, 0.88,
                                  dark, 12))
    return join(parts, "basket_farm")


BUILDERS = [
    ("carrot", carrot),
    ("corn", corn),
    ("eggplant", eggplant),
    ("frog", frog),
    ("pumpkin", pumpkin),
    ("mushroom", mushroom),
    ("koi", koi),
    ("lotus", lotus),
    ("duck", duck),
]


if __name__ == "__main__":
    # 容器精修时使用 --container-only，避免无关的 9 个物件和图标被 Blender 重导出。
    if "--container-only" not in sys.argv:
        for model_name, builder in BUILDERS:
            wipe()
            model = builder()
            export_glb(model, model_name)
            render_icon(model, model_name)

    if "--items-only" not in sys.argv:
        wipe()
        basket = harvest_basket()
        export_glb(basket, "basket_farm", normalize_item=False)
    print("ALL DONE", MODELS, ICONS)
