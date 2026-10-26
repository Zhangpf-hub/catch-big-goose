"""Original clean two-tone Shiba, authored mesh and unlit albedo atlas.
Run with Blender 4.5 --background --factory-startup --python this_file.
Candidate only; production installation is a separate step.
"""
import bpy, bmesh, math, json, sys
from pathlib import Path
from mathutils import Vector

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'source-assets/models/candidates/shiba-20261025-v1'
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
    vs=[];fs=[];last_u=None
    for i,(p,r) in enumerate(zip(points,radii)):
        p=Vector(p);t=Vector(points[min(i+1,len(points)-1)])-Vector(points[max(0,i-1)])
        t.normalize()
        u=last_u-t*last_u.dot(t) if last_u is not None else t.cross(Vector((1,0,0)))
        if u.length<.1:u=t.cross(Vector((0,1,0)))
        u.normalize();v=t.cross(u).normalized();last_u=u
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

# Large, clean colour fields, without fur noise or mottled markings.
gold=material('Red tan coat',(.87,.43,.135),.55)
cream=material('Warm ivory',(.99,.94,.83),.55)
pink=material('Muted inner ear',(.72,.36,.26),.65)
dark=material('Cocoa smile',(.16,.085,.055),.55)
eye=material('Black bead eyes',(.055,.038,.029),.28)

ball('torso',(0,.15,.72),(.24,.43,.265),gold,24,16)
ball('chest',(0,-.19,.82),(.235,.235,.29),gold,24,16)
ball('neck',(0,-.26,1.00),(.215,.205,.25),gold,24,16)
ball('head',(0,-.355,1.205),(.29,.258,.265),gold,32,20)
ball('muzzle',(0,-.556,1.095),(.205,.164,.125),gold,24,16)
for sign in [-1,1]:
    ball('cheek',(sign*.155,-.44,1.11),(.145,.172,.143),gold,24,16)
    for y in [-.17,.43]:
        ball('leg_root',(sign*(.125 if y<0 else .145),y,.71),(.12,.15,.21),gold,20,12)
        tube('leg',[(sign*.13,y,.75),(sign*.177,y,.55),(sign*.18,y-.01,.32),(sign*.18,y-.045,.12)],[.085,.075,.061,.067],gold,16)
        ball('paw',(sign*.18,y-.077,.09),(.079,.117,.075),gold,20,12)
body=join(parts,'shiba_skin');parts=[body]
mod=body.modifiers.new('Continuous soft toy body','REMESH');mod.mode='VOXEL';mod.voxel_size=.008;mod.use_smooth_shade=True;apply(body,mod)
mod=body.modifiers.new('Soft sculpted transitions','SMOOTH');mod.factor=1.0;mod.iterations=14;apply(body,mod)
mod=body.modifiers.new('Mobile body budget','DECIMATE');mod.ratio=min(1,3200/tris(body));apply(body,mod)
for p in body.data.polygons:p.use_smooth=True

# Broad connected ivory face/chest plus simple socks. These are surface paint,
# not separate floating plates, and contain no lighting or random texture.
nodes=gold.node_tree.nodes;links=gold.node_tree.links
bs=next(n for n in nodes if n.type=='BSDF_PRINCIPLED')
geo=nodes.new('ShaderNodeNewGeometry');trans=nodes.new('ShaderNodeVectorTransform');trans.vector_type='POINT';trans.convert_from='WORLD';trans.convert_to='OBJECT';links.new(geo.outputs['Position'],trans.inputs[0])
mask=None
for center,scale in [((0,-.63,1.055),(.35,.27,.205)),((0,-.40,.74),(.205,.14,.405))]:
    sub=nodes.new('ShaderNodeVectorMath');sub.operation='SUBTRACT';links.new(trans.outputs[0],sub.inputs[0]);sub.inputs[1].default_value=center
    div=nodes.new('ShaderNodeVectorMath');div.operation='DIVIDE';links.new(sub.outputs[0],div.inputs[0]);div.inputs[1].default_value=scale
    length=nodes.new('ShaderNodeVectorMath');length.operation='LENGTH';links.new(div.outputs[0],length.inputs[0])
    inside=nodes.new('ShaderNodeMath');inside.operation='LESS_THAN';inside.inputs[1].default_value=1;links.new(length.outputs['Value'],inside.inputs[0])
    if mask:
        union=nodes.new('ShaderNodeMath');union.operation='MAXIMUM';links.new(mask,union.inputs[0]);links.new(inside.outputs[0],union.inputs[1]);mask=union.outputs[0]
    else:mask=inside.outputs[0]
xyz=nodes.new('ShaderNodeSeparateXYZ');links.new(trans.outputs[0],xyz.inputs[0]);sock=nodes.new('ShaderNodeMath');sock.operation='LESS_THAN';sock.inputs[1].default_value=.205;links.new(xyz.outputs['Z'],sock.inputs[0])
union=nodes.new('ShaderNodeMath');union.operation='MAXIMUM';links.new(mask,union.inputs[0]);links.new(sock.outputs[0],union.inputs[1])
mix=nodes.new('ShaderNodeMixRGB');mix.inputs[1].default_value=tuple(linear(c) for c in (.87,.43,.135))+(1,);mix.inputs[2].default_value=tuple(linear(c) for c in (.99,.94,.83))+(1,)
links.new(union.outputs[0],mix.inputs[0]);links.new(mix.outputs[0],bs.inputs['Base Color'])

# Ears are closed, thick, softly bevelled triangular wedges.
earcoat=material('Solid red tan ears',(.87,.43,.135),.55)
def ear(name,sign,inset=False):
    if inset:
        xyz=[(sign*.125,-.358,1.405),(sign*.252,-.340,1.405),(sign*.242,-.317,1.570)]
        thickness=.009;mat=pink
    else:
        xyz=[(sign*.073,-.355,1.347),(sign*.294,-.325,1.355),(sign*.256,-.300,1.635)]
        thickness=.12;mat=earcoat
    vs=xyz+[(x,y+thickness,z) for x,y,z in xyz]
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(vs,[],[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)]);mesh.update()
    o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o);finish(o,name,mat)
    bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
    mod=o.modifiers.new('Rounded ear edges','BEVEL');mod.width=.008 if inset else .035;mod.segments=3;apply(o,mod)
    return o
for sign in [-1,1]:
    ear('ear',sign);ear('ear_inset',sign,True)
    ball('eye',(sign*.155,-.562,1.253),(.032,.023,.040),eye,20,12)
# Small, softly triangular nose; the muzzle stays broad and cream.
nose=ball('nose',(0,-.716,1.133),(.067,.036,.044),eye,20,12)
for v in nose.data.vertices:
    if v.co.z<0:v.co.x*=.65
tube('philtrum',[(0,-.719,1.118),(0,-.718,1.086)],[.005,.005],dark,6)
for sign in [-1,1]:
    pts=[]
    for i in range(9):
        t=i/8;x=sign*.122*t;z=1.073-.014*math.sin(t*math.pi)+.026*t
        y=-.556-.164*math.sqrt(max(.1,1-(x/.205)**2-((z-1.095)/.125)**2))-.006
        pts.append((x,y,z))
    tube('smile',pts,[.006]*len(pts),dark,8)

# A single thick curl, connected to the rump, with one cream tip.
control=[(0,.49,.83),(.015,.64,.89),(.04,.70,1.02),(.07,.64,1.15),(.10,.51,1.17),(.12,.41,1.08),(.12,.44,.98),(.12,.53,.99)]
tailpts=[]
for i in range(len(control)-1):
    a,b,c,d=[Vector(control[max(0,min(len(control)-1,j))]) for j in [i-1,i,i+1,i+2]]
    for k in range(5):
        t=k/5
        tailpts.append(tuple(.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t)))
tailpts.append(control[-1])
tail=tube('curled_tail',tailpts,[.095-.035*(i/(len(tailpts)-1)) for i in range(len(tailpts))],earcoat,12)
tail.vertex_groups.new(name='tail').add(list(range(len(tail.data.vertices))),1,'REPLACE')
tip=ball('cream_tail_tip',tailpts[-1],(.057,.059,.065),cream,20,12);tip.vertex_groups.new(name='tail').add(list(range(len(tip.data.vertices))),1,'REPLACE')

# Save editable authored parts before atlas baking.
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/shiba-authored.blend'))
obj=join(parts,'shiba');parts=[obj]
if tris(obj)>5000:
    mod=obj.modifiers.new('Final mobile detail budget','DECIMATE');mod.ratio=5000/tris(obj);apply(obj,mod)
print('PRE_BAKE_TRIANGLES',tris(obj),flush=True)
# Keep source UV islands padded enough for 512px mobile albedo.
bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.uv.smart_project(angle_limit=1.15,island_margin=.025);bpy.ops.object.mode_set(mode='OBJECT')
img=bpy.data.images.new('ShibaAlbedo',width=1024,height=1024,alpha=False)
for m in obj.data.materials:
    n=m.node_tree.nodes;l=m.node_tree.links;bs=next(x for x in n if x.type=='BSDF_PRINCIPLED');out=next(x for x in n if x.type=='OUTPUT_MATERIAL')
    emit=n.new('ShaderNodeEmission');emit.inputs['Color'].default_value=bs.inputs['Base Color'].default_value
    if bs.inputs['Base Color'].is_linked:l.new(bs.inputs['Base Color'].links[0].from_socket,emit.inputs['Color'])
    l.new(emit.outputs[0],out.inputs['Surface']);tex=n.new('ShaderNodeTexImage');tex.image=img;n.active=tex
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=1;scene.render.bake.margin=6
bpy.ops.object.bake(type='EMIT')
img.scale(512,512)
img.filepath_raw=str(OUT/'model/albedo.png');img.file_format='PNG';img.save();img.pack()
mat=material('shiba_mobile',(1,1,1),.52);n=mat.node_tree.nodes;l=mat.node_tree.links;bs=next(x for x in n if x.type=='BSDF_PRINCIPLED')
uv=n.new('ShaderNodeUVMap');uv.uv_map=obj.data.uv_layers.active.name
tex=n.new('ShaderNodeTexImage');tex.image=img;l.new(uv.outputs[0],tex.inputs['Vector']);l.new(tex.outputs['Color'],bs.inputs['Base Color'])
obj.data.materials.clear();obj.data.materials.append(mat)
for p in obj.data.polygons:p.material_index=0
# Normalize exact authored bounds, centered, maximum extent 1.
lo=Vector([min(v.co[i] for v in obj.data.vertices) for i in range(3)]);hi=Vector([max(v.co[i] for v in obj.data.vertices) for i in range(3)])
center=(lo+hi)/2;extent=max(hi-lo)
for v in obj.data.vertices:v.co=(v.co-center)/extent
obj.data.update()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/shiba-static.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'model/shiba.glb'),export_format='GLB',use_selection=True,export_yup=True,export_animations=False,export_extras=False)
bpy.ops.export_scene.fbx(filepath=str(OUT/'model/shiba.fbx'),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=False,path_mode='STRIP')
(OUT/'model/materials.json').write_text(json.dumps({'materials':[{'name':'shiba_mobile','texture':'albedo.png','color':[1,1,1,1],'roughness':.52,'metallic':0}]},indent=2))
metrics={'id':'shiba','triangles':tris(obj),'materials':1,'texture':[512,512],'dimensions':list((hi-lo)/extent),'center':[0,0,0],'sourceCenter':list(center),'sourceExtent':extent,'glbBytes':(OUT/'model/shiba.glb').stat().st_size,'basis':'Clean two-tone Shiba; 512 atlas preserves small facial details, no baked lighting'}
(OUT/'qa/metrics.json').write_text(json.dumps(metrics,indent=2));print('METRICS',metrics,flush=True)

# Export reimport, then render only the actual deliverable geometry.
bpy.data.objects.remove(obj,do_unlink=True)
bpy.ops.import_scene.gltf(filepath=str(OUT/'model/shiba.glb'))
obj=next(o for o in bpy.context.scene.objects if o.type=='MESH');obj.name='shiba'
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=12;scene.cycles.use_denoising=True
scene.view_settings.view_transform='AgX';scene.view_settings.look='AgX - Medium High Contrast';scene.view_settings.exposure=0;scene.view_settings.gamma=1
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
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/shiba-review.blend'))
print('SHIBA_DONE',OUT,flush=True)
