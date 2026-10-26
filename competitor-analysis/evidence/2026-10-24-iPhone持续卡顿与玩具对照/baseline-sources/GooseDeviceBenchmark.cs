#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Unity.Profiling;
using UnityEngine;

namespace CatchGoose
{
    public sealed class GooseDeviceBenchmark : MonoBehaviour
    {
        [Serializable] class Row
        {
            public string theme, phase; public int total, visibleItems, renderers, drawSlots, triangles, dynamicBodies, sleeping;
            public long drawCalls, batches, setPass, submittedTriangles; public float frameP95Ms, frameMaxMs;
        }
        [Serializable] class Report
        {
            public string scope="Windows graphics player forced mobile profile; real rendering counters, not phone FPS";
            public bool passed; public List<Row> rows=new List<Row>(); public List<string> errors=new List<string>();
        }
        readonly Report report=new Report(); string output;
        ProfilerRecorder draws,batches,passes,triangles;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void Boot()
        { if(Array.IndexOf(Environment.GetCommandLineArgs(),"-gooseDeviceBench")>=0) new GameObject("DeviceBenchmark").AddComponent<GooseDeviceBenchmark>(); }
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;draws.Dispose();batches.Dispose();passes.Dispose();triangles.Dispose();}
        void Log(string message,string stack,LogType type)
        { if(type==LogType.Error||type==LogType.Exception||type==LogType.Assert)report.errors.Add(message+"\n"+stack); }
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();int index=Array.IndexOf(args,"-gooseDeviceOutput");output=args[index+1];Directory.CreateDirectory(output);
            GooseSave.IsQa=true;yield return null;
            draws=ProfilerRecorder.StartNew(ProfilerCategory.Render,"Draw Calls Count",1);
            batches=ProfilerRecorder.StartNew(ProfilerCategory.Render,"Batches Count",1);
            passes=ProfilerRecorder.StartNew(ProfilerCategory.Render,"SetPass Calls Count",1);
            triangles=ProfilerRecorder.StartNew(ProfilerCategory.Render,"Triangles Count",1);
            var game=GooseGame.Instance;
            foreach(int theme in new[]{0,2,4})
            {
                game.GoHome();game.SelectTheme(theme);game.SelectDifficulty(2);game.BeginRound(false);
                float deadline=Time.realtimeSinceStartup+60;
                while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
                if(!game.SpawnComplete){report.errors.Add("Spawn deadline");break;}
                yield return new WaitForSeconds(2);
                yield return Sample(game,"settled");
                GooseFrameCapture.Save(Path.Combine(output,game.Theme.id+".png"));
                var item=game.Remaining.FirstOrDefault(i=>i.DepthVisible&&!i.Frozen);
                if(item)game.Pick(item);
                yield return Sample(game,"after-pick");
                Save();
            }
            game.GoHome();report.passed=report.errors.Count==0;Save();Application.Quit(report.passed?0:1);
        }
        IEnumerator Sample(GooseGame game,string phase)
        {
            var row=new Row{theme=game.Theme.id,phase=phase,total=game.Remaining.Count()};
            foreach(var item in game.Remaining)
            {
                if(!item.Body.isKinematic)row.dynamicBodies++;if(item.Body.IsSleeping())row.sleeping++;
                bool visible=false;
                foreach(var r in item.GetComponentsInChildren<MeshRenderer>())if(r.enabled)
                {
                    visible=true;row.renderers++;row.drawSlots+=r.sharedMaterials.Length;
                    var mesh=r.GetComponent<MeshFilter>().sharedMesh;
                    for(int i=0;i<mesh.subMeshCount;i++)row.triangles+=(int)mesh.GetIndexCount(i)/3;
                }
                if(visible)row.visibleItems++;
            }
            var frames=new List<float>(90);float end=Time.realtimeSinceStartup+2;
            while(Time.realtimeSinceStartup<end)
            {
                yield return null;frames.Add(Time.unscaledDeltaTime*1000);
                row.drawCalls=Math.Max(row.drawCalls,draws.LastValue);row.batches=Math.Max(row.batches,batches.LastValue);
                row.setPass=Math.Max(row.setPass,passes.LastValue);row.submittedTriangles=Math.Max(row.submittedTriangles,triangles.LastValue);
            }
            frames.Sort();row.frameP95Ms=frames[(int)((frames.Count-1)*.95)];row.frameMaxMs=frames.Last();
            report.rows.Add(row);
        }
        void Save(){File.WriteAllText(Path.Combine(output,"device-benchmark.json"),JsonUtility.ToJson(report,true));}
    }
}
#endif
