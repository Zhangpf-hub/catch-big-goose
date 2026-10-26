import bpy, os

MODELS = r"F:\FrontEnd\code\game-workspace\catch-the-goose\game\assets\resources\models"

# 目标:纯色不透明。断开 baseColor 贴图(现有贴图色不对/半透),给纯色 + 关透射 + OPAQUE。
JOBS = {
    "pixiu": {"color": (0.17, 0.53, 0.31, 1.0), "metallic": 0.0, "roughness": 0.35},
    "mile":  {"color": (0.92, 0.70, 0.26, 1.0), "metallic": 1.0, "roughness": 0.28},
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


for name, spec in JOBS.items():
    wipe()
    p = os.path.join(MODELS, name + ".glb")
    bpy.ops.import_scene.gltf(filepath=p)
    for m in bpy.data.materials:
        m.use_nodes = True
        try:
            m.blend_method = 'OPAQUE'
        except Exception:
            pass
        bsdf = m.node_tree.nodes.get("Principled BSDF")
        if not bsdf:
            continue
        # 断开 baseColor 与 Alpha 的贴图连线(半透就来自 Alpha 走贴图),改纯色不透明。
        for key in ("Base Color", "Alpha"):
            inp = bsdf.inputs.get(key)
            if inp:
                for link in list(inp.links):
                    m.node_tree.links.remove(link)
        bc = bsdf.inputs.get("Base Color")
        if bc:
            bc.default_value = spec["color"]
        for k, v in (("Metallic", spec["metallic"]), ("Roughness", spec["roughness"]),
                     ("Transmission Weight", 0.0), ("Transmission", 0.0), ("Alpha", 1.0)):
            inp = bsdf.inputs.get(k)
            if inp:
                inp.default_value = v
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(filepath=p, export_format='GLB', use_selection=True)
    print("RECOLORED", name)

print("DONE")
