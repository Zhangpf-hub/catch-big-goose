"""Recover selection evidence from the frozen 402 snapshot; never edit its inputs."""
import dataclasses
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'competitor-analysis/artifacts/selection-highlight-20261025'
sys.path[:0] = [str(ROOT / 'competitor-analysis/artifacts/competitor-tools/type-tree-deps'),
    'C:/Users/123/.codex/visualizations/2026/10/21/01a15f1e-af66-7022-bd6a-105254709b3b/competitor-goose/deps']
import UnityPy
import attrs
from UnityPy.helpers import CompressionHelper, TypeTreeHelper
from UnityPy.helpers.TypeTreeGenerator import TypeTreeGenerator


def sha(data):
    return hashlib.sha256(data).hexdigest()


def plain(value):
    if attrs.has(type(value)):
        return {k: plain(v) for k, v in attrs.asdict(value, recurse=False).items() if k != 'object_reader'}
    if dataclasses.is_dataclass(value):
        return {k: plain(v) for k, v in dataclasses.asdict(value).items()}
    if isinstance(value, dict):
        return {k: plain(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [plain(v) for v in value]
    if hasattr(value, '__dict__'):
        return {k: plain(v) for k, v in vars(value).items() if k != 'object_reader'}
    return value


def save(name, data):
    target = OUT / name
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(data, ensure_ascii=False, indent=2, default=str), encoding='utf-8')


def main():
    source = ROOT / 'competitor-analysis/artifacts/competitor-config-trace/source/6f7a2014e3c0092b.webgl.data.unityweb.bin'
    env = UnityPy.load(str(source))
    gen = TypeTreeGenerator(env.objects[0].assets_file.unity_version)
    gen.load_local_dll_folder(str(ROOT / 'competitor-analysis/artifacts/competitor-config-trace/dumper/DummyDll'))
    report = dict(source=str(source.relative_to(ROOT)), sha256=sha(source.read_bytes()),
                  scope='Frozen serialized configuration and compiled programs, not live online state.', objects=[], shaders=[], failures=[])
    for obj in env.objects:
        if obj.assets_file.name == 'sharedassets0.assets' and obj.path_id in {893, 900, 863}:
            head = obj.parse_monobehaviour_head()
            script = head.m_Script.read()
            fullname = (script.m_Namespace + '.' if script.m_Namespace else '') + script.m_ClassName
            layout = gen.get_nodes_up(script.m_AssemblyName, fullname)
            # Match Unity's aligned built-in header and enforce full byte consumption.
            enabled = next((c for c in layout.m_Children if c.m_Name == 'm_Enabled'), None)
            if enabled is not None:
                enabled.m_MetaFlag |= 0x4000
            boost = TypeTreeHelper.read_typetree_boost
            TypeTreeHelper.read_typetree_boost = None
            try:
                tree = obj.read_typetree(nodes=layout)
            finally:
                TypeTreeHelper.read_typetree_boost = boost
            assert tree['m_Script'] == {'m_FileID': head.m_Script.file_id, 'm_PathID': head.m_Script.path_id}
            save(f'config/{script.m_ClassName}-{obj.path_id}.json', tree)
            report['objects'].append(dict(pathId=obj.path_id, type=fullname, rawSha256=sha(obj.get_raw_data()), strictByteCount=True, headerMatches=True))
        if obj.type.name != 'Shader':
            continue
        try:
            shader = obj.read()
            name = shader.m_ParsedForm.m_Name
            if not name.startswith('HighlightPlus/'):
                continue
            folder = OUT / 'shaders' / name.replace('/', '-')
            folder.mkdir(parents=True, exist_ok=True)
            assert folder.resolve().is_relative_to(OUT.resolve())
            for previous in folder.glob('platform-*-program-*.glsl'):
                previous.unlink()  # Only this generator's outputs, never frozen inputs.
            save(str(folder.relative_to(OUT) / 'parsed-form.json'), plain(shader.m_ParsedForm))
            (folder / 'shader-structure.txt').write_text(shader.export(), encoding='utf-8')
            record = dict(name=name, assetsFile=obj.assets_file.name, pathId=obj.path_id, rawSha256=sha(obj.get_raw_data()), programs=[])
            for platform_index, platform in enumerate(shader.platforms):
                offsets = shader.offsets[platform_index]
                lengths = shader.compressedLengths[platform_index]
                decoded = shader.decompressedLengths[platform_index]
                if not isinstance(offsets, list):
                    offsets, lengths, decoded = [offsets], [lengths], [decoded]
                segments = []
                for offset, length, size in zip(offsets, lengths, decoded):
                    segments.append(CompressionHelper.decompress_lz4(bytes(shader.compressedBlob)[offset:offset+length], size))
                blob = b''.join(segments)
                (folder / f'platform-{platform}.bin').write_bytes(blob)
                # This player stores multiple program records in a segment. UnityPy's
                # generic exporter omits them from parsed-form output. Keep raw bytes
                # and extract the complete paired GLSL stages with their byte offsets.
                programs = re.finditer(rb'#ifdef VERTEX.*?#ifdef FRAGMENT.*?\n}\s*\n#endif', blob, re.S)
                for i, match in enumerate(programs):
                    code = match.group()
                    filename = f'platform-{platform}-program-{i}.glsl'
                    (folder / filename).write_bytes(code)
                    record['programs'].append(dict(file=filename, decompressedOffset=match.start(), platform=int(platform),
                        sha256=sha(code), bytes=len(code), vertexCode=b'gl_Position' in code, fragmentCode=b'void main' in code))
            report['shaders'].append(record)
        except Exception as ex:
            report['failures'].append(dict(assetsFile=obj.assets_file.name, pathId=obj.path_id, error=repr(ex)))
    save('manifest.json', report)
    print(json.dumps(dict(objects=len(report['objects']), shaders=len(report['shaders']), programs=sum(len(s['programs']) for s in report['shaders']), failures=report['failures']), ensure_ascii=False))


if __name__ == '__main__':
    main()
