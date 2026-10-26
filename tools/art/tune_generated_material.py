#!/usr/bin/env python3
"""在 glTF JSON 层收敛第三方生成件的材质参数。

为什么必须在 JSON 层做、而不是在 Blender 里做：
Blender 的 glTF 导入器把 KHR_materials_specular 存进材质的自定义属性，导出时原样写回；
metallicRoughness 贴图同理，光在节点树里断开链接是删不掉的。实测走 Blender 后
`specularColorFactor: [2,2,2]` 与 metallicRoughnessTexture 依旧留在产物里。

这三项在本作的弱环境光下都是负担：
  1. specularColorFactor 常被生成服务拉到 2.0，镜面压过漫反射 → 整件发暗发灰；
  2. metallicRoughness 贴图给本该哑光的部件带上金属度 → 同样发暗，且白占一张贴图；
  3. doubleSided=true 让不透明道具的 overdraw 翻倍。

铜钱 v2 踩过同一个坑（Blender 审计图清楚、游戏里发黑），结论是降金属度、提暖漫反射。
处理完记得跑 `gltf-transform prune` 清掉失去引用的贴图。

用法：
  python3 tools/art/tune_generated_material.py <输入.glb> <输出.glb> [--roughness 0.55]
"""

import argparse
import json
import struct


def read_glb(path: str) -> tuple[dict, bytes]:
    data = open(path, "rb").read()
    if data[:4] != b"glTF":
        raise SystemExit(f"{path} 不是 GLB")
    offset = 12
    doc: dict | None = None
    binary = b""
    while offset < len(data):
        length, kind = struct.unpack("<I4s", data[offset:offset + 8])
        chunk = data[offset + 8:offset + 8 + length]
        if kind == b"JSON":
            doc = json.loads(chunk.decode("utf-8"))
        elif kind == b"BIN\x00":
            binary = chunk
        offset += 8 + length
    if doc is None:
        raise SystemExit("GLB 缺少 JSON chunk")
    return doc, binary


def write_glb(path: str, doc: dict, binary: bytes) -> None:
    raw = json.dumps(doc, separators=(",", ":")).encode("utf-8")
    raw += b" " * (-len(raw) % 4)
    blob = binary + b"\x00" * (-len(binary) % 4)
    total = 12 + 8 + len(raw) + (8 + len(blob) if blob else 0)
    out = bytearray()
    out += struct.pack("<4sII", b"glTF", 2, total)
    out += struct.pack("<I4s", len(raw), b"JSON") + raw
    if blob:
        out += struct.pack("<I4s", len(blob), b"BIN\x00") + blob
    open(path, "wb").write(bytes(out))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("--roughness", type=float, default=0.55)
    parser.add_argument("--metallic", type=float, default=0.0)
    parser.add_argument("--keep-double-sided", action="store_true")
    args = parser.parse_args()

    doc, binary = read_glb(args.input)
    for index, material in enumerate(doc.get("materials", [])):
        pbr = material.setdefault("pbrMetallicRoughness", {})
        dropped = pbr.pop("metallicRoughnessTexture", None)
        pbr["metallicFactor"] = args.metallic
        pbr["roughnessFactor"] = args.roughness
        extensions = material.get("extensions", {})
        specular = extensions.pop("KHR_materials_specular", None)
        if not extensions:
            material.pop("extensions", None)
        if not args.keep_double_sided:
            material["doubleSided"] = False
        print(f"material[{index}] {material.get('name')}: "
              f"mrTexture={'dropped' if dropped else 'none'} "
              f"specular={'dropped' if specular else 'none'} "
              f"metallic={args.metallic} roughness={args.roughness}")

    used = [e for e in doc.get("extensionsUsed", []) if e != "KHR_materials_specular"]
    if used:
        doc["extensionsUsed"] = used
    else:
        doc.pop("extensionsUsed", None)

    write_glb(args.output, doc, binary)
    print(f"WROTE {args.output}")


if __name__ == "__main__":
    main()
