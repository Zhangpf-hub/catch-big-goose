"""Round-trip GLBs and render four views plus 192/64px icons for QA."""
import json,math
from pathlib import Path
import bpy
from mathutils import Vector
root=Path('assets-3d/candidates/mobile-runtime-20261024').resolve()
rows=json.loads((root/'batch-results.json').read_text('utf-8'));results=[]
for row in rows:
    folder=root/row['id'];bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(folder/(row['id']+'.glb')))
    objects=[o for o in bpy.context.scene.objects if o.type=='MESH']
    points=[o.matrix_world@Vector(c) for o in objects for c in o.bound_box]
    lo=Vector([min(p[i] for p in points) for i in range(3)]);hi=Vector([max(p[i] for p in points) for i in range(3)])
    centre=(lo+hi)*.5;size=max(hi-lo);scene=bpy.context.scene;scene.render.engine='BLENDER_EEVEE_NEXT'
    if hasattr(scene.eevee,'taa_render_samples'):scene.eevee.taa_render_samples=8
    scene.render.resolution_x=scene.render.resolution_y=256;scene.render.resolution_percentage=100
    scene.render.film_transparent=True;scene.render.image_settings.file_format='PNG'
    scene.view_settings.view_transform='Standard'
    world=bpy.data.worlds.new('Neutral');world.use_nodes=True;world.node_tree.nodes['Background'].inputs[0].default_value=(.65,.65,.65,1);world.node_tree.nodes['Background'].inputs[1].default_value=.5;scene.world=world
    for name,position,power,diameter in [('Key',(3,-4,5),350,4),('Fill',(-3,-2,2),180,3),('Rim',(0,3,3),220,3)]:
        data=bpy.data.lights.new(name,'AREA');data.energy=power;data.shape='DISK';data.size=diameter
        obj=bpy.data.objects.new(name,data);scene.collection.objects.link(obj);obj.location=centre+Vector(position)*size;obj.rotation_euler=(centre-obj.location).to_track_quat('-Z','Y').to_euler()
    camera=bpy.data.objects.new('QAView',bpy.data.cameras.new('QAView'));scene.collection.objects.link(camera);camera.data.type='ORTHO';camera.data.ortho_scale=size*1.4;scene.camera=camera
    for label,direction in [('three-quarter',(3,-4,3)),('top',(0,-.001,5)),('side',(5,0,1)),('back',(0,5,1))]:
        camera.location=centre+Vector(direction)*size;camera.rotation_euler=(centre-camera.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(folder/(label+'.png'));bpy.ops.render.render(write_still=True)
    image=bpy.data.images.load(str(folder/'three-quarter.png'),check_existing=False)
    for pixels in [192,64]:image.scale(pixels,pixels);image.filepath_raw=str(folder/('icon-'+str(pixels)+'.png'));image.file_format='PNG';image.save()
    results.append(dict(id=row['id'],views=4,glbRoundTrip=True));(root/'visual-render.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
    print('MOBILE_QA_RENDER',row['id'],flush=True)
