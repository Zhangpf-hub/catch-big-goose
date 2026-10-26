using System;
using UnityEngine;

namespace CatchGoose
{
    // Counts describe one live listener and the current app session separately.
    // A late asynchronous start result must not overwrite a newer listener state.
    public sealed class GooseShakeProbeState
    {
        public int Attempt, StreamCallbacks, TotalCallbacks, SensorAccepted, ManualAccepted, Applied;
        public bool Listening, Started;
        public string Status="等待进入关卡", Error="";
        public Vector3 Last;
        public float MotionPeak, LastCallbackTime=-1, StartedAt;
        public int Begin(float now)
        {
            Attempt++;Listening=true;Started=false;StreamCallbacks=0;MotionPeak=0;
            Last=Vector3.zero;LastCallbackTime=-1;StartedAt=now;Error="";Status="正在启动";return Attempt;
        }
        public bool Result(int attempt,bool success,string error)
        {
            if(!Listening||attempt!=Attempt)return false;
            Started=success;Error=success?"":error??"";Status=success?"已启动，等待数据":"启动失败";return true;
        }
        public bool Callback(Vector3 value,float now)
        {
            if(!Listening)return false;
            Last=value;LastCallbackTime=now;StreamCallbacks++;TotalCallbacks++;Status="收到传感器数据";return true;
        }
        public void Stop(string reason){Listening=false;Started=false;Status=reason;}
    }

    public sealed class GooseShakeDiagnostics : MonoBehaviour
    {
        public const string TestBuild=GooseRuntimePerformance.BuildId;
        [Serializable] class Settings { public bool enabled; }
        [Serializable] class Entry
        {
            public string build=TestBuild,eventName,status,error,source,detail;
            public int attempt,callbacks,totalCallbacks,sensorAccepted,manualAccepted,applied;
            public int affected,moved,planarMoved,turned,changedNeighbours,pulses;
            public float maxTravel,meanTravel,maxPlanarTravel,meanPlanarTravel,maxTurn;
            public bool fallbackAttempted,fallbackCompleted;public string fallbackFailure;
            public float seconds,x,y,z,motionPeak,threshold,cooldown;
        }
        public readonly GooseShakeProbeState State=new GooseShakeProbeState();
        GooseGame game;bool active;
        float nextLog,nextReject;
        int lastAffected,lastPulses;
        public bool Active=>active;
        public void Initialize(GooseGame owner)
        {
            game=owner;
            var file=Resources.Load<TextAsset>("Data/shake-diagnostics");
            active=(file&&JsonUtility.FromJson<Settings>(file.text).enabled)||Array.IndexOf(System.Environment.GetCommandLineArgs(),"-gooseShakeDiagnostics")>=0;
            if(!active)return;
            // Diagnostics stay in logs; the player HUD only shows the timer.
            Emit("session","","runtime="+Application.platform+"; no backend privacy configuration changed");
        }
        public void Environment(string platform,string model,string version,string sdk)
        {Emit("environment","","platform="+platform+"; model="+model+"; WeChat="+version+"; SDK="+sdk);}
        public int Begin()
        {
            int id=State.Begin(Time.unscaledTime);nextLog=Time.unscaledTime+2;
            Emit("start_requested","","interval=ui");return id;
        }
        public bool StartResult(int attempt,bool success,string error)
        {
            bool current=State.Result(attempt,success,error);
            Emit(current?(success?"start_success":"start_failed"):"stale_start_result","",error);
            return current;
        }
        public void Callback(Vector3 value)
        {
            if(!State.Callback(value,Time.unscaledTime))return;
            if(State.StreamCallbacks==1)Emit("first_callback","sensor","");
        }
        public void Motion(float magnitude){State.MotionPeak=Mathf.Max(State.MotionPeak,magnitude);}
        public void Request(bool sensor,bool accepted,string reason)
        {
            if(accepted){if(sensor)State.SensorAccepted++;else State.ManualAccepted++;}
            else if(Time.unscaledTime<nextReject)return;
            else nextReject=Time.unscaledTime+1;
            Emit(accepted?"shake_accepted":"shake_rejected",sensor?"sensor":"button_or_space",reason);
        }
        public void PhysicsApplied(int affected)
        {State.Applied++;lastAffected=affected;lastPulses=0;Emit("physics_applied","","affected="+affected);}
        public void PulseApplied(int pulse,int affected)
        {lastPulses=pulse;Emit("physics_pulse","","pulse="+pulse+"; affected="+affected);}
        public void MotionMeasured(GooseShakeController.MotionResult result)
        {Emit("motion_measured","","interrupted="+result.interrupted);}
        public void Stop(string reason){State.Stop(reason);Emit("listener_stopped","",reason);}
        void Emit(string name,string source,string detail)
        {
            if(!active)return;
            var motion=game&&game.Shake?game.Shake.LastMotion:null;
            var e=new Entry{eventName=name,status=State.Status,error=State.Error,source=source,detail=detail,
                attempt=State.Attempt,callbacks=State.StreamCallbacks,totalCallbacks=State.TotalCallbacks,
                sensorAccepted=State.SensorAccepted,manualAccepted=State.ManualAccepted,applied=State.Applied,
                seconds=Time.unscaledTime,x=State.Last.x,y=State.Last.y,z=State.Last.z,motionPeak=State.MotionPeak,
                threshold=GooseInteractionProfile.Current.sensorThreshold,
                cooldown=game&&game.Shake?game.Shake.CooldownRemaining:0,
                affected=motion!=null?motion.affected:lastAffected,pulses=motion!=null?motion.pulses:lastPulses,
                moved=motion!=null?motion.moved:0,turned=motion!=null?motion.turned:0,
                planarMoved=motion!=null?motion.planarMoved:0,maxPlanarTravel=motion!=null?motion.maxPlanarTravel:0,meanPlanarTravel=motion!=null?motion.meanPlanarTravel:0,
                fallbackAttempted=motion!=null&&motion.fallbackAttempted,fallbackCompleted=motion!=null&&motion.fallbackCompleted,fallbackFailure=motion!=null?motion.fallbackFailure:"",
                changedNeighbours=motion!=null?motion.changedNeighbours:0,maxTravel=motion!=null?motion.maxTravel:0,
                meanTravel=motion!=null?motion.meanTravel:0,maxTurn=motion!=null?motion.maxTurn:0};
            Debug.Log("[GooseShakeTest] "+JsonUtility.ToJson(e));
        }
        void Update()
        {
            if(!active)return;
            if(State.Listening&&Time.unscaledTime>=nextLog)
            {
                nextLog=Time.unscaledTime+2;Emit("sample_summary","sensor","");
            }
        }
    }
}
