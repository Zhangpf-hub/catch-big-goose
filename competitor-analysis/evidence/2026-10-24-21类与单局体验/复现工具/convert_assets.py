"""Run with Blender --background --factory-startup --python this_file."""
import bpy
import json
import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'unity/SourceAssets/Models'
DEST = ROOT / 'unity/Assets/Resources/Models'
parser = argparse.ArgumentParser()
parser.add_argument('--only', default='')
options = parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
selected = set(options.only.split(',')) if options.only else None

for source in sorted(SOURCE.glob('*.glb')):
    if selected is not None and source.stem not in selected:
        continue
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for collection in [bpy.data.materials, bpy.data.images, bpy.data.meshes]:
        for block in list(collection):
            if block.users == 0:
                collection.remove(block)
    bpy.ops.import_scene.gltf(filepath=str(source))
    model_dir = DEST / source.stem
    model_dir.mkdir(parents=True, exist_ok=True)
    materials = []
    for index, material in enumerate([m for m in bpy.data.materials if m.users]):
        material.name = f'{source.stem}_mat_{index}'
        bsdf = next((n for n in material.node_tree.nodes if n.type == 'BSDF_PRINCIPLED'), None) if material.use_nodes else None
        color = list(bsdf.inputs['Base Color'].default_value) if bsdf else list(material.diffuse_color)
        metallic = float(bsdf.inputs['Metallic'].default_value) if bsdf else 0
        roughness = float(bsdf.inputs['Roughness'].default_value) if bsdf else 0.6
        texture = ''
        if bsdf and bsdf.inputs['Base Color'].is_linked:
            node = bsdf.inputs['Base Color'].links[0].from_node
            if node.type == 'TEX_IMAGE' and node.image:
                texture = f'{source.stem}_albedo_{index}.png'
                node.image.filepath_raw = str(model_dir / texture)
                node.image.file_format = 'PNG'
                node.image.save()
        materials.append(dict(name=material.name, color=color, metallic=metallic,
                              roughness=roughness, texture=texture))
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.fbx(filepath=str(model_dir / f'{source.stem}.fbx'),
        use_selection=True, object_types={'MESH', 'EMPTY'}, add_leaf_bones=False,
        bake_anim=False, axis_forward='-Z', axis_up='Y', path_mode='STRIP',
        use_mesh_modifiers=True, mesh_smooth_type='FACE', use_triangles=True)
    (model_dir / 'materials.json').write_text(json.dumps({'materials': materials}, indent=2), encoding='utf-8')
    print(f'UNITY_CONVERTED {source.stem}', flush=True)
