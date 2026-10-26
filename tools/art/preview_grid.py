"""把预览目录里的 GLB 摆成网格渲染一张合影，肉眼验收辨识度与观感。"""
import bpy, os, math
from mathutils import Vector

SRC = r"C:\Users\Administrator\AppData\Local\Temp\fruit_preview"
OUT = os.path.join(SRC, "_grid.png")
NAMES = ["apple", "banana", "orange", "grape",
         "strawberry", "pear", "lemon", "cherry"]

# 清场
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

scene = bpy.context.scene
try:
    scene.render.engine = 'BLENDER_EEVEE_NEXT'
except Exception:
    scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x = 1280
scene.render.resolution_y = 640
scene.render.film_transparent = False
world = bpy.data.worlds[0] if bpy.data.worlds else bpy.data.worlds.new("W")
scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get("Background")
bg.inputs[0].default_value = (0.42, 0.44, 0.48, 1)
bg.inputs[1].default_value = 0.8

cols, gap = 4, 1.6
for i, name in enumerate(NAMES):
    p = os.path.join(SRC, name + ".glb")
    if not os.path.exists(p):
        print("MISS", name); continue
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=p)
    new = [o for o in bpy.context.scene.objects if o not in before and o.type == 'MESH']
    cx = (i % cols) * gap - (cols - 1) * gap / 2
    cy = -(i // cols) * gap + gap / 2
    for o in new:
        o.location = Vector((cx, cy, 0)) + o.location

# 相机：略俯视正交，对准网格中心
target = Vector((0, -0.1, 0))
cam_data = bpy.data.cameras.new("cam")
cam_data.type = 'ORTHO'
cam_data.ortho_scale = 7.4
cam = bpy.data.objects.new("cam", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
cam.location = (0, -5.5, 7.5)
dirv = (target - cam.location).normalized()
cam.rotation_euler = dirv.to_track_quat('-Z', 'Y').to_euler()

for loc, energy in [((4, -6, 10), 1200), ((-5, 3, 6), 500), ((0, 6, 4), 300)]:
    ld = bpy.data.lights.new("L", 'AREA')
    ld.energy = energy; ld.size = 8
    lo = bpy.data.objects.new("L", ld)
    lo.location = loc
    dl = (Vector((0, 0, 0)) - Vector(loc)).normalized()
    lo.rotation_euler = dl.to_track_quat('-Z', 'Y').to_euler()
    scene.collection.objects.link(lo)

scene.render.filepath = OUT
bpy.ops.render.render(write_still=True)
print("GRID ->", OUT)
