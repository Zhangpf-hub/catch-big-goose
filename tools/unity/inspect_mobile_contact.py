import bpy,json
from pathlib import Path
root=Path('source-assets/models/candidates/mobile-runtime-20261024').resolve();rows=[]
for p in root.glob('*/collision.fbx'):
    bpy.ops.wm.read_factory_settings(use_empty=True);bpy.ops.import_scene.fbx(filepath=str(p))
    entries=[]
    for o in bpy.context.scene.objects:
        if o.type=='MESH':o.data.calc_loop_triangles();entries.append(dict(name=o.name,triangles=len(o.data.loop_triangles)))
    rows.append(dict(id=p.parent.name,entries=entries))
(root/'contact-audit.json').write_text(json.dumps(rows,indent=2),encoding='utf-8');print(json.dumps(rows))
