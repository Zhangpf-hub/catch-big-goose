"""Dense corn kernels and closed folded husks, generated within a checked budget."""
import math
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from model_refresh_geometry import begin, material, mesh, cube, tube, join, finish

spec = begin('design/farm-theme/corn-v2/corn-sculpt-spec.json')
ochre = material('corn-core-ochre', (.65,.35,.025), .65)
gold = material('corn-kernel-gold', (.98,.64,.035), .38)
yellow = material('corn-kernel-yellow', (1,.75,.09), .4)
green = material('corn-husk-green', (.14,.36,.035), .54)
light = material('corn-husk-light', (.26,.48,.065), .55)
pale = material('corn-stalk', (.44,.51,.14), .67)

def radius(z):
    t = max(0, min(1, (z - .20) / .64))
    return .27 * (1 - .94 * t ** 1.5)

zs = [-.68 + 1.52 * i / 12 for i in range(13)]
core = tube('cob-core', [(0,0,z) for z in zs], [radius(z) for z in zs], ochre, 16)
kernels = []
for row in range(9):
    z = -.54 + row * .161
    r = radius(z)
    taper = 1 - .24 * (row / 8) ** 3
    width = 2 * (r + .039) * math.sin(math.pi / 12) * 1.045
    for col in range(12):
        a = col * math.tau / 12
        obj = cube('kernel', (width, .135, .171*taper),
                   ((r+.039)*math.cos(a), (r+.039)*math.sin(a), z),
                   yellow if (row+col)%3 else gold, min(.034*taper, width*.24), 1)
        obj.rotation_euler.z = a + math.pi / 2
        kernels.append(obj)
kernel_rows = join(kernels, 'kernel-rows')

leaves, veins = [], []
for leaf, angle in enumerate((-.65, 1.65, 3.55)):
    verts, uvs, faces, centers = [], [], [], []
    rows, columns = 15, 5
    for i in range(rows):
        t = i / (rows-1)
        # The tip curls away from the cob; the center fold retains real thickness.
        r = .16 + .31*(1-math.exp(-8*t)) + .14*t**5
        z = -.80 + 1.18*t - .03*t**7
        width = .025 + .27 * math.sin(math.pi*t) ** 1.1
        if i == rows-1:
            width = .012
        centers.append((r*math.cos(angle), r*math.sin(angle), z+.006))
        for side in range(2):
            for j in range(columns):
                across = (j/(columns-1)*2-1)
                fold = -.052*abs(across)**1.3 * math.sin(math.pi*t)
                radial = r + fold + (.012 if side == 0 else -.012)
                verts.append((radial*math.cos(angle)-across*width*math.sin(angle),
                              radial*math.sin(angle)+across*width*math.cos(angle), z))
                uvs.append((j/(columns-1), t))
    stride = columns*2
    for i in range(rows-1):
        for side in range(2):
            for j in range(columns-1):
                q = i*stride + side*columns+j
                face = (q,q+1,q+stride+1,q+stride)
                faces.append(face if side == 0 else tuple(reversed(face)))
        for j in (0,columns-1):
            q=i*stride+j
            faces.append((q,q+stride,q+stride+columns,q+columns))
    for i in (0,rows-1):
        for j in range(columns-1):
            q=i*stride+j
            faces.append((q,q+columns,q+columns+1,q+1))
    leaves.append(mesh('leaf',verts,faces, green if leaf%2 else light,uvs))
    vein_centers = [(x+.018*math.cos(angle),y+.018*math.sin(angle),z) for x,y,z in centers[1:-1]]
    veins.append(tube('vein',vein_centers,[.008]*len(vein_centers), light,6))
husks=join(leaves,'folded-husks')
veins=join(veins,'husk-veins')
stalk=tube('cut-stalk',[(0,0,-.97),(0,0,-.84),(0,0,-.65)],[.11,.125,.14],pale,12)
finish(spec,[core,kernel_rows,husks,veins,stalk])
