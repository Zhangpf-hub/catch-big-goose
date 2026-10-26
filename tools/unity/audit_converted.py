"""Blender roundtrip geometry audit; this does not replace the Unity runtime acceptance."""
import bpy
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]


def clear():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)


def measure():
    objects = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']
    points = [obj.matrix_world @ Vector(corner) for obj in objects for corner in obj.bound_box]
    sizes = [max(p[i] for p in points) - min(p[i] for p in points) for i in range(3)]
    triangles = 0
    for obj in objects:
        obj.data.calc_loop_triangles()
        triangles += len(obj.data.loop_triangles)
    return {'sizes': sizes, 'triangles': triangles, 'meshes': len(objects),
            'uvMeshes': sum(bool(obj.data.uv_layers) for obj in objects)}


rows = []
for source in sorted((ROOT / 'projects/catch-big-goose-unity/SourceAssets/Models').glob('*.glb')):
    clear()
    bpy.ops.import_scene.gltf(filepath=str(source))
    before = measure()
    clear()
    bpy.ops.import_scene.fbx(filepath=str(ROOT / f'projects/catch-big-goose-unity/Assets/Resources/Models/{source.stem}/{source.stem}.fbx'))
    after = measure()
    row = {'id': source.stem, 'source': before, 'converted': after,
           'passed': before['triangles'] == after['triangles']
           and max(abs(a - b) for a, b in zip(sorted(before['sizes']), sorted(after['sizes']))) < .0001
           and after['uvMeshes'] >= before['uvMeshes']}
    rows.append(row)
path = ROOT / 'work/unity-migration/geometry-roundtrip.json'
path.write_text(json.dumps({'passed': all(row['passed'] for row in rows), 'models': rows}, indent=2), encoding='utf-8')
failed = [row['id'] for row in rows if not row['passed']]
print('UNITY_GEOMETRY_AUDIT', len(rows), 'models, failures:', failed)
if failed:
    raise RuntimeError('Geometry roundtrip mismatch')
