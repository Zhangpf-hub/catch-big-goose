"""One-time conversion repair: use exact existing GLB triangles in each FBX."""
from pathlib import Path
import hashlib
import json
import bpy

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'source-assets/models/candidates/duck-series-v1/model-review-b2'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
rows=[]
for id in ('duck-eggtart','duck-steelcup','duck-numberblock'):
    folder=OUT/'models'/id;src=folder/(id+'.glb');dest=folder/(id+'.fbx')
    original=sha(src)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(src))
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.fbx(filepath=str(dest),use_selection=True,object_types={'MESH'},
        axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=False,path_mode='STRIP')
    assert sha(src)==original
    rows.append({'id':id,'glbSha256':original,'fbxSha256':sha(dest),
                 'triangles':sum(len(o.data.polygons) for o in bpy.context.scene.objects if o.type=='MESH')})
(OUT/'qa/fbx-triangle-provenance.json').write_text(json.dumps({
    'method':'FBX exported from existing roundtrip GLB explicit triangles; original GLB and authored blends unchanged.',
    'models':rows},indent=2),'utf-8')
print('B2_FBX_EXPLICIT_TRIANGLES',json.dumps(rows),flush=True)
