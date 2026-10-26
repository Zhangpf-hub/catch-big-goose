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
            public string theme, operation, shuffleLastFailure, shuffleBlockingCollider; public int stock, surface, independentExposed, exposedSelected, affected, moved, turned, changedNeighbours;
            public int visible, renderers, drawSlots, triangles, dynamicBodies, awake, held, hidden, recoveries, probes, exposureDelta, untouchedLower, lowerViolations;
            public float p50ms, p95ms, maxms, slowFrameFraction, beginCpuMs, depthRefreshMs, activeSurfaceThreshold, modelSize, minHullY = 100, maxTravel, meanTravel, maxTurn, managedMiB, unityMiB;
            public double shufflePlanningMs, shuffleMaxSliceMs;
            public int gcCollections, planarMovedEnough; public float maxPlanarTravel; public bool frameTimingMeasured; public int[] targetIds;
        }
        [Serializable] sealed class ClipFrame { public string file; public float seconds; }
        [Serializable] sealed class Report
        {
            public string build = GooseRuntimePerformance.BuildId;
            public string scope = "Native graphics player, forced mobile profile. Synthetic sensor and production prop/input. Operation frame samples include QA checks. Phone FPS/temperature not measured.";
            public bool completed, passed; public List<string> checks = new List<string>(), errors = new List<string>(); public List<Row> rows = new List<Row>();
            public List<ClipFrame> clipFrames = new List<ClipFrame>();
        }
        sealed class Pose
        {
            public GooseItem item; public Vector3 position; public Quaternion rotation; public bool held, surface, gravity, visible, promoted;
            public Collider[] colliders; public bool[] enabled;
        }
        readonly Report report = new Report(); readonly List<GooseItem> surface = new List<GooseItem>(64);
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
            if (part == "clip") { themeCount = 1; report.scope = "Production-camera visual capture with moderate 1.6g synthetic sensor input. Capture work changes timing; frame performance is not sampled or assessed."; }
            yield return null; game = GooseGame.Instance; game.InstantPicksForQa = true; StartCoroutine(Watchdog());
            Screen.SetResolution(390, 844, false);
            for (int theme = firstTheme; theme < Mathf.Min(game.Themes.Length, firstTheme + themeCount); theme++)
            {
                yield return Open(theme);
                if (part == "clip") { yield return CaptureClip(); continue; }
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
        Row Structure(string operation)
        {
            game.Depth.CopySurface(surface); var items = game.Remaining.ToArray();
            var row = new Row { theme = game.Theme.id, operation = operation, stock = items.Length, surface = surface.Count,
                probes = game.Depth.LastProbeCount, depthRefreshMs = game.Depth.LastRefreshMs, managedMiB = GC.GetTotalMemory(false) / 1048576f,
                activeSurfaceThreshold = game.Depth.ActiveSurfaceThreshold, modelSize = game.ModelSize,
                shufflePlanningMs = game.SurfaceShuffle.LastPlanningMilliseconds, shuffleMaxSliceMs = game.SurfaceShuffle.MaxPlanningSliceMilliseconds,
                shuffleLastFailure = game.SurfaceShuffle.LastFailure, shuffleBlockingCollider = game.SurfaceShuffle.LastBlockingCollider,
                unityMiB = UnityEngine.Profiling.Profiler.GetTotalAllocatedMemoryLong() / 1048576f };
            foreach (var item in items)
            {
                if (item.DepthHeld) row.held++; if (!item.DepthVisible) row.hidden++;
                if (!item.Body.isKinematic) { row.dynamicBodies++; if (!item.Body.IsSleeping()) row.awake++; }
                if (item.PhysicsRecoveryActive) row.recoveries++;
                if (item.DepthVisible) { row.visible++; row.renderers += item.RenderCount; row.drawSlots += item.DrawSlots; row.triangles += item.Triangles; }
                row.minHullY = Mathf.Min(row.minHullY, GooseColliderGeometry.MinY(item.SelectionCollider));
            }
            Check(items.All(i => i.Colliders.All(c => c.enabled) && i.Body.detectCollisions), row.theme + " support collision retained " + operation + "/" + row.stock);
            Check(items.Where(i => i.DepthHeld).All(i => i.Body.isKinematic && !i.Body.useGravity), row.theme + " lower supports do not simulate gravity " + operation + "/" + row.stock);
            Check(row.probes <= GoosePileDepth.MaxProbeCount, row.theme + " bounded depth query work " + operation + "/" + row.stock);
            Check(row.minHullY >= GooseCircularContainer.FloorY - .025f, row.theme + " hulls above floor " + operation + "/" + row.stock);
            return row;
        }
        IEnumerator Passive()
        {
            var row = Structure("idle"); var frames = new List<float>(90); int gc = GC.CollectionCount(0);
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
        IEnumerator CaptureClip()
        {
            yield return Settle(1.6f); var row = Structure("sensor-moderate-clip");
            var poses = game.Remaining.Select(Capture).ToArray(); game.Depth.CopySurface(surface);
            var eligible = new HashSet<int>(surface.Select(i => i.GetInstanceID()));
            yield return new WaitForEndOfFrame(); GooseFrameCapture.Save(Path.Combine(output, "clip-before.png"));
            Check(InjectSensor(1.6f), "visual clip accepts a moderate 1.6g gesture");
            float began = Time.realtimeSinceStartup;
            for (int frame = 0; frame <= 25; frame++)
            {
                while (Time.realtimeSinceStartup < began + frame * .1f) yield return null;
                yield return new WaitForEndOfFrame(); string file = "clip-" + frame.ToString("000") + ".png";
                report.clipFrames.Add(new ClipFrame { file = file, seconds = Time.realtimeSinceStartup - began });
                GooseFrameCapture.Save(Path.Combine(output, file));
            }
            row.targetIds = game.Shake.TargetIds.ToArray();
            Check(row.targetIds.Length > 0 && row.targetIds.All(eligible.Contains), "visual clip affects only its initial activated surface");
            var targetPoses = poses.Where(p => p.item && row.targetIds.Contains(p.item.GetInstanceID())).ToArray();
            PlanarNetStats(row, targetPoses); var motion = game.Shake.LastMotion;
            Check(motion != null && motion.affected > 0, "visual clip records a completed nonzero motion");
            if (motion != null)
            {
                row.affected = motion.affected; row.moved = motion.moved; row.turned = motion.turned; row.changedNeighbours = motion.changedNeighbours;
                row.maxTravel = motion.maxTravel; row.meanTravel = motion.meanTravel; row.maxTurn = motion.maxTurn;
                int movedEnough = targetPoses.Count(p => Vector3.Distance(p.position, p.item.Body.position) >= game.ItemScale * .12f);
                Check(movedEnough >= Mathf.CeilToInt(targetPoses.Length * .5f), "visual clip retains half-cohort settled 3D displacement");
                Check(row.planarMovedEnough >= Mathf.CeilToInt(targetPoses.Length * .5f), "visual clip retains half-cohort settled XZ displacement");
                if (targetPoses.Length >= 3) Check(motion.changedNeighbours > 0 || RelativeOrderChanged(targetPoses) || motion.maxTurn >= 15,
                    "visual clip changes relative XZ order, neighbours or a clear orientation");
            }
            Structure("visual-clip-end"); Check(game.Remaining.Count() == row.stock, "visual clip conserves inventory");
            report.rows.Add(row); Save();
        }
        IEnumerator Operate(string operation)
        {
            yield return Settle(1.6f); game.Depth.CopySurface(surface);
            var row = Structure(operation); var poses = game.Remaining.Select(Capture).ToArray();
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
            var endRow = Structure(operation + "-end"); row.minHullY = endRow.minHullY; row.recoveries = endRow.recoveries;
            row.shufflePlanningMs = endRow.shufflePlanningMs; row.shuffleMaxSliceMs = endRow.shuffleMaxSliceMs;
            row.shuffleLastFailure = endRow.shuffleLastFailure; row.shuffleBlockingCollider = endRow.shuffleBlockingCollider;
            FrameStats(row, frames); row.gcCollections = GC.CollectionCount(0) - gc; report.rows.Add(row); Save();
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
        IEnumerator Interruptions()
        {
            game.Depth.CopySurface(surface);
            if (surface.Count < 2) { int theme = game.ThemeIndex; yield return Open(theme); game.Depth.CopySurface(surface); }
            Check(surface.Count >= 2, "interruption fixture has exchange targets"); if (surface.Count < 2) yield break;
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
            game.QaGrant(2, 1); available = game.Props[2]; Check(game.UseProp(2), "same-round cancellation shuffle begins");
            yield return new WaitForSeconds(.2f); game.SurfaceShuffle.CancelRound();
            Check(game.Props[2] == available && !game.SurfaceShuffle.Active, "same-round cancellation refunds exactly one tool");
            Check(game.Remaining.All(i => !i.SurfaceAnimating && i.Colliders.All(c => c.enabled)), "same-round cancellation restores collision state");
            game.SurfaceShuffle.CancelRound(); Check(game.Props[2] == available, "repeated cancellation cannot refund twice"); yield return Settle(.4f);
            game.QaGrant(2, 1); available = game.Props[2];
            Check(game.UseProp(2), "home interruption shuffle begins"); yield return new WaitForSeconds(.2f);
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
