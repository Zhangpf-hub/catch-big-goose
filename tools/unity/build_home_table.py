"""Blender candidate: cream round table, tapered wood legs, UVs and source renders."""
import bpy, json, math, random
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'source-assets/models/candidates/home-table-lighting-20261025';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version=0
def image(name,size,fn):
    img=bpy.data.images.new(name,width=size,height=size,alpha=True)
    values=[]
    for y in range(size):
        for x in range(size):values.extend((*fn(x/size,y/size),1))
    img.pixels=values;img.filepath_raw=str(OUT/(name+'.png'));img.file_format='PNG';img.save();return img
wood=image('wood',256,lambda u,v:tuple(c*(.94+.035*math.sin(u*120+math.sin(v*8)*2)+.015*math.sin(u*470+v*8)) for c in (.69,.47,.28)))
cream=image('cream',64,lambda u,v:(.96,.925,.815))
def cap(u,v):
    x=u*2-1;y=v*2-1;z=math.sqrt(max(0,1-x*x-y*y));light=max(0,-x*.4+y*.6+z*.65)
    shine=math.exp(-((x+.32)**2+(y-.4)**2)/.11)
    return tuple(min(1,.13+.34*light+.17*shine) for _ in range(3))
image('matcap',128,cap)
def material(name,texture):
    mat=bpy.data.materials.new(name);mat.use_nodes=True;bs=mat.node_tree.nodes.get('Principled BSDF');bs.inputs['Roughness'].default_value=.64
    node=mat.node_tree.nodes.new('ShaderNodeTexImage');node.image=texture;mat.node_tree.links.new(node.outputs['Color'],bs.inputs['Base Color']);return mat
white=material('home_table_cream',cream);timber=material('home_table_wood',wood)
def lathe(name,profile,n,mat,xy=(0,0)):
    vertices=[];rings=[]
    for radius,z in profile:
        ring=[]
        for i in range(1 if radius==0 else n):
            a=i*math.tau/n;ring.append(len(vertices));vertices.append((xy[0]+radius*math.cos(a),xy[1]+radius*math.sin(a),z))
        rings.append(ring)
    faces=[]
    for lower,upper in zip(rings,rings[1:]):
        for i in range(n):
            j=(i+1)%n
            if len(lower)==1:faces.append((lower[0],upper[j],upper[i]))
            elif len(upper)==1:faces.append((lower[i],lower[j],upper[0]))
            else:faces.append((lower[i],lower[j],upper[j],upper[i]))
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(vertices,[],faces);mesh.update();obj=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(obj);mesh.materials.append(mat)
    uv=mesh.uv_layers.new(name='UVMap')
    for poly in mesh.polygons:
        poly.use_smooth=len(poly.vertices)==4
        for li in poly.loop_indices:
            p=mesh.vertices[mesh.loops[li].vertex_index].co
            uv.data[li].uv=((p.x-xy[0])/4.6+.5,(p.y-xy[1])/4.6+.5) if name=='Tabletop' else ((math.atan2(p.y-xy[1],p.x-xy[0])/math.tau)%1,p.z)
    return obj
objects=[lathe('Tabletop',[(0,-.2),(2.23,-.2),(2.28,-.19),(2.3,-.15),(2.3,-.05),(2.28,-.015),(2.25,0),(0,0)],64,white)]
for i in range(4):
    a=(45+i*90)*math.pi/180
    objects.append(lathe('Tapered leg',[(0,-1.2),(.065,-1.2),(.075,-1.17),(.105,-.24),(.10,-.19),(0,-.19)],16,timber,(math.cos(a)*1.4,math.sin(a)*1.4)))
for a in [45,135]:
    bpy.ops.mesh.primitive_cube_add(size=1,location=(0,0,-.34));o=bpy.context.object;o.name='Joined underframe';o.scale=(2.82,.13,.13);o.rotation_euler.z=math.radians(a);o.data.materials.append(timber)
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);mod=o.modifiers.new('Rounded joinery','BEVEL');mod.width=.035;mod.segments=2;bpy.ops.object.modifier_apply(modifier=mod.name);objects.append(o)
bpy.ops.object.select_all(action='DESELECT')
for o in objects:o.select_set(True)
bpy.context.view_layer.objects.active=objects[0];bpy.ops.object.join();obj=bpy.context.object;obj.name='home-table'
mod=obj.modifiers.new('Triangles','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=mod.name)
assert len(obj.data.polygons)<=4000 and len(obj.data.materials)==2
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'home-table.blend'))
bpy.ops.export_scene.fbx(filepath=str(OUT/'home-table.fbx'),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=False,path_mode='STRIP')
bpy.ops.export_scene.gltf(filepath=str(OUT/'home-table.glb'),export_format='GLB',use_selection=True,export_yup=True,export_animations=False)
triangles=len(obj.data.polygons)
# Roundtrip is independent from the generated mesh.
bpy.ops.wm.read_factory_settings(use_empty=True);bpy.ops.import_scene.gltf(filepath=str(OUT/'home-table.glb'))
models=[o for o in bpy.context.scene.objects if o.type=='MESH'];points=[];round_tri=0
for o in models:
    o.data.calc_loop_triangles();round_tri+=len(o.data.loop_triangles);points.extend(o.matrix_world@Vector(v) for v in o.bound_box)
dims=[max(p[i] for p in points)-min(p[i] for p in points) for i in range(3)]
assert round_tri==triangles and abs(dims[0]-4.6)<.001 and abs(dims[2]-1.2)<.001
report=dict(id='home-table',triangles=triangles,materials=2,dimensions=dims,roundtrip=True,scope='Non-physical furniture; authored diameter 4.6, not normalized gameplay item. No collider required.')
(OUT/'metrics.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
camera_data=bpy.data.cameras.new('QA');camera=bpy.data.objects.new('QA',camera_data);bpy.context.collection.objects.link(camera);bpy.context.scene.camera=camera;camera_data.type='ORTHO';camera_data.ortho_scale=5.5
ld=bpy.data.lights.new('Softbox','AREA');lamp=bpy.data.objects.new('Softbox',ld);bpy.context.collection.objects.link(lamp);lamp.location=(-3,5,6);ld.energy=650;ld.size=4
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=16;scene.world=bpy.data.worlds.new('QA world');scene.world.color=(.4,.4,.4);scene.render.film_transparent=True
for name,pos in [('front',(0,-6,3)),('side',(6,0,3)),('back',(0,6,3)),('three-quarter',(4,-5,4))]:
    camera.location=pos;camera.rotation_euler=(Vector((0,0,-.5))-camera.location).to_track_quat('-Z','Y').to_euler();scene.render.resolution_x=384;scene.render.resolution_y=384;scene.render.resolution_percentage=100;scene.render.filepath=str(OUT/(name+'.png'));bpy.ops.render.render(write_still=True)
for size in [192,64]:
    scene.render.resolution_x=scene.render.resolution_y=size;scene.render.filepath=str(OUT/('icon-'+str(size)+'.png'));bpy.ops.render.render(write_still=True)
print('HOME_TABLE',json.dumps(report))
