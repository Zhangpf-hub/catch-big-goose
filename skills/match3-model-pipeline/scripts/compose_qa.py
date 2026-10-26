"""Compose review sheets and measure icon clipping using Pillow (ordinary Python)."""
import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

parser = argparse.ArgumentParser()
parser.add_argument('--candidate', type=Path, required=True)
parser.add_argument('--project', type=Path, required=True)
args = parser.parse_args()
root = args.candidate.resolve()
ids = [item['id'] for item in json.loads((root / 'qa/generation.json').read_text(encoding='utf-8'))]
rows = (len(ids) + 4) // 5
font_path = Path('C:/Windows/Fonts/segoeui.ttf')
font = ImageFont.truetype(str(font_path), 24) if font_path.exists() else ImageFont.load_default()
small = ImageFont.truetype(str(font_path), 18) if font_path.exists() else font
title = ImageFont.truetype(str(font_path), 36) if font_path.exists() else font


def tile(canvas, path, x, y, size):
    image = Image.open(path).convert('RGBA')
    image.thumbnail((size, size), Image.Resampling.LANCZOS)
    canvas.paste(image, (x + (size - image.width) // 2, y + (size - image.height) // 2), image)


hero = Image.new('RGB', (1600, 140 + rows * 460), '#edf2f7')
draw = ImageDraw.Draw(hero)
draw.text((35, 22), 'ELECTRONICS / MATCH-3 QUALITY REVIEW', font=title, fill='#142b43')
draw.text((35, 76), 'Original geometry | GLB / Y-up | one atlas material per item | Blender 4.5 LTS', font=small, fill='#536b81')
for i, name in enumerate(ids):
    x, dy = i % 5 * 320, i // 5 * 460
    draw.rounded_rectangle((x + 12, 125 + dy, x + 308, 565 + dy), radius=18, fill='white')
    tile(hero, root / 'qa' / f'{name}-hero.png', x + 25, 142 + dy, 270)
    draw.text((x + 30, 418 + dy), name.upper(), font=font, fill='#142b43')
    metrics = json.loads((root / 'qa' / f'{name}.metrics.json').read_text())
    draw.text((x + 30, 453 + dy), f"{metrics['triangles']:,} tris / {metrics['bytes'] / 1024:.1f} KiB", font=small, fill='#536b81')
    tile(hero, root / 'icons' / f'{name}.png', x + 30, 492 + dy, 64)
    draw.text((x + 108, 511 + dy), '64px check', font=small, fill='#536b81')
hero.save(root / 'qa' / ('quality-contact-sheet.png' if len(ids) > 5 else 'contact-sheet.png'))

views = ['hero', 'top', 'front', 'back']
sheet = Image.new('RGB', (1320, 90 + len(ids) * 226), '#edf2f7')
draw = ImageDraw.Draw(sheet)
draw.text((25, 18), 'EXPORTED GLB / FOUR-VIEW ROUNDTRIP REVIEW', font=font, fill='#142b43')
for row, name in enumerate(ids):
    draw.text((20, 88 + row * 226), name, font=small, fill='#142b43')
    for col, view in enumerate(views):
        x, y = 125 + col * 295, 70 + row * 226
        draw.rounded_rectangle((x, y, x + 277, y + 211), radius=12, fill='white')
        tile(sheet, root / 'qa' / f'{name}-{view}.png', x + 42, y + 3, 190)
        draw.text((x + 10, y + 183), view, font=small, fill='#536b81')
sheet.save(root / 'qa' / 'four-view-sheet.png')

comparison = Image.new('RGB', (1200, 80 + (rows + 1) * 240), '#edf2f7')
draw = ImageDraw.Draw(comparison)
draw.text((25, 15), 'EXISTING ASSETS / NEW ELECTRONICS - ICON SCALE CHECK', font=font, fill='#142b43')
for row, names in enumerate([['apple', 'banana', 'carrot', 'donut', 'hulu']] + [ids[i:i+5] for i in range(0, len(ids), 5)]):
    for col, name in enumerate(names):
        path = args.project / 'reference-projects/catch-big-goose-cocos/assets/resources/icons' / f'{name}.png' if row == 0 else root / 'icons' / f'{name}.png'
        tile(comparison, path, col * 240 + 35, 70 + row * 240, 170)
        draw.text((col * 240 + 45, 245 + row * 240), name, font=small, fill='#142b43')
comparison.save(root / 'qa' / 'reference-comparison.png')

underside = Image.new('RGB', (1600, 60 + rows * 340), '#edf2f7')
draw = ImageDraw.Draw(underside)
draw.text((25, 15), 'UNDERSIDE REVIEW / REAR CAMERA AND CLOSED SHELLS', font=font, fill='#142b43')
for index, name in enumerate(ids):
    col, dy = index % 5, index // 5 * 340
    tile(underside, root / 'qa' / f'{name}-bottom.png', col * 320 + 30, 60 + dy, 260)
    draw.text((col * 320 + 45, 340 + dy), name, font=small, fill='#142b43')
underside.save(root / 'qa' / 'underside-sheet.png')

reports = []
for name in ids:
    path = root / 'icons' / f'{name}.png'
    image = Image.open(path)
    assert image.size == (192, 192) and image.mode == 'RGBA'
    alpha = image.getchannel('A')
    bounds = alpha.getbbox()
    assert bounds and min(bounds[0], bounds[1], 192 - bounds[2], 192 - bounds[3]) >= 6, (name, bounds)
    assert bounds[2] - bounds[0] >= 70 and bounds[3] - bounds[1] >= 70, (name, bounds)
    thumb = image.resize((64, 64), Image.Resampling.LANCZOS)
    thumb.save(root / 'qa' / f'{name}-64.png')
    reports.append(dict(id=name, size=[192, 192], alphaBounds=bounds,
                        transparentMarginPassed=True, thumbnailSize=[64, 64]))
(root / 'qa' / 'icon-audit.json').write_text(json.dumps(reports, indent=2), encoding='utf-8')
print('PASS: contact sheets, four views, existing-asset comparison, transparent margins and 64px thumbnails')
