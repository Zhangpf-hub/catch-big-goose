import bpy, os, math
from mathutils import Vector

MODELS = r"F:\FrontEnd\code\game-workspace\catch-the-goose\game\assets\resources\models"
OUT = r"C:\Users\Administrator\AppData\Local\Temp\model_thumbs"
os.makedirs(OUT, exist_ok=True)
ITEMS = ["goose", "baicai", "mile", "pixiu", "banzhi", "bracelet",
         "hulu", "pingankou", "tongqian", "yupai", "yuzhuo"]

scene = bpy.context.scene
try:
    scene.render.engine = 'BLENDER_EEVEE_NEXT'
except Exception:
    scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x = 320
scene.render.resolution_y = 320
scene.render.film_transparent = False
# neutral gray world so material colors read true
world = bpy.data.worlds.new("W") if not bpy.data.worlds else bpy.data.worlds[0]
scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get("Background")
if bg:
    bg.inputs[0].default_value = (0.5, 0.5, 0.5, 1)
    bg.inputs[1].default_value = 1.0


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
    lo = Vector((1e9, 1e9, 1e9))
    hi = Vector((-1e9, -1e9, -1e9))
    for o in objs:
        if o.type != 'MESH':
            continue
        for corner in o.bound_box:
            w = o.matrix_world @ Vector(corner)
            lo = Vector((min(lo[i], w[i]) for i in range(3)))
            hi = Vector((max(hi[i], w[i]) for i in range(3)))
    return lo, hi


for name in ITEMS:
    wipe()
    path = os.path.join(MODELS, name + ".glb")
    if not os.path.exists(path):
        print("MISS", name)
        continue
    bpy.ops.import_scene.gltf(filepath=path)
    objs = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    if not objs:
        print("NOMESH", name)
        continue
    lo, hi = bbox(objs)
    center = (lo + hi) / 2
    size = max((hi - lo)) or 1.0

    # camera: 3/4 front-top view
    cam_data = bpy.data.cameras.new("cam")
    cam = bpy.data.objects.new("cam", cam_data)
    scene.collection.objects.link(cam)
    scene.camera = cam
    d = size * 2.2
    cam.location = center + Vector((d * 0.7, -d * 0.9, d * 0.65))
    dirv = (center - cam.location).normalized()
    cam.rotation_euler = dirv.to_track_quat('-Z', 'Y').to_euler()
    cam_data.lens = 50

    # key + fill light
    for loc, energy in [((3, -4, 6), 800), ((-4, 2, 3), 300)]:
        ld = bpy.data.lights.new("L", 'AREA')
        ld.energy = energy * (size * size)
        ld.size = size * 3
        lo_ = bpy.data.objects.new("L", ld)
        lo_.location = center + Vector(loc) * size
        dl = (center - lo_.location).normalized()
        lo_.rotation_euler = dl.to_track_quat('-Z', 'Y').to_euler()
        scene.collection.objects.link(lo_)

    scene.render.filepath = os.path.join(OUT, name + ".png")
    bpy.ops.render.render(write_still=True)
    print("OK", name)

print("DONE ->", OUT)
