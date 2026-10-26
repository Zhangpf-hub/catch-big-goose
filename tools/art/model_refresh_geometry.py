"""Deterministic meshes and checked GLB export shared by individually runnable generators."""
import json
import math
from pathlib import Path

import bpy
import bmesh
from mathutils import Vector
from validate_model_spec import validate

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "source-assets/models/candidates/refresh-2026-09-08"


def begin(spec_path):
    spec = validate(ROOT / spec_path)
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    return spec


def material(name, color, roughness=0.5, metallic=0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return mat


def albedo(mat, name, width, height, pixel):
    image = bpy.data.images.new(name, width=width, height=height, alpha=True)
    values = [channel for y in range(height) for x in range(width)
              for channel in (*pixel(x / (width - 1), y / (height - 1)), 1)]
    if not all(math.isfinite(v) and 0 <= v <= 1 for v in values):
        raise ValueError(f"Invalid texture: {name}")
    if max(values[::4]) - min(values[::4]) < 0.01:
        raise ValueError(f"Texture is unexpectedly flat: {name}")
    image.pixels.foreach_set(values)
    image.pack()
    node = mat.node_tree.nodes.new("ShaderNodeTexImage")
    node.image = image
    mat.node_tree.links.new(node.outputs["Color"], mat.node_tree.nodes.get("Principled BSDF").inputs["Base Color"])


def mesh(name, vertices, faces, mat, uv=None, smooth=True):
    data = bpy.data.meshes.new(name + "-mesh")
    data.from_pydata(vertices, [], faces)
    data.update()
    obj = bpy.data.objects.new(name, data)
    bpy.context.scene.collection.objects.link(obj)
    data.materials.append(mat)
    if uv:
        layer = data.uv_layers.new(name="UVMap")
        for poly in data.polygons:
            for index in poly.loop_indices:
                layer.data[index].uv = uv[data.loops[index].vertex_index]
    for poly in data.polygons:
        poly.use_smooth = smooth
    return obj


def join(objects, name):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.join()
    obj = bpy.context.active_object
    obj.name = name
    return obj


def cube(name, size, location, mat, bevel=0.02, segments=2):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = obj.modifiers.new("rounded-edges", "BEVEL")
        mod.width = bevel
        mod.segments = segments
        bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.data.materials.append(mat)
    for poly in obj.data.polygons:
        poly.use_smooth = True
    mod = obj.modifiers.new("weighted-normals", "WEIGHTED_NORMAL")
    bpy.ops.object.modifier_apply(modifier=mod.name)
    return obj


def tube(name, centers, radii, mat, sides=12):
    vertices, uv = [], []
    for i, point in enumerate(centers):
        tangent = Vector(centers[min(i + 1, len(centers) - 1)]) - Vector(centers[max(0, i - 1)])
        tangent.normalize()
        axis = tangent.cross(Vector((0, 0, 1)))
        if axis.length < 0.01:
            axis = tangent.cross(Vector((0, 1, 0)))
        axis.normalize()
        other = tangent.cross(axis).normalized()
        for j in range(sides):
            angle = j * math.tau / sides
            vertices.append(Vector(point) + radii[i] * (axis * math.cos(angle) + other * math.sin(angle)))
            uv.append((i / max(1, len(centers) - 1), j / sides))
    faces = [(i * sides + j, i * sides + (j + 1) % sides,
              (i + 1) * sides + (j + 1) % sides, (i + 1) * sides + j)
             for i in range(len(centers) - 1) for j in range(sides)]
    faces += [tuple(reversed(range(sides))), tuple(range((len(centers) - 1) * sides, len(centers) * sides))]
    return mesh(name, vertices, faces, mat, uv)


def finish(spec, objects):
    expected = {part["name"] for part in spec["components"]}
    if {obj.name for obj in objects} != expected:
        raise ValueError("Generated parts differ from quality contract")
    bpy.context.view_layer.update()
    points = [obj.matrix_world @ vertex.co for obj in objects for vertex in obj.data.vertices]
    low = Vector(min(p[i] for p in points) for i in range(3))
    high = Vector(max(p[i] for p in points) for i in range(3))
    center = (low + high) / 2
    factor = 1 / max(high - low)
    triangles = 0
    mats = set()
    for obj in objects:
        matrix = obj.matrix_world.copy()
        for vertex in obj.data.vertices:
            vertex.co = (matrix @ vertex.co - center) * factor
        obj.matrix_world.identity()
        bm = bmesh.new()
        bm.from_mesh(obj.data)
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        if any(not edge.is_manifold for edge in bm.edges):
            raise ValueError(f"Open/non-manifold geometry: {obj.name}")
        bm.to_mesh(obj.data)
        bm.free()
        triangles += sum(len(face.vertices) - 2 for face in obj.data.polygons)
        mats.update(slot.material.name for slot in obj.material_slots)
    contract = spec["qualityContract"]
    if triangles > contract["maxTriangles"] or len(mats) > contract["maxMaterials"]:
        raise ValueError(f"Budget exceeded: {triangles} triangles / {len(mats)} materials")
    for obj in objects:
        for slot in obj.material_slots:
            for node in slot.material.node_tree.nodes:
                if node.type == "TEX_IMAGE" and node.image and max(node.image.size) > contract["maxTextureSize"]:
                    raise ValueError(f"Texture budget exceeded: {node.image.name}")
    root = bpy.data.objects.new(spec["id"], None)
    bpy.context.scene.collection.objects.link(root)
    by_name = {obj.name: obj for obj in objects}
    for part in spec["components"]:
        by_name[part["name"]].parent = by_name.get(part["parent"], root)
    bpy.ops.object.select_all(action="DESELECT")
    root.select_set(True)
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = root
    OUTPUT.mkdir(parents=True, exist_ok=True)
    path = OUTPUT / f"{spec['id']}.glb"
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True,
                             export_yup=True, export_cameras=False, export_lights=False)
    report = {"id": spec["id"], "triangles": triangles, "materials": len(mats),
              "components": sorted(expected), "normalizedBounds": list((high - low) * factor),
              "bytes": path.stat().st_size, "closedMeshes": True}
    path.with_suffix(".metrics.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print("PASS", json.dumps(report))
