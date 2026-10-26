"""Blender: original low-poly corn study. No competitor geometry or textures used."""
import bpy
import json
import math
import sys
from pathlib import Path
from mathutils import Vector

root = Path(__file__).resolve().parents[2]
out = root / 'assets-3d/candidates/competitor-alignment-corn'
out.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
vertices, faces, coords = [], [], []


def part(verts, polys, uv):
    offset = len(vertices)
    vertices.extend(verts)
    coords.extend(uv)
    faces.extend(tuple(offset + i for i in f) for f in polys)


# Closed tapered cob. Kernel rows are painted, not separate meshes.
segments, rings = 20, 13
verts, uv, polys = [], [], []
for row in range(rings):
    t = row / (rings-1)
    z = -.37 + .78 * t
    r = .15 * (.75 + .25 * math.sin(math.pi*t)) * (1 - .78 * t**4)
    for j in range(segments+1):
        angle = j / segments * math.tau
        verts.append((r*math.cos(angle), r*math.sin(angle), z))
        uv.append((.02 + .68*j/segments, .03 + .94*t))
for i in range(rings-1):
    for j in range(segments):
        k = i*(segments+1)+j
        polys.append((k,k+1,k+segments+2,k+segments+1))
polys.extend([tuple(reversed(range(segments))), tuple((rings-1)*(segments+1)+j for j in range(segments))])
part(verts, polys, uv)
# Three closed folded leaves, each with front, back, rim and physical thickness.
for leaf, angle in enumerate((.25, 2.35, 4.45)):
    verts, uv, polys = [], [], []
    rows, cols = 7, 3
    for side in range(2):
        for i in range(rows):
            t = i/(rows-1)
            r = .065 + .19*math.sin(math.pi*t*.6)
            z = -.44 + .64*t - .13*t**4
            width = .012 + .09*math.sin(math.pi*t)**.8
            for j in range(cols):
                s = j/(cols-1)*2-1
                radial = r - .045*abs(s)*math.sin(math.pi*t) + (.007 if side==0 else -.007)
                verts.append((radial*math.cos(angle)-s*width*math.sin(angle), radial*math.sin(angle)+s*width*math.cos(angle), z))
                uv.append((.75 + .10*j/(cols-1), .04+.92*t))
    stride=rows*cols
    for i in range(rows-1):
        for j in range(cols-1):
            k=i*cols+j
            polys.append((k,k+cols,k+cols+1,k+1))
            polys.append(tuple(x+stride for x in (k+1,k+cols+1,k+cols,k)))
        for j in (0,cols-1):
            k=i*cols+j
            f=(k,k+stride,k+cols+stride,k+cols)
            polys.append(f if j==0 else tuple(reversed(f)))
    for i in (0,rows-1):
        for j in range(cols-1):
            k=i*cols+j
            f=(k,k+1,k+1+stride,k+stride)
            polys.append(f if i==0 else tuple(reversed(f)))
    part(verts,polys,uv)
# Cut stalk.
verts,uv,polys=[],[],[]
for row,z in enumerate((-.50,-.37)):
    for j in range(10):
        ang=j/10*math.tau
        verts.append((.045*math.cos(ang),.045*math.sin(ang),z))
        uv.append((.91+.06*j/10,.1+.8*row))
for j in range(10):
    k=(j+1)%10
    polys.append((j,k,k+10,j+10))
polys.extend((tuple(reversed(range(10))),tuple(range(10,20))))
part(verts,polys,uv)

mesh=bpy.data.meshes.new('corn')
mesh.from_pydata(vertices,[],faces)
mesh.update()
obj=bpy.data.objects.new('corn',mesh)
bpy.context.collection.objects.link(obj)
bpy.context.view_layer.objects.active=obj
obj.select_set(True)
# Weld only duplicate UV-seam vertices; UVs remain on face corners.
layer=mesh.uv_layers.new(name='UVMap')
for poly in mesh.polygons:
    poly.use_smooth=True
    for li in poly.loop_indices:
        layer.data[li].uv=coords[mesh.loops[li].vertex_index]
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.remove_doubles(threshold=.000001)
bpy.ops.mesh.normals_make_consistent(inside=False)
bpy.ops.object.mode_set(mode='OBJECT')
lo=Vector([min(v.co[i] for v in mesh.vertices) for i in range(3)])
hi=Vector([max(v.co[i] for v in mesh.vertices) for i in range(3)])
center=(lo+hi)/2
scale=max(hi-lo)
for v in mesh.vertices:
    v.co=(v.co-center)/scale

image=bpy.data.images.new('corn_original_512',width=512,height=512,alpha=True)
pixels=[]
for y in range(512):
    v=y/511
    for x in range(512):
        u=x/511
        if u<.72:
            row=(v-.03)/.94*11
            col=(u-.02)/.68*12 + .12*math.sin(row*math.pi)
            dx,dy=(col%1-.5)*2,(row%1-.5)*2
            edge=max(abs(dx)**5,abs(dy)**6)
            seam=max(0,min(1,(edge-.46)/.54))
            shade=1-.32*seam+.07*(-dx-dy)
            noise=.022*math.sin(x*1.7+y*.8)*math.sin(y*1.31)
            color=(min(1,.98*shade+noise),min(1,.63*shade+.035*math.sin(row)+noise),max(.02,.075*shade+noise))
        elif u<.88:
            vein=.025*math.sin((u-.75)*math.pi*110)
            color=(.14+vein+.05*v,.32+vein+.17*v,.035+vein*.4)
        else:
            color=(.38+.08*v,.43+.06*v,.12)
        # Keep the 512px painted detail but bound color entropy for a small PNG/GLB.
        color=tuple(round(max(0,min(1,c))*31)/31 for c in color)
        pixels.extend((*color,1))
image.pixels.foreach_set(pixels)
image.filepath_raw=str(out/'corn-basecolor.png')
image.file_format='PNG'
image.save()
image.pack()
mat=bpy.data.materials.new('corn_original')
mat.use_nodes=True
shader=mat.node_tree.nodes.get('Principled BSDF')
shader.inputs['Roughness'].default_value=.6
tex=mat.node_tree.nodes.new('ShaderNodeTexImage')
tex.image=image
mat.node_tree.links.new(tex.outputs['Color'],shader.inputs['Base Color'])
mesh.materials.append(mat)
mesh.calc_loop_triangles()
tris=len(mesh.loop_triangles)
assert tris<=1500
import bmesh
bm=bmesh.new();bm.from_mesh(mesh)
assert all(e.is_manifold for e in bm.edges)
bm.free()
bpy.ops.wm.save_as_mainfile(filepath=str(out/'corn.blend'))
bpy.ops.export_scene.gltf(filepath=str(out/'corn.glb'),export_format='GLB',use_selection=True,export_yup=True,export_animations=False)
assert (out/'corn.glb').stat().st_size <= 256*1024, 'Candidate exceeds 256 KiB budget'
# Export roundtrip proof.
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(out/'corn.glb'))
obj=next(o for o in bpy.context.scene.objects if o.type=='MESH')
obj.data.calc_loop_triangles()
assert len(obj.data.loop_triangles)==tris and len(obj.data.materials)==1
points=[obj.matrix_world@Vector(c)for c in obj.bound_box]
sizes=[max(p[i]for p in points)-min(p[i]for p in points)for i in range(3)]
assert abs(max(sizes)-1)<.0001
scene=bpy.context.scene
scene.render.engine='CYCLES';scene.cycles.samples=20;scene.cycles.use_denoising=True
scene.render.film_transparent=True
scene.render.resolution_x=scene.render.resolution_y=384
scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'
scene.view_settings.view_transform='Standard'
scene.world.color=(.55,.55,.55)
light=bpy.data.objects.new('Studio',bpy.data.lights.new('Studio','AREA'))
scene.collection.objects.link(light);light.data.energy=350;light.data.size=3
light.location=(1,-1.5,3);light.rotation_euler=(-light.location).to_track_quat('-Z','Y').to_euler()
cam=bpy.data.objects.new('Camera',bpy.data.cameras.new('Camera'))
scene.collection.objects.link(cam);cam.data.type='ORTHO';cam.data.ortho_scale=1.5;scene.camera=cam
for name,direction in [('three-quarter',(1.1,-1.4,1.5)),('front',(0,-3,.2)),('back',(0,3,.2)),('top',(0,-.001,3))]:
    cam.location=direction;cam.rotation_euler=(-cam.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(out/(name+'.png'));bpy.ops.render.render(write_still=True)
(out/'verification.json').write_text(json.dumps(dict(id='corn',triangles=tris,materials=1,meshes=1,texture=[512,512],
    glbRoundtrip=True,closedGeometry=True,normalizedMaxSide=max(sizes),source='Original procedural geometry and texture; no competitor asset data used',
    status='Candidate only; not installed in Cocos/Unity; collision and in-game appearance pending'),ensure_ascii=False,indent=2),encoding='utf8')
print('ORIGINAL_CORN_CANDIDATE',tris)
