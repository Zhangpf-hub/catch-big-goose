#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using UnityEngine;

namespace CatchGoose
{
    // Isolated observational QA. Frozen mode pins bodies, never disables depth
    // classification, and is explicitly distinct from the natural production run.
    public sealed class GooseVisibilityStabilityAcceptance : MonoBehaviour
    {
        [Serializable] struct State
        {
            public Vector3 position, velocity, angularVelocity;
            public Vector3 renderPosition;
            public Quaternion rotation;
            public Quaternion renderRotation;
            public int constraints, interpolation, rendererCount, enabledRenderers, forcedOffRenderers;
            public int rendererStateHash;
            public bool visible, held, kinematic, gravity, awake, surface, exposed;
            public bool occlusionKnown, cachedCovered;
            public int visibilityChanges;
            public int visibilityEpoch, committedVisibilityEpoch, classifications;
            public float nextOcclusionCheck;
        }
        [Serializable] sealed class RendererState
        {
            public string name;
            public bool enabled, forceRenderingOff;
        }
        [Serializable] sealed class Event
        {
            public float seconds, geometryStillSeconds;
            public int frame, geometryEpoch, reprobes;
            public string reason;
            public string phase;
            public State state;
            public RendererState[] renderers;
        }
        [Serializable] sealed class ItemResult
        {
            public int instanceId;
            public string id;
            public Vector3 localScale, visualLocalScale;
            public Quaternion visualLocalRotation;
            public bool trackedLower, coverageEligible, flickerDetected, cleanupRestored;
            public bool baselinePlanVisible, finalPlanMatchesBaseline;
            public int baselineClassifications, shiftedClassifications, restoredClassifications;
            public Vector3 baselinePlanPosition;
            public Quaternion baselinePlanRotation;
            public int reprobes, stableGeometryReprobes, visibleFlips, rendererFlips, lowerStateChanges, outputMismatchFrames;
            public int maxFlipsInStableGeometry, eventsOmitted;
            public float maxPositionChange, maxRotationChange;
            public State setupOriginal, initial, final, cleanup;
            public RendererState[] initialRenderers, finalRenderers;
            public List<float> reprobeSeconds = new List<float>();
            public List<Event> events = new List<Event>();
        }
        [Serializable] sealed class Capture
        {
            public string file;
            public float seconds;
        }
        [Serializable] sealed class EpochEvent
        {
            public string phase;
            public float seconds, lastEpochSeconds;
            public int started, committed, completions, classifications, discarded, pendingItems, pendingHides;
            public bool inProgress, dirty;
        }
        [Serializable] sealed class Report
        {
            public string build = GooseRuntimePerformance.BuildId;
            public string scope, mode, theme, unityVersion, platform, phase = "initial-commit";
            public string coverageContract = "Two actual camera-dirty epochs, every original item classified and committed in each, then original-camera stable window. Periodic polling is not required.";
            public uint seed;
            public bool completed, passed, coverageSufficient, frozenStateRestored;
            public int difficulty = 1, itemCount, frames, geometryEpochs, maxProbeCount;
            public int trackedLower, coverageEligible, coveredTwice, flickeringItems;
            public int initialCommittedEpoch, shiftedCommittedEpoch, restoredCommittedEpoch, dirtyEpochsCompleted;
            public int finalWindowVisibleFlips, planMismatches, hiddenAtReference;
            public bool cameraRestored, sameGeometryForRoundtrip;
            public string originalSimulationMode, observedSimulationMode, restoredSimulationMode;
            public bool originalAutoSimulation, observedAutoSimulation, restoredAutoSimulation, physicsSimulationChanged, physicsSimulationRestored;
            public float requestedSeconds, observedSeconds, longestStableGeometrySeconds, currentStableGeometrySeconds;
            public float modelSize, itemScale;
            public float finalWindowStartedSeconds, finalWindowSeconds;
            public Matrix4x4 cameraView, cameraProjection;
            public List<string> checks = new List<string>(), errors = new List<string>();
            public List<ItemResult> perItem = new List<ItemResult>();
            public List<Capture> captures = new List<Capture>();
            public List<EpochEvent> epochs = new List<EpochEvent>();
            public GooseVisibilityReferenceCapture.Result reference, shadowControl, colorGeometryReference;
        }
        sealed class Tracked
        {
            public GooseItem item;
            public ItemResult result;
            public State previous;
            public State original;
            public RigidbodyConstraints savedConstraints;
            public RigidbodyInterpolation savedInterpolation;
            public Vector3 savedVelocity, savedAngularVelocity;
            public bool savedSleeping, frozen, lowerPoseViolationObserved;
            public Vector3 geometryPosition;
            public Quaternion geometryRotation;
            public Vector3 geometryRenderPosition;
            public Quaternion geometryRenderRotation;
            public int stableEpoch = -1, flipsInEpoch, probeEpoch = -1, probesInEpoch;
        }

        readonly Report report = new Report();
        readonly List<Tracked> tracked = new List<Tracked>(320);
        GooseGame game;
        LevelDefinition observedLevel;
        string output;
        bool done, restoreFailed;
        bool simulationCaptured, simulationSaved;
        SimulationMode savedSimulationMode;
        float began, lastGeometryChange;
        int geometryEpoch;
        Matrix4x4 previousView, previousProjection;
        Camera observedCamera;
        Vector3 originalCameraPosition;
        Quaternion originalCameraRotation;
        bool haveCameraPose, baselinePlanRecorded;
        int readyEpoch = -1, previousStarted = -1, previousCommitted = -1;
        bool previousProgress, previousDirty;
        float readySince = -1;
        const int MaxEventsPerItem = 512;
        const float StableBeforeFlip = 1.5f;
        const float RequiredStableSeconds = 12;

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void Boot()
        {
            if (Array.IndexOf(Environment.GetCommandLineArgs(), "-gooseVisibilityQa") >= 0)
                new GameObject("VisibilityStabilityAcceptance").AddComponent<GooseVisibilityStabilityAcceptance>();
        }
        void OnEnable() { Application.logMessageReceived += Log; }
        void OnDisable() { Application.logMessageReceived -= Log; RestoreCamera(); RestoreFrozen(); }
        void OnDestroy() { RestoreCamera(); RestoreFrozen(); }
        void Log(string message, string stack, LogType kind)
        {
            if (kind == LogType.Error || kind == LogType.Exception || kind == LogType.Assert)
                report.errors.Add(message + "\n" + stack);
        }
        static string Arg(string[] args, string name, string fallback)
        {
            int index = Array.IndexOf(args, name);
            return index >= 0 && index + 1 < args.Length ? args[index + 1] : fallback;
        }
        void Check(bool success, string label) { (success ? report.checks : report.errors).Add(label); }

        IEnumerator Start()
        {
            // GooseGame.Awake has completed before the QA save namespace is used.
            yield return null;
            GooseSave.IsQa = true;
            var args = Environment.GetCommandLineArgs();
            output = Arg(args, "-gooseStabilityOutput", Path.Combine(Application.persistentDataPath, "visibility-stability-qa"));
            Directory.CreateDirectory(output);
            report.mode = Arg(args, "-gooseStabilityMode", "natural");
            report.scope = "Native production difficulty-1 scene, per-frame visibility/renderer/body observation. " +
                (report.mode == "frozen" ? "Fixed Body+render geometry experiment: automatic physics is stopped with SimulationMode.Script; dynamic velocity/spin are zeroed once, interpolation is temporarily None and FreezeAll is set once, without per-frame pose repair. Original body motion and simulation mode are restored. This is not a natural-physics result. " : "Natural production physics; simulation mode, interpolation and body constraints are unchanged. Initial/final pose and plan equality are observations, not natural-mode gates. ") +
                "Depth remains enabled. Two real camera changes exercise dirty epochs; final original-camera renderer output is compared against a same-frame full-render reference. Screenshots/oracle add timing overhead; no phone FPS claim.";
            report.unityVersion = Application.unityVersion; report.platform = Application.platform.ToString();
            int theme;
            float seconds;
            if (!int.TryParse(Arg(args, "-gooseStabilityTheme", "0"), out theme) ||
                !float.TryParse(Arg(args, "-gooseStabilityDuration", "30"), NumberStyles.Float, CultureInfo.InvariantCulture, out seconds) ||
                float.IsNaN(seconds) || float.IsInfinity(seconds) || seconds <= 0 ||
                (report.mode != "natural" && report.mode != "frozen"))
            { report.errors.Add("Invalid stability arguments"); Finish(); yield break; }
            report.requestedSeconds = Mathf.Clamp(seconds, 1, 60);
            game = GooseGame.Instance;
            if (!game || theme < 0 || theme >= game.Themes.Length)
            { report.errors.Add("Missing GooseGame or invalid theme index"); Finish(); yield break; }
            StartCoroutine(Watchdog());
            try
            {
                Screen.SetResolution(390, 844, false);
                game.GoHome(); game.SelectTheme(theme); game.SelectDifficulty(1); game.BeginRound(false);
                float spawnDeadline = Time.realtimeSinceStartup + 90;
                while (!game.SpawnComplete && Time.realtimeSinceStartup < spawnDeadline) yield return null;
                Check(game.SpawnComplete, "real difficulty-1 opening completed");
                if (!game.SpawnComplete) yield break;
                float settleDeadline = Time.realtimeSinceStartup + 3;
                while (Time.realtimeSinceStartup < settleDeadline) { game.QaSetTime(3600); yield return null; }
                report.theme = game.Theme.id;
                observedLevel = game.Level; report.seed = game.Level.seed;
                report.modelSize = game.ModelSize; report.itemScale = game.ItemScale;
                Check(game.Difficulty == 1 && game.Playing, "observing actual second difficulty");
                savedSimulationMode=Physics.simulationMode;simulationCaptured=true;
                report.originalSimulationMode=savedSimulationMode.ToString();report.originalAutoSimulation=Physics.autoSimulation;
                if(report.mode=="frozen")
                {simulationSaved=true;Physics.simulationMode=SimulationMode.Script;report.physicsSimulationChanged=true;}
                report.observedSimulationMode=Physics.simulationMode.ToString();report.observedAutoSimulation=Physics.autoSimulation;
                foreach (var item in game.Items)
                {
                    if (!item || item.Picked || !item.gameObject.activeInHierarchy || !item.Body) continue;
                    var state = Read(item);
                    var result = new ItemResult { instanceId = item.GetInstanceID(), id = item.Id, setupOriginal = state,
                        localScale = item.transform.localScale, visualLocalScale = item.Visual.localScale, visualLocalRotation = item.Visual.localRotation,
                        trackedLower = state.held, coverageEligible = state.held && !state.exposed };
                    var entry = new Tracked { item = item, result = result, original = state,
                        savedConstraints = item.Body.constraints, savedVelocity = item.Body.velocity,
                        savedInterpolation = item.Body.interpolation,
                        savedAngularVelocity = item.Body.angularVelocity, savedSleeping = item.Body.IsSleeping(),
                        geometryPosition = state.position, geometryRotation = state.rotation };
                    tracked.Add(entry); report.perItem.Add(result);
                    if (report.mode == "frozen")
                    {
                        entry.frozen = true;
                        if(!item.Body.isKinematic){item.Body.velocity=Vector3.zero;item.Body.angularVelocity=Vector3.zero;}
                        item.Body.constraints = RigidbodyConstraints.FreezeAll;
                        item.Body.interpolation=RigidbodyInterpolation.None;
                        item.transform.SetPositionAndRotation(state.position,state.rotation);
                    }
                    if (result.trackedLower) report.trackedLower++;
                    if (result.coverageEligible) report.coverageEligible++;
                }
                if(report.mode=="frozen")Physics.SyncTransforms();
                // Formal observation starts only after the one-time fixture setup.
                foreach(var entry in tracked)
                {
                    var state=Read(entry.item);entry.result.initial=state;entry.result.initialRenderers=ReadRenderers(entry.item);
                    entry.previous=state;entry.geometryPosition=state.position;entry.geometryRotation=state.rotation;
                    entry.geometryRenderPosition=state.renderPosition;entry.geometryRenderRotation=state.renderRotation;
                }
                report.itemCount = tracked.Count;
                Check(report.itemCount > 0 && report.trackedLower > 0, "nonempty real pile includes lower supports");
                previousView = game.MainCamera.worldToCameraMatrix; previousProjection = game.MainCamera.projectionMatrix;
                report.cameraView = previousView; report.cameraProjection = previousProjection;
                observedCamera = game.MainCamera; originalCameraPosition = observedCamera.transform.position;
                originalCameraRotation = observedCamera.transform.rotation; haveCameraPose = true;
                began = lastGeometryChange = Time.realtimeSinceStartup;
                yield return new WaitForEndOfFrame(); CaptureFrame("before.png");
                float nextCapture = 2;
                while (Time.realtimeSinceStartup - began < 60)
                {
                    game.QaSetTime(3600);
                    yield return new WaitForEndOfFrame();
                    Observe();
                    if (report.observedSeconds >= nextCapture)
                    { CaptureFrame("frame-" + nextCapture.ToString("000", CultureInfo.InvariantCulture) + ".png"); nextCapture += 2; Save(); }
                    AdvanceCoveragePhase();
                    if (report.phase == "final-original-camera")
                    {
                        report.finalWindowSeconds = report.observedSeconds - report.finalWindowStartedSeconds;
                        if (report.finalWindowSeconds >= Mathf.Max(RequiredStableSeconds, report.requestedSeconds) && CoverageComplete() &&
                            (report.mode!="frozen"||report.currentStableGeometrySeconds >= RequiredStableSeconds)) break;
                    }
                }
                CaptureFrame("after.png");
                if (report.phase == "final-original-camera" && report.finalWindowSeconds >= RequiredStableSeconds &&
                    (report.mode!="frozen"||report.currentStableGeometrySeconds >= RequiredStableSeconds))
                {
                    report.reference = GooseVisibilityReferenceCapture.Capture(game, output, "final-original-camera");
                    report.shadowControl = GooseVisibilityReferenceCapture.Capture(game, output, "final-shadow-control", true);
                    // Raw all-caster lighting and no-shadow controls remain independently reported,
                    // including failures. This gate tests color geometry under production lighting.
                    report.colorGeometryReference = GooseVisibilityReferenceCapture.Capture(game, output, "final-production-casters", false, true);
                    if (!report.colorGeometryReference.passed && Array.IndexOf(Environment.GetCommandLineArgs(), "-gooseVisibilityContributors") >= 0)
                        GooseVisibilityReferenceCapture.DiagnoseContributors(game, output);
                    Check(report.colorGeometryReference.passed, "caster-preserving color geometry within predeclared .25% / .001 limits");
                    Check(report.colorGeometryReference.casterControlApplicable && report.colorGeometryReference.casterStateRestored,
                        "same production caster identities and all casting flags restored");
                    Check(report.reference.noisePassed, "reference self-comparison within noise limits");
                    Check(report.reference.rendererStateRestored, "reference restores every renderer flag");
                    foreach (var entry in tracked) if (entry.item && !entry.item.Picked && !entry.item.DepthVisible) report.hiddenAtReference++;
                    Check(report.hiddenAtReference > 0 && report.reference.referenceRenderers > report.reference.productionRenderers,
                        "real hidden inventory remains; production does not render all objects");
                }
                else report.errors.Add("Reference not captured: original-camera final stable window incomplete");
                Summarize();
            }
            finally
            {
                RestoreCamera(); RestoreFrozen();
                // If the enumerator aborts early, retain an explicit incomplete
                // result instead of silently claiming a completed observation.
                if (!done) Finish();
            }
        }

        static State Read(GooseItem item)
        {
            var state = new State { position = item.Body.position, rotation = item.Body.rotation,
                velocity = item.Body.velocity, angularVelocity = item.Body.angularVelocity,
                constraints = (int)item.Body.constraints, interpolation=(int)item.Body.interpolation,
                renderPosition=item.transform.position,renderRotation=item.transform.rotation,
                visible = item.DepthVisible, held = item.DepthHeld,
                kinematic = item.Body.isKinematic, gravity = item.Body.useGravity, awake = !item.Body.IsSleeping(),
                surface = item.SurfaceActive, exposed = item.SurfaceExposed, visibilityChanges = item.VisibilityChanges,
                visibilityEpoch = item.VisibilityEpoch, committedVisibilityEpoch = item.CommittedVisibilityEpoch,
                classifications = item.VisibilityClassifications,
                occlusionKnown = item.OcclusionKnown, cachedCovered = item.CachedCovered, nextOcclusionCheck = item.NextOcclusionCheck };
            foreach (var renderer in item.Renderers)
            {
                if (!renderer) continue;
                state.rendererCount++;
                if (renderer.enabled) state.enabledRenderers++;
                if (renderer.forceRenderingOff) state.forcedOffRenderers++;
                state.rendererStateHash = unchecked(state.rendererStateHash * 31 + (renderer.enabled ? 1 : 0) + (renderer.forceRenderingOff ? 2 : 0));
            }
            return state;
        }
        static RendererState[] ReadRenderers(GooseItem item)
        {
            var renderers = item.Renderers;
            var result = new RendererState[renderers.Length];
            for (int i = 0; i < renderers.Length; i++)
                result[i] = new RendererState { name = renderers[i] ? renderers[i].name : "<destroyed>",
                    enabled = renderers[i] && renderers[i].enabled, forceRenderingOff = renderers[i] && renderers[i].forceRenderingOff };
            return result;
        }
        static bool MatrixChanged(Matrix4x4 a, Matrix4x4 b)
        {
            for (int i = 0; i < 16; i++) if (Mathf.Abs(a[i] - b[i]) > .00001f) return true;
            return false;
        }
        void Observe()
        {
            report.frames++; report.observedSeconds = Time.realtimeSinceStartup - began;
            report.maxProbeCount = Mathf.Max(report.maxProbeCount, game.Depth.LastProbeCount);
            var depth = game.Depth;
            if (previousStarted != depth.VisibilityEpoch || previousCommitted != depth.CompletedVisibilityEpoch ||
                previousProgress != depth.VisibilityEpochInProgress || previousDirty != depth.VisibilityDirty)
            {
                report.epochs.Add(new EpochEvent { phase = report.phase, seconds = report.observedSeconds,
                    started = depth.VisibilityEpoch, committed = depth.CompletedVisibilityEpoch, completions = depth.VisibilityEpochCompletions,
                    classifications = depth.VisibilityClassifications, discarded = depth.DiscardedVisibilityEpochs,
                    pendingItems = depth.PendingVisibilityItems, pendingHides = depth.PendingVisibilityHides,
                    inProgress = depth.VisibilityEpochInProgress, dirty = depth.VisibilityDirty, lastEpochSeconds = depth.LastVisibilityEpochSeconds });
                previousStarted = depth.VisibilityEpoch; previousCommitted = depth.CompletedVisibilityEpoch;
                previousProgress = depth.VisibilityEpochInProgress; previousDirty = depth.VisibilityDirty;
            }
            var view = game.MainCamera.worldToCameraMatrix; var projection = game.MainCamera.projectionMatrix;
            bool geometryChanged = MatrixChanged(view, previousView) || MatrixChanged(projection, previousProjection);
            previousView = view; previousProjection = projection;
            foreach (var entry in tracked)
                if (!entry.item || !entry.item.Body || entry.item.Picked || !entry.item.gameObject.activeInHierarchy ||
                    Vector3.Distance(entry.geometryPosition, entry.item.Body.position) > .0001f ||
                    Quaternion.Angle(entry.geometryRotation, entry.item.Body.rotation) > .01f||
                    (report.mode=="frozen"&&((entry.geometryRenderPosition-entry.item.transform.position).sqrMagnitude>.00000001f||
                    Quaternion.Angle(entry.geometryRenderRotation,entry.item.transform.rotation)>.01f))) geometryChanged = true;
            if (geometryChanged)
            {
                geometryEpoch++; lastGeometryChange = Time.realtimeSinceStartup;
                foreach (var entry in tracked) if (entry.item && entry.item.Body)
                {
                    entry.geometryPosition = entry.item.Body.position; entry.geometryRotation = entry.item.Body.rotation;
                    entry.geometryRenderPosition=entry.item.transform.position;entry.geometryRenderRotation=entry.item.transform.rotation;
                }
            }
            float stillFor = Time.realtimeSinceStartup - lastGeometryChange;
            report.geometryEpochs = geometryEpoch;
            report.currentStableGeometrySeconds = stillFor;
            report.longestStableGeometrySeconds = Mathf.Max(report.longestStableGeometrySeconds, stillFor);
            foreach (var entry in tracked)
            {
                if (!entry.item || !entry.item.Body) continue;
                var current = Read(entry.item); var previous = entry.previous; var result = entry.result;
                if (current.nextOcclusionCheck > previous.nextOcclusionCheck + .0001f)
                {
                    result.reprobes++;
                    if (result.reprobeSeconds.Count < 256) result.reprobeSeconds.Add(report.observedSeconds);
                    if (entry.probeEpoch != geometryEpoch) { entry.probeEpoch = geometryEpoch; entry.probesInEpoch = 0; }
                    if (stillFor >= StableBeforeFlip) entry.probesInEpoch++;
                }
                result.stableGeometryReprobes = entry.probeEpoch == geometryEpoch ? entry.probesInEpoch : 0;
                bool flip = current.visible != previous.visible;
                bool rendererFlip = current.rendererStateHash != previous.rendererStateHash || current.rendererCount != previous.rendererCount;
                bool lowerState = current.held != previous.held || current.kinematic != previous.kinematic || current.gravity != previous.gravity;
                bool counterChanged = current.visibilityChanges != previous.visibilityChanges;
                bool classified = current.classifications != previous.classifications;
                if (current.enabledRenderers != (current.visible ? current.rendererCount : 0) || current.forcedOffRenderers != 0)
                    result.outputMismatchFrames++;
                if (flip)
                {
                    result.visibleFlips++;
                    if (report.phase == "final-original-camera") report.finalWindowVisibleFlips++;
                    if (entry.stableEpoch != geometryEpoch) { entry.stableEpoch = geometryEpoch; entry.flipsInEpoch = 0; }
                    if (stillFor >= StableBeforeFlip && report.phase == "final-original-camera")
                    {
                        entry.flipsInEpoch++;
                        result.maxFlipsInStableGeometry = Mathf.Max(result.maxFlipsInStableGeometry, entry.flipsInEpoch);
                        if (entry.flipsInEpoch >= 2) result.flickerDetected = true;
                    }
                }
                if (rendererFlip) result.rendererFlips++;
                if (lowerState) result.lowerStateChanges++;
                result.maxPositionChange = Mathf.Max(result.maxPositionChange, Vector3.Distance(result.initial.position, current.position));
                result.maxRotationChange = Mathf.Max(result.maxRotationChange, Quaternion.Angle(result.initial.rotation, current.rotation));
                bool lowerPose = result.trackedLower && !entry.lowerPoseViolationObserved &&
                    (result.maxPositionChange > .001f || result.maxRotationChange > .1f);
                if (lowerPose) entry.lowerPoseViolationObserved = true;
                if (flip || rendererFlip || lowerState || lowerPose || counterChanged || classified || current.awake != previous.awake)
                {
                    string reason = (flip ? "visible " : "") + (rendererFlip ? "renderer " : "") +
                        (lowerState ? "lower-state " : "") + (lowerPose ? "lower-pose " : "") +
                        (counterChanged ? "counter " : "") + (classified ? "classified " : "") + (current.awake != previous.awake ? "awake" : "");
                    if (result.events.Count < MaxEventsPerItem)
                        result.events.Add(new Event { seconds = report.observedSeconds, frame = Time.frameCount, geometryEpoch = geometryEpoch,
                            geometryStillSeconds = stillFor, reprobes = result.reprobes, phase = report.phase, reason = reason.Trim(), state = current, renderers = ReadRenderers(entry.item) });
                    else result.eventsOmitted++;
                }
                result.final = current; entry.previous = current;
            }
        }
        bool CoverageComplete()
        {
            if (report.dirtyEpochsCompleted != 2 || !ReadyForEpoch(report.shiftedCommittedEpoch)) return false;
            foreach (var entry in tracked)
                if (entry.result.shiftedClassifications <= entry.result.baselineClassifications ||
                    entry.result.restoredClassifications <= entry.result.shiftedClassifications) return false;
            return tracked.Count > 0;
        }
        bool ReadyForEpoch(int after)
        {
            var depth = game.Depth;
            if (depth.CompletedVisibilityEpoch <= after || depth.VisibilityEpochInProgress || depth.VisibilityDirty) return false;
            foreach (var entry in tracked)
                if (!entry.item || entry.item.Picked || !entry.item.gameObject.activeInHierarchy ||
                    entry.item.CommittedVisibilityEpoch != depth.CompletedVisibilityEpoch) return false;
            return true;
        }
        void AdvanceCoveragePhase()
        {
            if (report.phase == "final-original-camera") return;
            int after = report.phase == "initial-commit" ? 0 :
                report.phase == "shifted-camera" ? report.initialCommittedEpoch : report.shiftedCommittedEpoch;
            if (!ReadyForEpoch(after)) { readySince = -1; return; }
            int completed = game.Depth.CompletedVisibilityEpoch;
            if (readySince < 0 || readyEpoch != completed)
            { readySince = Time.realtimeSinceStartup; readyEpoch = completed; return; }
            // Commit precedes the .35s hide timer. Wait for a real refresh after
            // it expires, so the baseline records settled renderer output.
            if (Time.realtimeSinceStartup - readySince < 1.5f) return;
            readySince = -1;
            if (report.phase == "initial-commit")
            {
                report.initialCommittedEpoch = completed; baselinePlanRecorded = true;
                foreach (var entry in tracked)
                {
                    var row = entry.result; row.baselinePlanVisible = entry.item.DepthVisible;
                    row.baselineClassifications = entry.item.VisibilityClassifications;
                    row.baselinePlanPosition = entry.item.Body.position; row.baselinePlanRotation = entry.item.Body.rotation;
                }
                CaptureFrame("initial-committed.png");
                observedCamera.transform.position = originalCameraPosition + observedCamera.transform.right * .03f;
                report.phase = "shifted-camera";
            }
            else if (report.phase == "shifted-camera")
            {
                report.shiftedCommittedEpoch = completed; report.dirtyEpochsCompleted = 1;
                foreach (var entry in tracked) entry.result.shiftedClassifications = entry.item.VisibilityClassifications;
                CaptureFrame("shifted-committed.png");
                observedCamera.transform.SetPositionAndRotation(originalCameraPosition, originalCameraRotation);
                report.phase = "restored-camera";
            }
            else
            {
                report.restoredCommittedEpoch = completed; report.dirtyEpochsCompleted = 2;
                foreach (var entry in tracked) entry.result.restoredClassifications = entry.item.VisibilityClassifications;
                report.phase = "final-original-camera"; report.finalWindowStartedSeconds = report.observedSeconds;
                CaptureFrame("restored-committed.png");
            }
        }
        void Summarize()
        {
            report.sameGeometryForRoundtrip = baselinePlanRecorded;
            report.coverageSufficient = CoverageComplete() && (report.mode!="frozen"||report.currentStableGeometrySeconds >= RequiredStableSeconds) &&
                report.finalWindowSeconds >= RequiredStableSeconds;
            foreach (var entry in tracked)
            {
                var row = entry.result;
                if (row.coverageEligible && row.shiftedClassifications > row.baselineClassifications &&
                    row.restoredClassifications > row.shiftedClassifications) report.coveredTwice++;
                if (row.flickerDetected) { report.flickeringItems++; report.errors.Add("Repeated stable-geometry visibility flips: " + row.id + "/" + row.instanceId); }
                if (!entry.item || !entry.item.Body || entry.item.Picked || !entry.item.gameObject.activeInHierarchy)
                { report.errors.Add("Tracked inventory changed: " + row.id + "/" + row.instanceId); continue; }
                row.finalRenderers = ReadRenderers(entry.item);
                row.finalPlanMatchesBaseline = baselinePlanRecorded && row.final.visible == row.baselinePlanVisible;
                if (!row.finalPlanMatchesBaseline) report.planMismatches++;
                if (!baselinePlanRecorded || Vector3.Distance(row.final.position, row.baselinePlanPosition) > .0001f ||
                    Quaternion.Angle(row.final.rotation, row.baselinePlanRotation) > .01f) report.sameGeometryForRoundtrip = false;
                if (row.trackedLower && (row.lowerStateChanges != 0 || !row.final.held || !row.final.kinematic || row.final.gravity ||
                    row.maxPositionChange > .001f || row.maxRotationChange > .1f))
                    report.errors.Add("Lower support changed state/pose: " + row.id + "/" + row.instanceId);
                if (row.outputMismatchFrames != 0)
                    report.errors.Add("Renderer/depth output mismatch: " + row.id + "/" + row.instanceId);
            }
            bool originalCamera = haveCameraPose && !MatrixChanged(observedCamera.worldToCameraMatrix, report.cameraView) &&
                !MatrixChanged(observedCamera.projectionMatrix, report.cameraProjection);
            report.coverageSufficient &= (report.mode!="frozen"||report.sameGeometryForRoundtrip) && originalCamera;
            Check(report.coverageSufficient, "coverage sufficient: two actual camera-dirty complete epochs cover every tracked item, original camera and >=12s continuous zero-flip window; frozen additionally requires same fixed geometry; otherwise inconclusive at 60s");
            Check(originalCamera, "original camera is restored during final observation");
            if(report.mode=="frozen")Check(report.sameGeometryForRoundtrip && report.planMismatches == 0, "same fixed camera/geometry yields same settled visibility plan");
            Check(report.maxProbeCount <= GoosePileDepth.MaxProbeCount, "depth query count remains <=256");
            Check(report.flickeringItems == 0, "no item flips repeatedly within unchanged geometry after settling");
            Check(report.finalWindowVisibleFlips == 0, "zero visible flips after final epoch and hide hysteresis settled");
            report.completed = true;
        }
        void RestoreCamera()
        {
            if (!haveCameraPose) return;
            if (!observedCamera || !game || game.MainCamera != observedCamera || game.Level != observedLevel)
            { report.cameraRestored = false; return; }
            observedCamera.transform.SetPositionAndRotation(originalCameraPosition, originalCameraRotation);
            report.cameraRestored = Vector3.Distance(observedCamera.transform.position, originalCameraPosition) < .00001f &&
                Quaternion.Angle(observedCamera.transform.rotation, originalCameraRotation) < .01f;
        }
        void RestoreFrozen()
        {
            bool correctedPose = false;
            try
            {
            foreach (var entry in tracked)
            {
                if (!entry.frozen) continue;
                if (!entry.item || !entry.item.Body || entry.item.Picked || !entry.item.gameObject.activeInHierarchy ||
                    !game || game.Level != observedLevel || !game.Items.Contains(entry.item) || entry.item.SurfaceAnimating)
                { restoreFailed = true; entry.frozen = false; continue; }
                var initial = entry.original; var body = entry.item.Body;
                // All observation results were finalized before cleanup. Restore
                // only this fixture's surviving instances in the original round;
                // never transfer a saved pose/motion to a later pooled round.
                entry.item.SetDepthHeld(initial.held);
                body.isKinematic = initial.kinematic; body.useGravity = initial.gravity;
                body.constraints = entry.savedConstraints; entry.item.SurfaceActive = initial.surface;
                body.interpolation=entry.savedInterpolation;
                body.position = initial.position; body.rotation = initial.rotation;
                entry.item.transform.SetPositionAndRotation(initial.position, initial.rotation);
                correctedPose = true;
                if (!body.isKinematic)
                {
                    body.velocity = entry.savedVelocity; body.angularVelocity = entry.savedAngularVelocity;
                }
                else if (entry.savedVelocity.sqrMagnitude > .000001f || entry.savedAngularVelocity.sqrMagnitude > .000001f)
                    restoreFailed = true;
                if (entry.savedSleeping) body.Sleep(); else body.WakeUp();
                entry.result.cleanup = Read(entry.item);
                entry.result.cleanupRestored = entry.item.DepthHeld == initial.held && body.isKinematic == initial.kinematic &&
                    body.useGravity == initial.gravity && body.constraints == entry.savedConstraints &&
                    body.interpolation==entry.savedInterpolation&&
                    Vector3.Distance(body.position, initial.position) < .0001f && Quaternion.Angle(body.rotation, initial.rotation) < .01f &&
                    body.IsSleeping() == entry.savedSleeping &&
                    (body.isKinematic || (Vector3.Distance(body.velocity, entry.savedVelocity) < .0001f &&
                    Vector3.Distance(body.angularVelocity, entry.savedAngularVelocity) < .0001f));
                if (!entry.result.cleanupRestored) restoreFailed = true;
                entry.frozen = false;
            }
            }
            finally
            {
                // Restore bodies/scene queries before automatic simulation may
                // resume. The exact original enum is the sole restoration source.
                try{if(correctedPose)Physics.SyncTransforms();}
                finally
                {
                    if(simulationSaved){Physics.simulationMode=savedSimulationMode;simulationSaved=false;}
                    if(simulationCaptured)
                    {
                        report.restoredSimulationMode=Physics.simulationMode.ToString();report.restoredAutoSimulation=Physics.autoSimulation;
                        report.physicsSimulationRestored=Physics.simulationMode==savedSimulationMode;
                    }
                }
            }
            if (report.mode == "frozen") report.frozenStateRestored = !restoreFailed;
        }
        void CaptureFrame(string file)
        {
            GooseFrameCapture.Save(Path.Combine(output, file));
            report.captures.Add(new Capture { file = file, seconds = Time.realtimeSinceStartup - began });
        }
        void Save()
        {
            report.passed = report.completed && report.errors.Count == 0;
            if (!string.IsNullOrEmpty(output)) File.WriteAllText(Path.Combine(output, "visibility-stability.json"), JsonUtility.ToJson(report, true));
        }
        void Finish()
        {
            if (done) return;
            done = true; RestoreCamera(); RestoreFrozen();
            if (haveCameraPose && !report.cameraRestored) report.errors.Add("Could not restore original QA camera");
            if (report.mode == "frozen" && !report.frozenStateRestored) report.errors.Add("Could not restore all original frozen body motion state");
            if(simulationCaptured&&!report.physicsSimulationRestored)report.errors.Add("Could not restore original physics simulation mode");
            if (!report.completed && report.errors.Count == 0) report.errors.Add("Observation terminated before summary");
            Save(); Application.Quit(report.passed ? 0 : 1);
        }
        IEnumerator Watchdog()
        {
            yield return new WaitForSecondsRealtime(180);
            if (!done) { report.errors.Add("Visibility stability watchdog"); Finish(); }
        }
    }
}
#endif
