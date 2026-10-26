"""生成通用障碍物「石头」：低模 glb + 槽位图标（Blender 4.5 headless）。

石头是玩法层的干扰物：可拾取、占格、无法三消。视觉上刻意做成冷灰闷暗、
不规则棱角，一眼区别于鲜艳水果 —— 传达「非食物、别拿」。跨主题通用。

用法：
  & "C:\\Program Files\\Blender Foundation\\Blender 4.5\\blender.exe" ^
     --background --python scripts\\gen_rock.py
直接输出到 resources/models/rock.glb 与 resources/icons/rock.png。
"""
import bpy, os, bmesh, random
from mathutils import Vector

MODELS = r"F:\FrontEnd\code\game-workspace\catch-the-goose\game\assets\resources\models"
ICONS = r"F:\FrontEnd\code\game-workspace\catch-the-goose\game\assets\resources\icons"
ROCK_COLOR = (0.20, 0.21, 0.24, 1.0)   # 冷灰，略偏蓝，闷暗


def wipe():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for c in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for b in list(c):
            try:
                c.remove(b)
            except Exception:
                pass


def build_rock():
    random.seed(7)  # 固定种子：可复现
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0)
    o = bpy.context.active_object
    # 顶点沿径向随机凹凸 + 各向异性压扁，做出卵石/碎石的不规则感
    bm = bmesh.new(); bm.from_mesh(o.data)
    for v in bm.verts:
        d = v.co.normalized()
        v.co += d * random.uniform(-0.14, 0.20)
    bm.to_mesh(o.data); bm.free()
    o.scale = (1.0, 0.82, 0.66)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.transform_apply(scale=True)
    bpy.ops.object.shade_flat()  # 平面着色 → 硬朗棱面，石头质感
    m = bpy.data.materials.new("rock"); m.use_nodes = True
    b = m.node_tree.nodes.get("Principled BSDF")
    b.inputs["Base Color"].default_value = ROCK_COLOR
    b.inputs["Roughness"].default_value = 0.88
    b.inputs["Metallic"].default_value = 0.0
    o.data.materials.append(m)
    return o


def normalize_export(o, name):
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
    os.makedirs(MODELS, exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=os.path.join(MODELS, name + ".glb"),
                              export_format='GLB', use_selection=True)
    print("BUILT", name, "faces=", len(o.data.polygons))


def render_icon(o, name):
    """沿用水果图标的 Workbench(STUDIO) 出图：192×192 透明 PNG。"""
    scene = bpy.context.scene
    scene.render.engine = 'BLENDER_WORKBENCH'
    scene.display.shading.light = 'STUDIO'
    scene.display.shading.color_type = 'MATERIAL'
    scene.display.shading.show_shadows = False
    scene.render.resolution_x = 192
    scene.render.resolution_y = 192
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'

    lo = Vector((min((o.matrix_world @ v.co)[i] for v in o.data.vertices) for i in range(3)))
    hi = Vector((max((o.matrix_world @ v.co)[i] for v in o.data.vertices) for i in range(3)))
    center = (lo + hi) / 2; size = max((hi - lo)) or 1.0

    cd = bpy.data.cameras.new("cam"); cam = bpy.data.objects.new("cam", cd)
    scene.collection.objects.link(cam); scene.camera = cam
    cam.data.type = 'ORTHO'; cam.data.ortho_scale = size * 1.5
    d = size * 3
    cam.location = center + Vector((d * 0.55, -d * 0.9, d * 0.5))
    cam.rotation_euler = (center - cam.location).normalized().to_track_quat('-Z', 'Y').to_euler()
    for loc, e in [((3, -4, 6), 900), ((-4, 2, 3), 350)]:
        ld = bpy.data.lights.new("L", 'AREA'); ld.energy = e * (size * size); ld.size = size * 3
        lp = bpy.data.objects.new("L", ld); lp.location = center + Vector(loc) * size
        lp.rotation_euler = (center - lp.location).normalized().to_track_quat('-Z', 'Y').to_euler()
        scene.collection.objects.link(lp)
    os.makedirs(ICONS, exist_ok=True)
    scene.render.filepath = os.path.join(ICONS, name + ".png")
    bpy.ops.render.render(write_still=True)
    print("ICON", name)


wipe()
rock = build_rock()
normalize_export(rock, "rock")
render_icon(rock, "rock")
print("DONE")
