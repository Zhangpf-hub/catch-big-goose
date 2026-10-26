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
        const float OrbitSeconds = 1f, LandingSeconds = .3f, Clearance = .008f;

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
            public Quaternion rotation;
            public bool kinematic, gravity, detectCollisions;
            public RigidbodyInterpolation interpolation;
            public CollisionDetectionMode collision;
            public Shape[] shapes;
            public Bounds relativeBounds;
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
        readonly int[] permutation = new int[MaximumTargets];
        readonly Vector3[] planned = new Vector3[MaximumTargets];
        readonly List<Obstacle> supportObstacles = new List<Obstacle>(512);
        readonly System.Diagnostics.Stopwatch planningClock = new System.Diagnostics.Stopwatch();
        GooseGame game;
        GooseCircularContainer roundContainer;
        float elapsed, commonLift, orbitAngle, operationElapsed;
        System.Collections.IEnumerator planning;
        bool validatingFinish;
        string landingFailure, sceneBlocker;

        public bool Active { get; private set; }
        public IReadOnlyList<int> TargetIds => targetIds;
        public GooseShakeController.MotionResult LastMotion { get; private set; }
        public double LastPlanningMilliseconds { get; private set; }
        public double MaxPlanningSliceMilliseconds { get; private set; }
        public string LastFailure { get; private set; }
        public string LastBlockingCollider { get; private set; }
        public event System.Action<bool> Completed;

        public void Initialize(GooseGame owner) { game = owner; }

        public bool Begin()
        {
            if (Active || !game || !game.Playing || game.Paused || !game.SpawnComplete || !game.Depth || !game.Container)
                return false;
            game.CancelPointer(); game.Shake?.CancelRound();
            planningClock.Restart();
            candidates.Clear(); targets.Clear(); targetIds.Clear(); targetColliders.Clear(); LastMotion = null;
            LastFailure = LastBlockingCollider = landingFailure = sceneBlocker = "";
            MaxPlanningSliceMilliseconds = 0;
            game.Depth.CopySurface(candidates);
            roundContainer = game.Container;
            foreach (var item in candidates)
            {
                if (targets.Count == MaximumTargets) break;
                if (!Eligible(item)) continue;
                var body = item.Body;
                var target = new Target
                {
                    item = item, instanceId = item.GetInstanceID(), start = body.position, rotation = body.rotation,
                    velocity = body.velocity, angularVelocity = body.angularVelocity,
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
            if (targets.Count < 2)
            {
                planningClock.Stop(); LastPlanningMilliseconds = planningClock.Elapsed.TotalMilliseconds;
                LastFailure = "fewer_than_two_surface_targets";
                targets.Clear(); targetColliders.Clear(); return false;
            }
            planningClock.Stop(); LastPlanningMilliseconds = planningClock.Elapsed.TotalMilliseconds;

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
            orbitAngle = Random.value < .5f ? 56.25f : -56.25f;
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

        static Shape[] CaptureShapes(GooseItem item, Vector3 position, Quaternion rotation)
        {
            var result = new List<Shape>();
            bool hasEnabledShape = false;
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
            var target = targets[index]; safe = desired;
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
                    bool penetrating = false;
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

        void Update()
        {
            if (!Active) return;
            if (!SameRound() || !game.Playing) { CancelRound(); return; }
            if (game.Paused) return;
            operationElapsed += Time.deltaTime;
            if (operationElapsed > 2.45f)
            {
                LastFailure = "operation_deadline_exceeded elapsed=" + operationElapsed + " planningMs=" + LastPlanningMilliseconds;
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
            elapsed = Mathf.Min(OrbitSeconds + LandingSeconds, elapsed + Time.deltaTime);
            float orbit = Mathf.SmoothStep(0, 1, elapsed / OrbitSeconds);
            float landing = Mathf.SmoothStep(0, 1, (elapsed - OrbitSeconds) / LandingSeconds);
            var center = roundContainer.Center;
            Quaternion around = Quaternion.AngleAxis(orbitAngle * orbit, Vector3.up);
            foreach (var target in targets)
            {
                if (!Valid(target)) { CancelRound(); return; }
                Vector3 orbitPosition = center + around * (target.start - center);
                orbitPosition.y += commonLift * Mathf.SmoothStep(0, 1, elapsed / .18f);
                Vector3 position = Vector3.Lerp(orbitPosition, target.end, landing);
                Quaternion rotation = Quaternion.Slerp(around * target.rotation, target.rotation, landing);
                float min = float.PositiveInfinity;
                foreach (var shape in target.shapes) if (shape.enabled) min = Mathf.Min(min, MinimumY(shape, position, rotation));
                position.y += Mathf.Max(0, GooseCircularContainer.FloorY + Clearance - min);
                SetPose(target, position, rotation);
                target.travel = Mathf.Max(target.travel, Vector3.Distance(target.start, position));
                target.turn = Mathf.Max(target.turn, Quaternion.Angle(target.rotation, rotation));
            }
            if (elapsed >= OrbitSeconds + LandingSeconds) Finish();
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
                AddPlannedSupports(i);
                yield return null;
            }
        }

        void CompleteFinish()
        {
            var result = new GooseShakeController.MotionResult { affected = targets.Count };
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
            LastMotion = new GooseShakeController.MotionResult { interrupted = true };
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
