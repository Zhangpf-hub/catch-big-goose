"""Render every playable item from the same game-like camera and lighting.

The output is a visual QA baseline, not a source asset.  Run with Blender:

  blender --background --python tools/art/render_model_audit.py

Optional arguments after ``--``:

  --output <directory>   Override work/audits/model-quality/current
  --only apple,banana    Render a subset
  --azimuth <degrees>    Rotate models around Z for side/back QA
  --models-dir <path>    Read GLB candidates from another directory
  --map-stripped         Replace imported materials with neutral clay for silhouette QA
"""
from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[2]
MODELS = ROOT / "reference-projects/catch-big-goose-cocos/assets/resources/models"
DEFAULT_OUTPUT = ROOT / "work/audits/model-quality/current"

THEMES = {
    "fruit": ["apple", "banana", "grape", "orange", "strawberry", "lemon", "pear", "cherry", "goose"],
    "antique": ["tongqian", "bracelet", "baoshi", "hulu", "yuzhuo", "banzhi", "yuxi", "ruyi", "goose"],
    "farm": ["carrot", "corn", "eggplant", "frog", "pumpkin", "mushroom", "koi", "lotus", "duck"],
    "dessert": ["cupcake", "donut", "icecream", "macaron", "cookie", "cake_slice", "candy", "pudding", "croissant"],
}


def args() -> argparse.Namespace:
    raw = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--only", default="")
    parser.add_argument("--azimuth", type=float, default=-8.0)
    parser.add_argument("--models-dir", type=Path, default=MODELS)
    parser.add_argument("--map-stripped", action="store_true")
    return parser.parse_args(raw)


def clear_imported() -> None:
    for obj in list(bpy.context.scene.objects):
        if obj.get("audit_import"):
            bpy.data.objects.remove(obj, do_unlink=True)


def bounds(objects: list[bpy.types.Object]) -> tuple[Vector, Vector]:
    low = Vector((1e9, 1e9, 1e9))
    high = Vector((-1e9, -1e9, -1e9))
    for obj in objects:
        if obj.type != "MESH":
            continue
        for corner in obj.bound_box:
            point = obj.matrix_world @ Vector(corner)
            low = Vector(min(low[i], point[i]) for i in range(3))
            high = Vector(max(high[i], point[i]) for i in range(3))
    return low, high


def setup_scene() -> None:
    # Start from an empty scene; otherwise Blender's default cube sits directly in front of the
    # imported item and the audit misleadingly renders three giant blank faces.
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    scene = bpy.context.scene
    engines = bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items.keys()
    scene.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in engines else "BLENDER_EEVEE"
    scene.render.resolution_x = 420
    scene.render.resolution_y = 420
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.film_transparent = True
    scene.render.image_settings.color_depth = "8"

    scene.view_settings.look = "AgX - Medium High Contrast"
    world = bpy.data.worlds.get("World") or bpy.data.worlds.new("World")
    scene.world = world
    world.use_nodes = True
    background = world.node_tree.nodes.get("Background")
    background.inputs[0].default_value = (0.055, 0.042, 0.038, 1)
    background.inputs[1].default_value = 0.32

    camera_data = bpy.data.cameras.new("AuditCamera")
    camera_data.type = "ORTHO"
    camera_data.ortho_scale = 1.48
    camera = bpy.data.objects.new("AuditCamera", camera_data)
    scene.collection.objects.link(camera)
    camera.location = (1.65, -2.25, 2.8)
    camera.rotation_euler = (Vector((0, 0, 0.02)) - camera.location).to_track_quat("-Z", "Y").to_euler()
    scene.camera = camera

    lights = [
        ("Key", (2.8, -3.2, 5.0), 720.0, 3.0, (1.0, 0.72, 0.52)),
        ("Fill", (-3.5, -1.0, 3.2), 430.0, 4.0, (0.48, 0.67, 1.0)),
        ("Rim", (1.0, 3.6, 4.2), 620.0, 2.6, (1.0, 0.48, 0.30)),
    ]
    for name, location, energy, size, color in lights:
        data = bpy.data.lights.new(name, "AREA")
        data.energy = energy
        data.shape = "DISK"
        data.size = size
        data.color = color
        light = bpy.data.objects.new(name, data)
        light.location = location
        light.rotation_euler = (Vector((0, 0, 0)) - light.location).to_track_quat("-Z", "Y").to_euler()
        scene.collection.objects.link(light)

def render(name: str, output: Path, azimuth: float, models_dir: Path,
           map_stripped: bool = False) -> None:
    clear_imported()
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=str(models_dir / f"{name}.glb"))
    imported = [obj for obj in bpy.context.scene.objects if obj not in before]
    meshes = [obj for obj in imported if obj.type == "MESH"]
    if not meshes:
        print("SKIP", name, "no mesh")
        return
    for obj in imported:
        obj["audit_import"] = True

    if map_stripped:
        # Blockout 必须只审轮廓和体积，统一中性泥材质可避免高饱和颜色或贴图遮住结构缺陷。
        clay = bpy.data.materials.new("audit-neutral-clay")
        clay.diffuse_color = (0.55, 0.55, 0.55, 1.0)
        clay.use_nodes = True
        principled = clay.node_tree.nodes.get("Principled BSDF")
        principled.inputs["Base Color"].default_value = (0.55, 0.55, 0.55, 1.0)
        principled.inputs["Metallic"].default_value = 0.0
        principled.inputs["Roughness"].default_value = 0.72
        for obj in meshes:
            obj.data.materials.clear()
            obj.data.materials.append(clay)

    # GLB files may contain a transform root above their mesh.  Put all imported roots under one
    # audit pivot and transform only that pivot; moving every imported object would apply the same
    # offset twice to parented meshes and throw them out of frame.
    roots = [obj for obj in imported if obj.parent not in imported]
    pivot = bpy.data.objects.new(f"{name}_AuditPivot", None)
    pivot["audit_import"] = True
    bpy.context.scene.collection.objects.link(pivot)
    for root in roots:
        root.parent = pivot

    bpy.context.view_layer.update()
    low, high = bounds(meshes)
    center = (low + high) * 0.5
    size = max(high - low) or 1.0
    scale = 0.92 / size
    pivot.scale = (scale, scale, scale)
    pivot.location = -center * scale
    # 同一套相机只旋转模型，便于跨版本和多角度检查轮廓、穿插与材质连续性。
    pivot.rotation_euler.z = math.radians(azimuth)
    bpy.context.view_layer.update()

    # Align the model to a shared baseline in the transparent audit frame.
    low, _ = bounds(meshes)
    pivot.location.z += -0.50 - low.z
    bpy.context.view_layer.update()
    final_low, final_high = bounds(meshes)

    # A flat container sits lower than an upright item at the shared baseline.
    # Keep before/after camera geometry identical, with enough room for its front edge.
    bpy.context.scene.camera.data.ortho_scale = 1.70 if name.startswith('basket_') else 1.48

    output.mkdir(parents=True, exist_ok=True)
    bpy.context.scene.render.filepath = str(output / f"{name}.png")
    bpy.ops.render.render(write_still=True)
    triangles = sum(len(poly.vertices) - 2 for obj in meshes for poly in obj.data.polygons)
    materials = len({slot.material.name for obj in meshes for slot in obj.material_slots if slot.material})
    print("RENDERED", name, f"triangles={triangles}", f"materials={materials}",
          f"bounds={tuple(round(v, 3) for v in final_low)}..{tuple(round(v, 3) for v in final_high)}")


def main() -> None:
    options = args()
    if not options.output.is_absolute():
        options.output = ROOT / options.output
    if not options.models_dir.is_absolute():
        options.models_dir = ROOT / options.models_dir
    requested = {item.strip() for item in options.only.split(",") if item.strip()}
    # 显式指定的容器也必须渲染；过去 --only basket_redwood 会静默输出零张图。
    names = sorted(requested) if requested else list(dict.fromkeys(
        item for family in THEMES.values() for item in family))
    for name in names:
        if Path(name).name != name or not (options.models_dir / f"{name}.glb").is_file():
            raise SystemExit(f"Unknown or missing model: {name}")
    setup_scene()
    for name in names:
        render(name, options.output, options.azimuth, options.models_dir, options.map_stripped)


if __name__ == "__main__":
    main()
