#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;

namespace CatchGoose
{
    // Observes production input and natural physics. It never pins bodies,
    // selects replacement shake targets, or repairs production state.
    public sealed class GooseRevealStabilityAcceptance : MonoBehaviour
    {
        [Serializable] sealed class ItemState
        {
            public int instanceId, classifications, committedEpoch, enabledRenderers, renderers;
            public string id;
            public Vector3 position;
            public Quaternion rotation;
            public bool visible, held, kinematic, gravity, surface;
        }
        [Serializable] sealed class Event
        {
            public string phase, reason;
            public float seconds;
            public int startedEpoch, committedEpoch;
            public ItemState item;
        }
        [Serializable] sealed class Reveal
        {
            public string action;
            public float afterOperation;
            public bool independentlyExposed, inActivationBand;
            public ItemState item;
        }
        [Serializable] sealed class Phase
        {
            public string name;
            public bool completed, inconclusive;
            public int initialEpoch, completedEpoch, maxProbes, stationaryFlips, windowRestarts, minClassifications;
            public int stock, visible, held, dynamicBodies, renderers, drawSlots, triangles, refreshSamples;
            public float lastRefreshMs, maxRefreshMs, meanRefreshMs;
            public float operationSeconds, convergenceSeconds, stableSeconds, maxStationaryConvergenceSeconds, derivedConvergenceBound;
            public float commitAfterOperationSeconds, rendererSettledAfterOperationSeconds;
            public float maximumEpochSeconds, lastEpochSeconds;
            public GooseVisibilityReferenceCapture.Result colorGeometryReference;
        }
        [Serializable] sealed class Pick
        {
            public ItemState target, expectedHiddenHint;
            public Vector2 screen;
            public bool began, accepted, pickedStateObserved, exitedInventory;
            public int before, after;
        }
        [Serializable] sealed class ReleaseWitness
        {
            public int frame;public string item;public bool accepted;
            public GooseLowerPromotionWitnessPolicy.Evidence evidence;
        }
        [Serializable] sealed class Trace
        {
            public int instanceId; public string id;
            public Vector3 start, end; public Quaternion rotation;
            public float maxRise, maxTurn, peakXZ, peakPixels, netXZ;
            public bool airborneFlip, selected;
        }
        [Serializable] sealed class Report
        {
            public string build=GooseRuntimePerformance.BuildId,theme;
            public string scope="Native real difficulty-1 stock300; production pointer down/up and synthetic 1.6g gesture, natural physics, no freezing or instant picks. Independent QA probes and offscreen captures add work; no phone/FPS claim.";
            public string queryBound="Current visual contract: 25 outer-envelope samples, <=64 queries/item, >=64 reserved queries/refresh, at least one complete item/refresh. A dirty arriving in an old epoch needs at most its remainder plus one fresh epoch, plus prior .35s sleep and hide hysteresis.";
            public bool completed,passed,accepted,observedToss;
            public int initialStock,finalStock,sustainedReveals,omittedEvents,lowerViolations,floorViolations,boundaryViolations,targetReplacementViolations;
            public int[] originalSurfaceIds,acceptedIds,fixedIds;
            public GooseShakeController.MotionResult motion;
            public List<string> checks=new List<string>(),errors=new List<string>();
            public List<Phase> phases=new List<Phase>();
            public List<Pick> picks=new List<Pick>();
            public List<Reveal> reveals=new List<Reveal>();
            public List<Event> events=new List<Event>();
            public List<Trace> traces=new List<Trace>();
            public List<ItemState> promotedAfterMotion=new List<ItemState>();
            public int firstReleaseEvaluations,firstReleaseAccepted,firstReleaseOmitted,firstReleaseQueries;
            public List<ReleaseWitness> firstReleaseWitnesses=new List<ReleaseWitness>();
        }
        sealed class Watch
        {
            public GooseItem item;
            public Vector3 anchor;
            public Quaternion rotation;
            public bool visible,held,kinematic,gravity;
            public int classifications,materialRevision;
        }
        readonly Report report=new Report();
        readonly List<GooseItem> surface=new List<GooseItem>(64);
        readonly Dictionary<int,Watch> watch=new Dictionary<int,Watch>(320);
        readonly Dictionary<int,bool> hiddenBeforePick=new Dictionary<int,bool>(320);
        readonly HashSet<int> revealed=new HashSet<int>(),promoted=new HashSet<int>();
        readonly RaycastHit[] hits=new RaycastHit[128];
        readonly Dictionary<int,ItemState> lower=new Dictionary<int,ItemState>(320);
        readonly Dictionary<int,Trace> traces=new Dictionary<int,Trace>(64);
        readonly HashSet<int> originalIds=new HashSet<int>();
        GooseGame game;string output;bool done,motionPhase;
        float began,lastGeometry,operationBegan,lastCommitObserved;
        int previousCommit;
        Matrix4x4 cameraView,cameraProjection;
        Phase phase;
        struct ReleasePrevious{public bool held;public float nextCheck;}
        readonly Dictionary<int,ReleasePrevious> releasePrevious=new Dictionary<int,ReleasePrevious>();
        readonly HashSet<int> releaseRecorded=new HashSet<int>();
        GooseStageTwoLowerFixedObserver releaseObserver;LevelDefinition releaseRound;
        // Worst-case complete visual work, independent of early-out savings.
        const int MaximumVisualQueries=GoosePileDepth.MaxVisualProbeQueries,ReservedVisualQueries=64;
        const float StableWindow=12,PhaseLimit=120;
        const int MaxEvents=6000;

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        {if(Array.IndexOf(Environment.GetCommandLineArgs(),"-gooseRevealQa")>=0)new GameObject("RevealStabilityAcceptance").AddComponent<GooseRevealStabilityAcceptance>();}
        static string Arg(string[] args,string key,string fallback)
        {int n=Array.IndexOf(args,key);return n>=0&&n+1<args.Length?args[n+1]:fallback;}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string message,string stack,LogType kind)
        {if(kind==LogType.Error||kind==LogType.Exception||kind==LogType.Assert)report.errors.Add(message+"\n"+stack);}
        void Check(bool success,string label){(success?report.checks:report.errors).Add(label);}
        ItemState State(GooseItem item)
        {
            var value=new ItemState{instanceId=item.GetInstanceID(),id=item.Id,position=item.Body.position,rotation=item.Body.rotation,
                visible=item.DepthVisible,held=item.DepthHeld,kinematic=item.Body.isKinematic,gravity=item.Body.useGravity,surface=item.SurfaceActive,
                classifications=item.VisibilityClassifications,committedEpoch=item.CommittedVisibilityEpoch};
            foreach(var renderer in item.Renderers)if(renderer){value.renderers++;if(renderer.enabled&&!renderer.forceRenderingOff)value.enabledRenderers++;}
            return value;
        }
        static bool Valid(GooseItem item)=>item&&!item.Picked&&item.Body&&item.SelectionCollider&&item.gameObject.activeInHierarchy;
        void Record(string reason,GooseItem item)
        {
            if(report.events.Count>=MaxEvents){report.omittedEvents++;return;}
            report.events.Add(new Event{phase=phase==null?"startup":phase.name,reason=reason,seconds=Time.realtimeSinceStartup-began,
                startedEpoch=game.Depth.VisibilityEpoch,committedEpoch=game.Depth.CompletedVisibilityEpoch,item=State(item)});
        }
        void StartWatch()
        {
            watch.Clear();
            foreach(var item in game.Items)if(Valid(item))watch.Add(item.GetInstanceID(),new Watch{item=item,anchor=item.Body.position,rotation=item.Body.rotation,
                visible=item.DepthVisible,held=item.DepthHeld,kinematic=item.Body.isKinematic,gravity=item.Body.useGravity,
                classifications=item.VisibilityClassifications,materialRevision=item.VisualMaterialRevision});
            cameraView=game.MainCamera.worldToCameraMatrix;cameraProjection=game.MainCamera.projectionMatrix;
            lastGeometry=Time.realtimeSinceStartup;previousCommit=game.Depth.CompletedVisibilityEpoch;lastCommitObserved=lastGeometry;
        }
        static bool MatrixChanged(Matrix4x4 a,Matrix4x4 b)
        {for(int i=0;i<16;i++)if(Mathf.Abs(a[i]-b[i])>.00001f)return true;return false;}
        bool Observe()
        {
            float now=Time.realtimeSinceStartup;phase.maxProbes=Mathf.Max(phase.maxProbes,game.Depth.LastProbeCount);
            if(motionPhase)
            {
                report.observedToss|=game.SurfaceShuffle.OwnerPhoneToss;
                foreach(int selected in game.Shake.TargetIds)if(!originalIds.Contains(selected))report.targetReplacementViolations++;
            }
            bool changed=MatrixChanged(cameraView,game.MainCamera.worldToCameraMatrix)||MatrixChanged(cameraProjection,game.MainCamera.projectionMatrix);
            cameraView=game.MainCamera.worldToCameraMatrix;cameraProjection=game.MainCamera.projectionMatrix;
            foreach(var pair in watch)
            {
                var old=pair.Value;var item=old.item;if(!Valid(item))continue;
                if(Vector3.Distance(old.anchor,item.Body.position)>.0001f||Quaternion.Angle(old.rotation,item.Body.rotation)>.01f||
                    old.materialRevision!=item.VisualMaterialRevision)changed=true;
            }
            if(changed)
            {
                lastGeometry=now;
                foreach(var pair in watch)if(Valid(pair.Value.item))
                {var old=pair.Value;old.anchor=old.item.Body.position;old.rotation=old.item.Body.rotation;old.materialRevision=old.item.VisualMaterialRevision;}
            }
            if(previousCommit!=game.Depth.CompletedVisibilityEpoch)
            {previousCommit=game.Depth.CompletedVisibilityEpoch;lastCommitObserved=now;phase.completedEpoch=previousCommit;phase.lastEpochSeconds=game.Depth.LastVisibilityEpochSeconds;}
            foreach(var pair in watch)
            {
                var old=pair.Value;var item=old.item;if(!Valid(item))continue;
                bool flip=old.visible!=item.DepthVisible;
                if(flip||old.held!=item.DepthHeld||old.kinematic!=item.Body.isKinematic||old.gravity!=item.Body.useGravity)
                    Record(flip?"visibility":"physical-membership",item);
                if(flip&&!changed&&phase.stableSeconds>0)phase.stationaryFlips++;
                if(hiddenBeforePick.TryGetValue(pair.Key,out bool wasHidden)&&wasHidden&&item.DepthVisible&&revealed.Add(pair.Key))
                    report.reveals.Add(new Reveal{action=phase.name,afterOperation=now-operationBegan,item=State(item),
                        independentlyExposed=IndependentlyExposed(item),inActivationBand=GoosePileDepth.WithinActiveSurfaceBand(item.SelectionCollider.bounds,game.Depth.ActiveSurfaceThreshold)});
                old.visible=item.DepthVisible;old.held=item.DepthHeld;old.kinematic=item.Body.isKinematic;old.gravity=item.Body.useGravity;
                if(item.SelectionCollider.bounds.min.y<GooseCircularContainer.FloorY-.025f&&GooseColliderGeometry.MinY(item.SelectionCollider)<GooseCircularContainer.FloorY-.025f)report.floorViolations++;
                if(new Vector2(item.Body.position.x,item.Body.position.z-GooseCircularContainer.CenterZ).magnitude>game.Container.Radius+.05f)report.boundaryViolations++;
                if(motionPhase)ObserveMotion(item);
            }
            return changed;
        }
        bool IndependentlyExposed(GooseItem item){return IndependentlyExposed(item,out _);}
        bool IndependentlyExposed(GooseItem item,out int queryCount)
        {
            queryCount=0;
            float top=game.Items.Where(Valid).Max(value=>value.SelectionCollider.bounds.max.y)+1;var b=item.SelectionCollider.bounds;
            // A 5-point oracle misses legitimate exposure on the production
            // outer ring. This independent 25-point grid includes both rings
            // and their mixed offsets; it still requires an actual first hit.
            float[] offsets={-.72f,-.3f,0,.3f,.72f};
            for(int row=0;row<5;row++)for(int column=0;column<5;column++)
            {
                var offset=new Vector3(offsets[column]*b.extents.x,0,offsets[row]*b.extents.z);
                var ray=new Ray(new Vector3(b.center.x+offset.x,top,b.center.z+offset.z),Vector3.down);
                queryCount++;if(!item.SelectionCollider.Raycast(ray,out var own,100))continue;
                queryCount++;if(Physics.Raycast(ray,out var first,own.distance+.001f,~((1<<2)|(1<<8)|(1<<26)|(1<<27)|(1<<28)|(1<<29)|(1<<30)),QueryTriggerInteraction.Ignore)&&first.collider.attachedRigidbody==item.Body)return true;
            }
            return false;
        }
        bool Ready(int after,bool needNew)
        {
            var depth=game.Depth;if(depth.CompletedVisibilityEpoch<=0||depth.VisibilityDirty||depth.VisibilityEpochInProgress||(needNew&&depth.CompletedVisibilityEpoch<=after))return false;
            phase.minClassifications=int.MaxValue;
            foreach(var old in watch.Values)if(Valid(old.item))
            {
                if(old.item.CommittedVisibilityEpoch!=depth.CompletedVisibilityEpoch)return false;
                int delta=old.item.VisibilityClassifications-old.classifications;
                phase.minClassifications=Mathf.Min(phase.minClassifications,delta);
                if(needNew&&delta<=0)return false;
            }
            return true;
        }
        Phase NewPhase(string name)
        {
            var row=new Phase{name=name,initialEpoch=game.Depth.CompletedVisibilityEpoch};
            int stock=game.Items.Count(Valid),perRefresh=Mathf.Max(1,ReservedVisualQueries/MaximumVisualQueries);
            row.maximumEpochSeconds=(Mathf.Ceil((float)stock/perRefresh)+1)*game.AlgorithmSettings.refreshInterval;
            row.derivedConvergenceBound=row.maximumEpochSeconds*2+.35f+game.AlgorithmSettings.settledDuration+Time.fixedDeltaTime;
            report.phases.Add(row);phase=row;StartWatch();return row;
        }
        IEnumerator Steady(Phase row,bool needNew,float deadline)
        {
            phase=row;float window=-1;bool readyObserved=false;
            while(Time.realtimeSinceStartup<deadline)
            {
                game.QaSetTime(3600);yield return new WaitForEndOfFrame();bool changed=Observe();float now=Time.realtimeSinceStartup;
                // Sample gameplay refresh cost before any offscreen QA capture. This is not phone FPS.
                row.lastRefreshMs=game.Depth.LastRefreshMs;row.maxRefreshMs=Mathf.Max(row.maxRefreshMs,row.lastRefreshMs);
                row.refreshSamples++;row.meanRefreshMs+=(row.lastRefreshMs-row.meanRefreshMs)/row.refreshSamples;
                bool ready=Ready(row.initialEpoch,needNew)&&now-lastGeometry>=1.5f&&now-lastCommitObserved>=1.5f&&!game.Shake.Active&&!game.SurfaceShuffle.Active;
                if(changed||!ready){if(window>=0)row.windowRestarts++;window=-1;row.stableSeconds=0;}
                else
                {
                    if(window<0)
                    {
                        window=now;row.convergenceSeconds=now-operationBegan;readyObserved=true;
                        row.commitAfterOperationSeconds=Mathf.Max(0,lastCommitObserved-operationBegan);
                        row.rendererSettledAfterOperationSeconds=now-operationBegan;
                        row.maxStationaryConvergenceSeconds=Mathf.Max(row.maxStationaryConvergenceSeconds,Mathf.Max(0,lastCommitObserved-lastGeometry)+game.AlgorithmSettings.settledDuration);
                    }
                    row.stableSeconds=now-window;
                    if(row.stableSeconds>=StableWindow){row.completed=true;break;}
                }
            }
            row.operationSeconds=Time.realtimeSinceStartup-operationBegan;
            row.inconclusive=!row.completed;
            Check(row.completed,"natural complete-epoch and twelve-second stable window "+row.name+(row.inconclusive?" INCONCLUSIVE":""));
            Check(row.maxProbes<=GoosePileDepth.MaxProbeCount,"depth query budget "+row.name);
            Check(row.stationaryFlips==0,"zero stationary visibility flips "+row.name);
            Check(!readyObserved||row.maxStationaryConvergenceSeconds<=row.derivedConvergenceBound,"last geometry to commit/hysteresis within query-derived bound "+row.name);
            Save();
            if(!row.completed)yield break;
            foreach(var item in game.Items)if(Valid(item))
            {
                row.stock++;if(item.DepthVisible){row.visible++;row.renderers+=item.RenderCount;row.drawSlots+=item.DrawSlots;row.triangles+=item.Triangles;}
                if(item.DepthHeld)row.held++;if(!item.Body.isKinematic)row.dynamicBodies++;
                Check(item.Renderers.All(renderer=>!renderer||renderer.enabled==item.DepthVisible),"renderer publication "+row.name+"/"+item.GetInstanceID());
            }
            row.colorGeometryReference=GooseVisibilityReferenceCapture.Capture(game,output,row.name,false,true);
            Check(row.colorGeometryReference.passed&&row.colorGeometryReference.noisePassed&&row.colorGeometryReference.rendererStateRestored&&
                row.colorGeometryReference.casterControlApplicable&&row.colorGeometryReference.casterStateRestored,"original color geometry reference "+row.name);
            Check(row.visible<row.stock,"real hidden inventory retained "+row.name);
            if(Array.IndexOf(Environment.GetCommandLineArgs(),"-gooseVisibilityContributors")>=0)
            {
                var contributorOutput=Path.Combine(output,row.name+"-contributors");
                Directory.CreateDirectory(contributorOutput);
                GooseVisibilityReferenceCapture.DiagnoseContributors(game,contributorOutput);
            }
            GooseFrameCapture.Save(Path.Combine(output,row.name+".png"));Save();
        }
        bool PointerTarget(out GooseItem target,out Vector2 point,out GooseItem hiddenHint)
        {
            game.Depth.CopySurface(surface);target=null;hiddenHint=null;point=Vector2.zero;
            int bestRank=int.MaxValue;
            foreach(var candidate in surface)
            for(int probe=0;probe<25;probe++)
            {
                var b=candidate.SelectionCollider.bounds;
                var world=b.center+Vector3.Scale(b.extents,new Vector3((probe%5-2)*.35f,0,(probe/5-2)*.35f));
                var screen=(Vector2)game.MainCamera.WorldToScreenPoint(world);
                if(game.FindSelectableAtScreenPosition(screen)!=candidate)continue;
                if(!target){target=candidate;point=screen;}
                var ray=game.MainCamera.ScreenPointToRay(screen);int count=Physics.RaycastNonAlloc(ray,hits,100,~((1<<2)|(1<<8)|(1<<26)|(1<<27)|(1<<28)|(1<<29)|(1<<30)),QueryTriggerInteraction.Ignore);
                GooseItem next=null;float nearest=float.PositiveInfinity;
                if(count==hits.Length)continue;
                foreach(var hit in hits.Take(count))
                {
                    var item=hit.collider.GetComponentInParent<GooseItem>();
                    if(Valid(item)&&item!=candidate&&!item.DepthVisible&&hit.distance<nearest){nearest=hit.distance;next=item;}
                }
                if(!next)continue;
                int rank=hits.Take(count).Where(hit=>hit.distance<nearest).Select(hit=>hit.collider.GetComponentInParent<GooseItem>())
                    .Where(item=>Valid(item)&&item!=candidate).Distinct().Count();
                if(rank<bestRank){bestRank=rank;target=candidate;point=screen;hiddenHint=next;if(rank==0)return true;}
            }
            return target;
        }
        void ObserveMotion(GooseItem item)
        {
            int id=item.GetInstanceID();bool active=game.Shake.Active||game.SurfaceShuffle.Active;
            if(active)
            {
                if(lower.TryGetValue(id,out var old)&&(Vector3.Distance(old.position,item.Body.position)>.0005f||Quaternion.Angle(old.rotation,item.Body.rotation)>.05f||
                    item.DepthHeld!=old.held||item.Body.isKinematic!=old.kinematic||item.Body.useGravity!=old.gravity))report.lowerViolations++;
            }
            else if(lower.TryGetValue(id,out var old)&&!promoted.Contains(id))
            {
                if(Vector3.Distance(old.position,item.Body.position)>.0005f||Quaternion.Angle(old.rotation,item.Body.rotation)>.05f||
                    item.DepthHeld!=old.held||item.Body.isKinematic!=old.kinematic||item.Body.useGravity!=old.gravity)report.lowerViolations++;
            }
            if(!traces.TryGetValue(id,out var trace))return;
            var delta=item.Body.position-trace.start;trace.end=item.Body.position;
            trace.maxRise=Mathf.Max(trace.maxRise,delta.y);trace.maxTurn=Mathf.Max(trace.maxTurn,Quaternion.Angle(trace.rotation,item.Body.rotation));
            trace.peakXZ=Mathf.Max(trace.peakXZ,new Vector2(delta.x,delta.z).magnitude);
            trace.peakPixels=Mathf.Max(trace.peakPixels,Vector2.Distance(game.MainCamera.WorldToScreenPoint(trace.start),game.MainCamera.WorldToScreenPoint(item.Body.position)));
            trace.airborneFlip|=delta.y>=game.ItemScale*.6f&&Quaternion.Angle(trace.rotation,item.Body.rotation)>=75;
        }
        void ArmReleaseObserver()
        {
            releaseRound=game.Level;releasePrevious.Clear();releaseRecorded.Clear();
            foreach(var pair in lower)if(watch.TryGetValue(pair.Key,out var entry)&&Valid(entry.item))
                releasePrevious[pair.Key]=new ReleasePrevious{held=entry.item.DepthHeld,nextCheck=entry.item.NextSurfaceCheck};
            releaseObserver=gameObject.AddComponent<GooseStageTwoLowerFixedObserver>();releaseObserver.Step=ObserveReleaseWitness;
        }
        void ObserveReleaseWitness()
        {
            foreach(var pair in lower)
            {
                int id=pair.Key;if(!watch.TryGetValue(id,out var entry)||!Valid(entry.item)||!releasePrevious.TryGetValue(id,out var previous))continue;
                var item=entry.item;
                if(previous.held&&!item.DepthHeld&&!promoted.Contains(id)&&!originalIds.Contains(id))
                {
                    float top=game.Items.Where(Valid).Max(value=>value.SelectionCollider.bounds.max.y)+.2f;
                    int mask=~((1<<2)|(1<<8)|(1<<26)|(1<<27)|(1<<28)|(1<<29)|(1<<30));
                    bool raw=GoosePileDepth.ProbeSurface(item,top,mask,out int queries),independent=IndependentlyExposed(item,out int independentQueries);
                    report.firstReleaseQueries+=queries+independentQueries;var initial=pair.Value;
                    var evidence=new GooseLowerPromotionWitnessPolicy.Evidence{
                        initialId=initial.instanceId,currentId=item.GetInstanceID(),sameRound=game.Level==releaseRound,exists=true,
                        initialHeld=initial.held,initialKinematic=initial.kinematic,initialGravity=initial.gravity,previousHeld=previous.held,selected=originalIds.Contains(id),
                        prePhysics=true,inFixedStep=Time.inFixedTimeStep,shakeLock=game.Shake.Active,helperLock=game.SurfaceShuffle.Active,depthLock=game.Depth.AnimationInProgress,
                        currentHeld=item.DepthHeld,currentKinematic=item.Body.isKinematic,currentGravity=item.Body.useGravity,surfaceActive=item.SurfaceActive,
                        surfaceKnown=item.SurfaceKnown,surfaceExposed=item.SurfaceExposed,colliderEnabled=item.SelectionCollider.enabled,surfaceAnimating=item.SurfaceAnimating,
                        active=item.gameObject.activeInHierarchy,picked=item.Picked,raw=raw,independent=independent,time=Time.time,fixedTime=Time.fixedTime,
                        nextCheck=item.NextSurfaceCheck,previousNextCheck=previous.nextCheck,boundsMax=item.SelectionCollider.bounds.max.y,band=game.Depth.ActiveSurfaceThreshold,
                        positionDelta=Vector3.Distance(initial.position,item.Body.position),angleDelta=Quaternion.Angle(initial.rotation,item.Body.rotation)};
                    bool accepted=GooseLowerPromotionWitnessPolicy.Accept(evidence);report.firstReleaseEvaluations++;
                    if(accepted){promoted.Add(id);report.firstReleaseAccepted++;report.promotedAfterMotion.Add(State(item));}
                    if(releaseRecorded.Add(id)&&report.firstReleaseWitnesses.Count<8)
                        report.firstReleaseWitnesses.Add(new ReleaseWitness{frame=Time.frameCount,item=item.Id,accepted=accepted,evidence=evidence});
                    else report.firstReleaseOmitted++;
                }
                releasePrevious[id]=new ReleasePrevious{held=item.DepthHeld,nextCheck=item.NextSurfaceCheck};
            }
        }
        IEnumerator Start()
        {
            yield return null;GooseSave.IsQa=true;var args=Environment.GetCommandLineArgs();
            output=Arg(args,"-gooseRevealOutput",Path.Combine(Application.persistentDataPath,"reveal-stability-qa"));Directory.CreateDirectory(output);
            if(!int.TryParse(Arg(args,"-gooseRevealTheme","0"),out int theme)){report.errors.Add("invalid theme");Finish();yield break;}
            game=GooseGame.Instance;if(!game||theme<0||theme>=game.Themes.Length){report.errors.Add("missing game/theme");Finish();yield break;}
            StartCoroutine(Watchdog());Screen.SetResolution(390,844,false);game.GoHome();game.SelectTheme(theme);game.SelectDifficulty(1);game.BeginRound(false);
            float spawn=Time.realtimeSinceStartup+90;while(!game.SpawnComplete&&Time.realtimeSinceStartup<spawn)yield return null;
            Check(game.SpawnComplete&&!game.InstantPicksForQa,"production round opens with normal pointer/tray timings");if(!game.SpawnComplete){Finish();yield break;}
            report.theme=game.Theme.id;report.initialStock=game.Items.Count(Valid);Check(game.Difficulty==1&&report.initialStock==300,"actual difficulty-1 stock300");
            began=operationBegan=Time.realtimeSinceStartup;var initial=NewPhase("initial");yield return Steady(initial,false,operationBegan+PhaseLimit);
            float pickDeadline=Time.realtimeSinceStartup+PhaseLimit;
            for(int attempt=0;attempt<3&&Time.realtimeSinceStartup<pickDeadline;attempt++)
            {
                if(!PointerTarget(out var target,out var point,out var hint)){report.errors.Add("no production pointer surface target");break;}
                hiddenBeforePick.Clear();foreach(var item in game.Items)if(Valid(item))hiddenBeforePick[item.GetInstanceID()]=!item.DepthVisible;
                operationBegan=Time.realtimeSinceStartup;var picked=NewPhase("after-pick-"+(attempt+1));
                var pick=new Pick{target=State(target),screen=point,expectedHiddenHint=hint?State(hint):null,before=game.Items.Count(Valid)};report.picks.Add(pick);
                pick.began=game.BeginPointer(point,9321+attempt);pick.accepted=pick.began&&game.EndPointer(point,9321+attempt);
                pick.pickedStateObserved=target.Picked;pick.exitedInventory=!game.Remaining.Contains(target);pick.after=game.Items.Count(Valid);
                Check(pick.accepted&&pick.pickedStateObserved&&pick.exitedInventory&&pick.after==pick.before-1,"real pointer removes original identity "+target.GetInstanceID());
                yield return Steady(picked,true,pickDeadline);
                // An obsolete partial plan can conservatively reveal a buried
                // item and retire that reveal at commit. Continue until a real
                // settled reveal, instead of stopping on the first transient.
                if(game.Items.Any(item=>Valid(item)&&revealed.Contains(item.GetInstanceID())&&item.DepthVisible))break;
            }
            Check(report.reveals.Count>0,"pointer actions actually reveal previously hidden inventory (not only start a dirty epoch)");
            report.sustainedReveals=game.Items.Count(item=>Valid(item)&&revealed.Contains(item.GetInstanceID())&&item.DepthVisible);
            Check(report.sustainedReveals>0,"newly revealed inventory remains visible after the natural stable window");
            hiddenBeforePick.Clear();game.Depth.CopySurface(surface);
            report.originalSurfaceIds=surface.Select(item=>item.GetInstanceID()).ToArray();foreach(int id in report.originalSurfaceIds)originalIds.Add(id);
            foreach(var item in game.Items)if(Valid(item))
            {
                int id=item.GetInstanceID();if(item.DepthHeld&&!originalIds.Contains(id))lower[id]=State(item);
                if(originalIds.Contains(id)){var trace=new Trace{instanceId=id,id=item.Id,start=item.Body.position,end=item.Body.position,rotation=item.Body.rotation};traces.Add(id,trace);report.traces.Add(trace);}
            }
            operationBegan=Time.realtimeSinceStartup;var tossed=NewPhase("after-toss");motionPhase=true;ArmReleaseObserver();
            int before=game.Shake.Accepted;game.Shake.ResetSensor();float timestamp=Time.unscaledTime;
            for(int n=0;n<6;n++)game.Shake.Sample(Vector3.forward,timestamp+n*.06f);
            game.Shake.Sample(new Vector3(1.6f,0,1),timestamp+.42f);game.Shake.Sample(new Vector3(-1.6f,0,1),timestamp+.48f);game.Shake.Sample(Vector3.forward,timestamp+.54f);
            report.accepted=game.Shake.Accepted==before+1;report.acceptedIds=report.originalSurfaceIds.ToArray();
            Check(report.accepted&&report.originalSurfaceIds.Length>0,"first deliberate 1.6g gesture accepted with original surface");
            yield return new WaitForFixedUpdate();report.fixedIds=game.Shake.TargetIds.ToArray();
            foreach(var trace in report.traces)trace.selected=report.fixedIds.Contains(trace.instanceId);
            Check(report.fixedIds.Length>0&&report.fixedIds.All(originalIds.Contains)&&
                (float)report.fixedIds.Length/Mathf.Max(1,report.originalSurfaceIds.Length)>=.8f,"original surface target identities and eighty-percent coverage retained");
            yield return Steady(tossed,true,operationBegan+PhaseLimit);if(releaseObserver){releaseObserver.Step=null;releaseObserver.enabled=false;}motionPhase=false;report.motion=game.Shake.LastMotion;
            foreach(var trace in report.traces)trace.netXZ=new Vector2(trace.end.x-trace.start.x,trace.end.z-trace.start.z).magnitude;
            var selectedTraces=report.traces.Where(trace=>trace.selected).ToArray();int needed=Mathf.Max(1,Mathf.CeilToInt(selectedTraces.Length*.6f));
            Check(report.observedToss&&report.motion!=null&&report.motion.mode=="controlled-pan-toss"&&report.motion.tossCompleted&&!report.motion.interrupted&&string.IsNullOrEmpty(report.motion.tossFailure),"production controlled pan toss actually completes");
            Check(selectedTraces.Count(trace=>trace.airborneFlip)>=needed,"existing sixty-percent joint airborne flip");
            Check(selectedTraces.Count(trace=>trace.peakXZ>=game.ItemScale*.18f&&trace.peakPixels>=15)>=needed,"existing visible horizontal arc");
            Check(selectedTraces.Count(trace=>trace.netXZ>=game.ItemScale*.12f)>=Mathf.CeilToInt(selectedTraces.Length*.5f),"existing settled net-XZ rearrangement");
            Check(report.lowerViolations==0&&report.targetReplacementViolations==0,"animation leaves lower fixed and never supplements target identities");
            Check(report.floorViolations==0&&report.boundaryViolations==0,"floor and boundary remain safe after LateUpdate");
            report.finalStock=game.Items.Count(Valid);Check(report.finalStock==report.initialStock-report.picks.Count,"only real pointer picks remove stock");
            report.completed=true;Finish();
        }
        void Save(){report.passed=report.completed&&report.errors.Count==0;if(!string.IsNullOrEmpty(output))File.WriteAllText(Path.Combine(output,"reveal-stability.json"),JsonUtility.ToJson(report,true));}
        void Finish(){if(done)return;done=true;Save();Application.Quit(report.passed?0:1);}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(300);if(!done){report.errors.Add("reveal QA watchdog/inconclusive");Finish();}}
    }
}
#endif
