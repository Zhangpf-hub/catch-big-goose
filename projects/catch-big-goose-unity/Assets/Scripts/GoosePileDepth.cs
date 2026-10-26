using System.Collections.Generic;
using UnityEngine;

namespace CatchGoose
{
    // Physical surface membership, visual coverage and collision support are separate.
    public sealed class GoosePileDepth : MonoBehaviour
    {
        public const int MaxProbeCount=256;
        const int ItemMask=~((1<<2)|(1<<8)|(1<<26)|(1<<27)|(1<<28)|(1<<29)|(1<<30));
        GooseGame game; PileAlgorithmSettings settings;
        float nextRefresh,settleUntil,frontier,castTop;
        bool initialized; int probeCursor,visualCursor,urgentCursor;
        readonly List<GooseItem> scratch=new List<GooseItem>(320),urgent=new List<GooseItem>(320);
        readonly RaycastHit[] visualHits=new RaycastHit[48];
        public int HeldCount {get;private set;}
        public int HiddenCount {get;private set;}
        public int DynamicCount {get;private set;}
        public int SurfaceCount {get;private set;}
        public int ExposureActivations {get;private set;}
        public int LastProbeCount {get;private set;}
        public float LastRefreshMs {get;private set;}
        public bool AnimationInProgress;
        public bool OverDynamicBudget=>settings!=null&&DynamicCount>settings.maxDynamicBodies;
        public float VisibleThreshold {get;private set;}
        public float RigidThreshold {get;private set;}
        // A slit between higher pieces does not activate the entire depth of the
        // pile. This is the current height frontier, combined with real exposure.
        public float ActiveSurfaceThreshold=>VisibleThreshold;
        public static bool WithinActiveSurfaceBand(Bounds bounds,float threshold)=>bounds.max.y>=threshold;
        public void Initialize(GooseGame owner,PileAlgorithmSettings profile){game=owner;settings=profile;}
        public void ResetRound()
        {
            initialized=false;nextRefresh=0;settleUntil=float.PositiveInfinity;
            HeldCount=HiddenCount=DynamicCount=SurfaceCount=ExposureActivations=LastProbeCount=0;
            probeCursor=visualCursor=urgentCursor=0;urgent.Clear();scratch.Clear();AnimationInProgress=false;
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
            return true;
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
            // Removal can expose a much lower pile immediately (rapid matches
            // or the final few pieces). Re-anchor only the height frontier; the
            // bounded exposure pass still decides which individual supports wake.
            initialized=false;
            nextRefresh=0;
        }
        public void Invalidate(){nextRefresh=0;}
        public void ModelSizeChanged()
        {
            initialized=false;settleUntil=Time.time;nextRefresh=0;
            foreach(var item in game.Items)if(Valid(item)){item.OcclusionKnown=false;item.NextOcclusionCheck=0;}
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
            frontier=initialized?PileDepthPolicy.Descend(frontier,top,settings.frontierStep):top;initialized=true;
            VisibleThreshold=PileDepthPolicy.Threshold(frontier,settings.referenceHeight,settings.visibleDepthMin,settings.visibleDepthMax,1);
            RigidThreshold=PileDepthPolicy.Threshold(frontier,settings.referenceHeight,settings.visibleDepthMin,settings.visibleDepthMax,settings.rigidDepthMultiplier);
            bool locked=AnimationInProgress||(!opening&&game.Shake&&game.Shake.Active);
            if(!locked)
            {
                // Surface pass leaves at least 64 query slots for visual coverage.
                while(LastProbeCount<MaxProbeCount-82&&urgentCursor<urgent.Count)
                {
                    var item=urgent[urgentCursor++];if(!Valid(item))continue;
                    item.SurfaceProbeQueued=false;UpdateSurface(item);
                }
                if(urgentCursor>=urgent.Count){urgent.Clear();urgentCursor=0;}
                int visited=0;
                while(visited<scratch.Count&&LastProbeCount<MaxProbeCount-82)
                {
                    if(probeCursor>=scratch.Count)probeCursor=0;
                    var item=scratch[probeCursor++];visited++;
                    if(Time.time>=item.NextSurfaceCheck&&!item.SurfaceProbeQueued)UpdateSurface(item);
                }
                visited=0;
                while(visited<scratch.Count&&LastProbeCount<=MaxProbeCount-18)
                {
                    if(visualCursor>=scratch.Count)visualCursor=0;
                    var item=scratch[visualCursor++];visited++;
                    if(item.SurfaceAnimating||item.SurfaceExposed||Time.time<item.NextOcclusionCheck)continue;
                    item.CachedCovered=ProbeCovered(item);item.OcclusionKnown=true;
                    item.NextOcclusionCheck=Time.time+(item.DepthHeld?1f:.3f);
                }
            }
            bool allSleeping=true;
            foreach(var item in scratch)
            {
                if(item.SurfaceAnimating||locked)
                {Count(item);if(!item.Body.isKinematic&&!item.Body.IsSleeping())allSleeping=false;continue;}
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
                bool protectedVisible=item.DepthVisible&&(moving||Time.time<item.DepthProtectedUntil||Time.time-item.DepthStillSince<settings.settledDuration);
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
            if(allSleeping&&!opening&&urgent.Count==0)nextRefresh=Time.time+.35f;
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
        static bool ProbeSurface(GooseItem item,float top,int layerMask,out int queries)
        {
            queries=0;if(!Valid(item)||!item.SelectionCollider.enabled)return false;
            var bounds=item.SelectionCollider.bounds;float y=Mathf.Max(top,bounds.max.y+.1f);
            for(int probe=0;probe<9;probe++)
            {
                var offset=ProbeOffset(probe,bounds.extents*.72f);
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
        bool ProbeCovered(GooseItem item)
        {
            var bounds=item.SelectionCollider.bounds;var camera=game.MainCamera;
            var right=camera.transform.right;var up=camera.transform.up;var extents=bounds.extents;
            float x=(Mathf.Abs(right.x)*extents.x+Mathf.Abs(right.y)*extents.y+Mathf.Abs(right.z)*extents.z)*.72f;
            float y=(Mathf.Abs(up.x)*extents.x+Mathf.Abs(up.y)*extents.y+Mathf.Abs(up.z)*extents.z)*.72f;
            int intersections=0;
            for(int probe=0;probe<9;probe++)
            {
                var offset=ProbeOffset(probe,new Vector3(x,0,y));
                var sample=bounds.center+right*offset.x+up*offset.z;
                var ray=camera.ViewportPointToRay(camera.WorldToViewportPoint(sample));
                LastProbeCount++;if(!item.SelectionCollider.Raycast(ray,out var own,100))continue;
                intersections++;LastProbeCount++;
                int count=Physics.RaycastNonAlloc(ray,visualHits,Mathf.Max(.001f,own.distance-.003f),ItemMask,QueryTriggerInteraction.Ignore);
                if(count==visualHits.Length)return false;
                bool covered=false;
                for(int i=0;i<count;i++)
                {
                    var cover=visualHits[i].collider.GetComponentInParent<GooseItem>();
                    if(cover&&cover!=item&&!cover.Picked&&cover.DepthVisible){covered=true;break;}
                }
                if(!covered)return false;
            }
            // A sample missing the actual thin hull is not evidence that the hull
            // is visible. Only intersecting samples participate in this decision.
            return intersections>0;
        }
    }
}
