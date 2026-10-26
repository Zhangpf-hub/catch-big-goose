using System;
using System.Collections.Generic;
using UnityEngine;
namespace CatchGoose
{
    public sealed class GooseShakeController:MonoBehaviour
    {
        [Serializable] public sealed class MotionResult
        {
            public int affected,moved,turned,changedNeighbours,pulses;
            public float maxTravel,meanTravel,maxTurn,maxAddedHorizontal,maxAddedVertical;
            public bool interrupted;
        }
        sealed class Target
        {
            public GooseItem item,neighbour;public Vector3 start;public Quaternion rotation;
            public Vector2 added;public Vector3 spread,spin;
            public float travel,turn,horizontal,vertical;public bool affected;
        }
        public const float Cooldown=1.5f;
        public int Accepted {get;private set;}
        public bool SensorAvailable {get;set;}
        public float CooldownRemaining=>Mathf.Max(0,nextShake-Time.unscaledTime);
        public bool Active=>pending||tracking;
        public MotionResult LastMotion {get;private set;}
        readonly List<int> targetIds=new List<int>(48);
        public IReadOnlyList<int> TargetIds=>targetIds;
        readonly List<GooseItem> candidates=new List<GooseItem>(320);
        readonly List<Target> targets=new List<Target>(48);
        readonly Target[] pool=new Target[48];
        GooseGame game;GooseCircularContainer container;Vector3 gravity,direction;
        float lastSample=-1,nextShake,peakTime=-10,strength,started,samplePeak;
        Vector3 sampleDirection;
        bool pending,tracking,measure,sensorInput;int pulse;
        public void Initialize(GooseGame owner){game=owner;for(int i=0;i<pool.Length;i++)pool[i]=new Target();}
        public void ResetSensor(){lastSample=-1;peakTime=-10;gravity=Vector3.zero;if(sensorInput&&tracking)strength=0;}
        public void CancelRound(){pending=false;if(tracking)FinishMotion(true);targets.Clear();targetIds.Clear();nextShake=0;ResetSensor();}
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
            string rejected=!game.Playing?"not_playing":game.Paused?"paused":!game.SpawnComplete?"opening":game.Depth.AnimationInProgress?"reordering":Time.unscaledTime<nextShake?"cooldown":null;
            if(rejected==null)
            {
                bool available=false;
                foreach(var item in game.Items)if(CanShake(item)){available=true;break;}
                if(!available)rejected="no_surface";
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
            pending=false;tracking=true;pulse=0;started=Time.time;container=game.Container;measure=GooseSave.IsQa||(game.ShakeDiagnostics&&game.ShakeDiagnostics.Active);
            candidates.Clear();targets.Clear();targetIds.Clear();game.Depth.CopySurface(candidates);
            candidates.RemoveAll(item=>!CanShake(item));
            candidates.Sort((a,b)=>b.Body.position.y.CompareTo(a.Body.position.y));
            var profile=GooseInteractionProfile.Current;int count=Mathf.Min(Mathf.Min(candidates.Count,profile.shakeMaxBodies),pool.Length);
            for(int i=0;i<count;i++)
            {
                var t=pool[i];t.item=candidates[i];t.start=t.item.Body.position;t.rotation=t.item.Body.rotation;t.travel=t.turn=t.horizontal=t.vertical=0;t.added=Vector2.zero;t.affected=false;t.neighbour=null;
                float angle=i*2.399963f;t.spread=new Vector3(Mathf.Cos(angle),0,Mathf.Sin(angle));t.spin=new Vector3(Mathf.Sin(angle),.25f,Mathf.Cos(angle))*((i&1)==0?1:-1);
                targets.Add(t);targetIds.Add(t.item.GetInstanceID());
                // Existing dynamic bodies only. Do not release, reveal or change contact materials.
                t.item.DepthProtectedUntil=Mathf.Max(t.item.DepthProtectedUntil,started+profile.shakeForceWindowSeconds+.35f);t.item.DepthStillSince=Time.time;
            }
            if(measure)foreach(var t in targets)t.neighbour=Nearest(t.item);
            game.Depth.Invalidate();game.PlaySound("shake");
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
            if(measure)foreach(var t in targets)if(t.item&&!t.item.Picked){t.travel=Mathf.Max(t.travel,Vector3.Distance(t.start,t.item.Body.position));t.turn=Mathf.Max(t.turn,Quaternion.Angle(t.rotation,t.item.Body.rotation));}
            var p=GooseInteractionProfile.Current;
            if(samplePeak>0){direction=sampleDirection;strength=Mathf.Max(strength,samplePeak);samplePeak=0;}
            if(Time.time-started<p.shakeForceWindowSeconds)ApplyForce(p);
            if(Time.time-started>=p.shakeObserveSeconds)FinishMotion(false);
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
                if(pulse==0)
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
            var result=new MotionResult{pulses=pulse,interrupted=interrupted};float distance=Mathf.Max(.03f,game.ItemScale*.05f);
            foreach(var t in targets)if(t.affected)
            {
                result.affected++;result.maxTravel=Mathf.Max(result.maxTravel,t.travel);result.meanTravel+=t.travel;result.maxTurn=Mathf.Max(result.maxTurn,t.turn);
                result.maxAddedHorizontal=Mathf.Max(result.maxAddedHorizontal,t.horizontal);result.maxAddedVertical=Mathf.Max(result.maxAddedVertical,t.vertical);
                if(t.travel>=distance)result.moved++;if(t.turn>=5)result.turned++;
                if(measure&&t.item&&!t.item.Picked&&Nearest(t.item)!=t.neighbour)result.changedNeighbours++;
            }
            if(result.affected>0)result.meanTravel/=result.affected;LastMotion=result;tracking=false;targets.Clear();game.ShakeDiagnostics?.MotionMeasured(result);
        }
        void OnDisable(){pending=tracking=false;targets.Clear();}
    }
}
