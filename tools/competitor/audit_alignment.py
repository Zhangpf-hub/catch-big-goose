"""Compare the project's own GLBs with the observed competitor sample; make contact sheets."""
import argparse
import csv
import json
import statistics
import struct
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


def glb(path):
    b = path.read_bytes()
    assert b[:4] == b'glTF'
    n = struct.unpack_from('<I', b, 12)[0]
    d = json.loads(b[20:20+n])
    active_nodes = []
    def visit(index):
        node = d['nodes'][index]
        active_nodes.append(node)
        for child in node.get('children', []):
            visit(child)
    for index in d['scenes'][d.get('scene', 0)]['nodes']:
        visit(index)
    meshes = [d['meshes'][node['mesh']] for node in active_nodes if 'mesh' in node]
    tris = sum(d['accessors'][p['indices']]['count'] // 3 for m in meshes for p in m['primitives'])
    textures = []
    for image in d.get('images', []):
        if 'bufferView' not in image:
            continue
        view = d['bufferViews'][image['bufferView']]
        offset = 20 + n + 8 + view.get('byteOffset', 0)
        import io
        im = Image.open(io.BytesIO(b[offset:offset+view['byteLength']]))
        textures.append(list(im.size))
    return dict(id=path.stem, triangles=tris, meshes=len(meshes), materials=len(d.get('materials', [])),
                primitives=sum(len(m['primitives']) for m in meshes), textures=textures,
                bytes=len(b), exceedsObservedTriangles=tris > 1382, exceedsNewTarget=tris > 1500,
                exceedsTexture512=any(max(x) > 512 for x in textures))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--project', type=Path, required=True)
    ap.add_argument('--reference', type=Path, required=True)
    a = ap.parse_args()
    manifest = json.loads((a.reference / 'manifest.json').read_text(encoding='utf-8'))
    rows = [glb(p) for p in sorted((a.project / 'projects/catch-big-goose-unity/SourceAssets/Models').glob('*.glb'))]
    themes = json.loads((a.project / 'projects/catch-big-goose-unity/Assets/Resources/Data/themes.json').read_text(encoding='utf-8'))['themes']
    ordinary = {id for t in themes for id in t['items']}
    containers = {t['container'] for t in themes}
    for row in rows:
        row['category'] = 'ordinary' if row['id'] in ordinary else 'container' if row['id'] in containers else 'special'
    sample = [r for r in rows if r['category'] == 'ordinary']
    report = dict(date='2026-10-22', currentEngine='Unity migration (runtime acceptance tracked separately)',
                  competitor=dict(ordinarySamples=17, trianglesMin=220, trianglesMax=1382, trianglesMedian=760),
                  own=dict(ordinaryModels=len(sample), trianglesMedian=statistics.median(r['triangles'] for r in sample),
                           overObservedMax=sum(r['exceedsObservedTriangles'] for r in sample),
                           over1500=sum(r['exceedsNewTarget'] for r in sample),
                           texturesOver512=sum(r['exceedsTexture512'] for r in sample)), models=rows)
    (a.reference / 'project-audit.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    with (a.reference / 'project-audit.csv').open('w', encoding='utf-8-sig', newline='') as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    fontpath = 'C:/Windows/Fonts/msyh.ttc'
    font = ImageFont.truetype(fontpath, 21)
    small = ImageFont.truetype(fontpath, 16)
    title = ImageFont.truetype(fontpath, 30)
    for view in ['three-quarter', 'top']:
        sheet = Image.new('RGB', (1400, 100 + 4 * 300 + 58), '#f4efe5')
        draw = ImageDraw.Draw(sheet)
        draw.text((28, 18), '抓大鹅 · 烧烤模型风格参考 / ' + ('三分之四视角' if view == 'three-quarter' else '俯视'), fill='#243744', font=title)
        draw.text((28, 64), '竞品本地缓存提取 · 颜色贴图 + 中性灯光预览 · 未重现原 Toon / MatCap 着色', fill='#56626a', font=small)
        for i, model in enumerate(manifest['models']):
            x, y = (i % 5) * 280, 100 + (i // 5) * 300
            draw.rounded_rectangle((x+8, y+4, x+272, y+294), radius=15, fill='white')
            im = Image.open(a.reference / 'models' / model['id'] / (view + '.png')).convert('RGBA')
            im.thumbnail((236, 236))
            sheet.paste(im, (x + (280-im.width)//2, y+5), im)
            draw.text((x+18, y+239), model['id'], fill='#243744', font=font)
            draw.text((x+18, y+268), f"源网格 {model['triangles']} 三角形 / {model['materials']} 材质", fill='#56626a', font=small)
        draw.text((28, sheet.height-43), '仅作本地研究与风格参考；原始索引、贴图、哈希与清理记录见 manifest / export-verification。', fill='#56626a', font=small)
        sheet.save(a.reference / ('contact-sheet-' + view + '.jpg'), quality=93)
    print(json.dumps(report['own'], ensure_ascii=False))


if __name__ == '__main__':
    main()
