"""Read animation objects from the frozen 402 player with strict typed layouts."""
import json
import hashlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT / 'work/competitor-tools/type-tree-deps'),
    'C:/Users/123/.codex/visualizations/2026/10/21/01a15f1e-af66-7022-bd6a-105254709b3b/competitor-goose/deps']
import UnityPy
from UnityPy.helpers.TypeTreeGenerator import TypeTreeGenerator
from UnityPy.helpers import TypeTreeHelper

env = UnityPy.load(str(ROOT / 'work/competitor-config-trace/source/6f7a2014e3c0092b.webgl.data.unityweb.bin'))
gen = TypeTreeGenerator(env.objects[0].assets_file.unity_version)
gen.load_local_dll_folder(str(ROOT / 'work/competitor-config-trace/dumper/DummyDll'))
out = ROOT / 'work/interaction-20261024/serialized'
out.mkdir(parents=True, exist_ok=True)
index = []
for obj in env.objects:
    if obj.type.name != 'MonoBehaviour':
        continue
    head = obj.parse_monobehaviour_head()
    try:
        script = head.m_Script.read()
    except Exception:
        continue
    if script.m_ClassName not in {'LevelObjAnimManager', 'ObjAnimConfig'}:
        continue
    nodes = gen.get_nodes_up(script.m_AssemblyName, script.m_ClassName)
    next(c for c in nodes.m_Children if c.m_Name == 'm_Enabled').m_MetaFlag |= 0x4000
    boost = TypeTreeHelper.read_typetree_boost
    TypeTreeHelper.read_typetree_boost = None
    try:
        tree = obj.read_typetree(nodes=nodes)
    finally:
        TypeTreeHelper.read_typetree_boost = boost
    assert tree['m_Script'] == {'m_FileID': head.m_Script.file_id, 'm_PathID': head.m_Script.path_id}
    name = f'{script.m_ClassName}-{obj.path_id}.json'
    (out / name).write_text(json.dumps(tree, ensure_ascii=False, indent=2), encoding='utf-8')
    raw = obj.get_raw_data()
    index.append(dict(file=name, pathId=obj.path_id, assetsFile=obj.assets_file.name,
                      bytes=len(raw), rawSha256=hashlib.sha256(raw).hexdigest(), strictByteCount=True))
(out / 'index.json').write_text(json.dumps(index, indent=2), encoding='utf-8')
print(json.dumps(index))
