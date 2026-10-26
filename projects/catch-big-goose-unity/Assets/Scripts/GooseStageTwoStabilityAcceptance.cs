#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEngine.EventSystems;

namespace CatchGoose
{
    // Exercises the real tutorial -> automatic challenge chain. No instant
    // picks, forced win, direct challenge start, or production-state repairs.
    public sealed class GooseStageTwoStabilityAcceptance : MonoBehaviour
    {
        [Serializable] sealed class BodyState
        {
            public int instanceId; public string item;
            public Vector3 position; public Quaternion rotation;
            public bool held, gravity, kinematic, visible, surface;
        }
        [Serializable] sealed class MotionTrace
        {
            public int instanceId; public string item;
            public Vector3 start, end; public Quaternion rotation;
            public float maxRise, maxTurn, peakXZ, peakPixels, netXZ;
            public bool airborneFlip, selected;
        }
        [Serializable] sealed class Frame { public string file; public float seconds; }
        [Serializable] sealed class Phase
        {
            public string name, helperFailure; public float seconds;
            public int difficulty, stock, candidates, targets;
            public bool spawnComplete, playing, pointerReady, active, helperActive;
        }
        [Serializable] sealed class Report
        {
            public string build = GooseRuntimePerformance.BuildId;
            public string scope = "Production pointer tutorial clear and automatic normal challenge; synthetic sensor/manual Request, not physical phone or OS keyboard validation.";
            public string theme, input; public float requestedDelay, actualDelay, itemScale, candidateCoverage;
            public int readyFrame, injectionFrame;
            public bool completed, passed, accepted, observedToss;
            public int warmupStock, tutorialPicks, secondStock, lowerViolations, floorViolations, boundaryViolations;
            public int challengeOpeningPeakShown, challengeFirstVisible, challengeFirstRenderers;
            public int[] acceptedIds, fixedStepIds; public GooseShakeController.MotionResult motion;
            public List<string> checks = new List<string>(), errors = new List<string>(), diagnostics = new List<string>();
            public List<Phase> phases = new List<Phase>();
            public List<MotionTrace> traces = new List<MotionTrace>();
            public List<BodyState> acceptedStates = new List<BodyState>();
            public List<BodyState> legitimatelyPromoted = new List<BodyState>();
            public List<Frame> clipFrames = new List<Frame>();
        }
        readonly Report report = new Report();
        readonly List<GooseItem> surface = new List<GooseItem>();
        readonly List<RaycastResult> uiHits = new List<RaycastResult>();
        PointerEventData uiPointer; EventSystem uiSystem;
        GooseGame game; string output; bool done; float began;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        {
            if (Environment.GetCommandLineArgs().Contains("-gooseStageTwoQa"))
                new GameObject("StageTwoStabilityAcceptance").AddComponent<GooseStageTwoStabilityAcceptance>();
        }
        static string Arg(string[] args, string key, string fallback)
        { int i = Array.IndexOf(args, key); return i >= 0 && i + 1 < args.Length ? args[i + 1] : fallback; }
        void OnEnable() { Application.logMessageReceived += Log; }
        void OnDisable() { Application.logMessageReceived -= Log; }
        void Log(string message, string stack, LogType kind)
        {
            if (kind == LogType.Error || kind == LogType.Exception || kind == LogType.Assert) report.errors.Add(message + "\n" + stack);
            else if ((message.Contains("[GooseShake]") || message.Contains("[GooseSurfaceShuffle]")) && report.diagnostics.Count < 200)
                report.diagnostics.Add(message);
        }
        void Check(bool ok, string text) { (ok ? report.checks : report.errors).Add(text); Save(); }
        void Save()
        {
            if (string.IsNullOrEmpty(output)) return;
            report.passed = report.completed && report.errors.Count == 0;
            File.WriteAllText(Path.Combine(output, "stage-two-stability.json"), JsonUtility.ToJson(report, true));
        }
        void Finish() { if (done) return; done = true; report.completed = true; Save(); Application.Quit(report.passed ? 0 : 1); }
        IEnumerator Watchdog() { yield return new WaitForSecondsRealtime(300); if (!done) { report.errors.Add("stage transition watchdog"); Finish(); } }
        BodyState State(GooseItem item) => new BodyState { instanceId = item.GetInstanceID(), item = item.Id,
            position = item.Body.position, rotation = item.Body.rotation, held = item.DepthHeld, gravity = item.Body.useGravity,
            kinematic = item.Body.isKinematic, visible = item.DepthVisible, surface = item.SurfaceActive };
        void PhaseAt(string name)
        {
            game.Depth.CopySurface(surface);
            report.phases.Add(new Phase { name = name, seconds = Time.realtimeSinceStartup - began,
                difficulty = game.Difficulty, stock = game.Remaining.Count(), candidates = surface.Count,
                targets = game.Shake.TargetIds.Count, spawnComplete = game.SpawnComplete, playing = game.Playing,
                pointerReady = game.CanSelectItems, active = game.Shake.Active, helperActive = game.SurfaceShuffle.OwnerPhoneToss,
                helperFailure = game.SurfaceShuffle.LastFailure });
            Save();
        }
        bool ScreenPoint(GooseItem item, out Vector2 point)
        {
            point = default; if (!item || !item.DepthVisible || item.Picked) return false;
            var b = item.SelectionCollider.bounds;
            for (int n = 0; n < 27; n++)
            {
                var world = b.center + Vector3.Scale(b.extents,
                    new Vector3((n % 3 - 1) * .65f, (n / 3 % 3 - 1) * .65f, (n / 9 - 1) * .65f));
                var screen = game.MainCamera.WorldToScreenPoint(world);
                if (screen.z > 0 && game.MainCamera.pixelRect.Contains(screen) && !OverUi(screen) && game.FindSelectableAtScreenPosition(screen) == item)
                { point = screen; return true; }
            }
            return false;
        }
        bool OverUi(Vector2 point)
        {
            if (!EventSystem.current) return false;
            if (uiSystem != EventSystem.current) { uiSystem = EventSystem.current; uiPointer = new PointerEventData(uiSystem); }
            uiPointer.Reset(); uiPointer.position = point; uiHits.Clear(); uiSystem.RaycastAll(uiPointer, uiHits);
            return uiHits.Count > 0;
        }
        IEnumerator Start()
        {
            var args = Environment.GetCommandLineArgs();
            output = Arg(args, "-gooseStabilityOutput", Path.Combine(Application.persistentDataPath, "stage-two-stability"));
            Directory.CreateDirectory(output); GooseSave.IsQa = true;
            int theme = int.Parse(Arg(args, "-gooseStabilityTheme", "0"));
            report.requestedDelay = float.Parse(Arg(args, "-gooseStabilityDelay", "0"), System.Globalization.CultureInfo.InvariantCulture);
            report.input = Arg(args, "-gooseStabilityInput", "sensor");
            yield return null; game = GooseGame.Instance; StartCoroutine(Watchdog());
            Screen.SetResolution(390, 844, false);
            int daily = GooseSave.Daily; bool gm = GooseSave.GmUnlimited;
            GooseSave.GmUnlimited = false; GooseSave.Daily = Math.Max(3, daily);
            game.InstantPicksForQa = false; game.GoHome(); game.SelectTheme(theme); report.theme = game.Theme.id;
            began = Time.realtimeSinceStartup; game.StartFromHome();
            float deadline = Time.realtimeSinceStartup + 100;
            while ((!game.SpawnComplete || !game.CanSelectItems) && Time.realtimeSinceStartup < deadline) yield return null;
            report.warmupStock = game.Total;
            Check(game.Playing && game.SpawnComplete && game.Difficulty == 0 && game.Total == 15, "production StartFromHome starts the fifteen-item tutorial");
            if (!game.Playing || !game.SpawnComplete || game.Difficulty != 0) { GooseSave.Daily = daily; GooseSave.GmUnlimited = gm; Finish(); yield break; }
            PhaseAt("tutorial-ready"); GooseFrameCapture.Save(Path.Combine(output, "tutorial-ready.png"));
            deadline = Time.realtimeSinceStartup + 70;
            while (game.Difficulty == 0 && report.tutorialPicks < 15 && Time.realtimeSinceStartup < deadline)
            {
                if (!game.CanSelectItems) { yield return null; continue; }
                GooseItem selected = null; Vector2 point = default;
                foreach (var item in game.Remaining.OrderByDescending(i => game.Tray.Entries.Any(t => t.Id == i.Id)).ThenByDescending(i => i.Body.position.y))
                    if (ScreenPoint(item, out point)) { selected = item; break; }
                if (!selected) { yield return new WaitForSeconds(.12f); continue; }
                if (game.BeginPointer(point, 848) && game.CurrentSelectedItem == selected)
                {
                    yield return new WaitForEndOfFrame();
                    if (game.EndPointer(point, 848)) report.tutorialPicks++;
                }
                else game.CancelPointer(848);
                Save(); yield return new WaitForSeconds(.34f);
            }
            Check(report.tutorialPicks == 15 && !game.InstantPicksForQa, "all tutorial items clear through normal production pointer down/up and tray arrivals");
            deadline = Time.realtimeSinceStartup + 100;
            while (!(game.Playing && game.Difficulty == 1 && game.SpawnComplete && game.CanSelectItems) && Time.realtimeSinceStartup < deadline)
            {
                if (game.Playing && game.Difficulty == 1)
                    report.challengeOpeningPeakShown = Mathf.Max(report.challengeOpeningPeakShown,
                        game.Remaining.Count(i => i.DepthVisible && i.Visual && i.Visual.localScale.sqrMagnitude > .000001f));
                yield return null;
            }
            report.secondStock = game.Total;
            Check(game.Playing && game.Difficulty == 1 && game.SpawnComplete && game.Total == 300, "tutorial win automatically adopts the same-theme three-hundred-item challenge");
            if (!game.Playing || game.Difficulty != 1 || !game.SpawnComplete) { GooseSave.Daily = daily; GooseSave.GmUnlimited = gm; Finish(); yield break; }
            report.challengeFirstVisible = game.Remaining.Count(i => i.DepthVisible);
            report.challengeFirstRenderers = game.Remaining.Where(i => i.DepthVisible).Sum(i => i.RenderCount);
            Check(report.challengeFirstVisible > 0 && report.challengeFirstVisible < 300 && report.challengeOpeningPeakShown < 300,
                "challenge opening and first interactive frame keep genuinely covered inventory culled");
            float ready = Time.realtimeSinceStartup; report.readyFrame = Time.frameCount; PhaseAt("challenge-first-interactive-frame");
            while (Time.realtimeSinceStartup < ready + report.requestedDelay) yield return null;
            report.actualDelay = Time.realtimeSinceStartup - ready;
            PhaseAt("before-first-shake"); report.itemScale = game.ItemScale;
            game.Depth.CopySurface(surface); var accepted = surface.ToArray();
            report.acceptedIds = accepted.Select(i => i.GetInstanceID()).ToArray();
            report.acceptedStates = game.Remaining.Select(State).ToList();
            var lower = game.Remaining.Where(i => i.DepthHeld && !i.SurfaceActive).ToDictionary(i => i, State);
            var promoted = new HashSet<GooseItem>();
            report.traces = accepted.Select(i => new MotionTrace { instanceId = i.GetInstanceID(), item = i.Id,
                start = i.Body.position, end = i.Body.position, rotation = i.Body.rotation }).ToList();
            var traces = report.traces.ToDictionary(t => t.instanceId);
            GooseFrameCapture.Save(Path.Combine(output, "clip-before.png"));
            report.actualDelay = Time.realtimeSinceStartup - ready; report.injectionFrame = Time.frameCount;
            int acceptedBefore = game.Shake.Accepted;
            if (report.input == "sensor")
            {
                game.Shake.ResetSensor(); float t = Time.unscaledTime;
                for (int n = 0; n < 6; n++) game.Shake.Sample(Vector3.forward, t + n * .06f);
                game.Shake.Sample(new Vector3(1.6f, 0, 1), t + .42f);
                game.Shake.Sample(new Vector3(-1.6f, 0, 1), t + .48f);
                game.Shake.Sample(Vector3.forward, t + .54f);
            }
            else game.Shake.Request(new Vector3(1, 0, .35f));
            report.accepted = game.Shake.Accepted == acceptedBefore + 1;
            PhaseAt("request-returned");
            Check(report.accepted && accepted.Length > 0, "first deliberate challenge gesture is accepted with a nonempty original activated surface");
            var container = game.Container; float motionStart = Time.realtimeSinceStartup;
            yield return new WaitForFixedUpdate();
            report.fixedStepIds = game.Shake.TargetIds.ToArray(); PhaseAt("after-first-fixed-step");
            foreach (var trace in report.traces) trace.selected = report.fixedStepIds.Contains(trace.instanceId);
            report.candidateCoverage = accepted.Length == 0 ? 0 : (float)report.fixedStepIds.Length / accepted.Length;
            Check(report.fixedStepIds.Length > 0 && report.fixedStepIds.All(report.acceptedIds.Contains), "next physics step retains original identities without replacing them from below");
            int frame = 0;
            while (Time.realtimeSinceStartup - motionStart < 3.5f)
            {
                yield return new WaitForEndOfFrame();
                report.observedToss |= game.SurfaceShuffle.OwnerPhoneToss;
                foreach (var item in accepted)
                {
                    if (!item) continue; var trace = traces[item.GetInstanceID()]; var position = item.Body.position;
                    var delta = position - trace.start; float turn = Quaternion.Angle(trace.rotation, item.Body.rotation);
                    trace.end = position; trace.maxRise = Mathf.Max(trace.maxRise, delta.y); trace.maxTurn = Mathf.Max(trace.maxTurn, turn);
                    trace.peakXZ = Mathf.Max(trace.peakXZ, new Vector2(delta.x, delta.z).magnitude);
                    trace.peakPixels = Mathf.Max(trace.peakPixels, Vector2.Distance(game.MainCamera.WorldToScreenPoint(trace.start), game.MainCamera.WorldToScreenPoint(position)));
                    trace.airborneFlip |= delta.y >= game.ItemScale * .6f && turn >= 75;
                    if (GooseColliderGeometry.MinY(item.SelectionCollider, GooseColliderGeometry.BodyMatrix(item.SelectionCollider, item.Body)) < GooseCircularContainer.FloorY - .025f) report.floorViolations++;
                    if (new Vector2(position.x, position.z - GooseCircularContainer.CenterZ).magnitude > container.Radius + .05f) report.boundaryViolations++;
                }
                foreach (var pair in lower)
                {
                    var item = pair.Key; var old = pair.Value;
                    if (promoted.Contains(item)) continue;
                    bool locked = game.Shake.Active || game.SurfaceShuffle.Active;
                    if (!locked && item && !item.DepthHeld && item.SurfaceActive && !item.Body.isKinematic && item.Body.useGravity &&
                        GoosePileDepth.WithinActiveSurfaceBand(item.SelectionCollider.bounds, game.Depth.ActiveSurfaceThreshold))
                    {
                        float top = game.Remaining.Max(i => i.SelectionCollider.bounds.max.y) + .2f;
                        int mask = ~((1 << 2) | (1 << 8) | (1 << 26) | (1 << 27) | (1 << 28) | (1 << 29) | (1 << 30));
                        if (GoosePileDepth.ProbeSurface(item, top, mask))
                        { promoted.Add(item); report.legitimatelyPromoted.Add(State(item)); continue; }
                    }
                    if (!item || Vector3.Distance(item.Body.position, old.position) > .0005f || Quaternion.Angle(item.Body.rotation, old.rotation) > .05f ||
                        item.DepthHeld != old.held || item.Body.isKinematic != old.kinematic || item.Body.useGravity != old.gravity) report.lowerViolations++;
                }
                float seconds = Time.realtimeSinceStartup - motionStart;
                if (seconds >= (frame + 1) * .1f && frame < 33)
                {
                    string file = "clip-" + frame.ToString("000") + ".png";
                    GooseFrameCapture.Save(Path.Combine(output, file)); report.clipFrames.Add(new Frame { file = file, seconds = seconds }); frame++;
                }
            }
            report.motion = game.Shake.LastMotion; PhaseAt("challenge-shake-settled");
            foreach (var trace in report.traces) trace.netXZ = new Vector2(trace.end.x - trace.start.x, trace.end.z - trace.start.z).magnitude;
            var selectedTraces = report.traces.Where(t => t.selected).ToArray();
            int needed = Mathf.Max(1, Mathf.CeilToInt(selectedTraces.Length * .6f));
            Check(report.candidateCoverage >= .8f, "original accepted surface coverage remains above the existing eighty-percent gate");
            Check(report.motion != null && report.motion.mode == "controlled-pan-toss" && report.motion.tossCompleted && !report.motion.interrupted && string.IsNullOrEmpty(report.motion.tossFailure), "the first challenge gesture completes its declared pan toss rather than only accepting input");
            Check(report.observedToss && selectedTraces.Count(t => t.airborneFlip) >= needed, "at least sixty percent of the original selected challenge targets actually rise and flip together in midair");
            Check(selectedTraces.Count(t => t.peakXZ >= game.ItemScale * .18f && t.peakPixels >= 15) >= needed, "challenge toss has a visible horizontal arc in the production camera");
            Check(selectedTraces.Count(t => t.netXZ >= game.ItemScale * .12f) >= Mathf.CeilToInt(selectedTraces.Length * .5f), "challenge toss retains settled horizontal rearrangement");
            Check(report.lowerViolations == 0 && report.floorViolations == 0 && report.boundaryViolations == 0 && game.Container == container, "challenge toss preserves the original container, lower supports, floor and boundary");
            GooseSave.Daily = daily; GooseSave.GmUnlimited = gm; Finish();
        }
    }
}
#endif
