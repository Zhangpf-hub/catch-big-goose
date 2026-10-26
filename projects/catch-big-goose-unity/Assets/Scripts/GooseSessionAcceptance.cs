#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    public sealed class GooseSessionAcceptance:MonoBehaviour
    {
        [Serializable] public class Phase
        {
            public string theme,name;public int frames,over50,over100,gc0,stock,shakes,pickCount;
            public float seconds,p95,max,mean,pickMaxMs;public long allocated,managed,totalMemory;
        }
        [Serializable] public class Opening {public string theme;public int stage;public bool cached;public float prepareMs,firstMs,interactiveMs,clickToReadyMs;}
        [Serializable] public class Floor {public string theme,worstId;public float beforeLate,rendered,physical;public bool held;}
        [Serializable] class Report
        {
            public bool passed;public string scope="Native production mobile 30 Hz; not phone FPS. Frame samples exclude screenshots. Mono per-thread allocation counter returned zero and is unavailable; use GC collections and memory snapshots.";
            public List<Opening> openings=new List<Opening>();public List<Phase> phases=new List<Phase>();public List<string> checks=new List<string>(),errors=new List<string>();
            public List<Floor> floors=new List<Floor>();
        }
        Report report=new Report();GooseGame game;string output;bool done;List<GoosePreparedLayouts.Layout> layouts=new List<GoosePreparedLayouts.Layout>();
        List<float> frames=new List<float>(20000);bool measuring;float phaseStart;long allocStart;int gcStart;Phase current;
        void Check(bool ok,string text){(ok?report.checks:report.errors).Add(text);}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string s,string stack,LogType t){if(t==LogType.Error||t==LogType.Exception)report.errors.Add(s+"\n"+stack);}
        void LateUpdate(){if(measuring&&!game.Paused)frames.Add(Time.unscaledDeltaTime*1000);}
        void Begin(string name)
        {current=new Phase{theme=game.Theme.id,name=name};frames.Clear();phaseStart=Time.realtimeSinceStartup;gcStart=GC.CollectionCount(0);allocStart=GC.GetAllocatedBytesForCurrentThread();measuring=true;}
        void End()
        {
            measuring=false;current.allocated=GC.GetAllocatedBytesForCurrentThread()-allocStart;current.gc0=GC.CollectionCount(0)-gcStart;
            current.seconds=Time.realtimeSinceStartup-phaseStart;current.frames=frames.Count;frames.Sort();
            if(frames.Count>0){current.p95=frames[(int)((frames.Count-1)*.95)];current.max=frames.Last();current.mean=frames.Average();current.over50=frames.Count(f=>f>50);current.over100=frames.Count(f=>f>100);}
            current.stock=game.Remaining.Count();current.managed=GC.GetTotalMemory(false);current.totalMemory=UnityEngine.Profiling.Profiler.GetTotalAllocatedMemoryLong();report.phases.Add(current);Save();
        }
        IEnumerator Start()
        {
            game=GooseGame.Instance;GooseSave.IsQa=true;var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-gooseSessionOutput");output=args[at+1];Directory.CreateDirectory(output);
            at=Array.IndexOf(args,"-gooseSoakSeconds");float soak=at>=0?float.Parse(args[at+1],System.Globalization.CultureInfo.InvariantCulture):30;
            StartCoroutine(Watchdog());yield return null;
            at=Array.IndexOf(args,"-gooseSessionThemes");int themes=at>=0?int.Parse(args[at+1]):game.Themes.Length;
            for(int theme=0;theme<themes;theme++)for(int stage=0;stage<2;stage++)
            {
                game.GoHome();game.SelectTheme(theme);game.SelectDifficulty(stage);game.Preparation.Cancel();var level=game.PrepareLevel();
                float clicked=Time.realtimeSinceStartup;game.Preparation.Request(game.Theme,level);float until=clicked+90;
                while(game.Preparation.State==GooseRoundPreparation.Status.Preparing&&Time.realtimeSinceStartup<until)yield return null;
                Check(game.Preparation.State==GooseRoundPreparation.Status.Ready,"prepare "+theme+"/"+stage);if(game.Preparation.State!=GooseRoundPreparation.Status.Ready){Finish();yield break;}
                layouts.Add(new GoosePreparedLayouts.Layout{theme=game.Theme.id,stage=stage,key=GoosePreparedLayouts.Key(game,game.Theme,level),itemScale=game.Preparation.ItemScale,
                    items=game.Preparation.Items.Select(i=>new GoosePreparedLayouts.Pose{id=i.Id,position=i.Body.position,rotation=i.Body.rotation,scale=i.transform.localScale}).ToArray()});
                File.WriteAllText(Path.Combine(output,"prepared-layouts.json"),JsonUtility.ToJson(new GoosePreparedLayouts{layouts=layouts.ToArray()}));
                float prepare=game.Preparation.PrepareMs;bool cached=game.Preparation.UsedBakedLayout;game.BeginRound(false);until=Time.realtimeSinceStartup+15;
                while(!game.SpawnComplete&&Time.realtimeSinceStartup<until)yield return null;
                Check(game.SpawnComplete,"opening "+theme+"/"+stage);Check(game.Items.Count==level.Total,"exact inventory "+theme+"/"+stage);
                for(int layer=0;layer<level.pileLayers.Length;layer++)
                    Check(game.Items.Count(i=>i.GenerationLayer==layer)==level.pileLayers[layer].normalCount+(layer==0?level.targetCount:0),"cached layer inventory "+theme+"/"+stage+"/"+layer);
                report.openings.Add(new Opening{theme=game.Theme.id,stage=stage,cached=cached,prepareMs=prepare,firstMs=game.FirstRevealMs,interactiveMs=game.InteractiveMs,clickToReadyMs=(Time.realtimeSinceStartup-clicked)*1000});
                if(Array.IndexOf(args,"-gooseRequireCache")>=0){Check(cached,"baked layout used "+theme+"/"+stage);Check(game.InteractiveMs<=1100,"warm opening within 1.1s "+theme+"/"+stage);}
                Save();
                if(stage==0)
                {
                    if(Array.IndexOf(args,"-gooseRequireCache")>=0)
                    {
                        float deadline=Time.realtimeSinceStartup+10;
                        while((game.Preparation.State!=GooseRoundPreparation.Status.Ready||game.Preparation.Items.Count!=300)&&Time.realtimeSinceStartup<deadline)yield return null;
                        Check(game.Preparation.State==GooseRoundPreparation.Status.Ready&&game.Preparation.UsedBakedLayout,"tutorial prepares cached challenge in background "+theme);
                    }
                    else yield return new WaitForSeconds(.3f);
                    continue;
                }
                Begin("idle-300");yield return new WaitForSeconds(6);End();
                Begin("shake-300");for(int s=0;s<6;s++){Check(game.Shake.Request(new Vector3(1,0,.35f)),"shake accepted "+theme+"/"+s);current.shakes++;yield return new WaitForSeconds(1.7f);}End();
                Begin("soak-300");float end=Time.realtimeSinceStartup+soak,nextShake=Time.time+8;
                while(Time.realtimeSinceStartup<end){if(Time.time>=nextShake){nextShake=Time.time+8;Check(game.Shake.Request(Vector3.right),"soak shake "+theme);current.shakes++;}yield return null;}End();
                Begin("rapid-matches");int before=game.Removed;int picked=0;
                for(int burst=0;burst<4;burst++)
                {
                    var groups=game.Remaining.GroupBy(i=>i.Id).Where(g=>g.Count()>=3).Take(6).Select(g=>g.Take(3).ToArray()).ToArray();
                    foreach(var item in groups.SelectMany(g=>g))
                    {
                        long start=System.Diagnostics.Stopwatch.GetTimestamp();bool ok=game.Pick(item,true);
                        current.pickMaxMs=Mathf.Max(current.pickMaxMs,(float)((System.Diagnostics.Stopwatch.GetTimestamp()-start)*1000d/System.Diagnostics.Stopwatch.Frequency));
                        Check(ok,"rapid pick "+theme+"/"+picked);picked++;current.pickCount++;yield return null;
                    }
                    yield return new WaitForSeconds(1);
                }
                Check(game.PendingMatches==0&&game.Removed==before+picked,"all concurrent triples commit "+theme);Check(!game.Busy,"input remains available "+theme);End();
                game.SetPaused(true);var poses=game.Remaining.ToDictionary(i=>i,i=>i.Body.position);yield return new WaitForSecondsRealtime(.3f);
                Check(poses.All(p=>Vector3.Distance(p.Key.Body.position,p.Value)<.0001f),"pause freezes physics "+theme);game.Resume();yield return new WaitForSeconds(1);
                var floor=new Floor{theme=game.Theme.id,beforeLate=game.Remaining.Min(i=>GooseColliderGeometry.MinY(i.SelectionCollider))};
                // Support corrections run in LateUpdate. Validate the pose that
                // is rendered, and retain the earlier probe for diagnosis.
                yield return new WaitForEndOfFrame();
                var worst=game.Remaining.OrderBy(i=>GooseColliderGeometry.MinY(i.SelectionCollider)).First();
                floor.rendered=GooseColliderGeometry.MinY(worst.SelectionCollider);floor.worstId=worst.Id;floor.held=worst.DepthHeld;
                floor.physical=game.Remaining.Min(i=>GooseColliderGeometry.MinY(i.SelectionCollider,GooseColliderGeometry.BodyMatrix(i.SelectionCollider,i.Body)));report.floors.Add(floor);
                Check(floor.rendered>=-.005f&&floor.physical>=-.005f,"floor after soak "+theme);
                Check(game.Remaining.All(i=>new Vector2(i.Body.position.x,i.Body.position.z-GooseCircularContainer.CenterZ).magnitude<game.Container.Radius+.1f),"containment after soak "+theme);
                GooseFrameCapture.Save(Path.Combine(output,game.Theme.id+"-after.png"));
                yield return new WaitForSeconds(1.5f);
                Check(game.Shake.Request(Vector3.right),"shake before cleanup "+theme);yield return new WaitForFixedUpdate();
                game.GoHome();Check(game.PendingMatches==0&&game.Items.Count==0,"cleanup during shake "+theme);
                game.SelectDifficulty(1);game.BeginRound(false);until=Time.realtimeSinceStartup+10;
                while(!game.SpawnComplete&&Time.realtimeSinceStartup<until)yield return null;
                Check(game.SpawnComplete&&game.LastOpeningCached,"warm restart completes "+theme);
                Check(game.Remaining.All(i=>i.SelectionCollider.sharedMaterial==game.ContactMaterial),"pooled materials restored after interrupted shake "+theme);
                Check(game.Remaining.Count()==300,"warm restart inventory "+theme);game.GoHome();Save();
            }
            game.GoHome();Finish();
        }
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(1500);if(!done){report.errors.Add("watchdog");Finish();}}
        void Save(){report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"session-acceptance.json"),JsonUtility.ToJson(report,true));}
        void Finish(){if(done)return;done=true;Save();Application.Quit(report.passed?0:1);}
    }
}
#endif
