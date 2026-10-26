"""Bake the three fixed Chinese control labels into small transparent UI sprites."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / 'projects/catch-big-goose-unity/Assets/Resources/Textures/control-labels'

def main():
    DEST.mkdir(parents=True, exist_ok=True)
    font = ImageFont.truetype(str(ROOT / 'projects/catch-big-goose-unity/Assets/Resources/Fonts/Chinese-Bold.otf'), 108)
    for name, label in [('remove', '移出'), ('magnet', '凑齐'), ('shuffle', '打乱')]:
        image = Image.new('RGBA', (512, 224))
        draw = ImageDraw.Draw(image)
        bounds = draw.textbbox((0, 0), label, font=font)
        draw.text(((512 - bounds[2] - bounds[0]) / 2, (224 - bounds[3] - bounds[1]) / 2),
                  label, font=font, fill=(56, 48, 43, 255))
        image.save(DEST / (name + '.png'))

if __name__ == '__main__':
    main()
