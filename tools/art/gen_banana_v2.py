"""Build the banana from its checked, per-model sculpt contract."""
import math
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from mathutils import Vector
from model_refresh_geometry import begin, material, albedo, mesh, tube, finish

spec = begin('design/fruit-theme/banana-v2/banana-sculpt-spec.json')
peel = material('banana-warm-yellow', (0.94, 0.64, 0.055), .48)
olive = material('banana-olive-stem', (.31, .29, .065), .64)
brown = material('banana-cut-and-blossom', (.16, .075, .025), .74)

def peel_pixel(u, v):
    ridge = .045 * math.cos(v * math.tau * 5)
    end = max(0, 1 - u * 8) * .17 + max(0, u * 9 - 8) * .12
    speck = .018 * max(0, math.sin(u * 193 + math.sin(v * 91)) * math.sin(v * 151) - .63)
    return (.97 - end * .55 + ridge * .3 - speck,
            .74 - end * .7 + ridge - speck, .075 + end * .3 + ridge * .12)

albedo(peel, 'banana-peel-256', 256, 256, peel_pixel)
vertices, faces, uv = [], [], []
rings, sides = 33, 20
for i in range(rings):
    t = i / (rings - 1)
    center = Vector((-1.5 + 3 * t, -.83 * math.sin(math.pi * t), 0))
    tangent = Vector((3, -.83 * math.pi * math.cos(math.pi * t), 0)).normalized()
    across = Vector((-tangent.y, tangent.x, 0))
    radius = .055 + .255 * math.sin(math.pi * t) ** .58
    for j in range(sides):
        a = j * math.tau / sides
        r = radius * (1 + .055 * math.cos(5 * a))
        vertices.append(center + across * (r * math.cos(a)) + Vector((0, 0, .92 * r * math.sin(a))))
        uv.append((t, j / sides))
for i in range(rings - 1):
    for j in range(sides):
        faces.append((i*sides+j, i*sides+(j+1)%sides, (i+1)*sides+(j+1)%sides, (i+1)*sides+j))
faces += [tuple(reversed(range(sides))), tuple(range((rings-1)*sides, rings*sides))]
body = mesh('curved-peel', vertices, faces, peel, uv)
stem = tube('stem', [(-1.455,-.04,0), (-1.52,.045,0), (-1.535,.15,.005), (-1.49,.255,.015)], [.10,.117,.11,.095], olive, 16)
cut = tube('stem-cut', [(-1.494,.245,.014), (-1.486,.264,.016)], [.096,.093], brown, 16)
tip = tube('blossom-tip', [(1.473,-.025,0), (1.527,.025,0), (1.551,.056,0)], [.062,.043,.018], brown, 12)
finish(spec, [body, stem, cut, tip])
