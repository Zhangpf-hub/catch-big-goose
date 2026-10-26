"""Read only the supplied game's local cache; export reference geometry and evidence.

Requires UnityPy 1.25.4. No network, process memory, package decryption or cache writes.
"""
import argparse
import hashlib
import json
import re
import struct
import sys
from pathlib import Path


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def dump(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')


def vector(v):
    return [getattr(v, k) for k in ('x', 'y', 'z', 'w') if hasattr(v, k)]


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cache', type=Path, required=True)
    ap.add_argument('--evidence', type=Path, required=True)
    ap.add_argument('--deps', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    ap.add_argument('--include-all-static', action='store_true', help='Use all cached LevelObjPrefab entries in the supplied audit')
    ap.add_argument('--exclude-manifest', type=Path, help='Skip models already exported in an earlier reference batch')
    ap.add_argument('--models-only', action='store_true', help='Do not write the historical declaration-only algorithm report')
    a = ap.parse_args()
    sys.path.insert(0, str(a.deps))
    import UnityPy
    from UnityPy.helpers.MeshHelper import MeshHandler

    expected = json.loads((a.evidence / 'barbecue-prefabs.json').read_text(encoding='utf-8'))
    # Ordinary static items only. Skinned goose requires bone-pose reconstruction.
    expected = [x for x in expected if '/LevelObjPrefab/' in x['prefab']]
    if a.include_all_static:
        audit = json.loads((a.evidence / 'resource-audit.json').read_text(encoding='utf-8'))
        expected = [dict(prefab=x['path'], bundle=x['bundle']) for x in audit['containers']
                    if '/LevelObjPrefab/' in x['path'] and not x['path'].endswith('/ToolClaw.prefab')]
    if a.exclude_manifest:
        excluded = {x['id'] for x in json.loads(a.exclude_manifest.read_text(encoding='utf-8'))['models']}
        expected = [x for x in expected if Path(x['prefab']).stem not in excluded]
    names = {x['bundle'] for x in expected}
    files = {p.name: p for p in a.cache.rglob('*.bundle') if p.name in names}
    assert names == set(files), 'Required reference bundles missing'
    a.output.mkdir(parents=True, exist_ok=True)
    sources, models, skipped = [], [], []
    for bundle, path in sorted(files.items()):
        # Parse a single immutable in-memory byte snapshot, so cache replacements
        # cannot mix geometry and provenance during a live WeChat update.
        blob = path.read_bytes()
        sources.append({'file': str(path.relative_to(a.cache)), 'bytes': len(blob), 'sha256': hashlib.sha256(blob).hexdigest()})
        env = UnityPy.load(blob)
        for prefab, ptr in sorted(env.container.items()):
            original = next((x for x in expected if x['prefab'] == prefab), None)
            if not original:
                continue
            name = Path(prefab).stem
            def skinned(go):
                components = [(c.component.type.name, c.component) for c in go.m_Component]
                if any(typ == 'SkinnedMeshRenderer' for typ, _ in components):
                    return True
                tr = next((ptr.read() for typ, ptr in components if typ == 'Transform'), None)
                return bool(tr and any(skinned(ch.read().m_GameObject.read()) for ch in tr.m_Children))
            if skinned(ptr.read()):
                skipped.append({'id': name, 'prefab': prefab, 'reason': 'Skinned renderer; authored bone pose not reconstructed'})
                continue
            folder = a.output / 'models' / name
            folder.mkdir(parents=True, exist_ok=True)
            materials, meshes, nodes, colliders = {}, [], [], []

            def material(mp):
                key = str(mp.path_id)
                if key in materials:
                    return key
                m = mp.read()
                textures = {}
                for slot, info in m.m_SavedProperties.m_TexEnvs:
                    if not info.m_Texture.path_id:
                        continue
                    t = info.m_Texture.read()
                    texname = f'tex_{t.object_reader.path_id}.png'
                    t.image.save(folder / texname)
                    textures[slot] = dict(file=texname, name=t.m_Name, width=t.m_Width, height=t.m_Height,
                                          format=int(t.m_TextureFormat), scale=vector(info.m_Scale), offset=vector(info.m_Offset))
                floats = dict(m.m_SavedProperties.m_Floats)
                colors = {k: [v.r, v.g, v.b, v.a] for k, v in m.m_SavedProperties.m_Colors}
                try:
                    shader = getattr(m.m_Shader.read(), 'm_ParsedForm', None)
                    shader_name = shader.m_Name if shader else None
                except Exception:
                    shader_name = None
                materials[key] = dict(name=m.m_Name, shader=shader_name, textures=textures, floats=floats, colors=colors)
                return key

            def walk(go, parent=None, root=False):
                components = [(c.component.type.name, c.component) for c in go.m_Component]
                tr = next(p.read() for typ, p in components if typ == 'Transform')
                index = len(nodes)
                nodes.append(dict(name=go.m_Name, parent=parent,
                                  position=[0, 0, 0] if root else vector(tr.m_LocalPosition),
                                  rotation=vector(tr.m_LocalRotation), scale=vector(tr.m_LocalScale)))
                renderer = next((p.read() for typ, p in components if typ == 'MeshRenderer'), None)
                for typ, cp in components:
                    if typ == 'MeshFilter':
                        assert renderer is not None
                        mesh = cp.read().m_Mesh.read()
                        h = MeshHandler(mesh)
                        h.process()
                        triangles = list(h.get_triangles())
                        mats = [material(m) for m in renderer.m_Materials]
                        meshes.append(dict(name=mesh.m_Name, node=index, positions=h.m_Vertices,
                                           normals=h.m_Normals, uv=h.m_UV0, triangles=triangles, materials=mats))
                    elif typ.endswith('Collider'):
                        tree = cp.read_typetree()
                        colliders.append({'node': index, 'type': typ, 'properties': tree})
                for child in tr.m_Children:
                    walk(child.read().m_GameObject.read(), index)

            walk(ptr.read(), root=True)
            count = sum(len(faces) for m in meshes for faces in m['triangles'])
            if 'triangles' in original:
                assert count == original['triangles'], (name, count, original['triangles'])
            assert meshes, f'No static meshes: {name}'
            assert all(m['uv'] and len(m['positions']) == len(m['uv']) for m in meshes), name
            scene = dict(id=name, prefab=prefab, bundle=bundle, nodes=nodes, meshes=meshes,
                         materials=materials, colliders=colliders, triangles=count,
                         coordinateSystem='Unity left-handed Y-up; root translation removed, scale retained')
            dump(folder / 'source.json', scene)
            models.append(dict(id=name, triangles=count, meshes=len(meshes), materials=len(materials),
                               source=f'models/{name}/source.json', sourceSha256=sha(folder / 'source.json')))

    if a.models_only:
        dump(a.output / 'manifest.json', dict(appId='wxb98ac240fd74b0e3', date='2026-10-23',
             purpose='Local generation/style reference only; not runtime assets', unityPyVersion=UnityPy.__version__,
             sources=sources, models=models, skipped=skipped,
             priorBatch=str(a.exclude_manifest) if a.exclude_manifest else None))
        print(f'Extracted {len(models)} static references, skipped {len(skipped)} skinned prefabs')
        return

    # Parse metadata declaration tables only, with record bounds/version checks.
    metadata_result = {'methodBodiesRecovered': False}
    for webdata in sorted(a.cache.glob('*.bin')):
        blob = webdata.read_bytes()
        if not blob.startswith(b'UnityWebData1.0\0'):
            continue
        end = struct.unpack_from('<I', blob, 16)[0]
        pos, entries = 20, []
        while pos < end:
            offset, size, length = struct.unpack_from('<III', blob, pos)
            pos += 12
            name = blob[pos:pos + length].decode('utf-8')
            pos += length
            assert offset + size <= len(blob)
            entries.append(dict(name=name, bytes=size))
            if name.endswith('global-metadata.dat'):
                md = blob[offset:offset + size]
                magic, version = struct.unpack_from('<II', md)
                assert magic == 0xFAB11BAF and version == 29, ('Unsupported metadata', version)
                so, sl = struct.unpack_from('<II', md, 24)
                strings = md[so:so + sl]

                def string(i):
                    return strings[i:strings.index(b'\0', i)].decode('utf-8', 'replace')

                to, tl = struct.unpack_from('<II', md, 160)
                fo, fl = struct.unpack_from('<II', md, 96)
                mo, ml = struct.unpack_from('<II', md, 48)
                assert tl % 88 == 0 and fl % 12 == 0 and ml % 32 == 0
                wanted = {'LevelManager', 'MainLevelManager', 'LevelObjectPool', 'ObjectPoolMa', 'LevelConfig',
                          'LevelColControl', 'LevelDataHelper', 'ObjectUnit', 'LevelDataData', 'LevelABDataData',
                          'ObjectSelector', 'LevelLoader', 'KFakeRandom`1', 'GameModeType', 'MainLevelRecordData'}
                declarations = []
                for at in range(to, to + tl, 88):
                    v = struct.unpack_from('<16I8H2I', md, at)
                    if string(v[0]) not in wanted:
                        continue
                    fields = []
                    for i in range(v[18]):
                        fn, ft, token = struct.unpack_from('<III', md, fo + (v[8] + i) * 12)
                        fields.append(dict(name=string(fn), typeIndex=ft, token=f'0x{token:08x}'))
                    methods = []
                    for i in range(v[16]):
                        row = struct.unpack_from('<6I4H', md, mo + (v[9] + i) * 32)
                        methods.append(dict(name=string(row[0]), declaringType=row[1], returnTypeIndex=row[2],
                                            token=f'0x{row[5]:08x}', flags=row[6], parameterCount=row[9],
                                            bodyAvailable=False))
                    declarations.append(dict(name=string(v[0]), namespace=string(v[1]), fields=fields, methods=methods))
                dump(a.output / 'algorithm' / 'declarations.json', declarations)
                metadata_result.update(version=version, classes=len(declarations), metadataSha256=hashlib.sha256(md).hexdigest())
        dump(a.output / 'algorithm' / 'webdata-index.json', entries)
        metadata_result.update(webdata=webdata.name, webdataSha256=sha(webdata))
    wasm = []
    for p in a.cache.rglob('*'):
        if p.is_file() and 'wasm' in p.name.lower():
            head = p.read_bytes()[:8]
            wasm.append(dict(file=str(p.relative_to(a.cache)), bytes=p.stat().st_size,
                             header=head.hex(), isRawWasm=head.startswith(b'\0asm'), sha256=sha(p)))
    metadata_result['wasmCandidates'] = wasm
    metadata_result['limitation'] = 'Metadata declarations are not method bodies. Local wasm.br is a one-byte placeholder; no random formula, weight values or DDA recovered.'
    dump(a.output / 'algorithm' / 'recovery.json', metadata_result)
    dump(a.output / 'manifest.json', dict(appId='wxb98ac240fd74b0e3', date='2026-10-22',
         purpose='Local visual reference only; not runtime assets', unityPyVersion=UnityPy.__version__,
         sources=sources, models=models, methodBodiesRecovered=False, skipped=['Goose_Pancake: skinned special item']))
    print(f'Extracted {len(models)} static reference items, declarations={metadata_result.get("classes")}; method bodies unavailable')


if __name__ == '__main__':
    main()
