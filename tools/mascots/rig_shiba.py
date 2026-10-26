"""Add an original simple neck rig and three clips; inspect actual exported mesh."""
import bpy,bmesh,json,math
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'source-assets/models/candidates/shiba-20261025-v1'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'source/shiba-static.blend'))
bpy.context.preferences.filepaths.save_version=0
o=bpy.data.objects['shiba'];m=json.loads((OUT/'qa/metrics.json').read_text());center=Vector(m['sourceCenter']);extent=m['sourceExtent']
# Closed-shell audit after export and welding UV seams.
bpy.ops.wm.read_factory_settings(use_empty=True);bpy.ops.import_scene.gltf(filepath=str(OUT/'model/shiba.glb'))
o=next(o for o in bpy.context.scene.objects if o.type=='MESH');bpy.context.view_layer.update()
bm=bmesh.new();bm.from_mesh(o.data);bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=1e-6)
bad=sum(1 for e in bm.edges if not e.is_manifold);deg=sum(1 for f in bm.faces if f.calc_area()<1e-12)
points=[o.matrix_world@v.co for v in o.data.vertices];lo=Vector([min(v[i] for v in points) for i in range(3)]);hi=Vector([max(v[i] for v in points) for i in range(3)])
result={'closedShellEdges':bad,'degenerateFaces':deg,'dimensions':list(hi-lo),'center':list((hi+lo)*.5),'passed':bad==0 and deg==0 and abs(max(hi-lo)-1)<1e-4 and ((hi+lo)*.5).length<1e-4};bm.free()
(OUT/'qa/geometry.json').write_text(json.dumps(result,indent=2));assert result['passed'],result
# Work in original Blender basis for a predictable armature.
bpy.ops.wm.open_mainfile(filepath=str(OUT/'source/shiba-static.blend'));o=bpy.data.objects['shiba']
def p(v):return (Vector(v)-center)/extent
data=bpy.data.armatures.new('ShibaSkeleton');rig=bpy.data.objects.new('ShibaRig',data);bpy.context.collection.objects.link(rig)
bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);bpy.context.view_layer.objects.active=rig;bpy.ops.object.mode_set(mode='EDIT')
spec=[('body',(0,.1,.015),(0,.1,.7),None),('head',(0,-.24,.94),(0,-.34,1.33),'body'),('tail',(0,.47,.85),(.06,.59,1.15),'body')]
for name,a,b,parent in spec:
    bone=data.edit_bones.new(name);bone.head=p(a);bone.tail=p(b)
    if parent:bone.parent=data.edit_bones[parent]
bpy.ops.object.mode_set(mode='OBJECT')
tailgroup=o.vertex_groups.get('tail');tailverts={v.index for v in o.data.vertices if any(g.group==tailgroup.index and g.weight>.5 for g in v.groups)}
groups={name:o.vertex_groups.get(name) or o.vertex_groups.new(name=name) for name,*_ in spec}
for v in o.data.vertices:
    xyz=v.co*extent+center
    if v.index in tailverts:weights={'tail':1}
    else:
        blend=max(0,min(1,(xyz.z-.89)/.24)) if xyz.y<.1 else 0
        weights={'body':1-blend,'head':blend}
    for name,w in weights.items():
        if w>0:groups[name].add([v.index],w,'REPLACE')
mod=o.modifiers.new('Shiba expression rig','ARMATURE');mod.object=rig;o.parent=rig
rig.animation_data_create();scene=bpy.context.scene;scene.render.fps=24
for name,frames in [('Idle',60),('Happy',36),('Bounce',24)]:
    action=bpy.data.actions.new(name);rig.animation_data.action=action
    for frame in list(range(1,frames,2))+[frames]:
        t=(frame-1)/(frames-1);phase=math.sin(t*math.tau);pulse=math.sin(t*math.pi)
        for bone in rig.pose.bones:bone.rotation_mode='XYZ';bone.rotation_euler=(0,0,0);bone.scale=(1,1,1);bone.location=(0,0,0)
        if name=='Idle':
            rig.pose.bones['head'].rotation_euler.y=.045*phase
            rig.pose.bones['tail'].rotation_euler.z=.10*phase
            rig.pose.bones['body'].scale=(1+.01*phase,1+.012*phase,1+.01*phase)
        elif name=='Happy':
            rig.pose.bones['head'].rotation_euler.z=.19*pulse
            rig.pose.bones['head'].rotation_euler.x=.075*pulse
            rig.pose.bones['tail'].rotation_euler.z=.40*math.sin(t*math.tau*3)*pulse
        else:
            squash=math.sin(t*math.tau)*math.exp(-2*t)
            rig.pose.bones['body'].scale=(1+.14*squash,1-.20*squash,1+.14*squash)
            rig.pose.bones['head'].rotation_euler.x=.16*squash
            rig.pose.bones['tail'].rotation_euler.z=.22*squash
        if frame==frames:
            for bone in rig.pose.bones:bone.rotation_euler=(0,0,0);bone.scale=(1,1,1)
        for bone in rig.pose.bones:
            bone.keyframe_insert(data_path='rotation_euler',frame=frame);bone.keyframe_insert(data_path='scale',frame=frame);bone.keyframe_insert(data_path='location',frame=frame)
    track=rig.animation_data.nla_tracks.new();track.name=name;track.strips.new(name,1,action);track.mute=True
rig.animation_data.action=bpy.data.actions['Idle'];scene.frame_start=1;scene.frame_end=60;scene.frame_set(1)
bpy.ops.object.select_all(action='DESELECT');o.select_set(True);rig.select_set(True);bpy.context.view_layer.objects.active=rig
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/shiba-animated.blend'))
bpy.ops.export_scene.fbx(filepath=str(OUT/'model/shiba-home.fbx'),use_selection=True,object_types={'MESH','ARMATURE'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=True,bake_anim_use_nla_strips=False,bake_anim_use_all_actions=True,path_mode='STRIP')
(OUT/'qa/rig.json').write_text(json.dumps({'bones':len(data.bones),'unweightedVertices':sum(not v.groups for v in o.data.vertices),'tailVertices':len(tailverts),'clips':['Idle','Happy','Bounce'],'note':'Root anchored at ground; gentle head tilt, attached tail wag and elastic squash. No locomotion.'},indent=2))
print('SHIBA_RIG_AND_GEOMETRY_OK',result)
