"""Read selected configuration objects from a frozen local Unity data snapshot."""
import argparse
import hashlib
import json
import sys
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--snapshot', type=Path, required=True)
    ap.add_argument('--dlls', type=Path, required=True)
    ap.add_argument('--deps', type=Path, required=True)
    ap.add_argument('--generator-deps', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    ap.add_argument('--class', dest='classes', action='append', required=True)
    args = ap.parse_args()
    sys.path[:0] = [str(args.generator_deps.resolve()), str(args.deps.resolve())]
    import UnityPy
    from UnityPy.helpers.TypeTreeGenerator import TypeTreeGenerator
    from UnityPy.helpers import TypeTreeHelper
    env = UnityPy.load(str(args.snapshot.resolve()))
    gen = TypeTreeGenerator(env.objects[0].assets_file.unity_version)
    gen.load_local_dll_folder(str(args.dlls.resolve()))
    args.output.mkdir(parents=True, exist_ok=True)
    rows = []
    for obj in env.objects:
        if obj.type.name != 'MonoBehaviour':
            continue
        head = obj.parse_monobehaviour_head()
        try:
            script = head.m_Script.read()
        except Exception:
            continue
        if script.m_ClassName not in args.classes:
            continue
        identity = dict(cls=script.m_ClassName, name=head.m_Name, pathId=obj.path_id, file=obj.assets_file.name)
        try:
            fullname = (script.m_Namespace + '.' if script.m_Namespace else '') + script.m_ClassName
            node = gen.get_nodes_up(script.m_AssemblyName, fullname)
            next(child for child in node.m_Children if child.m_Name == 'm_Enabled').m_MetaFlag |= 0x4000
            boost = TypeTreeHelper.read_typetree_boost
            TypeTreeHelper.read_typetree_boost = None
            try:
                tree = obj.read_typetree(nodes=node)
            finally:
                TypeTreeHelper.read_typetree_boost = boost
            assert tree['m_Script'] == {'m_FileID': head.m_Script.file_id, 'm_PathID': head.m_Script.path_id}
            name = f'{script.m_ClassName}-{obj.path_id}'
            (args.output / (name + '.json')).write_text(json.dumps(tree, ensure_ascii=True, indent=2), encoding='utf-8')
            raw = obj.get_raw_data()
            (args.output / (name + '.bin')).write_bytes(raw)
            identity.update(passed=True, bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
        except Exception as ex:
            identity.update(passed=False, error=str(ex))
        rows.append(identity)
        print(json.dumps(identity, ensure_ascii=True))
    (args.output / 'index.json').write_text(json.dumps(rows, ensure_ascii=True, indent=2), encoding='utf-8')


if __name__ == '__main__':
    main()
