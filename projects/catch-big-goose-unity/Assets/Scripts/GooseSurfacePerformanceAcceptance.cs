#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;

namespace CatchGoose
{
    // Correctness instrumentation deliberately does not claim phone FPS. The passive
    // idle sample avoids per-frame hull probes; operation samples include QA work.
    public sealed class GooseSurfacePerformanceAcceptance : MonoBehaviour
    {
        [Serializable] sealed class Row
        {
            public string theme, operation, shuffleLastFailure, shuffleBlockingCollider, preCorrectionItemId, worstItemId, endWorstItemId; public int stock, surface, independentExposed, exposedSelected, affected, moved, turned, changedNeighbours;
            public int visible, renderers, drawSlots, triangles, dynamicBodies, awake, held, hidden, recoveries, probes, exposureDelta, untouchedLower, lowerViolations;
            public float p50ms, p95ms, maxms, slowFrameFraction, beginCpuMs, depthRefreshMs, activeSurfaceThreshold, modelSize, minHullY = 100, maxTravel, meanTravel, maxTurn, managedMiB, unityMiB;
            public double shufflePlanningMs, shuffleMaxSliceMs;
            public int gcCollections, planarMovedEnough; public float maxPlanarTravel; public bool frameTimingMeasured; public int[] targetIds;
            public string[] targetNames; public bool fallbackAttempted, fallbackCompleted; public string fallbackFailure;
            public BodyState[] initialStates, helperStartStates, helperEndStates, settledStates;
            public Vector3 nudgeStart, nudgeEnd; public float gestureSeconds, helperEndSeconds;
            public float preCorrectionMinY, afterLateMinY, preCorrectionBodyMinY, bodyMinY, endPreCorrectionMinY, endAfterLateMinY, endBodyMinY;
            public float maxRise, peakXZ, peakXZPixels, itemScale; public int liftedEnough, turnedEnough, jointEnough, visibleArcEnough, tossFloorViolations, tossBoundaryViolations;
            public bool tossHelperStarted, controlledTossObserved, tossCompleted; public string motionMode, tossFailure; public TossTarget[] tossTargets;
            public List<BoundaryEvent> boundaryEvents = new List<BoundaryEvent>();
        }
        struct FloorSample { public float visual, body; public string itemId; }
        [Serializable] sealed class BodyState
        {
            public string item; public int constraints;
            public Vector3 position, velocity, angularVelocity; public Quaternion rotation, visualRotation;
            public bool kinematic, gravity;
        }
        [Serializable] sealed class ClipFrame { public string file; public float seconds; }
        [Serializable] sealed class TossTarget
        {
            public int instanceId; public string item; public Vector3 initialPosition, peakPosition, finalPosition;
            public Quaternion initialRotation; public float maxRise, maxTurn, peakXZ, peakXZPixels, peakRiseSeconds, airborneFlipSeconds;
            public bool airborneFlip;
            public float maxRadial, maxRadialSeconds; public Vector3 maxRadialPosition;
        }
        [Serializable] sealed class BoundaryEvent
        {
            public int instanceId; public string item; public float seconds, radial, containerRadius;
            public Vector3 position, velocity; public Quaternion rotation;
            public bool ownerPhoneToss, surfaceAnimating, kinematic, gravity;
        }
        [Serializable] sealed class Report
        {
            public string build = GooseRuntimePerformance.BuildId;
            public string scope = "Native graphics player, forced mobile profile. Synthetic sensor and production prop/input. Operation frame samples include QA checks. Phone FPS/temperature not measured.";
            public bool completed, passed; public List<string> checks = new List<string>(), errors = new List<string>(); public List<Row> rows = new List<Row>();
            public List<ClipFrame> clipFrames = new List<ClipFrame>();
            public List<SingleRotationCase> singleRotationCases=new List<SingleRotationCase>();
        }
        sealed class Pose
        {
            public GooseItem item; public Vector3 position; public Quaternion rotation; public bool held, surface, gravity, visible, promoted;
            public Collider[] colliders; public bool[] enabled;
        }
        readonly Report report = new Report(); readonly List<GooseItem> surface = new List<GooseItem>(64);
        readonly Collider[] hitsColliders=new Collider[1024];
        readonly RaycastHit[] hits = new RaycastHit[1024]; GooseGame game; string output; bool done;
        int firstTheme, themeCount = 5, stockOnly; string part = "matrix";
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        { if (Array.IndexOf(Environment.GetCommandLineArgs(), "-gooseSurfaceQa") >= 0) new GameObject("SurfacePerformanceAcceptance").AddComponent<GooseSurfacePerformanceAcceptance>(); }
        void OnEnable() { Application.logMessageReceived += Log; }
        void OnDisable() { Application.logMessageReceived -= Log; }
        void Log(string text, string stack, LogType kind)
        { if (kind == LogType.Error || kind == LogType.Exception || kind == LogType.Assert) report.errors.Add(text + "\n" + stack); }
        void Check(bool passed, string label) { (passed ? report.checks : report.errors).Add(label); }
        string Arg(string[] args, string key, string fallback)
        { int i = Array.IndexOf(args, key); return i >= 0 && i + 1 < args.Length ? args[i + 1] : fallback; }
        IEnumerator Start()
        {
            var args = Environment.GetCommandLineArgs(); output = Arg(args, "-gooseSurfaceOutput", Path.Combine(Application.persistentDataPath, "surface-qa"));
            firstTheme = int.Parse(Arg(args, "-gooseSurfaceTheme", "0")); themeCount = int.Parse(Arg(args, "-gooseSurfaceThemeCount", "5"));
            stockOnly = int.Parse(Arg(args, "-gooseSurfaceStock", "0"));
            part = Arg(args, "-gooseSurfacePart", "matrix"); Directory.CreateDirectory(output); GooseSave.IsQa = true;
            if (part == "clip" || part == "toss") { themeCount = 1; report.scope = "Production-camera visual capture with moderate 1.6g synthetic sensor input. Controlled pan-toss mode is identified separately from physical Force; actual body rise/rotation/projection are sampled independently each rendered frame. Capture work changes timing; frame performance is not sampled or assessed."; }
            if (part == "fallback") { themeCount = 1; report.scope = "Native pinned/free/single-object controlled pan-toss geometry and lifecycle acceptance. Every accepted gesture uses the declared controlled animation; this is not a Force or phone-performance claim."; }
            yield return null; game = GooseGame.Instance; game.InstantPicksForQa = true; StartCoroutine(Watchdog());
            Screen.SetResolution(390, 844, false);
            for (int theme = firstTheme; theme < Mathf.Min(game.Themes.Length, firstTheme + themeCount); theme++)
            {
                yield return Open(theme);
                if(part=="single-rotation")
                {
                    yield return SingleRotationFixture("actual-tilted-book-success","ref_gtstickerbook",false,false);
                    yield return SingleRotationFixture("actual-tilted-book-cancel","ref_gtstickerbook",false,true);
                    yield return SingleRotationFixture("actual-tilted-book-reject","ref_gtstickerbook",true,false);
                    yield return SingleRotationFixture("actual-double-envelope-budget","ref_bfsesameball",true,false);
                    continue;
                }
                if (part == "fallback")
                {
                    yield return PhoneFallbackFixtures(); yield return TiltedSingleConvexFixture();
                    yield return TiltedSingleConvexFixture("ref_bfsesameball", "fixture-actual-max-unique-single", "actual-max-unique", 0);
                    yield return TiltedSingleConvexFixture("duck-steamedbread", "fixture-actual-max-raw-single", "actual-max-raw", 0);
                    yield return PhoneFallbackInterruptions(); yield return LateContainmentFixture(); continue;
                }
                if (part == "clip" || part == "toss")
                {
                    if (stockOnly > 0 && stockOnly < 300) yield return Reduce(stockOnly);
                    yield return CaptureClip(part == "toss"); continue;
                }
                if (part == "interrupt") { yield return Interruptions(); continue; }
                if (part == "fixture") { yield return CompletenessFixture(); continue; }
                if (stockOnly > 0)
                {
                    if (stockOnly <= 69) yield return Reduce(stockOnly);
                    else if (stockOnly <= 71) { yield return Reduce(69); AddExtras(stockOnly - 69); yield return Settle(4); }
                    yield return Case(stockOnly, stockOnly == 300); continue;
                }
                if (theme == firstTheme) yield return CompletenessFixture();
                yield return Case(300, true);
                if (part == "smoke") continue;
                yield return TruePointerTriple();
                yield return Reduce(69);
                var template = game.Remaining.First(); var extras = new List<GooseItem>(); float top = game.Remaining.Max(i => i.SelectionCollider.bounds.max.y);
                for (int n = 0; n < 2; n++)
                {
                    var item = game.CreateItem(template.Id); item.transform.localScale = template.transform.localScale;
                    item.transform.position = new Vector3(n == 0 ? -.35f : .35f, top + 1.2f, GooseCircularContainer.CenterZ);
                    item.DepthReady = true; item.DepthProtectedUntil = Time.time + .5f; extras.Add(item);
                }
                Physics.SyncTransforms(); yield return Settle(4);
                yield return Case(71, false); game.Forget(extras[0]); Destroy(extras[0].gameObject); yield return Settle(2);
                yield return Case(70, false); game.Forget(extras[1]); Destroy(extras[1].gameObject); yield return Settle(2);
                yield return Case(69, false); yield return Reduce(18); yield return Case(18, false); yield return Reduce(3); yield return Case(3, false);
                yield return Interruptions();
            }
            game.GoHome(); Finish();
        }
        IEnumerator Open(int theme)
        {
            game.GoHome(); game.SelectTheme(theme); game.SelectDifficulty(1); game.BeginRound(false);
            float deadline = Time.realtimeSinceStartup + 90;
            while (!game.SpawnComplete && Time.realtimeSinceStartup < deadline) yield return null;
            Check(game.SpawnComplete, "spawn " + theme); game.QaSetTime(3600); yield return Settle(3);
        }
        IEnumerator Settle(float seconds)
        { float end = Time.time + seconds; while (Time.time < end) { game.QaSetTime(3600); yield return null; } }
        void AddExtras(int count)
        {
            var template = game.Remaining.First(); float top = game.Remaining.Max(i => i.SelectionCollider.bounds.max.y);
            for (int n = 0; n < count; n++)
            {
                var item = game.CreateItem(template.Id); item.transform.localScale = template.transform.localScale;
                item.transform.position = new Vector3(n == 0 ? -.35f : .35f, top + 1.2f, GooseCircularContainer.CenterZ);
                item.DepthReady = true; item.DepthProtectedUntil = Time.time + .5f;
            }
            Physics.SyncTransforms();
        }
        IEnumerator CompletenessFixture()
        {
            var originals = game.Items.ToArray(); foreach (var item in originals) item.gameObject.SetActive(false); game.Items.Clear();
            var fixture = new GameObject("IndependentTwelveTopsFixture"); var tops = new List<GooseItem>(); var lower = new List<GooseItem>();
            try
            {
                for (int z = 0; z < 3; z++) for (int x = 0; x < 4; x++)
                {
                    var center = new Vector3((x - 1.5f) * .56f, .35f, GooseCircularContainer.CenterZ + (z - 1) * .56f);
                    lower.Add(FixtureBox(fixture.transform, "fixture-lower-" + x + "-" + z, center, new Vector3(.42f, .65f, .42f), true));
                    tops.Add(FixtureBox(fixture.transform, "fixture-top-" + x + "-" + z, center + Vector3.up * .475f, new Vector3(.42f, .3f, .42f), false));
                }
                Physics.SyncTransforms(); foreach (var top in tops) top.Body.Sleep();
                game.Depth.ResetRound(); game.Depth.SpawnFinished(true); game.Depth.RefreshNow(); yield return Settle(.7f);
                game.Depth.CopySurface(surface);
                Check(tops.All(surface.Contains) && tops.All(GooseShakeController.CanShake), "all twelve independently exposed tops enter shared surface and shake eligibility");
                Check(lower.All(i => !surface.Contains(i) && !i.SurfaceActive && i.Body.isKinematic && !i.Body.useGravity), "covered fixture supports never enter surface or gravity simulation");
                Check(surface.Count == 12, "independent fixture selects exactly twelve exposed tops");
                Check(tops.Any(i => i.Body.IsSleeping()), "fixture includes sleeping eligible tops");

                // Reproduce the real final-three regression: a high, now removed
                // item must not leave the active frontier metres above the stock.
                // Keep three independently exposed tops and their actual supports.
                foreach (var item in tops.Skip(3).Concat(lower.Skip(3)))
                { game.Items.Remove(item); item.gameObject.SetActive(false); }
                var remainingTops = tops.Take(3).ToArray(); var remainingLower = lower.Take(3).ToArray();
                var decoy = FixtureBox(fixture.transform, "fixture-high-frontier-decoy",
                    new Vector3(.95f, 12, GooseCircularContainer.CenterZ + .55f), Vector3.one * .25f, true);
                Physics.SyncTransforms(); game.Depth.ResetRound(); game.Depth.SpawnFinished(true); game.Depth.RefreshNow();
                Check(game.Depth.ActiveSurfaceThreshold > 10, "frontier regression fixture first establishes a genuinely high frontier");
                Bounds removedBounds = decoy.SelectionCollider.bounds; Vector3 removedPosition = decoy.Body.position;
                game.Items.Remove(decoy); decoy.gameObject.SetActive(false); Physics.SyncTransforms();
                game.Depth.NotifyRemoval(removedPosition, 3, removedBounds);
                yield return new WaitForFixedUpdate(); yield return null; game.Depth.CopySurface(surface);
                float remainingHighestCenter = remainingTops.Concat(remainingLower).Max(i => i.Body.position.y);
                float remainingTop = remainingTops.Max(i => i.SelectionCollider.bounds.max.y);
                Check(game.Depth.ActiveSurfaceThreshold < remainingHighestCenter,
                    "removal rebuilds frontier from actual remaining height without a multi-second catch-up");
                Check(remainingTops.All(i => i.SelectionCollider.bounds.max.y >= game.Depth.ActiveSurfaceThreshold && Exposed(i, remainingTop) && surface.Contains(i) && GooseShakeController.CanShake(i)),
                    "all three genuinely exposed remaining tops immediately enter the rebuilt surface");
                Check(surface.Count == 3 && remainingLower.All(i => !surface.Contains(i) && !i.SurfaceActive && i.DepthHeld && i.Body.isKinematic && !i.Body.useGravity),
                    "frontier rebuild does not wake or add any of the three covered supports");

                // A second, different regression: the surviving top itself falls
                // after the removal callback. No additional NotifyRemoval can help.
                foreach (var topItem in remainingTops)
                {
                    topItem.SetDepthHeld(false); topItem.RestoreNormalPhysics();
                    var raised = topItem.Body.position + Vector3.up * 3;
                    topItem.Body.position = raised; topItem.transform.position = raised;
                    topItem.Body.velocity = topItem.Body.angularVelocity = Vector3.zero; topItem.Body.WakeUp();
                }
                Physics.SyncTransforms(); game.Depth.ResetRound(); game.Depth.SpawnFinished(true); game.Depth.RefreshNow();
                Check(game.Depth.ActiveSurfaceThreshold > 3, "falling-frontier fixture establishes high surviving tops");
                var supportPositions = remainingLower.Select(i => i.Body.position).ToArray();
                yield return Settle(1.8f); Physics.SyncTransforms(); game.Depth.RefreshNow(); game.Depth.CopySurface(surface);
                float fallenCenter = remainingTops.Max(i => i.Body.position.y);
                float fallenTop = remainingTops.Max(i => i.SelectionCollider.bounds.max.y);
                Check(fallenCenter < 1.2f, "surviving tops actually fall onto the three original supports");
                Check(game.Depth.ActiveSurfaceThreshold < fallenCenter && remainingTops.All(i => Exposed(i, fallenTop) && surface.Contains(i) && GooseShakeController.CanShake(i)),
                    "frontier follows the surviving tops downward without a second removal callback");
                Check(surface.Count == 3 && remainingLower.Select((item, index) => item.DepthHeld && item.Body.isKinematic && !item.Body.useGravity && Vector3.Distance(item.Body.position, supportPositions[index]) < .0005f).All(x => x),
                    "falling-frontier recovery leaves all three lower supports fixed and without gravity");
            }
            finally
            {
                game.Items.Clear(); fixture.SetActive(false); Destroy(fixture);
                game.Items.AddRange(originals); foreach (var item in originals) item.gameObject.SetActive(true);
                Physics.SyncTransforms(); game.Depth.ResetRound(); game.Depth.SpawnFinished(true); game.Depth.RefreshNow();
            }
            yield return Settle(1);
        }
        GooseItem FixtureBox(Transform parent, string id, Vector3 position, Vector3 size, bool held)
        {
            var root = GameObject.CreatePrimitive(PrimitiveType.Cube); root.name = id; root.transform.SetParent(parent);
            root.transform.position = position; root.transform.localScale = size;
            var item = root.AddComponent<GooseItem>(); item.Id = id; item.Visual = root.transform; item.Body = root.AddComponent<Rigidbody>();
            item.Body.mass = .95f; item.CacheParts(); item.DepthReady = true; item.DepthStillSince = Time.time - 2; item.DepthProtectedUntil = Time.time - 1;
            item.SetDepthHeld(held); game.Items.Add(item); return item;
        }
        IEnumerator Reduce(int count)
        {
            while (game.Remaining.Count() > count)
            {
                var group = game.Remaining.GroupBy(i => i.Id).FirstOrDefault(g => g.Count() >= 3);
                if (group == null) { Check(false, "reduction triple available"); yield break; }
                foreach (var item in group.Take(3).ToArray()) Check(game.Pick(item, true), "fixture reduction pick");
                yield return null;
            }
            yield return Settle(3);
        }
        IEnumerator TruePointerTriple()
        {
            var stock = game.Remaining.ToArray(); GooseItem target = null; Vector2 point = Vector2.zero;
            foreach (var item in stock)
            {
                var candidate = (Vector2)game.MainCamera.WorldToScreenPoint(item.SelectionCollider.bounds.center);
                if (game.FindSelectableAtScreenPosition(candidate) == item && stock.Count(i => i.Id == item.Id) >= 3)
                { target = item; point = candidate; break; }
            }
            Check(target, game.Theme.id + " independently selectable real pointer target"); if (!target) yield break;
            string id = target.Id; int before = game.Remaining.Count();
            bool began = game.BeginPointer(point, 8765); bool picked = began && game.EndPointer(point, 8765);
            Check(picked && game.Remaining.Count() == before - 1, game.Theme.id + " production pointer selects exposed item");
            if (picked) foreach (var item in game.Remaining.Where(i => i.Id == id).Take(2).ToArray()) game.Pick(item, true);
            yield return Settle(2);
        }
        IEnumerator Case(int expected, bool sensor)
        {
            Check(game.Remaining.Count() == expected, "fixture stock " + expected);
            yield return Passive(); yield return Operate(sensor ? "sensor" : "button");
            if (sensor) yield return Operate("sensor-moderate");
            yield return Operate("shuffle");
            yield return new WaitForEndOfFrame(); GooseFrameCapture.Save(Path.Combine(output, game.Theme.id + "-" + expected + ".png")); Save();
        }
        FloorSample SampleFloor()
        {
            var sample = new FloorSample { visual = 100, body = 100, itemId = "" };
            foreach (var item in game.Remaining)
            {
                float min = GooseColliderGeometry.MinY(item.SelectionCollider);
                if (min >= sample.visual) continue;
                sample.visual = min; sample.itemId = item.Id + "/" + item.GetInstanceID();
                sample.body = GooseColliderGeometry.MinY(item.SelectionCollider, GooseColliderGeometry.BodyMatrix(item.SelectionCollider, item.Body));
            }
            return sample;
        }
        // Call only after WaitForEndOfFrame: production's LateUpdate support
        // projection has now run, so the asserted pose is the rendered pose.
        Row Structure(string operation, FloorSample beforeCorrection)
        {
            game.Depth.CopySurface(surface); var items = game.Remaining.ToArray();
            var row = new Row { theme = game.Theme.id, operation = operation, stock = items.Length, surface = surface.Count,
                probes = game.Depth.LastProbeCount, depthRefreshMs = game.Depth.LastRefreshMs, managedMiB = GC.GetTotalMemory(false) / 1048576f,
                activeSurfaceThreshold = game.Depth.ActiveSurfaceThreshold, modelSize = game.ModelSize, itemScale = game.ItemScale,
                shufflePlanningMs = game.SurfaceShuffle.LastPlanningMilliseconds, shuffleMaxSliceMs = game.SurfaceShuffle.MaxPlanningSliceMilliseconds,
                shuffleLastFailure = game.SurfaceShuffle.LastFailure, shuffleBlockingCollider = game.SurfaceShuffle.LastBlockingCollider,
                preCorrectionMinY = beforeCorrection.visual, preCorrectionBodyMinY = beforeCorrection.body, preCorrectionItemId = beforeCorrection.itemId,
                unityMiB = UnityEngine.Profiling.Profiler.GetTotalAllocatedMemoryLong() / 1048576f };
            foreach (var item in items)
            {
                if (item.DepthHeld) row.held++; if (!item.DepthVisible) row.hidden++;
                if (!item.Body.isKinematic) { row.dynamicBodies++; if (!item.Body.IsSleeping()) row.awake++; }
                if (item.PhysicsRecoveryActive) row.recoveries++;
                if (item.DepthVisible) { row.visible++; row.renderers += item.RenderCount; row.drawSlots += item.DrawSlots; row.triangles += item.Triangles; }
                float hullY = GooseColliderGeometry.MinY(item.SelectionCollider);
                if (hullY < row.minHullY)
                {
                    row.minHullY = hullY; row.worstItemId = item.Id + "/" + item.GetInstanceID();
                    row.bodyMinY = GooseColliderGeometry.MinY(item.SelectionCollider, GooseColliderGeometry.BodyMatrix(item.SelectionCollider, item.Body));
                }
            }
            row.afterLateMinY = row.minHullY;
            Check(items.All(i => i.Colliders.All(c => c.enabled) && i.Body.detectCollisions), row.theme + " support collision retained " + operation + "/" + row.stock);
            Check(items.Where(i => i.DepthHeld).All(i => i.Body.isKinematic && !i.Body.useGravity), row.theme + " lower supports do not simulate gravity " + operation + "/" + row.stock);
            Check(row.probes <= GoosePileDepth.MaxProbeCount, row.theme + " bounded depth query work " + operation + "/" + row.stock);
            Check(row.minHullY >= GooseCircularContainer.FloorY - .025f, row.theme + " hulls above floor " + operation + "/" + row.stock);
            return row;
        }
        IEnumerator Passive()
        {
            var beforeCorrection = SampleFloor(); yield return new WaitForEndOfFrame();
            var row = Structure("idle", beforeCorrection); var frames = new List<float>(90); int gc = GC.CollectionCount(0);
            float end = Time.realtimeSinceStartup + 2;
            while (Time.realtimeSinceStartup < end) { yield return null; frames.Add(Time.unscaledDeltaTime * 1000); }
            FrameStats(row, frames); row.gcCollections = GC.CollectionCount(0) - gc; report.rows.Add(row); Save();
            yield return new WaitForEndOfFrame();
            GooseFrameCapture.Save(Path.Combine(output, row.theme + "-idle-" + row.stock + ".png"));
        }
        // Independent vertical-ray oracle: include a target only when an actual
        // ray intersects that collider and no nearer geometry covers the same point.
        bool Exposed(GooseItem item, float top)
        {
            var b = item.SelectionCollider.bounds;
            for (int p = 0; p < 5; p++)
            {
                float x = p == 0 ? 0 : (p % 2 == 0 ? 1 : -1) * b.extents.x * .3f;
                float z = p == 0 ? 0 : (p < 3 ? 1 : -1) * b.extents.z * .3f;
                var ray = new Ray(new Vector3(b.center.x + x, top + 1, b.center.z + z), Vector3.down);
                if (!item.SelectionCollider.Raycast(ray, out var own, 100)) continue;
                int count = Physics.RaycastNonAlloc(ray, hits, own.distance + .001f, ~((1 << 2) | (1 << 8) | (1 << 27) | (1 << 28) | (1 << 29) | (1 << 30)), QueryTriggerInteraction.Ignore);
                bool covered = false; for (int h = 0; h < count; h++) if (hits[h].collider != item.SelectionCollider && hits[h].distance < own.distance - .002f) { covered = true; break; }
                if (!covered) return true;
            }
            return false;
        }
        Pose Capture(GooseItem item)
        { return new Pose { item = item, position = item.Body.position, rotation = item.Body.rotation, held = item.DepthHeld, surface = item.SurfaceActive, gravity = item.Body.useGravity, visible = item.DepthVisible, colliders = item.Colliders, enabled = item.Colliders.Select(c => c.enabled).ToArray() }; }
        int[] ToolUses() => Enumerable.Range(0, 3).Select(i => game.QaToolUses(i)).ToArray();
        bool SameTools(int[] props, int[] uses) => props.SequenceEqual(game.Props) && uses.SequenceEqual(ToolUses());
        static BodyState[] BodyStates(IEnumerable<GooseItem> items) => items.Where(i => i && i.Body).Select(i => new BodyState
        {
            item = i.Id + "/" + i.GetInstanceID(), constraints = (int)i.Body.constraints, position = i.Body.position,
            velocity = i.Body.velocity, angularVelocity = i.Body.angularVelocity, rotation = i.Body.rotation,
            visualRotation = i.transform.rotation, kinematic = i.Body.isKinematic, gravity = i.Body.useGravity
        }).ToArray();
        static void FallbackStats(Row row, GooseShakeController.MotionResult motion)
        {
            row.fallbackAttempted = motion.fallbackAttempted; row.fallbackCompleted = motion.fallbackCompleted; row.fallbackFailure = motion.fallbackFailure;
            row.motionMode = motion.mode; row.tossCompleted = motion.tossCompleted; row.tossFailure = motion.tossFailure;
        }
        bool InjectSensor(float amplitude)
        {
            int before = game.Shake.Accepted; game.Shake.ResetSensor(); float t = Time.unscaledTime;
            for (int n = 0; n < 6; n++) game.Shake.Sample(Vector3.forward, t + n * .06f);
            game.Shake.Sample(new Vector3(amplitude, 0, 1), t + .42f); game.Shake.Sample(new Vector3(-amplitude, 0, 1), t + .48f);
            game.Shake.Sample(Vector3.forward, t + .54f); return game.Shake.Accepted == before + 1;
        }
        void PlanarNetStats(Row row, Pose[] poses)
        {
            foreach (var pose in poses)
            {
                var delta = pose.item.Body.position - pose.position; float travel = new Vector2(delta.x, delta.z).magnitude;
                row.maxPlanarTravel = Mathf.Max(row.maxPlanarTravel, travel);
                if (travel >= game.ItemScale * .12f) row.planarMovedEnough++;
            }
        }
        void ObserveClip(Row row, Pose[] poses, Dictionary<int, TossTarget> traces, float began)
        {
            // A declared controlled toss is measured as animation, never Force.
            // The old weak-Force helper still cannot prove a physical kick.
            if (game.SurfaceShuffle.OwnerPhoneToss) row.controlledTossObserved = true;
            if (game.SurfaceShuffle.OwnerFromShake && !game.SurfaceShuffle.OwnerPhoneToss) row.tossHelperStarted = true;
            var ids = game.Shake.TargetIds;
            foreach (var pose in poses)
            {
                var item = pose.item; if (!item || item.Picked) continue;
                if (pose.held && !pose.surface)
                {
                    if (item.SurfaceActive) pose.promoted = true;
                    if (!pose.promoted && (!item.DepthHeld || !item.Body.isKinematic || item.Body.useGravity || !item.Body.detectCollisions ||
                        Vector3.Distance(pose.position, item.Body.position) > .0005f || Quaternion.Angle(pose.rotation, item.Body.rotation) > .05f ||
                        pose.colliders.Where((c, i) => c && c.enabled != pose.enabled[i]).Any())) row.lowerViolations++;
                }
                int id = item.GetInstanceID();
                if (!ids.Contains(id) || !traces.TryGetValue(id, out var trace)) continue;
                float minY = GooseColliderGeometry.MinY(item.SelectionCollider, GooseColliderGeometry.BodyMatrix(item.SelectionCollider, item.Body));
                if (minY < GooseCircularContainer.FloorY - .025f) row.tossFloorViolations++;
                var radial = new Vector2(item.Body.position.x, item.Body.position.z - GooseCircularContainer.CenterZ);
                float radius = radial.magnitude;
                if (radius > trace.maxRadial)
                { trace.maxRadial = radius; trace.maxRadialSeconds = Time.realtimeSinceStartup - began; trace.maxRadialPosition = item.Body.position; }
                if (radius > game.Container.Radius + .05f)
                {
                    row.tossBoundaryViolations++;
                    row.boundaryEvents.Add(new BoundaryEvent { instanceId = id, item = item.Id, seconds = Time.realtimeSinceStartup - began,
                        radial = radius, containerRadius = game.Container.Radius, position = item.Body.position, velocity = item.Body.velocity,
                        rotation = item.Body.rotation, ownerPhoneToss = game.SurfaceShuffle.OwnerPhoneToss,
                        surfaceAnimating = item.SurfaceAnimating, kinematic = item.Body.isKinematic, gravity = item.Body.useGravity });
                }
                trace.finalPosition = item.Body.position;
                if (row.tossHelperStarted) continue;
                Vector3 delta = item.Body.position - pose.position;
                if (delta.y > trace.maxRise)
                { trace.maxRise = delta.y; trace.peakPosition = item.Body.position; trace.peakRiseSeconds = Time.realtimeSinceStartup - began; }
                float turn = Quaternion.Angle(pose.rotation, item.Body.rotation);
                trace.maxTurn = Mathf.Max(trace.maxTurn, turn);
                trace.peakXZ = Mathf.Max(trace.peakXZ, new Vector2(delta.x, delta.z).magnitude);
                var firstScreen = game.MainCamera.WorldToScreenPoint(pose.position);
                var nowScreen = game.MainCamera.WorldToScreenPoint(item.Body.position);
                trace.peakXZPixels = Mathf.Max(trace.peakXZPixels, Vector2.Distance(firstScreen, nowScreen));
                if (!trace.airborneFlip && delta.y >= game.ItemScale * .6f && turn >= 75)
                { trace.airborneFlip = true; trace.airborneFlipSeconds = Time.realtimeSinceStartup - began; }
            }
        }
        IEnumerator CaptureClip(bool requireToss = false)
        {
            yield return Settle(1.6f); var beforeCorrection = SampleFloor(); yield return new WaitForEndOfFrame();
            var row = Structure(requireToss ? "sensor-moderate-toss" : "sensor-moderate-clip", beforeCorrection);
            var poses = game.Remaining.Select(Capture).ToArray(); game.Depth.CopySurface(surface);
            var propsBefore = game.Props.ToArray(); var usesBefore = ToolUses();
            var eligible = new HashSet<int>(surface.Select(i => i.GetInstanceID()));
            var traces = poses.Where(p => eligible.Contains(p.item.GetInstanceID())).ToDictionary(p => p.item.GetInstanceID(), p => new TossTarget {
                instanceId = p.item.GetInstanceID(), item = p.item.Id, initialPosition = p.position, initialRotation = p.rotation, peakPosition = p.position });
            GooseFrameCapture.Save(Path.Combine(output, "clip-before.png"));
            Check(InjectSensor(1.6f), "visual clip accepts a moderate 1.6g gesture");
            float began = Time.realtimeSinceStartup;
            for (int frame = 0; frame < 33; frame++)
            {
                while (Time.realtimeSinceStartup < began + (frame + 1) * .1f)
                { yield return new WaitForEndOfFrame(); ObserveClip(row, poses, traces, began); }
                yield return new WaitForEndOfFrame(); string file = "clip-" + frame.ToString("000") + ".png";
                ObserveClip(row, poses, traces, began);
                report.clipFrames.Add(new ClipFrame { file = file, seconds = Time.realtimeSinceStartup - began });
                GooseFrameCapture.Save(Path.Combine(output, file));
            }
            row.targetIds = game.Shake.TargetIds.ToArray();
            row.targetNames = poses.Where(p => p.item && row.targetIds.Contains(p.item.GetInstanceID())).Select(p => p.item.Id + "/" + p.item.GetInstanceID()).ToArray();
            Check(row.targetIds.Length > 0 && row.targetIds.All(eligible.Contains), "visual clip affects only its initial activated surface");
            var targetPoses = poses.Where(p => p.item && row.targetIds.Contains(p.item.GetInstanceID())).ToArray();
            row.tossTargets = row.targetIds.Where(traces.ContainsKey).Select(id => traces[id]).ToArray();
            foreach (var trace in row.tossTargets)
            {
                row.maxRise = Mathf.Max(row.maxRise, trace.maxRise); row.peakXZ = Mathf.Max(row.peakXZ, trace.peakXZ);
                row.peakXZPixels = Mathf.Max(row.peakXZPixels, trace.peakXZPixels);
                bool lifted = trace.maxRise >= game.ItemScale * .6f, turned = trace.maxTurn >= 75;
                if (lifted) row.liftedEnough++; if (turned) row.turnedEnough++; if (trace.airborneFlip) row.jointEnough++;
                if (trace.peakXZ >= game.ItemScale * .18f && trace.peakXZPixels >= 15) row.visibleArcEnough++;
            }
            if (requireToss)
            {
                Check(row.controlledTossObserved, "controlled pan toss actually executes its declared trajectory");
                Check(row.jointEnough >= Mathf.CeilToInt(targetPoses.Length * .6f), "pan toss raises and flips at least sixty percent of the same original targets while airborne");
                Check(row.visibleArcEnough >= Mathf.CeilToInt(targetPoses.Length * .6f), "pan toss gives at least sixty percent of targets a real XZ arc of .18 scale and fifteen screen pixels");
            }
            Check(row.lowerViolations == 0, "visual clip never moves or releases an unexposed lower support");
            Check(row.tossFloorViolations == 0, "visual clip target hulls stay above the unchanged floor tolerance");
            Check(row.tossBoundaryViolations == 0, "visual clip target centers remain in the production container boundary");
            PlanarNetStats(row, targetPoses); var motion = game.Shake.LastMotion;
            Check(motion != null && motion.affected > 0, "visual clip records a completed nonzero motion");
            if (motion != null)
            {
                row.motionMode = motion.mode;
                Check(motion.mode == "controlled-pan-toss" && motion.tossCompleted && string.IsNullOrEmpty(motion.tossFailure),
                    "controlled animation completes and is labelled explicitly rather than reported as Force");
                FallbackStats(row, motion);
                Check(!motion.interrupted && (!motion.fallbackAttempted || motion.fallbackCompleted), "visual clip finishes its real force/fallback gesture");
                row.affected = motion.affected; row.moved = motion.moved; row.turned = motion.turned; row.changedNeighbours = motion.changedNeighbours;
                row.maxTravel = motion.maxTravel; row.meanTravel = motion.meanTravel; row.maxTurn = motion.maxTurn;
                int movedEnough = targetPoses.Count(p => Vector3.Distance(p.position, p.item.Body.position) >= game.ItemScale * .12f);
                Check(movedEnough >= Mathf.CeilToInt(targetPoses.Length * .5f), "visual clip retains half-cohort settled 3D displacement");
                Check(row.planarMovedEnough >= Mathf.CeilToInt(targetPoses.Length * .5f), "visual clip retains half-cohort settled XZ displacement");
                if (targetPoses.Length >= 3) Check(motion.changedNeighbours > 0 || RelativeOrderChanged(targetPoses) || motion.maxTurn >= 15,
                    "visual clip changes relative XZ order, neighbours or a clear orientation");
            }
            yield return null; var beforeEndCorrection = SampleFloor(); yield return new WaitForEndOfFrame();
            RecordEndFloor(row, Structure("visual-clip-end", beforeEndCorrection)); Check(game.Remaining.Count() == row.stock, "visual clip conserves inventory");
            Check(SameTools(propsBefore, usesBefore), "visual phone gesture never consumes or refunds props or tool-use counts");
            report.rows.Add(row); Save();
        }
        IEnumerator Operate(string operation)
        {
            yield return Settle(1.6f); var beforeCorrection = SampleFloor(); yield return new WaitForEndOfFrame();
            game.Depth.CopySurface(surface);
            var row = Structure(operation, beforeCorrection); var poses = game.Remaining.Select(Capture).ToArray();
            if (row.stock == 3) row.initialStates = BodyStates(poses.Select(p => p.item));
            var propsBefore = game.Props.ToArray(); var usesBefore = ToolUses();
            float top = poses.Max(p => p.item.SelectionCollider.bounds.max.y);
            // The published gameplay contract limits activation to the current
            // depth frontier. Seeing a lower piece through a narrow hole does not
            // promote it; the independent geometry oracle still verifies exposure.
            var independentlyExposed = new HashSet<int>(poses.Where(p => p.item.SelectionCollider.bounds.max.y >= row.activeSurfaceThreshold && Exposed(p.item, top)).Select(p => p.item.GetInstanceID()));
            row.independentExposed = independentlyExposed.Count; var initialEligible = new HashSet<int>(surface.Select(i => i.GetInstanceID()));
            if (operation == "shuffle" && initialEligible.Count < 2)
            {
                game.QaGrant(2, 1); int available = game.Props[2]; bool used = game.UseProp(2);
                Check(!used && game.Props[2] == available, row.theme + " no exchange target means no tool consumption " + row.stock);
                Check(poses.All(p => Vector3.Distance(p.position, p.item.Body.position) < .0005f && Quaternion.Angle(p.rotation, p.item.Body.rotation) < .05f),
                    row.theme + " unavailable single-surface shuffle keeps every pose " + row.stock);
                row.operation = "shuffle-unavailable-single"; row.targetIds = new int[0]; report.rows.Add(row); Save(); yield break;
            }
            int exposures = game.Depth.ExposureActivations, gc = GC.CollectionCount(0); var timer = System.Diagnostics.Stopwatch.StartNew(); bool accepted;
            if (operation == "shuffle") { game.QaGrant(2, 1); accepted = game.UseProp(2); }
            else if (operation.StartsWith("sensor", StringComparison.Ordinal))
            {
                float amplitude = operation == "sensor-moderate" ? 1.6f : 4f;
                // A quiet callback before FixedUpdate must not erase the accepted peak.
                accepted = InjectSensor(amplitude);
            }
            else accepted = game.Shake.Request(new Vector3(1, .25f, .3f), 1);
            timer.Stop(); row.beginCpuMs = (float)timer.Elapsed.TotalMilliseconds; Check(accepted, row.theme + " accepted " + operation + "/" + row.stock);
            yield return new WaitForFixedUpdate(); yield return null;
            row.targetIds = (operation == "shuffle" ? game.SurfaceShuffle.TargetIds : game.Shake.TargetIds).ToArray();
            row.targetNames = poses.Where(p => p.item && row.targetIds.Contains(p.item.GetInstanceID())).Select(p => p.item.Id + "/" + p.item.GetInstanceID()).ToArray();
            Check(row.targetIds.Length > 0 && row.targetIds.All(initialEligible.Contains), row.theme + " fixed eligible surface snapshot only " + operation + "/" + row.stock);
            Check(row.targetIds.Length <= GooseInteractionProfile.Current.shakeMaxBodies, row.theme + " bounded target count " + operation + "/" + row.stock);
            row.exposedSelected = row.targetIds.Count(independentlyExposed.Contains);
            if (row.stock == 300 && independentlyExposed.Count > 0)
                Check(row.exposedSelected >= Mathf.Min(independentlyExposed.Count, GooseInteractionProfile.Current.shakeMaxBodies) * .8f, row.theme + " independently exposed candidate coverage " + operation);
            var frames = new List<float>(130); float end = Time.time + 3; var lowerSeen = new HashSet<int>();
            while (Time.time < end)
            {
                yield return null; frames.Add(Time.unscaledDeltaTime * 1000);
                foreach (var p in poses) if (p.item && p.held && !p.surface)
                {
                    if (p.item.SurfaceActive) p.promoted = true;
                    if (p.promoted) continue;
                    lowerSeen.Add(p.item.GetInstanceID());
                    bool stable = p.item.Body.isKinematic && !p.item.Body.useGravity && Vector3.Distance(p.position, p.item.Body.position) < .0005f && Quaternion.Angle(p.rotation, p.item.Body.rotation) < .05f;
                    for (int c = 0; c < p.colliders.Length; c++) stable &= p.colliders[c] && p.colliders[c].enabled == p.enabled[c];
                    if (!stable) row.lowerViolations++;
                }
            }
            row.untouchedLower = lowerSeen.Count; row.exposureDelta = game.Depth.ExposureActivations - exposures;
            Check(row.lowerViolations == 0, row.theme + " unexposed lower poses/gravity/colliders unchanged " + operation + "/" + row.stock);
            var motion = operation == "shuffle" ? game.SurfaceShuffle.LastMotion : game.Shake.LastMotion;
            Check(motion != null, row.theme + " motion observation finished " + operation + "/" + row.stock);
            if (motion != null)
            {
                FallbackStats(row, motion);
                Check(!motion.interrupted && (!motion.fallbackAttempted || motion.fallbackCompleted), row.theme + " actual motion completes " + operation + "/" + row.stock);
                if (operation != "shuffle") Check(motion.mode == "controlled-pan-toss" && motion.tossCompleted && string.IsNullOrEmpty(motion.tossFailure),
                    row.theme + " gesture completes its declared controlled pan toss " + operation + "/" + row.stock);
                else Check(motion.mode == "surface-shuffle", row.theme + " paid prop retains its separate surface-shuffle path " + row.stock);
                row.affected = motion.affected; row.moved = motion.moved; row.turned = motion.turned; row.changedNeighbours = motion.changedNeighbours;
                row.maxTravel = motion.maxTravel; row.meanTravel = motion.meanTravel; row.maxTurn = motion.maxTurn;
                Check(motion.affected > 0, row.theme + " nonzero actual affected " + operation + "/" + row.stock);
                var targetPoses = poses.Where(p => row.targetIds.Contains(p.item.GetInstanceID()) && p.item).ToArray();
                PlanarNetStats(row, targetPoses);
                int movedEnough = targetPoses.Count(p => Vector3.Distance(p.position, p.item.Body.position) >= game.ItemScale * .12f);
                if (row.stock == 300) Check(movedEnough >= Mathf.CeilToInt(targetPoses.Length * .5f), row.theme + " at least half visibly displace " + operation);
                if (row.stock == 300 && operation.StartsWith("sensor", StringComparison.Ordinal))
                    Check(row.planarMovedEnough >= Mathf.CeilToInt(targetPoses.Length * .5f), row.theme + " at least half retain settled XZ displacement " + operation);
                bool relativeChanged = motion.changedNeighbours > 0 || RelativeOrderChanged(targetPoses);
                if (operation.StartsWith("sensor", StringComparison.Ordinal) && targetPoses.Length >= 3)
                    Check(relativeChanged || motion.maxTurn >= 15, row.theme + " sensor changes XZ order, neighbours or clear orientation " + operation);
                if (operation == "shuffle" && targetPoses.Length >= 3) Check(relativeChanged, row.theme + " reorders rather than translating cohort " + row.stock);
                else Check(motion.moved > 0 && (motion.turned > 0 || relativeChanged || targetPoses.Length < 3), row.theme + " visible travel and turn/neighbour effect " + operation + "/" + row.stock);
            }
            Check(game.Remaining.Count() == row.stock, row.theme + " inventory conserved " + operation + "/" + row.stock);
            if (operation != "shuffle") Check(SameTools(propsBefore, usesBefore), row.theme + " phone/manual gesture leaves all prop and use counts unchanged " + operation + "/" + row.stock);
            var beforeEndCorrection = SampleFloor(); yield return new WaitForEndOfFrame();
            var endRow = Structure(operation + "-end", beforeEndCorrection); RecordEndFloor(row, endRow); row.recoveries = endRow.recoveries;
            if (row.stock == 3) row.settledStates = BodyStates(game.Remaining);
            row.shufflePlanningMs = endRow.shufflePlanningMs; row.shuffleMaxSliceMs = endRow.shuffleMaxSliceMs;
            row.shuffleLastFailure = endRow.shuffleLastFailure; row.shuffleBlockingCollider = endRow.shuffleBlockingCollider;
            FrameStats(row, frames); row.gcCollections = GC.CollectionCount(0) - gc; report.rows.Add(row); Save();
        }
        static void RecordEndFloor(Row row, Row endRow)
        {
            row.endPreCorrectionMinY = endRow.preCorrectionMinY; row.endAfterLateMinY = endRow.afterLateMinY;
            row.endBodyMinY = endRow.bodyMinY; row.endWorstItemId = endRow.worstItemId;
            row.minHullY = Mathf.Min(row.minHullY, endRow.minHullY);
            row.shufflePlanningMs = endRow.shufflePlanningMs; row.shuffleMaxSliceMs = endRow.shuffleMaxSliceMs;
            row.shuffleLastFailure = endRow.shuffleLastFailure; row.shuffleBlockingCollider = endRow.shuffleBlockingCollider;
        }
        static bool RelativeOrderChanged(Pose[] poses)
        {
            for (int i = 0; i < poses.Length; i++) for (int j = i + 1; j < poses.Length; j++)
            {
                var before = poses[i].position - poses[j].position; var after = poses[i].item.Body.position - poses[j].item.Body.position;
                if ((Mathf.Abs(before.x) > .06f && Mathf.Abs(after.x) > .06f && before.x * after.x < 0) ||
                    (Mathf.Abs(before.z) > .06f && Mathf.Abs(after.z) > .06f && before.z * after.z < 0)) return true;
            }
            return false;
        }
        GameObject PinningCages(Transform parent, IEnumerable<GooseItem> tops, bool itemSupports = false)
        {
            var cages = new GameObject("StaticPhysicalPinningCages"); cages.transform.SetParent(parent);
            foreach (var top in tops)
            {
                // Real collision, no fake controller flags: a .42 box fits a .44
                // aperture, but a bounded physical hop cannot clear these walls.
                for (int side = 0; side < 4; side++)
                {
                    var wall = GameObject.CreatePrimitive(PrimitiveType.Cube); wall.transform.SetParent(cages.transform);
                    wall.name = "PinningWall-" + top.Id + "-" + side;
                    var offset = side < 2 ? new Vector3(side == 0 ? -.25f : .25f, 0, 0) : new Vector3(0, 0, side == 2 ? -.25f : .25f);
                    wall.transform.position = new Vector3(top.Body.position.x, 1.075f, top.Body.position.z) + offset;
                    wall.transform.localScale = side < 2 ? new Vector3(.06f, .8f, .56f) : new Vector3(.56f, .8f, .06f);
                    wall.GetComponent<Renderer>().enabled = false;
                    if (itemSupports)
                    {
                        // Non-selectable collision supports are still physical.
                        // Using the real IgnoreRaycast layer keeps the walls out
                        // of the independent top-surface oracle without fake flags.
                        wall.layer = 2; wall.GetComponent<Renderer>().forceRenderingOff = true;
                        var support = wall.AddComponent<GooseItem>(); support.Id = wall.name; support.Visual = wall.transform;
                        support.Body = wall.AddComponent<Rigidbody>(); support.CacheParts(); support.DepthReady = true;
                        support.DepthStillSince = Time.time - 2; support.SetDepthHeld(true); game.Items.Add(support);
                    }
                }
            }
            return cages;
        }
        void ResetFallbackFixture(IReadOnlyList<GooseItem> tops, IReadOnlyList<GooseItem> lower)
        {
            game.SurfaceShuffle.CancelRound(); game.Shake.CancelRound();
            for (int i = 0; i < tops.Count; i++)
            {
                foreach (var item in new[] { tops[i], lower[i] })
                {
                    item.SetDepthHeld(false); item.Body.position = new Vector3((i - (tops.Count - 1) * .5f) * .56f,
                        item == tops[i] ? .825f : .35f, GooseCircularContainer.CenterZ);
                    item.Body.rotation = Quaternion.identity; item.transform.SetPositionAndRotation(item.Body.position, Quaternion.identity);
                    item.Body.velocity = item.Body.angularVelocity = Vector3.zero; item.DepthProtectedUntil = Time.time - 1; item.DepthStillSince = Time.time - 2;
                    item.RestoreNormalPhysics(); item.SetDepthVisible(true);
                }
                tops[i].Body.constraints = RigidbodyConstraints.FreezeRotation; lower[i].SetDepthHeld(true);
            }
            Physics.SyncTransforms(); game.Depth.ResetRound(); game.Depth.SpawnFinished(true); game.Depth.RefreshNow();
        }
        IEnumerator FixturePhoneGesture(string name, GooseItem[] expectedTops, GooseItem[] lower)
        {
            var pre = SampleFloor(); yield return new WaitForEndOfFrame(); var row = Structure(name, pre);
            var originals = expectedTops.Select(Capture).ToArray(); var lowerPoses = lower.Select(Capture).ToArray();
            row.initialStates = BodyStates(expectedTops);
            var props = game.Props.ToArray(); var uses = ToolUses();
            game.Depth.CopySurface(surface); var expectedIds = new HashSet<int>(expectedTops.Select(i => i.GetInstanceID()));
            Check(expectedIds.SetEquals(surface.Select(i => i.GetInstanceID())), name + " authored geometry determines the exact original surface");
            Check(InjectSensor(1.6f), name + " moderate gesture accepted");
            bool sawToss = false, ownerCorrect = true, hasNudgeStart = false, hasNudgeEnd = false;
            Vector3 nudgeStart = Vector3.zero, nudgeEnd = Vector3.zero; float firstPhysics = -1, deadline = Time.time + 3;
            while (game.Shake.Active && Time.time < deadline)
            {
                yield return new WaitForEndOfFrame();
                if (game.Shake.TargetIds.Count > 0 && firstPhysics < 0) firstPhysics = Time.time;
                bool activeToss = game.Shake.TossActive;
                if (activeToss)
                {
                    sawToss = true; ownerCorrect &= game.SurfaceShuffle.OwnerPhoneToss;
                    Check(!game.Shake.Request(Vector3.right), name + " active controlled toss cannot be overwritten by a new gesture");
                    if (!hasNudgeStart)
                    { hasNudgeStart = true; nudgeStart = originals[0].position; row.helperStartStates = BodyStates(expectedTops); }
                }
                else if (sawToss && !hasNudgeEnd)
                {
                    hasNudgeEnd = true; nudgeEnd = expectedTops[0].Body.position; row.helperEndStates = BodyStates(expectedTops);
                    row.helperEndSeconds = firstPhysics < 0 ? 0 : Time.time - firstPhysics;
                }
                foreach (var pose in lowerPoses)
                    if (!pose.item.DepthHeld || !pose.item.Body.isKinematic || pose.item.Body.useGravity ||
                        Vector3.Distance(pose.position, pose.item.Body.position) > .0005f || pose.item.Colliders.Any(c => !c.enabled)) row.lowerViolations++;
            }
            Check(!game.Shake.Active && firstPhysics >= 0 && Time.time - firstPhysics <= GooseShakeController.MaximumGestureSeconds + .05f,
                name + " completes within the overall gesture budget");
            row.gestureSeconds = firstPhysics < 0 ? 0 : Time.time - firstPhysics; row.nudgeStart = nudgeStart; row.nudgeEnd = nudgeEnd;
            Check(ownerCorrect && sawToss, name + " uses the explicit controlled pan-toss path for pinned and free targets");
            row.targetIds = game.Shake.TargetIds.ToArray(); row.targetNames = expectedTops.Select(i => i.Id + "/" + i.GetInstanceID()).ToArray();
            Check(expectedIds.SetEquals(row.targetIds), name + " never replaces its original authored targets");
            yield return Settle(.7f);
            var motion = game.Shake.LastMotion; Check(motion != null && !motion.interrupted, name + " reports a genuine completed gesture");
            if (motion != null)
            {
                FallbackStats(row, motion); row.affected = motion.affected; row.moved = motion.moved; row.turned = motion.turned;
                row.changedNeighbours = motion.changedNeighbours; row.maxTravel = motion.maxTravel; row.meanTravel = motion.meanTravel; row.maxTurn = motion.maxTurn;
                Check(motion.mode == "controlled-pan-toss" && motion.tossCompleted && string.IsNullOrEmpty(motion.tossFailure) && !motion.fallbackAttempted,
                    name + " diagnostics distinguish completed controlled animation from Force and fallback");
                PlanarNetStats(row, originals);
                Check(row.planarMovedEnough >= Mathf.CeilToInt(expectedTops.Length * .5f), name + " retains real final planar rearrangement");
            }
            if (expectedTops.Length == 1)
            {
                float distance = new Vector2(nudgeEnd.x - nudgeStart.x, nudgeEnd.z - nudgeStart.z).magnitude;
                Check(hasNudgeStart && hasNudgeEnd && distance >= game.ItemScale * .2f - .002f && distance <= game.ItemScale * .3f + .002f,
                    name + " single-object animation ends at a bounded safe neighbour");
            }
            Check(row.lowerViolations == 0, name + " original lower supports remain fixed throughout the gesture");
            Check(SameTools(props, uses), name + " never spends or refunds any prop or tool-use count");
            var endPre = SampleFloor(); yield return new WaitForEndOfFrame(); RecordEndFloor(row, Structure(name + "-end", endPre));
            row.settledStates = BodyStates(expectedTops);
            report.rows.Add(row); Save();
        }
        IEnumerator PhoneFallbackFixtures()
        {
            var originals = game.Items.ToArray(); var props = game.Props.ToArray(); var uses = ToolUses();
            foreach (var item in originals) item.gameObject.SetActive(false); game.Items.Clear();
            var root = new GameObject("IndependentPhoneFallbackFixture"); var tops = new List<GooseItem>(); var lower = new List<GooseItem>();
            GameObject cages = null;
            try
            {
                for (int i = 0; i < 3; i++)
                {
                    lower.Add(FixtureBox(root.transform, "phone-fixture-lower-" + i, new Vector3((i - 1) * .56f, .35f, GooseCircularContainer.CenterZ), new Vector3(.42f, .65f, .42f), true));
                    tops.Add(FixtureBox(root.transform, "phone-fixture-top-" + i, new Vector3((i - 1) * .56f, .825f, GooseCircularContainer.CenterZ), new Vector3(.42f, .3f, .42f), false));
                }
                ResetFallbackFixture(tops, lower); cages = PinningCages(root.transform, tops); Physics.SyncTransforms();
                yield return FixturePhoneGesture("fixture-pinned-three", tops.ToArray(), lower.ToArray());
                cages.SetActive(false); ResetFallbackFixture(tops, lower);
                yield return FixturePhoneGesture("fixture-free-three", tops.ToArray(), lower.ToArray());
                for (int i = 1; i < 3; i++) foreach (var item in new[] { tops[i], lower[i] }) { game.Items.Remove(item); item.gameObject.SetActive(false); }
                var single = new[] { tops[0] }; var singleLower = new[] { lower[0] };
                ResetFallbackFixture(single, singleLower); cages = PinningCages(root.transform, single, true); Physics.SyncTransforms();
                Check(!Physics.GetIgnoreLayerCollision(0, 2), "single-object pinning supports have real collision with the target layer");
                var beforeProp = game.Props[2]; Check(!game.UseProp(2) && game.Props[2] == beforeProp, "ordinary prop remains unavailable for the one-object fixture");
                yield return FixturePhoneGesture("fixture-pinned-single", single, singleLower.Concat(cages.GetComponentsInChildren<GooseItem>()).ToArray());
                ResetFallbackFixture(single, singleLower); var state = single.Select(Capture).ToArray();
                bool began = game.SurfaceShuffle.BeginTossFromShake(single, game.Container, .001f); yield return Settle(.12f);
                Check(!began || !game.SurfaceShuffle.Active, "insufficient phone-helper time is rejected or ends by its deadline");
                Check(!game.SurfaceShuffle.Active && single.All(i => !i.SurfaceAnimating && i.Colliders.All(c => c.enabled)), "insufficient phone-helper time restores every collision state");
                Check(state.All(p => Vector3.Distance(p.position, p.item.Body.position) < .01f) && SameTools(props, uses), "phone-helper deadline failure cannot move inventory or refund a prop");
                var wrongRoot = new GameObject("ForeignContainerIdentityProbe");
                var wrongContainer = wrongRoot.AddComponent<GooseCircularContainer>();
                Check(!game.SurfaceShuffle.BeginTossFromShake(single, wrongContainer), "phone toss rejects the wrong round container"); Destroy(wrongRoot);
                Check(SameTools(props, uses), "all independent phone fixtures preserve original prop and use counts");
            }
            finally
            {
                game.SurfaceShuffle.CancelRound(); game.Shake.CancelRound(); game.Items.Clear(); root.SetActive(false); Destroy(root);
                game.Items.AddRange(originals); foreach (var item in originals) if (item) item.gameObject.SetActive(true);
                Physics.SyncTransforms(); game.Depth.ResetRound(); game.Depth.SpawnFinished(true); game.Depth.RefreshNow();
            }
            yield return Settle(1);
        }
        bool ActualUnderside(GooseItem item, out RaycastHit hit)
        {
            var collider = item.SelectionCollider; var com = item.Body.worldCenterOfMass;
            return collider.Raycast(new Ray(new Vector3(com.x, collider.bounds.min.y - 2, com.z), Vector3.up),
                out hit, collider.bounds.size.y + 4);
        }
        IEnumerator TiltedSingleConvexFixture(string itemId = "ref_bfxiaolongbao", string operation = "fixture-actual-tilted-steamer-single",
            string imageName = "actual-tilted-steamer", float tiltDegrees = 15)
        {
            // Use the real cooked item collider as an independent geometry oracle.
            // The source physics mesh has fan indices, not closed convex faces.
            var originals = game.Items.ToArray(); foreach (var item in originals) item.gameObject.SetActive(false); game.Items.Clear();
            var root = new GameObject("ActualTiltedSteamerSupportFixture");
            try
            {
                var top = game.CreateItem(itemId); top.transform.SetParent(root.transform, true);
                top.Body.isKinematic = false; top.Body.useGravity = false; top.Body.constraints = RigidbodyConstraints.None;
                top.Body.interpolation = RigidbodyInterpolation.None;
                top.Body.position = new Vector3(.3f, 3, GooseCircularContainer.CenterZ);
                top.Body.rotation = Quaternion.identity; top.transform.SetPositionAndRotation(top.Body.position, top.Body.rotation);
                top.Body.velocity = top.Body.angularVelocity = Vector3.zero; Physics.SyncTransforms();
                bool firstHit = ActualUnderside(top, out var underside);
                Check(firstHit && top.SelectionCollider is MeshCollider && ((MeshCollider)top.SelectionCollider).convex,
                    operation + " uses the actual cooked model convex collider");
                if (!firstHit) yield break;
                // Align an actual supporting face, then tilt both item and support
                // by the fixture angle. The size-budget fixtures stay level to
                // avoid confusing a real ball rolling downhill with planner cost.
                // No rotation lock holds any item after landing.
                var aligned = Quaternion.FromToRotation(-underside.normal, Vector3.up) * top.Body.rotation;
                top.Body.rotation = Quaternion.AngleAxis(tiltDegrees, Vector3.forward) * aligned;
                top.transform.SetPositionAndRotation(top.Body.position, top.Body.rotation); Physics.SyncTransforms();
                bool tiltedHit = ActualUnderside(top, out underside);
                Check(tiltedHit && (tiltDegrees <= 0 || -underside.normal.y >= .8f), operation + " independent underside ray measures the real collider");
                if (!tiltedHit) yield break;
                var normal = -underside.normal; float thickness = game.ItemScale * .16f;
                var contactPoint = underside.point;
                if (tiltDegrees <= 0)
                {
                    // A second ray can reach a different face after alignment.
                    // A prescribed horizontal budget fixture must stay horizontal:
                    // place it below the true hull minimum and let gravity settle
                    // the unconstrained item naturally on that level platform.
                    normal = Vector3.up;
                    contactPoint.y = GooseColliderGeometry.MinY(top.SelectionCollider,
                        GooseColliderGeometry.BodyMatrix(top.SelectionCollider, top.Body));
                }
                var support = FixtureBox(root.transform, imageName + "-support",
                    contactPoint - normal * (thickness * .5f + .003f), new Vector3(game.ItemScale * 2.8f, thickness, game.ItemScale * 2.8f), true);
                support.Body.rotation = Quaternion.FromToRotation(Vector3.up, normal);
                support.transform.SetPositionAndRotation(support.Body.position, support.Body.rotation);
                support.gameObject.layer = 2;
                foreach (var renderer in support.Renderers) renderer.forceRenderingOff = true;
                top.Body.useGravity = true; top.DepthReady = true; top.DepthStillSince = Time.time - 2; top.DepthProtectedUntil = Time.time - 1;
                Physics.SyncTransforms(); game.Depth.ResetRound(); game.Depth.SpawnFinished(true); game.Depth.RefreshNow(); yield return Settle(.8f);
                Check(top.Body.constraints == RigidbodyConstraints.None && !top.Body.isKinematic && top.Body.useGravity,
                    operation + " has ordinary gravity and no rotation lock before the gesture");
                float actualAngle = Vector3.Angle(support.transform.up, Vector3.up);
                Check(tiltDegrees > 0 ? actualAngle >= 8 : actualAngle <= 1,
                    operation + " support has the independently requested real plane angle");
                GooseFrameCapture.Save(Path.Combine(output, imageName + "-before.png"));
                yield return FixturePhoneGesture(operation, new[] { top }, new[] { support });
                Check(top.Body.constraints == RigidbodyConstraints.None && !top.Body.isKinematic && top.Body.useGravity,
                    operation + " restores free physical settling without a rotation lock");
                GooseFrameCapture.Save(Path.Combine(output, imageName + "-after.png"));
            }
            finally
            {
                game.SurfaceShuffle.CancelRound(); game.Shake.CancelRound(); game.Items.Clear(); root.SetActive(false); Destroy(root);
                game.Items.AddRange(originals); foreach (var item in originals) if (item) item.gameObject.SetActive(true);
                Physics.SyncTransforms(); game.Depth.ResetRound(); game.Depth.SpawnFinished(true); game.Depth.RefreshNow();
            }
            yield return Settle(1);
        }
        [Serializable] sealed class SingleRotationCase
        {
            public string name,item,failure,geometry;
            public bool began,success,cancelled,uprightUsed,jointAirborne,settledSleeping,cancelledWhilePaused;
            public Quaternion startRotation,endRotation,restoredRotation,settledRotation;
            public Vector3 startPosition,endPosition,settledPosition,settledVelocity,settledAngularVelocity;
            public float startTilt,endTilt,peakRise,peakAngle,netXZ,seconds,minimumY=100,originalBottomRange,itemScale;
            public int lowerViolations,vertices,envelopePasses;
            public float settledNetXZ,settledMinY,settledPenetration,settledMaxGap,settledMinGap=100;
            public double planningMs,maxSliceMs;
        }
        IEnumerator SingleRotationFixture(string name,string itemId,bool reject,bool cancel)
        {
            game.SurfaceShuffle.CancelRound();game.Shake.CancelRound();
            var originals=game.Items.ToArray();foreach(var item in originals)item.gameObject.SetActive(false);game.Items.Clear();
            var root=new GameObject("SingleRotationFixture");GooseItem top=null,support=null;
            Action<bool> completedHandler=null;
            var record=new SingleRotationCase{name=name,item=itemId,itemScale=game.ItemScale};report.singleRotationCases.Add(record);
            try
            {
                top=game.CreateItem(itemId);top.transform.SetParent(root.transform,true);
                top.Body.isKinematic=true;top.Body.useGravity=false;top.Body.constraints=RigidbodyConstraints.None;top.Body.interpolation=RigidbodyInterpolation.None;
                var rotation=new Quaternion(.73324f,.56618f,.35471f,.12642f).normalized;
                top.Body.position=new Vector3(.2f,5,GooseCircularContainer.CenterZ);top.Body.rotation=rotation;
                top.transform.SetPositionAndRotation(top.Body.position,rotation);Physics.SyncTransforms();
                var mesh=top.SelectionCollider as MeshCollider;
                Check(mesh&&mesh.convex&&mesh.sharedMesh,name+" uses actual cooked model geometry");
                record.vertices=mesh&&mesh.sharedMesh?mesh.sharedMesh.vertexCount:0;
                float minimum=GooseColliderGeometry.MinY(top.SelectionCollider,GooseColliderGeometry.BodyMatrix(top.SelectionCollider,top.Body));
                float thickness=game.ItemScale*.2f;
                support=FixtureBox(root.transform,name+"-support",new Vector3(.2f,minimum-thickness*.5f-.008f,GooseCircularContainer.CenterZ),new Vector3(game.ItemScale*4,thickness,game.ItemScale*4),true);
                support.gameObject.layer=2;foreach(var renderer in support.Renderers)renderer.forceRenderingOff=true;
                if(reject)
                {
                    support.Body.rotation=Quaternion.AngleAxis(50,Vector3.forward);support.transform.SetPositionAndRotation(support.Body.position,support.Body.rotation);Physics.SyncTransforms();
                    var p=support.Body.position;p.y+=minimum-.008f-support.SelectionCollider.bounds.max.y;
                    support.Body.position=p;support.transform.position=p;
                }
                top.DepthReady=true;top.DepthProtectedUntil=Time.time-1;top.DepthStillSince=Time.time-2;
                top.SetDepthHeld(false);top.Body.useGravity=true;top.Body.velocity=top.Body.angularVelocity=Vector3.zero;
                Physics.SyncTransforms();game.Depth.ResetRound();game.Depth.SpawnFinished(true);game.Depth.RefreshNow();
                // Reproduce the observed sleeping large-tilt state without a
                // rotation constraint; no physics step occurs before request.
                top.Body.Sleep();record.startPosition=top.Body.position;record.startRotation=top.Body.rotation;
                record.startTilt=Vector3.Angle(top.Body.rotation*Vector3.up,Vector3.up);
                Check(!top.Body.isKinematic&&top.Body.useGravity&&top.Body.constraints==RigidbodyConstraints.None,name+" starts dynamic with ordinary gravity and no rotation lock");
                var com=top.Body.worldCenterOfMass;float margin=Mathf.Clamp(Mathf.Min(top.SelectionCollider.bounds.size.x,top.SelectionCollider.bounds.size.z)*.03f,.008f,.02f);
                float low=100,high=-100;
                for(int i=0;i<5;i++)
                {
                    var offset=i==0?Vector3.zero:i==1?Vector3.right*margin:i==2?Vector3.left*margin:i==3?Vector3.forward*margin:Vector3.back*margin;
                    var ray=new Ray(new Vector3(com.x+offset.x,minimum-1,com.z+offset.z),Vector3.up);
                    bool hit=top.SelectionCollider.Raycast(ray,out var under,10);Check(hit,name+" independent underside sample "+i);
                    if(hit){low=Mathf.Min(low,under.point.y);high=Mathf.Max(high,under.point.y);}
                }
                record.originalBottomRange=high-low;
                if(itemId=="ref_gtstickerbook")Check(record.originalBottomRange>.025f+Mathf.Clamp(game.ItemScale*.06f,.025f,.065f)+.02f,name+" original tilted pose cannot satisfy the unchanged level-support tolerance");
                var lowerPosition=support.Body.position;var lowerRotation=support.Body.rotation;
                bool finished=false,success=false;float beganAt=Time.time,finishedAt=-1,firstMotion=-1;
                completedHandler=value=>{finished=true;success=value;finishedAt=Time.time;record.endPosition=top.Body.position;record.endRotation=top.Body.rotation;};
                game.SurfaceShuffle.Completed+=completedHandler;
                record.began=game.SurfaceShuffle.BeginTossFromShake(new[]{top},game.Container);
                Check(record.began,name+" accepts the original single target");
                float deadline=Time.time+1.60f;
                while(!finished&&Time.time<deadline)
                {
                    yield return new WaitForEndOfFrame();
                    var delta=top.Body.position-record.startPosition;
                    record.peakRise=Mathf.Max(record.peakRise,delta.y);record.peakAngle=Mathf.Max(record.peakAngle,Quaternion.Angle(record.startRotation,top.Body.rotation));
                    record.jointAirborne|=delta.y>=game.ItemScale*.6f&&Quaternion.Angle(record.startRotation,top.Body.rotation)>=75;
                    record.minimumY=Mathf.Min(record.minimumY,GooseColliderGeometry.MinY(top.SelectionCollider,GooseColliderGeometry.BodyMatrix(top.SelectionCollider,top.Body)));
                    if(!support.DepthHeld||!support.Body.isKinematic||support.Body.useGravity||Vector3.Distance(lowerPosition,support.Body.position)>.0005f||Quaternion.Angle(lowerRotation,support.Body.rotation)>.05f)record.lowerViolations++;
                    if(firstMotion<0&&delta.magnitude>.02f)firstMotion=Time.time;
                    if(cancel&&!finished&&firstMotion>=0&&Time.time-firstMotion>=.60f)
                    {
                        record.cancelled=true;game.SetPaused(true);record.cancelledWhilePaused=game.Paused;game.SurfaceShuffle.CancelRound();record.restoredRotation=top.Body.rotation;
                        Check(Vector3.Distance(top.Body.position,record.startPosition)<=.0005f&&Quaternion.Angle(top.Body.rotation,record.startRotation)<=.05f,name+" synchronous cancellation restores original position and rotation");
                        Check(top.Colliders.All(c=>c.enabled)&&top.Body.detectCollisions&&!top.Body.isKinematic&&top.Body.useGravity&&top.Body.velocity.sqrMagnitude<.000001f&&top.Body.angularVelocity.sqrMagnitude<.000001f,name+" cancellation restores original collision, gravity and velocity state");
                        Check(record.cancelledWhilePaused,name+" cancellation also covers the paused new-orientation state");game.SetPaused(false);
                    }
                }
                record.success=success;record.seconds=(finishedAt<0?Time.time:finishedAt)-beganAt;
                record.failure=game.SurfaceShuffle.LastFailure;record.geometry=game.SurfaceShuffle.LastSingleGeometry;
                record.envelopePasses=record.geometry.Split(new[]{"envelopeRawPoints="},StringSplitOptions.None).Length-1;
                record.uprightUsed=record.geometry.Contains("uprightLandingRotation=");record.endTilt=Vector3.Angle(record.endRotation*Vector3.up,Vector3.up);
                record.netXZ=Vector2.Distance(new Vector2(record.startPosition.x,record.startPosition.z),new Vector2(record.endPosition.x,record.endPosition.z));
                record.planningMs=game.SurfaceShuffle.LastPlanningMilliseconds;record.maxSliceMs=game.SurfaceShuffle.MaxPlanningSliceMilliseconds;
                Check(finished&&record.seconds<=1.51f,name+" completes or safely rejects within the unchanged helper deadline");
                // The original 2ms slice target is checked after an indivisible
                // MoveNext; retain actual cold/warm maxima, not a false hard cap.
                Check(record.lowerViolations==0,name+" original lower support remains fixed without gravity");
                if(reject)Check(!success&&record.uprightUsed&&record.envelopePasses==2&&record.failure.Contains("single_unstable_com_support")&&!game.SurfaceShuffle.Active,name+" rejects both completed envelope poses for the actual unsafe support rather than a timeout");
                else if(cancel)Check(record.cancelled&&!success&&record.uprightUsed,name+" cancellation exercised the new pose path");
                else
                {
                    Check(success&&record.uprightUsed,name+" genuinely completes the authored-up fallback");
                    Check(record.endTilt<1&&Quaternion.Angle(record.startRotation,record.endRotation)>30,name+" lands in the validated new orientation");
                    Check(record.netXZ>=game.ItemScale*.2f-.002f&&record.netXZ<=game.ItemScale*.3f+.002f,name+" keeps the original safe-neighbour displacement");
                    Check(record.jointAirborne,name+" simultaneously rises and flips in midair");
                    Check(record.minimumY>=GooseCircularContainer.FloorY-.025f,name+" actual rotating hull remains above the floor");
                    Check(!top.Body.isKinematic&&top.Body.useGravity&&top.Body.constraints==RigidbodyConstraints.None,name+" restores unconstrained gravity after landing");
                    yield return Settle(.7f);
                    record.settledPosition=top.Body.position;record.settledRotation=top.Body.rotation;record.settledVelocity=top.Body.velocity;
                    record.settledAngularVelocity=top.Body.angularVelocity;record.settledSleeping=top.Body.IsSleeping();
                    record.settledNetXZ=Vector2.Distance(new Vector2(record.startPosition.x,record.startPosition.z),new Vector2(top.Body.position.x,top.Body.position.z));
                    record.settledMinY=GooseColliderGeometry.MinY(top.SelectionCollider,GooseColliderGeometry.BodyMatrix(top.SelectionCollider,top.Body));
                    Check(!top.Body.isKinematic&&top.Body.useGravity&&top.Body.constraints==RigidbodyConstraints.None,name+" settles naturally without a rotation lock");
                    Check(record.settledNetXZ>=game.ItemScale*.12f,name+" retains real settled planar displacement");
                    Check(record.settledMinY>=GooseCircularContainer.FloorY-.025f&&new Vector2(top.Body.position.x,top.Body.position.z-GooseCircularContainer.CenterZ).magnitude<=game.Container.Radius+.05f,name+" settled hull and center stay within floor and bowl limits");
                    Check(support.DepthHeld&&support.Body.isKinematic&&!support.Body.useGravity&&Vector3.Distance(lowerPosition,support.Body.position)<=.0005f&&Quaternion.Angle(lowerRotation,support.Body.rotation)<=.05f,name+" lower support remains unchanged after settling");
                    var settledBounds=top.SelectionCollider.bounds;var settledCom=top.Body.worldCenterOfMass;
                    float settledMargin=Mathf.Clamp(Mathf.Min(settledBounds.size.x,settledBounds.size.z)*.03f,.008f,.02f);
                    for(int i=0;i<5;i++)
                    {
                        var offset=i==0?Vector3.zero:i==1?Vector3.right*settledMargin:i==2?Vector3.left*settledMargin:i==3?Vector3.forward*settledMargin:Vector3.back*settledMargin;
                        var down=new Ray(new Vector3(settledCom.x+offset.x,settledBounds.max.y+1,settledCom.z+offset.z),Vector3.down);
                        bool platformHit=support.SelectionCollider.Raycast(down,out var platform,20);
                        var up=new Ray(new Vector3(settledCom.x+offset.x,settledBounds.min.y-1,settledCom.z+offset.z),Vector3.up);
                        bool undersideHit=top.SelectionCollider.Raycast(up,out var under,20);
                        float gap=platformHit&&undersideHit?under.point.y-platform.point.y:100;
                        record.settledMaxGap=Mathf.Max(record.settledMaxGap,gap);record.settledMinGap=Mathf.Min(record.settledMinGap,gap);
                        Check(platformHit&&undersideHit&&platform.normal.y>=.8f&&gap>=-.02f&&gap<=Mathf.Clamp(game.ItemScale*.06f,.025f,.065f),name+" actual settled support and hull gap "+i);
                    }
                    int overlapCount=Physics.OverlapBoxNonAlloc(settledBounds.center,settledBounds.extents+.002f*Vector3.one,hitsColliders,Quaternion.identity,~0,QueryTriggerInteraction.Ignore);
                    Check(overlapCount<hitsColliders.Length,name+" settled collision query is complete");
                    for(int i=0;i<overlapCount;i++)
                    {
                        var other=hitsColliders[i];if(!other||other.attachedRigidbody==top.Body)continue;
                        if(Physics.ComputePenetration(top.SelectionCollider,top.SelectionCollider.transform.position,top.SelectionCollider.transform.rotation,other,other.transform.position,other.transform.rotation,out _,out float distance))record.settledPenetration=Mathf.Max(record.settledPenetration,distance);
                    }
                    Check(record.settledPenetration<=.002f,name+" real settled shape passes the original narrow-phase tolerance");
                }
                Save();
            }
            finally
            {
                if(completedHandler!=null)game.SurfaceShuffle.Completed-=completedHandler;
                if(game.Paused)game.SetPaused(false);
                game.SurfaceShuffle.CancelRound();game.Shake.CancelRound();game.Items.Clear();root.SetActive(false);Destroy(root);
                game.Items.AddRange(originals);foreach(var item in originals)if(item)item.gameObject.SetActive(true);
                Physics.SyncTransforms();game.Depth.ResetRound();game.Depth.SpawnFinished(true);game.Depth.RefreshNow();
            }
            yield return null;
        }

        IEnumerator PhoneFallbackInterruptions()
        {
            game.Depth.CopySurface(surface); var props = game.Props.ToArray(); var uses = ToolUses();
            Check(surface.Count > 0 && game.SurfaceShuffle.BeginTossFromShake(surface.ToArray(), game.Container), "phone toss interruption starts with the current fixed snapshot");
            yield return new WaitForSeconds(.1f); Check(game.SurfaceShuffle.OwnerPhoneToss, "pause interrupts a genuinely active controlled phone toss"); game.SetPaused(true);
            var poses = game.Remaining.Select(Capture).ToArray(); yield return new WaitForSecondsRealtime(.25f);
            Check(poses.All(p => Vector3.Distance(p.position, p.item.Body.position) < .001f), "paused phone helper preserves every pose");
            game.SurfaceShuffle.CancelRound(); Check(SameTools(props, uses), "cancelled phone helper cannot refund a paid tool");
            Check(game.SurfaceShuffle.LastMotion != null && game.SurfaceShuffle.LastMotion.mode == "controlled-pan-toss" && game.SurfaceShuffle.LastMotion.interrupted && !game.SurfaceShuffle.LastMotion.tossCompleted,
                "cancelled controlled toss reports interruption rather than completion or Force");
            Check(game.Remaining.All(i => !i.SurfaceAnimating && i.Colliders.All(c => c.enabled)), "cancelled phone helper restores all target colliders");
            game.SetPaused(false); yield return Settle(.4f); game.Depth.CopySurface(surface);
            Check(surface.Count > 0 && game.SurfaceShuffle.BeginTossFromShake(surface.ToArray(), game.Container), "controlled phone toss home-interruption starts");
            yield return new WaitForSeconds(.1f); int theme = game.ThemeIndex; game.GoHome(); yield return null;
            Check(!game.SurfaceShuffle.Active && !game.Shake.Active && game.Items.Count == 0 && SameTools(props, uses), "phone home-interruption clears identities without a refund");
            yield return Open(theme); yield return Settle(1.7f);
            Check(game.Props.All(n => n == 1) && ToolUses().All(n => n == 0), "old phone-helper work cannot change a new round's inventory or counters");
        }
        IEnumerator LateContainmentFixture()
        {
            // Resume after this frame's FixedUpdates. A pre-simulation Fixed
            // correction cannot satisfy the following same-frame EOF assertion.
            yield return null; game.Depth.CopySurface(surface);
            var top = surface.FirstOrDefault(i => !i.Body.isKinematic && !i.SurfaceAnimating);
            Check(top, "late containment fixture has an already active dynamic surface object"); if (!top) yield break;
            var body = top.Body; var original = Capture(top); bool sleeping = body.IsSleeping();
            var velocity = body.velocity; var angular = body.angularVelocity; var collision = body.collisionDetectionMode;
            float protectedUntil = top.DepthProtectedUntil, stillSince = top.DepthStillSince, occlusion = top.NextOcclusionCheck;
            var lower = game.Remaining.Where(i => i.DepthHeld).Select(Capture).ToArray();
            int frame = Time.frameCount, recoveries = game.Container.ContainmentRecoveries;
            var outward = Vector3.right; var tangent = Vector3.forward;
            var injected = new Vector3(game.Container.Radius + .12f, original.position.y, GooseCircularContainer.CenterZ);
            var injectedVelocity = outward * 1.2f + tangent * .7f + Vector3.up * .3f;
            var injectedAngular = new Vector3(.4f, .5f, .6f);
            try
            {
                body.position = injected; top.transform.position = injected;
                body.velocity = injectedVelocity; body.angularVelocity = injectedAngular; Physics.SyncTransforms();
                yield return new WaitForEndOfFrame();
                Check(Time.frameCount == frame, "late containment is verified in the injection frame without another FixedUpdate");
                var offset = new Vector2(body.position.x, body.position.z - GooseCircularContainer.CenterZ);
                var renderOffset = new Vector2(top.transform.position.x, top.transform.position.z - GooseCircularContainer.CenterZ);
                Check(offset.magnitude <= game.Container.Radius + .02f + .0001f && renderOffset.magnitude <= game.Container.Radius + .02f + .0001f,
                    "same-frame containment corrects both actual and rendered centers within the original policy");
                Check(Mathf.Abs(body.position.y - injected.y) < .0001f && Vector3.Distance(body.angularVelocity, injectedAngular) < .0001f,
                    "late containment preserves height and angular velocity");
                var expected = injectedVelocity - outward * Vector3.Dot(injectedVelocity, outward);
                Check(Vector3.Distance(body.velocity, expected) < .0001f,
                    "late containment removes only outward velocity while preserving vertical and tangential motion");
                Check(game.Container.ContainmentRecoveries > recoveries,
                    "same-frame correction actually runs the production containment path");
                Check(lower.All(p => p.item.DepthHeld && p.item.Body.isKinematic && !p.item.Body.useGravity &&
                    Vector3.Distance(p.position, p.item.Body.position) < .0005f && Quaternion.Angle(p.rotation, p.item.Body.rotation) < .05f &&
                    p.colliders.Where((c, i) => c && c.enabled != p.enabled[i]).Count() == 0),
                    "late containment never moves or changes hidden kinematic support states");
            }
            finally
            {
                body.position = original.position; body.rotation = original.rotation;
                top.transform.SetPositionAndRotation(original.position, original.rotation);
                body.velocity = velocity; body.angularVelocity = angular; body.collisionDetectionMode = collision;
                top.DepthProtectedUntil = protectedUntil; top.DepthStillSince = stillSince; top.NextOcclusionCheck = occlusion;
                Physics.SyncTransforms(); if (sleeping) body.Sleep(); else body.WakeUp();
            }
        }
        IEnumerator EnsurePaidExchangeTargets(string scenario)
        {
            game.Depth.CopySurface(surface);
            if (surface.Count < 2)
            {
                // Establish this subcase independently. A real final-three pile
                // can settle to one exposed object after the previous operation.
                // First verify that production correctly refuses a paid swap.
                if (game.Props[2] == 0) game.QaGrant(2, 1);
                int available = game.Props[2], uses = game.QaToolUses(2);
                var poses = game.Remaining.Select(Capture).ToArray();
                bool accepted = game.UseProp(2);
                Check(!accepted && !game.SurfaceShuffle.Active && game.Props[2] == available && game.QaToolUses(2) == uses,
                    scenario + " with fewer than two surface targets refuses the prop without spending inventory or uses");
                Check(game.SurfaceShuffle.LastFailure == "fewer_than_two_surface_targets",
                    scenario + " refusal is caused by unavailable exchange targets: " + game.SurfaceShuffle.LastFailure);
                Check(poses.All(p => Vector3.Distance(p.position, p.item.Body.position) < .0005f && Quaternion.Angle(p.rotation, p.item.Body.rotation) < .05f),
                    scenario + " unavailable exchange leaves all poses unchanged");
                int theme = game.ThemeIndex; yield return Open(theme); yield return Settle(1.6f); game.Depth.CopySurface(surface);
            }
            Check(surface.Count >= 2, scenario + " independently establishes at least two current exchange targets");
        }
        IEnumerator Interruptions()
        {
            yield return EnsurePaidExchangeTargets("pause interruption"); if (surface.Count < 2) yield break;
            game.QaGrant(2, 1); int available = game.Props[2];
            Check(game.UseProp(2), "interruption shuffle begins");
            Check(game.Props[2] == available - 1, "accepted shuffle reserves exactly one tool"); yield return new WaitForSeconds(.2f);
            var items = game.Remaining.ToArray(); var positions = items.Select(i => i.Body.position).ToArray(); game.SetPaused(true);
            yield return new WaitForSecondsRealtime(.25f);
            Check(items.Select((item, i) => Vector3.Distance(item.Body.position, positions[i])).All(d => d < .001f), "pause freezes shuffle poses");
            game.SetPaused(false); yield return Settle(2); Check(!game.SurfaceShuffle.Active, "resume completes shuffle");
            Check(game.SurfaceShuffle.LastMotion != null && !game.SurfaceShuffle.LastMotion.interrupted && game.Props[2] == available - 1,
                "successful resumed shuffle consumes exactly one tool without refund");
            Check(game.Remaining.All(i => !i.SurfaceAnimating && i.Colliders.All(c => c.enabled)), "resume restores all target collisions");
            yield return EnsurePaidExchangeTargets("same-round cancellation"); if (surface.Count < 2) yield break;
            game.QaGrant(2, 1); available = game.Props[2]; Check(game.UseProp(2), "same-round cancellation shuffle begins");
            yield return new WaitForSeconds(.2f); game.SurfaceShuffle.CancelRound();
            Check(game.Props[2] == available && !game.SurfaceShuffle.Active, "same-round cancellation refunds exactly one tool");
            Check(game.Remaining.All(i => !i.SurfaceAnimating && i.Colliders.All(c => c.enabled)), "same-round cancellation restores collision state");
            game.SurfaceShuffle.CancelRound(); Check(game.Props[2] == available, "repeated cancellation cannot refund twice"); yield return Settle(.4f);
            yield return EnsurePaidExchangeTargets("home interruption"); if (surface.Count < 2) yield break;
            game.QaGrant(2, 1); available = game.Props[2];
            Check(game.UseProp(2), "home interruption shuffle begins with surface=" + surface.Count + " failure=" + game.SurfaceShuffle.LastFailure);
            yield return new WaitForSeconds(.2f);
            Check(game.SurfaceShuffle.Active && !game.SurfaceShuffle.OwnerFromShake,
                "home interrupts a genuinely active paid shuffle rather than an unavailable operation");
            int roundTheme = game.ThemeIndex; game.GoHome(); yield return null;
            Check(!game.SurfaceShuffle.Active && !game.Shake.Active, "home cancels motion controllers");
            Check(game.Items.Count == 0, "home clears former inventory");
            Check(game.Props[2] == available, "home cancellation refunds before next round resets inventory");
            yield return Open(roundTheme); Check(game.Props[2] == 1, "new round begins with exactly one shuffle tool");
            yield return Settle(1.6f); Check(game.Props[2] == 1, "old animation cannot refund into new round inventory");
        }
        static void FrameStats(Row row, List<float> frames)
        {
            if (frames.Count == 0) return; row.frameTimingMeasured = true; frames.Sort(); row.p50ms = frames[(int)((frames.Count - 1) * .5f)];
            row.p95ms = frames[(int)((frames.Count - 1) * .95f)]; row.maxms = frames[frames.Count - 1]; row.slowFrameFraction = frames.Count(f => f > 50) / (float)frames.Count;
        }
        IEnumerator Watchdog() { yield return new WaitForSecondsRealtime(1800); if (!done) { report.errors.Add("surface QA watchdog"); Finish(); } }
        void Save() { report.passed = report.completed && report.errors.Count == 0; File.WriteAllText(Path.Combine(output, "surface-acceptance.json"), JsonUtility.ToJson(report, true)); }
        void Finish() { done = true; report.completed = true; Save(); Application.Quit(report.passed ? 0 : 1); }
    }
}
#endif
