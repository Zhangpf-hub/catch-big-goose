"""Add an original simple neck rig and three clips; inspect actual exported mesh."""
import bpy,bmesh,json,math
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'source-assets/models/candidates/giraffe-b-20261024-v1'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'source/giraffe-static.blend'))
o=bpy.data.objects['giraffe'];m=json.loads((OUT/'qa/metrics.json').read_text());center=Vector(m['sourceCenter']);extent=m['sourceExtent']
# Closed-shell audit after export and welding UV seams.
bpy.ops.wm.read_factory_settings(use_empty=True);bpy.ops.import_scene.gltf(filepath=str(OUT/'model/giraffe.glb'))
o=next(o for o in bpy.context.scene.objects if o.type=='MESH');bpy.context.view_layer.update()
bm=bmesh.new();bm.from_mesh(o.data);bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=1e-6)
bad=sum(1 for e in bm.edges if not e.is_manifold);deg=sum(1 for f in bm.faces if f.calc_area()<1e-12)
points=[o.matrix_world@v.co for v in o.data.vertices];lo=Vector([min(v[i] for v in points) for i in range(3)]);hi=Vector([max(v[i] for v in points) for i in range(3)])
result={'closedShellEdges':bad,'degenerateFaces':deg,'dimensions':list(hi-lo),'center':list((hi+lo)*.5),'passed':bad==0 and deg==0 and abs(max(hi-lo)-1)<1e-4 and ((hi+lo)*.5).length<1e-4};bm.free()
(OUT/'qa/geometry.json').write_text(json.dumps(result,indent=2));assert result['passed'],result
# Work in original Blender basis for a predictable armature.
bpy.ops.wm.open_mainfile(filepath=str(OUT/'source/giraffe-static.blend'));o=bpy.data.objects['giraffe']
def p(v):return (Vector(v)-center)/extent
data=bpy.data.armatures.new('GiraffeSkeleton');rig=bpy.data.objects.new('GiraffeRig',data);bpy.context.collection.objects.link(rig)
bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);bpy.context.view_layer.objects.active=rig;bpy.ops.object.mode_set(mode='EDIT')
spec=[('body',(0,.1,.8),(0,.1,1.2),None),('neck_lower',(0,-.16,1.18),(0,-.25,1.88),'body'),('neck_upper',(0,-.25,1.88),(0,-.29,2.48),'neck_lower'),('head',(0,-.29,2.48),(0,-.45,2.65),'neck_upper')]
for name,a,b,parent in spec:
    bone=data.edit_bones.new(name);bone.head=p(a);bone.tail=p(b)
    if parent:bone.parent=data.edit_bones[parent]
bpy.ops.object.mode_set(mode='OBJECT')
groups={name:o.vertex_groups.new(name=name) for name,*_ in spec}
for v in o.data.vertices:
    z=(v.co*extent+center).z
    if z<1.12:weights={'body':1}
    elif z<1.48:t=(z-1.12)/.36;weights={'body':1-t,'neck_lower':t}
    elif z<1.73:weights={'neck_lower':1}
    elif z<2.05:t=(z-1.73)/.32;weights={'neck_lower':1-t,'neck_upper':t}
    elif z<2.30:weights={'neck_upper':1}
    elif z<2.49:t=(z-2.30)/.19;weights={'neck_upper':1-t,'head':t}
    else:weights={'head':1}
    for name,w in weights.items():
        if w>0:groups[name].add([v.index],w,'REPLACE')
mod=o.modifiers.new('Giraffe expressive neck','ARMATURE');mod.object=rig;o.parent=rig
rig.animation_data_create();scene=bpy.context.scene;scene.render.fps=30
for name,frames in [('Idle',120),('Peek',48),('Bounce',30)]:
    action=bpy.data.actions.new(name);rig.animation_data.action=action
    for frame in range(1,frames+1,3):
        t=(frame-1)/(frames-1);phase=math.sin(t*math.tau);pulse=math.sin(t*math.pi)
        for bone in rig.pose.bones:bone.rotation_mode='XYZ';bone.rotation_euler=(0,0,0);bone.scale=(1,1,1);bone.location=(0,0,0)
        if name=='Idle':
            rig.pose.bones['neck_lower'].rotation_euler.z=.025*phase;rig.pose.bones['head'].rotation_euler.y=.06*phase
        elif name=='Peek':
            rig.pose.bones['neck_lower'].rotation_euler.x=.18*pulse;rig.pose.bones['neck_upper'].rotation_euler.x=-.25*pulse;rig.pose.bones['head'].rotation_euler.y=.22*math.sin(t*math.tau)*pulse
        else:
            squash=math.sin(t*math.tau)*math.exp(-3*t)
            rig.pose.bones['neck_lower'].scale=(1+.10*squash,1-.18*squash,1+.10*squash)
            rig.pose.bones['neck_upper'].rotation_euler.x=.16*squash
        for bone in rig.pose.bones:
            bone.keyframe_insert(data_path='rotation_euler',frame=frame);bone.keyframe_insert(data_path='scale',frame=frame);bone.keyframe_insert(data_path='location',frame=frame)
    # Explicitly close the loop at its last frame.
    for bone in rig.pose.bones:
        bone.rotation_euler=(0,0,0);bone.scale=(1,1,1);bone.location=(0,0,0)
        bone.keyframe_insert(data_path='rotation_euler',frame=frames);bone.keyframe_insert(data_path='scale',frame=frames);bone.keyframe_insert(data_path='location',frame=frames)
    track=rig.animation_data.nla_tracks.new();track.name=name;track.strips.new(name,1,action);track.mute=True
rig.animation_data.action=bpy.data.actions['Idle'];scene.frame_start=1;scene.frame_end=120;scene.frame_set(1)
bpy.ops.object.select_all(action='DESELECT');o.select_set(True);rig.select_set(True);bpy.context.view_layer.objects.active=rig
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/giraffe-animated.blend'))
bpy.ops.export_scene.fbx(filepath=str(OUT/'model/giraffe-home.fbx'),use_selection=True,object_types={'MESH','ARMATURE'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=True,bake_anim_use_nla_strips=False,bake_anim_use_all_actions=True,path_mode='STRIP')
(OUT/'qa/rig.json').write_text(json.dumps({'bones':len(data.bones),'unweightedVertices':sum(not v.groups for v in o.data.vertices),'clips':['Idle','Peek','Bounce'],'note':'Neck articulation with planted legs. No locomotion clip in this pass.'},indent=2))
print('RIG_AND_GEOMETRY_OK',result)
