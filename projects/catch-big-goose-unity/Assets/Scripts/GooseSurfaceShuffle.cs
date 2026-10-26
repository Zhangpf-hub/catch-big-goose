using System.Collections.Generic;
using UnityEngine;

namespace CatchGoose
{
    /// <summary>
    /// A local permutation of the current surface, inspired by package 402's
    /// MessObjRotaAnim. Eligibility, bounded paths and convex landing checks are
    /// project adaptations. No dormant inventory is revealed or re-created.
    /// </summary>
    public sealed class GooseSurfaceShuffle : MonoBehaviour
    {
        const int MaximumTargets = 48;
        const float Clearance = .008f;

        sealed class Shape
        {
            public Collider collider;
            public bool enabled;
            public Vector3 localPosition;
            public Quaternion localRotation;
            public Matrix4x4 localMatrix;
            public Bounds localBounds;
            public Vector3[] vertices;
        }

        sealed class Target
        {
            public GooseItem item;
            public int instanceId, neighbour;
            public Vector3 start, end, velocity, angularVelocity;
            public Vector3 localCenterOfMass;
            public Quaternion rotation;
            public bool kinematic, gravity, detectCollisions;
            public RigidbodyInterpolation interpolation;
            public CollisionDetectionMode collision;
            public Shape[] shapes;
            public Bounds relativeBounds;
            public Vector3[] supportProbes;
            public float[] supportBottom;
            public float travel, turn;
        }

        struct Obstacle
        {
            public Collider collider;
            public Bounds bounds;
            public Vector3 position;
            public Quaternion rotation;
        }

        readonly List<GooseItem> candidates = new List<GooseItem>(MaximumTargets);
        readonly List<Target> targets = new List<Target>(MaximumTargets);
        readonly List<int> targetIds = new List<int>(MaximumTargets);
        readonly HashSet<Collider> targetColliders = new HashSet<Collider>();
        readonly Collider[] overlaps = new Collider[1024];
        readonly RaycastHit[] supportHits = new RaycastHit[64];
        readonly int[] permutation = new int[MaximumTargets];
        readonly Vector3[] planned = new Vector3[MaximumTargets];
        readonly List<Obstacle> supportObstacles = new List<Obstacle>(512);
        readonly System.Diagnostics.Stopwatch planningClock = new System.Diagnostics.Stopwatch();
        GooseGame game;
        GooseCircularContainer roundContainer;
        float elapsed, commonLift, orbitAngle, operationElapsed;
        float orbitSeconds = 1f, landingSeconds = .3f, operationLimit = 2.45f;
        float animationDuration = 1.3f;
        bool fromShake;
        bool phoneToss;
        int singleEnvelopePoints, singleEnvelopeUniquePoints;
        long singleEnvelopeCombinations;
        Vector3 tossDirection, tossFlipAxis;
        System.Collections.IEnumerator planning;
        bool validatingFinish;
        string landingFailure, sceneBlocker;

        public bool Active { get; private set; }
        public bool OwnerFromShake => Active && fromShake;
        public bool LastFromShake { get; private set; }
        public bool OwnerPhoneToss => Active && phoneToss;
        public bool LastPhoneToss { get; private set; }
        public IReadOnlyList<int> TargetIds => targetIds;
        public GooseShakeController.MotionResult LastMotion { get; private set; }
        public double LastPlanningMilliseconds { get; private set; }
        public double MaxPlanningSliceMilliseconds { get; private set; }
        public string LastFailure { get; private set; }
        public string LastBlockingCollider { get; private set; }
        public string LastSingleGeometry { get; private set; }
        public event System.Action<bool> Completed;

        public void Initialize(GooseGame owner) { game = owner; }

        public bool Begin() => BeginInternal(false, null, null, 2.45f);

        public bool BeginFromShake(IReadOnlyList<GooseItem> fixedTargets, GooseCircularContainer expectedContainer,
            float maximumSeconds = 1.55f)
            => BeginInternal(true, fixedTargets, expectedContainer, maximumSeconds);

        public bool BeginTossFromShake(IReadOnlyList<GooseItem> original, GooseCircularContainer expected,
            float maximumSeconds = 1.55f)
            => BeginInternal(true, original, expected, maximumSeconds, true);

        bool BeginInternal(bool phone, IReadOnlyList<GooseItem> fixedTargets, GooseCircularContainer expectedContainer,
            float maximumSeconds, bool controlledToss = false)
        {
            if (Active || !game || !game.Playing || game.Paused || !game.SpawnComplete || !game.Depth || !game.Container)
                return false;
            if (phone && (!expectedContainer || game.Container != expectedContainer || fixedTargets == null))
            { LastFailure = "shake_source_container_or_snapshot_invalid"; return false; }
            if (phone && (float.IsNaN(maximumSeconds) || maximumSeconds < .70f))
            { LastFailure = "shake_remaining_time_below_safe_minimum"; return false; }
            if (controlledToss && maximumSeconds < 1.10f)
            { LastFailure = "controlled_toss_remaining_time_below_safe_minimum"; return false; }
            game.CancelPointer();
            // The caller still owns the original accepted gesture and observes
            // motion from its original poses. Never recursively cancel it here.
            if (!phone) game.Shake?.CancelRound();
            planningClock.Restart();
            candidates.Clear(); targets.Clear(); targetIds.Clear(); targetColliders.Clear(); LastMotion = null;
            LastFailure = LastBlockingCollider = landingFailure = sceneBlocker = "";
            LastSingleGeometry = "";
            MaxPlanningSliceMilliseconds = 0;
            if (phone)
            {
                // Copy references now; the caller may clear/reuse its list after
                // this call. No surface rescan or replacement of rejected targets.
                for (int i = 0; i < fixedTargets.Count && candidates.Count < MaximumTargets; i++)
                {
                    var item = fixedTargets[i];
                    if (Eligible(item) && game.Items.Contains(item) && !candidates.Contains(item)) candidates.Add(item);
                }
            }
            else game.Depth.CopySurface(candidates);
            roundContainer = game.Container;
            foreach (var item in candidates)
            {
                if (targets.Count == MaximumTargets) break;
                if (!Eligible(item) || !game.Items.Contains(item)) continue;
                var body = item.Body;
                var target = new Target
                {
                    item = item, instanceId = item.GetInstanceID(), start = body.position, rotation = body.rotation,
                    velocity = body.velocity, angularVelocity = body.angularVelocity,
                    localCenterOfMass = Quaternion.Inverse(body.rotation) * (body.worldCenterOfMass - body.position),
                    kinematic = body.isKinematic, gravity = body.useGravity, detectCollisions = body.detectCollisions,
                    interpolation = body.interpolation, collision = body.collisionDetectionMode,
                    shapes = CaptureShapes(item, body.position, body.rotation)
                };
                if (target.shapes.Length == 0) continue;
                bool firstShape = true;
                foreach (var shape in target.shapes) if (shape.enabled)
                {
                    var bounds = ShapeBounds(shape, Vector3.zero, target.rotation);
                    if (firstShape) { target.relativeBounds = bounds; firstShape = false; }
                    else target.relativeBounds.Encapsulate(bounds);
                }
                targets.Add(target);
                foreach (var shape in target.shapes) targetColliders.Add(shape.collider);
            }
            if (targets.Count < (phone ? 1 : 2))
            {
                planningClock.Stop(); LastPlanningMilliseconds = planningClock.Elapsed.TotalMilliseconds;
                LastFailure = phone ? "shake_snapshot_has_no_eligible_target" : "fewer_than_two_surface_targets";
                targets.Clear(); targetColliders.Clear(); return false;
            }
            if (phone && targets.Count == 1)
            {
                var single = targets[0];
                // Derive actual collider geometry relative to the rendered root,
                // then evaluate that local geometry at the Rigidbody pose. An
                // interpolated Transform is not necessarily the current body pose.
                single.shapes = CaptureShapes(single.item, single.start, single.rotation, true);
                targetColliders.Clear(); bool first = true;
                foreach (var shape in single.shapes)
                {
                    targetColliders.Add(shape.collider);
                    if (!shape.enabled) continue;
                    var bounds = ShapeBounds(shape, Vector3.zero, single.rotation);
                    if (first) { single.relativeBounds = bounds; first = false; }
                    else single.relativeBounds.Encapsulate(bounds);
                }
                LastSingleGeometry = "item=" + single.item.Id + " bodyPosition=" + single.start + " bodyRotation=" + single.rotation
                    + " renderedPosition=" + single.item.transform.position + " renderedRotation=" + single.item.transform.rotation
                    + " rootRelativeBounds=" + single.relativeBounds + " shapes=" + single.shapes.Length;
                foreach (var shape in single.shapes)
                    LastSingleGeometry += " [" + shape.collider.GetType().Name + " localBounds=" + shape.localBounds
                        + " hullVertices=" + (shape.vertices == null ? 0 : shape.vertices.Length) + "]";
                if (GooseSave.IsQa) Debug.Log("[GooseSurfaceShuffle] single actual geometry " + LastSingleGeometry);
            }
            planningClock.Stop(); LastPlanningMilliseconds = planningClock.Elapsed.TotalMilliseconds;
            fromShake = phone; LastFromShake = phone;
            singleEnvelopePoints = singleEnvelopeUniquePoints = 0; singleEnvelopeCombinations = 0;
            phoneToss = controlledToss; LastPhoneToss = controlledToss;
            orbitSeconds = controlledToss ? .90f : phone ? .3f : 1f;
            landingSeconds = controlledToss ? 0 : phone ? .25f : .3f;
            // Mono can retain the sum in higher precision during comparisons.
            // Store one float duration for both clamping and completion; comparing
            // a clamped float against a freshly promoted 1f + .3f can never finish.
            animationDuration = orbitSeconds + landingSeconds;
            // Reserve one 30 Hz step so Update's deadline check cannot extend
            // an accepted phone fallback beyond the caller's remaining budget.
            operationLimit = phone ? Mathf.Min(maximumSeconds, 1.55f) - .04f : 2.45f;
            if (phoneToss)
            {
                var camera = game.MainCamera;
                tossDirection = camera ? Vector3.ProjectOnPlane(camera.transform.up, Vector3.up) : Vector3.forward;
                if (tossDirection.sqrMagnitude < .001f) tossDirection = Vector3.forward;
                tossDirection.Normalize();
                Vector3 mean = Vector3.zero;
                foreach (var target in targets) mean += target.start;
                mean /= targets.Count;
                // Pick the common screen direction with more room in the bowl.
                if (Vector3.Dot(tossDirection, roundContainer.Center - mean) < 0) tossDirection = -tossDirection;
                tossFlipAxis = Vector3.Cross(Vector3.up, tossDirection).normalized;
            }

            float lowest = float.PositiveInfinity, supportTop = GooseCircularContainer.FloorY;
            foreach (var target in targets)
                foreach (var shape in target.shapes)
                    if (shape.enabled) lowest = Mathf.Min(lowest, MinimumY(shape, target.start, target.rotation));
            // A common lift preserves the relative arrangement during the orbit.
            // The unselected support bodies keep their original physics state.
            foreach (var item in game.Items)
            {
                if (!item || item.Picked || !item.gameObject.activeInHierarchy || ContainsTarget(item)) continue;
                foreach (var collider in item.Colliders)
                    if (collider && collider.enabled && !collider.isTrigger) supportTop = Mathf.Max(supportTop, collider.bounds.max.y);
            }
            commonLift = Mathf.Clamp(supportTop - lowest + .10f, .14f, Mathf.Max(.45f, game.ItemScale));
            orbitAngle = (Random.value < .5f ? 1 : -1) * (phone ? Random.Range(22.5f, 33.75f) : 56.25f);
            foreach (var target in targets)
            {
                target.neighbour = Nearest(target, false);
                targetIds.Add(target.instanceId);
                target.item.SurfaceAnimating = true;
                var body = target.item.Body;
                body.velocity = body.angularVelocity = Vector3.zero;
                body.interpolation = RigidbodyInterpolation.None;
                body.collisionDetectionMode = CollisionDetectionMode.ContinuousSpeculative;
                body.isKinematic = true; body.useGravity = false; body.detectCollisions = false;
                foreach (var shape in target.shapes) if (shape.collider) shape.collider.enabled = false;
            }
            elapsed = operationElapsed = 0; Active = true; game.Depth.AnimationInProgress = true;
            validatingFinish = false; planning = PlanPermutation();
            return true;
        }

        static bool Eligible(GooseItem item)
            => item && !item.Picked && item.gameObject.activeInHierarchy && item.SurfaceActive && !item.SurfaceAnimating
               && item.DepthVisible && !item.DepthHeld && item.Body && !item.Body.isKinematic;

        static Shape[] CaptureShapes(GooseItem item, Vector3 position, Quaternion rotation, bool relativeToRenderedRoot = false)
        {
            var result = new List<Shape>();
            bool hasEnabledShape = false;
            if (relativeToRenderedRoot) { position = item.transform.position; rotation = item.transform.rotation; }
            var inverse = Matrix4x4.TRS(position, rotation, Vector3.one).inverse;
            foreach (var collider in item.Colliders)
            {
                if (!collider || collider.isTrigger) continue;
                var shape = new Shape
                {
                    collider = collider, enabled = collider.enabled,
                    localPosition = Quaternion.Inverse(rotation) * (collider.transform.position - position),
                    localRotation = Quaternion.Inverse(rotation) * collider.transform.rotation,
                    localMatrix = inverse * collider.transform.localToWorldMatrix
                };
                if (collider is MeshCollider mesh && mesh.sharedMesh && mesh.convex)
                { shape.localBounds = mesh.sharedMesh.bounds; shape.vertices = mesh.sharedMesh.vertices; }
                else if (collider is BoxCollider box) shape.localBounds = new Bounds(box.center, box.size);
                else if (collider is SphereCollider sphere)
                    shape.localBounds = new Bounds(sphere.center, Vector3.one * (sphere.radius * 2));
                else if (collider is CapsuleCollider capsule)
                {
                    var size = Vector3.one * (capsule.radius * 2); size[capsule.direction] = capsule.height;
                    shape.localBounds = new Bounds(capsule.center, size);
                }
                else return new Shape[0]; // Unknown geometry is never silently treated as collision-free.
                hasEnabledShape |= shape.enabled;
                result.Add(shape);
            }
            return hasEnabledShape ? result.ToArray() : new Shape[0];
        }

        System.Collections.IEnumerator PlanPermutation()
        {
            int count = targets.Count;
            if (fromShake && count == 1)
            {
                var envelope = PrepareSingleEnvelope(targets[0]);
                while (envelope.MoveNext()) yield return null;
                if (targets[0].supportBottom == null)
                { LastFailure = "shake_single_geometry_unavailable " + landingFailure; CancelRound(); yield break; }
                CacheSupports();
                var target = targets[0];
                Vector3 towardCenter = roundContainer.Center - target.start;
                float firstAngle = towardCenter.x * towardCenter.x + towardCenter.z * towardCenter.z > .0025f
                    ? Mathf.Atan2(towardCenter.z, towardCenter.x) : Random.value * Mathf.PI * 2;
                float step = game.ItemScale * .29f;
                for (int direction = 0; direction < 8; direction++)
                {
                    float angle = firstAngle + direction * Mathf.PI * .25f;
                    var desired = target.start + new Vector3(Mathf.Cos(angle), 0, Mathf.Sin(angle)) * step;
                    if (FindLanding(0, desired, 1.4f, out planned[0]) && ValidSingleNeighbour(target.start, planned[0])
                        && StableSingleSupport(target, planned[0]))
                    { target.end = planned[0]; LastFailure = ""; yield break; }
                    LastFailure = "shake_single_no_safe_neighbour direction=" + direction + " item=" + target.item.Id
                        + " desired=" + desired + " planned=" + planned[0] + " reason=" + landingFailure;
                    yield return null;
                }
                Debug.LogWarning("[GooseSurfaceShuffle] rejected " + LastFailure + " blocker=" + LastBlockingCollider);
                CancelRound(); yield break;
            }
            for (int attempt = 0; attempt < 4; attempt++)
            {
                CacheSupports();
                for (int i = 0; i < count; i++) permutation[i] = i;
                // Alternate whole-cohort cycles with size-neighbour cycles. All
                // candidates stay in the fixed snapshot; no difficult target is
                // silently discarded to make the result appear successful.
                if ((attempt & 1) == 0)
                    for (int i = count - 1; i > 0; i--)
                    { int j = Random.Range(0, i); int value = permutation[i]; permutation[i] = permutation[j]; permutation[j] = value; }
                else
                {
                    var order = new List<int>(count);
                    for (int i = 0; i < count; i++) order.Add(i);
                    order.Sort((a, b) => targets[a].relativeBounds.size.sqrMagnitude.CompareTo(targets[b].relativeBounds.size.sqrMagnitude));
                    int direction = attempt == 1 ? 1 : count - 1;
                    for (int i = 0; i < count; i++) permutation[order[i]] = order[(i + direction) % count];
                }
                int moved = 0; bool valid = true;
                for (int i = 0; i < count; i++)
                {
                    if (!FindLanding(i, targets[permutation[i]].start, 1.4f, out planned[i]))
                    {
                        LastFailure = "plan_attempt=" + attempt + " target=" + targets[i].item.Id + " instance=" + targets[i].instanceId
                            + " slot=" + permutation[i] + " start=" + targets[i].start + " desired=" + targets[permutation[i]].start
                            + " size=" + targets[i].relativeBounds.size + " radius=" + roundContainer.Radius + " reason=" + landingFailure;
                        valid = false; break;
                    }
                    AddPlannedSupports(i);
                    if ((planned[i] - targets[i].start).sqrMagnitude >= .01f) moved++;
                    yield return null;
                }
                if (!valid || moved < Mathf.Min(2, count)) { yield return null; continue; }
                for (int i = 0; i < count; i++) targets[i].end = planned[i];
                bool changed = HasRelativeOrderChange();
                foreach (var target in targets) if (Nearest(target, false) != Nearest(target, true)) changed = true;
                if (changed) { LastFailure = ""; yield break; }
                LastFailure = "no_relative_order_change";
                yield return null;
            }
            Debug.LogWarning("[GooseSurfaceShuffle] rejected " + LastFailure + " blocker=" + LastBlockingCollider);
            CancelRound();
        }

        bool ValidSingleNeighbour(Vector3 start, Vector3 end)
        {
            float distance = new Vector2(end.x - start.x, end.z - start.z).magnitude;
            return distance >= game.ItemScale * .2f && distance <= game.ItemScale * .3f + .001f;
        }

        bool StableSingleSupport(Target target, Vector3 position)
        {
            if (target.supportBottom != null)
                return SingleSupportPose(target, position, false, out _);
            // A penetration-free point can still be perched over the original
            // hole. Require a small, level support patch below the actual COM
            // before restoring gravity, including IgnoreRaycast collision walls.
            Vector3 com = position + target.rotation * target.localCenterOfMass;
            var bounds = target.relativeBounds; bounds.center += position;
            float minimum = float.PositiveInfinity;
            foreach (var shape in target.shapes)
                if (shape.enabled) minimum = Mathf.Min(minimum, MinimumY(shape, position, target.rotation));
            float margin = Mathf.Clamp(Mathf.Min(bounds.size.x, bounds.size.z) * .03f, .008f, .02f);
            float maximumGap = Mathf.Clamp(game.ItemScale * .06f, .025f, .065f);
            float rayY = Mathf.Max(bounds.max.y, com.y) + .025f;
            foreach (var obstacle in supportObstacles)
            {
                var b = obstacle.bounds;
                if (b.max.x < bounds.min.x || b.min.x > bounds.max.x || b.max.z < bounds.min.z || b.min.z > bounds.max.z) continue;
                var body = obstacle.collider.attachedRigidbody;
                if (!body || body.isKinematic) rayY = Mathf.Max(rayY, b.max.y + .025f);
            }
            float rayLength = Mathf.Max(.05f, rayY - minimum + maximumGap);
            float firstHeight = float.NaN;
            for (int probe = 0; probe < 5; probe++)
            {
                Vector3 origin = new Vector3(com.x, rayY, com.z);
                if (probe == 1) origin.x += margin;
                else if (probe == 2) origin.x -= margin;
                else if (probe == 3) origin.z += margin;
                else if (probe == 4) origin.z -= margin;
                int count = Physics.RaycastNonAlloc(new Ray(origin, Vector3.down), supportHits, rayLength,
                    ~0, QueryTriggerInteraction.Ignore);
                if (count == supportHits.Length)
                { landingFailure = "single_support_ray_buffer_saturated"; return false; }
                bool found = false; float distance = float.PositiveInfinity; RaycastHit support = default;
                for (int h = 0; h < count; h++)
                {
                    var hit = supportHits[h]; var collider = hit.collider;
                    if (!collider || targetColliders.Contains(collider)) continue;
                    var body = collider.attachedRigidbody;
                    if (body && !body.isKinematic) continue;
                    if (hit.distance < distance) { distance = hit.distance; support = hit; found = true; }
                }
                if (!found)
                { landingFailure = "single_com_support_gap probe=" + probe + " origin=" + origin; return false; }
                float gap = minimum - support.point.y;
                if (support.normal.y < .8f || gap > maximumGap || gap < -.02f
                    || (!float.IsNaN(firstHeight) && Mathf.Abs(firstHeight - support.point.y) > .025f))
                {
                    landingFailure = "single_unstable_com_support probe=" + probe + " collider=" + support.collider.name
                        + " gap=" + gap + " normal=" + support.normal;
                    return false;
                }
                if (probe == 0) firstHeight = support.point.y;
            }
            return true;
        }

        System.Collections.IEnumerator PrepareSingleEnvelope(Target target)
        {
            // These meshes are point clouds whose fan indices are placeholders:
            // PhysX cooks their convex hull. The lower convex envelope at an XZ
            // point is a linear program; an optimum uses at most three vertices.
            // Enumerating those triples therefore queries the real point hull,
            // without mistaking source indices or rotated AABB corners for faces.
            var clock = System.Diagnostics.Stopwatch.StartNew();
            var bounds = target.relativeBounds;
            float margin = Mathf.Clamp(Mathf.Min(bounds.size.x, bounds.size.z) * .03f, .008f, .02f);
            Vector3 com = target.rotation * target.localCenterOfMass;
            target.supportProbes = new[] { com, com + Vector3.right * margin, com - Vector3.right * margin,
                com + Vector3.forward * margin, com - Vector3.forward * margin };
            var bottoms = new float[5];
            for (int p = 0; p < 5; p++) bottoms[p] = float.PositiveInfinity;
            long combinations = 0; int pointCount = 0, uniquePointCount = 0;
            foreach (var shape in target.shapes)
            {
                if (!shape.enabled) continue;
                Vector3[] source = shape.vertices;
                if (source == null && shape.collider is BoxCollider)
                {
                    source = new Vector3[8];
                    for (int i = 0; i < 8; i++) source[i] = shape.localBounds.center + Vector3.Scale(shape.localBounds.extents,
                        new Vector3((i & 1) == 0 ? -1 : 1, (i & 2) == 0 ? -1 : 1, (i & 4) == 0 ? -1 : 1));
                }
                if (source == null || source.Length < 4)
                { landingFailure = "single_convex_envelope_unsupported " + shape.collider.GetType().Name; yield break; }
                // Default Vector3.Equals/GetHashCode compares exact coordinates;
                // unlike operator==, it does not weld nearby distinct hull points.
                var unique = new HashSet<Vector3>(source);
                if (unique.Count < 4)
                { landingFailure = "single_convex_envelope_fewer_than_four_unique_points"; yield break; }
                var vertices = new Vector3[unique.Count]; pointCount += source.Length; uniquePointCount += unique.Count;
                singleEnvelopePoints = pointCount;
                singleEnvelopeUniquePoints = uniquePointCount;
                var matrix = Matrix4x4.TRS(Vector3.zero, target.rotation, Vector3.one) * shape.localMatrix;
                int vertexIndex = 0;
                foreach (var vertex in unique) vertices[vertexIndex++] = matrix.MultiplyPoint3x4(vertex);
                for (int a = 0; a < vertices.Length - 2; a++)
                    for (int b = a + 1; b < vertices.Length - 1; b++)
                        for (int c = b + 1; c < vertices.Length; c++)
                        {
                            var v = vertices[a]; var ab = vertices[b] - v; var ac = vertices[c] - v;
                            float determinant = ab.x * ac.z - ab.z * ac.x;
                            if (Mathf.Abs(determinant) > .00000001f)
                                for (int p = 0; p < 5; p++)
                                {
                                    var delta = target.supportProbes[p] - v;
                                    float u = (delta.x * ac.z - delta.z * ac.x) / determinant;
                                    float w = (ab.x * delta.z - ab.z * delta.x) / determinant;
                                    if (u >= 0 && w >= 0 && u + w <= 1)
                                        bottoms[p] = Mathf.Min(bottoms[p], v.y + u * ab.y + w * ac.y);
                                }
                            combinations++;
                            singleEnvelopeCombinations = combinations;
                            if ((combinations & 127) == 0) yield return null;
                        }
            }
            for (int p = 0; p < 5; p++)
                if (float.IsInfinity(bottoms[p]))
                { landingFailure = "single_com_outside_convex_footprint probe=" + p; yield break; }
            target.supportBottom = bottoms;
            LastSingleGeometry += " envelopeRawPoints=" + pointCount + " envelopeUniquePoints=" + uniquePointCount + " envelopeCombinations=" + combinations
                + " envelopeWallMs=" + clock.Elapsed.TotalMilliseconds.ToString("F3")
                + " bottom=" + string.Join(",", bottoms);
            if (GooseSave.IsQa) Debug.Log("[GooseSurfaceShuffle] single convex envelope " + LastSingleGeometry);
        }

        bool SingleSupportPose(Target target, Vector3 position, bool solveHeight, out Vector3 safe)
        {
            safe = position;
            float maximumGap = Mathf.Clamp(game.ItemScale * .06f, .025f, .065f);
            float rayY = Mathf.Max(position.y + target.relativeBounds.max.y, position.y + (target.rotation * target.localCenterOfMass).y) + .025f;
            foreach (var obstacle in supportObstacles)
            {
                var b = obstacle.bounds; var footprint = target.relativeBounds; footprint.center += position;
                if (b.max.x >= footprint.min.x && b.min.x <= footprint.max.x && b.max.z >= footprint.min.z && b.min.z <= footprint.max.z)
                    rayY = Mathf.Max(rayY, b.max.y + .025f);
            }
            var heights = new float[5]; float firstHeight = float.NaN;
            float requiredY = float.NegativeInfinity;
            for (int probe = 0; probe < 5; probe++)
            {
                var point = position + target.supportProbes[probe];
                var origin = new Vector3(point.x, rayY, point.z);
                int count = Physics.RaycastNonAlloc(new Ray(origin, Vector3.down), supportHits,
                    Mathf.Max(.05f, rayY - GooseCircularContainer.FloorY + maximumGap), ~0, QueryTriggerInteraction.Ignore);
                if (count == supportHits.Length)
                { landingFailure = "single_support_ray_buffer_saturated"; return false; }
                bool found = false; float distance = float.PositiveInfinity; RaycastHit support = default;
                for (int h = 0; h < count; h++)
                {
                    var hit = supportHits[h]; var collider = hit.collider;
                    if (!collider || targetColliders.Contains(collider)) continue;
                    // Invisible boundary guards and the rim are containment,
                    // never substitute landing platforms for a missing support.
                    if (collider.name.StartsWith("CircularBoundary_") || collider.name.StartsWith("VisibleRim_")) continue;
                    var body = collider.attachedRigidbody;
                    if (body && !body.isKinematic) continue;
                    if (hit.distance < distance) { distance = hit.distance; support = hit; found = true; }
                }
                if (!found)
                { landingFailure = "single_com_support_gap probe=" + probe + " origin=" + origin; return false; }
                if (support.normal.y < .8f || (!float.IsNaN(firstHeight) && Mathf.Abs(firstHeight - support.point.y) > .025f))
                { landingFailure = "single_unstable_com_support probe=" + probe + " collider=" + support.collider.name
                    + " normal=" + support.normal + " height=" + support.point.y; return false; }
                if (probe == 0) firstHeight = support.point.y;
                heights[probe] = support.point.y;
                requiredY = Mathf.Max(requiredY, support.point.y - target.supportBottom[probe] + Clearance);
            }
            if (solveHeight) safe.y = requiredY;
            foreach (var shape in target.shapes) if (shape.enabled)
                safe.y += Mathf.Max(0, GooseCircularContainer.FloorY + Clearance - MinimumY(shape, safe, target.rotation));
            for (int probe = 0; probe < 5; probe++)
            {
                float gap = safe.y + target.supportBottom[probe] - heights[probe];
                if (gap < -.02f || gap > maximumGap)
                { landingFailure = "single_unstable_com_support probe=" + probe + " actualHullGap=" + gap; return false; }
            }
            return true;
        }

        void CacheSupports()
        {
            supportObstacles.Clear();
            // Item supports only: the six-metre guard walls must never be used
            // as a landing platform. Floor and scenery are checked separately.
            foreach (var item in game.Items)
            {
                if (!item || item.Picked || !item.gameObject.activeInHierarchy || ContainsTarget(item)) continue;
                foreach (var collider in item.Colliders)
                    if (collider && collider.enabled && !collider.isTrigger)
                        supportObstacles.Add(new Obstacle { collider = collider, bounds = collider.bounds,
                            position = collider.transform.position, rotation = collider.transform.rotation });
            }
            supportObstacles.Sort((a, b) => a.bounds.max.y.CompareTo(b.bounds.max.y));
        }

        void AddPlannedSupports(int index)
        {
            var target = targets[index];
            foreach (var shape in target.shapes) if (shape.enabled)
            {
                var obstacle = new Obstacle { collider = shape.collider,
                    bounds = ShapeBounds(shape, planned[index], target.rotation),
                    position = planned[index] + target.rotation * shape.localPosition,
                    rotation = target.rotation * shape.localRotation };
                int low = 0, high = supportObstacles.Count;
                while (low < high)
                { int mid = (low + high) / 2; if (supportObstacles[mid].bounds.max.y < obstacle.bounds.max.y) low = mid + 1; else high = mid; }
                supportObstacles.Insert(low, obstacle);
            }
        }

        bool HasRelativeOrderChange()
        {
            for (int i = 0; i < targets.Count; i++) for (int j = i + 1; j < targets.Count; j++)
            {
                Vector3 before = targets[i].start - targets[j].start, after = targets[i].end - targets[j].end;
                if (Vector3.Dot(before, after) < 0) return true;
            }
            return false;
        }

        bool FindLanding(int index, Vector3 desired, float maximumLift, out Vector3 safe)
        {
            if (phoneToss) desired = ClampTossCenter(desired);
            var target = targets[index]; safe = desired;
            if (fromShake && targets.Count == 1 && target.supportBottom != null)
            {
                if (!SingleSupportPose(target, desired, true, out safe)) return false;
                if (safe.y > desired.y + maximumLift + .0001f)
                { landingFailure = "maximum_lift_exceeded safeY=" + safe.y; return false; }
                if (!SceneClear(target, safe, out _, out _))
                { landingFailure = "single_convex_landing_blocked " + sceneBlocker; return false; }
                return true;
            }
            float highest = desired.y + maximumLift;
            float inset = 0;
            for (int correction = 0; correction < 6; correction++)
            {
                safe.y = Mathf.Max(safe.y, GooseCircularContainer.FloorY + Clearance - target.relativeBounds.min.y);
                // Ascending obstacle tops make each upward jump final: a later
                // jump cannot re-enter any already passed lower obstacle.
                foreach (var obstacle in supportObstacles)
                {
                    var bounds = target.relativeBounds; bounds.center += safe;
                    if (!bounds.Intersects(obstacle.bounds)) continue;
                    var obstacleBody = obstacle.collider.attachedRigidbody;
                    // Only the phone single-object path uses this conservative
                    // support projection. It must not accept a pose sunk into a
                    // static support merely because a narrow-phase query misses
                    // that contact while the target colliders are disabled.
                    bool penetrating = fromShake && targets.Count == 1 && (!obstacleBody || obstacleBody.isKinematic);
                    if (!penetrating)
                        foreach (var shape in target.shapes)
                            if (shape.enabled && Penetrates(shape, safe, target.rotation, obstacle.collider, obstacle.position, obstacle.rotation))
                            { penetrating = true; break; }
                    if (penetrating)
                    {
                        safe.y = obstacle.bounds.max.y - target.relativeBounds.min.y + Clearance;
                        LastBlockingCollider = "support=" + obstacle.collider.name + " parent="
                            + (obstacle.collider.transform.parent ? obstacle.collider.transform.parent.name : "<root>")
                            + " bounds=" + obstacle.bounds + " requiredRootY=" + safe.y;
                    }
                }
                if (safe.y > highest + .0001f)
                { landingFailure = "maximum_lift_exceeded safeY=" + safe.y + " highest=" + highest; return false; }
                if (SceneClear(target, safe, out bool sideBlocked, out float up)) return true;
                if (sideBlocked)
                {
                    if (inset >= .249f)
                    { landingFailure = "maximum_inset_exceeded at=" + safe + " blocker=" + sceneBlocker; return false; }
                    float step = Mathf.Min(.065f, .25f - inset); inset += step;
                    var radial = new Vector2(safe.x, safe.z - GooseCircularContainer.CenterZ);
                    radial = Vector2.ClampMagnitude(radial, Mathf.Max(0, radial.magnitude - step));
                    safe.x = radial.x; safe.z = GooseCircularContainer.CenterZ + radial.y;
                }
                else safe.y += Mathf.Max(Clearance, up + Clearance);
            }
            landingFailure = "correction_count_exceeded at=" + safe + " blocker=" + sceneBlocker; return false;
        }

        bool SceneClear(Target target, Vector3 position, out bool sideBlocked, out float up)
        {
            sideBlocked = false; up = 0; bool clear = true;
            if (new Vector2(position.x, position.z - GooseCircularContainer.CenterZ).magnitude > roundContainer.Radius + .01f)
            { sideBlocked = true; sceneBlocker = "root_outside_radius position=" + position; LastBlockingCollider = sceneBlocker; return false; }
            foreach (var shape in target.shapes)
            {
                if (!shape.enabled) continue;
                Bounds bounds = ShapeBounds(shape, position, target.rotation);
                int count = Physics.OverlapBoxNonAlloc(bounds.center, bounds.extents + Vector3.one * Clearance,
                    overlaps, Quaternion.identity, ~0, QueryTriggerInteraction.Ignore);
                if (count == overlaps.Length)
                { sceneBlocker = "overlap_buffer_saturated"; LastBlockingCollider = sceneBlocker; return false; }
                for (int c = 0; c < count; c++)
                {
                    var other = overlaps[c];
                    if (!other || targetColliders.Contains(other)) continue;
                    if (Physics.ComputePenetration(shape.collider, position + target.rotation * shape.localPosition,
                        target.rotation * shape.localRotation, other, other.transform.position, other.transform.rotation,
                        out var direction, out float distance) && distance > .002f)
                    {
                        clear = false;
                        sceneBlocker = other.name + " parent=" + (other.transform.parent ? other.transform.parent.name : "<root>")
                            + " position=" + other.transform.position + " bounds=" + other.bounds + " push=" + direction + " depth=" + distance;
                        LastBlockingCollider = sceneBlocker;
                        if (direction.y > .5f) up = Mathf.Max(up, distance / direction.y);
                        else sideBlocked = true;
                    }
                }
            }
            return clear;
        }

        static bool Penetrates(Shape shape, Vector3 position, Quaternion rotation, Collider other,
            Vector3 otherPosition, Quaternion otherRotation)
            => Physics.ComputePenetration(shape.collider, position + rotation * shape.localPosition,
                rotation * shape.localRotation, other, otherPosition, otherRotation, out _, out float distance) && distance > .002f;

        static Bounds ShapeBounds(Shape shape, Vector3 position, Quaternion rotation)
        {
            Matrix4x4 matrix = Matrix4x4.TRS(position, rotation, Vector3.one) * shape.localMatrix;
            Vector3 e = shape.localBounds.extents;
            return new Bounds(matrix.MultiplyPoint3x4(shape.localBounds.center), new Vector3(
                Mathf.Abs(matrix.m00) * e.x + Mathf.Abs(matrix.m01) * e.y + Mathf.Abs(matrix.m02) * e.z,
                Mathf.Abs(matrix.m10) * e.x + Mathf.Abs(matrix.m11) * e.y + Mathf.Abs(matrix.m12) * e.z,
                Mathf.Abs(matrix.m20) * e.x + Mathf.Abs(matrix.m21) * e.y + Mathf.Abs(matrix.m22) * e.z) * 2);
        }

        static float MinimumY(Shape shape, Vector3 position, Quaternion rotation)
        {
            if (shape.vertices == null) return ShapeBounds(shape, position, rotation).min.y;
            Matrix4x4 matrix = Matrix4x4.TRS(position, rotation, Vector3.one) * shape.localMatrix;
            float min = float.PositiveInfinity;
            foreach (var vertex in shape.vertices) min = Mathf.Min(min, matrix.MultiplyPoint3x4(vertex).y);
            return min;
        }

        Vector3 ClampTossCenter(Vector3 position)
        {
            var offset = new Vector2(position.x, position.z - GooseCircularContainer.CenterZ);
            offset = Vector2.ClampMagnitude(offset, Mathf.Max(.02f, roundContainer.Radius - .02f));
            position.x = offset.x; position.z = GooseCircularContainer.CenterZ + offset.y;
            return position;
        }

        void TossPose(Target target, float progress, out Vector3 position, out Quaternion rotation)
        {
            float u = Mathf.Clamp01(progress);
            float catchProgress = Mathf.SmoothStep(0, 1, (u - .5f) * 2);
            // Keep the launch arc coherent and visible in the actual 90-degree
            // production camera. Slot interpolation only starts after the apex,
            // so an opposite slot displacement cannot cancel the visible hop.
            position = Vector3.Lerp(target.start, target.end, catchProgress);
            position += tossDirection * (game.ItemScale * .26f * Mathf.Sin(Mathf.PI * u));
            float apex = Mathf.Max(target.start.y, target.end.y) + game.ItemScale * .78f;
            if (u <= .5f)
            {
                float remaining = 1 - u * 2;
                position.y = Mathf.Lerp(target.start.y, apex, 1 - remaining * remaining);
            }
            else
            {
                float fall = (u - .5f) * 2;
                position.y = Mathf.Lerp(apex, target.end.y, fall * fall);
            }
            position = ClampTossCenter(position);
            // Evaluate the full turn directly. Slerping between equivalent zero
            // and 360-degree quaternions would erase the visible flip entirely.
            rotation = Quaternion.AngleAxis(360f * u, tossFlipAxis) * target.rotation;
        }

        void Update()
        {
            if (!Active) return;
            if (!SameRound() || !game.Playing) { CancelRound(); return; }
            if (game.Paused) return;
            operationElapsed += Time.deltaTime;
            if (operationElapsed > operationLimit)
            {
                LastFailure = "operation_deadline_exceeded elapsed=" + operationElapsed.ToString("R")
                    + " animationElapsed=" + elapsed.ToString("R") + " animationDuration=" + animationDuration.ToString("R")
                    + " orbitSeconds=" + orbitSeconds.ToString("R") + " landingSeconds=" + landingSeconds.ToString("R")
                    + " planning=" + (planning != null) + " validatingFinish=" + validatingFinish + " fromShake=" + fromShake
                    + " phoneToss=" + phoneToss + " targets=" + targets.Count + " planningMs=" + LastPlanningMilliseconds;
                LastFailure += " singleEnvelopePoints=" + singleEnvelopePoints + " singleEnvelopeCombinations=" + singleEnvelopeCombinations
                    + " singleEnvelopeUniquePoints=" + singleEnvelopeUniquePoints
                    + " singleEnvelopeReady=" + (targets.Count == 1 && targets[0].supportBottom != null);
                Debug.LogWarning("[GooseSurfaceShuffle] " + LastFailure + " blocker=" + LastBlockingCollider);
                CancelRound(); return;
            }
            if (planning != null)
            {
                long start = System.Diagnostics.Stopwatch.GetTimestamp();
                var routine = planning;
                while (Active && routine == planning)
                {
                    if (!routine.MoveNext())
                    {
                        planning = null;
                        if (Active) { if (validatingFinish) CompleteFinish(); else elapsed = 0; }
                        break;
                    }
                    if ((System.Diagnostics.Stopwatch.GetTimestamp() - start) * 1000.0 / System.Diagnostics.Stopwatch.Frequency >= 2) break;
                }
                double slice = (System.Diagnostics.Stopwatch.GetTimestamp() - start) * 1000.0 / System.Diagnostics.Stopwatch.Frequency;
                LastPlanningMilliseconds += slice; MaxPlanningSliceMilliseconds = System.Math.Max(MaxPlanningSliceMilliseconds, slice);
                return;
            }
            elapsed = Mathf.Min(animationDuration, elapsed + Time.deltaTime);
            float orbit = phoneToss ? 0 : Mathf.SmoothStep(0, 1, elapsed / orbitSeconds);
            float landing = phoneToss ? 0 : Mathf.SmoothStep(0, 1, (elapsed - orbitSeconds) / landingSeconds);
            var center = roundContainer.Center;
            Quaternion around = Quaternion.AngleAxis(orbitAngle * orbit, Vector3.up);
            foreach (var target in targets)
            {
                if (!Valid(target)) { CancelRound(); return; }
                Vector3 position; Quaternion rotation;
                if (phoneToss) TossPose(target, elapsed / animationDuration, out position, out rotation);
                else
                {
                    Vector3 orbitPosition = center + around * (target.start - center);
                    orbitPosition.y += commonLift * Mathf.SmoothStep(0, 1, elapsed / .18f);
                    position = Vector3.Lerp(orbitPosition, target.end, landing);
                    rotation = Quaternion.Slerp(around * target.rotation, target.rotation, landing);
                }
                float min = float.PositiveInfinity;
                foreach (var shape in target.shapes) if (shape.enabled) min = Mathf.Min(min, MinimumY(shape, position, rotation));
                position.y += Mathf.Max(0, GooseCircularContainer.FloorY + Clearance - min);
                SetPose(target, position, rotation);
                target.travel = Mathf.Max(target.travel, Vector3.Distance(target.start, position));
                target.turn = Mathf.Max(target.turn, Quaternion.Angle(target.rotation, rotation));
            }
            if (elapsed >= animationDuration - .0001f) Finish();
        }

        void Finish()
        {
            validatingFinish = true; planning = ValidateFinish();
        }

        System.Collections.IEnumerator ValidateFinish()
        {
            // Recheck against the current scene before restoring physical contacts.
            // Queries ignore the disabled targets; pair checks use their planned poses.
            CacheSupports();
            for (int i = 0; i < targets.Count; i++)
            {
                if (!FindLanding(i, targets[i].end, 1.4f, out planned[i]))
                {
                    LastFailure = "finish target=" + targets[i].item.Id + " reason=" + landingFailure;
                    Debug.LogWarning("[GooseSurfaceShuffle] " + LastFailure + " blocker=" + LastBlockingCollider);
                    CancelRound(); yield break;
                }
                if (fromShake && targets.Count == 1 && !ValidSingleNeighbour(targets[i].start, planned[i]))
                {
                    LastFailure = "shake_single_neighbour_changed_beyond_planar_bounds_at_finish";
                    Debug.LogWarning("[GooseSurfaceShuffle] " + LastFailure);
                    CancelRound(); yield break;
                }
                if (fromShake && targets.Count == 1 && !StableSingleSupport(targets[i], planned[i]))
                {
                    LastFailure = "shake_single_support_changed_before_gravity_restore " + landingFailure;
                    Debug.LogWarning("[GooseSurfaceShuffle] " + LastFailure);
                    CancelRound(); yield break;
                }
                AddPlannedSupports(i);
                yield return null;
            }
        }

        void CompleteFinish()
        {
            var result = new GooseShakeController.MotionResult { affected = targets.Count,
                mode = phoneToss ? "controlled-pan-toss" : fromShake ? "physics-fallback-reorder" : "surface-shuffle",
                tossCompleted = phoneToss };
            float movedDistance = Mathf.Max(.03f, game.ItemScale * .15f);
            for (int i = 0; i < targets.Count; i++) targets[i].end = planned[i];
            for (int i = 0; i < targets.Count; i++)
            {
                var target = targets[i];
                SetPose(target, target.end, target.rotation);
                target.travel = Mathf.Max(target.travel, Vector3.Distance(target.start, target.end));
                result.maxTravel = Mathf.Max(result.maxTravel, target.travel); result.meanTravel += target.travel;
                result.maxTurn = Mathf.Max(result.maxTurn, target.turn);
                if (target.travel >= movedDistance) result.moved++;
                if (target.turn >= 5) result.turned++;
                if (Nearest(target, true) != target.neighbour) result.changedNeighbours++;
                Restore(target, false);
            }
            result.meanTravel /= targets.Count; LastMotion = result;
            EndState();
            Completed?.Invoke(true);
        }

        void Restore(Target target, bool cancelled)
        {
            if (!Valid(target)) return;
            var item = target.item; var body = item.Body;
            if (cancelled) SetPose(target, target.start, target.rotation);
            else item.RestoreNormalPhysics();
            foreach (var shape in target.shapes) if (shape.collider) shape.collider.enabled = shape.enabled;
            body.useGravity = target.gravity; body.detectCollisions = target.detectCollisions;
            body.isKinematic = target.kinematic;
            body.collisionDetectionMode = cancelled ? target.collision : GooseRuntimePerformance.DynamicCollision;
            body.interpolation = cancelled ? target.interpolation : RigidbodyInterpolation.Interpolate;
            if (!body.isKinematic)
            {
                body.velocity = cancelled ? target.velocity : Vector3.zero;
                body.angularVelocity = cancelled ? target.angularVelocity : Vector3.zero;
                body.WakeUp();
            }
            item.SurfaceAnimating = false;
            if (!cancelled)
            {
                item.DepthProtectedUntil = Mathf.Max(item.DepthProtectedUntil, Time.time + .65f);
                item.DepthStillSince = Time.time; item.NextOcclusionCheck = 0;
            }
        }

        public void CancelRound()
        {
            if (!Active) return;
            foreach (var target in targets) Restore(target, true);
            LastMotion = new GooseShakeController.MotionResult { interrupted = true,
                mode = phoneToss ? "controlled-pan-toss" : fromShake ? "physics-fallback-reorder" : "surface-shuffle",
                tossFailure = phoneToss ? LastFailure : null };
            EndState();
            Completed?.Invoke(false);
        }

        void EndState()
        {
            Active = false; planning = null; validatingFinish = false;
            if (SameRound() && game.Depth) { game.Depth.AnimationInProgress = false; game.Depth.Invalidate(); }
            targets.Clear(); targetColliders.Clear();
        }

        bool SameRound() => game && roundContainer && game.Container == roundContainer;
        bool Valid(Target target) => SameRound() && target.item && target.item.GetInstanceID() == target.instanceId
            && !target.item.Picked && target.item.gameObject.activeInHierarchy && game.Items.Contains(target.item);
        bool ContainsTarget(GooseItem item)
        { foreach (var target in targets) if (target.item == item) return true; return false; }
        int Nearest(Target target, bool after)
        {
            int id = 0; float best = float.PositiveInfinity; Vector3 position = after ? target.end : target.start;
            foreach (var other in targets)
            {
                if (other == target) continue;
                float distance = ((after ? other.end : other.start) - position).sqrMagnitude;
                if (distance < best) { best = distance; id = other.instanceId; }
            }
            return id;
        }
        static void SetPose(Target target, Vector3 position, Quaternion rotation)
        { target.item.Body.position = position; target.item.Body.rotation = rotation; target.item.transform.SetPositionAndRotation(position, rotation); }
        void OnDisable() { CancelRound(); }
    }
}
