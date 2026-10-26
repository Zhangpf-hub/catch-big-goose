"""Compose render_model_audit.py outputs into labeled theme sheets."""
import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT = ROOT / "work/audits/model-quality/current"
THEMES = {
    "fruit": ["apple", "banana", "grape", "orange", "strawberry", "lemon", "pear", "cherry", "goose"],
    "antique": ["tongqian", "bracelet", "baoshi", "hulu", "yuzhuo", "banzhi", "yuxi", "ruyi", "goose"],
    "farm": ["carrot", "corn", "eggplant", "frog", "pumpkin", "mushroom", "koi", "lotus", "duck"],
    "dessert": ["cupcake", "donut", "icecream", "macaron", "cookie", "cake_slice", "candy", "pudding", "croissant"],
}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, default=DEFAULT_OUTPUT)
    options = parser.parse_args()
    output = options.input if options.input.is_absolute() else ROOT / options.input
    font_path = Path("C:/Windows/Fonts/arial.ttf")
    font = ImageFont.truetype(str(font_path), 24) if font_path.exists() else ImageFont.load_default()
    for theme, names in THEMES.items():
        sheet = Image.new("RGB", (900, 1020), (22, 17, 15))
        draw = ImageDraw.Draw(sheet)
        for index, name in enumerate(names):
            x = index % 3 * 300
            y = index // 3 * 340
            source = output / f"{name}.png"
            if not source.exists():
                continue
            image = Image.open(source).convert("RGB").resize((300, 300), Image.Resampling.LANCZOS)
            sheet.paste(image, (x, y))
            draw.text((x + 12, y + 306), name, fill=(245, 232, 214), font=font)
        sheet.save(output / f"_sheet_{theme}.jpg", quality=92, optimize=True)


if __name__ == "__main__":
    main()
