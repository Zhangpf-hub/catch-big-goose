"""Generate quality-gated v2 farm-theme GLB candidates.

Single-model example:

  blender --background --python tools/art/gen_farm_theme_v2.py -- carrot
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_antique_theme_v2 as base


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT = ROOT / "source-assets/models/candidates/farm-v2"


def make_carrot(output: Path) -> None:
    orange = base.material("carrot_warm_orange_skin", (1.0, 0.31, 0.012, 1),
                           metalness=0.0, roughness=0.58)
    groove = base.material("carrot_soft_orange_growth_grooves", (0.78, 0.105, 0.012, 1),
                           metalness=0.0, roughness=0.58)
    leaf_deep = base.material("carrot_deep_leaf_green", (0.055, 0.30, 0.075, 1),
                              metalness=0.0, roughness=0.58)
    leaf_fresh = base.material("carrot_fresh_leaf_green", (0.24, 0.62, 0.11, 1),
                               metalness=0.0, roughness=0.53)
    leaf_vein = base.material("carrot_leaf_vein", (0.43, 0.78, 0.18, 1),
                              metalness=0.0, roughness=0.50)

    # 连续低对比橙色皮纹只提供温润层次，禁止生成深色横带，避免重新读成交通锥。
    width, height = 256, 128
    skin_image = bpy.data.images.new("carrot_continuous_skin", width=width, height=height)
    skin_pixels: list[float] = []
    deep = Vector((0.96, 0.20, 0.006))
    light = Vector((1.0, 0.47, 0.016))
    for y in range(height):
        v = y / (height - 1)
        for x in range(width):
            u = x / (width - 1)
            broad = 0.50 + 0.10 * math.sin((v * 1.2 + 0.05 * math.sin(u * math.tau)) * math.tau)
            freckles = 0.014 * math.sin((u * 29.0 + v * 17.0) * math.tau)
            color = deep.lerp(light, max(0.34, min(0.68, broad)))
            skin_pixels.extend((max(0.0, min(1.0, color.x + freckles)),
                                max(0.0, min(1.0, color.y + freckles * 0.45)),
                                max(0.0, min(1.0, color.z)), 1.0))
    skin_image.pixels.foreach_set(skin_pixels)
    skin_image.pack()
    nodes = orange.node_tree.nodes
    texture = nodes.new("ShaderNodeTexImage")
    texture.image = skin_image
    texture.extension = "REPEAT"
    orange.node_tree.links.new(texture.outputs["Color"], nodes.get("Principled BSDF").inputs["Base Color"])

    profile = [
        (0.62, 0.12, -0.01), (0.56, 0.28, -0.005), (0.46, 0.38, 0.00),
        (0.30, 0.40, 0.010), (0.10, 0.36, 0.025), (-0.10, 0.31, 0.045),
        (-0.30, 0.25, 0.068), (-0.49, 0.18, 0.084), (-0.65, 0.11, 0.092),
        (-0.78, 0.055, 0.088), (-0.86, 0.018, 0.080),
    ]
    segments = 28
    vertices: list[tuple[float, float, float]] = []
    uvs: list[tuple[float, float]] = []
    for ring_index, (z, radius, center_x) in enumerate(profile):
        for segment in range(segments):
            angle = segment * math.tau / segments
            squash = 1.0 - 0.045 * math.cos(angle * 2.0 + ring_index * 0.7)
            vertices.append((center_x + math.cos(angle) * radius * squash,
                             math.sin(angle) * radius, z))
            uvs.append((segment / segments, ring_index / (len(profile) - 1)))
    faces: list[tuple[int, ...]] = []
    for ring_index in range(len(profile) - 1):
        for segment in range(segments):
            nxt = (segment + 1) % segments
            a = ring_index * segments + segment
            b = ring_index * segments + nxt
            c = (ring_index + 1) * segments + nxt
            d = (ring_index + 1) * segments + segment
            faces.append((a, b, c, d))
    faces.extend((tuple(reversed(range(segments))),
                  tuple(range((len(profile) - 1) * segments, len(profile) * segments))))
    mesh = bpy.data.meshes.new("continuous-curved-carrot-root-mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    root_body = bpy.data.objects.new("continuous-curved-carrot-root", mesh)
    bpy.context.scene.collection.objects.link(root_body)
    root_body.data.materials.append(orange)
    uv_layer = mesh.uv_layers.new(name="UVMap")
    for polygon in mesh.polygons:
        for loop_index in polygon.loop_indices:
            vertex_index = mesh.loops[loop_index].vertex_index
            uv_layer.data[loop_index].uv = uvs[vertex_index]
        polygon.use_smooth = True
    base.bevel(root_body, 0.018, 2)

    def leaf_blade(name: str, angle: float, lean: float, length: float, leaf_width: float,
                   mat: bpy.types.Material) -> tuple[bpy.types.Object, bpy.types.Object]:
        rows = 11
        blade_vertices: list[tuple[float, float, float]] = []
        centerline: list[tuple[float, float, float]] = []
        direction = Vector((math.cos(angle), math.sin(angle), 0.0))
        tangent = Vector((-math.sin(angle), math.cos(angle), 0.0))
        for row in range(rows):
            t = row / (rows - 1)
            center = Vector((0, 0, 0.57)) + direction * (lean * (t ** 1.40))
            center.z += length * t - 0.12 * length * (t ** 2)
            centerline.append(tuple(center + Vector((0, 0, 0.024))))
            half_width = leaf_width * (math.sin(math.pi * t) ** 0.78) + 0.010 * (1.0 - t)
            for side in (-1, 1):
                point = center + tangent * (half_width * side)
                blade_vertices.extend((tuple(point + Vector((0, 0, -0.018))),
                                       tuple(point + Vector((0, 0, 0.018)))))
        blade_faces: list[tuple[int, ...]] = []
        for row in range(rows - 1):
            base_index = row * 4
            next_index = (row + 1) * 4
            blade_faces.extend(((base_index + 1, base_index + 3, next_index + 3, next_index + 1),
                                (base_index, next_index, next_index + 2, base_index + 2),
                                (base_index, base_index + 1, next_index + 1, next_index),
                                (base_index + 2, next_index + 2, next_index + 3, base_index + 3)))
        leaf_mesh = bpy.data.meshes.new(f"{name}-mesh")
        leaf_mesh.from_pydata(blade_vertices, [], blade_faces)
        leaf_mesh.update()
        blade = bpy.data.objects.new(name, leaf_mesh)
        bpy.context.scene.collection.objects.link(blade)
        blade.data.materials.append(mat)
        base.bevel(blade, 0.012, 2)
        vein = base.curve_stroke_3d(f"{name}-center-vein", centerline, 0.010, leaf_vein)
        return blade, vein

    blade_parts: list[bpy.types.Object] = []
    vein_parts: list[bpy.types.Object] = []
    for index, (angle, lean, length, leaf_width) in enumerate([
        (-2.55, 0.38, 1.02, 0.125), (-1.25, 0.25, 1.14, 0.120),
        (0.05, 0.15, 1.25, 0.125), (1.15, 0.32, 1.10, 0.130),
        (2.40, 0.42, 0.96, 0.120),
    ]):
        blade, vein = leaf_blade(f"lanceolate-leaf-{index}", angle, lean, length,
                                 leaf_width, leaf_deep if index % 2 == 0 else leaf_fresh)
        blade_parts.append(blade)
        vein_parts.append(vein)
    leaves = base.join(blade_parts, "five-lanceolate-leaf-blades")
    leaf_veins = base.join(vein_parts, "five-readable-leaf-veins")

    bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=0.18, depth=0.10,
                                         location=(0, 0, 0.58))
    crown = bpy.context.active_object
    crown.name = "deep-green-embedded-leaf-crown"
    crown.data.materials.append(leaf_deep)
    base.bevel(crown, 0.025, 2)

    # 生长纹只覆盖局部弧段，不绕根体一整圈；这正是旧版“交通锥”观感的根因。
    mark_parts: list[bpy.types.Object] = []
    mark_specs = [(0.34, 0.33, -0.95), (0.18, 0.35, -0.30), (-0.02, 0.30, 0.55),
                  (-0.22, 0.24, -0.75), (-0.42, 0.17, 0.15), (-0.58, 0.11, 0.88)]
    for index, (z, radius, center_angle) in enumerate(mark_specs):
        center_x = 0.01 + (0.085 * (0.62 - z) / 1.48)
        points = []
        for step in range(6):
            angle = center_angle - 0.34 + step * 0.136
            points.append((center_x + math.cos(angle) * (radius + 0.003),
                           math.sin(angle) * (radius + 0.003), z + 0.008 * math.sin(step)))
        mark_parts.append(base.curve_stroke_3d(f"partial-growth-mark-{index}", points,
                                               0.006, groove))
    growth_marks = base.join(mark_parts, "six-partial-growth-marks")

    side_root_parts = []
    for index, points in enumerate([
        [(0.305, -0.02, 0.02), (0.36, -0.025, -0.04), (0.40, -0.02, -0.11)],
        [(-0.19, 0.14, -0.20), (-0.25, 0.18, -0.25), (-0.28, 0.21, -0.32)],
        [(0.16, -0.16, -0.43), (0.20, -0.20, -0.48), (0.22, -0.22, -0.54)],
    ]):
        side_root_parts.append(base.curve_stroke_3d(f"fine-side-root-{index}", points,
                                                    0.006, orange))
    side_roots = base.join(side_root_parts, "three-embedded-side-roots")

    root_tail = base.curve_stroke_3d("hooked-fine-root-tail",
                                     [(0.08, 0, -0.83), (0.10, 0.01, -0.91),
                                      (0.13, 0.015, -0.97)], 0.012, orange)

    base.normalize_export_parts(
        [root_body, growth_marks, side_roots, root_tail, crown, leaves, leaf_veins],
        "carrot", output,
    )


BUILDERS = {"carrot": make_carrot}


def main() -> None:
    requested = [arg for arg in sys.argv[sys.argv.index("--") + 1:] if arg] if "--" in sys.argv else []
    names = requested or list(BUILDERS)
    unknown = [name for name in names if name not in BUILDERS]
    if unknown:
        raise SystemExit(f"Unknown farm v2 model(s): {', '.join(unknown)}")
    for name in names:
        base.clear_scene()
        BUILDERS[name](DEFAULT_OUTPUT)


if __name__ == "__main__":
    main()
