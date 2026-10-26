"""渲染水果族的槽位图标 PNG（192×192 透明），沿用 icon_render 的 Workbench 实心着色。"""
import bpy, os
from mathutils import Vector

MODELS = r"F:\FrontEnd\code\game-workspace\catch-the-goose\game\assets\resources\models"
OUT = r"F:\FrontEnd\code\game-workspace\catch-the-goose\game\assets\resources\icons"
ITEMS = ["apple", "banana", "orange", "grape",
         "strawberry", "pear", "lemon", "cherry"]

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


def wipe():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for c in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for b in list(c):
            try:
                c.remove(b)
            except Exception:
                pass


def bbox(objs):
    lo = Vector((1e9,) * 3); hi = Vector((-1e9,) * 3)
    for o in objs:
        if o.type != 'MESH':
            continue
        for c in o.bound_box:
            w = o.matrix_world @ Vector(c)
            lo = Vector((min(lo[i], w[i]) for i in range(3)))
            hi = Vector((max(hi[i], w[i]) for i in range(3)))
    return lo, hi


for name in ITEMS:
    wipe()
    bpy.ops.import_scene.gltf(filepath=os.path.join(MODELS, name + ".glb"))
    objs = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    if not objs:
        print("NOMESH", name); continue
    lo, hi = bbox(objs); center = (lo + hi) / 2; size = max((hi - lo)) or 1.0

    cd = bpy.data.cameras.new("cam"); cam = bpy.data.objects.new("cam", cd)
    scene.collection.objects.link(cam); scene.camera = cam
    cam.data.type = 'ORTHO'
    cam.data.ortho_scale = size * 1.5
    d = size * 3
    cam.location = center + Vector((d * 0.55, -d * 0.9, d * 0.5))
    cam.rotation_euler = (center - cam.location).normalized().to_track_quat('-Z', 'Y').to_euler()

    for loc, e in [((3, -4, 6), 900), ((-4, 2, 3), 350)]:
        ld = bpy.data.lights.new("L", 'AREA'); ld.energy = e * (size * size); ld.size = size * 3
        lo_ = bpy.data.objects.new("L", ld); lo_.location = center + Vector(loc) * size
        lo_.rotation_euler = (center - lo_.location).normalized().to_track_quat('-Z', 'Y').to_euler()
        scene.collection.objects.link(lo_)

    scene.render.filepath = os.path.join(OUT, name + ".png")
    bpy.ops.render.render(write_still=True)
    print("ICON", name)
print("DONE")
