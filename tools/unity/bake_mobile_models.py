"""Blender batch: preserve silhouettes/UV appearance, bake one albedo material.

Outputs candidates only. Original Unity resources are archived before staging.
"""
import argparse
import json
import math
import sys
import subprocess
from pathlib import Path
import bpy
from mathutils import Vector

def save(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def clear():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version=0
def meshes():return [o for o in bpy.context.scene.objects if o.type=='MESH']
def bounds(objects):
    points=[o.matrix_world@Vector(c) for o in objects for c in o.bound_box]
    lo=Vector([min(v[i] for v in points) for i in range(3)])
    hi=Vector([max(v[i] for v in points) for i in range(3)])
    return (lo+hi)*.5,hi-lo
def triangle_count(obj):
    obj.data.calc_loop_triangles();return len(obj.data.loop_triangles)
def emission(mat, material_info, folder):
    mat.use_nodes=True;nodes=mat.node_tree.nodes;links=mat.node_tree.links
    bsdf=next((n for n in nodes if n.type=='BSDF_PRINCIPLED'),None)
    out=next(n for n in nodes if n.type=='OUTPUT_MATERIAL')
    source=None;color=(1,1,1,1)
    if material_info:
        authored=material_info['color']
        color=tuple(v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in authored[:3])+(authored[3],)
        if material_info.get('texture'):
            tex=nodes.new('ShaderNodeTexImage');tex.image=bpy.data.images.load(str(folder/material_info['texture']),check_existing=True)
            uv=nodes.new('ShaderNodeUVMap');uv.uv_map='SourceUV';links.new(uv.outputs['UV'],tex.inputs['Vector'])
            mul=nodes.new('ShaderNodeMixRGB');mul.blend_type='MULTIPLY';mul.inputs[0].default_value=1;mul.inputs[2].default_value=color
            links.new(tex.outputs['Color'],mul.inputs[1]);source=mul.outputs[0]
    elif bsdf:
        color=bsdf.inputs['Base Color'].default_value[:]
        if bsdf.inputs['Base Color'].is_linked:source=bsdf.inputs['Base Color'].links[0].from_socket
        for tex in [n for n in nodes if n.type=='TEX_IMAGE']:
            if not tex.inputs['Vector'].is_linked:
                uv=nodes.new('ShaderNodeUVMap');uv.uv_map='SourceUV';links.new(uv.outputs[0],tex.inputs['Vector'])
    emit=nodes.new('ShaderNodeEmission');emit.inputs['Color'].default_value=color
    if source:links.new(source,emit.inputs['Color'])
    links.new(emit.outputs[0],out.inputs['Surface'])

def process(item,outroot):
    clear();source=Path(item['source']);folder=outroot/item['id'];folder.mkdir(parents=True,exist_ok=True)
    if source.suffix=='.blend':bpy.ops.wm.open_mainfile(filepath=str(source))
    else:bpy.ops.import_scene.fbx(filepath=str(source))
    objects=meshes();_,dimensions=bounds(objects)
    infos={}
    if item.get('materialFile'):infos={m['name']:m for m in json.loads(Path(item['materialFile']).read_text('utf-8'))['materials']}
    total=sum(triangle_count(o) for o in objects);target=item['target']
    for obj in objects:
        bpy.context.view_layer.objects.active=obj;obj.select_set(True)
        if len(obj.data.uv_layers)==0:obj.data.uv_layers.new(name='SourceUV')
        obj.data.uv_layers.active.name='SourceUV'
        for mat in obj.data.materials:
            info=infos.get(mat.name) or infos.get(mat.name.split('.')[0])
            emission(mat,info,source.parent)
        if total>target:
            mod=obj.modifiers.new('Mobile silhouette budget','DECIMATE');mod.ratio=target/total;mod.use_collapse_triangulate=True
            bpy.ops.object.modifier_apply(modifier=mod.name)
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0];bpy.ops.object.join();obj=bpy.context.object
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    center,size=bounds([obj]);factor=1/max(size)
    for v in obj.data.vertices:v.co=(v.co-center)*factor
    obj.data.update();obj.name=item['id']
    collision=None
    if item.get('container'):
        collision=obj.copy();collision.data=obj.data.copy();bpy.context.collection.objects.link(collision)
        collision.hide_render=True
        if item['id']=='basket_farm':
            # Do not collide against every disconnected woven strip. An open
            # 24-sided inner bowl retains a floor and sloped inner wall.
            c,s=bounds([obj]);segments=24;vertices=[(0,0,-s.z*.5+s.z*.10)]
            for radius,z in [(.86,-s.z*.5+s.z*.10),(.96,s.z*.5)]:
                for i in range(segments):
                    a=i*2*math.pi/segments;vertices.append((math.cos(a)*s.x*.5*radius,math.sin(a)*s.y*.5*radius,z))
            faces=[]
            for i in range(segments):
                j=(i+1)%segments;faces.append((0,1+i,1+j));faces.append((1+i,1+segments+i,1+segments+j,1+j))
            mesh=bpy.data.meshes.new('BasketInnerContact');mesh.from_pydata(vertices,[],faces);mesh.update();collision.data=mesh
        bpy.ops.object.select_all(action='DESELECT');collision.select_set(True)
        bpy.context.view_layer.objects.active=collision
        collision.data.materials.clear()
        for uv in list(collision.data.uv_layers):collision.data.uv_layers.remove(uv)
        bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.remove_doubles(threshold=.00001);bpy.ops.object.mode_set(mode='OBJECT')
        mod=collision.modifiers.new('Static contact mesh','DECIMATE');mod.ratio=min(1,400/max(1,triangle_count(collision)));mod.use_collapse_triangulate=True
        bpy.ops.object.modifier_apply(modifier=mod.name)
        collision.hide_set(False);bpy.ops.object.select_all(action='DESELECT');collision.select_set(True)
        bpy.ops.export_scene.fbx(filepath=str(folder/'collision.fbx'),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False)
        collision.hide_set(True)
    bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
    sourceuv=obj.data.uv_layers.get('SourceUV');uv=obj.data.uv_layers.new(name='AtlasUV');obj.data.uv_layers.active=uv;uv.active_render=True
    material_data=[]
    for index,material in enumerate(obj.data.materials):
        info=infos.get(material.name) or infos.get(material.name.split('.')[0])
        coords=[sourceuv.data[loop].uv[:] for poly in obj.data.polygons if poly.material_index==index for loop in poly.loop_indices]
        lo=[min((v[j] for v in coords),default=0) for j in range(2)];hi=[max((v[j] for v in coords),default=1) for j in range(2)]
        if info:
            color=info['color'];texture=str(source.parent/info['texture']) if info.get('texture') else None
        else:
            bsdf=next((n for n in material.node_tree.nodes if n.type=='BSDF_PRINCIPLED'),None)
            textures=[n.image for n in material.node_tree.nodes if n.type=='TEX_IMAGE' and n.image]
            local=source.parent/Path(textures[0].filepath).name if textures else None
            texture=str(local) if local and local.exists() else bpy.path.abspath(textures[0].filepath) if textures else None
            if texture and not Path(texture).exists():
                texture=str(folder/('source_'+str(index)+'.png'))
                if textures[0].packed_file:Path(texture).write_bytes(textures[0].packed_file.data)
                else:textures[0].filepath_raw=texture;textures[0].file_format='PNG';textures[0].save()
            color=[1,1,1,1] if texture else list(bsdf.inputs['Base Color'].default_value) if bsdf else [1,1,1,1]
            if not texture:color=[12.92*v if v<=.0031308 else 1.055*v**(1/2.4)-.055 for v in color[:3]]+[color[3]]
        material_data.append(dict(color=color,texture=texture,uvMin=lo,uvMax=hi,alphaOverTint=bool(info and info.get('alphaOverTint'))))
    atlas_file=folder/'atlas-input.json';save(atlas_file,dict(materials=material_data,output=str(folder/'albedo.png')))
    subprocess.run(['C:/Users/123/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe',str(Path(__file__).resolve().parent/'build_material_atlas.py'),str(atlas_file)],check=True)
    rects=json.loads(atlas_file.with_suffix('.rects.json').read_text('utf-8'))
    for poly in obj.data.polygons:
        info=material_data[poly.material_index];rect=rects[poly.material_index]
        for loop in poly.loop_indices:
            old=sourceuv.data[loop].uv
            uv.data[loop].uv=[rect['min'][j]+rect['scale'][j]*((old[j]-info['uvMin'][j])/max(.000001,info['uvMax'][j]-info['uvMin'][j]) if info['texture'] else .5) for j in range(2)]
    image=bpy.data.images.load(str(folder/'albedo.png'),check_existing=False);image.pack()
    mat=bpy.data.materials.new(item['id']+'_mobile');mat.use_nodes=True
    tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=image
    mat.node_tree.links.new(tex.outputs['Color'],mat.node_tree.nodes.get('Principled BSDF').inputs['Base Color'])
    mat.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=.65
    obj.data.materials.clear();obj.data.materials.append(mat)
    for poly in obj.data.polygons:poly.material_index=0
    for layer in list(obj.data.uv_layers):
        if layer.name!='AtlasUV':obj.data.uv_layers.remove(layer)
    if collision:bpy.data.objects.remove(collision,do_unlink=True)
    bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
    bpy.ops.wm.save_as_mainfile(filepath=str(folder/(item['id']+'.blend')))
    bpy.ops.export_scene.fbx(filepath=str(folder/(item['id']+'.fbx')),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,path_mode='STRIP')
    bpy.ops.export_scene.gltf(filepath=str(folder/(item['id']+'.glb')),export_format='GLB',use_selection=True,export_yup=True)
    save(folder/'materials.json',{'materials':[{'name':mat.name,'color':[1,1,1,1],'metallic':0,'roughness':.65,'texture':'albedo.png'}]})
    version=item.get('pipelineVersion',6 if item.get('reference') else 5)
    result=dict(pipelineVersion=version,id=item['id'],source=str(source),sourceTriangles=total,triangles=triangle_count(obj),renderers=1,materials=1,sourceDimensions=list(dimensions),
                normalizedDimensions=list(bounds([obj])[1]),reference=item.get('reference',False),textureSize=item.get('textureSize',512),collisionTriangles=None)
    save(folder/'metrics.json',result);print('MOBILE_BAKED',item['id'],result['triangles'],flush=True)
    return result

def main():
    p=argparse.ArgumentParser();p.add_argument('--batch',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    args=p.parse_args(sys.argv[sys.argv.index('--')+1:]);args.output=args.output.resolve();args.output.mkdir(parents=True,exist_ok=True)
    batch=json.loads(args.batch.read_text('utf-8'));results=[]
    for item in batch:
        marker=args.output/item['id']/'metrics.json'
        version=item.get('pipelineVersion',6 if item.get('reference') else 5)
        if marker.exists() and (marker.parent/'albedo.png').exists() and json.loads(marker.read_text('utf-8')).get('pipelineVersion')==version:
            results.append(json.loads(marker.read_text('utf-8')));continue
        results.append(process(item,args.output));save(args.output/'batch-results.json',results)
    save(args.output/'batch-results.json',results)
if __name__=='__main__':main()
