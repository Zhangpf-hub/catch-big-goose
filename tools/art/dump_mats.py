import bpy, os

MODELS = r"F:\FrontEnd\code\game-workspace\catch-the-goose\game\assets\resources\models"
CHECK = ["pixiu", "mile", "baicai", "pingankou", "hulu"]


def wipe():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for c in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for b in list(c):
            try:
                c.remove(b)
            except Exception:
                pass


for name in CHECK:
    wipe()
    p = os.path.join(MODELS, name + ".glb")
    if not os.path.exists(p):
        print(name, "MISS")
        continue
    bpy.ops.import_scene.gltf(filepath=p)
    print("====", name, "====")
    for m in bpy.data.materials:
        if not m.use_nodes:
            print("  ", m.name, "no-nodes")
            continue
        bsdf = m.node_tree.nodes.get("Principled BSDF")
        info = {"blend": m.blend_method}
        tex = False
        if bsdf:
            bc = bsdf.inputs.get("Base Color")
            info["baseColor"] = tuple(round(v, 3) for v in bc.default_value) if bc else None
            info["baseColor_linked"] = bool(bc.is_linked) if bc else None
            al = bsdf.inputs.get("Alpha")
            info["alpha"] = round(al.default_value, 3) if al else None
            for key in ("Metallic", "Roughness", "Transmission Weight", "Transmission"):
                inp = bsdf.inputs.get(key)
                if inp:
                    info[key] = round(inp.default_value, 3)
            if bc and bc.is_linked:
                tex = True
        info["hasTex"] = tex
        print("  MAT", m.name, info)
