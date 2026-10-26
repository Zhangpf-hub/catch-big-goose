"""Prepare the licensed Sketchfab guardian-lion scan for the yuxi model.

Run with Blender:
  blender --background --python tools/art/prepare_yuxi_guardian_source.py -- \
    --input source-assets/models/sources/yuxi/rvscanners-chinese-guardian-lion/original/scene.gltf \
    --output source-assets/models/processed/yuxi/guardian-lion-game.glb \
    --target-faces 12000
"""

from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

import bmesh
import bpy
from mathutils import Vector


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--target-faces", type=int, default=18_000)
    parser.add_argument("--voxel-size", type=float, default=0.0045)
    parser.add_argument("--base-cut", type=float, default=0.0)
    return parser.parse_args(sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else [])


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def world_bounds(obj: bpy.types.Object) -> tuple[Vector, Vector]:
    corners = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
    return (
        Vector((min(p.x for p in corners), min(p.y for p in corners), min(p.z for p in corners))),
        Vector((max(p.x for p in corners), max(p.y for p in corners), max(p.z for p in corners))),
    )


def join_meshes(meshes: list[bpy.types.Object]) -> bpy.types.Object:
    # Sketchfab 为绕开单个 primitive 的顶点限制把扫描件拆成多段；先合并再减面，
    # 才能用统一误差预算保住脸部和鬃毛，而不是让每段分别损失轮廓。
    bpy.ops.object.select_all(action="DESELECT")
    for obj in meshes:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
    lion = bpy.context.active_object
    lion.name = "guardian-lion-scan"
    # glTF 根节点带有校正矩阵。合并后若继续保留父节点，后面的居中会在局部坐标与
    # 世界坐标之间错位，导出时狮子会被推离原点；先保留世界矩阵再解除父子关系。
    world_matrix = lion.matrix_world.copy()
    lion.parent = None
    lion.matrix_world = world_matrix
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return lion


def warm_jade_material() -> bpy.types.Material:
    material = bpy.data.materials.new("guardian_warm_nephrite")
    material.diffuse_color = (0.82, 0.72, 0.52, 1.0)
    material.use_nodes = True
    principled = material.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Base Color"].default_value = (0.82, 0.72, 0.52, 1.0)
    principled.inputs["Roughness"].default_value = 0.31
    principled.inputs["Metallic"].default_value = 0.0
    if "Coat Weight" in principled.inputs:
        principled.inputs["Coat Weight"].default_value = 0.22
        principled.inputs["Coat Roughness"].default_value = 0.18
    return material


def normalize(lion: bpy.types.Object) -> None:
    vertices = lion.data.vertices
    minimum = Vector(tuple(min(vertex.co[axis] for vertex in vertices) for axis in range(3)))
    maximum = Vector(tuple(max(vertex.co[axis] for vertex in vertices) for axis in range(3)))
    size = maximum - minimum
    center = (minimum + maximum) * 0.5
    lion.location -= center
    bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)

    # 扫描件最长边是身体方向；统一缩放到 1.0，后续玉玺生成器只负责摆放，
    # 避免每次改印台时意外重复缩放源雕塑。
    scale = 1.0 / max(size)
    lion.scale = (scale, scale, scale)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

    # 保证最小 Z 落在承托面上；如果源文件本身横躺，后续预览会明确暴露，
    # 不在这里凭猜测破坏雕塑的真实朝向。
    vertices = lion.data.vertices
    minimum = Vector(tuple(min(vertex.co[axis] for vertex in vertices) for axis in range(3)))
    lion.location.z -= minimum.z
    bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)


def crop_pedestal(lion: bpy.types.Object, cut_height: float) -> None:
    """Remove the scan's display plinth while retaining the thin slab under the paws."""
    if cut_height <= 0:
        return
    mesh = lion.data
    editable = bmesh.new()
    editable.from_mesh(mesh)
    geometry = list(editable.verts) + list(editable.edges) + list(editable.faces)
    bmesh.ops.bisect_plane(
        editable,
        geom=geometry,
        plane_co=Vector((0, 0, cut_height)),
        plane_no=Vector((0, 0, 1)),
        clear_inner=True,
        clear_outer=False,
    )
    boundary = [edge for edge in editable.edges if edge.is_boundary]
    if boundary:
        bmesh.ops.holes_fill(editable, edges=boundary, sides=0)
    editable.to_mesh(mesh)
    editable.free()
    mesh.update()

def main() -> None:
    options = parse_args()
    source = options.input.resolve()
    output = options.output.resolve()
    output.parent.mkdir(parents=True, exist_ok=True)

    clear_scene()
    bpy.ops.import_scene.gltf(filepath=str(source))
    meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    if not meshes:
        raise RuntimeError(f"No mesh objects found in {source}")

    lion = join_meshes(meshes)
    original_faces = len(lion.data.polygons)
    normalize(lion)

    # 原始扫描为 28 个空间分片，直接 Decimate 会把分片边界保留成裂缝和锯齿。
    # 先在归一化尺度上体素融合成闭合雕塑，再减面，能消除黑线并保住大轮廓。
    lion.data.remesh_voxel_size = options.voxel_size
    lion.data.remesh_voxel_adaptivity = 0.0
    bpy.context.view_layer.objects.active = lion
    lion.select_set(True)
    bpy.ops.object.voxel_remesh()
    crop_pedestal(lion, options.base_cut)
    normalize(lion)
    remeshed_faces = len(lion.data.polygons)

    # 分段收敛最多三轮，避免一次极低比例折叠集中破坏脸部特征。
    for pass_index in range(3):
        current_faces = len(lion.data.polygons)
        if current_faces <= int(options.target_faces * 1.08):
            break
        modifier = lion.modifiers.new(f"guardian-mobile-decimation-{pass_index + 1}", "DECIMATE")
        modifier.decimate_type = "COLLAPSE"
        modifier.ratio = max(0.0001, options.target_faces / current_faces)
        modifier.use_collapse_triangulate = True
        bpy.context.view_layer.objects.active = lion
        bpy.ops.object.modifier_apply(modifier=modifier.name)

    lion.data.materials.clear()
    lion.data.materials.append(warm_jade_material())
    for polygon in lion.data.polygons:
        polygon.use_smooth = True

    minimum, maximum = world_bounds(lion)
    print(
        "GUARDIAN_PREP",
        f"source_faces={original_faces}",
        f"remeshed_faces={remeshed_faces}",
        f"output_faces={len(lion.data.polygons)}",
        f"bounds_min={tuple(round(value, 4) for value in minimum)}",
        f"bounds_max={tuple(round(value, 4) for value in maximum)}",
    )

    bpy.ops.object.select_all(action="DESELECT")
    lion.select_set(True)
    bpy.context.view_layer.objects.active = lion
    bpy.ops.export_scene.gltf(
        filepath=str(output),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_yup=True,
        export_materials="EXPORT",
    )


if __name__ == "__main__":
    main()
