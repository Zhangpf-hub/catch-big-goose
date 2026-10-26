"""UV/material-only round-container adaptation; original geometry stays unchanged."""
import bpy,json,math,hashlib,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'source-assets/models/candidates/round-surfaces-20261025';OUT.mkdir(parents=True,exist_ok=True)
reference=ROOT/'projects/catch-big-goose-unity/Assets/Resources/ReferenceTextures'
existing={hashlib.sha256(p.read_bytes()).hexdigest():'ReferenceTextures/'+p.stem for p in reference.glob('*.png')}
report=[]
for theme in ['breakfast','barbecue','countryside','toys','grocery']:
    mid='round_'+theme+'_r4';folder=OUT/mid;folder.mkdir(exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(ROOT/'source-assets/models/candidates/r4-scenes-20261025/containers'/mid/(mid+'.blend')))
    bpy.context.preferences.filepaths.save_version=0
    obj=next(o for o in bpy.context.scene.objects if o.type=='MESH');mesh=obj.data
    geometry=[list(v.co) for v in mesh.vertices];triangles=len(mesh.polygons)
    uv=mesh.uv_layers.active or mesh.uv_layers.new(name='UVMap')
    for poly in mesh.polygons:
        planar=abs(poly.normal.z)>.7
        us=[(math.atan2(mesh.vertices[mesh.loops[li].vertex_index].co.y,mesh.vertices[mesh.loops[li].vertex_index].co.x)/math.tau)%1 for li in poly.loop_indices]
        seam=max(us)-min(us)>.5
        for li,u in zip(poly.loop_indices,us):
            v=mesh.vertices[mesh.loops[li].vertex_index].co
            uv.data[li].uv=(v.x/4.1+.5,v.y/4.1+.5) if planar else (u+(1 if seam and u<.5 else 0),v.z*2+.2)
    source=ROOT/'reference-projects/competitor-goose/2026-10-25-containers/models'/('scene_'+theme)/'source.json';data=json.loads(source.read_text('utf-8'))
    raw=list(data['materials'].values());materials=[]
    def texture(path,name):
        digest=hashlib.sha256(path.read_bytes()).hexdigest()
        if digest in existing:return existing[digest]
        shutil.copy2(path,folder/(name+'.png'));return 'Models/'+mid+'/'+name
    for i,mat in enumerate(mesh.materials):
        selected=raw[min(i,len(raw)-1)] if theme in ['breakfast','toys','grocery'] else next(m for m in raw if m['name']==('BarbecueNetMa' if theme=='barbecue' and i==0 else 'BarbecueIronTableMa' if theme=='barbecue' else 'FireTableMetalMa'))
        tex=selected.get('textures',{});base=None
        if theme=='breakfast':base=texture(source.parent/raw[0]['textures']['_BaseColor']['file'],'surface')
        elif theme=='barbecue' and i==0:base=texture(source.parent/tex['_BaseColor']['file'],'grill')
        color=[1,1,1,1] if base else list(mat.diffuse_color)
        if not base and theme in ['countryside','grocery']:
            # Our circular wood UV is not a recovered source atlas. Keep this
            # subtle grain explicitly labelled as a project-derived material.
            image=bpy.data.images.new('wood grain',width=256,height=256);pixels=[]
            for y in range(256):
                for x in range(256):
                    grain=.94+.035*math.sin(x*.35+math.sin(y*.05))+.015*math.sin(x*1.7+y*.02)
                    pixels.extend([grain,grain,grain,1])
            image.pixels=pixels;image.filepath_raw=str(folder/('grain'+str(i)+'.png'));image.file_format='PNG';image.save();base='Models/'+mid+'/grain'+str(i)
        cap=texture(source.parent/tex['_Matcap']['file'],'matcap'+str(i)) if '_Matcap' in tex else None
        materials.append(dict(name=mat.name,referenceMaterial=True,sourceShader=selected['shader'],texture=base,color=color,matcap=cap,
            matcapScale=min(.25,selected.get('floats',{}).get('_MatcapScale',.15)),matcapColor=selected.get('colors',{}).get('_MatcapColor',[.277,.277,.277,0]),
            lightColor=[.27,.27,.27,0],sourceMaterial=selected['name'],adaptation='Original MatCap/base bindings where reusable; circular UV, grain and bounded strength are project adaptations.'))
    assert geometry==[list(v.co) for v in mesh.vertices]
    bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
    bpy.ops.wm.save_as_mainfile(filepath=str(folder/(mid+'.blend')))
    bpy.ops.export_scene.fbx(filepath=str(folder/(mid+'.fbx')),use_selection=True,axis_forward='-Z',axis_up='Y',apply_unit_scale=True,bake_anim=False,add_leaf_bones=False)
    bpy.ops.export_scene.gltf(filepath=str(folder/(mid+'.glb')),export_format='GLB',use_selection=True,export_yup=True)
    (folder/'materials.json').write_text(json.dumps(dict(materials=materials),indent=2),encoding='utf-8')
    report.append(dict(id=mid,triangles=triangles,materials=len(materials),source=source.relative_to(ROOT).as_posix(),unchangedVertices=True))
(OUT/'metrics.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print(json.dumps(report))
