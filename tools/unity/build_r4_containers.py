"""Five authored circular containers, in Blender; no live scene is modified."""
import bpy, math, json
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'source-assets/models/candidates/r4-scenes-20261025/containers'
OUT.mkdir(parents=True, exist_ok=True)
THEMES = {
    'breakfast': ((.72,.47,.22),(.92,.73,.42)),
    'barbecue': ((.18,.20,.22),(.46,.49,.50)),
    'countryside': ((.49,.33,.16),(.80,.64,.37)),
    'toys': ((.22,.60,.57),(.97,.76,.36)),
    'grocery': ((.38,.23,.12),(.64,.44,.25)),
}
def material(name, rgb):
    m=bpy.data.materials.new(name);m.diffuse_color=(*rgb,1);m.use_nodes=True
    bs=m.node_tree.nodes.get('Principled BSDF');bs.inputs['Base Color'].default_value=(*rgb,1)
    bs.inputs['Roughness'].default_value=.65
    return m
def lathe(name, profile, mat, n=96):
    verts=[(r*math.cos(i*2*math.pi/n),r*math.sin(i*2*math.pi/n),z) for r,z in profile for i in range(n)]
    faces=[]
    for j in range(len(profile)-1):
        for i in range(n):
            a=j*n+i;b=j*n+(i+1)%n;c=(j+1)*n+(i+1)%n;d=(j+1)*n+i
            if profile[j][0]==0: faces.append((a,c,d))
            elif profile[j+1][0]==0:faces.append((a,b,c))
            else:faces.append((a,b,c,d))
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update()
    obj=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(obj);obj.data.materials.append(mat)
    for p in mesh.polygons:p.use_smooth=True
    return obj
def torus(name,r,z,minor,mat):
    bpy.ops.mesh.primitive_torus_add(major_radius=r,minor_radius=minor,major_segments=96,minor_segments=6,location=(0,0,z))
    o=bpy.context.object;o.name=name;o.data.materials.append(mat)
    for p in o.data.polygons:p.use_smooth=True
    return o
report=[]
for theme,(body,trim) in THEMES.items():
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    base=material(theme+'_body',body);rim=material(theme+'_rim',trim)
    objs=[lathe('Closed shallow bowl',[(0,-.10),(1.88,-.10),(2,.10),(1.98,.24),(1.80,.24),(1.74,0),(0,0)],base)]
    objs.append(torus('Rolled comfortable rim',1.90,.24,.065,rim))
    if theme in ('breakfast','countryside','grocery'):
        for j in range(4):objs.append(torus('Woven horizontal binding',1.81+j*.037,.03+j*.045,.012,rim))
        for i in range(48):
            a=i*math.pi*2/48;r=1.91
            bpy.ops.mesh.primitive_cube_add(size=1,location=(math.cos(a)*r,math.sin(a)*r,.12))
            o=bpy.context.object;o.name='Raised radial weave';o.scale=(.017,.15,.18);o.rotation_euler.z=a;o.data.materials.append(rim);objs.append(o)
    elif theme=='barbecue':
        for j in range(3):objs.append(torus('Metal inset rings',1.80+j*.04,.12+j*.035,.012,rim))
    else:objs.append(torus('Contrasting plastic lip',1.89,.17,.025,rim))
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:o.select_set(True)
    bpy.context.view_layer.objects.active=objs[0];bpy.ops.object.join();o=bpy.context.object
    o.name='round_'+theme+'_r4';bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    bpy.context.scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
    mod=o.modifiers.new('Triangulate','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=mod.name)
    folder=OUT/o.name;folder.mkdir(exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(folder/(o.name+'.blend')))
    bpy.ops.export_scene.gltf(filepath=str(folder/(o.name+'.glb')),export_format='GLB',use_selection=True,export_yup=True)
    bpy.ops.export_scene.fbx(filepath=str(folder/(o.name+'.fbx')),use_selection=True,axis_forward='-Z',axis_up='Y',apply_unit_scale=True,bake_anim=False,add_leaf_bones=False)
    camdata=bpy.data.cameras.new('QA');cam=bpy.data.objects.new('QA',camdata);bpy.context.collection.objects.link(cam);bpy.context.scene.camera=cam
    camdata.type='ORTHO';camdata.ortho_scale=4.7
    ld=bpy.data.lights.new('Softbox','AREA');lo=bpy.data.objects.new('Softbox',ld);bpy.context.collection.objects.link(lo);lo.location=(-3,-4,6);ld.energy=500;ld.size=5
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=16;scene.world.color=(.7,.7,.7)
    scene.render.resolution_x=512;scene.render.resolution_y=512;scene.render.resolution_percentage=100
    for label,pos in [('top',(0,-.01,7)),('front',(0,-6,4)),('back',(0,6,4)),('side',(6,0,4))]:
        cam.location=pos;cam.rotation_euler=(Vector((0,0,.05))-cam.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(folder/(label+'.png'));bpy.ops.render.render(write_still=True)
    report.append(dict(id=o.name,triangles=len(o.data.polygons),materials=len(o.data.materials),outerDiameter=4,innerRadius=1.74,floorY=0,rimHeight=.305))
(OUT/'geometry-report.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('R4_CONTAINERS_COMPLETE',json.dumps(report))
