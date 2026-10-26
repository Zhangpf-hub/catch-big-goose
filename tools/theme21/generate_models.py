"""Blender batch: 60 original candidates, GLB roundtrip and real rendered views."""
import argparse
import hashlib
import json
import math
import sys
from pathlib import Path
import bpy
from mathutils import Vector
sys.path.insert(0,str(Path(__file__).resolve().parent))
from catalog import specifications,BATCH
from modelkit import base
from organic import fruit,farm
from craft_food import antique,dessert
from devices import electronics

def render(obj,output):
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=12;scene.cycles.use_denoising=True
    scene.render.film_transparent=True;scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA'
    scene.render.resolution_x=scene.render.resolution_y=256;scene.render.resolution_percentage=100
    scene.view_settings.view_transform='Standard';scene.world.color=(.45,.45,.45)
    camera=bpy.data.objects.new('QaCamera',bpy.data.cameras.new('QaCamera'));bpy.context.collection.objects.link(camera)
    camera.data.type='ORTHO';scene.camera=camera
    for loc,power in [((3,-4,5),380),((-3,1,3),220)]:
        light=bpy.data.objects.new('QaLight',bpy.data.lights.new('QaLight','AREA'));bpy.context.collection.objects.link(light)
        light.location=loc;light.data.energy=power;light.data.size=4;light.rotation_euler=(-light.location).to_track_quat('-Z','Y').to_euler()
    for view,loc in [('hero',(2.7,-4.2,2.9)),('top',(0,-.001,5)),('back',(-2.7,4.2,2)),('side',(5,0,.3))]:
        camera.location=loc;camera.rotation_euler=(-camera.location).to_track_quat('-Z','Y').to_euler()
        bpy.context.view_layer.update();inverse=camera.matrix_world.inverted()
        points=[inverse@(obj.matrix_world@Vector(v)) for v in obj.bound_box]
        camera.data.ortho_scale=max(max(p.x for p in points)-min(p.x for p in points),max(p.y for p in points)-min(p.y for p in points))*1.28
        scene.render.filepath=str(output/'qa'/f'{obj.name}-{view}.png');bpy.ops.render.render(write_still=True)
    icon=bpy.data.images.load(str(output/'qa'/f'{obj.name}-hero.png'),check_existing=False)
    for size in [192,64]:
        icon.scale(size,size);icon.filepath_raw=str(output/'icons'/f'{obj.name}{"" if size==192 else "-64"}.png');icon.file_format='PNG';icon.save()
    bpy.data.images.remove(icon)

def main():
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=BATCH);p.add_argument('--only',default='');p.add_argument('--skip-render',action='store_true');a=p.parse_args(sys.argv[sys.argv.index('--')+1:])
    a.output=a.output.resolve()
    for name in ['models','source','icons','qa']:(a.output/name).mkdir(parents=True,exist_ok=True)
    bpy.context.preferences.filepaths.save_version=0
    specs=specifications();wanted=set(a.only.split(',')) if a.only else {s['id'] for s in specs}
    for s in specs:
        id=s['id']
        if id not in wanted:continue
        base.clear();base.PARTS=[];base.MAT=base.palette(id)
        globals()[s['theme']](id)
        obj=base.normalize_and_join(id);metrics=base.geometry_metrics(obj)
        bpy.ops.wm.save_as_mainfile(filepath=str(a.output/'source'/f'{id}.blend'))
        bpy.ops.object.select_all(action='DESELECT');obj.select_set(True)
        glb=a.output/'models'/f'{id}.glb'
        bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,export_yup=True,export_apply=True,
                                  export_cameras=False,export_lights=False,export_extras=True,export_materials='EXPORT')
        base.clear();bpy.ops.import_scene.gltf(filepath=str(glb));objs=[o for o in bpy.context.scene.objects if o.type=='MESH'];assert len(objs)==1
        obj=objs[0];obj.name=id;loaded=base.geometry_metrics(obj);assert loaded['triangles']==metrics['triangles']
        assert glb.stat().st_size<=262144
        row=dict(id=id,theme=s['theme'],**loaded,materials=1,textureSize=[64,64],bytes=glb.stat().st_size,
                 sha256=hashlib.sha256(glb.read_bytes()).hexdigest(),roundtripPassed=True,blenderVersion=bpy.app.version_string,
                 origin='Original procedural geometry and palette; no competitor mesh or texture')
        if not a.skip_render:render(obj,a.output)
        (a.output/'qa'/f'{id}.metrics.json').write_text(json.dumps(row,indent=2),'utf-8')
        print('MODEL_PASS '+json.dumps(row),flush=True)
    rows=[json.loads(p.read_text('utf-8')) for p in sorted((a.output/'qa').glob('*.metrics.json'))]
    (a.output/'qa/generation.json').write_text(json.dumps(rows,indent=2),'utf-8')
    print('GENERATED',len(rows),flush=True)

if __name__=='__main__':main()
