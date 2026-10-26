"""Validate candidate GLBs with the actual hull pipeline, then stage own assets."""
import argparse
import hashlib
import json
import shutil
import subprocess
from catalog import ROOT, BATCH, specifications
from PIL import Image, ImageDraw

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--stage',action='store_true');args=parser.parse_args()
    specs=specifications();rows=[]
    for index in range(0,60,5):
        batch=ROOT/'work/theme21/audit-sets'/str(index//5)
        (batch/'models').mkdir(parents=True,exist_ok=True);(batch/'qa').mkdir(exist_ok=True)
        previous=batch/'qa/asset-audit.json'
        if previous.exists():
            cached=json.loads(previous.read_text('utf-8'))
            if all(hashlib.sha256((BATCH/'models'/f"{r['id']}.glb").read_bytes()).hexdigest()==r['sha256'] for r in cached['models']):
                rows.extend(cached['models']);print('AUDIT_CACHED',index//5,flush=True);continue
        for s in specs[index:index+5]: shutil.copy2(BATCH/'models'/f"{s['id']}.glb",batch/'models')
        result=subprocess.run(['node',str(ROOT/'skills/match3-model-pipeline/scripts/audit_assets.mjs'),'--project',str(ROOT),'--candidate',str(batch),'--validator','D:/开发/tools/gltf-audit/node_modules/gltf-validator'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,encoding='utf-8')
        (batch/'qa/run.log').write_text(result.stdout,'utf-8')
        if result.returncode: raise RuntimeError(f'audit set {index//5}: {result.stdout[-3000:]}')
        report=json.loads((batch/'qa/asset-audit.json').read_text('utf-8'));rows.extend(report['models'])
        print('AUDIT_PASS',index//5,flush=True)
    (BATCH/'qa/validated-models.json').write_text(json.dumps(rows,indent=2),'utf-8')
    for theme in ['fruit','antique','farm','dessert','electronics']:
        items=[s for s in specs if s['theme']==theme]
        sheet=Image.new('RGB',(960,12*148),(227,223,210));draw=ImageDraw.Draw(sheet)
        for row,s in enumerate(items):
            draw.text((8,row*148+5),s['id'],fill='black')
            for col,view in enumerate(['hero','top','back','side']):
                im=Image.open(BATCH/'qa'/f"{s['id']}-{view}.png").convert('RGBA');im.thumbnail((132,124));sheet.paste(im,(150+col*170,row*148+18),im)
            icon=Image.open(BATCH/'icons'/f"{s['id']}-64.png").convert('RGBA');sheet.paste(icon,(850,row*148+36),icon)
        sheet.save(BATCH/'qa'/f'{theme}-contact.png')
    if args.stage:
        manifest=[]
        for s in specs:
            for folder,suffix,target in [('models','.glb','projects/catch-big-goose-unity/SourceAssets/Models'),('icons','.png','projects/catch-big-goose-unity/Assets/Resources/Icons')]:
                source=BATCH/folder/(s['id']+suffix);dest=ROOT/target/source.name
                dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,dest)
                manifest.append(dict(id=s['id'],theme=s['theme'],source=source.relative_to(ROOT).as_posix(),target=dest.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(source.read_bytes()).hexdigest()))
        (ROOT/'work/theme21/staged-assets.json').write_text(json.dumps(manifest,indent=2),'utf-8')
        print('STAGED',len(manifest))

if __name__=='__main__':main()
