"""Blender: preserve original UVs, normals and material groups; normalize only units."""
import json,sys
from pathlib import Path
import bpy
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'source-assets/models/candidates/reference-look-20261025'
if '--root' in sys.argv:OUT=ROOT/sys.argv[sys.argv.index('--root')+1]
only=sys.argv[sys.argv.index('--only')+1] if '--only' in sys.argv else None
results=json.loads((OUT/'results.json').read_text('utf-8')) if only and (OUT/'results.json').exists() else []
for entry in json.loads((OUT/'batch.json').read_text('utf-8')):
    if only and entry['id']!=only:continue
    bpy.ops.wm.open_mainfile(filepath=entry['source'])
    bpy.context.preferences.filepaths.save_version=0
    objects=[o for o in bpy.data.objects if o.type=='MESH']
    for obj in objects:obj.hide_set(False);obj.hide_viewport=False;obj.hide_select=False;obj.hide_render=False
    info={name:m for m in entry['materials'] for name in [m['sourceName'],m['name']]}
    canonical={}
    for obj in objects:
        for slot,mat in enumerate(obj.data.materials):
            m=info.get(mat.name) or info.get(mat.name.rsplit('.',1)[0]);assert m,(entry['id'],mat.name)
            if m['name'] in canonical:
                obj.data.materials[slot]=canonical[m['name']];continue
            canonical[m['name']]=mat
            mat.name=m['name'];mat.use_nodes=True
            bsdf=mat.node_tree.nodes.get('Principled BSDF');bsdf.inputs['Roughness'].default_value=.5
            bsdf.inputs['Base Color'].default_value=m['color']
            bsdf.inputs['Alpha'].default_value=m['opacity'];mat.surface_render_method='DITHERED' if m['glass'] else 'DITHERED'
    bpy.ops.object.select_all(action='DESELECT')
    for obj in objects:obj.select_set(True)
    bpy.context.view_layer.objects.active=objects[0];bpy.ops.object.join();obj=bpy.context.object
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    points=[obj.matrix_world@Vector(v) for v in obj.bound_box]
    lo=Vector([min(v[j] for v in points) for j in range(3)]);hi=Vector([max(v[j] for v in points) for j in range(3)])
    center=(lo+hi)*.5;scale=1/max(hi-lo)
    for vertex in obj.data.vertices:vertex.co=(vertex.co-center)*scale
    obj.data.update()
    # Splitting by source material permits independent transparent sorting/casting.
    bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.separate(type='MATERIAL');bpy.ops.object.mode_set(mode='OBJECT')
    objects=[o for o in bpy.context.scene.objects if o.type=='MESH' and len(o.data.polygons)>0]
    # Some source scenes retain disconnected objects with the same material.
    # Consolidate those objects into one renderer per original material role.
    groups={}
    for obj in objects:
        used={p.material_index for p in obj.data.polygons}
        assert len(used)==1,(entry['id'],obj.name,used)
        mat=obj.data.materials[next(iter(used))]
        groups.setdefault(mat.name,[]).append(obj)
    for group in groups.values():
        if len(group)<2:continue
        bpy.ops.object.select_all(action='DESELECT')
        for obj in group:obj.select_set(True)
        bpy.context.view_layer.objects.active=group[0];bpy.ops.object.join()
    objects=[o for o in bpy.context.scene.objects if o.type=='MESH' and len(o.data.polygons)>0]
    assert len(objects)==len(entry['materials']),(entry['id'],len(objects),len(entry['materials']))
    triangles=0
    for i,obj in enumerate(objects):
        bpy.context.view_layer.objects.active=obj;bpy.ops.object.material_slot_remove_unused()
        obj.name=entry['id']+'_part'+str(i);obj.data.calc_loop_triangles();triangles+=len(obj.data.loop_triangles)
    assert triangles==entry['expectedTriangles'],(entry['id'],triangles,entry['expectedTriangles'])
    folder=OUT/entry['id'];bpy.ops.object.select_all(action='DESELECT')
    for obj in objects:obj.select_set(True)
    bpy.ops.wm.save_as_mainfile(filepath=str(folder/(entry['id']+'.blend')))
    bpy.ops.export_scene.fbx(filepath=str(folder/(entry['id']+'.fbx')),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,path_mode='STRIP')
    bpy.ops.export_scene.gltf(filepath=str(folder/(entry['id']+'.glb')),export_format='GLB',use_selection=True,export_yup=True,export_animations=False)
    bpy.ops.wm.read_factory_settings(use_empty=True);bpy.ops.import_scene.gltf(filepath=str(folder/(entry['id']+'.glb')))
    roundtrip=[o for o in bpy.context.scene.objects if o.type=='MESH'];count=0
    points=[]
    for obj in roundtrip:
        obj.data.calc_loop_triangles();count+=len(obj.data.loop_triangles);points.extend(obj.matrix_world@Vector(v) for v in obj.bound_box)
    dims=[max(v[j] for v in points)-min(v[j] for v in points) for j in range(3)]
    assert count==triangles and abs(max(dims)-1)<.0001,(entry['id'],count,dims)
    row=dict(id=entry['id'],triangles=triangles,parts=len(objects),materials=len(entry['materials']),dimensions=dims,glbRoundtrip=True)
    (folder/'metrics.json').write_text(json.dumps(row,indent=2),encoding='utf-8');results=[x for x in results if x['id']!=entry['id']];results.append(row)
(OUT/'results.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
