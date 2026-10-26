import json, shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
src=ROOT/'source-assets/models/candidates/r4-scenes-20261025/containers'
themes_path=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data/themes.json'
data=json.loads(themes_path.read_text(encoding='utf-8-sig'))
for theme in data['themes']:
    id='round_'+theme['id']+'_r4'
    target=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Models'/id
    target.mkdir(parents=True,exist_ok=True)
    shutil.copy2(src/id/(id+'.fbx'),target/(id+'.fbx'))
    theme.update(container=id,background='mobile-ui/themes/'+theme['id']+'-r4',circular=True,halfX=1.72,halfZ=1.72)
themes_path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
p=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data/reference-lab.json'
data=json.loads(p.read_text(encoding='utf-8-sig'))
data['theme'].update(container='round_toys_r4',background='mobile-ui/themes/toys-r4',circular=True,halfX=1.72,halfZ=1.72)
p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Five circular containers, five theme backgrounds, and reference scene mapped.')
