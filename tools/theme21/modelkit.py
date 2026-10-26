"""Original solid-part builders using the repository's palette pipeline."""
import importlib.util
import math
from pathlib import Path
import bpy
from mathutils import Vector

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('existing_model_pipeline',ROOT/'skills/match3-model-pipeline/scripts/generate_electronics.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
base.COLORS[6]=(.40,.20,.075,1)
box=base.box
disc=base.disc
tube=base.tube

def ball(name,loc,scale,color,segments=16,rings=8):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments,ring_count=rings,location=loc)
    o=bpy.context.object;o.scale=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    return base.paint(o,name,color)

def ring(name,loc,major,minor,color,rotation=(0,0,0),segments=24):
    bpy.ops.mesh.primitive_torus_add(major_radius=major,minor_radius=minor,
        major_segments=segments,minor_segments=8,location=loc,rotation=rotation)
    return base.paint(bpy.context.object,name,color)

def lathe(name,profile,color,loc=(0,0,0),segments=24):
    verts=[];faces=[]
    for z,r in profile:
        assert r>0
        verts.extend((loc[0]+r*math.cos(j*math.tau/segments),loc[1]+r*math.sin(j*math.tau/segments),loc[2]+z) for j in range(segments))
    for row in range(len(profile)-1):
        for j in range(segments):
            a=row*segments+j;b=row*segments+(j+1)%segments
            faces.append((a,b,b+segments,a+segments))
    faces += [tuple(reversed(range(segments))),tuple((len(profile)-1)*segments+j for j in range(segments))]
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update()
    o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o)
    return base.paint(o,name,color)

def leaf(name,loc,length,width,color,angle=0):
    o=ball(name,loc,(width,length,.035),color,12,6);o.rotation_euler.z=angle
    return o

def eyes(x,z,y=-.19,color=5):
    for sign in [-1,1]:ball('eye',(sign*x,y,z),(.027,.018,.027),color,12,6)

def stem(z=.45,color=6):disc('stem',(0,0,z),.035,.16,color,vertices=12)

def radial_leaves(z,count=5,radius=.14,width=.065,length=.17,color=12):
    for i in range(count):
        a=i*math.tau/count
        leaf('leaf',(radius*math.sin(a),radius*math.cos(a),z),length,width,color,-a)

def raw_mesh(name,verts,faces,color):
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update()
    o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o)
    return base.paint(o,name,color)
