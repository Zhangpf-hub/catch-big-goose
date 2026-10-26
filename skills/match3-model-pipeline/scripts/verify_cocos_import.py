"""Check real Creator-generated metadata and library assets after Creator import."""
import argparse
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--project', type=Path, required=True)
parser.add_argument('--candidate', type=Path, required=True)
parser.add_argument('--asset-dir', default='reference-projects/catch-big-goose-cocos/assets/models-pool/electronics')
parser.add_argument('--icon-dir')
parser.add_argument('--library-project', type=Path)
args = parser.parse_args()
project, batch = args.project.resolve(), args.candidate.resolve()
asset_dir = project / args.asset_dir
icon_dir = project / args.icon_dir if args.icon_dir else asset_dir / 'icons'
library_project = args.library_project.resolve() if args.library_project else project / 'reference-projects/catch-big-goose-cocos'
audit = json.loads((batch / 'qa/asset-audit.json').read_text(encoding='utf-8'))
rows = []
for row in audit['models']:
    model_id = row['id']
    meta = json.loads((asset_dir / f'{model_id}.glb.meta').read_text(encoding='utf-8'))
    assert meta['importer'] == 'gltf' and meta['imported']
    sub = list(meta['subMetas'].values())
    def one(kind):
        found = [item for item in sub if item['importer'] == kind]
        assert len(found) == 1 and found[0]['imported'], (model_id, kind)
        return found[0]
    mesh, material, prefab, texture, image = [one(k) for k in
        ('gltf-mesh', 'gltf-material', 'gltf-scene', 'texture', 'gltf-embeded-image')]
    assert mesh['userData']['triangleCount'] == row['triangles']
    assert prefab['name'] == f'{model_id}.prefab'
    def library(item):
        uid = item['uuid']
        return json.loads((library_project / 'library' / uid[:2] / f'{uid}.json').read_text(encoding='utf-8'))
    mat = library(material)
    assert mat['__type__'] == 'cc.Material' and mat['_defines'][0]['USE_ALBEDO_MAP']
    props = mat['_props'][0]
    assert props['metallic'] == 0 and abs(props['roughness'] - .6) < 1e-5
    assert props['mainTexture']['__uuid__'] == texture['uuid']
    mesh_data = library(mesh)
    mesh_text = json.dumps(mesh_data)
    assert 'a_position' in mesh_text and 'a_normal' in mesh_text and 'a_texCoord' in mesh_text
    scene = library(prefab)
    assert any(item.get('__type__') == 'cc.Node' and item.get('_name') == model_id for item in scene)
    assert sum(item.get('__type__') == 'cc.MeshRenderer' for item in scene) == 1
    icon_meta = json.loads((icon_dir / f'{model_id}.png.meta').read_text(encoding='utf-8'))
    assert icon_meta['imported'] and icon_meta['userData']['hasAlpha']
    assert icon_meta['userData']['type'] == 'texture'
    rows.append(dict(id=model_id, modelUuid=meta['uuid'], prefabUuid=prefab['uuid'],
                     materialUuid=material['uuid'], iconUuid=icon_meta['uuid'],
                     triangles=mesh['userData']['triangleCount'], meshRendererCount=1,
                     albedoTexture=True, normalsAndUV=True, alphaIcon=True, status='passed'))
report = dict(status='passed', creatorVersion='3.8.8', scope='actual Creator metadata, mesh/prefab/material library output and icon import; no in-game candidate UI test', models=rows)
(batch / 'qa/cocos-import.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
print(f'PASS: {len(rows)} Creator-imported prefabs, textures, material links, normals/UV and alpha icons')
