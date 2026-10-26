using System;
using System.Collections.Generic;
using UnityEngine;
namespace CatchGoose
{
    public sealed class GooseShakeController:MonoBehaviour
    {
        [Serializable] public sealed class MotionResult
        {
            public string mode="physics";
            public bool tossCompleted;public string tossFailure;
            public int affected,moved,planarMoved,turned,changedNeighbours,pulses;
            public float maxTravel,meanTravel,maxPlanarTravel,meanPlanarTravel,maxTurn,maxAddedHorizontal,maxAddedVertical;
            public bool interrupted,fallbackAttempted,fallbackCompleted;
            public string fallbackFailure;
        }
        sealed class Target
        {
            public GooseItem item,neighbour;public int instanceId;public Vector3 start;public Quaternion rotation;
            public Vector2 added;public Vector3 spread,spin;
            public float travel,planar,turn,horizontal,vertical;public bool affected;
        }
        public const float Cooldown=1.5f;
        public const float MaximumGestureSeconds=2.3f;
        public int Accepted {get;private set;}
        public bool SensorAvailable {get;set;}
        public float CooldownRemaining=>Mathf.Max(0,nextShake-Time.unscaledTime);
        public bool Active=>pending||tracking;
        public bool FallbackActive=>tracking&&fallbackStarted&&game&&game.SurfaceShuffle&&game.SurfaceShuffle.OwnerFromShake;
        public bool TossActive=>tracking&&tossStarted&&game&&game.SurfaceShuffle&&game.SurfaceShuffle.OwnerPhoneToss;
        public MotionResult LastMotion {get;private set;}
        readonly List<int> targetIds=new List<int>(48);
        public IReadOnlyList<int> TargetIds=>targetIds;
        readonly List<GooseItem> candidates=new List<GooseItem>(320);
        readonly List<GooseItem> fallbackTargets=new List<GooseItem>(48);
        readonly List<Target> targets=new List<Target>(48);
        readonly Target[] pool=new Target[48];
        GooseGame game;GooseCircularContainer container;Vector3 gravity,direction;
        float lastSample=-1,nextShake,peakTime=-10,strength,started,samplePeak;
        Vector3 sampleDirection;
        bool pending,tracking,measure,sensorInput;int pulse;
        bool fallbackAttempted,fallbackStarted,fallbackFinished,fallbackCompleted;
        string fallbackFailure="";
        bool tossRequested,tossStarted,tossFinished,tossSucceeded;string tossFailure="";
        public void Initialize(GooseGame owner){game=owner;for(int i=0;i<pool.Length;i++)pool[i]=new Target();}
        public void ResetSensor(){lastSample=-1;peakTime=-10;gravity=Vector3.zero;if(sensorInput&&tracking)strength=0;}
        public void CancelRound()
        {
            pending=false;
            if(FallbackActive||TossActive){fallbackFailure="round_interrupted";tossFailure="round_interrupted";game.SurfaceShuffle.CancelRound();}
            if(tracking)FinishMotion(true);
            targets.Clear();targetIds.Clear();candidates.Clear();fallbackTargets.Clear();nextShake=0;ResetSensor();
        }
        public static bool CanShake(GooseItem item)=>item&&!item.Picked&&item.gameObject.activeInHierarchy&&item.SurfaceActive&&!item.SurfaceAnimating&&item.DepthVisible&&!item.DepthHeld&&item.Body&&!item.Body.isKinematic;
        public void Sample(Vector3 acceleration,float timestamp)
        {
            if(!game.Playing||game.Paused||!game.SpawnComplete){ResetSensor();return;}
            if(lastSample<0){gravity=acceleration;lastSample=timestamp;return;}
            float dt=Mathf.Clamp(timestamp-lastSample,.005f,.25f);lastSample=timestamp;
            gravity=Vector3.Lerp(gravity,acceleration,1-Mathf.Exp(-dt/GooseInteractionProfile.Current.sensorFilterSeconds));
            var motion=acceleration-gravity;game.ShakeDiagnostics?.Motion(motion.magnitude);
            float power=Mathf.Clamp01((motion.magnitude-.8f)/2);var mapped=new Vector3(motion.x,motion.z,motion.y);
            // Hold the accepted peak for the short burst. A quiet callback must
            // not erase the impulse before the next physics step. Strong reverse
            // peaks update direction once per step, independently of callback Hz.
            if(sensorInput&&(pending||tracking)&&power>=.25f&&power>=samplePeak)
            {samplePeak=power;sampleDirection=mapped.sqrMagnitude>.001f?mapped.normalized:direction;}
            if(motion.magnitude<GooseInteractionProfile.Current.sensorThreshold)return;
            if(timestamp-peakTime<.28f)TryRequest(mapped,power,true);
            peakTime=timestamp;
        }
        public bool Request(Vector3 input,float power=1){return TryRequest(input,power,false);}
        bool TryRequest(Vector3 input,float power,bool sensor)
        {
            if(!game)return false;
            string rejected=!game.Playing?"not_playing":game.Paused?"paused":!game.SpawnComplete?"opening":game.Depth.AnimationInProgress?"reordering":tracking&&fallbackStarted?"finishing_shake":Time.unscaledTime<nextShake?"cooldown":null;
            if(rejected==null)
            {
                // The accepted input fixes its candidate snapshot now. The first
                // physics step can remove invalid entries, but never add new ones.
                game.Depth.CopySurface(candidates);
                candidates.RemoveAll(item=>!CanShake(item));
                if(candidates.Count==0)rejected="no_surface";
            }
            if(rejected!=null){game.ShakeDiagnostics?.Request(sensor,false,rejected);return false;}
            if(tracking)FinishMotion(true);
            nextShake=Time.unscaledTime+GooseInteractionProfile.Current.shakeCooldown;
            direction=input.sqrMagnitude<.01f?Vector3.right:input.normalized;
            // Once the deliberate two-peak gesture is accepted, deliver a clear
            // response even at a normal phone amplitude. Tiny raw power after
            // the threshold must not turn a valid gesture into a barely visible tick.
            strength=Mathf.Clamp(power,.7f,1);samplePeak=0;sampleDirection=direction;sensorInput=sensor;pending=true;Accepted++;LastMotion=null;game.ShakeDiagnostics?.Request(sensor,true,"");return true;
        }
        void Update(){if(Input.GetKeyDown(KeyCode.Space))Request(new Vector3(1,0,.35f));}
        void BeginMotion()
        {
            pending=false;tracking=true;pulse=0;started=Time.time;container=game.Container;measure=GooseSave.IsQa||(game.ShakeDiagnostics&&game.ShakeDiagnostics.Active)||(game.DeviceMonitor&&game.DeviceMonitor.Requested);
            fallbackAttempted=fallbackStarted=fallbackFinished=fallbackCompleted=false;fallbackFailure="";fallbackTargets.Clear();
            tossRequested=tossStarted=tossFinished=tossSucceeded=false;tossFailure="";
            targets.Clear();targetIds.Clear();
            candidates.RemoveAll(item=>!CanShake(item));
            candidates.Sort((a,b)=>b.Body.position.y.CompareTo(a.Body.position.y));
            var profile=GooseInteractionProfile.Current;int count=Mathf.Min(Mathf.Min(candidates.Count,profile.shakeMaxBodies),pool.Length);
            for(int i=0;i<count;i++)
            {
                var t=pool[i];t.item=candidates[i];t.instanceId=t.item.GetInstanceID();t.start=t.item.Body.position;t.rotation=t.item.Body.rotation;t.travel=t.planar=t.turn=t.horizontal=t.vertical=0;t.added=Vector2.zero;t.affected=false;t.neighbour=null;
                float angle=i*2.399963f;t.spread=new Vector3(Mathf.Cos(angle),0,Mathf.Sin(angle));t.spin=new Vector3(Mathf.Sin(angle),.25f,Mathf.Cos(angle))*((i&1)==0?1:-1);
                targets.Add(t);targetIds.Add(t.item.GetInstanceID());
                // Existing dynamic bodies only. Do not release, reveal or change contact materials.
                t.item.DepthProtectedUntil=Mathf.Max(t.item.DepthProtectedUntil,started+profile.shakeForceWindowSeconds+.35f);t.item.DepthStillSince=Time.time;
            }
            if(measure)foreach(var t in targets)t.neighbour=Nearest(t.item);
            game.Depth.Invalidate();game.PlaySound("shake");
            // The accepted gesture starts one bounded pan toss immediately.
            // The helper copies only this original surface; no force is sent to
            // buried supports, and the animation never spends a tool.
            tossRequested=true;
            foreach(var t in targets)fallbackTargets.Add(t.item);
            tossStarted=game.SurfaceShuffle&&game.SurfaceShuffle.BeginTossFromShake(fallbackTargets,container,1.55f);
            if(tossStarted)foreach(var t in targets)t.affected=true;
            else tossFailure=game.SurfaceShuffle?game.SurfaceShuffle.LastFailure:"pan_toss_helper_missing";
        }
        GooseItem Nearest(GooseItem item)
        {
            GooseItem nearest=null;float distance=float.PositiveInfinity;
            foreach(var t in targets)if(t.item&&t.item!=item&&!t.item.Picked){float d=(t.item.Body.position-item.Body.position).sqrMagnitude;if(d<distance){distance=d;nearest=t.item;}}
            return nearest;
        }
        void FixedUpdate()
        {
            if(!game||!game.Playing||!game.SpawnComplete){pending=false;if(tracking)FinishMotion(true);return;}
            if(game.Paused)return;if(pending)BeginMotion();if(!tracking)return;
            if(container!=game.Container){FinishMotion(true);return;}
            ObserveTargets();
            var p=GooseInteractionProfile.Current;float elapsed=Time.time-started;
            if(tossRequested)
            {
                if(elapsed>=MaximumGestureSeconds&&TossActive)
                {tossFailure="gesture_deadline";game.SurfaceShuffle.CancelRound();}
                if(!TossActive){ReadTossCompletion();FinishMotion(!tossSucceeded);}
                return;
            }
            if(samplePeak>0){direction=sampleDirection;strength=Mathf.Max(strength,samplePeak);samplePeak=0;}
            if(elapsed<p.shakeForceWindowSeconds&&!FallbackActive)ApplyForce(p);
            if(fallbackStarted&&!FallbackActive&&!fallbackFinished)ReadFallbackCompletion();
            if(!fallbackAttempted&&elapsed>=.65f)TryPlanarFallback(elapsed);
            if(elapsed>=MaximumGestureSeconds&&FallbackActive)
            {fallbackFailure="gesture_deadline";game.SurfaceShuffle.CancelRound();ReadFallbackCompletion();}
            if(elapsed>=p.shakeObserveSeconds&&!FallbackActive&&(!fallbackStarted||fallbackFinished))
                FinishMotion(fallbackAttempted&&!fallbackCompleted);
        }
        void ObserveTargets()
        {
            if(measure)foreach(var t in targets)if(t.item&&!t.item.Picked&&t.item.GetInstanceID()==t.instanceId)
            {var delta=t.item.Body.position-t.start;t.travel=Mathf.Max(t.travel,delta.magnitude);t.planar=Mathf.Max(t.planar,new Vector2(delta.x,delta.z).magnitude);t.turn=Mathf.Max(t.turn,Quaternion.Angle(t.rotation,t.item.Body.rotation));}
        }
        void TryPlanarFallback(float elapsed)
        {
            fallbackTargets.Clear();int enough=0;float distance=game.ItemScale*.12f;
            foreach(var target in targets)
            {
                if(!target.item||target.item.GetInstanceID()!=target.instanceId||!CanShake(target.item))continue;
                fallbackTargets.Add(target.item);var delta=target.item.Body.position-target.start;
                if(new Vector2(delta.x,delta.z).magnitude>=distance)enough++;
            }
            if(fallbackTargets.Count==0||enough>=Mathf.CeilToInt(fallbackTargets.Count*.5f))return;
            // Continue checking until the normal observation ends: an early hop
            // which returns to its old slot is not a successful reordering.
            fallbackAttempted=true;
            float remaining=Mathf.Min(1.55f,MaximumGestureSeconds-elapsed);
            fallbackStarted=game.SurfaceShuffle&&game.SurfaceShuffle.BeginFromShake(fallbackTargets,container,remaining);
            fallbackFinished=!fallbackStarted;
            if(!fallbackStarted)fallbackFailure=game.SurfaceShuffle?game.SurfaceShuffle.LastFailure:"reorder_helper_missing";
        }
        void ReadFallbackCompletion()
        {
            fallbackFinished=true;var helper=game.SurfaceShuffle;
            fallbackCompleted=helper&&helper.LastFromShake&&helper.LastMotion!=null&&!helper.LastMotion.interrupted;
            if(!fallbackCompleted&&string.IsNullOrEmpty(fallbackFailure))
                fallbackFailure=helper&&!string.IsNullOrEmpty(helper.LastFailure)?helper.LastFailure:"reorder_interrupted";
        }
        void ReadTossCompletion()
        {
            tossFinished=true;var helper=game.SurfaceShuffle;
            tossSucceeded=tossStarted&&helper&&helper.LastPhoneToss&&helper.LastMotion!=null&&!helper.LastMotion.interrupted;
            if(!tossSucceeded&&string.IsNullOrEmpty(tossFailure))
                tossFailure=helper&&!string.IsNullOrEmpty(helper.LastFailure)?helper.LastFailure:"pan_toss_interrupted";
        }
        void ApplyForce(GooseInteractionProfile p)
        {
            // Project adaptation: a bounded peak envelope, small decorrelated
            // horizontal forces and one lift. Integration is based on simulation
            // time, never the number of sensor callbacks received in that step.
            int affected=0;float dt=Time.fixedDeltaTime;
            foreach(var t in targets)
            {
                if(!CanShake(t.item))continue;var body=t.item.Body;
                Vector3 axis=new Vector3(direction.x,0,direction.z);
                if(axis.sqrMagnitude<.01f)axis=Vector3.right;axis=(axis.normalized+t.spread*.8f).normalized;
                // Apply the accepted acceleration peak at the start of the hop,
                // while contacts are unloading. A slow ramp spent most of its
                // budget after the pieces had already fallen back into friction.
                float step=pulse==0?p.shakeHorizontalBudget*.55f:p.shakeForceGain*dt;
                Vector2 desired=t.added+new Vector2(axis.x,axis.z)*(strength*step);
                var limited=Vector2.ClampMagnitude(desired,p.shakeHorizontalBudget);var change=limited-t.added;t.added=limited;
                Vector3 dv=new Vector3(change.x,0,change.y);
                if(Time.time-started<p.shakeLiftSupportSeconds)
                {
                    // Contact can absorb the first lift in a tightly packed top.
                    // Brief bounded feedback retries the lift, instead of spending
                    // the whole response on one impulse that never leaves contact.
                    float targetLift=p.shakeLiftSpeed*Mathf.Lerp(.7f,1,strength);
                    dv.y=Mathf.Min(Mathf.Max(0,targetLift-body.velocity.y),Mathf.Max(0,p.shakeVerticalBudget-t.vertical));
                }
                // Explicit velocity-change torque can bypass PhysX's rotation
                // locks. Respect a fully rotation-locked body's contract.
                if(pulse==0&&(body.constraints&RigidbodyConstraints.FreezeRotation)!=RigidbodyConstraints.FreezeRotation)
                {
                    var spin=Vector3.ClampMagnitude(body.angularVelocity+t.spin*(p.shakeTurnSpeed*.32f*strength),p.maxShakeAngularVelocity)-body.angularVelocity;
                    body.AddTorque(spin,ForceMode.VelocityChange);
                }
                var before=body.velocity;var after=BoundVelocity(before,dv,p.maxShakeVelocity,Mathf.Max(0,p.shakeVerticalBudget-t.vertical));
                dv=after-before;t.horizontal=Mathf.Max(t.horizontal,t.added.magnitude);t.vertical+=Mathf.Max(0,dv.y);
                body.AddForce(dv*(body.mass/dt),ForceMode.Force);t.affected=true;affected++;
            }
            if(pulse==0)game.ShakeDiagnostics?.PhysicsApplied(affected);
            pulse++;if(game.ShakeDiagnostics&&game.ShakeDiagnostics.Active)game.ShakeDiagnostics.PulseApplied(pulse,affected);
        }
        public static Vector3 BoundVelocity(Vector3 before,Vector3 added,float maximum,float remainingUpward)
        {
            // Do not turn an already fast fall into an unbudgeted upward impulse.
            // Gravity/collision velocity can exceed the shake's injection limit.
            float limit=Mathf.Max(maximum,before.magnitude);
            var after=Vector3.ClampMagnitude(before+added,limit);
            float ceiling=before.y+Mathf.Max(0,remainingUpward);
            if(after.y>ceiling)
            {
                after.y=ceiling;
                float horizontalLimit=Mathf.Sqrt(Mathf.Max(0,limit*limit-after.y*after.y));
                var horizontal=Vector2.ClampMagnitude(new Vector2(after.x,after.z),horizontalLimit);
                after.x=horizontal.x;after.z=horizontal.y;
            }
            return after;
        }
        void FinishMotion(bool interrupted)
        {
            if(interrupted&&TossActive){tossFailure="gesture_interrupted";game.SurfaceShuffle.CancelRound();}
            if(tossRequested&&!tossFinished)ReadTossCompletion();
            if(interrupted&&FallbackActive){fallbackFailure="gesture_interrupted";game.SurfaceShuffle.CancelRound();}
            if(fallbackStarted&&!fallbackFinished)ReadFallbackCompletion();
            ObserveTargets();
            var result=new MotionResult{mode=tossRequested?"controlled-pan-toss":"physics",tossCompleted=tossSucceeded,tossFailure=tossFailure,pulses=pulse,interrupted=interrupted,fallbackAttempted=fallbackAttempted,fallbackCompleted=fallbackCompleted,fallbackFailure=fallbackFailure};float distance=Mathf.Max(.03f,game.ItemScale*.05f);
            foreach(var t in targets)if(t.affected)
            {
                result.affected++;result.maxTravel=Mathf.Max(result.maxTravel,t.travel);result.meanTravel+=t.travel;result.maxTurn=Mathf.Max(result.maxTurn,t.turn);
                result.maxPlanarTravel=Mathf.Max(result.maxPlanarTravel,t.planar);result.meanPlanarTravel+=t.planar;
                result.maxAddedHorizontal=Mathf.Max(result.maxAddedHorizontal,t.horizontal);result.maxAddedVertical=Mathf.Max(result.maxAddedVertical,t.vertical);
                if(t.travel>=distance)result.moved++;if(t.planar>=distance)result.planarMoved++;if(t.turn>=5)result.turned++;
                if(measure&&t.item&&!t.item.Picked&&Nearest(t.item)!=t.neighbour)result.changedNeighbours++;
            }
            if(result.affected>0){result.meanTravel/=result.affected;result.meanPlanarTravel/=result.affected;}LastMotion=result;tracking=false;targets.Clear();game.ShakeDiagnostics?.MotionMeasured(result);
        }
        void OnDisable(){CancelRound();}
    }
}
