"""Original B-proportion giraffe, authored geometry and baked painted-plastic atlas.
Run with Blender 4.5 --background --factory-startup --python this_file.
Candidate only; production installation is a separate step.
"""
import bpy, bmesh, math, json, sys
from pathlib import Path
from mathutils import Vector

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'source-assets/models/candidates/giraffe-b-20261024-v1'
OUT.mkdir(parents=True,exist_ok=True)
for d in ['source','model','renders','qa']: (OUT/d).mkdir(exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version=0
parts=[]

def linear(c): return c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4
def material(name,color,rough=.48):
    m=bpy.data.materials.new(name);m.use_nodes=True
    bs=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    bs.inputs['Base Color'].default_value=tuple(linear(c) for c in color)+(1,)
    bs.inputs['Roughness'].default_value=rough
    return m
gold=material('Butter yellow',(.98,.72,.22));brown=material('Caramel patches',(.64,.31,.105))
cream=material('Cream muzzle',(1,.91,.69));pink=material('Warm ear inset',(.95,.58,.38))
dark=material('Dark cocoa',(.19,.085,.035));eye=material('Black bead eye',(.065,.043,.026),.23)
hoof=material('Brown hoof',(.43,.22,.09))

def finish(o,name,mat):
    o.name=name
    if mat:o.data.materials.append(mat)
    for p in o.data.polygons:p.use_smooth=True
    parts.append(o);return o
def ball(name,loc,scale,mat,segments=20,rings=12):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments,ring_count=rings,location=loc)
    o=bpy.context.object;o.scale=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    return finish(o,name,mat)
def tube(name,points,radii,mat,sides=16):
    vs=[];fs=[]
    for i,(p,r) in enumerate(zip(points,radii)):
        p=Vector(p);t=Vector(points[min(i+1,len(points)-1)])-Vector(points[max(0,i-1)])
        t.normalize();u=t.cross(Vector((0,1,0)))
        if u.length<.1:u=t.cross(Vector((1,0,0)))
        u.normalize();v=t.cross(u).normalized()
        for j in range(sides):vs.append(p+r*(math.cos(j*math.tau/sides)*u+math.sin(j*math.tau/sides)*v))
    for i in range(len(points)-1):
        for j in range(sides):a=i*sides+j;b=i*sides+(j+1)%sides;fs.append((a,b,b+sides,a+sides))
    fs.extend([tuple(reversed(range(sides))),tuple((len(points)-1)*sides+j for j in range(sides))])
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(vs,[],fs);mesh.update()
    o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o)
    return finish(o,name,mat)
def join(objects,name):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0];bpy.ops.object.join()
    o=bpy.context.object;o.name=name
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    return o
def tris(o):o.data.calc_loop_triangles();return len(o.data.loop_triangles)
def apply(o,mod):bpy.context.view_layer.objects.active=o;bpy.ops.object.modifier_apply(modifier=mod.name)

# A continuous skin: smooth neck/shoulder/head and four attached solid legs.
ball('torso',(0,.15,1.02),(.285,.43,.32),gold)
ball('shoulder',(0,-.12,1.16),(.245,.25,.29),gold)
tube('neck',[(0,-.12,1.13),(0,-.19,1.40),(0,-.25,1.72),(0,-.27,2.03),(0,-.28,2.32),(0,-.29,2.54)],
     [.195,.16,.125,.112,.12,.14],gold,24)
ball('head',(0,-.31,2.57),(.20,.225,.235),gold,28,16)
for x in [-.19,.19]:
    for y in [-.115,.39]:
        tube('leg',[(x*.87,y,1.01),(x,y,.76),(x*1.03,y+.015,.46),(x*1.05,y-.025,.14),(x*1.05,y-.04,.065)],
             [.105,.083,.065,.070,.075],gold,16)
body=join(parts,'giraffe_skin');parts=[body]
mod=body.modifiers.new('Continuous toy skin','REMESH');mod.mode='VOXEL';mod.voxel_size=.014;mod.use_smooth_shade=True;apply(body,mod)
mod=body.modifiers.new('Soft transitions','SMOOTH');mod.factor=1.3;mod.iterations=6;apply(body,mod)
mod=body.modifiers.new('Mobile body budget','DECIMATE');mod.ratio=min(1,3000/tris(body));apply(body,mod)
for p in body.data.polygons:p.use_smooth=True

# Paint larger, sparse spots directly in a shader so they follow the curved skin.
nodes=gold.node_tree.nodes;links=gold.node_tree.links
bs=next(n for n in nodes if n.type=='BSDF_PRINCIPLED')
geo=nodes.new('ShaderNodeNewGeometry');trans=nodes.new('ShaderNodeVectorTransform');trans.vector_type='POINT';trans.convert_from='WORLD';trans.convert_to='OBJECT';links.new(geo.outputs['Position'],trans.inputs[0])
mask=None
spots=[]
for sign in [-1,1]:
    for x,y,z,sx,sy,sz in [(.115,-.22,2.25,.085,.12,.14),(.12,-.26,1.91,.075,.10,.11),(.14,-.17,1.60,.095,.13,.14),(.18,-.12,1.34,.10,.14,.13),(.255,.04,1.08,.08,.15,.15),(.25,.31,1.15,.085,.14,.13),(.24,.43,.92,.08,.095,.10)]:
        spots.append(((sign*x,y+(0.03 if sign<0 else 0),z+(0.04 if sign<0 else 0)),(sx,sy,sz)))
spots += [((0,-.39,2.08),(.075,.08,.14)),((.035,-.38,1.77),(.075,.09,.12)),((-.05,-.34,1.44),(.085,.10,.12)),((0,.05,1.31),(.15,.13,.07)),((.02,.32,1.30),(.11,.11,.08)),((0,-.14,2.4),(.08,.07,.10)),((0,-.12,2.02),(.085,.07,.12))]
for center,scale in spots:
    sub=nodes.new('ShaderNodeVectorMath');sub.operation='SUBTRACT';links.new(trans.outputs[0],sub.inputs[0]);sub.inputs[1].default_value=center
    div=nodes.new('ShaderNodeVectorMath');div.operation='DIVIDE';links.new(sub.outputs[0],div.inputs[0]);div.inputs[1].default_value=scale
    length=nodes.new('ShaderNodeVectorMath');length.operation='LENGTH';links.new(div.outputs[0],length.inputs[0])
    inside=nodes.new('ShaderNodeMath');inside.operation='LESS_THAN';inside.inputs[1].default_value=1;links.new(length.outputs['Value'],inside.inputs[0])
    if mask:
        union=nodes.new('ShaderNodeMath');union.operation='MAXIMUM';links.new(mask,union.inputs[0]);links.new(inside.outputs[0],union.inputs[1]);mask=union.outputs[0]
    else:mask=inside.outputs[0]
mix=nodes.new('ShaderNodeMixRGB');mix.inputs[1].default_value=tuple(linear(c) for c in (.98,.72,.22))+(1,);mix.inputs[2].default_value=tuple(linear(c) for c in (.64,.31,.105))+(1,)
links.new(mask,mix.inputs[0]);links.new(mix.outputs[0],bs.inputs['Base Color'])

# Connected muzzle, horns, leaf ears, hoof caps and compact tail.
ball('muzzle',(0,-.492,2.49),(.183,.205,.139),cream,24,14)
for sign in [-1,1]:
    ball('eye',(sign*.145,-.457,2.625),(.034,.028,.040),eye,16,10)
    ball('nostril',(sign*.060,-.684,2.535),(.012,.009,.018),dark,12,8)
    stem=tube('horn',[(sign*.105,-.26,2.72),(sign*.13,-.245,2.86),(sign*.15,-.23,2.96)],[.034,.030,.033],brown,12)
    ball('horn_tip',(sign*.15,-.23,2.96),(.053,.05,.055),brown,16,10)
    ear=ball('ear',(sign*.297,-.27,2.67),(.177,.062,.095),gold,20,12);ear.rotation_euler.y=-sign*.38
    inset=ball('ear_inset',(sign*.31,-.321,2.673),(.125,.018,.059),pink,16,8);inset.rotation_euler.y=-sign*.38
    for y in [-.115,.39]:ball('hoof',(sign*.1995,y-.039,.078),(.080,.090,.060),hoof,16,8)
mouth=[]
for i in range(13):
    x=-.09+.18*i/12;mouth.append((x,-.492-.205*math.sqrt(max(0,1-(x/.183)**2-((2.445+.025*(x/.09)**2-2.49)/.139)**2))-.003,2.445+.025*(x/.09)**2))
tube('smile',mouth,[.006]*13,dark,6)
tube('tail',[(0,.48,1.10),(.04,.61,1.04),(.07,.69,.91),(.08,.70,.82)],[.035,.030,.025,.028],gold,12)
ball('tail_tuft',(.08,.704,.794),(.053,.055,.09),brown,16,8)

# Save editable authored parts before atlas baking.
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/giraffe-authored.blend'))
obj=join(parts,'giraffe');parts=[obj]
if tris(obj)>5000:
    mod=obj.modifiers.new('Final mobile detail budget','DECIMATE');mod.ratio=5000/tris(obj);apply(obj,mod)
print('PRE_BAKE_TRIANGLES',tris(obj),flush=True)
# Keep source UV islands padded enough for 512px mobile albedo.
bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.uv.smart_project(angle_limit=1.15,island_margin=.025);bpy.ops.object.mode_set(mode='OBJECT')
img=bpy.data.images.new('GiraffeAlbedo',width=1024,height=1024,alpha=False)
for m in obj.data.materials:
    n=m.node_tree.nodes;l=m.node_tree.links;bs=next(x for x in n if x.type=='BSDF_PRINCIPLED');out=next(x for x in n if x.type=='OUTPUT_MATERIAL')
    emit=n.new('ShaderNodeEmission');emit.inputs['Color'].default_value=bs.inputs['Base Color'].default_value
    if bs.inputs['Base Color'].is_linked:l.new(bs.inputs['Base Color'].links[0].from_socket,emit.inputs['Color'])
    l.new(emit.outputs[0],out.inputs['Surface']);tex=n.new('ShaderNodeTexImage');tex.image=img;n.active=tex
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=1;scene.render.bake.margin=6
bpy.ops.object.bake(type='EMIT')
img.scale(512,512)
img.filepath_raw=str(OUT/'model/albedo.png');img.file_format='PNG';img.save();img.pack()
mat=material('giraffe_mobile',(1,1,1),.52);n=mat.node_tree.nodes;l=mat.node_tree.links;bs=next(x for x in n if x.type=='BSDF_PRINCIPLED')
uv=n.new('ShaderNodeUVMap');uv.uv_map=obj.data.uv_layers.active.name
tex=n.new('ShaderNodeTexImage');tex.image=img;l.new(uv.outputs[0],tex.inputs['Vector']);l.new(tex.outputs['Color'],bs.inputs['Base Color'])
obj.data.materials.clear();obj.data.materials.append(mat)
for p in obj.data.polygons:p.material_index=0
# Normalize exact authored bounds, centered, maximum extent 1.
lo=Vector([min(v.co[i] for v in obj.data.vertices) for i in range(3)]);hi=Vector([max(v.co[i] for v in obj.data.vertices) for i in range(3)])
center=(lo+hi)/2;extent=max(hi-lo)
for v in obj.data.vertices:v.co=(v.co-center)/extent
obj.data.update()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/giraffe-static.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'model/giraffe.glb'),export_format='GLB',use_selection=True,export_yup=True,export_animations=False,export_extras=False)
bpy.ops.export_scene.fbx(filepath=str(OUT/'model/giraffe.fbx'),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=False,path_mode='STRIP')
(OUT/'model/materials.json').write_text(json.dumps({'materials':[{'name':'giraffe_mobile','texture':'albedo.png','color':[1,1,1,1],'roughness':.52,'metallic':0}]},indent=2))
metrics={'id':'giraffe','triangles':tris(obj),'materials':1,'texture':[512,512],'dimensions':list((hi-lo)/extent),'center':[0,0,0],'sourceCenter':list(center),'sourceExtent':extent,'glbBytes':(OUT/'model/giraffe.glb').stat().st_size,'basis':'Original B proportions; current Unity pipeline; 512 texture preserves painted patches'}
(OUT/'qa/metrics.json').write_text(json.dumps(metrics,indent=2));print('METRICS',metrics,flush=True)

# Export reimport, then render only the actual deliverable geometry.
bpy.data.objects.remove(obj,do_unlink=True)
bpy.ops.import_scene.gltf(filepath=str(OUT/'model/giraffe.glb'))
obj=next(o for o in bpy.context.scene.objects if o.type=='MESH');obj.name='giraffe'
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=32
scene.view_settings.view_transform='Standard';scene.view_settings.look='Medium High Contrast';scene.view_settings.exposure=0;scene.view_settings.gamma=1
scene.world=bpy.data.worlds.new('Soft daylight');scene.world.use_nodes=True;scene.world.node_tree.nodes.get('Background').inputs[0].default_value=(.72,.76,.82,1);scene.world.node_tree.nodes.get('Background').inputs[1].default_value=.45
def aim(o,point):o.rotation_euler=(Vector(point)-o.location).to_track_quat('-Z','Y').to_euler()
for name,loc,power,size in [('Key',(-2,-3,4),180,4),('Fill',(3,-1,2),95,3),('Rim',(0,3,3),120,3)]:
    data=bpy.data.lights.new(name,'AREA');data.energy=power;data.shape='DISK';data.size=size;o=bpy.data.objects.new(name,data);scene.collection.objects.link(o);o.location=loc;aim(o,(0,0,0))
camData=bpy.data.cameras.new('ReviewCamera');cam=bpy.data.objects.new('ReviewCamera',camData);scene.collection.objects.link(cam);scene.camera=cam;camData.type='ORTHO';camData.ortho_scale=1.22
scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA';scene.render.film_transparent=True
for name,loc in [('front',(0,-3,.05)),('side',(3,0,.05)),('back',(0,3,.05)),('hero',(2.2,-3,1.4)),('gameplay',(1.4,-2.3,3.3))]:
    cam.location=loc;aim(cam,(0,0,0));scene.render.resolution_x=768;scene.render.resolution_y=768;scene.render.resolution_percentage=100
    scene.render.filepath=str(OUT/'renders'/f'{name}.png');bpy.ops.render.render(write_still=True)
cam.location=(2.2,-3,1.4);aim(cam,(0,0,0));camData.ortho_scale=1.22
for size in [192,64]:
    scene.render.resolution_x=size;scene.render.resolution_y=size;scene.render.filepath=str(OUT/'model'/f'icon-{size}.png');bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/giraffe-review.blend'))
print('GIRAFFE_DONE',OUT,flush=True)
