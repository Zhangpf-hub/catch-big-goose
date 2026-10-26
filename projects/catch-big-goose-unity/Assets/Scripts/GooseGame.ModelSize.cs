using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace CatchGoose
{
    public sealed partial class GooseGame
    {
        // A versioned preference: older installs start with the corrected size.
        public const float DefaultModelSize = 1.30f, MinimumModelSize = .70f, MaximumModelSize = 1.60f;
        public float ModelSize => modelSize < 0 ? GooseSave.ModelSize : modelSize;
        float modelSize = -1, previewStartSize;
        bool modelSizeDirty;
        sealed class SizePose
        {
            public GooseItem item;
            public Vector3 position, scale;
            public bool kinematic;
            public Collider[] colliders;
            public bool[] enabled;
        }
        readonly List<SizePose> sizePreview = new List<SizePose>();
        public static float ClampModelSize(float value) => float.IsNaN(value) || float.IsInfinity(value)
            ? DefaultModelSize : Mathf.Round(Mathf.Clamp(value, MinimumModelSize, MaximumModelSize) * 100) / 100;

        public bool PreviewModelSize(float value)
        {
            if (Playing && (!Paused || !SpawnComplete || Busy || PendingMatches > 0 || (SurfaceShuffle && SurfaceShuffle.Active) || (Shake && Shake.Active) || Depth.AnimationInProgress)) return false;
            value = ClampModelSize(value);
            if (Mathf.Approximately(value, ModelSize)) return true;
            if (Playing && sizePreview.Count == 0)
            {
                previewStartSize = ModelSize;
                foreach (var item in Remaining.OrderBy(i => i.transform.position.y))
                {
                    var cols = item.GetComponentsInChildren<Collider>();
                    sizePreview.Add(new SizePose { item = item, position = item.transform.position, scale = item.transform.localScale,
                        kinematic = item.Body.isKinematic, colliders = cols, enabled = cols.Select(c => c.enabled).ToArray() });
                    item.Body.collisionDetectionMode = CollisionDetectionMode.ContinuousSpeculative;
                    item.Body.isKinematic = true;
                }
            }
            modelSize = value; modelSizeDirty = true;
            float ratio = sizePreview.Count > 0 ? value / previewStartSize : 1;
            foreach (var pose in sizePreview)
            {
                var item = pose.item; if (!item) continue;
                item.transform.localScale = pose.scale * ratio;
                // Vertical dilation keeps the current frozen layers apart during preview.
                var p = pose.position; p.y = GooseCircularContainer.FloorY + (p.y - GooseCircularContainer.FloorY) * ratio;
                item.transform.position = p; item.Body.position = p;
            }
            Physics.SyncTransforms();
            return true;
        }

        public void CommitModelSize()
        {
            if (!modelSizeDirty) return;
            if (sizePreview.Count > 0)
            {
                float ratio = ModelSize / previewStartSize;
                // Refit actual collision shapes once on confirmation, not per drag frame.
                foreach (var pose in sizePreview) foreach (var col in pose.colliders) if (col) col.enabled = false;
                Physics.SyncTransforms();
                try
                {
                    foreach (var pose in sizePreview)
                    {
                        var item = pose.item; if (!item) continue;
                        for (int i = 0; i < pose.colliders.Length; i++) pose.colliders[i].enabled = pose.enabled[i];
                        if (Mathf.Approximately(ratio, 1)) continue;
                        Physics.SyncTransforms();
                        var p = item.transform.position;
                        p.y = Mathf.Max(p.y, p.y + GooseCircularContainer.FloorY + .012f - GooseColliderGeometry.MinY(item.SelectionCollider));
                        p = PlaceSizedItem(item, p, Physics.defaultPhysicsScene, Container.Radius, dropOverlaps);
                        item.transform.position = p; item.Body.position = p;
                        var bounds = item.SelectionCollider.bounds;
                        if (GooseGame.BoundsOf(item.Visual.gameObject).max.y > GoosePhoneLayout.MaximumPileHeight)
                            throw new System.InvalidOperationException($"Size bounds {item.Id}: radius={new Vector2(bounds.extents.x, bounds.extents.z).magnitude}, y={bounds.max.y}");
                        Physics.SyncTransforms();
                    }
                    Presentation?.ResizeReturnScales(ratio);
                    itemScale *= ratio;
                }
                catch (System.Exception e)
                {
                    foreach (var pose in sizePreview) if (pose.item)
                    { pose.item.transform.localScale = pose.scale; pose.item.transform.position = pose.position; pose.item.Body.position = pose.position; }
                    modelSize = previewStartSize;
                    Debug.LogWarning("[GooseSize] Preview restored: " + e.Message);
                    Hud.Toast("当前物堆放不下这个尺寸，已恢复原值");
                }
                foreach (var pose in sizePreview) if (pose.item)
                {
                    for (int i = 0; i < pose.colliders.Length; i++) pose.colliders[i].enabled = pose.enabled[i];
                    pose.item.Body.isKinematic = pose.kinematic;
                    if (!pose.kinematic) { pose.item.Body.collisionDetectionMode = GooseRuntimePerformance.DynamicCollision; pose.item.Body.velocity = pose.item.Body.angularVelocity = Vector3.zero; }
                }
                sizePreview.Clear(); Physics.SyncTransforms(); Depth.ModelSizeChanged();
            }
            if (modelSize >= 0) { GooseSave.ModelSize = modelSize; Preparation.Cancel(); }
            modelSizeDirty = false;
        }

        internal Vector3 PlaceSizedItem(GooseItem item, Vector3 desired, PhysicsScene physics, float radius, Collider[] overlaps)
        {
            var bounds = item.SelectionCollider.bounds;
            var offset = bounds.center - item.transform.position;
            desired = ClampModelFootprint(item, desired, radius);
            // AABB overlap alone hugely over-stacks bowls and long thin objects.
            // Use actual convex contact tests, moving upward only when shapes intersect.
            for (int attempt = 0; attempt < 512; attempt++)
            {
                int count = physics.OverlapBox(desired + offset, bounds.extents, overlaps, Quaternion.identity, ~0, QueryTriggerInteraction.Ignore);
                float lift = 0; var delta = desired - item.transform.position;
                for (int i = 0; i < count; i++)
                {
                    var other = overlaps[i]; var owner = other.GetComponentInParent<GooseItem>();
                    if (!owner || owner == item || owner.Picked) continue;
                    foreach (var col in item.Colliders) if (col.enabled && Physics.ComputePenetration(col, col.transform.position + delta, col.transform.rotation,
                        other, other.transform.position, other.transform.rotation, out var direction, out var distance))
                    {
                        float clear = Mathf.Max(.005f, other.bounds.max.y - (bounds.min.y + delta.y) + .005f);
                        lift = Mathf.Max(lift, direction.y > .1f ? Mathf.Min(clear, distance / direction.y + .005f) : Mathf.Min(clear, .12f));
                    }
                }
                if (count == overlaps.Length) throw new System.InvalidOperationException("Size collision buffer full");
                if (lift == 0) return desired;
                desired.y += lift;
            }
            throw new System.InvalidOperationException("Cannot fit resized item " + item.Id);
        }

        internal static Vector3 ClampModelFootprint(GooseItem item, Vector3 desired, float radius)
        {
            var col = item.SelectionCollider;
            if (!(col is MeshCollider mesh))
            {
                var offset = col.bounds.center - item.transform.position;
                float fallbackLimit = Mathf.Max(.02f, radius - new Vector2(col.bounds.extents.x,col.bounds.extents.z).magnitude - .025f);
                var point = Vector2.ClampMagnitude(new Vector2(desired.x+offset.x,desired.z+offset.z-GooseCircularContainer.CenterZ),fallbackLimit);
                desired.x=point.x-offset.x;desired.z=GooseCircularContainer.CenterZ+point.y-offset.z;return desired;
            }
            var vertices = mesh.sharedMesh.vertices;
            var matrix = col.transform.localToWorldMatrix;
            for (int i = 0; i < vertices.Length; i++) vertices[i] = matrix.MultiplyPoint3x4(vertices[i]) - item.transform.position;
            // Clamp the actual convex footprint. An enclosing AABB diagonal
            // wrongly funnels broad bowls into the centre and builds a tall tower.
            float limit = radius - .025f;
            for (int pass = 0; pass < 32; pass++)
            {
                float far = limit; Vector2 normal = Vector2.zero;
                foreach (var vertex in vertices)
                {
                    var point = new Vector2(desired.x + vertex.x, desired.z + vertex.z - GooseCircularContainer.CenterZ);
                    if (point.magnitude > far) { far = point.magnitude; normal = point.normalized; }
                }
                if (far <= limit + .002f) return desired;
                desired.x -= normal.x * (far - limit); desired.z -= normal.y * (far - limit);
            }
            throw new System.InvalidOperationException("Resized convex footprint does not fit " + item.Id);
        }
    }
}
