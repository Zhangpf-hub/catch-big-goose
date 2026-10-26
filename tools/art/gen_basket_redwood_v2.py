"""Low square wood basket with a solid floor and genuine interleaving ribbons."""
import math
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from model_refresh_geometry import begin, material, albedo, mesh, cube, tube, join, finish

spec = begin('design/fruit-theme/basket_redwood-v2/basket_redwood-sculpt-spec.json')
wood=material('basket-chestnut-wood',(.36,.135,.045),.64)
rimwood=material('basket-polished-rim',(.40,.17,.06),.49)
honey=material('basket-honey-weave',(.62,.36,.13),.73)
straw=material('basket-light-weave',(.74,.46,.18),.73)
brass=material('basket-brass-pins',(.54,.32,.10),.5,.30)

def grain(u,v):
    wave=math.sin(v*math.tau*17 + .55*math.sin(u*math.tau*3))
    fine=math.sin(v*math.tau*93 + 1.4*math.sin(u*math.tau*2))
    d=.022*wave+.008*fine
    return (.57+d,.325+d*.8,.16+d*.5)
albedo(wood,'basket-wood-grain',512,256,grain)
albedo(rimwood,'basket-rim-grain',512,256,grain)

def contour(hx,hy,r,n=8):
    points=[]
    for cx,cy,start in ((hx-r,hy-r,0),(-hx+r,hy-r,90),(-hx+r,-hy+r,180),(hx-r,-hy+r,270)):
        for i in range(n+1):
            a=math.radians(start+i*90/n)
            points.append((cx+r*math.cos(a),cy+r*math.sin(a)))
    return points

def ring(name,profile,mat):
    vertices,uv,faces=[],[],[]
    for k,(hx,hy,r,z) in enumerate(profile):
        for j,(x,y) in enumerate(contour(hx,hy,r)):
            vertices.append((x,y,z));uv.append((j/36,k/len(profile)))
    count=36
    for k in range(len(profile)):
        for j in range(count):
            faces.append((k*count+j,k*count+(j+1)%count,((k+1)%len(profile))*count+(j+1)%count,((k+1)%len(profile))*count+j))
    return mesh(name,vertices,faces,mat,uv)

wall=ring('wall',[(1.90,1.90,.23,.17),(1.90,1.90,.23,1.19),
                  (1.36,1.42,.13,1.21),(1.36,1.42,.13,.30)],wood)
base=cube('solid-base',(3.79,3.79,.35),(0,0,.175),wood,.12,3)
shell=join([wall,base],'wooden-shell')
rim=ring('rolled-rim',[(1.91,1.91,.25,1.10),(1.99,1.99,.30,1.18),
                       (2,2,.32,1.26),(1.94,1.94,.29,1.34),
                       (1.43,1.49,.18,1.34),(1.35,1.42,.14,1.27),
                       (1.35,1.42,.14,1.18),(1.42,1.49,.18,1.10)],rimwood)
strips=[]
for direction in range(2):
    for strip in range(12):
        verts,uv,faces=[],[],[]
        cross=-1.21+strip*.22
        for i in range(37):
            along=-1.34+i*2.68/36
            height=.365+.012*math.cos((along+1.21)/.22*math.pi+strip*math.pi+direction*math.pi)
            for dw,dz in ((-.102,-.022),(.102,-.022),(.102,.010),(-.102,.010)):
                a,b=along,cross+dw
                verts.append((a,b,height+dz) if direction==0 else (b,a,height+dz))
                uv.append((i/36,(dw+.102)/.204))
        for i in range(36):
            for j in range(4):
                faces.append((i*4+j,i*4+(j+1)%4,(i+1)*4+(j+1)%4,(i+1)*4+j))
        faces += [(3,2,1,0),(144,145,146,147)]
        strips.append(mesh('ribbon',verts,faces,honey if direction==0 else straw,uv,False))
floor=join(strips,'woven-floor')
pins=[]
for x in (-1.62,1.62):
    for y in (-1.62,1.62):
        for offset in (-.09,.09):
            pins.append(tube('pin',[(x+offset,y,1.325),(x+offset,y,1.354)], [.043,.038],brass,10))
fasteners=join(pins,'brass-fasteners')
finish(spec,[shell,rim,floor,fasteners])
