"""Deterministic Blender 4.5+ electronics pilot. Run through Blender --background --python.

All geometry is original; output paths are explicit and existing game assets are untouched.
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

import bmesh
import bpy
from mathutils import Vector

IDS = ('phone', 'laptop', 'camera', 'headphones', 'handheld',
       'speaker', 'mouse', 'smartwatch', 'radio')
COLORS = [
    (0.96, 0.29, 0.28, 1), (0.19, 0.77, 0.60, 1),
    (1.0, 0.68, 0.12, 1), (0.63, 0.40, 0.91, 1),
    (0.16, 0.56, 0.94, 1), (0.075, 0.12, 0.20, 1),
    (0.23, 0.40, 0.53, 1), (0.88, 0.96, 0.99, 1),
    (0.37, 0.85, 0.95, 1), (1.0, 0.83, 0.62, 1),
    (0.98, 0.48, 0.56, 1), (0.12, 0.26, 0.36, 1),
    (0.41, 0.91, 0.69, 1), (0.99, 0.92, 0.43, 1),
    (0.80, 0.67, 0.98, 1), (0.46, 0.73, 1.0, 1),
]
PARTS = []
MAT = None


def clear():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for datablocks in (bpy.data.meshes, bpy.data.materials, bpy.data.images,
                       bpy.data.cameras, bpy.data.lights, bpy.data.curves):
        for block in list(datablocks):
            if block.users == 0:
                datablocks.remove(block)


def palette(model_id):
    image = bpy.data.images.new(model_id + '_palette', width=64, height=64, alpha=False)
    image.colorspace_settings.name = 'sRGB'
    image.pixels.foreach_set([c for y in range(64) for x in range(64)
                             for c in COLORS[(y // 16) * 4 + x // 16]])
    image.pack()
    mat = bpy.data.materials.new(model_id + '_material')
    mat.use_nodes = True
    mat.use_backface_culling = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Metallic'].default_value = 0
    bsdf.inputs['Roughness'].default_value = 0.6
    # Keep default specular: changing it emits KHR_materials_specular in glTF.
    bsdf.inputs['Specular IOR Level'].default_value = 0.5
    texture = mat.node_tree.nodes.new('ShaderNodeTexImage')
    texture.image = image
    texture.interpolation = 'Closest'
    uv = mat.node_tree.nodes.new('ShaderNodeUVMap')
    uv.uv_map = 'UVMap'
    mat.node_tree.links.new(uv.outputs['UV'], texture.inputs['Vector'])
    mat.node_tree.links.new(texture.outputs['Color'], bsdf.inputs['Base Color'])
    return mat


def paint(obj, name, color):
    obj.name = name
    obj.data.materials.clear()
    obj.data.materials.append(MAT)
    uv = obj.data.uv_layers.get('UVMap') or obj.data.uv_layers.new(name='UVMap')
    for item in uv.data:
        item.uv = ((color % 4 + 0.5) / 4, (color // 4 + 0.5) / 4)
    for poly in obj.data.polygons:
        poly.use_smooth = True
    bpy.context.view_layer.objects.active = obj
    # Weighted normals keep broad toy surfaces flat while rounding edges.
    mod = obj.modifiers.new('weighted_normals', 'WEIGHTED_NORMAL')
    mod.keep_sharp = True
    bpy.ops.object.modifier_apply(modifier=mod.name)
    PARTS.append(obj)
    return obj


def box(name, loc, size, color, bevel=0.025, rotation=(0, 0, 0), segments=2):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc, rotation=rotation)
    obj = bpy.context.object
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = obj.modifiers.new('rounded_edges', 'BEVEL')
        mod.width = min(bevel, min(size) * 0.45)
        mod.segments = segments
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return paint(obj, name, color)


def disc(name, loc, radius, depth, color, rotation=(0, 0, 0), vertices=24):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth,
                                       location=loc, rotation=rotation)
    obj = bpy.context.object
    mod = obj.modifiers.new('rounded_lip', 'BEVEL')
    mod.width = min(depth * 0.25, 0.015)
    mod.segments = 1
    bpy.ops.object.modifier_apply(modifier=mod.name)
    return paint(obj, name, color)


def tube(name, points, radius, color):
    curve = bpy.data.curves.new(name, 'CURVE')
    curve.dimensions = '3D'
    curve.bevel_depth = radius
    curve.bevel_resolution = 2
    curve.use_fill_caps = True
    spline = curve.splines.new('POLY')
    spline.points.add(len(points) - 1)
    for point, co in zip(spline.points, points):
        point.co = (*co, 1)
    obj = bpy.data.objects.new(name, curve)
    bpy.context.collection.objects.link(obj)
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.convert(target='MESH')
    return paint(bpy.context.object, name, color)


def phone():
    box('coral_case', (0, 0, 0), (.54, 1, .14), 0, .06)
    box('screen_bezel', (0, 0, .071), (.48, .91, .024), 5, .04)
    box('display', (0, -.015, .085), (.415, .76, .012), 8, .025)
    box('speaker', (0, .405, .087), (.13, .019, .014), 7, .006)
    box('home_bar', (0, -.402, .091), (.12, .018, .009), 7, .004)
    for i, (x, y, c) in enumerate([(-.11, .12, 0), (.10, .12, 13),
                                  (-.11, -.10, 3), (.10, -.10, 7)]):
        box(f'app_{i}', (x, y, .095), (.13, .13, .012), c, .025)
    box('volume', (-.278, .16, 0), (.025, .18, .056), 9, .01)
    box('camera_island', (-.135, .32, -.078), (.21, .25, .035), 10, .035)
    for y in (.26, .38):
        disc('rear_lens', (-.135, y, -.104), .044, .025, 5)


def laptop():
    box('mint_base', (0, -.02, -.24), (1, .70, .10), 1, .045)
    box('keyboard_deck', (0, .025, -.183), (.86, .36, .015), 5, .02)
    for row in range(3):
        for column in range(8):
            box(f'key_{row}_{column}', (-.35 + column * .10, -.08 + row * .10, -.169),
                (.075, .067, .018), 7, .009, segments=1)
    box('trackpad', (0, -.257, -.181), (.27, .10, .016), 12, .015)
    angle = math.radians(12)
    screen_center = Vector((0, .255, .105))
    rot = (angle, 0, 0)
    box('open_lid', screen_center, (.97, .075, .64), 1, .035, rot)
    # Place the screen in front of the tilted lid using the same local axes.
    from mathutils import Euler
    rotation = Euler(rot).to_matrix()
    box('screen_bezel', screen_center + rotation @ Vector((0, -.044, 0)),
        (.87, .018, .54), 5, .018, rot)
    box('display', screen_center + rotation @ Vector((0, -.056, -.005)),
        (.79, .012, .45), 8, .012, rot)
    for x, z, w, h, c in [(-.18, .045, .23, .23, 13), (.115, .08, .24, .08, 7),
                           (.115, -.055, .24, .12, 12)]:
        box('screen_tile', screen_center + rotation @ Vector((x, -.066, z)),
            (w, .012, h), c, .008, rot)
    for x in (-.33, .33):
        disc('hinge', (x, .27, -.19), .045, .20, 11, (0, math.pi / 2, 0))


def camera():
    box('yellow_body', (0, .02, 0), (.90, .34, .56), 2, .06)
    box('front_panel', (0, -.16, -.025), (.80, .035, .39), 9, .025)
    box('grip', (-.34, -.12, -.01), (.17, .15, .46), 5, .04)
    box('viewfinder', (.01, .015, .31), (.29, .25, .15), 2, .03)
    box('flash', (.01, -.12, .315), (.20, .025, .072), 7, .012)
    disc('lens_barrel', (.075, -.25, -.035), .245, .20, 5, (math.pi / 2, 0, 0), 32)
    disc('lens_ring', (.075, -.365, -.035), .212, .045, 7, (math.pi / 2, 0, 0), 32)
    disc('lens_glass', (.075, -.393, -.035), .171, .018, 11, (math.pi / 2, 0, 0), 32)
    disc('lens_iris', (.075, -.405, -.035), .115, .013, 8, (math.pi / 2, 0, 0))
    disc('lens_glint', (.028, -.416, .016), .039, .008, 7, (math.pi / 2, 0, 0), 16)
    disc('shutter', (-.29, -.02, .30), .066, .055, 0)
    disc('top_dial', (.30, .04, .30), .075, .04, 5)
    box('rear_display', (0, .199, 0), (.53, .023, .33), 5, .02)
    box('rear_screen', (0, .216, 0), (.45, .012, .25), 8, .015)


def headphones():
    points = [(.40 * math.cos(t * math.pi / 24), 0, .10 + .46 * math.sin(t * math.pi / 24))
              for t in range(25)]
    tube('headband', points, .065, 3)
    points = [(.40 * math.cos(t * math.pi / 24), -.005,
               .10 + .46 * math.sin(t * math.pi / 24) - .026) for t in range(3, 22)]
    tube('headband_cushion', points, .043, 14)
    for side in (-1, 1):
        x = side * .40
        box('yoke', (x, 0, .07), (.07, .12, .25), 7, .025)
        box('earcup', (x, -.005, -.095), (.23, .27, .35), 3, .07)
        box('earpad', (x - side * .11, -.005, -.095), (.07, .23, .29), 5, .03)
        box('earcup_inset', (x + side * .12, -.005, -.095), (.025, .16, .22), 14, .011)
    disc('power_button', (.43, -.149, -.07), .027, .014, 12, (math.pi / 2, 0, 0), 16)


def handheld():
    box('blue_body', (0, 0, 0), (1, .51, .16), 4, .07)
    box('left_grip', (-.415, 0, .008), (.20, .50, .175), 8, .055)
    box('right_grip', (.415, 0, .008), (.20, .50, .175), 0, .055)
    box('screen_bezel', (0, 0, .089), (.59, .43, .023), 5, .02)
    box('display', (0, 0, .105), (.51, .35, .013), 11, .015)
    # Stylized game landscape; no text or logos.
    box('game_ground', (0, -.09, .116), (.48, .11, .013), 1, .01)
    box('game_avatar', (-.07, -.015, .122), (.062, .086, .018), 13, .009)
    for x in (.05, .17):
        box('game_platform', (x, .04 + x * .35, .12), (.10, .035, .015), 7, .006)
    disc('left_stick_base', (-.411, .12, .104), .057, .025, 5)
    disc('left_stick', (-.411, .12, .125), .039, .026, 6)
    box('dpad_vertical', (-.411, -.105, .11), (.035, .14, .028), 5, .01)
    box('dpad_horizontal', (-.411, -.105, .112), (.14, .035, .028), 5, .01)
    for x, y, c in [(.411, .175, 13), (.411, .065, 7), (.356, .12, 1), (.466, .12, 3)]:
        disc('action_button', (x, y, .112), .025, .03, c, vertices=16)
    disc('right_stick', (.411, -.105, .112), .047, .034, 5)
    for x in (-.37, .37):
        box('shoulder_button', (x, .258, 0), (.16, .035, .10), 7, .012)


def mouse():
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, location=(0, 0, 0))
    obj = bpy.context.object
    obj.scale = (.31, .50, .24)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    paint(obj, 'cream_shell', 9)
    for x in (-.117, .117):
        box('click_button', (x, .18, .20), (.215, .34, .055), 7, .025)
    box('button_seam', (0, .17, .228), (.018, .40, .017), 5, .005)
    disc('scroll_wheel', (0, .17, .245), .065, .065, 4, (0, math.pi / 2, 0))
    box('thumb_button', (-.303, .02, .015), (.025, .15, .065), 0, .01)
    box('lower_shell', (0, -.01, -.14), (.49, .78, .11), 7, .045)


def smartwatch():
    box('upper_strap', (0, .33, -.015), (.26, .46, .10), 2, .035)
    box('lower_strap', (0, -.33, -.015), (.26, .46, .10), 2, .035)
    box('watch_case', (0, 0, .025), (.44, .48, .17), 7, .055)
    box('watch_bezel', (0, 0, .117), (.37, .41, .027), 5, .034)
    box('watch_glass', (0, 0, .138), (.31, .35, .018), 11, .027)
    disc('dial_ring', (0, 0, .151), .126, .014, 8, vertices=32)
    disc('dial_face', (0, 0, .161), .104, .012, 5, vertices=32)
    box('hour_hand', (-.025, .022, .174), (.07, .016, .012), 7, .004, rotation=(0, 0, -.6))
    box('minute_hand', (.013, .042, .176), (.014, .105, .012), 13, .004, rotation=(0, 0, -.3))
    disc('crown', (.237, .055, .025), .044, .04, 2, (0, math.pi / 2, 0), 16)
    for y in (-.31, -.40, -.49):
        box('strap_hole', (0, y, .042), (.045, .045, .014), 9, .012, segments=1)


def speaker():
    box('aqua_body', (0, 0, 0), (.47, .38, .87), 8, .065)
    box('front_grille', (0, -.197, 0), (.38, .025, .69), 11, .022)
    for z, radius in [(-.14, .145), (.20, .085)]:
        disc('driver_rim', (0, -.222, z), radius, .028, 7, (math.pi / 2, 0, 0), 24)
        disc('driver', (0, -.241, z), radius * .80, .018, 5, (math.pi / 2, 0, 0), 24)
        disc('driver_dome', (0, -.254, z), radius * .37, .018, 6, (math.pi / 2, 0, 0), 20)
    for x in (-.12, 0, .12):
        disc('top_control', (x, 0, .445), .026, .025, 7, vertices=16)
    box('status_light', (0, -.218, -.335), (.07, .014, .018), 12, .004)
    box('rubber_foot', (0, 0, -.447), (.35, .29, .035), 5, .015)


def radio():
    box('rose_body', (0, 0, 0), (.91, .31, .53), 10, .055)
    box('cream_front', (0, -.163, 0), (.82, .025, .42), 9, .025)
    disc('speaker_rim', (-.205, -.19, -.005), .18, .035, 5, (math.pi / 2, 0, 0), 28)
    disc('speaker_cone', (-.205, -.216, -.005), .144, .025, 6, (math.pi / 2, 0, 0), 28)
    disc('speaker_center', (-.205, -.232, -.005), .075, .022, 5, (math.pi / 2, 0, 0))
    box('tuner_window', (.205, -.186, .10), (.27, .023, .12), 11, .015)
    for i in range(6):
        box('tuner_tick', (.115 + i * .035, -.202, .10), (.008, .01, .052), 7, .002, segments=1)
    box('tuner_pointer', (.19, -.211, .10), (.014, .009, .084), 0, .002)
    for x in (.12, .30):
        disc('control_knob', (x, -.20, -.105), .057, .06, 2, (math.pi / 2, 0, 0), 20)
    tube('carry_handle', [(-.29, 0, .25), (-.29, 0, .40), (.29, 0, .40), (.29, 0, .25)], .035, 5)


def normalize_and_join(model_id):
    bpy.context.view_layer.update()
    points = [o.matrix_world @ v.co for o in PARTS for v in o.data.vertices]
    low = Vector(min(v[i] for v in points) for i in range(3))
    high = Vector(max(v[i] for v in points) for i in range(3))
    center, factor = (low + high) / 2, 1 / max(high - low)
    component_names = [o.name for o in PARTS]
    for obj in PARTS:
        matrix = obj.matrix_world.copy()
        for v in obj.data.vertices:
            v.co = (matrix @ v.co - center) * factor
        obj.matrix_world.identity()
    bpy.ops.object.select_all(action='DESELECT')
    for obj in PARTS:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = PARTS[0]
    bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = obj.data.name = model_id
    # Uniform material and atlas produce one primitive / one draw call.
    for face in obj.data.polygons:
        face.material_index = 0
    while len(obj.data.materials) > 1:
        obj.data.materials.pop(index=1)
    obj['component_inventory'] = json.dumps(component_names)
    return obj


def geometry_metrics(obj):
    points = [obj.matrix_world @ v.co for v in obj.data.vertices]
    low = [min(v[i] for v in points) for i in range(3)]
    high = [max(v[i] for v in points) for i in range(3)]
    size = [high[i] - low[i] for i in range(3)]
    center = [(low[i] + high[i]) / 2 for i in range(3)]
    obj.data.calc_loop_triangles()
    degenerate = sum(t.area < 1e-12 for t in obj.data.loop_triangles)
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    # glTF splits vertices at normals / UV seams. Weld a temporary QA copy only.
    bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=1e-6)
    open_edges = sum(not edge.is_manifold for edge in bm.edges)
    bm.free()
    assert all(math.isfinite(c) for p in points for c in p), 'Nonfinite positions'
    assert abs(max(size) - 1) < 1e-4 and max(map(abs, center)) < 1e-4, (size, center)
    assert min(size) >= .08, f'Too thin: {size}'
    assert len(obj.data.loop_triangles) <= 6000, 'Triangle budget exceeded'
    assert len(obj.data.materials) == 1 and open_edges == 0 and degenerate == 0, (open_edges, degenerate)
    return dict(triangles=len(obj.data.loop_triangles), vertices=len(points),
                blenderBounds=size, center=center, openEdgesAfterWeld=open_edges,
                degenerateTriangles=degenerate)


def look_at(obj):
    obj.rotation_euler = (-obj.location).to_track_quat('-Z', 'Y').to_euler()


def render(obj, output, views=True):
    scene = bpy.context.scene
    engines = bpy.types.RenderSettings.bl_rna.properties['engine'].enum_items.keys()
    scene.render.engine = 'BLENDER_EEVEE_NEXT' if 'BLENDER_EEVEE_NEXT' in engines else 'BLENDER_EEVEE'
    scene.eevee.taa_render_samples = 24
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'
    scene.view_settings.view_transform = 'AgX'
    scene.view_settings.look = 'AgX - Medium High Contrast'
    scene.world.color = (.18, .18, .18)
    camera = bpy.data.objects.new('QA_Camera', bpy.data.cameras.new('QA_Camera'))
    scene.collection.objects.link(camera)
    camera.data.type = 'ORTHO'
    scene.camera = camera
    lights = []
    for loc, energy, color in [((3, -4, 5), 450, (1, .91, .80)),
                                ((-4, -1, 3), 300, (.72, .85, 1)),
                                ((1, 4, 4), 350, (.85, 1, .95))]:
        light = bpy.data.objects.new('QA_Light', bpy.data.lights.new('QA_Light', 'AREA'))
        scene.collection.objects.link(light)
        light.location = loc
        light.data.energy, light.data.size, light.data.color = energy, 4, color
        look_at(light)
        lights.append(light)
    directions = [('hero', (2.7, -4.2, 2.9)), ('top', (0, -.001, 5)),
                  ('front', (0, -5, .001)), ('back', (0, 5, .001)),
                  ('bottom', (0, -.001, -5))]
    for name, loc in directions if views else directions[:1]:
        camera.location = loc
        look_at(camera)
        bpy.context.view_layer.update()
        inverse = camera.matrix_world.inverted()
        pts = [inverse @ (obj.matrix_world @ Vector(c)) for c in obj.bound_box]
        width = max(p.x for p in pts) - min(p.x for p in pts)
        height = max(p.y for p in pts) - min(p.y for p in pts)
        camera.data.ortho_scale = max(width, height) * 1.25
        scene.render.resolution_x = scene.render.resolution_y = 512
        scene.render.resolution_percentage = 100
        scene.render.filepath = str(output / f'{obj.name}-{name}.png')
        bpy.ops.render.render(write_still=True)
        if name == 'hero':
            scene.render.resolution_x = scene.render.resolution_y = 192
            scene.render.filepath = str(output.parent / 'icons' / f'{obj.name}.png')
            bpy.ops.render.render(write_still=True)
    for item in [camera, *lights]:
        bpy.data.objects.remove(item, do_unlink=True)


def main():
    global PARTS, MAT
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--only', default=','.join(IDS))
    parser.add_argument('--skip-render', action='store_true')
    options = parser.parse_args(sys.argv[sys.argv.index('--') + 1:])
    output = options.output.resolve()
    for folder in ('models', 'icons', 'source', 'qa'):
        (output / folder).mkdir(parents=True, exist_ok=True)
    requested = options.only.split(',')
    if not requested or any(i not in IDS for i in requested):
        parser.error(f'--only must select from {IDS}')
    reports = []
    for model_id in requested:
        clear()
        PARTS = []
        MAT = palette(model_id)
        globals()[model_id]()
        obj = normalize_and_join(model_id)
        metrics = geometry_metrics(obj)
        bpy.ops.wm.save_as_mainfile(filepath=str(output / 'source' / f'{model_id}.blend'))
        bpy.ops.object.select_all(action='DESELECT')
        obj.select_set(True)
        glb = output / 'models' / f'{model_id}.glb'
        bpy.ops.export_scene.gltf(filepath=str(glb), export_format='GLB', use_selection=True,
                                 export_yup=True, export_apply=True, export_cameras=False,
                                 export_lights=False, export_extras=True,
                                 export_materials='EXPORT', export_image_format='AUTO')
        # Verify the actual exported GLB; renders come from the reimported resource.
        bpy.data.objects.remove(obj, do_unlink=True)
        bpy.ops.import_scene.gltf(filepath=str(glb))
        meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
        assert len(meshes) == 1, 'Expected one exported mesh'
        obj = meshes[0]
        obj.name = model_id
        imported_metrics = geometry_metrics(obj)
        assert metrics['triangles'] == imported_metrics['triangles']
        row = dict(id=model_id, **imported_metrics, bytes=glb.stat().st_size,
                   materials=1, textures=1, textureSize=[64, 64],
                   gltfAxes='Y-up, front +Z', blenderVersion=bpy.app.version_string,
                   roundtripPassed=True)
        assert row['bytes'] <= 256 * 1024
        (output / 'qa' / f'{model_id}.metrics.json').write_text(json.dumps(row, indent=2), encoding='utf-8')
        reports.append(row)
        if not options.skip_render:
            render(obj, output / 'qa')
        print('MODEL_PASS ' + json.dumps(row), flush=True)
    (output / 'qa' / 'generation.json').write_text(json.dumps(reports, indent=2), encoding='utf-8')


if __name__ == '__main__':
    main()
