"""Stage renderer-produced reference icons only after complete appearance QA."""
import argparse,json,shutil
from PIL import Image
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--preview',type=Path,required=True);args=p.parse_args()
source=args.preview.resolve();report=json.loads((source/'look-acceptance.json').read_text('utf-8'))
assert report['passed'] and report['icons']==report['models']*2
backup=ROOT/'projects/catch-big-goose-unity/SourceAssets/ReferenceLookBaseline-20261025/icons';backup.mkdir(exist_ok=True)
ids=[x['id'] for x in json.loads((ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data/reference-material-models.json').read_text('utf-8'))['models']]
assert len(ids)==report['models']
for mid in ids:
    icon=source/'models'/mid/'icon-192.png';assert icon.is_file()
    rgba=Image.open(icon).convert('RGBA');alpha=rgba.getchannel('A')
    assert alpha.getextrema()[0]==0 and alpha.getextrema()[1]>0,(mid,'preview must have actual transparent background')
    assert all(alpha.getpixel(p)==0 for p in [(0,0),(191,0),(0,191),(191,191)]),(mid,'another scene leaked into icon preview')
    target=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Icons'/(mid+'.png')
    if target.exists() and not (backup/target.name).exists():shutil.copy2(target,backup/target.name)
    shutil.copy2(icon,target)
print(str(len(ids))+' real Unity material-preview icons staged; existing icon GUIDs retained.')
