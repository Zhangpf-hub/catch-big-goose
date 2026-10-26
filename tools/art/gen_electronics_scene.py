"""Original electronics work tray and station art from actual game models."""
import json
import sys
from pathlib import Path
import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'skills/match3-model-pipeline/scripts'))
import generate_electronics as base

OUT = ROOT / 'source-assets/models/candidates/electronics-v2'
base.clear()
base.PARTS = []
base.MAT = base.palette('tray_electronics')
# 0.0875*4 = 0.35: floor top aligns with game y=0 when model bottom is y=-0.35.
base.box('blue_tray_base', (0, 0, 0), (1, 1, .0875), 4, .035)
base.box('antistatic_floor', (0, 0, .046), (.84, .84, .005), 12, .002)
for axis in (0, 1):
    for side in (-1, 1):
        loc, size = [0, 0, .105 + .002 * (axis * 2 + (side + 1) // 2)], [.08, 1, .22]
        loc[axis] = side * .46
        if axis == 1:
            size = [1, .08, .22]
        base.box('raised_rim', loc, size, 8, .028)
for value in (-.30, -.15, 0, .15, .30):
    base.box('mat_grid_x', (value, 0, .05), (.003, .79, .003), 1, .001, segments=1)
    base.box('mat_grid_y', (0, value, .05), (.79, .003, .003), 1, .001, segments=1)
for x in (-.46, .46):
    for y in (-.42, .42):
        base.disc('corner_fastener', (x, y, .223), .018, .012, 7, vertices=12)
obj = base.normalize_and_join('tray_electronics')
base.geometry_metrics(obj)
for folder in ('source', 'models', 'icons', 'qa'):
    (OUT / folder).mkdir(parents=True, exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT / 'source/tray_electronics.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT / 'models/tray_electronics.glb'), export_format='GLB',
                         use_selection=True, export_yup=True, export_extras=True,
                         export_cameras=False, export_lights=False)
base.render(obj, OUT / 'qa')
print('TRAY_COMPLETE', flush=True)
