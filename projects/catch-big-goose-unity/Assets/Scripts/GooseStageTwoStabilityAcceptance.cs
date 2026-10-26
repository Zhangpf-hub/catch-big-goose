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
            public Vector3 position,transformPosition,velocity,angularVelocity; public Quaternion rotation,transformRotation;
            public bool surfaceKnown,surfaceExposed,surfaceQueued,surfaceAnimating,colliderEnabled,recovering;
            public float nextSurfaceCheck,protectedUntil,stillSince; public int floorCorrections;
            public Bounds colliderBounds;
            public bool held, gravity, kinematic, visible, surface;
        }
        [Serializable] sealed class ProbeSample
        {
            public Vector3 origin; public bool ownHit,firstIsSelf;
            public string firstCollider,firstItem; public int firstId;
            public float ownDistance,firstDistance;
        }
        [Serializable] sealed class LowerViolationDiagnostic
        {
            public int instanceId,violatingSamples,frame,extraQueries,lastDepthQueries;
            public string item,phase="WaitForEndOfFrame after production LateUpdate",helperOwner;
            public float seconds,time,fixedTime,unscaledTime,band,cacheDeadlineDelta,positionDelta,angle,rawDot,componentDelta,oldSelfAngle,currentSelfAngle;
            public float containerRadius,targetRadius,diagnosticMilliseconds;
            public int containmentRecoveries,exposureActivations;
            public bool exists,shakeLock,helperLock,depthLock,inBand,productionProbe,independentProbe,cacheExpired,originalAccepted,qaLocked;
            public bool missingViolation,positionViolation,rotationViolation,heldViolation,kinematicViolation,gravityViolation;
            public bool beforeSimulation,inFixedStep,previousKnown,previousExposed,witnessAccepted;
            public GooseLowerPromotionWitnessPolicy.Evidence witness;public float previousNextCheck,previousFixedTime;
            public BodyState oldState,currentState; public List<ProbeSample> samples=new List<ProbeSample>();
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
            public string lowerDiagnosticScope="QA-only first 8 unique offenders at EOF; extra independent 25-point raycasts are excluded from runtime probe budget and timing claims. Original gate is unchanged.";
            public int lowerDiagnosticQueries,lowerUniqueOffenders,lowerDiagnosticOmittedUnique,lowerDiagnosticOmittedSamples;
            public float lowerDiagnosticMilliseconds;
            public List<LowerViolationDiagnostic> lowerOffenders=new List<LowerViolationDiagnostic>();
            public List<LowerViolationDiagnostic> fixedPromotions=new List<LowerViolationDiagnostic>();
            public int fixedPromotionOmitted,fixedObserverSteps,fixedWitnessEvaluations,fixedWitnessAccepted;
        }
        readonly Report report = new Report();
        readonly List<GooseItem> surface = new List<GooseItem>();
        readonly List<RaycastResult> uiHits = new List<RaycastResult>();
        PointerEventData uiPointer; EventSystem uiSystem;
        GooseGame game; string output; bool done; float began;
        readonly Dictionary<int,LowerViolationDiagnostic> lowerDiagnostics=new Dictionary<int,LowerViolationDiagnostic>();
        readonly HashSet<int> lowerDiagnosticSeen=new HashSet<int>();
        struct FixedLowerPrevious {public bool held,known,exposed;public float nextCheck,time;}
        readonly Dictionary<GooseItem,FixedLowerPrevious> fixedPrevious=new Dictionary<GooseItem,FixedLowerPrevious>();
        readonly HashSet<int> fixedRecorded=new HashSet<int>();
        Dictionary<GooseItem,BodyState> fixedLower;HashSet<GooseItem> fixedPromoted;LevelDefinition fixedRound;GooseStageTwoLowerFixedObserver fixedObserver;float fixedMotionStart;
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
            kinematic = item.Body.isKinematic, visible = item.DepthVisible, surface = item.SurfaceActive,
            transformPosition=item.transform.position,transformRotation=item.transform.rotation,velocity=item.Body.velocity,angularVelocity=item.Body.angularVelocity,
            surfaceKnown=item.SurfaceKnown,surfaceExposed=item.SurfaceExposed,surfaceQueued=item.SurfaceProbeQueued,surfaceAnimating=item.SurfaceAnimating,
            colliderEnabled=item.SelectionCollider&&item.SelectionCollider.enabled,colliderBounds=item.SelectionCollider?item.SelectionCollider.bounds:default,
            nextSurfaceCheck=item.NextSurfaceCheck,protectedUntil=item.DepthProtectedUntil,stillSince=item.DepthStillSince,
            recovering=item.PhysicsRecoveryActive,floorCorrections=item.FloorCorrections };
        void RecordLowerViolation(GooseItem item,BodyState old,bool locked,float motionStart)
        {
            int id=old.instanceId;
            if(lowerDiagnosticSeen.Add(id))report.lowerUniqueOffenders++;
            if(lowerDiagnostics.TryGetValue(id,out var existing)){existing.violatingSamples++;return;}
            if(lowerDiagnostics.Count>=8)
            {
                report.lowerDiagnosticOmittedSamples++;
                report.lowerDiagnosticOmittedUnique=report.lowerUniqueOffenders-lowerDiagnostics.Count;
                return;
            }
            var d=CaptureLowerDiagnostic(item,old,locked,motionStart);
            lowerDiagnostics.Add(id,d);report.lowerOffenders.Add(d);Save();
        }
        LowerViolationDiagnostic CaptureLowerDiagnostic(GooseItem item,BodyState old,bool locked,float motionStart)
        {
            long beganProbe=System.Diagnostics.Stopwatch.GetTimestamp();
            var d=new LowerViolationDiagnostic{instanceId=old.instanceId,item=old.item,violatingSamples=1,oldState=old,
                seconds=Time.realtimeSinceStartup-motionStart,time=Time.time,fixedTime=Time.fixedTime,unscaledTime=Time.unscaledTime,
                frame=Time.frameCount,exists=item&&item.Body,qaLocked=locked,shakeLock=game.Shake.Active,helperLock=game.SurfaceShuffle.Active,
                depthLock=game.Depth.AnimationInProgress,band=game.Depth.ActiveSurfaceThreshold,lastDepthQueries=game.Depth.LastProbeCount,
                exposureActivations=game.Depth.ExposureActivations,containerRadius=game.Container.Radius,targetRadius=game.Container.TargetRadius,
                containmentRecoveries=game.Container.ContainmentRecoveries,
                helperOwner=game.SurfaceShuffle.OwnerPhoneToss?"phone-toss":game.SurfaceShuffle.OwnerFromShake?"shake-fallback":"none",
                originalAccepted=report.acceptedIds!=null&&report.acceptedIds.Contains(old.instanceId)};
            d.missingViolation=!d.exists;
            if(d.exists)
            {
                d.currentState=State(item);d.positionDelta=Vector3.Distance(old.position,item.Body.position);
                d.angle=Quaternion.Angle(old.rotation,item.Body.rotation);d.rawDot=Quaternion.Dot(old.rotation,item.Body.rotation);
                d.oldSelfAngle=Quaternion.Angle(old.rotation,old.rotation);d.currentSelfAngle=Quaternion.Angle(item.Body.rotation,item.Body.rotation);
                var q=item.Body.rotation;
                d.componentDelta=Mathf.Max(Mathf.Abs(old.rotation.x-q.x),Mathf.Abs(old.rotation.y-q.y),Mathf.Abs(old.rotation.z-q.z),Mathf.Abs(old.rotation.w-q.w));
                d.positionViolation=d.positionDelta>.0005f;d.rotationViolation=d.angle>.05f;
                d.heldViolation=item.DepthHeld!=old.held;d.kinematicViolation=item.Body.isKinematic!=old.kinematic;d.gravityViolation=item.Body.useGravity!=old.gravity;
                d.cacheDeadlineDelta=Time.time-item.NextSurfaceCheck;d.cacheExpired=Time.time>=item.NextSurfaceCheck;
                d.inBand=GoosePileDepth.WithinActiveSurfaceBand(item.SelectionCollider.bounds,d.band);
                int mask=~((1<<2)|(1<<8)|(1<<26)|(1<<27)|(1<<28)|(1<<29)|(1<<30));
                float top=game.Remaining.Max(value=>value.SelectionCollider.bounds.max.y)+.2f;
                d.productionProbe=GoosePileDepth.ProbeSurface(item,top,mask,out int queries);d.extraQueries+=queries;
                var b=item.SelectionCollider.bounds;
                // Include every point from both production rings; a five-point
                // diagonal subset cannot disprove exposure on the outer rim.
                float[] offsets={-.72f,-.3f,0,.3f,.72f};
                for(int row=0;row<5;row++)for(int column=0;column<5;column++)
                {
                    var offset=new Vector3(offsets[column]*b.extents.x,0,offsets[row]*b.extents.z);
                    var sample=new ProbeSample{origin=new Vector3(b.center.x+offset.x,top,b.center.z+offset.z)};
                    var ray=new Ray(sample.origin,Vector3.down);d.extraQueries++;
                    sample.ownHit=item.SelectionCollider.Raycast(ray,out var own,100);sample.ownDistance=sample.ownHit?own.distance:-1;
                    d.extraQueries++;
                    if(Physics.Raycast(ray,out var hit,sample.ownHit?own.distance+.015f:100,mask,QueryTriggerInteraction.Ignore))
                    {
                        var first=hit.collider.GetComponentInParent<GooseItem>();sample.firstCollider=hit.collider.name;
                        sample.firstId=first?first.GetInstanceID():0;sample.firstItem=first?first.Id:"<non-item>";sample.firstDistance=hit.distance;
                        sample.firstIsSelf=sample.ownHit&&hit.collider.attachedRigidbody==item.Body;d.independentProbe|=sample.firstIsSelf;
                    }
                    d.samples.Add(sample);
                }
            }
            d.diagnosticMilliseconds=(float)((System.Diagnostics.Stopwatch.GetTimestamp()-beganProbe)*1000.0/System.Diagnostics.Stopwatch.Frequency);
            report.lowerDiagnosticQueries+=d.extraQueries;report.lowerDiagnosticMilliseconds+=d.diagnosticMilliseconds;
            return d;
        }
        void ArmFixedObserver(Dictionary<GooseItem,BodyState> lower,HashSet<GooseItem> promoted,float motionStart)
        {
            fixedLower=lower;fixedPromoted=promoted;fixedRound=game.Level;fixedMotionStart=motionStart;fixedPrevious.Clear();fixedRecorded.Clear();
            foreach(var pair in lower)if(pair.Key)fixedPrevious[pair.Key]=new FixedLowerPrevious{held=pair.Key.DepthHeld,known=pair.Key.SurfaceKnown,
                exposed=pair.Key.SurfaceExposed,nextCheck=pair.Key.NextSurfaceCheck,time=Time.fixedTime};
            fixedObserver=gameObject.AddComponent<GooseStageTwoLowerFixedObserver>();fixedObserver.Step=ObserveFixedPromotions;
        }
        void ObserveFixedPromotions()
        {
            if(fixedLower==null)return;report.fixedObserverSteps++;
            foreach(var pair in fixedLower)
            {
                var item=pair.Key;if(!item||!item.Body||!fixedPrevious.TryGetValue(item,out var previous))continue;
                int id=pair.Value.instanceId;
                if(previous.held&&!item.DepthHeld&&!fixedPromoted.Contains(item)&&!report.acceptedIds.Contains(id))
                {
                    var d=CaptureLowerDiagnostic(item,pair.Value,game.Shake.Active||game.SurfaceShuffle.Active,fixedMotionStart);
                    d.phase="FixedUpdate observer(-99), after Depth(-100), before physics";d.beforeSimulation=true;d.inFixedStep=Time.inFixedTimeStep;
                    d.previousKnown=previous.known;d.previousExposed=previous.exposed;d.previousNextCheck=previous.nextCheck;d.previousFixedTime=previous.time;d.violatingSamples=0;
                    var c=d.currentState;var initial=pair.Value;
                    d.witness=new GooseLowerPromotionWitnessPolicy.Evidence{
                        initialId=initial.instanceId,currentId=item.GetInstanceID(),sameRound=game.Level==fixedRound,exists=d.exists,
                        initialHeld=initial.held,initialKinematic=initial.kinematic,initialGravity=initial.gravity,previousHeld=previous.held,selected=d.originalAccepted,
                        prePhysics=d.beforeSimulation,inFixedStep=d.inFixedStep,shakeLock=d.shakeLock,helperLock=d.helperLock,depthLock=d.depthLock,
                        currentHeld=c.held,currentKinematic=c.kinematic,currentGravity=c.gravity,surfaceActive=c.surface,surfaceKnown=c.surfaceKnown,surfaceExposed=c.surfaceExposed,
                        colliderEnabled=c.colliderEnabled,surfaceAnimating=c.surfaceAnimating,active=item.gameObject.activeInHierarchy,picked=item.Picked,
                        raw=d.productionProbe,independent=d.independentProbe,time=d.time,fixedTime=d.fixedTime,nextCheck=c.nextSurfaceCheck,previousNextCheck=previous.nextCheck,
                        boundsMax=c.colliderBounds.max.y,band=d.band,positionDelta=d.positionDelta,angleDelta=d.angle};
                    d.witnessAccepted=GooseLowerPromotionWitnessPolicy.Accept(d.witness);report.fixedWitnessEvaluations++;
                    if(d.witnessAccepted){fixedPromoted.Add(item);report.fixedWitnessAccepted++;report.legitimatelyPromoted.Add(State(item));}
                    // Validate every release; only persisted diagnostic records are capped.
                    if(fixedRecorded.Add(id)&&report.fixedPromotions.Count<8){report.fixedPromotions.Add(d);Save();}
                    else report.fixedPromotionOmitted++;
                }
                fixedPrevious[item]=new FixedLowerPrevious{held=item.DepthHeld,known=item.SurfaceKnown,exposed=item.SurfaceExposed,
                    nextCheck=item.NextSurfaceCheck,time=Time.fixedTime};
            }
        }
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
            ArmFixedObserver(lower,promoted,motionStart);
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
                    if (!item || Vector3.Distance(item.Body.position, old.position) > .0005f || Quaternion.Angle(item.Body.rotation, old.rotation) > .05f ||
                        item.DepthHeld != old.held || item.Body.isKinematic != old.kinematic || item.Body.useGravity != old.gravity)
                    { report.lowerViolations++; RecordLowerViolation(item,old,locked,motionStart); }
                }
                float seconds = Time.realtimeSinceStartup - motionStart;
                if (seconds >= (frame + 1) * .1f && frame < 33)
                {
                    string file = "clip-" + frame.ToString("000") + ".png";
                    GooseFrameCapture.Save(Path.Combine(output, file)); report.clipFrames.Add(new Frame { file = file, seconds = seconds }); frame++;
                }
            }
            if(fixedObserver){fixedObserver.Step=null;fixedObserver.enabled=false;}
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
    // Pure QA timing contract. This certifies the release moment only, never a
    // sensor/SDK callback or permission. Runtime observers and fixtures share it.
    public static class GooseLowerPromotionWitnessPolicy
    {
        [Serializable] public struct Evidence
        {
            public int initialId,currentId;
            public bool sameRound,exists,initialHeld,initialKinematic,initialGravity,previousHeld,selected;
            public bool prePhysics,inFixedStep,shakeLock,helperLock,depthLock;
            public bool currentHeld,currentKinematic,currentGravity,surfaceActive,surfaceKnown,surfaceExposed,colliderEnabled,surfaceAnimating,active,picked;
            public bool raw,independent;
            public float time,fixedTime,nextCheck,previousNextCheck,boundsMax,band,positionDelta,angleDelta;
        }
        static bool Finite(float value){return !float.IsNaN(value)&&!float.IsInfinity(value);}
        public static bool Accept(Evidence e)
        {
            if(!e.sameRound||!e.exists||e.initialId==0||e.initialId!=e.currentId||!e.initialHeld||!e.initialKinematic||e.initialGravity||
                !e.previousHeld||e.selected||!e.prePhysics||!e.inFixedStep||e.shakeLock||e.helperLock||e.depthLock)return false;
            if(e.currentHeld||e.currentKinematic||!e.currentGravity||!e.surfaceActive||!e.surfaceKnown||!e.surfaceExposed||
                !e.colliderEnabled||e.surfaceAnimating||!e.active||e.picked||!e.raw||!e.independent)return false;
            if(!Finite(e.time)||!Finite(e.fixedTime)||!Finite(e.nextCheck)||!Finite(e.previousNextCheck)||!Finite(e.boundsMax)||!Finite(e.band)||
                !Finite(e.positionDelta)||!Finite(e.angleDelta))return false;
            return System.Math.Abs(e.time-e.fixedTime)<=.0001f&&e.nextCheck>e.time&&e.nextCheck>e.previousNextCheck&&
                System.Math.Abs((e.nextCheck-e.time)-.25f)<=.0001f&&e.boundsMax>=e.band&&e.positionDelta>=0&&e.positionDelta<=.0005f&&
                e.angleDelta>=0&&e.angleDelta<=.05f;
        }
    }
    [DefaultExecutionOrder(-99)]
    public sealed class GooseStageTwoLowerFixedObserver:MonoBehaviour
    {
        public Action Step;
        void FixedUpdate(){Step?.Invoke();}
    }

}
#endif
