"""Publish the approved production batch to the active Unity project; preserve metas."""
import sys,json,shutil,hashlib
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from duck_series_catalog import ROOT,OUT,CATALOG,THEME_NAMES
PROJECT=ROOT/'projects/catch-big-goose-unity'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def collision_export():
    import bpy
    for row in CATALOG:
        id=row['id'];folder=PROJECT/'Assets/duck-collision-inputs';folder.mkdir(exist_ok=True)
        data=json.loads((OUT/'qa'/(id+'-collision.json')).read_text('utf-8'))
        assert data['sourceSha256']==sha(OUT/'models'/id/(id+'.glb'))
        bpy.ops.wm.read_factory_settings(use_empty=True)
        mesh=bpy.data.meshes.new(id);mesh.from_pydata(data['vertices'],[],data['faces']);mesh.update()
        obj=bpy.data.objects.new(id,mesh);bpy.context.collection.objects.link(obj);obj.select_set(True);bpy.context.view_layer.objects.active=obj
        bpy.ops.export_scene.fbx(filepath=str(folder/(id+'-collision.fbx')),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=False)
def stage():
    from PIL import Image
    protected=['Assets/Resources/Data/themes.json','Assets/Resources/Data/theme-rounds.json','Assets/Editor/GoosePlayerNetworkPolicy.cs']
    hashes={p:sha(PROJECT/p) for p in protected}
    inputs=[]
    for row in CATALOG:
        id=row['id'];src=OUT/'models'/id;dest=PROJECT/'Assets/Resources/Models'/id;dest.mkdir(parents=True,exist_ok=True)
        orm=Image.open(src/'metalrough.png').convert('RGB');_,rough,metal=orm.split();zero=Image.new('L',orm.size,0)
        Image.merge('RGBA',(metal,zero,zero,rough.point(lambda v:255-v))).save(src/'unity-metallic.png')
        for name in [id+'.fbx','albedo.png','unity-metallic.png']:
            shutil.copy2(src/name,dest/name);inputs.append({'source':str((src/name).relative_to(ROOT)),'sha256':sha(src/name)})
        shutil.copy2(OUT/'renders'/id/'duck/icon-192.png',PROJECT/'Assets/Resources/Icons'/(id+'.png'))
    home=PROJECT/'Assets/duck-mascot-inputs';home.mkdir(exist_ok=True)
    shutil.copy2(OUT.parent/'model-review-b2/qa/unity-import/duck-b2-home.fbx',home/'duck-home.fbx')
    shutil.copy2(OUT.parent/'master-b2/models/duck-b2-master/albedo.png',home/'albedo.png')
    shutil.copy2(Path(__file__).with_name('GooseDuckMobile.shader'),PROJECT/'Assets/Resources/GooseDuckMobile.shader')
    (PROJECT/'Assets/Resources/Mascots').mkdir(exist_ok=True)
    themes=json.loads((PROJECT/protected[0]).read_text('utf-8'))['themes'];review=[]
    for key,name in THEME_NAMES.items():
        original=next(t for t in themes if t['id']=={'courtyard':'countryside'}.get(key,key))
        ids=[r['id'] for r in CATALOG if r['theme']==key]
        review.append({**original,'id':'duck-review-'+key,'name':'鸭子评审 · '+name,'icon':ids[0],'items':ids,
            'itemWeights':[1]*4,'groupWeights':[1]*4,'coreGroupWeights':[1]*4,'coreWeightEvidence':'Independent B2 review catalog; 12 objects per type.'})
    (PROJECT/'Assets/Resources/Data/duck-review.json').write_text(json.dumps({'themes':review},ensure_ascii=False,indent=2),'utf-8')
    path=PROJECT/'Assets/Resources/Data/item-presentation.json';data=json.loads(path.read_text('utf-8'));lookup={r['id']:r for r in data['items']}
    ids={r['id'] for r in CATALOG};data['items']=[r for r in data['items'] if r['id'] not in ids]
    for row in CATALOG:
        ref='ref_goose_'+Path(row['reference']).stem.removeprefix('Goose_').lower()
        data['items'].append({'id':row['id'],'scale':lookup.get(ref,{}).get('scale',1),'evidence':'B2 normalized extent; same presentation scale as '+ref})
    path.write_text(json.dumps(data,ensure_ascii=False,indent=2),'utf-8')
    assert all(sha(PROJECT/p)==h for p,h in hashes.items())
    (OUT/'qa/unity-staging.json').write_text(json.dumps({'protectedFiles':hashes,'inputs':inputs,'productionProject':str(PROJECT),'userAuthorization':'B2 三款通过，继续完整计划'},ensure_ascii=False,indent=2),'utf-8')
    print('STAGED',len(CATALOG),'duck models and B2 homepage rig')
if __name__=='__main__':
    if '--collisions' in sys.argv:collision_export()
    else:stage()
