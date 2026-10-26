"""Bake serialized prefab bone poses, retaining every skin input as evidence.

This does not evaluate Animator/Animancer or claim to recover a running frame.
"""
import argparse
import hashlib
import json
import sys
from pathlib import Path

def dump(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), 'utf-8')

def vec(v):
    return [getattr(v, k) for k in ('x','y','z','w') if hasattr(v,k)]

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for k in ['cache','deps','audit','output']: p.add_argument('--'+k,type=Path,required=True)
    a=p.parse_args();sys.path.insert(0,str(a.deps))
    import numpy as np
    import UnityPy
    from UnityPy.helpers.MeshHelper import MeshHandler
    audit=json.loads(a.audit.read_text('utf-8'))
    targets={'Goose_Pancake','Goose_GTCapsulePen','Goose_GTCraftPunch','Goose_GTNumberBlock','Goose_GTYoYo'}
    entries=[x for x in audit['containers'] if Path(x['path']).stem in targets]
    paths={p.name:p for p in a.cache.rglob('*.bundle')}
    sources=[];models=[]
    def trs(t,root=False):
        x,y,z,w=vec(t.m_LocalRotation)
        m=np.eye(4)
        m[:3,:3]=np.array([[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)],
                          [2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)],
                          [2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]])@np.diag(vec(t.m_LocalScale))
        m[:3,3]=[0,0,0] if root else vec(t.m_LocalPosition)
        return m
    for bundle in sorted({x['bundle'] for x in entries}):
        blob=paths[bundle].read_bytes();env=UnityPy.load(blob)
        sources.append(dict(file=bundle,bytes=len(blob),sha256=hashlib.sha256(blob).hexdigest()))
        for prefab,ptr in env.container.items():
            name=Path(prefab).stem
            if name not in targets: continue
            folder=a.output/'models'/name;folder.mkdir(parents=True,exist_ok=True)
            nodes=[];worlds={};renderers=[];materials={};meshes=[];skin=[];animation=[]
            def walk(go,parent=None,world=None,active=True):
                comps=[(c.component.type.name,c.component) for c in go.m_Component]
                tr=next(p.read() for typ,p in comps if typ=='Transform')
                i=len(nodes);local=trs(tr,parent is None)
                world=local if world is None else world@local
                active=active and bool(go.m_IsActive)
                worlds[tr.object_reader.path_id]=world
                nodes.append(dict(name=go.m_Name,parent=parent,pathId=tr.object_reader.path_id,
                                  position=[0,0,0] if parent is None else vec(tr.m_LocalPosition),
                                  rotation=vec(tr.m_LocalRotation),scale=vec(tr.m_LocalScale),active=active,
                                  worldMatrix=world.tolist()))
                renderer=next((p.read() for typ,p in comps if typ=='MeshRenderer'),None)
                for typ,cp in comps:
                    if typ=='SkinnedMeshRenderer': renderers.append((i,cp.read(),True,active))
                    if typ=='MeshFilter' and renderer: renderers.append((i,(cp.read(),renderer),False,active))
                    if typ in ['Animator','Animation','MonoBehaviour']:
                        animation.append(dict(node=i,type=typ,pathId=cp.path_id,
                                              evidence='Component present; runtime animation not evaluated'))
                for child in tr.m_Children: walk(child.read().m_GameObject.read(),i,world,active)
            walk(ptr.read())
            def mat(mp):
                key=str(mp.path_id)
                if key in materials:return key
                m=mp.read();textures={}
                for slot,info in m.m_SavedProperties.m_TexEnvs:
                    if not info.m_Texture.path_id:continue
                    t=info.m_Texture.read();file=f'tex_{t.object_reader.path_id}.png';t.image.save(folder/file)
                    textures[slot]=dict(file=file,name=t.m_Name,width=t.m_Width,height=t.m_Height,
                                        format=int(t.m_TextureFormat),scale=vec(info.m_Scale),offset=vec(info.m_Offset))
                shader=getattr(m.m_Shader.read(),'m_ParsedForm',None)
                materials[key]=dict(name=m.m_Name,shader=shader.m_Name if shader else None,textures=textures,
                                    floats=dict(m.m_SavedProperties.m_Floats),
                                    colors={k:[v.r,v.g,v.b,v.a] for k,v in m.m_SavedProperties.m_Colors})
                return key
            for node,r,is_skin,active in renderers:
                if is_skin: mesh=r.m_Mesh.read();renderer=r
                else: mf,renderer=r;mesh=mf.m_Mesh.read()
                h=MeshHandler(mesh);h.process()
                v=np.array(h.m_Vertices,dtype=float)[:,:3];n=np.array(h.m_Normals,dtype=float)[:,:3]
                source_v=v.copy();source_n=n.copy()
                if is_skin:
                    bp=np.array([[[getattr(m,f'e{i}{j}') for j in range(4)] for i in range(4)] for m in mesh.m_BindPose])
                    indices=np.array(h.m_BoneIndices,dtype=int);weights=np.array(h.m_BoneWeights,dtype=float)
                    assert len(v)==len(indices)==len(weights)
                    error=float(np.max(np.abs(weights.sum(axis=1)-1)))
                    assert error<1e-4,(name,error)
                    bone_ids=[b.path_id for b in r.m_Bones]
                    transforms=np.array([worlds[b]@bind for b,bind in zip(bone_ids,bp)])
                    assert len(transforms)==len(bp)==len(bone_ids)
                    v=np.zeros_like(v);n=np.zeros_like(n)
                    for slot in range(weights.shape[1]):
                        mask=weights[:,slot]>0
                        assert np.all(indices[mask,slot]<len(transforms))
                        selected=transforms[indices[mask,slot]]
                        v[mask]+=weights[mask,slot,None]*np.einsum('nij,nj->ni',selected,np.column_stack((source_v[mask],np.ones(mask.sum()))))[:,:3]
                        normal_matrices=np.linalg.inv(selected[:,:3,:3]).transpose(0,2,1)
                        n[mask]+=weights[mask,slot,None]*np.einsum('nij,nj->ni',normal_matrices,source_n[mask])
                    skin.append(dict(node=node,meshName=mesh.m_Name,boneTransformPathIds=bone_ids,
                                     rootBonePathId=r.m_RootBone.path_id,bindPoses=bp.tolist(),
                                     positions=source_v.tolist(),normals=source_n.tolist(),
                                     indices=indices.tolist(),weights=weights.tolist(),weightSumMaxError=error,
                                     rendererEnabled=bool(renderer.m_Enabled),activeInHierarchy=active,
                                     serializedAabb=renderer.m_AABB.__dict__ if hasattr(renderer.m_AABB,'__dict__') else str(renderer.m_AABB)))
                else:
                    tr=worlds[nodes[node]['pathId']]
                    v=(tr@np.column_stack((v,np.ones(len(v)))).T).T[:,:3]
                    n=(np.linalg.inv(tr[:3,:3]).T@n.T).T
                lengths=np.linalg.norm(n,axis=1);assert np.all(lengths>0);n/=lengths[:,None]
                if active and renderer.m_Enabled:
                    meshes.append(dict(name=mesh.m_Name,node=0,positions=v.tolist(),normals=n.tolist(),uv=h.m_UV0,
                                       triangles=list(h.get_triangles()),materials=[mat(m) for m in renderer.m_Materials]))
            triangles=sum(len(t) for m in meshes for t in m['triangles'])
            assert meshes and skin,(name,'No visible skin')
            pose=dict(id=name,nodes=nodes,skins=skin,animationComponents=animation,
                      formula='vRoot = sum(weight * boneWorld(prefab pose, root translation removed) * bindPose * vMesh)',
                      scope='Serialized prefab pose; runtime clips, constraints and animation are not evaluated')
            dump(folder/'source-pose.json',pose)
            scene=dict(id=name,prefab=prefab,bundle=bundle,
                       nodes=[dict(name='BakedPrefabPose',parent=None,position=[0,0,0],rotation=[0,0,0,1],scale=[1,1,1])],
                       meshes=meshes,materials=materials,colliders=[],triangles=triangles,
                       coordinateSystem='Unity LH Y-up, full prefab scale preserved; root translation removed',
                       poseEvidence='source-pose.json')
            dump(folder/'source.json',scene)
            models.append(dict(id=name,triangles=triangles,meshes=len(meshes),materials=len(materials),
                               skinRenderers=len(skin),bones=sum(len(s['bindPoses']) for s in skin),
                               source=f'models/{name}/source.json',sourceSha256=hashlib.sha256((folder/'source.json').read_bytes()).hexdigest(),
                               pose='Serialized prefab pose baked into a static reference; full skin inputs retained separately'))
    assert {m['id'] for m in models}==targets
    dump(a.output/'manifest.json',dict(appId='wxb98ac240fd74b0e3',date='2026-10-23',purpose='Pose and generation reference only; not runtime models',
                                     unityPyVersion=UnityPy.__version__,sources=sources,models=models))
    print(json.dumps(models,ensure_ascii=True))

if __name__=='__main__': main()
