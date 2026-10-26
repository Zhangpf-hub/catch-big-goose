"""Slice the approved generated UI sprite sheet without changing its pixels."""
from pathlib import Path
import shutil,json
from PIL import Image
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Textures/story-ui';OUT.mkdir(parents=True,exist_ok=True)
source=Path('C:/Users/123/.codex/generated_images/01a16bd0-8fc1-74a1-ac57-1e45c185e153/exec-5ded1d16-b523-40f3-ac89-fb3cdb47feb9.png')
archive=ROOT/'source-assets/models/candidates/two-stage-ui-20261025';archive.mkdir(exist_ok=True);shutil.copy2(source,archive/'ui-sheet.png')
im=Image.open(source)
regions={'remove':(0,0,535,628),'match':(540,0,1020,628),'shuffle':(1024,0,1536,628),'yellow-button':(0,637,512,938),'blue-button':(512,637,1024,938),'ivory-panel':(1024,637,1536,938)}
for name,box in regions.items():
    tile=im.crop(box)
    destination=OUT if name in {'remove','match','shuffle'} else archive/'legacy-slices'
    destination.mkdir(parents=True,exist_ok=True);tile.save(destination/(name+'.png'))
(archive/'provenance.json').write_text(json.dumps(dict(tool='built-in image_gen',source=str(source),purpose='Production UI sprites; no generated gameplay screenshots',regions=regions,prompt='Single transparent six-cell sprite sheet: remove/storage box, magnet/match, shuffle arrows, yellow button, blue button, ivory inset panel; chunky plastic casual-game stickers, warm brown outline and white rim; no text.'),indent=2),'utf8')
print('UI sprites staged',len(regions))
