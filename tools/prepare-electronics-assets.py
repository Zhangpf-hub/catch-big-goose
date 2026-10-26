"""Promote the validated nine-model theme and package locally generated artwork."""
import json
import shutil
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
BATCH = ROOT / 'source-assets/models/candidates/electronics-v2'
MODELS = ROOT / 'reference-projects/catch-big-goose-cocos/assets/resources/models'
ICONS = ROOT / 'reference-projects/catch-big-goose-cocos/assets/resources/icons'
audit = json.loads((BATCH / 'qa/asset-audit.json').read_text(encoding='utf-8'))
assert len(audit['models']) == 9 and all(m['validatorErrors'] == 0 for m in audit['models'])
for model_id in [m['id'] for m in audit['models']] + ['tray_electronics']:
    destinations = [('.glb', MODELS)] + ([] if model_id.startswith('tray_') else [('.png', ICONS)])
    for suffix, destination in destinations:
        source_dir = 'models' if suffix == '.glb' else 'icons'
        source, target = BATCH / source_dir / (model_id + suffix), destination / (model_id + suffix)
        pool = ROOT / 'reference-projects/catch-big-goose-cocos/assets/models-pool/electronics'
        old = pool / (model_id + suffix) if suffix == '.glb' else pool / 'icons' / (model_id + suffix)
        # Preserve the UUID of the first pilot on promotion; never copy another asset's metadata.
        if old.exists():
            assert not target.exists(), f'Unexpected existing active resource: {target}'
            old.replace(target)
            meta = Path(str(old) + '.meta')
            if meta.exists():
                meta.replace(Path(str(target) + '.meta'))
        shutil.copy2(source, target)
        if suffix == '.png':
            with Image.open(target) as image:
                image.convert('RGBA').quantize(colors=256, method=Image.Quantize.FASTOCTREE).save(target, optimize=True)

source = Path('C:/Users/123/.codex/generated_images/01a15ee5-dea9-76b2-917c-bc8251d360fc/exec-b10b271d-f44c-4671-887d-25a83f364ed5.png')
archive = ROOT / 'source-assets/models/electronics'
archive.mkdir(parents=True, exist_ok=True)
shutil.copy2(source, archive / 'background-source.png')
with Image.open(source) as image:
    image.convert('RGB').resize((720, 1280), Image.Resampling.LANCZOS).save(
        ROOT / 'reference-projects/catch-big-goose-cocos/assets/resources/textures/bg_electronics.jpg', quality=78, optimize=True)

badge = Image.new('RGBA', (256, 256), (0, 0, 0, 0))
draw = ImageDraw.Draw(badge)
draw.ellipse((4, 4, 252, 252), fill='#BFE4DE', outline='#F8F2DB', width=7)
draw.ellipse((17, 17, 239, 239), fill='#D9F0E9', outline='#65AFAF', width=3)
for mid, x, y, scale in [('headphones', 98, 20, 150), ('phone', 10, 95, 150), ('camera', 110, 106, 130)]:
    item = Image.open(BATCH / 'qa' / f'{mid}-hero.png').convert('RGBA')
    item.thumbnail((scale, scale), Image.Resampling.LANCZOS)
    badge.alpha_composite(item, (x, y))
mask = Image.new('L', (256, 256), 0)
ImageDraw.Draw(mask).ellipse((3, 3, 253, 253), fill=255)
badge.putalpha(Image.composite(badge.getchannel('A'), Image.new('L', badge.size, 0), mask))
badge.save(ROOT / 'reference-projects/catch-big-goose-cocos/assets/resources/textures/challenge-ui/station-medallion-electronics.png')

ids = ['phone', 'laptop', 'camera', 'headphones', 'handheld', 'speaker', 'mouse', 'smartwatch', 'radio']
sheet = Image.new('RGB', (1200, 1250), '#ECF3F5')
draw = ImageDraw.Draw(sheet)
font = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 25)
title = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 34)
draw.text((30, 18), 'DIGITAL WORKSHOP / NINE MATCH-3 ITEMS', font=title, fill='#18324B')
for index, mid in enumerate(ids):
    x, y = index % 3 * 400, 85 + index // 3 * 380
    draw.rounded_rectangle((x + 12, y, x + 388, y + 360), radius=15, fill='white')
    item = Image.open(BATCH / 'qa' / f'{mid}-hero.png').convert('RGBA')
    item.thumbnail((300, 285), Image.Resampling.LANCZOS)
    sheet.paste(item, (x + 50, y + 10), item)
    draw.text((x + 30, y + 307), mid.upper(), font=font, fill='#18324B')
sheet.save(BATCH / 'qa/contact-sheet.png')
print('PROMOTED: nine products, work tray, background and station medallion')
