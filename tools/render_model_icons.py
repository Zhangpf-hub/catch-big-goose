import bpy
import math
import os
import sys
from pathlib import Path
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "reference-projects/catch-big-goose-cocos/assets/resources/models"
OUTPUT_DIR = ROOT / "reference-projects/catch-big-goose-cocos/assets/resources/icons"


def requested_model_ids() -> set[str]:
    """Allow `-- hulu,yuxi` so one model update never rewrites every icon."""
    if "--" not in sys.argv:
        return set()
    return {
        item.strip()
        for argument in sys.argv[sys.argv.index("--") + 1:]
        for item in argument.split(",")
        if item.strip()
    }


def look_at(obj, target):
    obj.rotation_euler = (Vector(target) - obj.location).to_track_quat('-Z', 'Y').to_euler()


def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)


def add_light(name, location, energy, size, color):
    data = bpy.data.lights.new(name, 'AREA')
    data.energy = energy
    data.shape = 'DISK'
    data.size = size
    data.color = color
    light = bpy.data.objects.new(name, data)
    bpy.context.scene.collection.objects.link(light)
    light.location = location
    look_at(light, (0, 0, 0))


def render_icon(source_path, output_path):
    clear_scene()
    bpy.ops.import_scene.gltf(filepath=source_path)
    imported = [obj for obj in bpy.context.scene.objects if obj.type in {'MESH', 'EMPTY'}]
    meshes = [obj for obj in imported if obj.type == 'MESH']
    if not meshes:
        return

    root = bpy.data.objects.new('IconRoot', None)
    bpy.context.scene.collection.objects.link(root)
    for obj in imported:
        if obj.parent is None:
            obj.parent = root

    corners = []
    for obj in meshes:
        corners.extend(obj.matrix_world @ Vector(corner) for corner in obj.bound_box)
    low = Vector((min(p.x for p in corners), min(p.y for p in corners), min(p.z for p in corners)))
    high = Vector((max(p.x for p in corners), max(p.y for p in corners), max(p.z for p in corners)))
    center = (low + high) * 0.5
    max_dim = max(high.x - low.x, high.y - low.y, high.z - low.z)
    # Blender Object 的变换顺序是先缩放子节点、再叠加父节点位移。
    # 旧代码直接 root.location = -center，随后再缩放，实际中心会变成
    # (scale - 1) * center，带原始根偏移的 GLB 因而被推到画布边缘甚至裁掉。
    scale_value = 1.75 / max_dim
    root.scale = (scale_value,) * 3
    root.location = -center * scale_value
    bpy.context.view_layer.update()

    camera_data = bpy.data.cameras.new('IconCamera')
    camera = bpy.data.objects.new('IconCamera', camera_data)
    bpy.context.scene.collection.objects.link(camera)
    camera.location = (3.2, -4.4, 3.0)
    camera_data.type = 'ORTHO'
    look_at(camera, (0, 0, 0))
    bpy.context.scene.camera = camera
    bpy.context.view_layer.update()

    # 按最终观察角度下的投影包围盒自适应正交相机，并留 18% 安全边距。
    # 不能只用世界轴 max_dim：细长/扁平模型旋转到相机空间后对角线可能更大。
    camera_inverse = camera.matrix_world.inverted()
    projected = []
    for obj in meshes:
        projected.extend(camera_inverse @ (obj.matrix_world @ Vector(corner)) for corner in obj.bound_box)
    projected_width = max(p.x for p in projected) - min(p.x for p in projected)
    projected_height = max(p.y for p in projected) - min(p.y for p in projected)
    camera_data.ortho_scale = max(projected_width, projected_height) * 1.18

    add_light('Key', (3.8, -3.0, 5.0), 950, 4.0, (1.0, 0.88, 0.72))
    add_light('Fill', (-4.0, -1.0, 2.6), 620, 4.5, (0.60, 0.78, 1.0))
    add_light('Rim', (1.0, 4.5, 4.0), 720, 3.0, (0.75, 1.0, 0.86))

    scene = bpy.context.scene
    engines = bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items.keys()
    scene.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in engines else "BLENDER_EEVEE"
    scene.render.resolution_x = 192
    scene.render.resolution_y = 192
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'
    scene.render.film_transparent = True
    scene.render.filepath = output_path
    scene.render.image_settings.color_depth = '8'
    scene.view_settings.look = 'AgX - Medium High Contrast'
    bpy.ops.render.render(write_still=True)


OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
requested = requested_model_ids()
for source_path in sorted(SOURCE_DIR.glob("*.glb")):
    model_id = source_path.stem
    if requested and model_id not in requested:
        continue
    render_icon(str(source_path), str(OUTPUT_DIR / f"{model_id}.png"))
    print("ICON", model_id)
