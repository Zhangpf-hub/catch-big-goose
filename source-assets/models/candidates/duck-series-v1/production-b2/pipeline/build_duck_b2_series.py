"""Build the remaining 17 props around the approved, unscaled B2 anatomy.

Approved three are copied byte-for-byte. References are only read for comparisons.
"""
import argparse,hashlib,importlib.util,json,math,shutil,sys
from pathlib import Path
import bpy
from mathutils import Vector,Matrix
sys.path.insert(0,str(Path(__file__).parent))
from duck_series_catalog import ROOT,OUT,APPROVED,CATALOG,BY_ID,IDS,NEW_IDS,APPROVED_IDS
spec=importlib.util.spec_from_file_location('b2',Path(__file__).with_name('build_duck_b2_combinations.py'))
C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C);H=C.H
C.OUT=H.OUT=OUT
H.REFS={id:ROOT/BY_ID[id]['reference'] for id in IDS}
PALETTE=C.PALETTE.copy()
PALETTE.update(purple=(.40,.18,.62),leaf=(.24,.59,.14),leafdark=(.12,.36,.09),tan=(.78,.57,.34),
    brown=(.42,.25,.12),cream=(1,.90,.65),blue=(.18,.63,.90),pink=(.98,.43,.60),yellow=(1,.80,.10),seed=(.10,.065,.035))
C.PALETTE=H.PALETTE=PALETTE

def rule(root=(.12,-.02,.55),cut=.66,pose=(.18,.10,-.28),feet=((- .11,0,0),(.11,0,0)),tail=(0,.24,.30),**kw):
    return dict(neckCut=cut,neckPose=list(pose),yaw=0,lean=0,root=list(root),feet=list(feet),footYaw=0,tailBase=list(tail),tailYaw=0,**kw)
C.RULES.update({
 'duck-eggpancake':rule((.15,0,.55),tail=(.30,.01,.35)),
 'duck-milletcake':rule((.14,0,.60),cut=.70,tail=(.29,.02,.35)),
 'duck-steamedbread':rule((.13,-.01,.53),tail=(0,.22,.31)),
 'duck-eggplant':rule((.015,0,.54),cut=.68,tail=(0,.17,.28)),
 'duck-greenpepper':rule((.18,-.01,.48),cut=.68,tail=(0,.20,.28)),
 'duck-pancake':rule((.15,0,.43),cut=.64,tail=(0,.23,.26)),
 'duck-potato':rule((.13,-.01,.51),cut=.66,tail=(0,.21,.27)),
 'duck-tomato':rule((.14,0,.47),cut=.68,tail=(0,.23,.29)),
 'duck-farmer':rule((0,-.16,.28),cut=.57,pose=(.22,.10,-.32),feet=((- .12,-.08,.02),(.12,-.08,.02)),tail=(0,.27,.29)),
 'duck-watermelon':rule((.13,0,.37),cut=.66,tail=(0,.10,.25)),
 'duck-yoyo':rule((0,0,.39),cut=.55,tail=(-.24,0,.34)),
 'duck-craftpunch':rule((.12,.02,.44),cut=.64,tail=(0,.20,.24)),
 'duck-capsulepen':rule((-.05,0,.32),cut=.62,feet=((- .19,0,0),(.16,0,0)),tail=(-.34,0,.29)),
 'duck-chilisauce':rule((.16,-.03,.57),cut=.70,tail=(0,.25,.30)),
 'duck-colacup':rule((.13,-.06,.61),cut=.70,tail=(0,.24,.30)),
 'duck-egg':rule((.08,0,.47),cut=.64,tail=(0,.20,.26)),
 'duck-noodles':rule((.12,-.07,.61),cut=.70,tail=(0,.25,.31)),
})

def lathe(name,profile,key,center=(0,0,0),axis='Z',n=28):
    verts=[];faces=[]
    for r,z in profile:
        for j in range(n):
            a=math.tau*j/n;p=Vector((r*math.cos(a),r*math.sin(a),z))
            if axis=='Y':p=Vector((p.x,p.z,p.y))
            if axis=='X':p=Vector((p.z,p.x,p.y))
            verts.append(p+Vector(center))
    for k in range(len(profile)-1):
        for j in range(n):faces.append((k*n+j,k*n+(j+1)%n,(k+1)*n+(j+1)%n,(k+1)*n+j))
    faces+=[tuple(reversed(range(n))),tuple((len(profile)-1)*n+j for j in range(n))]
    return H.mesh(name,verts,faces,key)
def torus(name,loc,r,thick,key,axis='Z',n=32,s=6):
    profile=[(r+thick*math.cos(j*math.tau/s),thick*math.sin(j*math.tau/s)) for j in range(s)]
    o=H.revolution(name,profile,key,center=loc,axis=axis,segments=n);return o
def curve(name,points,r,key,s=6,steps=3):
    p=H.curved_points(points,steps);return H.tube(name,p,[r]*len(p),key,s)
def leafstar(name,center,r,key='leaf',n=5):
    verts=[]
    for z in [-.012,.012]:
        for i in range(n*2):
            a=math.pi/2+i*math.pi/n;rr=r if i%2==0 else r*.4
            verts.append(Vector(center)+Vector((rr*math.cos(a),rr*math.sin(a),z)))
    m=n*2;faces=[tuple(reversed(range(m))),tuple(range(m,m*2))]+[(i,(i+1)%m,(i+1)%m+m,i+m) for i in range(m)]
    return H.mesh(name,verts,faces,key)
def semidisk(name,r,z,depth,key,y=0,n=24):
    outline=[(r*math.cos(j*math.pi/n),r*math.sin(j*math.pi/n)+z) for j in range(n+1)]
    verts=[(x,y+d,zz) for d in [-depth/2,depth/2] for x,zz in outline];m=len(outline)
    faces=[tuple(reversed(range(m))),tuple(range(m,m*2))]+[(j,(j+1)%m,(j+1)%m+m,j+m) for j in range(m)]
    return H.mesh(name,verts,faces,key)
def eggpancake():
    H.ball('Folded golden egg pancake',(0,0,.36),(.36,.115,.27),'rim',32,10)
    curve('Folded crepe seam',[(-.29,-.067,.25),(0,-.12,.18),(.29,-.067,.25)],.014,'crust')
    H.ball('Cooked egg white',(-.04,-.111,.36),(.20,.025,.14),'cream',24,8)
    H.ball('Rounded egg yolk',(-.02,-.14,.37),(.079,.025,.078),'yellow',20,8)
    for x,z in [(-.22,.39),(.18,.31),(.10,.47)]:H.box('Scallion fleck',(x,-.115,z),(.04,.018,.025),.005,'leaf')
def milletcake():
    H.ball('Thick millet round',(0,0,.40),(.31,.15,.30),'toast',32,10)
    def front(x,z):return -.15*math.sqrt(max(.01,1-(x/.31)**2-((z-.40)/.30)**2))-.003
    for k in [-1,0,1]:
        x=k*.115;p=[(x,front(x,.20+j*.05),.20+j*.05) for j in range(9)];H.tube('Seated millet grid',p,[.009]*len(p),'crust',6)
    for z in [.28,.42,.54]:
        p=[(-.21+j*.0525,front(-.21+j*.0525,z),z) for j in range(9)];H.tube('Seated millet cross',p,[.009]*len(p),'crust',6)
    for x,z in [(-.16,.34),(.06,.34),(-.07,.49),(.17,.48),(.05,.58)]:H.ball('Millet seed',(x,front(x,z),z),(.025,.009,.013),'cream',8,4)
def steamedbread():
    o=H.ball('Pleated steamed bun',(0,0,.35),(.30,.24,.25),'white',32,12)
    for v in o.data.vertices:
        z=v.co.z;angle=math.atan2(v.co.y/.24,v.co.x/.30)
        amount=.025*math.cos(angle*8)*max(0,z/.25)
        v.co.x*=1+amount;v.co.y*=1+amount
    for j in range(8):
        a=j*math.tau/8
        curve('Soft bun fold',[(.04*math.cos(a),.032*math.sin(a),.60),(.13*math.cos(a),.10*math.sin(a),.568),(.21*math.cos(a),.17*math.sin(a),.50)],.009,'cream')
def eggplant():
    o=lathe('Long purple eggplant',[(.035,.11),(.15,.12),(.235,.23),(.22,.40),(.14,.55),(.065,.64),(.03,.65)],'purple',n=32)
    for v in o.data.vertices:v.co.x-=.07*math.sin((v.co.z-.11)/.54*math.pi)
    leafstar('Eggplant green calyx',(-.02,0,.62),.13)
    curve('Eggplant short bent stalk',[(-.02,0,.62),(-.04,0,.70),(-.10,.01,.72)],.032,'leaf',8)
def greenpepper():
    for x,y in [(-.105,-.035),(.105,-.035),(0,.10)]:H.ball('Pepper lobe',(x,y,.34),(.17,.19,.23),'leaf',24,10)
    leafstar('Pepper top calyx',(0,0,.54),.105,'leafdark')
    curve('Pepper bent stem',[(0,0,.54),(-.02,0,.64),(-.10,0,.65)],.032,'leafdark',8)
def pancake():
    for z in [.20,.31,.42]:H.ball('Layered pan cake',(0,0,z),(.33,.26,.085),'rim' if z==.42 else 'crust',28,8)
    for x,y in [(-.15,-.08),(.08,-.12),(.04,.14)]:H.ball('Toasted patch',(x,y,.498),(.07,.05,.008),'toast',12,4)
def potato():
    o=H.ball('Irregular potato',(0,0,.34),(.29,.23,.24),'tan',32,12)
    for v in o.data.vertices:
        f=1+.045*math.sin(v.co.z*26+v.co.x*8)*math.cos(v.co.y*15);v.co*=f
    for x,z in [(-.12,.43),(.09,.40),(-.08,.25),(.17,.29),(.01,.52)]:
        y=-.23*math.sqrt(max(.01,1-(x/.29)**2-((z-.34)/.24)**2))-.004
        H.ball('Potato eye',(x,y,z),(.022,.010,.015),'brown',10,4)
def tomato():
    o=H.ball('Ribbed red tomato',(0,0,.35),(.29,.26,.25),'red',36,12)
    for v in o.data.vertices:
        a=math.atan2(v.co.y,v.co.x);f=1+.035*math.cos(6*a);v.co.x*=f;v.co.y*=f
    leafstar('Tomato star calyx',(0,0,.585),.15,'leafdark',6)
    curve('Tomato stalk',[(0,0,.59),(0,.01,.65),(-.06,.03,.67)],.018,'leafdark',6)
def farmer():
    H.ball('Wide rounded straw brim',(0,0,.175),(.41,.34,.075),'rim',40,8)
    lathe('Domed straw crown',[(.26,.18),(.29,.23),(.28,.32),(.23,.42),(.14,.49),(.035,.51)],'toast',n=32)
    lathe('Dark woven hat band',[(.298,.225),(.297,.295)],'brown',n=32)
    for r,z in [(.29,.20),(.275,.335),(.225,.425)]:torus('Broad straw weave ring',(0,0,z),r,.008,'rim',n=32,s=4)
def watermelon():
    semidisk('Green watermelon rind',.36,.105,.23,'leafdark')
    semidisk('Pale rind inset',.333,.123,.025,'cream',-.116)
    semidisk('Red cut watermelon face',.31,.143,.025,'red',-.133)
    for r,n in [(.15,3),(.245,5)]:
        for j in range(n):
            a=math.pi*(j+1)/(n+1);x=r*math.cos(a);z=.143+r*math.sin(a)
            H.ball('Black watermelon seed',(x,-.153,z),(.012,.009,.026),'seed',8,4)
def yoyo():
    for y in [-.10,.10]:lathe('Blue yoyo half',[(.21,y-.06),(.275,y-.035),(.285,y+.015),(.25,y+.06)],'blue',center=(0,0,.39),axis='Y',n=32)
    lathe('Connected yellow axle',[(.08,-.09),(.08,.09)],'yellow',center=(0,0,.39),axis='Y',n=20)
    torus('Yellow front center ring',(0,-.17,.39),.13,.018,'yellow',axis='Y',n=28)
    H.ball('Front axle button',(0,-.175,.39),(.057,.014,.057),'white',16,6)
def craftpunch():
    H.box('Blue craft punch base',(0,0,.16),(.58,.40,.12),.035,'blue')
    H.box('Pink press lever',(0,.02,.395),(.49,.35,.18),.055,'pink')
    for x in [-.19,.19]:H.box('Hinge support',(x,.12,.28),(.075,.10,.18),.018,'metal')
    lathe('Actual punch shaft',[(.055,.20),(.055,.34)],'metal-light',n=20)
    H.ball('White flower center',(0,-.01,.49),(.044,.044,.012),'white',12,4)
    for j in range(5):
        a=j*math.tau/5;H.ball('Flower punch mark',(.07*math.cos(a),-.01+.07*math.sin(a),.49),(.034,.034,.012),'white',10,4)
def capsulepen():
    lathe('Blue capsule barrel',[(.07,-.34),(.12,-.29),(.125,.18),(.105,.24)],'blue',center=(0,0,.225),axis='X',n=28)
    lathe('Pink rounded pen cap',[(.04,-.44),(.105,-.41),(.126,-.34),(.126,-.18)],'pink',center=(0,0,.225),axis='X',n=28)
    lathe('White cap collar',[(.128,-.20),(.128,-.16)],'white',center=(0,0,.225),axis='X',n=28)
    lathe('Cream pen tip',[(.106,.23),(.065,.34),(.018,.44)],'cream',center=(0,0,.225),axis='X',n=28)
    lathe('Dark writing point',[(.02,.425),(.007,.46)],'seed',center=(0,0,.225),axis='X',n=12)
def chilisauce():
    lathe('Red chili jar',[(.18,.11),(.235,.14),(.25,.48),(.21,.55),(.19,.60)],'red-dark',n=32)
    lathe('Dark screw cap',[(.22,.56),(.235,.58),(.235,.64),(.21,.65)],'brown',n=32)
    lathe('Broad cream label',[(.246,.25),(.25,.43)],'cream',n=32)
    curve('Red chili pictogram',[(-.09,-.253,.39),(.02,-.261,.39),(.09,-.254,.32),(.04,-.252,.29)],.028,'red',8)
    curve('Chili green stem',[(-.09,-.253,.39),(-.11,-.25,.42)],.012,'leaf',6,1)
def colacup():
    lathe('Tapered red cola cup',[(.18,.11),(.20,.14),(.27,.60)],'red',n=32)
    lathe('Cream cola stripe',[(.230,.30),(.253,.45)],'white',n=32)
    lathe('White raised drink lid',[(.275,.595),(.29,.61),(.29,.64),(.26,.66)],'white',n=32)
    curve('Bent drinking straw',[(-.10,.06,.64),(-.10,.06,.82),(-.18,.06,.87)],.018,'cream',8)
def egg():
    n=32;verts=[];faces=[]
    for level in range(6):
        for j in range(n):
            a=j*math.tau/n
            r=[.07,.20,.255,.25,.225,.205][level]
            z=[.10,.15,.29,.40,.46,.45][level]
            if level>=4:z+=(.025 if j%2==0 else -.025)
            verts.append((r*math.cos(a),r*math.sin(a),z))
    for k in range(5):
        for j in range(n):faces.append((k*n+j,k*n+(j+1)%n,(k+1)*n+(j+1)%n,(k+1)*n+j))
    faces += [tuple(reversed(range(n))),tuple(5*n+j for j in range(n))]
    H.mesh('Cracked egg shell',verts,faces,'white')
    H.ball('Visible warm egg interior',(0,0,.445),(.205,.205,.047),'yellow',28,8)
def noodles():
    lathe('Red noodle paper cup',[(.20,.11),(.22,.14),(.30,.58),(.30,.62)],'red-dark',n=32)
    lathe('Cream noodle label',[(.252,.29),(.283,.46)],'cream',n=32)
    H.ball('Noodle bed',(0,0,.61),(.282,.282,.035),'cream',28,8)
    torus('Rolled noodle cup rim',(0,0,.62),.296,.018,'cream',n=32)
    for k in range(4):
        y=-.18+k*.11;points=[(-.20+.4*j/10,y+.035*math.sin(j*math.pi*.7+k),.645) for j in range(11)]
        H.tube('Curled noodle strand',points,[.017]*len(points),'rim',6)
    for x,y in [(-.10,-.05),(.14,.12)]:H.box('Green garnish',(x,y,.66),(.045,.04,.025),.006,'leaf')
    lid=H.ball('Peeled attached lid',(0,.21,.80),(.295,.025,.23),'red',28,8)
    lid.rotation_euler.x=math.radians(-30)
    for k in range(2):curve('Noodle label swirl',[(-.10,-.276,.40-k*.04),(0,-.282,.43-k*.04),(.10,-.276,.40-k*.04)],.012,'toast',6)
PROPS={k:globals()[k] for k in [r['key'] for r in CATALOG if r['id'] in NEW_IDS]}

def atlas(obj,folder,id):
    keys=list(PALETTE);grid=8;px=[];orm=[]
    for y in range(256):
        for x in range(256):
            key=keys[min(len(keys)-1,y//32*8+x//32)];px.extend((*PALETTE[key],1))
            metal=.7 if key in ['metal','metal-light','inside'] else 0;rough=.31 if metal else .24 if key=='eye' else .5
            orm.extend((1,rough,metal,1))
    imgs=[]
    for data,name,linear in [(px,'albedo.png',False),(orm,'metalrough.png',True)]:
        im=bpy.data.images.new(id+'-'+name,width=256,height=256,alpha=False)
        if linear:im.colorspace_settings.name='Non-Color'
        im.pixels[:]=data;im.filepath_raw=str(folder/name);im.file_format='PNG';im.save();im.pack();imgs.append(im)
    for uv in list(obj.data.uv_layers):obj.data.uv_layers.remove(uv)
    uv=obj.data.uv_layers.new(name='UVMap')
    for f in obj.data.polygons:
        key=obj.data.materials[f.material_index].name.split('.')[0];idx=keys.index(key)
        for loop in f.loop_indices:uv.data[loop].uv=((idx%grid+.5)/grid,(idx//grid+.5)/grid)
    mat=bpy.data.materials.new(id+'-mobile');mat.use_nodes=True;n=mat.node_tree.nodes;l=mat.node_tree.links
    bs=next(node for node in n if node.type=='BSDF_PRINCIPLED');uvn=n.new('ShaderNodeUVMap');uvn.uv_map='UVMap'
    for im,socket in [(imgs[0],'Base Color'),(imgs[1],None)]:
        tex=n.new('ShaderNodeTexImage');tex.image=im;l.new(uvn.outputs['UV'],tex.inputs['Vector'])
        if socket:l.new(tex.outputs['Color'],bs.inputs[socket])
        else:
            sep=n.new('ShaderNodeSeparateColor');l.new(tex.outputs['Color'],sep.inputs['Color']);l.new(sep.outputs['Green'],bs.inputs['Roughness']);l.new(sep.outputs['Blue'],bs.inputs['Metallic'])
    obj.data.materials.clear();obj.data.materials.append(mat)
    for f in obj.data.polygons:f.material_index=0

def stage_approved():
    for id in APPROVED_IDS:
        for sub in ['models','renders']:shutil.copytree(APPROVED/sub/id,OUT/sub/id,dirs_exist_ok=True)
        for sub in ['source','qa']:
            for p in (APPROVED/sub).glob(id+'*'):
                if p.is_file():shutil.copy2(p,OUT/sub/p.name)
def build(id):
    C.mother_parts(id);PROPS[BY_ID[id]['key']]()
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source'/(id+'-authored.blend')))
    for o in H.PARTS:
        name=o.name;ratio=.32 if name=='B2 mother bill' else .38 if 'mother foot' in name else .42 if 'mother eye' in name else .5 if name=='B2 mother tail' else None
        if ratio:
            mod=o.modifiers.new('Same accepted accessory LOD','DECIMATE');mod.ratio=ratio;H.apply(o,mod)
    anatomy=sum(H.tris(o) for o in H.PARTS if o.name.startswith('B2 mother'))
    props=[o for o in H.PARTS if not o.name.startswith('B2 mother')];propTriangles=sum(H.tris(o) for o in props)
    reduction=1
    if anatomy+propTriangles>4000:
        reduction=max(.25,(3900-anatomy)/propTriangles)
        for o in props:
            if H.tris(o)>80:
                mod=o.modifiers.new('Prop budget reduction','DECIMATE');mod.ratio=reduction;H.apply(o,mod)
    H.write(OUT/'qa'/(id+'-part-budgets.json'),{'anatomyTriangles':anatomy,'propRatio':reduction,'headNeckReduced':False,'parts':[{'name':o.name,'triangles':H.tris(o)} for o in H.PARTS]})
    obj=H.join(H.PARTS,id);folder=OUT/'models'/id;folder.mkdir(parents=True,exist_ok=True);atlas(obj,folder,id)
    lo,hi=H.bounds([obj]);center=(lo+hi)*.5;extent=max(hi-lo)
    for v in obj.data.vertices:v.co=(v.co-center)/extent
    obj.data.update();obj.vertex_groups.clear();bpy.context.view_layer.objects.active=obj
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source'/(id+'-static.blend')))
    dest=folder/(id+'.glb');bpy.ops.export_scene.gltf(filepath=str(dest),export_format='GLB',use_selection=True,export_animations=False,export_extras=False)
    metric={'id':id,'triangles':H.tris(obj),'dimensions':list((hi-lo)/extent),'sourceCenter':list(center),'sourceExtent':extent,'materials':1,'atlas':[256,256],'glbBytes':dest.stat().st_size,'blender':bpy.app.version_string,'sameMotherBeforeNormalization':True}
    H.write(OUT/'qa'/(id+'-metrics.json'),metric)
    H.clear();bpy.ops.import_scene.gltf(filepath=str(dest));geometry=H.audit_import(id)
    bpy.ops.object.select_all(action='SELECT');bpy.ops.export_scene.fbx(filepath=str(folder/(id+'.fbx')),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=False,path_mode='STRIP')
    assert geometry['passed'],geometry
    assert metric['triangles']<=6000,metric
    H.hull_proxy(id);print('B2_SERIES_BUILT',json.dumps(metric),flush=True)
def main():
    p=argparse.ArgumentParser();p.add_argument('--only',choices=IDS);p.add_argument('--build-only',action='store_true');p.add_argument('--render-only',action='store_true');p.add_argument('--preview',action='store_true');p.add_argument('--references',action='store_true')
    a=p.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
    for d in ['models','source','qa','renders','concepts']:(OUT/d).mkdir(parents=True,exist_ok=True)
    H.write(OUT/'design-spec.json',{'version':'b2-production','approval':'B2 三款通过，继续完整计划','models':CATALOG})
    if not a.render_only:
        stage_approved()
        for id in ([a.only] if a.only else NEW_IDS):
            if id in NEW_IDS:build(id)
    if not a.build_only:
        if a.preview:H.VIEWS={'hero':H.VIEWS['hero']}
        for id in ([a.only] if a.only else NEW_IDS):
            H.render_one(id,False)
            if a.references:H.render_one(id,True)
if __name__=='__main__':main()
