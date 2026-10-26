"""B2 duck: authored silhouette cage, continuous subdivision surface, no voxel union.

The approved front/side drawing constrains the section table. High and low use
the SAME editable cage. No competitor geometry is used. Candidate only.
"""
import argparse
import hashlib
import importlib.util
import json
import math
import sys
from pathlib import Path

import bpy
import bmesh
from mathutils import Vector, Matrix

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT/'source-assets/models/candidates/duck-series-v1/master-b2'
spec=importlib.util.spec_from_file_location('render_helpers',Path(__file__).with_name('build_duck_representatives.py'))
H=importlib.util.module_from_spec(spec);spec.loader.exec_module(H)
H.OUT=OUT
ID='duck-b2-master'

# z, half-width, front y, rear y. Units: full height about 1.0.
# The front and side silhouettes were measured from the approved 1774x887 B2
# concept; sections are adjusted explicitly, not inferred from primitive balls.
SECTIONS=[
 (.102,.054,-.036,.071),(.115,.067,-.054,.101),
 (.135,.087,-.079,.132),(.185,.113,-.119,.174),
 (.250,.131,-.147,.190),(.280,.136,-.153,.193),
 (.305,.138,-.156,.193),(.335,.140,-.158,.191),
 (.420,.138,-.151,.165),(.500,.123,-.135,.119),
 (.580,.099,-.116,.068),(.650,.075,-.103,.026),
 (.720,.052,-.099,-.012),(.785,.039,-.106,-.033),
 (.840,.037,-.119,-.043),(.875,.042,-.143,-.040),
 (.900,.051,-.165,-.033),(.935,.057,-.175,-.032),
 (.965,.053,-.173,-.039),(.988,.035,-.158,-.056),
 (1.000,.009,-.127,-.093),
]

def smoothstep(t):
    t=max(0,min(1,t));return t*t*(3-2*t)

def section(z):
    for a,b in zip(SECTIONS,SECTIONS[1:]):
        if z<=b[0]:
            t=max(0,min(1,(z-a[0])/(b[0]-a[0])))
            return tuple(a[i]+(b[i]-a[i])*t for i in [1,2,3])
    return SECTIONS[-1][1:]

def subd(obj,levels=2):
    m=obj.modifiers.new('Reference-constrained Catmull Clark','SUBSURF')
    m.subdivision_type='CATMULL_CLARK';m.levels=levels;m.render_levels=levels
    return m

def loft(name,rings,colour,sides=16,levels=2):
    vertices=[p for ring in rings for p in ring]
    faces=[]
    for i in range(len(rings)-1):
        for j in range(sides):
            faces.append((i*sides+j,i*sides+(j+1)%sides,(i+1)*sides+(j+1)%sides,(i+1)*sides+j))
    # One pole per end, stable on export and avoids nonplanar n-gons.
    for end,idx in [(0,0),(-1,(len(rings)-1)*sides)]:
        center=sum((Vector(p) for p in rings[end]),Vector())/sides
        pole=len(vertices);vertices.append(center)
        for j in range(sides):faces.append((pole,idx+(j+1)%sides,idx+j))
    obj=H.mesh(name,vertices,faces,colour)
    subd(obj,levels)
    return obj

def make_skin():
    rings=[];sides=20
    for z,rx,front,back in SECTIONS:
        ring=[]
        for j in range(sides):
            a=j*math.tau/sides
            c=math.cos(a);s=math.sin(a)
            y=(front+back)/2+(back-front)/2*c
            # A small upturned tail is part of the continuous torso cage.
            tail=.112*math.exp(-((z-.300)/.028)**2)*max(0,c)**10
            y+=tail
            zz=z
            if z<.12:zz-=.014*abs(s)**2
            ring.append((rx*s,y,zz))
        rings.append(ring)
    return loft('B2 continuous head neck torso tail',rings,'white',sides,2)

def make_bill():
    # bridge, spatulate middle, and rounded flat tip; the bridge embeds in face.
    rows=[(-.147,.027,.017,.904),(-.166,.028,.016,.901),
          (-.188,.034,.010,.895),(-.221,.041,.009,.894),
          (-.242,.037,.008,.894),(-.253,.024,.007,.895),
          (-.257,.006,.003,.896)]
    rings=[]
    for y,rx,rz,z in rows:
        rings.append([(rx*math.cos(j*math.tau/16),y,z+rz*math.sin(j*math.tau/16)) for j in range(16)])
    return loft('B2 small broad flat bill',rings,'orange',16,2)

def make_wing(sign):
    rings=[]
    # Vertical teardrop, tightly folded along the torso surface.
    for z,y,ry,depth in [(.187,.152,.003,.001),(.208,.144,.022,.006),
        (.255,.118,.045,.018),(.325,.090,.058,.026),
        (.400,.060,.058,.026),(.475,.036,.045,.021),
        (.531,.023,.025,.010),(.548,.023,.006,.001)]:
        rx,f,b=section(z);yc=(f+b)/2;yr=(b-f)/2
        ring=[]
        for j in range(12):
            a=j*math.tau/12;yy=y+ry*math.cos(a)
            surface=rx*math.sqrt(max(.08,1-((yy-yc)/yr)**2))
            xx=surface+.006+depth*math.sin(a)
            ring.append((sign*xx,yy,z))
        rings.append(ring)
    return loft('B2 folded wing '+str(sign),rings,'white',12,2)

def make_foot(sign):
    # Organic closed ankle-to-web loft, 3 shallow toe scallops, no block extrusion.
    cx=sign*.054
    rows=[(.006,.027,-.071,.006),(.013,.046,-.079,.020),
          (.024,.048,-.077,.023),(.037,.033,-.051,.023),
          (.054,.015,-.010,.021),(.083,.013,-.005,.021),
          (.105,.016,-.007,.022)]
    rings=[]
    for z,rx,f,b in rows:
        ring=[]
        for j in range(16):
            a=j*math.tau/16;c=math.cos(a);s=math.sin(a)
            y=(f+b)/2+(b-f)/2*c
            if c<0 and z<.040:
                y-=.0045*math.cos(s*math.pi*3)*(-c)
            ring.append((cx+rx*s,y,z))
        rings.append(ring)
    return loft('B2 small webbed foot '+str(sign),rings,'orange',16,2)

def make_eye(sign):
    # Eyes sit on the cheek. The black bead is small and only slightly proud.
    obj=H.ball('B2 black eye '+str(sign),(sign*.042,-.1475,.946),(.0064,.0045,.0085),'eye',12,8)
    obj.rotation_euler.z=sign*math.radians(30)
    return obj

def rig_weights(obj):
    groups={name:obj.vertex_groups.new(name=name) for name in ['body','neck_base','neck_upper','head','wing_l','wing_r','foot_l','foot_r']}
    if 'wing' in obj.name:
        name='wing_l' if obj.name.endswith('-1') else 'wing_r'
        groups[name].add(list(range(len(obj.data.vertices))),1,'REPLACE');return
    if 'foot' in obj.name:
        name='foot_l' if obj.name.endswith('-1') else 'foot_r'
        groups[name].add(list(range(len(obj.data.vertices))),1,'REPLACE');return
    if 'eye' in obj.name or 'bill' in obj.name:
        groups['head'].add(list(range(len(obj.data.vertices))),1,'REPLACE');return
    for v in obj.data.vertices:
        z=v.co.z
        if z<.44:weights={'body':1}
        elif z<.67:
            t=smoothstep((z-.44)/.23);weights={'body':1-t,'neck_base':t}
        elif z<.82:
            t=smoothstep((z-.67)/.15);weights={'neck_base':1-t,'neck_upper':t}
        elif z<.90:
            t=smoothstep((z-.82)/.08);weights={'neck_upper':1-t,'head':t}
        else:weights={'head':1}
        for name,w in weights.items():
            if w>0:groups[name].add([v.index],w,'REPLACE')

def write(path,data):H.write(path,data)

def material_quality():
    H.PALETTE['white']=(.985,.976,.953)
    H.PALETTE['orange']=(1,.54,.065)

def build():
    H.clear();material_quality()
    skin=make_skin();make_bill()
    for sign in [-1,1]:make_wing(sign);make_foot(sign);make_eye(sign)
    # Preserve editable cage; packed reference is an image data block, not geometry.
    ref=ROOT/'source-assets/models/candidates/duck-series-v1/concepts-b2/duck-b2-turnaround.png'
    im=bpy.data.images.load(str(ref));im.pack()
    for obj in H.PARTS:
        obj['design_source']='approved-b2';obj['revision']='b2-continuous-cage-1'
        rig_weights(obj)
    skin['section_table']=json.dumps(SECTIONS)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/duck-b2-master-cage.blend'))
    source_parts=list(H.PARTS)
    # Export a high-resolution authoring surface separately, preserving the cage.
    high=[]
    for obj in source_parts:
        cp=obj.copy();cp.data=obj.data.copy();bpy.context.collection.objects.link(cp)
        high.append(cp)
        for mod in list(cp.modifiers):H.apply(cp,mod)
    hightri=sum(H.tris(o) for o in high)
    bpy.ops.object.select_all(action='DESELECT')
    for obj in high:obj.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(OUT/'models/duck-b2-master-high.glb'),export_format='GLB',use_selection=True,export_animations=False)
    for obj in high:bpy.data.objects.remove(obj,do_unlink=True)
    # Exactly one subdivision level; no voxelization or whole-character decimate.
    for obj in source_parts:
        for mod in list(obj.modifiers):
            if mod.type=='SUBSURF':mod.levels=1;mod.render_levels=1
            H.apply(obj,mod)
        # Preserve all head/neck/torso loops. Reduce only the small accessory
        # surfaces, with high-versus-low silhouette evidence rendered below.
        if 'wing' in obj.name or 'foot' in obj.name or 'bill' in obj.name:
            m=obj.modifiers.new('Accessory-only mobile reduction','DECIMATE')
            m.ratio=.45 if 'bill' in obj.name else .34
            H.apply(obj,m)
    low=H.join(source_parts,ID)
    folder=OUT/'models'/ID;folder.mkdir(parents=True,exist_ok=True)
    H.atlas(low,folder,ID)
    lo,hi=H.bounds([low]);center=(lo+hi)*.5;extent=max(hi-lo)
    for v in low.data.vertices:v.co=(v.co-center)/extent
    low.data.update()
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/duck-b2-master-mobile.blend'))
    bpy.ops.export_scene.gltf(filepath=str(folder/(ID+'.glb')),export_format='GLB',use_selection=True,export_animations=False)
    bpy.ops.export_scene.fbx(filepath=str(folder/(ID+'.fbx')),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=False,path_mode='STRIP')
    write(OUT/'qa/authoring.json',{'method':'one continuous authored quad section cage; level 2 high / level 1 mobile; accessory-only reduction','reference':str(ref.relative_to(ROOT)),'referenceSha256':hashlib.sha256(ref.read_bytes()).hexdigest(),'sectionTable':SECTIONS,'highTriangles':hightri,'mobileTriangles':H.tris(low),'sourceCenter':list(center),'sourceExtent':extent,'noVoxelUnion':True,'skinDecimated':False,'accessoryDecimation':{'bill':.45,'wings':.34,'feet':.34},'noCompetitorGeometry':True,'conceptApprovedUserText':'通过 完成计划','motherModelApproved':False})
    H.clear();bpy.ops.import_scene.gltf(filepath=str(folder/(ID+'.glb')))
    report=H.audit_import(ID);print('B2_MASTER_BUILT',json.dumps(report),flush=True)
    assert report['passed'],report

def render(preview=False):
    H.clear();bpy.ops.import_scene.gltf(filepath=str(OUT/'models'/ID/(ID+'.glb')))
    scene,cam=H.studio()
    scene.cycles.samples=32
    for o in scene.objects:
        if o.type=='LIGHT':
            if o.name=='Key':o.data.size=2.5;o.data.energy=220
            if o.name=='Fill':o.data.energy=40
    bg=next(n for n in scene.world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs[1].default_value=.3
    # Shallower hero than gameplay so the head proportions can be assessed.
    views={'front':(0,-4,0),'side':(4,0,0),'back':(0,4,0),'hero':(2.3,-4,.45),'gameplay':(1.4,-2.3,3.3)}
    for name,pos in views.items():
        if preview and name not in ['front','side','hero']:continue
        cam.location=pos;H.aim(cam)
        cam.data.ortho_scale=1.18
        scene.render.resolution_x=scene.render.resolution_y=900
        scene.render.filepath=str(OUT/'renders'/f'{name}.png');bpy.ops.render.render(write_still=True)
    if not preview:
        cam.location=views['hero'];H.aim(cam);cam.data.ortho_scale=1.25
        for size in [192,64]:
            scene.render.resolution_x=scene.render.resolution_y=size
            scene.render.filepath=str(OUT/'renders'/f'icon-{size}.png');bpy.ops.render.render(write_still=True)
        # Face detail is explicitly a close-up; never labelled same-size reference.
        cam.location=(1.5,-3,.47);H.aim(cam,(0,-.11,.43));cam.data.ortho_scale=.32
        scene.render.resolution_x=scene.render.resolution_y=640
        scene.render.filepath=str(OUT/'renders/head-detail.png');bpy.ops.render.render(write_still=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/duck-b2-master-review.blend'))
    write(OUT/'qa/render-source.json',{'source':str((OUT/'models'/ID/(ID+'.glb')).relative_to(ROOT)),'sha256':hashlib.sha256((OUT/'models'/ID/(ID+'.glb')).read_bytes()).hexdigest(),'views':views,'orthographicScale':1.18,'canvas':[900,900],'renderedFromRoundtripGlb':True,'renderer':bpy.app.version_string+' Cycles 32 samples','conceptUsedAsTexture':False})

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--render-only',action='store_true');parser.add_argument('--build-only',action='store_true');parser.add_argument('--preview',action='store_true')
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
    for d in ['source','models','renders','qa']:(OUT/d).mkdir(parents=True,exist_ok=True)
    if not args.render_only:build()
    if not args.build_only:render(args.preview)

if __name__=='__main__':main()
