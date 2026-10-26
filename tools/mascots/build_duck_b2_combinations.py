"""Three B2 candidates derived from the exact reusable mother mesh and skeleton.

Only hidden torso/wing geometry is removed. Heads, bills, eyes and feet are not
regenerated; the existing neck is posed and cut inside the prop shell. Sources
and competitor GLBs are read-only. No Unity runtime assets are changed here.
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
from mathutils import Vector,Matrix

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'source-assets/models/candidates/duck-series-v1/model-review-b2'
MASTER=ROOT/'source-assets/models/candidates/duck-series-v1/master-b2'
spec=importlib.util.spec_from_file_location('shared',Path(__file__).with_name('build_duck_representatives.py'))
H=importlib.util.module_from_spec(spec);spec.loader.exec_module(H);H.OUT=OUT
IDS=['duck-eggtart','duck-steelcup','duck-numberblock']
DETAIL=False
META=json.loads((MASTER/'qa/authoring.json').read_text('utf-8'))
CENTER=Vector(META['sourceCenter']);EXTENT=META['sourceExtent']
PALETTE=H.PALETTE.copy();PALETTE.update(white=(.985,.976,.953),orange=(1,.54,.065),rim=(.96,.64,.26),crust=(.83,.43,.12),custard=(1,.79,.22),metal=(.73,.77,.80),inside=(.46,.49,.52),red=(.97,.23,.18),green=(.61,.89,.19))
H.PALETTE=PALETTE
RULES={
 'duck-eggtart':{'neckCut':.68,'neckPose':[.55,.18,-.73],'headReach':.18,'yaw':0,'lean':0,'root':[.045,.025,.66],'feet':[[-.10,-.005,0],[.10,-.005,0]],'footYaw':0,'tailBase':[.395,.065,.42],'tailYaw':-90},
 'duck-steelcup':{'neckCut':.56,'bodyPose':.7,'neckPose':[-.55,.15,-.9981317],'yaw':90,'lean':40,'root':[.15,0,.33],'feet':[[-.22,-.16,0],[.16,-.08,0]],'footYaw':90,'tailBase':[-.425,0,.36],'keepTorso':True},
 'duck-numberblock':{'neckCut':.55,'neckPose':[.05,.05,-.7108652],'headReach':.12,'yaw':90,'lean':35,'root':[.10,0,.52],'feet':[[-.24,-.17,0],[.10,-.17,0]],'footYaw':45,'tailBase':[-.37,.02,.44]},
}

def raw(p):return Vector(p)*EXTENT+CENTER
def norm(p):return (Vector(p)-CENTER)/EXTENT
def write(p,d):H.write(p,d)

def part_kind(obj):
    weights={g.name:0 for g in obj.vertex_groups}
    for v in obj.data.vertices:
        for g in v.groups:weights[obj.vertex_groups[g.group].name]+=g.weight
    for prefix in ['foot_l','foot_r','wing_l','wing_r','body']:
        if weights.get(prefix,0)>1:return 'skin' if prefix=='body' else prefix
    uv=obj.data.uv_layers.active.data[0].uv
    cell=int(uv.x*4)+4*int(uv.y*4)
    return 'bill' if list(PALETTE)[cell]=='orange' else 'eye'

def crop(obj,normal,offset,keep_positive):
    bm=bmesh.new();bm.from_mesh(obj.data)
    n=Vector(normal);p=n*offset
    result=bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=1e-7,plane_co=p,plane_no=n,clear_inner=keep_positive,clear_outer=not keep_positive)
    edges=[e for e in bm.edges if e.is_boundary]
    if edges:bmesh.ops.holes_fill(bm,edges=edges,sides=0)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bm.to_mesh(obj.data);bm.free();obj.data.update()

def set_colour(obj,key):
    obj.data.materials.clear();obj.data.materials.append(H.material(key))
    for f in obj.data.polygons:f.material_index=0;f.use_smooth=True

def simplify_hidden_torso(obj):
    # Collapse no coordinates and never touch the exposed face. Only dissolve
    # nearly coplanar edges of the original torso below the neck inside the cup.
    bm=bmesh.new();bm.from_mesh(obj.data)
    verts=[v for v in bm.verts if raw(v.co).z<.60]
    edges=[e for e in bm.edges if all(raw(v.co).z<.60 for v in e.verts)]
    before=len(bm.faces)
    bmesh.ops.dissolve_limit(bm,angle_limit=math.radians(13),use_dissolve_boundaries=False,verts=verts,edges=edges,delimit=set())
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(obj.data);bm.free();obj.data.update()
    print('B2_HIDDEN_TORSO_DISSOLVE',before,len(obj.data.polygons),H.tris(obj),flush=True)

def mother_parts(id):
    rule=RULES[id]
    bpy.ops.wm.open_mainfile(filepath=str(MASTER/'source/duck-b2-master-rig.blend'))
    H.PARTS=[];H.MATS={};bpy.context.preferences.filepaths.save_version=0
    rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
    obj=next(o for o in bpy.context.scene.objects if o.type=='MESH')
    if rig.animation_data:
        rig.animation_data.action=None
        for tr in rig.animation_data.nla_tracks:tr.mute=True
    for bone in rig.pose.bones:
        bone.rotation_mode='XYZ';bone.rotation_euler=(0,0,0);bone.location=(0,0,0);bone.scale=(1,1,1)
    for bone,angle in zip(['neck_base','neck_upper','head'],rule['neckPose']):rig.pose.bones[bone].rotation_euler.x=angle
    rig.pose.bones['body'].rotation_euler.x=rule.get('bodyPose',0)
    rig.pose.bones['head'].location.y=rule.get('headReach',0)
    bpy.context.view_layer.update()
    bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
    bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.separate(type='LOOSE');bpy.ops.object.mode_set(mode='OBJECT')
    parts=[o for o in bpy.context.scene.objects if o.type=='MESH']
    # Find the posed cap centre before crop. This is a weighted vertex centroid
    # near the rest cut height, avoiding per-object proportions or head remeshing.
    skin=next(o for o in parts if part_kind(o)=='skin')
    dg=bpy.context.evaluated_depsgraph_get();ev=skin.evaluated_get(dg);em=ev.to_mesh()
    cut=rule['neckCut']
    indices=[v.index for v in skin.data.vertices if abs(raw(v.co).z-cut)<.035]
    cap_center=sum((raw(em.vertices[i].co) for i in indices),Vector())/len(indices)
    ev.to_mesh_clear()
    rotation=Matrix.Rotation(math.radians(rule['lean']),4,'Y')@Matrix.Rotation(math.radians(rule['yaw']),4,'Z')
    offset=Vector(rule['root'])-rotation@cap_center
    # Tail is copied from the original continuous mother surface, then cut inside
    # its hidden root. It is not a newly generated sphere or primitive.
    tail=skin.copy();tail.data=skin.data.copy();bpy.context.collection.objects.link(tail);parts.append(tail)
    kinds={o:part_kind(o) for o in parts};kinds[tail]='tail'
    crop(skin,(0,0,1),norm((0,0,.102 if rule.get('keepTorso') else cut)).z,True)
    if rule.get('keepTorso'):simplify_hidden_torso(skin)
    crop(tail,(0,1,0),norm((0,.185,0)).y,True)
    identity=[]
    for o in parts:
        kind=kinds[o]
        if kind.startswith('wing'):
            bpy.data.objects.remove(o,do_unlink=True);continue
        o.name='B2 mother '+kind
        # Cache unmodified head/bill samples to prove that only rigid placement
        # and the existing skeletal deformation are used on the exposed face.
        before=[raw(v.co) for v in o.data.vertices]
        head_indices=[]
        if kind=='skin':
            group=o.vertex_groups.get('head')
            head_indices=[v.index for v in o.data.vertices if raw(v.co).z>.92 and any(g.group==group.index and g.weight>.9999 for g in v.groups)]
        for mod in list(o.modifiers):H.apply(o,mod)
        after=[raw(v.co) for v in o.data.vertices]
        if kind=='tail':
            # The tail's rear cap moves rigidly; a body lean used for an open cup
            # must not bend the separately seated tail plug a second time.
            after=before
            r=Matrix.Rotation(math.radians(rule.get('tailYaw',90)),4,'Z')
            delta=Vector(rule['tailBase'])-r@Vector((0,.185,.30))
        elif kind.startswith('foot'):
            sign=-1 if kind=='foot_l' else 1;index=0 if sign<0 else 1
            r=Matrix.Rotation(math.radians(rule['footYaw']),4,'Z')
            delta=Vector(rule['feet'][index])-r@Vector((sign*.054,0,0))
        else:r=rotation;delta=offset
        for v,p in zip(o.data.vertices,after):v.co=r@p+delta
        o.matrix_world=Matrix.Identity(4);o.parent=None;o.data.update()
        if id=='duck-steelcup' and kind=='foot_r':crop(o,(0,0,1),.09,False)
        set_colour(o,'orange' if kind.startswith('foot') or kind=='bill' else 'eye' if kind=='eye' else 'white')
        H.PARTS.append(o)
        if kind in ['bill','eye'] or head_indices:
            pool=head_indices or list(range(len(before)))
            ids=pool[::max(1,len(pool)//12)][:12]
            max_error=max(abs((before[a]-before[b]).length-(after[a]-after[b]).length) for a in ids for b in ids)
            identity.append({'part':'head-core' if head_indices else kind,'sampledVertices':len(ids),'maximumPairwiseDistanceChange':max_error})
            assert max_error<1e-5,identity
    bpy.data.objects.remove(rig,do_unlink=True)
    write(OUT/'qa'/f'{id}-mother-identity.json',{'source':str((MASTER/'source/duck-b2-master-rig.blend').relative_to(ROOT)),'sourceSha256':hashlib.sha256((MASTER/'source/duck-b2-master-rig.blend').read_bytes()).hexdigest(),'rule':rule,'neckCapCenter':list(cap_center),'rigidPlacement':{'rotation':list(map(list,rotation)),'translation':list(offset)},'headRegenerated':False,'uniformScaleBeforeFinalNormalization':1,'faceRigidShapeChecksBeforeAccessoryLod':identity,'exposedSkinFurtherDecimated':False,'hiddenTorsoRemoved':not rule.get('keepTorso',False),'singleContinuousTorsoKept':rule.get('keepTorso',False),'hiddenWingsRemoved':True,'tailCopiedFromMother':True,'artAccepted':False})

def pastry():
    # 16 soft lobes around a shallow fluted crust, not the prior polygonal bowl.
    centre=Vector((0,.02,.475));profile=[(.368,-.072),(.406,-.083),(.426,-.035),(.421,.046),(.397,.084),(.368,.048)]
    n=96 if DETAIL else 80;verts=[];faces=[]
    for r,y in profile:
        for j in range(n):
            a=math.tau*j/n;rr=r+.012*(r/.426)**4*math.cos(a*16)
            verts.append(centre+Vector((rr*math.cos(a),y,rr*math.sin(a))))
    for k in range(len(profile)):
        kk=(k+1)%len(profile)
        for j in range(n):faces.append((k*n+j,k*n+(j+1)%n,kk*n+(j+1)%n,kk*n+j))
    H.mesh('Shallow fluted pastry shell',verts,faces,'rim')
    H.ball('Custard surface',(0,.013,.475),(.383,.080,.383),'custard',48 if DETAIL else 36,8 if DETAIL else 6)
    H.ball('Golden pastry back',(0,.069,.475),(.378,.035,.378),'crust',32 if DETAIL else 24,6)

def cup():
    profile=[(.030,-.385),(.250,-.385),(.289,-.357),(.305,-.320),(.305,.245),(.320,.268),(.320,.292),(.304,.311),(.282,.305),(.273,.275),(.273,-.304),(.246,-.329),(.030,-.329)]
    sides=48 if DETAIL else 40
    o=H.revolution('Closed steel cup wall and rolled rim',profile,'metal',segments=sides)
    transform=Matrix(((0,0,1),(1,0,0),(0,1,0)))
    for v in o.data.vertices:v.co=transform@v.co+Vector((-.04,0,.36))
    o.data.update();o.data.materials.append(H.material('inside'))
    for f in o.data.polygons:
        if 9*sides<=f.index<12*sides:f.material_index=1
    path=H.curved_points([(-.32,0,.63),(-.30,0,.78),(-.17,0,.82),(.04,0,.80),(.14,0,.66)],4)
    H.tube('Rounded attached steel handle',path,[.036]*len(path),'metal-light',10 if DETAIL else 8)

def block():
    start=len(H.PARTS);c=Vector((-.08,0,.390));angle=math.radians(-10)
    H.box('Rounded red numeric toy',c,(.67,.40,.62),.045,'red')
    outline=[(-.10,.16),(-.015,.23),(.05,.23),(.05,-.155),(.14,-.155),(.14,-.215),(-.12,-.215),(-.12,-.155),(-.032,-.155),(-.032,.123),(-.085,.087)]
    verts=[(x+c.x,y,z+c.z) for y in [-.226,-.192] for x,z in outline];n=len(outline)
    faces=[tuple(reversed(range(n))),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    digit=H.mesh('Raised lime numeral one',verts,faces,'green')
    mod=digit.modifiers.new('Soft numeral edge','BEVEL');mod.width=.015;mod.segments=3;H.apply(digit,mod)
    mod=digit.modifiers.new('Broad numeral face','WEIGHTED_NORMAL');mod.keep_sharp=True;H.apply(digit,mod)
    for x in [-.15,.15]:
        for z in [-.14,.14]:H.ball('Back toy connector',(c.x+x,.218,c.z+z),(.070,.033,.070),'red',16,6)
    rot=Matrix.Rotation(angle,4,'Y')
    for obj in H.PARTS[start:]:
        matrix=obj.matrix_world.copy()
        for v in obj.data.vertices:v.co=rot@(matrix@v.co-c)+c
        obj.matrix_world=Matrix.Identity(4);obj.data.update()
    # Short ankle continuation seats the right foot into the tilted underside;
    # its webbed foot remains the unchanged mother component.
    H.tube('Seated right ankle continuation',[(.10,-.17,.08),(.10,-.17,.14)],[.012,.012],'orange',10)

def atlas(obj,folder,id):
    # A palette plus broad baked-custard variation and per-swatch metal/roughness.
    colours=list(PALETTE);base=bpy.data.images.new(id+'-albedo',width=256,height=256,alpha=False)
    orm=bpy.data.images.new(id+'-metalrough',width=256,height=256,alpha=False);orm.colorspace_settings.name='Non-Color'
    pixels=[];channels=[]
    for y in range(256):
        for x in range(256):
            idx=min(len(colours)-1,y//64*4+x//64);key=colours[idx];colour=PALETTE[key]
            if key=='custard':
                u=((x%64)-7)/50*2-1;v=((y%64)-7)/50*2-1
                d=0
                for cx,cy,rx,ry in [(-.42,.12,.31,.26),(.36,-.28,.28,.30),(-.08,-.59,.20,.14)]:d=max(d,.24*math.exp(-2*(((u-cx)/rx)**2+((v-cy)/ry)**2)))
                colour=tuple(a*(1-d)+b*d for a,b in zip(colour,(.87,.48,.12)))
            pixels.extend((*colour,1))
            metal=.7 if key in ['metal','metal-light','inside'] else 0
            rough=.31 if metal else .42 if key in ['orange','red','green'] else .25 if key=='eye' else .55
            channels.extend((1,rough,metal,1))
    for image,pix,name in [(base,pixels,'albedo.png'),(orm,channels,'metalrough.png')]:
        image.pixels[:]=pix;image.filepath_raw=str(folder/name);image.file_format='PNG';image.save();image.pack()
    for old in list(obj.data.uv_layers):obj.data.uv_layers.remove(old)
    uv=obj.data.uv_layers.new(name='UVMap')
    for face in obj.data.polygons:
        key=obj.data.materials[face.material_index].name.split('.')[0];idx=colours.index(key)
        for loop in face.loop_indices:
            if key=='custard':
                p=obj.data.vertices[obj.data.loops[loop].vertex_index].co
                coord=((idx%4*64+7+(p.x/.766+.5)*50)/256,(idx//4*64+7+((p.z-.475)/.766+.5)*50)/256)
            else:coord=((idx%4+.5)/4,(idx//4+.5)/4)
            uv.data[loop].uv=coord
    mat=bpy.data.materials.new(id+'-mobile');mat.use_nodes=True;n=mat.node_tree.nodes;l=mat.node_tree.links
    bs=next(x for x in n if x.type=='BSDF_PRINCIPLED');uvn=n.new('ShaderNodeUVMap');uvn.uv_map='UVMap'
    tex=n.new('ShaderNodeTexImage');tex.image=base;tex.interpolation='Linear';l.new(uvn.outputs['UV'],tex.inputs['Vector']);l.new(tex.outputs['Color'],bs.inputs['Base Color'])
    mr=n.new('ShaderNodeTexImage');mr.image=orm;mr.interpolation='Linear';sep=n.new('ShaderNodeSeparateColor');l.new(uvn.outputs['UV'],mr.inputs['Vector']);l.new(mr.outputs['Color'],sep.inputs['Color']);l.new(sep.outputs['Green'],bs.inputs['Roughness']);l.new(sep.outputs['Blue'],bs.inputs['Metallic'])
    obj.data.materials.clear();obj.data.materials.append(mat)
    for face in obj.data.polygons:face.material_index=0

def build(id):
    mother_parts(id)
    {'duck-eggtart':pastry,'duck-steelcup':cup,'duck-numberblock':block}[id]()
    write(OUT/'qa'/f'{id}-part-budgets.json',{'parts':[{'name':o.name,'triangles':H.tris(o)} for o in H.PARTS]})
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source'/f'{id}-authored.blend'))
    if not DETAIL:
        for obj in H.PARTS:
            name=obj.name
            ratio=.32 if name=='B2 mother bill' else .38 if 'mother foot' in name else .42 if 'mother eye' in name else .5 if name=='B2 mother tail' else None
            if ratio:
                mod=obj.modifiers.new('Accessory silhouette checked mobile LOD','DECIMATE');mod.ratio=ratio;H.apply(obj,mod)
        write(OUT/'qa'/f'{id}-part-budgets-mobile.json',{'parts':[{'name':o.name,'triangles':H.tris(o)} for o in H.PARTS],'headNeckSkinFurtherReduced':False,'accessoryReduction':{'bill':.32,'feet':.38,'eyes':.42,'tail':.5}})
    obj=H.join(H.PARTS,id);folder=OUT/'models'/id;folder.mkdir(parents=True,exist_ok=True)
    atlas(obj,folder,id)
    lo,hi=H.bounds([obj]);centre=(lo+hi)*.5;extent=max(hi-lo)
    for v in obj.data.vertices:v.co=(v.co-centre)/extent
    obj.data.update();obj.vertex_groups.clear()
    bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source'/f'{id}-static.blend'))
    bpy.ops.export_scene.gltf(filepath=str(folder/(id+'.glb')),export_format='GLB',use_selection=True,export_animations=False,export_extras=False)
    metrics={'id':id,'triangles':H.tris(obj),'dimensions':list((hi-lo)/extent),'sourceExtent':extent,'sourceCenter':list(centre),'materials':1,'atlas':[256,256],'glbBytes':(folder/(id+'.glb')).stat().st_size,'blender':bpy.app.version_string,'sameMotherBeforeNormalization':True,'preferredTriangleTargetMet':H.tris(obj)<=4000}
    write(OUT/'qa'/f'{id}-metrics.json',metrics)
    H.clear();bpy.ops.import_scene.gltf(filepath=str(folder/(id+'.glb')));report=H.audit_import(id)
    # FBX/Unity must use the same explicit triangles as the accepted GLB.
    # Exporting the pre-triangulated authoring n-gons separately let Unity
    # choose a different triangulation (8 triangles lost on the steel cup).
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.fbx(filepath=str(folder/(id+'.fbx')),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=False,path_mode='STRIP')
    print('B2_COMBINATION_BUILT',json.dumps({**metrics,'geometryPassed':report['passed']}),flush=True)
    assert report['passed'],report
    assert metrics['triangles']<=(6000 if DETAIL else 4000),metrics

def main():
    global OUT,DETAIL
    parser=argparse.ArgumentParser();parser.add_argument('--only',choices=IDS);parser.add_argument('--build-only',action='store_true');parser.add_argument('--render-only',action='store_true');parser.add_argument('--reference-only',action='store_true');parser.add_argument('--duck-only',action='store_true');parser.add_argument('--hulls-only',action='store_true');parser.add_argument('--preview',action='store_true');parser.add_argument('--detail-baseline',action='store_true');parser.add_argument('--identity-only',action='store_true')
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
    if args.detail_baseline:DETAIL=True;OUT=OUT/'quality-baseline';H.OUT=OUT
    for d in ['source','models','renders','qa']:(OUT/d).mkdir(parents=True,exist_ok=True)
    ids=[args.only] if args.only else IDS
    if args.identity_only:
        for id in ids:mother_parts(id)
        return
    if args.hulls_only:
        for id in ids:H.hull_proxy(id)
        return
    if not args.render_only:
        for id in ids:build(id)
    if not args.build_only:
        if args.preview:H.VIEWS={'hero':H.VIEWS['hero']}
        for id in ids:
            if not args.reference_only:H.render_one(id)
            if not args.duck_only:H.render_one(id,True)

if __name__=='__main__':main()
