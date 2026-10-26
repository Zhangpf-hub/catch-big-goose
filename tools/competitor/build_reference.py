"""Run in Blender: rebuild static reference items, retain UV, export and render.

Preview is base-color with neutral studio lighting, not a recreation of ToonLite1.
"""
import argparse
import json
import math
import sys
from pathlib import Path
import bpy
from mathutils import Matrix, Quaternion, Vector


def write(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')


def measure():
    meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    for o in meshes:
        o.data.calc_loop_triangles()
    points = [o.matrix_world @ Vector(c) for o in meshes for c in o.bound_box]
    lo = Vector([min(p[i] for p in points) for i in range(3)])
    hi = Vector([max(p[i] for p in points) for i in range(3)])
    return meshes, lo, hi, sum(len(o.data.loop_triangles) for o in meshes)


def clear():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for collection in (bpy.data.meshes, bpy.data.materials, bpy.data.images, bpy.data.cameras, bpy.data.lights):
        for block in list(collection):
            if block.users == 0:
                collection.remove(block)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--reference', type=Path, required=True)
    p.add_argument('--generation-reference', action='store_true', help='Add back/side views and 192/64px generation reference icons')
    p.add_argument('--skip-previews', action='store_true', help='Export and round-trip only; runtime conversion renders are produced separately')
    p.add_argument('--manifest', default='manifest.json', help='Selection manifest inside the reference folder')
    a = p.parse_args(sys.argv[sys.argv.index('--') + 1:])
    a.reference = a.reference.resolve()
    bpy.context.preferences.filepaths.save_version = 0
    manifest = json.loads((a.reference / a.manifest).read_text(encoding='utf-8'))
    # Unity LH Y-up -> Blender RH Z-up. Reflection requires reversed winding.
    basis = Matrix(((-1, 0, 0, 0), (0, 0, -1, 0), (0, 1, 0, 0), (0, 0, 0, 1)))
    results = []
    for item in manifest['models']:
        clear()
        folder = a.reference / 'models' / item['id']
        data = json.loads((folder / 'source.json').read_text(encoding='utf-8'))
        transforms = []
        for n in data['nodes']:
            q = n['rotation']
            local = Matrix.LocRotScale(Vector(n['position']), Quaternion((q[3], q[0], q[1], q[2])), Vector(n['scale']))
            transforms.append(local if n['parent'] is None else transforms[n['parent']] @ local)
        mats = {}
        for key, m in data['materials'].items():
            mat = bpy.data.materials.new(m['name'])
            mat.use_nodes = True
            bsdf = next(n for n in mat.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
            bsdf.inputs['Roughness'].default_value = .65
            bsdf.inputs['Metallic'].default_value = 0
            color = m.get('colors', {}).get('_BaseColor') or m.get('colors', {}).get('_Color')
            if color:
                bsdf.inputs['Base Color'].default_value = color
            if m.get('shader') == 'ToonGlass':
                # Presentation approximation only: retain the source alpha tint
                # so transparent wrappers do not become opaque white covers.
                alpha = m.get('colors', {}).get('_BaseTint', [1, 1, 1, 1])[3]
                bsdf.inputs['Alpha'].default_value = max(0, min(1, alpha))
                mat.surface_render_method = 'DITHERED'
            info = m['textures'].get('_BaseColor') or m['textures'].get('_MainTex')
            if info:
                tex = mat.node_tree.nodes.new('ShaderNodeTexImage')
                tex.image = bpy.data.images.load(str(folder / info['file']), check_existing=True)
                tex.image.pack()
                mat.node_tree.links.new(tex.outputs['Color'], bsdf.inputs['Base Color'])
                mat.node_tree.nodes.active = tex
                # Keep the original UV scale/offset in the mesh below.
            mats[key] = mat
        removed_duplicates = 0
        for source in data['meshes']:
            transform = basis @ transforms[source['node']]
            verts = [transform @ Vector(v[:3]) for v in source['positions']]
            faces, material_ids = [], []
            seen_faces = set()
            for index, triangles in enumerate(source['triangles']):
                for face in triangles:
                    face_key = tuple(sorted(face))
                    if face_key in seen_faces:
                        removed_duplicates += 1
                        continue
                    seen_faces.add(face_key)
                    faces.append(tuple(reversed(face)))
                    material_ids.append(index)
            mesh = bpy.data.meshes.new(source['name'])
            mesh.from_pydata(verts, [], faces)
            mesh.update()
            obj = bpy.data.objects.new(source['name'], mesh)
            bpy.context.collection.objects.link(obj)
            for key in source['materials']:
                mesh.materials.append(mats[key])
            uv = mesh.uv_layers.new(name='UVMap')
            for poly, material_index in zip(mesh.polygons, material_ids):
                poly.material_index = material_index
                poly.use_smooth = True
                material = data['materials'][source['materials'][material_index]]
                tex = material['textures'].get('_BaseColor') or material['textures'].get('_MainTex') or {}
                scale, offset = tex.get('scale', [1, 1]), tex.get('offset', [0, 0])
                for loop_index in poly.loop_indices:
                    coord = source['uv'][mesh.loops[loop_index].vertex_index]
                    uv.data[loop_index].uv = (coord[0] * scale[0] + offset[0], coord[1] * scale[1] + offset[1])
            if source.get('normals'):
                normal_transform = transform.to_3x3().inverted().transposed()
                normals = [(normal_transform @ Vector(n[:3])).normalized() for n in source['normals']]
                mesh.normals_split_custom_set_from_vertices(normals)
        bpy.context.view_layer.update()
        meshes, lo, hi, count = measure()
        assert count + removed_duplicates == item['triangles'], (item['id'], count)
        # Preserve authored dimensions in exports. Presentation fitting is camera-only.
        bpy.ops.wm.save_as_mainfile(filepath=str(folder / (item['id'] + '.blend')))
        bpy.ops.object.select_all(action='DESELECT')
        for o in meshes:
            o.select_set(True)
        bpy.ops.export_scene.gltf(filepath=str(folder / (item['id'] + '.glb')), export_format='GLB',
                                  use_selection=True, export_yup=True, export_animations=False, export_extras=False)
        bpy.ops.wm.obj_export(filepath=str(folder / (item['id'] + '.obj')), export_selected_objects=True,
                              forward_axis='NEGATIVE_Z', up_axis='Y')
        # Verify the actual exported GLB before rendering it.
        before_size = list(hi - lo)
        clear()
        bpy.ops.import_scene.gltf(filepath=str(folder / (item['id'] + '.glb')))
        meshes, lo, hi, roundtrip_count = measure()
        error = max(abs(x - y) for x, y in zip(before_size, hi - lo))
        assert roundtrip_count == count and error < .00001, (item['id'], count, roundtrip_count, error)
        assert all(o.data.uv_layers for o in meshes)
        if a.skip_previews:
            results.append(dict(id=item['id'], sourceTriangles=item['triangles'], exportedTriangles=roundtrip_count,
                                duplicateFacesRemoved=removed_duplicates, dimensionError=error, meshes=len(meshes), uvPreserved=True))
            continue
        scene = bpy.context.scene
        scene.render.engine = 'CYCLES'
        scene.cycles.samples = 16
        scene.cycles.use_denoising = True
        scene.render.resolution_x = scene.render.resolution_y = 256
        scene.render.resolution_percentage = 100
        scene.render.film_transparent = True
        scene.render.image_settings.file_format = 'PNG'
        scene.view_settings.view_transform = 'Standard'
        scene.world.color = (.55, .55, .55)
        center, size = (lo + hi) / 2, max(hi - lo)
        lamp = bpy.data.lights.new('Neutral softbox', 'AREA')
        lamp.energy = 350 * size * size
        lamp.shape = 'DISK'
        lamp.size = size * 3
        light = bpy.data.objects.new('Neutral softbox', lamp)
        scene.collection.objects.link(light)
        light.location = center + Vector((1, -1.5, 3)) * size
        light.rotation_euler = (center - light.location).to_track_quat('-Z', 'Y').to_euler()
        camera = bpy.data.objects.new('ReferenceCamera', bpy.data.cameras.new('ReferenceCamera'))
        scene.collection.objects.link(camera)
        camera.data.type = 'ORTHO'
        camera.data.ortho_scale = size * 1.48
        scene.camera = camera
        views = [('three-quarter', (1.1, -1.4, 1.5)), ('top', (0, -.001, 3))]
        if a.generation_reference:
            views += [('back', (-1.1, 1.4, .9)), ('side', (3, 0, .35))]
        for label, direction in views:
            camera.location = center + Vector(direction) * size
            camera.rotation_euler = (center - camera.location).to_track_quat('-Z', 'Y').to_euler()
            scene.render.filepath = str(folder / (label + '.png'))
            bpy.ops.render.render(write_still=True)
        if a.generation_reference:
            icon = bpy.data.images.load(str(folder / 'three-quarter.png'), check_existing=False)
            for pixels in (192, 64):
                icon.scale(pixels, pixels)
                icon.filepath_raw = str(folder / f'icon-{pixels}.png')
                icon.file_format = 'PNG'
                icon.save()
            bpy.data.images.remove(icon)
        results.append(dict(id=item['id'], sourceTriangles=item['triangles'], exportedTriangles=roundtrip_count,
                            duplicateFacesRemoved=removed_duplicates,
                            dimensionError=error, meshes=len(meshes), uvPreserved=True,
                            preview='base-color, neutral lighting; original Toon/MatCap shader not reproduced'))
    write(a.reference / 'export-verification.json', dict(passed=len(results) == len(manifest['models']), models=results))
    print('REFERENCE_EXPORT_VERIFIED', len(results))


if __name__ == '__main__':
    main()
