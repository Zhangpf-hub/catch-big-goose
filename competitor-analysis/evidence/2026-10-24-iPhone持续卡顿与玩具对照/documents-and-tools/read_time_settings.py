import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,'C:/Users/123/.codex/visualizations/2026/10/21/01a15f1e-af66-7022-bd6a-105254709b3b/competitor-goose/deps')
import UnityPy
source=ROOT/'work/competitor-config-trace/source/6f7a2014e3c0092b.webgl.data.unityweb.bin'
env=UnityPy.load(str(source));rows=[]
for obj in env.objects:
    if obj.type.name in {'TimeManager','PhysicsManager','QualitySettings'}:
        try:tree=obj.read_typetree()
        except Exception as error:tree={'readError':str(error)}
        rows.append(dict(type=obj.type.name,pathId=obj.path_id,assetsFile=obj.assets_file.name,data=tree))
output=ROOT/'work/device-profile-20261024/competitor-time-physics.json'
output.write_text(json.dumps(dict(source=str(source),sha256=hashlib.sha256(source.read_bytes()).hexdigest(),objects=rows),ensure_ascii=False,indent=2),encoding='utf-8')
for row in rows:
    if row['type']=='TimeManager':print(json.dumps(row,ensure_ascii=False))
