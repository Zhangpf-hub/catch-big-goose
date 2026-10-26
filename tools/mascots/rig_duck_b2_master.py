"""Bind the exact B2 mother mesh, test evaluated vertex motion, render pose studies.
Candidate rig only. Does not replace the Unity home mascot.
"""
import hashlib
import importlib.util
import json
import math
from pathlib import Path
import bpy
from mathutils import Vector

spec=importlib.util.spec_from_file_location('master',Path(__file__).with_name('build_duck_b2_master.py'))
M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
H=M.H;OUT=M.OUT
data=json.loads((OUT/'qa/authoring.json').read_text('utf-8'))
center=Vector(data['sourceCenter']);extent=data['sourceExtent']
def point(p):return (Vector(p)-center)/extent

def reset(rig):
    for pb in rig.pose.bones:
        pb.rotation_mode='XYZ';pb.rotation_euler=(0,0,0);pb.location=(0,0,0);pb.scale=(1,1,1)
    bpy.context.view_layer.update()

def evaluated(obj):
    dg=bpy.context.evaluated_depsgraph_get();e=obj.evaluated_get(dg)
    mesh=e.to_mesh();p=[e.matrix_world@v.co for v in mesh.vertices];e.to_mesh_clear()
    return p

def main():
    bpy.ops.wm.open_mainfile(filepath=str(OUT/'source/duck-b2-master-mobile.blend'))
    obj=next(o for o in bpy.context.scene.objects if o.type=='MESH')
    arm=bpy.data.armatures.new('B2 reusable deformation skeleton')
    rig=bpy.data.objects.new('duck-b2-rig',arm);bpy.context.collection.objects.link(rig)
    bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);bpy.context.view_layer.objects.active=rig
    bpy.ops.object.mode_set(mode='EDIT')
    bones=[
        ('root',(0,0,0),(0,0,.1),None),
        ('body',(0,.015,.12),(0,.005,.55),'root'),
        ('neck_base',(0,.005,.55),(0,-.06,.74),'body'),
        ('neck_upper',(0,-.06,.74),(0,-.085,.87),'neck_base'),
        ('head',(0,-.085,.87),(0,-.1,.99),'neck_upper'),
    ]
    for sign,tag in [(-1,'l'),(1,'r')]:
        bones += [('wing_'+tag,(sign*.108,.023,.5),(sign*.14,.12,.25),'body'),('foot_'+tag,(sign*.054,0,.10),(sign*.054,-.05,.015),'root')]
    for name,a,b,parent in bones:
        bone=arm.edit_bones.new(name);bone.head=point(a);bone.tail=point(b)
        if parent:bone.parent=arm.edit_bones[parent]
    bpy.ops.object.mode_set(mode='OBJECT')
    mod=obj.modifiers.new('Reusable B2 mother deformation','ARMATURE');mod.object=rig
    # The armature modifier supplies deformation. Keep the mesh at scene root
    # so glTF runtimes do not encounter ignored parent transforms on skin nodes.
    obj.parent=None
    unweighted=[];sums=[]
    for v in obj.data.vertices:
        s=sum(g.weight for g in v.groups);sums.append(s)
        if s<.999:unweighted.append(v.index)
    assert not unweighted
    scene=bpy.context.scene;scene.render.fps=30
    clips={
      'duck_idle':[(1,{}),(31,{'neck_base':{'rotation_euler':(.025,0,.015)},'head':{'rotation_euler':(-.025,.035,0)}}),(61,{})],
      'duck_greet':[(1,{}),(9,{'wing_r':{'rotation_euler':(0,0,-.65)},'head':{'rotation_euler':(-.07,.12,0)}}),(17,{'wing_r':{'rotation_euler':(0,0,-.25)},'head':{'rotation_euler':(-.04,.1,0)}}),(25,{'wing_r':{'rotation_euler':(0,0,-.7)}}),(40,{})],
      'duck_click':[(1,{}),(4,{'root':{'scale':(1.05,.88,1.05)},'head':{'rotation_euler':(.07,0,0)}}),(9,{'root':{'scale':(.98,1.045,.98)},'head':{'rotation_euler':(-.04,0,0)}}),(18,{})]
    }
    rig.animation_data_create()
    metrics=[]
    reset(rig);base=evaluated(obj)
    for name,keys in clips.items():
        action=bpy.data.actions.new(name);rig.animation_data.action=action
        for frame,changes in keys:
            reset(rig)
            for bone,channels in changes.items():
                for key,value in channels.items():setattr(rig.pose.bones[bone],key,value)
            for pb in rig.pose.bones:
                for ch in ['rotation_euler','location','scale']:pb.keyframe_insert(data_path=ch,frame=frame,group=pb.name)
        # Test actual evaluated mesh vertices, not merely animation channels.
        testframe=keys[1][0];scene.frame_set(testframe);bpy.context.view_layer.update()
        moved=evaluated(obj);d=[(a-b).length for a,b in zip(base,moved)]
        metrics.append({'action':name,'frames':[keys[0][0],keys[-1][0]],'sampleFrame':testframe,'movedVertices':sum(x>1e-5 for x in d),'maximumDisplacement':max(d)})
        assert max(d)>.003,name
        action.use_fake_user=True
        track=rig.animation_data.nla_tracks.new();track.name=name
        strip=track.strips.new(name,1,action);track.mute=True
    rig.animation_data.action=None;reset(rig);scene.frame_set(1)
    bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);obj.select_set(True)
    bpy.context.view_layer.objects.active=rig
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/duck-b2-master-rig.blend'))
    dest=OUT/'models/duck-b2-master-rig.glb'
    # ACTIONS exports individual clips; rig remains in its neutral rest pose.
    bpy.ops.export_scene.gltf(filepath=str(dest),export_format='GLB',use_selection=True,export_animations=True,export_animation_mode='ACTIONS',export_force_sampling=True,export_frame_range=False)
    H.write(OUT/'qa/rig-source-validation.json',{'meshSha256':hashlib.sha256((OUT/'models/duck-b2-master/duck-b2-master.glb').read_bytes()).hexdigest(),'boneCount':len(bones),'unweightedVertices':len(unweighted),'weightSumRange':[min(sums),max(sums)],'clips':metrics,'blenderEvaluatedVertexMotionPassed':True,'unityImported':False,'unityVertexMotionVerified':False})
    # Verify the exported GLB's animated vertices after re-import.
    H.clear();bpy.context.scene.render.fps=30;bpy.ops.import_scene.gltf(filepath=str(dest))
    rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
    obj=next(o for o in bpy.context.scene.objects if o.type=='MESH')
    exported=[]
    for action in bpy.data.actions:
        rig.animation_data_create();rig.animation_data.action=action
        for tr in rig.animation_data.nla_tracks:tr.mute=True
        first,last=tuple(action.frame_range)
        for f in [first,first+(last-first)*.25,first+(last-first)*.5,last]:
            bpy.context.scene.frame_set(int(f),subframe=f-int(f));bpy.context.view_layer.update()
            p=evaluated(obj)
            if f==first:start=p
            else:
                d=[(a-b).length for a,b in zip(start,p)]
                exported.append({'action':action.name,'frame':f,'isEnd':f==last,'movedVertices':sum(x>1e-5 for x in d),'maximumDisplacement':max(d)})
    assert len(bpy.data.actions)==3,len(bpy.data.actions)
    assert all(any(r['action']==a.name and r['maximumDisplacement']>.003 for r in exported) for a in bpy.data.actions)
    assert all(r['maximumDisplacement']<1e-5 for r in exported if r['isEnd'])
    H.write(OUT/'qa/rig-roundtrip-validation.json',{'sourceSha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'actionCount':len(bpy.data.actions),'actions':[a.name for a in bpy.data.actions],'samples':exported,'roundtripVertexMotionPassed':True,'allClipsReturnToRest':True,'unityVertexMotionVerified':False})
    print('B2_RIG_ROUNDTRIP_PASSED',flush=True)
    scene,cam=H.studio();scene.cycles.samples=12
    cam.location=(2.3,-4,.45);cam.data.ortho_scale=1.25;H.aim(cam)
    scene.render.resolution_x=scene.render.resolution_y=320
    animinfo=[]
    for action in bpy.data.actions:
        rig.animation_data.action=action
        first,last=tuple(action.frame_range)
        count=24 if action.name!='duck_click' else 16
        folder=OUT/'renders/animation-frames'/action.name;folder.mkdir(parents=True,exist_ok=True)
        for index in range(count):
            f=first+(last-first)*index/(count-1)
            scene.frame_set(int(f),subframe=f-int(f));bpy.context.view_layer.update()
            scene.render.filepath=str(folder/f'{index:03}.png');bpy.ops.render.render(write_still=True)
        animinfo.append({'action':action.name,'frames':count,'durationSeconds':(last-first)/30,'renderedFromRoundtripGlb':True})
    H.write(OUT/'qa/animation-preview.json',{'sourceSha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'clips':animinfo,'canvas':[320,320],'orthographicScale':1.25})
    # Pose studies from that same source mesh and rig; no shell production yet.
    bpy.ops.wm.open_mainfile(filepath=str(OUT/'source/duck-b2-master-rig.blend'))
    rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE');obj=next(o for o in bpy.context.scene.objects if o.type=='MESH')
    rig.animation_data.action=None
    for tr in rig.animation_data.nla_tracks:tr.mute=True
    scene,cam=H.studio();scene.cycles.samples=32
    cam.location=(2.3,-4,.45);cam.data.ortho_scale=1.25;H.aim(cam)
    scene.render.resolution_x=scene.render.resolution_y=700
    poses={
        'rest':{},
        'reach':{'neck_base':(.5,0,0),'neck_upper':(.4,0,0),'head':(-.65,0,0)},
        'greeting':{'wing_r':(0,0,-.65),'head':(-.07,.12,0)},
    }
    for name,changes in poses.items():
        reset(rig)
        for bone,rot in changes.items():rig.pose.bones[bone].rotation_euler=rot
        bpy.context.view_layer.update()
        scene.render.filepath=str(OUT/'renders'/('pose-'+name+'.png'));bpy.ops.render.render(write_still=True)
    reset(rig)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/duck-b2-master-rig-review.blend'))

if __name__=='__main__':main()
