using System.Collections.Generic;
using UnityEngine;

namespace CatchGoose
{
    // Reference AverageNormals groups vertices by their exact authored position.
    // Only effect geometry is modified; the lit mesh, UV seams and normals stay intact.
    public static class GooseSelectionGeometry
    {
        public sealed class Geometry
        {
            public Mesh mesh;
            public int[] groups;
            public int groupCount;
        }
        static readonly Dictionary<Mesh, Geometry> cache = new Dictionary<Mesh, Geometry>();
        public static int Count => cache.Count;

        public static Geometry Prepare(Mesh source)
        {
            if (!source) return null;
            if (cache.TryGetValue(source, out var existing)) return existing;
            if (!source.isReadable)
            {
                Debug.LogError("[GooseSelection] Prepare effect normals before releasing mesh CPU data: " + source.name);
                return null;
            }
            var vertices = source.vertices; var normals = source.normals;
            var positions = new Dictionary<Vector3, int>(vertices.Length);
            var indices = new int[vertices.Length]; var sums = new Vector3[vertices.Length];
            int count = 0;
            for (int i = 0; i < vertices.Length; i++)
            {
                if (!positions.TryGetValue(vertices[i], out int group)) { group = count++; positions.Add(vertices[i], group); }
                indices[i] = group;
                if (i < normals.Length) sums[group] += normals[i];
            }
            var copy = Object.Instantiate(source); copy.name = source.name + "_SelectionSmooth";
            if (normals.Length == vertices.Length)
            {
                for (int i = 0; i < normals.Length; i++) normals[i] = sums[indices[i]].normalized;
                copy.normals = normals;
            }
            copy.UploadMeshData(true);
            var geometry = new Geometry { mesh = copy, groups = indices, groupCount = count };
            cache.Add(source, geometry); return geometry;
        }

        public static void Prepare(GameObject model)
        {
            foreach (var filter in model.GetComponentsInChildren<MeshFilter>(true)) Prepare(filter.sharedMesh);
            foreach (var skin in model.GetComponentsInChildren<SkinnedMeshRenderer>(true)) Prepare(skin.sharedMesh);
        }
    }
}
