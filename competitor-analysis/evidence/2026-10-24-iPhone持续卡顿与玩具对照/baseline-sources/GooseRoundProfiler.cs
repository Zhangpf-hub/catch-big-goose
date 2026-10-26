using System;
using System.Collections.Generic;
using UnityEngine;
namespace CatchGoose
{
    // One bounded console sample per mobile round, suitable for actual device logs.
    public sealed class GooseRoundProfiler : MonoBehaviour
    {
        [Serializable] class Sample
        {
            public string theme, platform;
            public int total, frames, framesOver50ms, dynamicBodies, hidden, pooled;
            public float spawnWallMs, frameP95Ms, frameMaxMs, fixedStep;
            public double createTotalMs, createMaxMs;
            public long managedBytes;
        }
        GooseGame game;float began,spawn=-1;bool active;
        readonly List<float> frames=new List<float>(1024);
        public void Begin(GooseGame owner)
        {game=owner;began=Time.realtimeSinceStartup;spawn=-1;active=true;frames.Clear();GoosePerformanceCounters.Reset();}
        void LateUpdate()
        {
            if(!active||!game||!game.Playing||game.Paused)return;
            if(frames.Count<1024)frames.Add(Time.unscaledDeltaTime*1000);
            if(game.SpawnComplete&&spawn<0)spawn=Time.realtimeSinceStartup;
            if(spawn<0||Time.realtimeSinceStartup-spawn<5)return;
            active=false;frames.Sort();int slow=0;foreach(float frame in frames)if(frame>50)slow++;
            var row=new Sample{theme=game.Theme.id,platform=Application.platform.ToString(),total=game.Total,frames=frames.Count,
                framesOver50ms=slow,spawnWallMs=(spawn-began)*1000,frameP95Ms=frames[(int)((frames.Count-1)*.95)],frameMaxMs=frames[frames.Count-1],
                fixedStep=Time.fixedDeltaTime,dynamicBodies=game.Depth.DynamicCount,hidden=game.Depth.HiddenCount,pooled=game.PooledCount,
                createTotalMs=GoosePerformanceCounters.createMs,createMaxMs=GoosePerformanceCounters.createMaxMs,managedBytes=GC.GetTotalMemory(false)};
            Debug.Log("[GoosePerf] "+JsonUtility.ToJson(row));
        }
    }
}
