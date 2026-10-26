using System;
using UnityEngine;
namespace CatchGoose
{
    // Low-frequency structural counters and a bounded frame ring. Device figures
    // originate on the phone; this is intentionally not a desktop FPS estimate.
    public sealed class GooseDeviceMonitor : MonoBehaviour
    {
        [Serializable] public class Sample
        {
            public string build=GooseRuntimePerformance.BuildId,platform,scene;public int width,height,total,visible,renderers,materialSlots,triangles,dynamicBodies,awakeBodies;
            public float fps,p95ms,physicsStep,prepareMs,interactiveMs,managedMiB,unityMiB,pickMaxMs;
            public int slowFrames,gcCollections;public bool cached;
            public int recoveringBodies,floorCorrections,visibilityChanges,protectedHideViolations,shakeAccepted;public bool shakeActive;
            public int surfaceBodies,exposureActivations,depthProbes,over100ms;
            public float depthMs,shuffleMs,shuffleMaxSliceMs;public bool shuffleActive;
        }
        readonly float[] frames=new float[120],sorted=new float[120];int cursor,count;
        GooseGame game;float next;bool requested;int gcBaseline;LevelDefinition lastLevel;
        public Sample Latest {get;private set;}
        public bool Requested=>requested;
        public void Initialize(GooseGame owner)
        {
            game=owner;
        }
        public void Toggle(){requested=!requested;next=0;cursor=count=0;gcBaseline=GC.CollectionCount(0);if(requested)Latest=null;}
        void Update()
        {
            bool enabled=requested||game.ReferenceTrial;
            if(!enabled||!game.Playing||game.Paused||game.Preparing||!game.SpawnComplete)return;
            if(lastLevel!=game.Level){lastLevel=game.Level;cursor=count=0;gcBaseline=GC.CollectionCount(0);}
            frames[cursor]=Time.unscaledDeltaTime*1000;cursor=(cursor+1)%frames.Length;count=Mathf.Min(count+1,frames.Length);
            if(Time.unscaledTime<next)return;next=Time.unscaledTime+1;
            var sample=new Sample{platform=Application.platform.ToString(),scene=game.Theme.id,width=Screen.width,height=Screen.height,
                total=game.Total,physicsStep=Time.fixedDeltaTime};
            float sum=0;for(int i=0;i<count;i++){sum+=frames[i];sorted[i]=frames[i];}
            Array.Sort(sorted,0,count);sample.fps=count*1000/Mathf.Max(1,sum);sample.p95ms=sorted[(int)((count-1)*.95f)];
            for(int i=0;i<count;i++){if(frames[i]>50)sample.slowFrames++;if(frames[i]>100)sample.over100ms++;}
            sample.prepareMs=game.LastPrepareMs;sample.interactiveMs=game.InteractiveMs;sample.cached=game.LastOpeningCached;
            sample.managedMiB=GC.GetTotalMemory(false)/1048576f;sample.unityMiB=UnityEngine.Profiling.Profiler.GetTotalAllocatedMemoryLong()/1048576f;
            sample.gcCollections=GC.CollectionCount(0)-gcBaseline;sample.pickMaxMs=game.PickMaxMs;
            foreach(var item in game.Items)if(item&&!item.Picked&&item.gameObject.activeInHierarchy)
            {
                if(item.PhysicsRecoveryActive)sample.recoveringBodies++;sample.floorCorrections+=item.FloorCorrections;sample.visibilityChanges+=item.VisibilityChanges;sample.protectedHideViolations+=item.ProtectedHideViolations;
                if(!item.Body.isKinematic){sample.dynamicBodies++;if(!item.Body.IsSleeping())sample.awakeBodies++;}
                if(item.DepthVisible){sample.visible++;sample.renderers+=item.RenderCount;sample.materialSlots+=item.DrawSlots;sample.triangles+=item.Triangles;}
            }
            sample.shakeActive=game.Shake.Active;sample.shakeAccepted=game.Shake.Accepted;
            sample.surfaceBodies=game.Depth.SurfaceCount;sample.exposureActivations=game.Depth.ExposureActivations;
            sample.depthProbes=game.Depth.LastProbeCount;sample.depthMs=game.Depth.LastRefreshMs;
            sample.shuffleActive=game.SurfaceShuffle.Active;
            sample.shuffleMs=(float)game.SurfaceShuffle.LastPlanningMilliseconds;
            sample.shuffleMaxSliceMs=(float)game.SurfaceShuffle.MaxPlanningSliceMilliseconds;
            Latest=sample;
            Debug.Log("[GooseDevice] "+JsonUtility.ToJson(sample));
        }
    }
}
