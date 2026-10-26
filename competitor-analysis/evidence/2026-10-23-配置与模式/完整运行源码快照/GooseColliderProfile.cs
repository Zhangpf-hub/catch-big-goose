using UnityEngine;

namespace CatchGoose
{
    /// <summary>
    /// Original, conservative primitive profiles informed by the reference asset audit.
    /// Other models retain the migrated convex proxy until their profile is validated.
    /// Coordinates are measured from the normalized visual, before instance scaling.
    /// </summary>
    public static class GooseColliderProfile
    {
        public static bool TryBuild(GameObject owner, string id, GameObject visual, PhysicMaterial material)
        {
            bool capsule = id == "corn" || id == "carrot" || id == "eggplant";
            bool box = id == "phone" || id == "handheld" || id == "speaker" || id == "radio";
            if (!capsule && !box) return false;
            var bounds = LocalBounds(owner.transform, visual);
            Collider collider;
            if (capsule)
            {
                var c = owner.AddComponent<CapsuleCollider>();
                Vector3 size = bounds.size;
                int axis = size.x >= size.y && size.x >= size.z ? 0 : size.y >= size.z ? 1 : 2;
                c.direction = axis;
                c.center = bounds.center;
                c.radius = Mathf.Max(size[(axis + 1) % 3], size[(axis + 2) % 3]) * .5f;
                c.height = Mathf.Max(size[axis], c.radius * 2);
                collider = c;
            }
            else
            {
                var c = owner.AddComponent<BoxCollider>();
                c.center = bounds.center;
                c.size = bounds.size;
                collider = c;
            }
            collider.sharedMaterial = material;
            return true;
        }

        static Bounds LocalBounds(Transform owner, GameObject visual)
        {
            var bounds = new Bounds();
            bool first = true;
            foreach (var filter in visual.GetComponentsInChildren<MeshFilter>())
            {
                var b = filter.sharedMesh.bounds;
                var matrix = owner.worldToLocalMatrix * filter.transform.localToWorldMatrix;
                for (int i = 0; i < 8; i++)
                {
                    Vector3 corner = b.center + Vector3.Scale(b.extents,
                        new Vector3((i & 1) == 0 ? -1 : 1, (i & 2) == 0 ? -1 : 1, (i & 4) == 0 ? -1 : 1));
                    Vector3 point = matrix.MultiplyPoint3x4(corner);
                    if (first) { bounds = new Bounds(point, Vector3.zero); first = false; }
                    else bounds.Encapsulate(point);
                }
            }
            if (first) throw new System.InvalidOperationException("Collider profile has no mesh: " + visual.name);
            return bounds;
        }
    }
}
