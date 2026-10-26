"""把第三方 3D 生成服务的 GLB 处理成本作可用的资源（Blender 一次过完成）。

生成件的固有问题与对策：
  1. 概念图若是多视图拼版，图生 3D 会把每个视图各重建成一个实体
     → 焊接后按顶点数取最大连通块，顺带清掉噪点碎片；
     （只需要这一步时，也可以用 tools/art/keep-largest-glb-component.cjs）
  2. 顶点沿 UV 缝未焊接，直接减面会沿缝撕开 → 先 remove_doubles 再 Decimate；
  3. 面数与贴图远超移动端预算 → Decimate COLLAPSE 到目标面数；
  4. 材质带 KHR_materials_specular（specularColorFactor 常被拉到 2.0）与
     metallicRoughness 贴图，在本作弱环境光下镜面压过漫反射、整件发暗
     → 统一收敛成 metallic=0 + 固定 roughness；经 Blender 重新导出后
     specular 扩展自然消失。铜钱 v2「Blender 里清楚、游戏里发黑」是同一个坑。

最后按本作约定归一化：几何居中、最大边 = 1.0、Y 轴向上，并把节点/网格/材质名
统一成模型 id。

用法：
  blender --background --python tools/art/prepare_generated_model.py -- \
    --input <生成件.glb> --output <候选.glb> --target-faces 6000 \
    --keep-largest --name basket_farm
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
    parser.add_argument("--target-faces", type=int, default=4000)
    parser.add_argument("--weld", type=float, default=1e-5)
    parser.add_argument("--keep-largest", action="store_true")
    parser.add_argument("--smooth-angle", type=float, default=35.0)
    parser.add_argument("--roughness", type=float, default=0.55)
    # 节点名必须等于游戏内的模型 id。Cocos 的 prefab 子资源虽按**文件名**命名，
    # 但网格与材质名会进 subMetas，保持一致才好排查。
    parser.add_argument("--name", default="")
    return parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else [])


def join_all() -> bpy.types.Object:
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    if not meshes:
        raise SystemExit("导入结果里没有网格")
    bpy.ops.object.select_all(action="DESELECT")
    for obj in meshes:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    if len(meshes) > 1:
        bpy.ops.object.join()
    return bpy.context.view_layer.objects.active


def weld_and_isolate(obj: bpy.types.Object, weld: float, keep_largest: bool) -> None:
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    before = len(bm.verts)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=weld)
    bm.verts.ensure_lookup_table()
    print(f"WELD verts={before} -> {len(bm.verts)}")

    seen: set[int] = set()
    groups: list[set[int]] = []
    for vert in bm.verts:
        if vert.index in seen:
            continue
        stack = [vert]
        comp: set[int] = set()
        while stack:
            cur = stack.pop()
            if cur.index in comp:
                continue
            comp.add(cur.index)
            for edge in cur.link_edges:
                other = edge.other_vert(cur)
                if other.index not in comp:
                    stack.append(other)
        seen |= comp
        groups.append(comp)

    stats = []
    for comp in groups:
        pts = [bm.verts[i].co for i in comp]
        lo = Vector((min(p[i] for p in pts) for i in range(3)))
        hi = Vector((max(p[i] for p in pts) for i in range(3)))
        stats.append((len(comp), hi - lo, comp))
    stats.sort(key=lambda row: -row[0])
    total = sum(row[0] for row in stats) or 1
    print(f"COMPONENTS n={len(groups)}")
    for count, size, _ in stats[:6]:
        print(f"  verts={count:>7} ({count / total * 100:5.1f}%) "
              f"size=({size.x:.3f},{size.y:.3f},{size.z:.3f})")

    if keep_largest and len(stats) > 1:
        keep = stats[0][2]
        doomed = [v for v in bm.verts if v.index not in keep]
        bmesh.ops.delete(bm, geom=doomed, context="VERTS")
        print(f"KEEP largest ({stats[0][0] / total * 100:.1f}%), dropped {len(stats) - 1} others")

    bm.to_mesh(obj.data)
    bm.free()
    obj.data.update()


def decimate(obj: bpy.types.Object, target: int) -> None:
    faces = len(obj.data.polygons)
    if faces <= target:
        print(f"DECIMATE skipped faces={faces} <= target={target}")
        return
    modifier = obj.modifiers.new("decimate", "DECIMATE")
    modifier.decimate_type = "COLLAPSE"
    modifier.ratio = target / faces
    modifier.use_collapse_triangulate = True
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    print(f"DECIMATE faces={faces} -> {len(obj.data.polygons)}")


def tune_materials(obj: bpy.types.Object, roughness: float) -> None:
    """去掉 metallicRoughness 贴图与金属度，关闭双面渲染。"""
    for material in obj.data.materials:
        if not material or not material.node_tree:
            continue
        bsdf = next((n for n in material.node_tree.nodes if n.type == "BSDF_PRINCIPLED"), None)
        if bsdf is None:
            continue
        # 只断链接不够：Blender 的 glTF 导出器仍会把孤立的贴图节点写进
        # metallicRoughnessTexture，白占体积且继续压暗漫反射。必须整个节点删掉。
        for socket in ("Metallic", "Roughness"):
            link = next((l for l in material.node_tree.links
                         if l.to_node is bsdf and l.to_socket.name == socket), None)
            if link:
                source = link.from_node
                material.node_tree.links.remove(link)
                for node in list(material.node_tree.nodes):
                    if node is source or (node.type == "TEX_IMAGE" and node.image
                                          and any(k in (node.image.name or "").lower()
                                                  for k in ("metallic", "rough"))):
                        material.node_tree.nodes.remove(node)
        bsdf.inputs["Metallic"].default_value = 0.0
        bsdf.inputs["Roughness"].default_value = roughness
        material.use_backface_culling = True
    print(f"MATERIAL metallic=0 roughness={roughness} backface_culling=True")


def normalize(obj: bpy.types.Object) -> None:
    obj.rotation_euler = (0.0, 0.0, 0.0)
    obj.location = (0.0, 0.0, 0.0)
    obj.scale = (1.0, 1.0, 1.0)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    lo = Vector((min(v.co[i] for v in obj.data.vertices) for i in range(3)))
    hi = Vector((max(v.co[i] for v in obj.data.vertices) for i in range(3)))
    center = (lo + hi) / 2
    longest = max(hi - lo) or 1.0
    factor = 1.0 / longest
    obj.scale = (factor, factor, factor)
    obj.location = (-center.x * factor, -center.y * factor, -center.z * factor)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    lo = Vector((min(v.co[i] for v in obj.data.vertices) for i in range(3)))
    hi = Vector((max(v.co[i] for v in obj.data.vertices) for i in range(3)))
    size = hi - lo
    print(f"NORMALIZE size=({size.x:.3f},{size.y:.3f},{size.z:.3f}) "
          f"bounds=({lo.x:.3f},{lo.y:.3f},{lo.z:.3f})..({hi.x:.3f},{hi.y:.3f},{hi.z:.3f})")


def main() -> None:
    options = parse_args()
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.gltf(filepath=str(options.input))

    obj = join_all()
    print(f"IMPORT faces={len(obj.data.polygons)} verts={len(obj.data.vertices)} "
          f"uv={[l.name for l in obj.data.uv_layers]} materials={len(obj.data.materials)}")

    weld_and_isolate(obj, options.weld, options.keep_largest)
    decimate(obj, options.target_faces)

    if options.smooth_angle > 0:
        bpy.ops.object.select_all(action="DESELECT")
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.shade_smooth_by_angle(angle=math.radians(options.smooth_angle))

    tune_materials(obj, options.roughness)
    normalize(obj)

    name = options.name or options.output.stem
    obj.name = name
    obj.data.name = name
    for index, material in enumerate(obj.data.materials):
        if material:
            material.name = name if index == 0 else f"{name}_{index}"
    print(f"RENAME {name}")

    options.output.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.export_scene.gltf(filepath=str(options.output), export_format="GLB",
                              use_selection=True, export_apply=True)
    print(f"EXPORT {options.output} faces={len(obj.data.polygons)}")


if __name__ == "__main__":
    main()
