"""Slice the generated transparent atlas without changing its pixels or alpha."""
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('atlas', type=Path)
    args = parser.parse_args()
    source = ROOT / 'source-assets/ui/reward-truck-v1'
    target = ROOT / 'projects/catch-big-goose-unity/Assets/Resources/Textures/reward-truck'
    source.mkdir(parents=True, exist_ok=True)
    target.mkdir(parents=True, exist_ok=True)
    raw = args.atlas.read_bytes()
    (source / 'atlas.png').write_bytes(raw)
    atlas = Image.open(args.atlas)
    assert atlas.mode == 'RGBA' and atlas.size == (1536, 1024)
    slices = {'body': (20, 28, 1510, 670), 'wheel': (627, 706, 909, 988)}
    for name, box in slices.items():
        piece = atlas.crop(box)
        piece.save(target / (name + '.png'))
    report = dict(tool='built-in image_gen', atlasSha256=hashlib.sha256(raw).hexdigest(),
                  slices=slices, processing='Pixel-preserving rectangle slicing only; alpha preserved')
    (source / 'slices.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps(report))

if __name__ == '__main__':
    main()
