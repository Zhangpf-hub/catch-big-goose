"""Stage an isolated Unity 2022.3.62f3 import/PhysX audit. Run with Blender.

Does not touch the active Unity project or alter the approved concept/source mesh.
"""
from pathlib import Path
import hashlib
import json
import shutil
import bpy

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'source-assets/models/candidates/duck-series-v1'
QA = ROOT / 'work/duck-b2-unity-qa'
IDS = ('duck-eggtart', 'duck-steelcup', 'duck-numberblock')


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    for name in ('Assets/Editor', 'Assets/candidates', 'ProjectSettings', 'Packages'):
        (QA / name).mkdir(parents=True, exist_ok=True)
    active = ROOT / 'projects/catch-big-goose-unity'
    shutil.copy2(active/'ProjectSettings/ProjectVersion.txt', QA/'ProjectSettings/ProjectVersion.txt')
    shutil.copy2(active/'Assets/Editor/GoosePlayerNetworkPolicy.cs', QA/'Assets/Editor/GoosePlayerNetworkPolicy.cs')
    shutil.copy2(Path(__file__).with_name('DuckB2UnityAudit.cs'), QA/'Assets/Editor/DuckB2UnityAudit.cs')
    (QA/'Packages/manifest.json').write_text(json.dumps({'dependencies': {
        'com.unity.modules.animation':'1.0.0',
        'com.unity.modules.physics':'1.0.0',
        'com.unity.modules.imageconversion':'1.0.0',
        'com.unity.modules.jsonserialize':'1.0.0',
    }}, indent=2), 'utf-8')
    inputs = []
    for id in IDS:
        src = SOURCE/'model-review-b2/models'/id
        dest = QA/'Assets/candidates'/id
        dest.mkdir(exist_ok=True)
        for name in (id+'.fbx','albedo.png','unity-metallic.png'):
            shutil.copy2(src/name,dest/name)
            inputs.append({'source':str((src/name).relative_to(ROOT)), 'sha256':sha(src/name),
                           'staged':str((dest/name).relative_to(QA))})
        bpy.ops.wm.read_factory_settings(use_empty=True)
        data=json.loads((SOURCE/'model-review-b2/qa'/f'{id}-collision.json').read_text('utf-8'))
        assert data['sourceSha256']==sha(src/(id+'.glb'))
        mesh=bpy.data.meshes.new(id+'-collision')
        mesh.from_pydata(data['vertices'],[],data['faces']);mesh.update()
        obj=bpy.data.objects.new(id+'-collision',mesh);bpy.context.collection.objects.link(obj)
        obj.select_set(True);bpy.context.view_layer.objects.active=obj
        bpy.ops.export_scene.fbx(filepath=str(dest/'collision.fbx'),use_selection=True,
            object_types={'MESH'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=False)
        inputs.append({'source':str((src/'convex-hull.obj').relative_to(ROOT)),
                       'sha256':sha(src/'convex-hull.obj'),'staged':str((dest/'collision.fbx').relative_to(QA)),
                       'conversion':'The exact validated offline hull vertices, exported with the visual FBX axes.'})
    rigSource=SOURCE/'master-b2/source/duck-b2-master-rig.blend'
    originalHash=sha(rigSource)
    bpy.ops.wm.open_mainfile(filepath=str(rigSource))
    rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
    rig.animation_data.action=None
    for track in rig.animation_data.nla_tracks:track.mute=True
    for bone in rig.pose.bones:
        bone.location=(0,0,0);bone.rotation_mode='XYZ';bone.rotation_euler=(0,0,0);bone.scale=(1,1,1)
    bpy.context.scene.frame_set(1);bpy.context.view_layer.update()
    bpy.ops.object.select_all(action='DESELECT')
    for obj in bpy.context.scene.objects:
        if obj.type in ('ARMATURE','MESH'):obj.select_set(True)
    bpy.context.view_layer.objects.active=rig
    dest=QA/'Assets/candidates/duck-b2-home';dest.mkdir(exist_ok=True)
    bpy.ops.export_scene.fbx(filepath=str(dest/'duck-b2-home.fbx'),use_selection=True,
        object_types={'MESH','ARMATURE'},axis_forward='-Z',axis_up='Y',add_leaf_bones=False,
        bake_anim=True,bake_anim_use_all_actions=True,bake_anim_use_nla_strips=False,
        bake_anim_simplify_factor=0,bake_anim_step=1,path_mode='STRIP')
    shutil.copy2(SOURCE/'master-b2/models/duck-b2-master/albedo.png',dest/'albedo.png')
    assert sha(rigSource)==originalHash
    inputs.append({'source':str(rigSource.relative_to(ROOT)), 'sha256':originalHash,
                   'staged':'Assets/candidates/duck-b2-home/duck-b2-home.fbx',
                   'conversion':'FBX bake of the three original actions, original blend unchanged.'})
    (QA/'staging.json').write_text(json.dumps({'inputs':inputs,'sourceProjectModified':False,
        'unityVersion':'2022.3.62f3','networkPolicyCopied':True},indent=2),'utf-8')
    print('DUCK_B2_UNITY_QA_STAGED',str(QA),flush=True)


if __name__=='__main__':main()
