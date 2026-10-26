import bpy, os
from mathutils import Vector

CD = r"C:\Users\Administrator\AppData\Local\Temp\cand_models"
OUT = r"F:\FrontEnd\code\game-workspace\catch-the-goose\game\assets\resources\models"

# id: (源文件, 改色 baseColor 或 None 保留, metallic, roughness)
JOBS = {
    "yuanbao":  ("ingot.glb",    (0.92, 0.70, 0.26, 1.0), 1.0, 0.30),
    "baoshi":   ("gem.glb",      (0.17, 0.53, 0.31, 1.0), 0.0, 0.20),
    "yushi":    ("crystal.glb",  (0.22, 0.55, 0.33, 1.0), 0.0, 0.25),
    "jingling": ("pokeball.glb", None, None, None),  # 保留红白配色
}


def wipe():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for c in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for b in list(c):
            try:
                c.remove(b)
            except Exception:
                pass


for name, (src, color, metal, rough) in JOBS.items():
    wipe()
    bpy.ops.import_scene.gltf(filepath=os.path.join(CD, src))
    meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    if not meshes:
        print("NOMESH", name); continue

    # 合并成单一网格,便于统一归一化
    bpy.ops.object.select_all(action='DESELECT')
    for o in meshes:
        o.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
    obj = bpy.context.view_layer.objects.active
    obj.rotation_euler = (0, 0, 0)
    obj.location = (0, 0, 0)
    obj.scale = (1, 1, 1)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    # 归一化:最大边 = 1.0,并居中到原点
    lo = Vector((min(v.co[i] for v in obj.data.vertices) for i in range(3)))
    hi = Vector((max(v.co[i] for v in obj.data.vertices) for i in range(3)))
    center = (lo + hi) / 2
    maxd = max(hi - lo) or 1.0
    s = 1.0 / maxd
    obj.scale = (s, s, s)
    obj.location = (-center.x * s, -center.y * s, -center.z * s)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    # 改色(纯色因子;无贴图,导出为 baseColorFactor)
    if color is not None:
        for m in obj.data.materials:
            if not m or not m.use_nodes:
                continue
            bsdf = m.node_tree.nodes.get("Principled BSDF")
            if not bsdf:
                continue
            for key in ("Base Color", "Alpha"):
                inp = bsdf.inputs.get(key)
                if inp:
                    for link in list(inp.links):
                        m.node_tree.links.remove(link)
            bsdf.inputs["Base Color"].default_value = color
            for k, v in (("Metallic", metal), ("Roughness", rough), ("Alpha", 1.0)):
                inp = bsdf.inputs.get(k)
                if inp:
                    inp.default_value = v

    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, name + ".glb"),
                              export_format='GLB', use_selection=True)
    print("BUILT", name, "maxdim->1.0 faces=", len(obj.data.polygons))

print("DONE")
