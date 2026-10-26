"""Read a frozen WebGL data snapshot. Never write to the game's cache.

Flat table schemas come from the supplied IL2CPP declaration dump, not guessed
offsets. Every decoded table must consume all bytes and re-encode identically.
The LevelManager layout is generated from metadata-only dummy assemblies.
"""
import argparse
import hashlib
import json
import re
import struct
import sys
from pathlib import Path


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def dump(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    # Preserve even invalid source UTF-8 via surrogateescape and JSON escapes.
    path.write_text(json.dumps(data, ensure_ascii=True, indent=2) + '\n', encoding='utf-8')


class Cursor:
    def __init__(self, raw, start):
        self.raw, self.at = raw, start
        self.rebuilt = bytearray(raw[:start])

    def take(self, count):
        if count < 0 or self.at + count > len(self.raw):
            raise ValueError(f'Out of bounds at {self.at}, requested {count}')
        value = self.raw[self.at:self.at + count]
        self.at += count
        return value

    def scalar(self, kind):
        if kind == 'string':
            size = struct.unpack('<i', self.take(4))[0]
            if not 0 <= size <= len(self.raw):
                raise ValueError(f'Invalid string length: {size}')
            text = self.take(size).decode('utf-8', 'surrogateescape')
            padding = self.take((-self.at) % 4)
            encoded = text.encode('utf-8', 'surrogateescape')
            self.rebuilt += struct.pack('<i', len(encoded)) + encoded + padding
            return text
        formats = {'int': 'i', 'float': 'f', 'bool': '?'}
        fmt = formats[kind]
        value = struct.unpack('<' + fmt, self.take(struct.calcsize(fmt)))[0]
        self.rebuilt += struct.pack('<' + fmt, value)
        if kind == 'bool':
            self.rebuilt += self.take((-self.at) % 4)
        return value

    def value(self, kind):
        if not kind.endswith('[]'):
            return self.scalar(kind)
        size = self.scalar('int')
        if not 0 <= size <= 100000:
            raise ValueError(f'Invalid array length: {size}')
        return [self.scalar(kind[:-2]) for _ in range(size)]


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--snapshot', type=Path, required=True)
    ap.add_argument('--dump', type=Path, required=True)
    ap.add_argument('--dlls', type=Path, required=True)
    ap.add_argument('--deps', type=Path, required=True)
    ap.add_argument('--generator-deps', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()
    sys.path[:0] = [str(args.generator_deps.resolve()), str(args.deps.resolve())]
    import UnityPy
    from UnityPy.helpers.TypeTreeGenerator import TypeTreeGenerator
    from UnityPy.helpers import TypeTreeHelper

    declaration = args.dump.read_text(encoding='utf-8-sig')
    blocks = dict(re.findall(r'^public class (\w+)[^\n]*\n\{(.*?)^\}', declaration, re.M | re.S))
    env = UnityPy.load(str(args.snapshot.resolve()))
    version = env.objects[0].assets_file.unity_version
    generator = TypeTreeGenerator(version)
    generator.load_local_dll_folder(str(args.dlls.resolve()))
    env.typetree_generator = generator
    args.output.mkdir(parents=True, exist_ok=True)
    index, failures = [], []
    for obj in env.objects:
        if obj.type.name != 'MonoBehaviour':
            continue
        head = obj.parse_monobehaviour_head()
        try:
            script = head.m_Script.read()
        except Exception:
            continue
        cls = script.m_ClassName
        block = blocks.get(cls, '')
        match = re.search(r'public (\w+)\[\] dataArray;', block)
        if cls != 'LevelManager' and not match:
            continue
        raw = obj.get_raw_data()
        identity = {'class': cls, 'name': head.m_Name, 'pathId': obj.path_id,
                    'assetsFile': obj.assets_file.name, 'bytes': len(raw), 'rawSha256': sha(raw)}
        try:
            if cls == 'LevelManager':
                layout = generator.get_nodes_up(script.m_AssemblyName, cls)
                # Generator 0.0.10 omits alignment on the built-in UInt8 header.
                # Match UnityPy's native MonoBehaviour header before trusting fields.
                next(child for child in layout.m_Children if child.m_Name == 'm_Enabled').m_MetaFlag |= 0x4000
                # Boost 1.25.4 does not honor this modified primitive alignment;
                # the Python reference reader does. Check the native header below.
                boost = TypeTreeHelper.read_typetree_boost
                TypeTreeHelper.read_typetree_boost = None
                try:
                    tree = obj.read_typetree(nodes=layout)  # strict byte-count check remains enabled
                finally:
                    TypeTreeHelper.read_typetree_boost = boost
                if tree['m_Script'] != {'m_FileID': head.m_Script.file_id, 'm_PathID': head.m_Script.path_id}:
                    raise ValueError('Generated/native MonoBehaviour headers disagree')
                dump(args.output / f'{cls}.json', tree)
                (args.output / f'{cls}-layout.txt').write_text(layout.dump_structure(), encoding='utf-8')
                identity.update(decoder='Generated type tree; strict byte consumption; native header alignment fixed', rows=1, baseHeaderMatches=True)
            else:
                row_cls = match[1]
                fields_block = blocks[row_cls].split('// Properties')[0].split('// Methods')[0]
                fields = re.findall(r'(?:private|public) (int|float|string|bool)(\[\])? (\w+);', fields_block)
                schema = [(name, kind + suffix) for kind, suffix, name in fields]
                if not schema:
                    raise ValueError(f'No flat schema found for {row_cls}')
                start = (32 + struct.unpack_from('<i', raw, 28)[0] + 3) & ~3
                reader = Cursor(raw, start)
                sheet = reader.scalar('string')
                worksheet = reader.scalar('string')
                count = reader.scalar('int')
                if not 0 <= count <= 100000:
                    raise ValueError(f'Invalid table size: {count}')
                rows = []
                for _ in range(count):
                    rows.append({name: reader.value(kind) for name, kind in schema})
                if reader.at != len(raw) or bytes(reader.rebuilt) != raw:
                    raise ValueError(f'Byte verification failed: {reader.at}/{len(raw)}')
                dump(args.output / f'{cls}.json', {'SheetName': sheet, 'WorksheetName': worksheet, 'dataArray': rows})
                dump(args.output / f'{cls}-schema.json', {'rowClass': row_cls, 'fields': schema})
                identity.update(decoder='Flat declaration schema', rows=count, bytesConsumed=reader.at, byteExactRoundTrip=True)
            (args.output / 'raw').mkdir(exist_ok=True)
            (args.output / 'raw' / f'{cls}-{obj.path_id}.bin').write_bytes(raw)
            index.append(identity)
            print(cls, identity['rows'], identity['bytes'])
        except Exception as ex:
            failures.append(dict(identity, error=f'{type(ex).__name__}: {ex}'))
    dump(args.output / 'index.json', {
        'unityVersion': version, 'unityPyVersion': UnityPy.__version__,
        'snapshot': str(args.snapshot), 'snapshotSha256': sha(args.snapshot.read_bytes()),
        'declarationSha256': sha(args.dump.read_bytes()), 'objects': index, 'failures': failures,
        'scope': 'Serialized local assets, not runtime values after network or mode overrides.'
    })
    print('Tables/configs:', len(index), 'excluded:', len(failures))


if __name__ == '__main__':
    main()
