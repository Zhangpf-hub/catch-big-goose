"""Neutral actual-mesh turn views and animated review video, no image generation."""
import bpy,math
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'source-assets/models/candidates/shiba-20261025-v1'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'source/shiba-animated.blend'))
bpy.context.preferences.filepaths.save_version=0
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=16;scene.cycles.use_denoising=True
scene.view_settings.view_transform='AgX';scene.view_settings.look='AgX - Medium High Contrast'
scene.world=bpy.data.worlds.new('Review daylight');scene.world.use_nodes=True
bg=next(n for n in scene.world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs[0].default_value=(.75,.80,.88,1);bg.inputs[1].default_value=.5
def aim(o,point):o.rotation_euler=(Vector(point)-o.location).to_track_quat('-Z','Y').to_euler()
for name,loc,power,size in [('Key',(-2,-3,4),180,4),('Fill',(3,-1,2),95,3),('Rim',(0,3,3),120,3)]:
    data=bpy.data.lights.new(name,'AREA');data.energy=power;data.shape='DISK';data.size=size;o=bpy.data.objects.new(name,data);scene.collection.objects.link(o);o.location=loc;aim(o,(0,0,0))
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.5));floor=bpy.context.object
mat=bpy.data.materials.new('Warm neutral ground');mat.use_nodes=True;bs=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED');bs.inputs['Base Color'].default_value=(.55,.53,.48,1);bs.inputs['Roughness'].default_value=.85;floor.data.materials.append(mat)
data=bpy.data.cameras.new('ReviewCamera');cam=bpy.data.objects.new('ReviewCamera',data);scene.collection.objects.link(cam);scene.camera=cam;data.type='ORTHO';data.ortho_scale=1.28
cam.location=(2.1,-3,1.1);aim(cam,(0,0,0));scene.render.resolution_x=768;scene.render.resolution_y=768;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGB';scene.render.filepath=str(OUT/'renders/model-review.png');scene.frame_set(1);bpy.ops.render.render(write_still=True)
rig=bpy.data.objects['ShibaRig'];rig.animation_data.action=None
for track in rig.animation_data.nla_tracks:track.mute=True
for name,start in [('Idle',1),('Happy',61),('Bounce',97)]:
    tr=rig.animation_data.nla_tracks.new();tr.name='Review_'+name+str(start);strip=tr.strips.new(name,start,bpy.data.actions[name]);strip.extrapolation='NOTHING'
scene.render.fps=24;scene.frame_start=1;scene.frame_end=120;scene.render.resolution_x=480;scene.render.resolution_y=480;scene.cycles.samples=4
scene.render.image_settings.file_format='FFMPEG';scene.render.ffmpeg.format='MPEG4';scene.render.ffmpeg.codec='H264';scene.render.filepath=str(OUT/'renders/animation-review.mp4')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/shiba-animation-review.blend'))
bpy.ops.render.render(animation=True)
print('REVIEW_VIDEO_DONE')
