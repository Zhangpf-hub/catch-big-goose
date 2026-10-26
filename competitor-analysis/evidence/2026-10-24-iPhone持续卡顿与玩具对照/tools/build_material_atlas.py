"""Pack source material swatches/textures without shrinking thousands of UV islands."""
import json,math,sys
from pathlib import Path
sys.path.insert(0,'C:/Users/123/.codex/visualizations/2026/10/21/01a15f1e-af66-7022-bd6a-105254709b3b/competitor-goose/deps')
from PIL import Image
import numpy as np
source=Path(sys.argv[1]);data=json.loads(source.read_text('utf-8'));materials=data['materials']
grid=1
while grid*grid<len(materials):grid*=2
size=512 if any(m.get('texture') for m in materials) else max(32,grid*16)
tile=size//grid;pad=3;canvas=Image.new('RGB',(size,size));rects=[]
def linear(x):return np.where(x<=.04045,x/12.92,((x+.055)/1.055)**2.4)
def srgb(x):return np.where(x<=.0031308,x*12.92,1.055*np.maximum(x,0)**(1/2.4)-.055)
for i,m in enumerate(materials):
    x0=(i%grid)*tile;y0=(i//grid)*tile
    tint=np.array(m['color'][:3],dtype=np.float32)
    if m.get('texture'):
        image=np.array(Image.open(m['texture']).convert('RGB'),dtype=np.float32)/255
        h,w=image.shape[:2];lo=m['uvMin'];hi=m['uvMax']
        # The inset is replicated into padding; texture repeats remain inside its tile.
        u=np.clip((np.arange(tile)-pad+.5)/(tile-2*pad),0,1)*(hi[0]-lo[0])+lo[0]
        v=hi[1]-np.clip((np.arange(tile)-pad+.5)/(tile-2*pad),0,1)*(hi[1]-lo[1])
        ix=(np.floor((u%1)*w).astype(int))%w;iy=(np.floor((1-v%1)*h).astype(int))%h
        pixels=image[iy[:,None],ix[None,:]]
        pixels=srgb(linear(pixels)*linear(tint))
        patch=Image.fromarray(np.uint8(np.clip(pixels,0,1)*255+.5),'RGB')
    else:patch=Image.new('RGB',(tile,tile),tuple(int(max(0,min(1,c))*255+.5) for c in tint))
    canvas.paste(patch,(x0,size-y0-tile))
    rects.append(dict(min=[(x0+pad)/size,(y0+pad)/size],scale=[(tile-2*pad)/size,(tile-2*pad)/size]))
canvas.save(data['output'])
source.with_suffix('.rects.json').write_text(json.dumps(rects),encoding='utf-8')
