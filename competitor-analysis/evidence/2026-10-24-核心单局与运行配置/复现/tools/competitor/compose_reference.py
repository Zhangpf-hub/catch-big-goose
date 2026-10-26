"""Arrange already-rendered reference views; no asset geometry or textures are edited."""
import argparse
import json
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('folder', type=Path)
    args = parser.parse_args()
    models = json.loads((args.folder / 'manifest.json').read_text(encoding='utf-8'))['models']
    font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 16)
    title = ImageFont.truetype('C:/Windows/Fonts/msyh.ttc', 24)
    sheet = Image.new('RGB', (1200, 60 + math.ceil(len(models) / 6) * 225), '#ece7df')
    draw = ImageDraw.Draw(sheet)
    draw.text((18, 14), f'竞品静态参考 · 新增 {len(models)} 件 · 原贴图 / 中性灯光', font=title, fill='#283b43')
    for i, model in enumerate(models):
        x, y = i % 6 * 200, 60 + i // 6 * 225
        with Image.open(args.folder / 'models' / model['id'] / 'three-quarter.png') as view:
            view = view.convert('RGBA').resize((200, 200), Image.Resampling.LANCZOS)
            sheet.paste(view, (x, y), view)
        draw.text((x + 5, y + 201), model['id'], font=font, fill='#283b43')
    sheet.save(args.folder / 'contact-sheet.jpg', quality=94)
    for start in range(0, len(models), 9):
        chunk = models[start:start + 9]
        review = Image.new('RGB', (760, 50 + len(chunk) * 190), '#ece7df')
        draw = ImageDraw.Draw(review)
        for column, name in enumerate(['three-quarter', 'top', 'back', 'side']):
            draw.text((column * 190 + 12, 14), name, font=font, fill='#283b43')
        for row, model in enumerate(chunk):
            for column, name in enumerate(['three-quarter', 'top', 'back', 'side']):
                with Image.open(args.folder / 'models' / model['id'] / (name + '.png')) as view:
                    view = view.convert('RGBA').resize((165, 165), Image.Resampling.LANCZOS)
                    review.paste(view, (column * 190 + 12, 50 + row * 190), view)
            draw.text((12, 50 + row * 190 + 165), model['id'], font=font, fill='#283b43')
        review.save(args.folder / f'multiview-{start // 9 + 1}.jpg', quality=93)
    print('Composed reference contact sheet and', math.ceil(len(models) / 9), 'four-view sheets')


if __name__ == '__main__':
    main()
