"""Author three original duck-B collectibles and render GLB round-trip comparisons.

Run with Blender 4.5 --background --factory-startup --python-exit-code 1
--python tools/mascots/build_duck_representatives.py -- [--build-only|--render-only]
All reference inputs are read-only. No Unity runtime assets are staged here.
"""
import argparse
import hashlib
import json
import math
import sys
from pathlib import Path

import bpy
import bmesh
from mathutils import Vector, Matrix

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'source-assets/models/candidates/duck-series-v1/model-review-v1'
IDS = ['duck-eggtart', 'duck-steelcup', 'duck-numberblock']
REFS = {
    'duck-eggtart': ROOT/'reference-projects/competitor-goose/2026-10-25-complete-skinned/models/Goose_EggTart/Goose_EggTart.glb',
    'duck-steelcup': ROOT/'reference-projects/competitor-goose/2026-10-25-complete-skinned/models/Goose_SteelCup/Goose_SteelCup.glb',
    'duck-numberblock': ROOT/'reference-projects/competitor-goose/2026-10-23-skinned/models/Goose_GTNumberBlock/Goose_GTNumberBlock.glb',
}
PALETTE = {
    'white': (.965, .955, .92), 'orange': (1.0, .47, .075),
    'eye': (.028, .032, .035), 'bill-line': (.72, .29, .035),
    'crust': (.85, .47, .14), 'rim': (.97, .66, .26),
    'custard': (1.0, .79, .23), 'toast': (.94, .65, .15),
    'metal': (.67, .72, .76), 'metal-light': (.79, .83, .85),
    'inside': (.36, .41, .44), 'red': (.96, .25, .20),
    'green': (.59, .87, .16), 'red-dark': (.80, .15, .12),
}
PARTS = []
MATS = {}


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n', 'utf-8')


def linear(v):
    return v/12.92 if v <= .04045 else ((v+.055)/1.055)**2.4


def clear():
    global PARTS, MATS
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version = 0
    PARTS, MATS = [], {}


def material(key):
    if key in MATS:
        return MATS[key]
    mat = bpy.data.materials.new(key)
    mat.use_nodes = True
    bs = next(n for n in mat.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    bs.inputs['Base Color'].default_value = tuple(linear(v) for v in PALETTE[key])+(1,)
    bs.inputs['Roughness'].default_value = .55
    mat.diffuse_color = (*PALETTE[key], 1)
    MATS[key] = mat
    return mat


def finish(obj, name, colour, smooth=True):
    obj.name = name
    obj.data.materials.append(material(colour))
    for face in obj.data.polygons:
        face.use_smooth = smooth
    PARTS.append(obj)
    return obj


def mesh(name, verts, faces, colour, smooth=True):
    data = bpy.data.meshes.new(name)
    data.from_pydata(verts, [], faces)
    data.update()
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    bm = bmesh.new(); bm.from_mesh(data)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(data); bm.free()
    return finish(obj, name, colour, smooth)


def ball(name, loc, scale, colour, segments=20, rings=12):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=loc)
    obj = bpy.context.object; obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish(obj, name, colour)


def apply(obj, mod):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=mod.name)


def tris(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def join(objects, name):
    bpy.ops.object.select_all(action='DESELECT')
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.join()
    obj = bpy.context.object; obj.name = name
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return obj


def tube(name, points, radii, colour, sides=12, cap=True):
    verts, faces = [], []
    old_u = None
    for i, (point, radius) in enumerate(zip(points, radii)):
        p = Vector(point)
        tangent = Vector(points[min(i+1, len(points)-1)])-Vector(points[max(0, i-1)])
        tangent.normalize()
        u = old_u-tangent*old_u.dot(tangent) if old_u is not None else tangent.cross(Vector((1, 0, 0)))
        if u.length < .1:
            u = tangent.cross(Vector((0, 1, 0)))
        u.normalize(); v = tangent.cross(u).normalized(); old_u = u
        for j in range(sides):
            verts.append(p+radius*(math.cos(j*math.tau/sides)*u+math.sin(j*math.tau/sides)*v))
    for i in range(len(points)-1):
        for j in range(sides):
            a=i*sides+j; b=i*sides+(j+1)%sides
            faces.append((a,b,b+sides,a+sides))
    if cap:
        faces += [tuple(reversed(range(sides))), tuple((len(points)-1)*sides+j for j in range(sides))]
    return mesh(name, verts, faces, colour)


def curved_points(points, steps=4):
    result=[]
    for i in range(len(points)-1):
        a,b,c,d=[Vector(points[max(0,min(len(points)-1,j))]) for j in [i-1,i,i+1,i+2]]
        for k in range(steps):
            t=k/steps
            result.append(.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t))
    result.append(Vector(points[-1]))
    return result


def box(name, loc, size, bevel, colour):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj=bpy.context.object; obj.scale=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    mod=obj.modifiers.new('Rounded toy edges','BEVEL');mod.width=bevel;mod.segments=3
    apply(obj,mod)
    finish(obj,name,colour)
    mod=obj.modifiers.new('Broad flat toy faces','WEIGHTED_NORMAL');mod.keep_sharp=True
    apply(obj,mod)
    return obj


def webbed_foot(x, y, z, scale=1):
    # One closed broad webbed silhouette, with rounded large toe lobes.
    outline=[(-.055,.045),(.055,.045),(.070,-.010),(.092,-.095),(.085,-.135),(.045,-.144),(.006,-.131),(-.036,-.146),(-.080,-.134),(-.088,-.102),(-.068,-.025)]
    verts=[(x+a*scale,y+b*scale,z+dz*scale) for dz in [0,.043] for a,b in outline]
    n=len(outline);faces=[tuple(reversed(range(n))),tuple(range(n,n*2))]
    faces += [(j,(j+1)%n,(j+1)%n+n,j+n) for j in range(n)]
    obj=mesh('Orange webbed foot',verts,faces,'orange')
    mod=obj.modifiers.new('Soft webbed toe edges','BEVEL');mod.width=.014*scale;mod.segments=2
    apply(obj,mod)
    ball('Short ankle',(x,y+.012*scale,z+.070*scale),(.040*scale,.045*scale,.074*scale),'orange',10,6)
    return obj


def bill(head, yaw=0, scale=1):
    """Closed broad spatulate bill, horizontal seam separate from orange mass."""
    h=Vector(head)
    rot=Matrix.Rotation(yaw,4,'Z')
    def world(p):return h+rot@Vector(p)*scale
    # Rings run from embedded base to broad rounded tip; elliptical cross-section.
    levels=[(-.085,.083,.034,.004),(-.145,.109,.031,-.004),(-.225,.118,.028,-.014),(-.275,.100,.024,-.014),(-.298,.058,.018,-.011),(-.304,.006,.006,-.011)]
    verts=[];faces=[];n=16
    for y,rx,rz,dz in levels:
        for j in range(n):
            a=j*math.tau/n
            verts.append(world((rx*math.cos(a),y,-.046+dz+rz*math.sin(a))))
    faces.append(tuple(reversed(range(n))))
    for i in range(len(levels)-1):
        for j in range(n):faces.append((i*n+j,i*n+(j+1)%n,(i+1)*n+(j+1)%n,(i+1)*n+j))
    faces.append(tuple((len(levels)-1)*n+j for j in range(n)))
    mesh('Broad flat duck bill',verts,faces,'orange')
    line=[world((x,-.272+.07*(abs(x)/.09)**2,-.067)) for x in [-.087,-.060,-.030,0,.030,.060,.087]]
    tube('Subtle closed bill seam',line,[.0028*scale]*len(line),'bill-line',6)


def bird(head, neck, body_center, body_scale, yaw=0, neck_radius=.075, target=1250):
    """Shared B head and continuous neck/body; all three variants call this."""
    global PARTS
    start=len(PARTS)
    ball('Concealed slender torso',body_center,body_scale,'white',24,16)
    pts=curved_points(neck,4)
    radii=[neck_radius*(1.15-.15*i/(len(pts)-1)) for i in range(len(pts))]
    tube('Medium slender neck',pts,radii,'white',16)
    h=Vector(head)
    ball('Small duck B head',h,(.133,.128,.155),'white',24,16)
    skin_parts=PARTS[start:]
    obj=join(skin_parts,'Continuous duck B skin')
    PARTS=PARTS[:start]+[obj]
    mod=obj.modifiers.new('Continuous head neck torso','REMESH');mod.mode='VOXEL';mod.voxel_size=.007
    mod.use_smooth_shade=True;apply(obj,mod)
    mod=obj.modifiers.new('Soft neck transitions','SMOOTH');mod.factor=.75;mod.iterations=7;apply(obj,mod)
    mod=obj.modifiers.new('Skin mobile budget','DECIMATE');mod.ratio=min(1,target/tris(obj));apply(obj,mod)
    for face in obj.data.polygons:face.use_smooth=True
    rot=Matrix.Rotation(yaw,4,'Z')
    for sign in [-1,1]:
        eye=h+rot@Vector((sign*.106,-.078,.034))
        ball('Black bead eye',eye,(.017,.017,.020),'eye',10,6)
    bill(head,yaw)
    return obj


def tail(loc, scale=(.055,.105,.082)):
    obj=ball('Short tapered white tail',loc,scale,'white',10,6)
    obj.rotation_euler.x=math.radians(-25)
    return obj


def revolution(name, profile, colour, center=(0,0,0), axis='Z', segments=48, scallop=0):
    # Closed cross-section; no zero-radius repeated pole rings.
    verts=[];faces=[]
    for r,h in profile:
        for i in range(segments):
            a=i*math.tau/segments
            rr=r+scallop*math.cos(a*16)
            if axis=='Y':p=(rr*math.cos(a),h,rr*math.sin(a))
            else:p=(rr*math.cos(a),rr*math.sin(a),h)
            verts.append(tuple(Vector(p)+Vector(center)))
    for k in range(len(profile)):
        kk=(k+1)%len(profile)
        for i in range(segments):faces.append((k*segments+i,k*segments+(i+1)%segments,kk*segments+(i+1)%segments,kk*segments+i))
    return mesh(name,verts,faces,colour)


def make_eggtart():
    # Disc front is -Y. Its shallow profile has a central fill, an actual raised rim,
    # and a white torso behind; the neck passes through the front custard surface.
    c=(0,.025,.57)
    revolution('Scalloped golden pastry rim',[(.397,-.090),(.470,-.065),(.479,-.006),(.467,.066),(.430,.091),(.395,.058)],'rim',c,'Y',48,.009)
    ball('Custard-filled shallow tart',(0,.010,.57),(.431,.072,.431),'custard',32,9)
    ball('Golden back of pastry',(0,.070,.57),(.430,.044,.430),'crust',24,8)
    # Custard toast is surface colour in the atlas, never raised cookie chips.
    h=(.090,-.20,1.055)
    bird(h,[(.08,.025,.67),(.105,-.08,.77),(.10,-.20,.87),(.09,-.20,1.025)],(.015,.055,.57),(.110,.045,.270),neck_radius=.074,target=1000)
    for x in [-.155,.155]:webbed_foot(x,.012,.006,.95)
    tail((.31,.105,.49),(.065,.13,.08))


def make_steelcup():
    # Axis +X, mouth at +X. Closed profile includes outer wall, rounded rim,
    # inner wall, back wall and a small fitted tail opening at the rear.
    center=(-.12,0,.40)
    profile=[(.075,-.36),(.255,-.36),(.290,-.33),(.302,-.29),(.302,.26),(.316,.29),(.318,.315),(.302,.336),(.282,.333),(.271,.305),(.268,-.285),(.244,-.310),(.075,-.310)]
    o=revolution('Thick walled sideways steel cup',profile,'metal',segments=40)
    # Revolution creates axis Z; map (x,y,z)->(z,x,y), then lift.
    transform=Matrix(((0,0,1),(1,0,0),(0,1,0)))
    for v in o.data.vertices:v.co=transform@v.co+Vector(center)
    o.data.update()
    # Mark inside wall dark grey while keeping one final palette material.
    o.data.materials.append(material('inside'))
    for f in o.data.polygons:
        if 9*40 <= f.index < 12*40:f.material_index=1
    handle=curved_points([(-.35,.03,.62),(-.36,.03,.80),(-.22,.03,.86),(.03,.03,.84),(.10,.03,.66)],4)
    tube('Attached steel cup handle',handle,[.039]*len(handle),'metal-light',8)
    h=(.49,-.025,.83)
    bird(h,[(.00,0,.40),(.23,0,.42),(.38,-.015,.57),(.49,-.025,.72),(.49,-.025,.80)],(-.10,0,.40),(.230,.128,.135),yaw=math.radians(-25),neck_radius=.075,target=1150)
    for x in [-.27,.12]:webbed_foot(x,-.038,.006,.86)
    tail((-.48,.01,.40),(.115,.070,.065))


def make_numberblock():
    shell=box('Coral red rounded block',(-.08,0,.42),(.67,.40,.60),.053,'red')
    # Dedicated collar is seated on the side face; the white neck enters it.
    collar=ball('Rounded red neck fitting',(.265,-.005,.53),(.035,.105,.115),'red-dark',16,10)
    h=(.47,-.025,.93)
    bird(h,[(.03,0,.43),(.25,-.005,.50),(.38,-.018,.63),(.47,-.025,.80),(.47,-.025,.90)],(-.08,0,.43),(.225,.14,.21),yaw=math.radians(-15),neck_radius=.073,target=1300)
    for x in [-.25,.115]:webbed_foot(x,-.035,.006,.95)
    tail((-.44,.025,.50),(.105,.068,.070))
    # An authored polygonal numeral avoids font dependencies and is a closed mesh.
    outline=[(-.115,.575),(-.020,.660),(.047,.660),(.047,.295),(.140,.295),(.140,.230),(-.120,.230),(-.120,.295),(-.033,.295),(-.033,.548),(-.090,.510)]
    verts=[(x-.08,y,z) for y in [-.224,-.200] for x,z in outline]
    n=len(outline);faces=[tuple(reversed(range(n))),tuple(range(n,2*n))]
    faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    digit=mesh('Raised green numeral 1',verts,faces,'green')
    mod=digit.modifiers.new('Rounded readable numeral','BEVEL');mod.width=.012;mod.segments=2
    apply(digit,mod)
    mod=digit.modifiers.new('Flat numeral face','WEIGHTED_NORMAL');mod.keep_sharp=True;apply(digit,mod)


def atlas(obj, folder, id):
    # One 256px palette atlas; every original part points to a padded colour cell.
    # No diffuse-light baking, no hidden shading in the base colour.
    colours=list(PALETTE)
    image=bpy.data.images.new(id+'-palette',width=256,height=256,alpha=False)
    pixels=[]
    for y in range(256):
        for x in range(256):
            k=min(len(colours)-1,(y//64)*4+x//64)
            # Generated image pixels are stored directly into the PNG's sRGB
            # channels. The image texture supplies the sRGB->linear conversion.
            colour=PALETTE[colours[k]]
            if colours[k]=='custard':
                u=((x%64)-8)/48*2-1;v=((y%64)-8)/48*2-1
                amount=0
                for cx,cy,rx,ry in [(-.40,.12,.24,.31),(.35,-.30,.21,.23),(-.08,-.52,.19,.14)]:
                    amount=max(amount,.70*math.exp(-2*(((u-cx)/rx)**2+((v-cy)/ry)**2)))
                colour=tuple(a*(1-amount)+b*amount for a,b in zip(colour,PALETTE['toast']))
            pixels.extend((*colour,1))
    image.pixels[:]=pixels
    image.filepath_raw=str(folder/'albedo.png');image.file_format='PNG';image.save();image.pack()
    for old_uv in list(obj.data.uv_layers):
        obj.data.uv_layers.remove(old_uv)
    uv=obj.data.uv_layers.new(name='UVMap')
    for face in obj.data.polygons:
        name=obj.data.materials[face.material_index].name.split('.')[0]
        idx=colours.index(name)
        coord=((idx%4+.5)/4,(idx//4+.5)/4)
        for loop in face.loop_indices:
            if name=='custard':
                p=obj.data.vertices[obj.data.loops[loop].vertex_index].co
                uv.data[loop].uv=((idx%4*64+8+(p.x/.862+.5)*48)/256,(idx//4*64+8+((p.z-.57)/.862+.5)*48)/256)
            else:uv.data[loop].uv=coord
    mat=bpy.data.materials.new(id+'-mobile');mat.use_nodes=True
    bs=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    bs.inputs['Metallic'].default_value=0;bs.inputs['Roughness'].default_value=.53
    tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=image;tex.interpolation='Linear'
    coord=mat.node_tree.nodes.new('ShaderNodeUVMap');coord.uv_map='UVMap'
    mat.node_tree.links.new(coord.outputs['UV'],tex.inputs['Vector'])
    mat.node_tree.links.new(tex.outputs['Color'],bs.inputs['Base Color'])
    obj.data.materials.clear();obj.data.materials.append(mat)
    for face in obj.data.polygons:face.material_index=0


def bounds(objects):
    bpy.context.view_layer.update()
    points=[o.matrix_world@v.co for o in objects for v in o.data.vertices]
    lo=Vector([min(p[i] for p in points) for i in range(3)])
    hi=Vector([max(p[i] for p in points) for i in range(3)])
    return lo,hi


def audit_import(id):
    meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
    bad_edges=degenerate=0
    for o in meshes:
        bm=bmesh.new();bm.from_mesh(o.data)
        bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=1e-6)
        bad_edges+=sum(not e.is_manifold for e in bm.edges)
        degenerate+=sum(f.calc_area()<1e-12 for f in bm.faces)
        bm.free()
    lo,hi=bounds(meshes)
    report=dict(id=id,triangles=sum(tris(o) for o in meshes),meshObjects=len(meshes),nonManifoldEdges=bad_edges,degenerateFaces=degenerate,dimensions=list(hi-lo),center=list((hi+lo)*.5))
    report['passed']=bad_edges==0 and degenerate==0 and abs(max(hi-lo)-1)<1e-4 and ((hi+lo)*.5).length<1e-4
    write(OUT/'qa'/f'{id}-geometry.json',report)
    return report


def hull_proxy(id):
    clear()
    source=OUT/'models'/id/f'{id}.glb'
    bpy.ops.import_scene.gltf(filepath=str(source))
    objects=[o for o in bpy.context.scene.objects if o.type=='MESH']
    points=[o.matrix_world@v.co for o in objects for v in o.data.vertices]
    supports=[]
    for a in range(12):
        for b in range(7):
            az=a*math.pi/6;el=-math.pi/2+b*math.pi/6
            direction=Vector((math.cos(el)*math.cos(az),math.cos(el)*math.sin(az),math.sin(el)))
            p=max(points,key=lambda v:v.dot(direction))
            if not any((p-q).length<1e-6 for q in supports):supports.append(p.copy())
    bm=bmesh.new()
    verts=[bm.verts.new(p) for p in supports]
    bmesh.ops.convex_hull(bm,input=verts,use_existing_faces=False)
    bmesh.ops.triangulate(bm,faces=list(bm.faces))
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.verts.ensure_lookup_table();bm.verts.index_update()
    nonmanifold=sum(not e.is_manifold for e in bm.edges)
    vertices=[list(v.co) for v in bm.verts];faces=[[v.index for v in f.verts] for f in bm.faces]
    path=OUT/'models'/id/'convex-hull.obj'
    content='# Offline convex support hull; Blender Z-up; not PhysX acceptance\n'
    content+=''.join('v '+' '.join(f'{x:.8f}' for x in v)+'\n' for v in vertices)
    content+=''.join('f '+' '.join(str(i+1) for i in f)+'\n' for f in faces)
    path.write_text(content,'utf-8')
    report=dict(id=id,sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(),supportPoints=len(supports),vertices=vertices,faces=faces,triangles=len(faces),nonManifoldEdges=nonmanifold,convexVolume=bm.calc_volume(signed=False),offlineGeometryPassed=nonmanifold==0 and len(faces)<255,physicsRuntimeVerified=False,note='Offline 12x7 directional convex proxy only; not Unity/PhysX cooking, drop, sleep, raycast or match acceptance. OBJ basis Blender Z-up.')
    bm.free();write(OUT/'qa'/f'{id}-collision.json',report)
    assert report['offlineGeometryPassed'],report
    print('DUCK_OFFLINE_HULL',id,len(supports),len(faces),flush=True)


def build(id):
    clear()
    {'duck-eggtart':make_eggtart,'duck-steelcup':make_steelcup,'duck-numberblock':make_numberblock}[id]()
    folder=OUT/'models'/id;folder.mkdir(parents=True,exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source'/f'{id}-authored.blend'))
    obj=join(PARTS,id)
    # Triangulate before export and only decimate if the actual chosen budget needs it.
    if tris(obj)>5900:
        mod=obj.modifiers.new('Final mobile cap','DECIMATE');mod.ratio=5900/tris(obj);apply(obj,mod)
    atlas(obj,folder,id)
    lo,hi=bounds([obj]);center=(lo+hi)*.5;extent=max(hi-lo)
    for v in obj.data.vertices:v.co=(v.co-center)/extent
    obj.data.update()
    bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source'/f'{id}-static.blend'))
    bpy.ops.export_scene.gltf(filepath=str(folder/f'{id}.glb'),export_format='GLB',use_selection=True,export_yup=True,export_animations=False,export_extras=False,export_cameras=False,export_lights=False)
    bpy.ops.export_scene.fbx(filepath=str(folder/f'{id}.fbx'),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=False,path_mode='STRIP')
    write(folder/'materials.json',dict(materials=[dict(name=id+'-mobile',texture='albedo.png',metallic=0,roughness=.53)]))
    metrics=dict(id=id,triangles=tris(obj),dimensions=list((hi-lo)/extent),sourceExtent=extent,sourceCenter=list(center),materials=1,atlas=[256,256],glbBytes=(folder/f'{id}.glb').stat().st_size,blender=bpy.app.version_string)
    write(OUT/'qa'/f'{id}-metrics.json',metrics)
    clear();bpy.ops.import_scene.gltf(filepath=str(folder/f'{id}.glb'))
    report=audit_import(id)
    print('DUCK_BUILT',json.dumps({**metrics,'geometryPassed':report['passed']}),flush=True)
    assert report['passed'],report


def aim(obj,at=(0,0,0)):
    obj.rotation_euler=(Vector(at)-obj.location).to_track_quat('-Z','Y').to_euler()


def studio():
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=16;scene.cycles.use_denoising=True
    scene.render.threads_mode='FIXED';scene.render.threads=10
    scene.view_settings.view_transform='AgX';scene.view_settings.look='AgX - Medium High Contrast'
    scene.world=bpy.data.worlds.new('Identical neutral studio');scene.world.use_nodes=True
    bg=next(n for n in scene.world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs[0].default_value=(.72,.76,.80,1);bg.inputs[1].default_value=.45
    for name,loc,power,size in [('Key',(-2,-3,4),180,4),('Fill',(3,-1,2),95,3),('Rim',(0,3,3),120,3)]:
        d=bpy.data.lights.new(name,'AREA');d.energy=power;d.shape='DISK';d.size=size
        o=bpy.data.objects.new(name,d);scene.collection.objects.link(o);o.location=loc;aim(o)
    d=bpy.data.cameras.new('Fixed comparison camera');o=bpy.data.objects.new('Fixed comparison camera',d);scene.collection.objects.link(o);scene.camera=o
    d.type='ORTHO';d.ortho_scale=1.48;d.lens=50
    scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA';scene.render.film_transparent=True
    scene.render.resolution_percentage=100
    return scene,o


VIEWS={'front':(0,-3,.015),'side':(3,0,.015),'back':(0,3,.015),'hero':(2.2,-3,1.5),'gameplay':(1.4,-2.3,3.3)}


def render_one(id,reference=False):
    clear()
    source=REFS[id] if reference else OUT/'models'/id/f'{id}.glb'
    before_hash=hashlib.sha256(source.read_bytes()).hexdigest()
    bpy.ops.import_scene.gltf(filepath=str(source))
    objects=[o for o in bpy.context.scene.objects if o.type=='MESH']
    lo,hi=bounds(objects);center=(lo+hi)*.5;extent=max(hi-lo)
    # Bake transformed coordinates into new in-memory mesh copies only.
    for o in objects:
        matrix=o.matrix_world.copy();data=o.data.copy();o.data=data
        for v in data.vertices:v.co=(matrix@v.co-center)/extent
        o.parent=None;o.matrix_world=Matrix.Identity(4);data.update()
    normalized_lo,normalized_hi=bounds(objects)
    label='reference' if reference else 'duck'
    target=OUT/'renders'/id/label;target.mkdir(parents=True,exist_ok=True)
    scene,cam=studio()
    for view,loc in VIEWS.items():
        cam.location=loc;aim(cam)
        scene.render.resolution_x=scene.render.resolution_y=640 if view in ['hero','gameplay'] else 512
        scene.render.filepath=str(target/f'{view}.png');bpy.ops.render.render(write_still=True)
    cam.location=VIEWS['hero'];aim(cam)
    for pixels in [192,64]:
        scene.render.resolution_x=scene.render.resolution_y=pixels;scene.render.filepath=str(target/f'icon-{pixels}.png')
        bpy.ops.render.render(write_still=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source'/f'{id}-{label}-review.blend'))
    assert hashlib.sha256(source.read_bytes()).hexdigest()==before_hash
    record=dict(id=id,kind=label,input=str(source.relative_to(ROOT)).replace('\\','/'),sourceSha256=before_hash,originalWorldDimensions=list(hi-lo),uniformScale=1/extent,normalizedWorldDimensions=list(normalized_hi-normalized_lo),normalizedCenter=list((normalized_hi+normalized_lo)*.5),orthographicScale=1.48,cameras=VIEWS,lighting='Identical neutral studio; Key180 Fill95 Rim120 world0.45',shader='Recovered base-colour/PBR approximation' if reference else 'Original 256px palette PBR',sourceUnchanged=True)
    write(OUT/'qa'/f'{id}-{label}-comparison.json',record)
    print('DUCK_RENDERED',id,label,flush=True)


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--build-only',action='store_true');parser.add_argument('--render-only',action='store_true');parser.add_argument('--only',choices=IDS);parser.add_argument('--reference-only',action='store_true');parser.add_argument('--duck-only',action='store_true');parser.add_argument('--hulls-only',action='store_true')
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
    for folder in ['source','models','renders','qa']:(OUT/folder).mkdir(parents=True,exist_ok=True)
    chosen=[args.only] if args.only else IDS
    if args.hulls_only:
        for id in chosen:hull_proxy(id)
        return
    if not args.render_only:
        for id in chosen:build(id)
    if not args.build_only:
        for id in chosen:
            if not args.reference_only:render_one(id)
            if not args.duck_only:render_one(id,True)


if __name__=='__main__':main()
