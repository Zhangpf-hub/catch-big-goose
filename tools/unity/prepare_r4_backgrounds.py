"""Stage the five approved ImageGen background plates without editing their pixels."""
import hashlib, json, shutil
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path('C:/Users/123/.codex/generated_images/01a1700a-1f83-7490-bc99-5f87946c797b')
FILES = {
    'breakfast': 'exec-0affceb0-849d-4e32-99a4-f88336acd3ae.png',
    'barbecue': 'exec-8a3de636-032b-4730-8b3d-08c9860ff656.png',
    'countryside': 'exec-d703bd71-8e62-40b0-bf6a-c32916bd8ab4.png',
    'toys': 'exec-d797146e-51ac-411a-b51b-25988850460f.png',
    'grocery': 'exec-3e39c71b-73af-4cfd-b0d5-fb7b6ebcd99a.png',
}
out = ROOT / 'projects/catch-big-goose-unity/Assets/Resources/Textures/mobile-ui/themes'
archive = ROOT / 'source-assets/models/candidates/r4-scenes-20261025/backgrounds'
out.mkdir(parents=True, exist_ok=True)
archive.mkdir(parents=True, exist_ok=True)
report = []
for theme, filename in FILES.items():
    src = SOURCE / filename
    im = Image.open(src)
    assert im.height > im.width and max(im.size) <= 2048
    target = out / (theme + '-r4.png')
    shutil.copy2(src, target)
    shutil.copy2(src, archive / target.name)
    report.append(dict(theme=theme, source=str(src), asset=str(target.relative_to(ROOT)),
                       width=im.width, height=im.height, bytes=src.stat().st_size,
                       sha256=hashlib.sha256(src.read_bytes()).hexdigest(), generator='built-in image_gen'))
(archive / 'manifest.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps(report, ensure_ascii=False, indent=2))
