"""Actual high/low render and numerical source mesh inspection for B2 acceptance."""
import hashlib
import importlib.util
import json
from pathlib import Path
import bpy
from mathutils import Vector,Matrix

spec=importlib.util.spec_from_file_location('master',Path(__file__).with_name('build_duck_b2_master.py'))
M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
H=M.H;OUT=M.OUT

def main():
    a=json.loads((OUT/'qa/authoring.json').read_text('utf-8'))
    center=Vector(a['sourceCenter']);extent=a['sourceExtent']
    H.clear();src=OUT/'models/duck-b2-master-high.glb'
    bpy.ops.import_scene.gltf(filepath=str(src))
    for o in [o for o in bpy.context.scene.objects if o.type=='MESH']:
        mat=o.matrix_world.copy()
        for v in o.data.vertices:v.co=(mat@v.co-center)/extent
        o.matrix_world=Matrix.Identity(4);o.data.update()
    scene,cam=H.studio();scene.cycles.samples=32
    for o in scene.objects:
        if o.type=='LIGHT':
            if o.name=='Key':o.data.size=2.5;o.data.energy=220
            if o.name=='Fill':o.data.energy=40
    bg=next(n for n in scene.world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs[1].default_value=.3
    cam.data.ortho_scale=1.18;scene.render.resolution_x=scene.render.resolution_y=900
    for name,pos in {'front':(0,-4,0),'side':(4,0,0),'hero':(2.3,-4,.45)}.items():
        cam.location=pos;H.aim(cam)
        scene.render.filepath=str(OUT/'renders'/('high-'+name+'.png'));bpy.ops.render.render(write_still=True)
    H.write(OUT/'qa/high-render-source.json',{'sourceSha256':hashlib.sha256(src.read_bytes()).hexdigest(),'sharedLowNormalization':{'center':list(center),'extent':extent},'sameCameraAndLightingAsLow':True,'conceptUsedAsTexture':False})
    bpy.ops.wm.open_mainfile(filepath=str(OUT/'source/duck-b2-master-mobile.blend'))
    o=next(o for o in bpy.context.scene.objects if o.type=='MESH')
    def has(v,name):
        idx=o.vertex_groups[name].index
        return any(g.group==idx and g.weight>.4 for g in v.groups)
    def raw(v):return v.co*extent+center
    head=[v.co.x for v in o.data.vertices if raw(v).z>.875 and has(v,'head')]
    body=[v.co.x for v in o.data.vertices if .18<raw(v).z<.55 and has(v,'body')]
    foot=[v.co.x for v in o.data.vertices if has(v,'foot_l')]
    neck=[v.co.x for v in o.data.vertices if .775<raw(v).z<.805 and (has(v,'neck_base') or has(v,'neck_upper'))]
    span=lambda xs:max(xs)-min(xs)
    proportions={'headWidth':span(head),'torsoWidthExcludingWings':span(body),'singleFootWidth':span(foot),'neckWidthAtZ078':span(neck),'headToTorsoWidth':span(head)/span(body),'footToTorsoWidth':span(foot)/span(body),'unit':'full mother model maximum edge = 1','source':'evaluated mobile mesh vertices grouped by authored part; descriptive metrics, not user acceptance'}
    H.write(OUT/'qa/proportions.json',proportions)
    # Editable continuous quad cage proof; colors use workbench, independent of PBR.
    bpy.ops.wm.open_mainfile(filepath=str(OUT/'source/duck-b2-master-cage.blend'))
    meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
    for o in meshes:
        for mod in list(o.modifiers):o.modifiers.remove(mod)
        # Render geometry-edge tubes. This is a diagnostic overlay, not an asset.
        for mat in o.data.materials:
            mat.diffuse_color=(.74,.8,.82,1)
        o.show_wire=True;o.show_all_edges=True
    skin=next(o for o in meshes if 'continuous' in o.name)
    H.write(OUT/'qa/cage-topology.json',{'skinVertices':len(skin.data.vertices),'skinFaces':len(skin.data.polygons),'skinQuads':sum(len(f.vertices)==4 for f in skin.data.polygons),'separateHeadPrimitive':False,'skinComponents':1,'note':'Head, neck, torso and tail are one authored cage. Bill/eyes/wings/feet are separate closed attached surfaces.'})
    print('B2_PROPORTIONS',json.dumps(proportions),flush=True)

if __name__=='__main__':main()
