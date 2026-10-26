#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    // Desktop instrumented comparison, deliberately not a phone FPS claim.
    public sealed class GoosePerformanceAcceptance : MonoBehaviour
    {
        [Serializable] class Sample { public string theme; public bool warm; public int stock, held, hidden, escaped, frames, over50ms, pooledBefore; public float spawnSeconds, frameP95ms, frameMaxMs, fixedStep; public double createMs, createMaxMs; }
        [Serializable] class Report { public string scope = "Windows development player, headless CPU/structural comparison; not WeChat or phone FPS"; public bool passed; public List<Sample> samples = new List<Sample>(); public List<string> errors = new List<string>(); }
        readonly Report report = new Report(); string output;
        void OnEnable() { Application.logMessageReceived += Log; }
        void OnDisable() { Application.logMessageReceived -= Log; }
        void Log(string msg,string stack,LogType type) { if(type==LogType.Error||type==LogType.Exception||type==LogType.Assert)report.errors.Add(msg+"\n"+stack); }
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-goosePerformanceOutput");output=args[at+1];Directory.CreateDirectory(output);
            GooseSave.IsQa=true; var game=GooseGame.Instance; yield return null;
            for(int theme=0;theme<game.Themes.Length;theme++) for(int repeat=0;repeat<2;repeat++)
            {
                game.GoHome();game.SelectTheme(theme);game.SelectDifficulty(2);
                int pooledBefore = game.PooledCount;
                GoosePerformanceCounters.Reset();float start=Time.realtimeSinceStartup;game.BeginRound(false);
                var frames=new List<float>();
                while(!game.SpawnComplete && Time.realtimeSinceStartup-start<90){yield return null;frames.Add(Time.unscaledDeltaTime*1000);}
                float spawn=Time.realtimeSinceStartup-start;
                float end=Time.realtimeSinceStartup+2;while(Time.realtimeSinceStartup<end){yield return null;frames.Add(Time.unscaledDeltaTime*1000);}
                frames.Sort();var stock=game.Remaining.ToList();
                var row=new Sample{theme=game.Theme.id,warm=repeat==1,pooledBefore=pooledBefore,stock=stock.Count,held=game.Depth.HeldCount,hidden=game.Depth.HiddenCount,
                    escaped=stock.Count(i=>!float.IsFinite(i.transform.position.y)||i.transform.position.y<-.5f),frames=frames.Count,over50ms=frames.Count(t=>t>50),
                    spawnSeconds=spawn,frameP95ms=frames[(int)((frames.Count-1)*.95)],frameMaxMs=frames.Last(),fixedStep=Time.fixedDeltaTime,
                    createMs=GoosePerformanceCounters.createMs,createMaxMs=GoosePerformanceCounters.createMaxMs};
                report.samples.Add(row);if(row.stock!=300||row.escaped!=0)report.errors.Add(row.theme+": inventory or containment");
                File.WriteAllText(Path.Combine(output,"performance.json"),JsonUtility.ToJson(report,true));
            }
            game.GoHome();report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"performance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);
        }
    }
}
#endif
