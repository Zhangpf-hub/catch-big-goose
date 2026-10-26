import bpy, os
from mathutils import Vector

CD = r"C:\Users\Administrator\AppData\Local\Temp\cand_models"
OUT = r"C:\Users\Administrator\AppData\Local\Temp\cand_models"
NAMES = ["ingot", "crystal", "gem"]

scene = bpy.context.scene
scene.render.engine = 'BLENDER_WORKBENCH'
scene.display.shading.light = 'STUDIO'
scene.display.shading.color_type = 'MATERIAL'
scene.render.resolution_x = 320
scene.render.resolution_y = 320


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
    lo = Vector((1e9,)*3); hi = Vector((-1e9,)*3)
    for o in objs:
        if o.type != 'MESH':
            continue
        for c in o.bound_box:
            w = o.matrix_world @ Vector(c)
            lo = Vector((min(lo[i], w[i]) for i in range(3)))
            hi = Vector((max(hi[i], w[i]) for i in range(3)))
    return lo, hi


for name in NAMES:
    wipe()
    p = os.path.join(CD, name + ".glb")
    if not os.path.exists(p):
        print("MISS", name); continue
    bpy.ops.import_scene.gltf(filepath=p)
    objs = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    if not objs:
        print("NOMESH", name); continue
    lo, hi = bbox(objs); center = (lo+hi)/2; size = max((hi-lo)) or 1.0
    cd = bpy.data.cameras.new("cam"); cam = bpy.data.objects.new("cam", cd)
    scene.collection.objects.link(cam); scene.camera = cam
    d = size*2.2
    cam.location = center + Vector((d*0.7, -d*0.9, d*0.65))
    cam.rotation_euler = (center - cam.location).normalized().to_track_quat('-Z','Y').to_euler()
    scene.render.filepath = os.path.join(OUT, name + "_thumb.png")
    bpy.ops.render.render(write_still=True)
    tris = sum(len(o.data.polygons) for o in objs)
    print("OK", name, "faces=", tris)
print("DONE")
