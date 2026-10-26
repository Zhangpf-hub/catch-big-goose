using System;
using System.Collections.Generic;
using UnityEngine;

namespace CatchGoose
{
    // Physical surface membership, visual coverage and collision support are separate.
    [DefaultExecutionOrder(-100)]
    public sealed class GoosePileDepth : MonoBehaviour
    {
        public const int MaxProbeCount=256;
        public const int MaxSurfaceProbeQueries=34;
        public const int MaxVisualProbeQueries=64;
        const int ItemMask=~((1<<2)|(1<<8)|(1<<26)|(1<<27)|(1<<28)|(1<<29)|(1<<30));
        GooseGame game; PileAlgorithmSettings settings;
        float nextRefresh,settleUntil,frontier,castTop;
        bool initialized; int probeCursor,visualCursor,urgentCursor;
        readonly List<GooseItem> scratch=new List<GooseItem>(320),urgent=new List<GooseItem>(320);
        readonly RaycastHit[] visualHits=new RaycastHit[48];
        sealed class VisualEntry
        {
            public GooseItem item;
            public Vector3 position,scale;
            public Quaternion rotation;
            public Bounds bounds;
            public float depth;
            public bool forced,enabled,confirmed,visible,opaque;
            public int rank,seen,materialRevision;
        }
        readonly List<VisualEntry> visualPlan=new List<VisualEntry>(320);
        readonly Stack<VisualEntry> visualPool=new Stack<VisualEntry>(320);
        readonly Dictionary<GooseItem,VisualEntry> visualByItem=new Dictionary<GooseItem,VisualEntry>(320);
        readonly Dictionary<GooseItem,VisualEntry> visualObserved=new Dictionary<GooseItem,VisualEntry>(320);
        readonly List<GooseItem> staleVisualItems=new List<GooseItem>(32);
        readonly Dictionary<Material,GooseItem.VisualMaterialState> visualMaterials=new Dictionary<Material,GooseItem.VisualMaterialState>(256);
        Predicate<GooseItem> visualCoverFilter;
        VisualEntry visualTarget;
        bool visualDirty=true,visualInProgress,visualPlanInvalid,visualCameraKnown;
        int visualScan;
        float visualEpochBegan;
        Matrix4x4 observedView,observedProjection,epochView,epochProjection;
        public int HeldCount {get;private set;}
        public int HiddenCount {get;private set;}
        public int DynamicCount {get;private set;}
        public int SurfaceCount {get;private set;}
        public int ExposureActivations {get;private set;}
        public int LastProbeCount {get;private set;}
        public float LastRefreshMs {get;private set;}
        public bool AnimationInProgress;
        public int VisibilityEpoch {get;private set;}
        public int CompletedVisibilityEpoch {get;private set;}
        public int VisibilityEpochCompletions {get;private set;}
        public int VisibilityClassifications {get;private set;}
        public int DiscardedVisibilityEpochs {get;private set;}
        public int PendingVisibilityHides {get;private set;}
        public float LastVisibilityEpochSeconds {get;private set;}
        public bool VisibilityEpochInProgress=>visualInProgress;
        public bool VisibilityDirty=>visualDirty||visualPlanInvalid;
        public int PendingVisibilityItems=>visualInProgress?visualPlan.Count-visualCursor:0;
        public bool OverDynamicBudget=>settings!=null&&DynamicCount>settings.maxDynamicBodies;
        public float VisibleThreshold {get;private set;}
        public float RigidThreshold {get;private set;}
        // A slit between higher pieces does not activate the entire depth of the
        // pile. This is the current height frontier, combined with real exposure.
        public float ActiveSurfaceThreshold=>VisibleThreshold;
        public static bool WithinActiveSurfaceBand(Bounds bounds,float threshold)=>bounds.max.y>=threshold;
        public void Initialize(GooseGame owner,PileAlgorithmSettings profile){game=owner;settings=profile;visualCoverFilter=PlannedVisualCover;}
        public void ResetRound()
        {
            initialized=false;nextRefresh=0;settleUntil=float.PositiveInfinity;
            HeldCount=HiddenCount=DynamicCount=SurfaceCount=ExposureActivations=LastProbeCount=0;
            probeCursor=visualCursor=urgentCursor=0;urgent.Clear();scratch.Clear();AnimationInProgress=false;
            foreach(var entry in visualPlan)visualPool.Push(entry);
            visualPlan.Clear();visualByItem.Clear();visualObserved.Clear();staleVisualItems.Clear();
            visualMaterials.Clear();visualTarget=null;
            visualDirty=true;visualInProgress=visualPlanInvalid=visualCameraKnown=false;visualScan=0;
            VisibilityEpoch=CompletedVisibilityEpoch=VisibilityEpochCompletions=VisibilityClassifications=DiscardedVisibilityEpochs=PendingVisibilityHides=0;
            LastVisibilityEpochSeconds=0;
        }
        public void SpawnFinished(bool preSettled=false)
        {
            // A completed opening scan remains valid when interaction starts.
            if(!initialized)QueueOpening();
            settleUntil=preSettled?Time.time:Time.time+settings.spawnProtection;nextRefresh=0;
        }
        void QueueOpening()
        {
            urgent.Clear();urgentCursor=0;
            foreach(var item in game.Items)if(Valid(item))
            {item.SurfaceKnown=false;item.NextSurfaceCheck=0;item.SurfaceProbeQueued=true;urgent.Add(item);}
            urgent.Sort((a,b)=>b.SelectionCollider.bounds.max.y.CompareTo(a.SelectionCollider.bounds.max.y));
        }
        // After synchronising the prepared poses, call once per rendered frame
        // until true, before revealing the opening. No unbounded startup pass.
        public bool RefreshPreparedOpening()
        {
            if(!game||settings==null)return true;
            if(!initialized&&urgent.Count==0){settleUntil=Time.time;QueueOpening();}
            Refresh(true);
            if(urgent.Count>0)return false;
            foreach(var item in scratch)if(!item.SurfaceKnown||(!item.SurfaceExposed&&!item.OcclusionKnown))return false;
            return !visualInProgress&&!visualDirty&&CompletedVisibilityEpoch>0;
        }
        static bool Valid(GooseItem item)=>item&&!item.Picked&&item.gameObject.activeInHierarchy&&item.Body&&item.SelectionCollider;
        static bool Eligible(GooseItem item)=>Valid(item)&&item.SurfaceActive&&item.DepthVisible&&!item.DepthHeld&&!item.Body.isKinematic&&!item.SurfaceAnimating;
        public void CopySurface(List<GooseItem> destination)
        {
            destination.Clear();if(!game)return;
            foreach(var item in game.Items)if(Eligible(item)&&
                WithinActiveSurfaceBand(item.SelectionCollider.bounds,ActiveSurfaceThreshold))destination.Add(item);
        }
        void Queue(GooseItem item)
        {
            item.NextSurfaceCheck=0;item.NextOcclusionCheck=0;
            if(item.SurfaceProbeQueued)return;
            item.SurfaceProbeQueued=true;urgent.Add(item);
        }
        public void NotifyRemoval(Vector3 position,float radius,Bounds? removedBounds=null)
        {
            var removed=removedBounds??new Bounds(position,Vector3.one*Mathf.Min(radius,.7f));
            foreach(var item in game.Items)
            {
                if(!Valid(item)||item.SurfaceAnimating)continue;
                var bounds=item.SelectionCollider.bounds;var delta=bounds.center-position;delta.y=0;
                if(delta.sqrMagnitude>radius*radius)continue;
                Queue(item);
                // Wake immediate contact neighbours above the removed hull,
                // never a whole cylinder down to the bottom of the pile.
                bool above=bounds.center.y>=removed.center.y-.04f;
                bool touching=bounds.min.y<=removed.max.y+.12f&&bounds.min.y>=removed.min.y-.08f;
                bool overlap=bounds.max.x>=removed.min.x-.06f&&bounds.min.x<=removed.max.x+.06f&&
                    bounds.max.z>=removed.min.z-.06f&&bounds.min.z<=removed.max.z+.06f;
                if(above&&touching&&overlap)item.ReleaseDepth(Time.time+Mathf.Min(.25f,settings.disturbanceProtection),false);
            }
            // The runtime frontier follows actual downward geometry on the next
            // refresh. Keep its prior value so a simultaneous upward shake and
            // pick cannot raise the frontier and demote unrelated surface pieces.
            nextRefresh=0;
            MarkVisualDirty();
        }
        public void Invalidate(){nextRefresh=0;}
        public void ModelSizeChanged()
        {
            initialized=false;settleUntil=Time.time;nextRefresh=0;
            foreach(var item in game.Items)if(Valid(item)){item.OcclusionKnown=false;item.NextOcclusionCheck=0;}
            MarkVisualDirty();
            QueueOpening();
        }
        public void DisturbAll()
        {
            // Retained for old callers, but no longer releases buried pieces.
            foreach(var item in game.Items)if(Eligible(item))
            {item.DepthProtectedUntil=Time.time+settings.disturbanceProtection;item.Body.WakeUp();}
            nextRefresh=0;
        }
        void FixedUpdate()
        {
            if(!game||!game.Playing||game.Paused||!game.SpawnComplete||Time.time<nextRefresh)return;
            nextRefresh=Time.time+settings.refreshInterval;RefreshNow();
        }
        void LateUpdate()
        {
            if(!game||!game.Playing||game.Paused||!game.SpawnComplete||AnimationInProgress)return;
            bool corrected=false;
            foreach(var item in game.Items)
                if(Valid(item)&&!item.DepthHeld&&!item.SurfaceAnimating&&(!item.Body.IsSleeping()||item.PhysicsRecoveryActive))
                    corrected|=CorrectFloorSupport(item);
            if(corrected)Physics.SyncTransforms();
        }
        bool CorrectFloorSupport(GooseItem item)
        {
            if(item.DepthHeld||item.SurfaceAnimating||item.Body.isKinematic)return false;
            var collider=item.SelectionCollider;if(!collider)return false;
            if(collider.bounds.min.y>=GooseCircularContainer.FloorY+.02f&&GooseColliderGeometry.BoundsMinY(collider)>=GooseCircularContainer.FloorY+.02f)return false;
            float physicalMin=GooseColliderGeometry.MinY(collider,GooseColliderGeometry.BodyMatrix(collider,item.Body));
            float lift=GooseCircularContainer.FloorY+.005f-physicalMin;
            if(lift<=.01f&&GooseColliderGeometry.MinY(collider)>=GooseCircularContainer.FloorY-.005f)return false;
            item.ReleaseDepth(Time.time+.3f,false);item.BeginFloorRecovery();
            var position=item.Body.position+Vector3.up*Mathf.Max(0,lift);var rotation=item.Body.rotation;
            item.Body.position=position;item.Body.rotation=rotation;item.transform.SetPositionAndRotation(position,rotation);
            var velocity=item.Body.velocity;if(velocity.y<0)velocity.y=0;item.Body.velocity=velocity;item.Body.WakeUp();return true;
        }
        public void RefreshNow()
        {
            if(!game||!game.Playing||game.Paused||!game.SpawnComplete)return;
            Refresh(false);
        }
        void Refresh(bool opening)
        {
            long began=System.Diagnostics.Stopwatch.GetTimestamp();LastProbeCount=0;
            scratch.Clear();castTop=0;float top=float.NegativeInfinity;
            foreach(var item in game.Items)if(Valid(item))
            {scratch.Add(item);top=Mathf.Max(top,item.Body.position.y);castTop=Mathf.Max(castTop,item.SelectionCollider.bounds.max.y+.25f);}
            HeldCount=HiddenCount=DynamicCount=SurfaceCount=0;
            if(scratch.Count==0){FinishTiming(began);return;}
            // Runtime geometry adaptation: follow an actual fall immediately,
            // while a shake lifting the top cannot lift the activation frontier.
            // The recovered rate-limited formula remains in PileDepthPolicy for
            // source research, but made late-game pieces wait behind empty air.
            frontier=initialized?Mathf.Min(frontier,top):top;initialized=true;
            VisibleThreshold=PileDepthPolicy.Threshold(frontier,settings.referenceHeight,settings.visibleDepthMin,settings.visibleDepthMax,1);
            RigidThreshold=PileDepthPolicy.Threshold(frontier,settings.referenceHeight,settings.visibleDepthMin,settings.visibleDepthMax,settings.rigidDepthMultiplier);
            bool locked=AnimationInProgress||(!opening&&game.Shake&&game.Shake.Active);
            if(!locked)
            {
                // Include the worst complete multi-scale test before starting
                // another item, leaving at least 64 queries for visual coverage.
                while(LastProbeCount<MaxProbeCount-64-MaxSurfaceProbeQueries&&urgentCursor<urgent.Count)
                {
                    var item=urgent[urgentCursor++];if(!Valid(item))continue;
                    item.SurfaceProbeQueued=false;UpdateSurface(item);
                }
                if(urgentCursor>=urgent.Count){urgent.Clear();urgentCursor=0;}
                int visited=0;
                while(visited<scratch.Count&&LastProbeCount<MaxProbeCount-64-MaxSurfaceProbeQueries)
                {
                    if(probeCursor>=scratch.Count)probeCursor=0;
                    var item=scratch[probeCursor++];visited++;
                    if(Time.time>=item.NextSurfaceCheck&&!item.SurfaceProbeQueued)UpdateSurface(item);
                }
            }
            bool allSleeping=true;
            foreach(var item in scratch)
            {
                if(item.SurfaceAnimating||locked)
                {if(!item.Body.isKinematic&&!item.Body.IsSleeping())allSleeping=false;continue;}
                float speed=item.Body.isKinematic?0:item.Body.velocity.magnitude;
                float angular=item.Body.isKinematic?0:item.Body.angularVelocity.magnitude;
                bool moving=speed>settings.speedGuard||angular>settings.angularSpeedGuard;
                if(moving)item.DepthStillSince=Time.time;
                bool inBand=WithinActiveSurfaceBand(item.SelectionCollider.bounds,ActiveSurfaceThreshold);
                bool exposed=inBand&&item.SurfaceKnown&&item.SurfaceExposed;
                if(exposed)
                {
                    // Opening classification precedes the grow-in animation.
                    // Keep every prepared pose anchored until SpawnFinished.
                    if(!opening&&(item.DepthHeld||item.Body.isKinematic)){item.SetDepthHeld(false);ExposureActivations++;}
                    item.SurfaceActive=!opening;
                }
                else
                {
                    item.SurfaceActive=false;
                    bool protectedState=!item.DepthReady||Time.time<item.DepthProtectedUntil||Time.time<settleUntil;
                    if(!protectedState&&!moving&&Time.time-item.DepthStillSince>=settings.settledDuration&&
                        !item.DepthHeld&&!CorrectFloorSupport(item))item.SetDepthHeld(true);
                }
                if(!item.Body.isKinematic&&!item.Body.IsSleeping())
                {allSleeping=false;CorrectFloorSupport(item);}
                if(item.PhysicsRecoveryActive)
                {
                    bool settled=Time.time>item.DepthProtectedUntil&&Time.time-item.DepthStillSince>.35f&&!moving;
                    bool expired=Time.time-item.PhysicsRecoveryStarted>2&&GooseColliderGeometry.MinY(item.SelectionCollider,
                        GooseColliderGeometry.BodyMatrix(item.SelectionCollider,item.Body))>=GooseCircularContainer.FloorY-.005f;
                    if(settled||expired)item.RestoreNormalPhysics();
                }
            }
            // Capture geometry after this refresh's physical support corrections.
            // The rendering decision never feeds the next classification epoch.
            if(!locked){ObserveVisualGeometry();AdvanceVisualEpoch(opening);}
            foreach(var item in scratch)
            {
                if(item.SurfaceAnimating||locked){Count(item);continue;}
                bool exposed=WithinActiveSurfaceBand(item.SelectionCollider.bounds,ActiveSurfaceThreshold)&&item.SurfaceKnown&&item.SurfaceExposed;
                bool protectedVisible=ForceVisible(item);
                // A protected reveal must retire a previous hide. Its expiry
                // cannot resurrect an old covered cache before a new epoch ends.
                if(protectedVisible){item.CachedCovered=false;item.OcclusionKnown=true;}
                bool knownCoverage=item.OcclusionKnown;
                // Height gates physics participation, never the rendered
                // silhouette. Side-visible supports stay drawn and kinematic.
                bool visible=exposed||!item.DepthReady||protectedVisible||
                    (knownCoverage?!item.CachedCovered:item.DepthVisible);
                if(visible)item.CoveredSince=-1;
                else if(item.DepthVisible)
                {if(item.CoveredSince<0)item.CoveredSince=Time.time;visible=Time.time-item.CoveredSince<settings.settledDuration;}
                item.SetDepthVisible(visible);Count(item);
            }
            if(allSleeping&&!opening&&urgent.Count==0&&!visualInProgress&&!visualDirty)nextRefresh=Time.time+.35f;
            FinishTiming(began);
        }
        void Count(GooseItem item)
        {
            if(item.DepthHeld)HeldCount++;else DynamicCount++;
            if(!item.DepthVisible)HiddenCount++;if(Eligible(item))SurfaceCount++;
        }
        void FinishTiming(long began)
        {LastRefreshMs=(float)((System.Diagnostics.Stopwatch.GetTimestamp()-began)*1000.0/System.Diagnostics.Stopwatch.Frequency);}
        void UpdateSurface(GooseItem item)
        {
            if(item.SurfaceAnimating)return;
            if(!WithinActiveSurfaceBand(item.SelectionCollider.bounds,ActiveSurfaceThreshold))
            {item.SurfaceKnown=true;item.SurfaceExposed=false;item.NextSurfaceCheck=Time.time+.35f;return;}
            bool exposed=ProbeSurface(item,castTop,ItemMask,out int queries);
            LastProbeCount+=queries;item.SurfaceKnown=true;item.SurfaceExposed=exposed;
            item.NextSurfaceCheck=Time.time+(exposed?.25f:1f);
        }
        // Pure geometry entry, usable without constructing GooseGame.
        public static bool ProbeSurface(GooseItem item,float top,int layerMask)
        {return ProbeSurface(item,top,layerMask,out _);}
        public static bool ProbeSurface(GooseItem item,float top,int layerMask,out int queries)
        {
            queries=0;if(!Valid(item)||!item.SelectionCollider.enabled)return false;
            var bounds=item.SelectionCollider.bounds;float y=Mathf.Max(top,bounds.max.y+.1f);
            // A covered center and rim do not prove the inner footprint is
            // covered: gaps between neighbouring hulls can expose that region.
            // Keep the original outer ring and add a full inner ring.
            for(int probe=0;probe<17;probe++)
            {
                var offset=probe<=8?ProbeOffset(probe,bounds.extents*.30f):
                    ProbeOffset(probe-8,bounds.extents*.72f);
                var ray=new Ray(new Vector3(bounds.center.x+offset.x,y,bounds.center.z+offset.z),Vector3.down);
                queries++;if(!item.SelectionCollider.Raycast(ray,out var own,100))continue;
                queries++;if(!Physics.Raycast(ray,out var hit,own.distance+.015f,layerMask,QueryTriggerInteraction.Ignore))continue;
                if(hit.collider.attachedRigidbody==item.Body)return true;
            }
            return false;
        }
        public bool IsExposed(GooseItem item)=>ProbeSurface(item,castTop,ItemMask);
        static Vector3 ProbeOffset(int probe,Vector3 extents)
        {
            switch(probe)
            {
                case 1:return new Vector3(extents.x,0,0);case 2:return new Vector3(-extents.x,0,0);
                case 3:return new Vector3(0,0,extents.z);case 4:return new Vector3(0,0,-extents.z);
                case 5:return new Vector3(extents.x,0,extents.z);case 6:return new Vector3(-extents.x,0,extents.z);
                case 7:return new Vector3(extents.x,0,-extents.z);case 8:return new Vector3(-extents.x,0,-extents.z);
                default:return Vector3.zero;
            }
        }
        bool ForceVisible(GooseItem item)
        {
            if(!item.DepthReady)return true;
            if(item.SurfaceKnown&&item.SurfaceExposed&&WithinActiveSurfaceBand(item.SelectionCollider.bounds,ActiveSurfaceThreshold))return true;
            // Prepared opening poses are anchored. A boundary-rounding error in
            // the still timer must not force the entire inventory to grow in.
            if(!game.SpawnComplete)return false;
            bool moving=!item.Body.isKinematic&&(item.Body.velocity.sqrMagnitude>settings.speedGuard*settings.speedGuard||
                item.Body.angularVelocity.sqrMagnitude>settings.angularSpeedGuard*settings.angularSpeedGuard);
            return moving||Time.time<item.DepthProtectedUntil||Time.time-item.DepthStillSince<settings.settledDuration;
        }
        void MarkVisualDirty()
        {
            visualDirty=true;
            if(visualInProgress)visualPlanInvalid=true;
        }
        static bool SameMatrix(Matrix4x4 a,Matrix4x4 b)
        {
            for(int i=0;i<16;i++)if(Mathf.Abs(a[i]-b[i])>.00001f)return false;
            return true;
        }
        static bool SameVisualGeometry(VisualEntry a,VisualEntry b)
        {
            return (a.position-b.position).sqrMagnitude<=.00000001f&&Quaternion.Angle(a.rotation,b.rotation)<=.01f&&
                (a.scale-b.scale).sqrMagnitude<=.00000001f&&(a.bounds.center-b.bounds.center).sqrMagnitude<=.00000001f&&
                (a.bounds.size-b.bounds.size).sqrMagnitude<=.00000001f&&a.enabled==b.enabled&&a.forced==b.forced&&
                a.opaque==b.opaque&&a.materialRevision==b.materialRevision;
        }
        void CaptureVisual(VisualEntry entry,GooseItem item)
        {
            entry.item=item;entry.position=item.Body.position;entry.rotation=item.Body.rotation;
            entry.scale=item.transform.lossyScale;entry.bounds=item.SelectionCollider.bounds;
            entry.enabled=item.SelectionCollider.enabled;entry.forced=ForceVisible(item);
            entry.opaque=item.VisualOccluder;entry.materialRevision=item.VisualMaterialRevision;
        }
        // Reused scratch entry avoids allocating pose snapshots every refresh.
        readonly VisualEntry visualSample=new VisualEntry();
        void ObserveVisualGeometry()
        {
            var camera=game.MainCamera;var view=camera.worldToCameraMatrix;var projection=camera.projectionMatrix;
            if(!visualCameraKnown||!SameMatrix(view,observedView)||!SameMatrix(projection,observedProjection))MarkVisualDirty();
            observedView=view;observedProjection=projection;visualCameraKnown=true;visualScan++;
            visualMaterials.Clear();
            foreach(var item in scratch)
            {
                if(item.RefreshVisualOcclusionCache(visualMaterials))MarkVisualDirty();
                CaptureVisual(visualSample,item);
                if(!visualObserved.TryGetValue(item,out var prior))
                {prior=new VisualEntry();visualObserved.Add(item,prior);CaptureVisual(prior,item);MarkVisualDirty();}
                else if(!SameVisualGeometry(prior,visualSample))
                {CaptureVisual(prior,item);MarkVisualDirty();}
                prior.seen=visualScan;
            }
            staleVisualItems.Clear();
            foreach(var pair in visualObserved)if(pair.Value.seen!=visualScan)staleVisualItems.Add(pair.Key);
            foreach(var item in staleVisualItems){visualObserved.Remove(item);MarkVisualDirty();}
        }
        bool CurrentVisualEntry(VisualEntry entry)
        {
            return Valid(entry.item)&&entry.item.SelectionCollider.enabled&&
                visualObserved.TryGetValue(entry.item,out var current)&&SameVisualGeometry(entry,current)&&
                SameMatrix(epochView,observedView)&&SameMatrix(epochProjection,observedProjection);
        }
        void BeginVisualEpoch()
        {
            foreach(var entry in visualPlan)visualPool.Push(entry);
            visualPlan.Clear();visualByItem.Clear();visualCursor=0;PendingVisibilityHides=0;
            var camera=game.MainCamera;var forward=camera.transform.forward;var cameraPosition=camera.transform.position;
            foreach(var item in scratch)
            {
                var entry=visualPool.Count>0?visualPool.Pop():new VisualEntry();
                entry.confirmed=entry.visible=false;CaptureVisual(entry,item);var e=entry.bounds.extents;
                entry.depth=Vector3.Dot(entry.bounds.center-cameraPosition,forward)-
                    (Mathf.Abs(forward.x)*e.x+Mathf.Abs(forward.y)*e.y+Mathf.Abs(forward.z)*e.z);
                visualPlan.Add(entry);
            }
            visualPlan.Sort((a,b)=>{int order=a.depth.CompareTo(b.depth);return order!=0?order:a.item.GetInstanceID().CompareTo(b.item.GetInstanceID());});
            for(int i=0;i<visualPlan.Count;i++){var entry=visualPlan[i];entry.rank=i;visualByItem.Add(entry.item,entry);}
            epochView=observedView;epochProjection=observedProjection;
            VisibilityEpoch++;visualInProgress=true;visualDirty=visualPlanInvalid=false;visualEpochBegan=Time.unscaledTime;
        }
        void AdvanceVisualEpoch(bool opening)
        {
            if(!visualInProgress&&visualDirty)
            {
                // Startup must not classify against a partly-known physical
                // surface and then restart simply because its probes completed.
                if(opening){foreach(var item in scratch)if(!item.SurfaceKnown)return;}
                BeginVisualEpoch();
            }
            if(!visualInProgress)return;
            while(visualCursor<visualPlan.Count)
            {
                var entry=visualPlan[visualCursor];var item=entry.item;
                if(!Valid(item)){visualPlanInvalid=true;visualDirty=true;visualCursor++;continue;}
                bool forced=ForceVisible(item);
                bool current=CurrentVisualEntry(entry);
                if(!forced&&!current){visualCursor++;continue;}
                if(!forced&&LastProbeCount>MaxProbeCount-MaxVisualProbeQueries)break;
                entry.visible=forced||!ProbeCovered(entry);entry.confirmed=true;visualCursor++;
                item.VisibilityEpoch=VisibilityEpoch;item.VisibilityClassifications++;VisibilityClassifications++;
                if(!forced)item.NextOcclusionCheck=Time.time+(item.DepthHeld?1f:.3f);
                if(entry.visible)
                {
                    // Reveals can publish immediately. New hides wait until the
                    // whole plan is known, so hiding an old cover cannot open a
                    // hole while its formerly hidden successor is still pending.
                    item.CachedCovered=false;item.OcclusionKnown=true;
                }
                else PendingVisibilityHides++;
            }
            if(visualCursor<visualPlan.Count)return;
            bool valid=!visualPlanInvalid;
            foreach(var entry in visualPlan)if(!entry.confirmed||!CurrentVisualEntry(entry)){valid=false;break;}
            if(valid)
            {
                foreach(var entry in visualPlan)
                {
                    var item=entry.item;item.CachedCovered=!entry.visible;item.OcclusionKnown=true;
                    item.CommittedVisibilityEpoch=VisibilityEpoch;
                }
                CompletedVisibilityEpoch=VisibilityEpoch;VisibilityEpochCompletions++;
            }
            else{DiscardedVisibilityEpochs++;visualDirty=true;}
            LastVisibilityEpochSeconds=Time.unscaledTime-visualEpochBegan;
            visualInProgress=false;visualPlanInvalid=false;PendingVisibilityHides=0;
        }
        bool ProbeCovered(VisualEntry target)
        {
            visualTarget=target;
            bool covered=ProbeVisualCoverage(target.item,game.MainCamera,visualCoverFilter,visualHits,out int queries);
            LastProbeCount+=queries;return covered;
        }
        bool PlannedVisualCover(GooseItem cover)
        {
            return visualByItem.TryGetValue(cover,out var planned)&&planned.opaque&&
                planned.rank<visualTarget.rank&&planned.confirmed&&planned.visible&&CurrentVisualEntry(planned);
        }
        // Same camera/hull query used by production and isolated real-material
        // fixtures. The caller supplies already-confirmed DAG predecessors.
        public static bool ProbeVisualCoverage(GooseItem item,Camera camera,Predicate<GooseItem> confirmedPredecessor,
            RaycastHit[] hits,out int queries)
        {
            queries=0;if(!Valid(item)||!camera||hits==null||hits.Length==0)return false;
            var bounds=item.OcclusionVisualBounds;
            var right=camera.transform.right;var up=camera.transform.up;var extents=bounds.extents;
            float x=Mathf.Abs(right.x)*extents.x+Mathf.Abs(right.y)*extents.y+Mathf.Abs(right.z)*extents.z;
            float y=Mathf.Abs(up.x)*extents.x+Mathf.Abs(up.y)*extents.y+Mathf.Abs(up.z)*extents.z;
            var forward=camera.transform.forward;
            float nearDepth=Vector3.Dot(bounds.center-camera.transform.position,forward)-
                (Mathf.Abs(forward.x)*extents.x+Mathf.Abs(forward.y)*extents.y+Mathf.Abs(forward.z)*extents.z);
            if(float.IsNaN(nearDepth)||float.IsInfinity(nearDepth)||nearDepth<=camera.nearClipPlane||item.Frozen)return false;
            for(int row=0;row<5;row++)for(int column=0;column<5;column++)
            {
                var sample=bounds.center+right*((column*.5f-1)*x)+up*((row*.5f-1)*y);
                var ray=camera.ViewportPointToRay(camera.WorldToViewportPoint(sample));
                float denominator=Vector3.Dot(ray.direction,forward);if(denominator<=.00001f)return false;
                float limit=(nearDepth-Vector3.Dot(ray.origin-camera.transform.position,forward))/denominator-.003f;
                if(limit<=0||float.IsNaN(limit)||float.IsInfinity(limit)||queries>=MaxVisualProbeQueries)return false;
                queries++;
                int count=Physics.RaycastNonAlloc(ray,hits,limit,ItemMask,QueryTriggerInteraction.Ignore);
                if(count==hits.Length)return false;
                bool covered=false;
                for(int i=0;i<count;i++)
                {
                    var cover=hits[i].collider.GetComponentInParent<GooseItem>();
                    if(cover&&cover!=item&&!cover.Picked&&cover.VisualOccluder&&confirmedPredecessor!=null&&confirmedPredecessor(cover))
                    {
                        // A physical convex proxy can extend beyond the visible
                        // mesh. Only its contracted interior can hide another
                        // item, with every outer target sample covered as well.
                        if(queries>=MaxVisualProbeQueries)return false;
                        const float interior=.95f;
                        var center=hits[i].collider.bounds.center;
                        var interiorRay=new Ray(center+(ray.origin-center)/interior,ray.direction);
                        queries++;
                        if(hits[i].collider.Raycast(interiorRay,out var inner,limit/interior))
                        {covered=true;break;}
                    }
                }
                if(!covered)return false;
            }
            return true;
        }
    }
}
