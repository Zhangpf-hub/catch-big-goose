#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;

namespace CatchGoose
{
    public sealed class GooseR4Acceptance : MonoBehaviour
    {
        [Serializable] public class Row
        {
            public string theme,background;public int stage,stock,remaining,accessible,shakes,containmentRecoveries;public uint seed;
            public float prepareMs,firstMs,interactiveMs,radius,targetRadius,minY,frameP95Ms,frameMaxMs;
            public long managedBytes,allocatedBytes;
        }
        [Serializable] public class Report
        {
            public string build=GooseRuntimePerformance.BuildId,scope="Native forced-mobile player, production animation and physics. Not a connected phone.";
            public bool passed;public List<string> checks=new List<string>(),errors=new List<string>();public List<Row> rounds=new List<Row>();
        }
        GooseGame game;string output;bool done,previousSound;readonly Report report=new Report();
        string caseSuffix="";bool recording;int seedCount=1;float watchdogSeconds=900;
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string text,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception||type==LogType.Assert)report.errors.Add(text+"\n"+stack);}
        void Check(bool ok,string text){(ok?report.checks:report.errors).Add(text);if(!ok)Debug.LogWarning("[R4Check] "+text);}
        IEnumerator Start()
        {
            game=GooseGame.Instance;GooseSave.IsQa=true;previousSound=GooseSave.Sound;GooseSave.Sound=true;
            var args=Environment.GetCommandLineArgs();int a=Array.IndexOf(args,"-gooseR4Output");
            output=a>=0?args[a+1]:Path.Combine(Application.persistentDataPath,"r4-qa");Directory.CreateDirectory(output);
            int si=Array.IndexOf(args,"-gooseR4Seeds");if(si>=0)seedCount=Mathf.Clamp(int.Parse(args[si+1]),1,10);
            watchdogSeconds=900*seedCount;StartCoroutine(Watchdog());yield return null;
            int themeCount=Array.IndexOf(args,"-gooseR4Smoke")>=0?1:game.Themes.Length;
            int firstTheme=0;int ti=Array.IndexOf(args,"-gooseR4Theme");if(ti>=0)firstTheme=int.Parse(args[ti+1]);
            for(int theme=firstTheme;theme<Mathf.Min(game.Themes.Length,firstTheme+themeCount);theme++)for(int stage=0;stage<2;stage++)for(int sample=0;sample<seedCount;sample++)
            {
                game.GoHome();game.SelectTheme(theme);game.SelectDifficulty(stage);yield return null;
                var level=game.PrepareLevel();level.seed+=(uint)(sample*7919);caseSuffix=sample==0?"":"-seed"+sample;
                string key=GooseRoundPreparation.MakeKey(game.Theme,level);
                game.Preparation.Request(game.Theme,level);
                float until=Time.realtimeSinceStartup+100;
                while(game.Preparation.Key==key&&game.Preparation.State==GooseRoundPreparation.Status.Preparing&&Time.realtimeSinceStartup<until)yield return null;
                Check(game.Preparation.State==GooseRoundPreparation.Status.Ready,game.Theme.id+" ready before start");
                if(game.Preparation.State!=GooseRoundPreparation.Status.Ready){Finish();yield break;}
                var row=new Row{theme=game.Theme.id,stage=stage+1,stock=level.Total,seed=level.seed,prepareMs=game.Preparation.PrepareMs,background=game.Theme.background};
                if(Array.IndexOf(args,"-gooseR4Record")>=0)
                {recording=true;StartCoroutine(RecordFrames(Path.Combine(output,"frames-"+row.theme+"-stage"+row.stage+caseSuffix)));}
                game.BeginExperienceRound(level.seed);until=Time.realtimeSinceStartup+10;
                var heights=new Dictionary<GooseItem,float>();float last=float.NegativeInfinity;
                while(!game.SpawnComplete&&Time.realtimeSinceStartup<until)
                {
                    foreach(var item in game.Items.Where(i=>i.DepthVisible&&!heights.ContainsKey(i)).OrderBy(i=>i.transform.position.y))
                    {Check(item.transform.position.y+.001f>=last,"Ascending reveal "+row.theme+" "+heights.Count);last=item.transform.position.y;heights[item]=last;}
                    yield return null;
                }
                Check(game.SpawnComplete,"Opening completed "+row.theme+"/"+row.stage);
                row.firstMs=game.FirstRevealMs;row.interactiveMs=game.InteractiveMs;
                Check(row.firstMs>=0&&row.firstMs<=1000,"Warm first reveal <=1s "+row.theme+"/"+row.stage);
                Check(row.interactiveMs<=2000,"Warm interactive <=2s "+row.theme+"/"+row.stage);
                Check(game.Items.Count==level.Total,"Prepared stock conserved "+row.theme);
                Check(game.Hud.Background.sprite&&game.Hud.Background.sprite.name==row.theme+"-r4","Theme background applied "+row.theme);
                Check(game.Container&&Mathf.Abs(game.Container.Radius-1.72f)<.001f,"Circular initial boundary "+row.theme);
                var plate=game.Container.transform.Find("CircularVisual");
                var initialPlateBounds=GooseGame.BoundsOf(plate.gameObject);
                var initialRim=game.Container.transform.Find("VisibleRim_0").position;
                var initialView=game.MainCamera.transform.rotation;
                yield return new WaitForSeconds(.8f);
                row.managedBytes=GC.GetTotalMemory(false);row.allocatedBytes=UnityEngine.Profiling.Profiler.GetTotalAllocatedMemoryLong();
                Capture(row.theme+"-stage"+row.stage+"-opening.png");
                Snapshot(row.theme+"-stage"+row.stage+"-opening-state.json");
                row.minY=game.Remaining.Min(SupportY);
                Check(row.minY>=GooseCircularContainer.FloorY-.04f,"Bottom collision support "+row.theme+"/"+row.stage);
                var groups=game.Remaining.GroupBy(i=>i.Id).Where(g=>g.Count()>=3).Take(2).Select(g=>g.Take(3).ToArray()).ToArray();
                int before=game.Removed;
                foreach(var item in groups[0]){item.SetDepthVisible(true);Check(game.Pick(item),"First triple accepted "+row.theme);}
                Check(game.PendingMatches==1&&!game.Busy,"Match does not lock input "+row.theme);
                foreach(var item in groups[1]){item.SetDepthVisible(true);Check(game.Pick(item),"Concurrent triple accepted "+row.theme);}
                Check(game.PendingMatches==2,"Two independent match batches "+row.theme);
                // Production animations use scaled game time. Keep the same
                // clock for transaction completion, with a real-time watchdog;
                // unscaled frame samples still expose any slow rendering.
                var frames=new List<float>();float end=Time.time+1.1f,deadline=Time.realtimeSinceStartup+4;
                while(Time.time<end&&Time.realtimeSinceStartup<deadline){frames.Add(Time.unscaledDeltaTime*1000);yield return null;}
                Check(game.Removed==before+6,"Concurrent triples commit exactly once "+row.theme);
                Check(game.PendingMatches==0&&groups.SelectMany(g=>g).All(i=>!game.Presentation.Contains(i)),"Concurrent animation releases entries "+row.theme);
                frames.Sort();row.frameP95Ms=frames[(int)((frames.Count-1)*.95f)];row.frameMaxMs=frames.Last();
                var positions=game.Remaining.ToDictionary(i=>i,i=>i.Body.position);
                int shakes=game.Shake.Accepted;
                Check(game.Shake.Request(new Vector3(1,0,.4f)),"Free physical shake accepted "+row.theme);
                Check(!game.Shake.Request(Vector3.right),"Shake cooldown "+row.theme);
                yield return new WaitForSeconds(.06f);
                Check(game.GetComponents<AudioSource>().Any(s=>!s.loop&&s.isPlaying),"Accepted shake plays SFX "+row.theme);
                yield return new WaitForSeconds(.9f);
                Check(game.Shake.Accepted==shakes+1,"Shake counted once "+row.theme);
                Check(positions.Any(p=>Vector3.Distance(p.Key.Body.position,p.Value)>.03f),"Shake moves physical pile "+row.theme);
                Check(game.Remaining.Count()==positions.Count,"Shake preserves inventory "+row.theme);
                game.Shake.ResetSensor();float ts=Time.unscaledTime;int count=game.Shake.Accepted;
                for(int j=0;j<20;j++)game.Shake.Sample(new Vector3(0,0,1),ts+j*.06f);
                Check(game.Shake.Accepted==count,"Stationary phone does not shake "+row.theme);
                game.Shake.Sample(new Vector3(3,0,1),ts+1.3f);game.Shake.Sample(new Vector3(-3,0,1),ts+1.4f);
                Check(game.Shake.Accepted==count+1,"Sensor burst reaches physics controller "+row.theme);
                yield return new WaitForSeconds(.9f);
                // Controlled inventory fixture exercises real animation; selection
                // visibility is measured separately below through actual screen rays.
                int keep=Array.IndexOf(args,"-gooseR4Keep3")>=0?3:level.Total>30?18:Mathf.Max(3,level.Total-6);
                while(game.Remaining.Count()>keep&&game.Playing)
                {
                    var triple=game.Remaining.GroupBy(i=>i.Id).FirstOrDefault(g=>g.Count()>=3)?.Take(3).ToArray();
                    if(triple==null)break;
                    foreach(var item in triple){item.SetDepthVisible(true);Check(game.Pick(item),"Bulk match reservation "+row.theme);}
                    yield return new WaitForSeconds(.05f);
                }
                yield return new WaitForSeconds(2.5f);
                game.Depth.RefreshNow();
                row.remaining=game.Remaining.Count();row.radius=game.Container.Radius;row.targetRadius=game.Container.TargetRadius;row.shakes=game.Shake.Accepted;
                row.accessible=Accessible();
                row.containmentRecoveries=game.Container.ContainmentRecoveries;
                if(row.accessible==0)
                {
                    foreach(var item in game.Remaining.Take(3))
                    {
                        var ray=game.MainCamera.ScreenPointToRay(game.MainCamera.WorldToScreenPoint(item.VisualBounds.center));
                        bool hit=Physics.Raycast(ray,out var h,100,~((1<<2)|(1<<27)|(1<<28)|(1<<29)|(1<<30)),QueryTriggerInteraction.Ignore);
                        Debug.Log($"[R4RayProbe] {item.Id} visible={item.DepthVisible} colliderEnabled={item.SelectionCollider.enabled} layer={item.gameObject.layer} scene={item.gameObject.scene.name} body={item.Body.position} visual={item.VisualBounds.center} hit={(hit?h.collider.name:"none")} layer={(hit?h.collider.gameObject.layer:-1)}");
                    }
                }
                Check(row.radius<1.72f-.05f,"Playable pile boundary contracts "+row.theme+"/"+row.stage);
                var finalPlateBounds=GooseGame.BoundsOf(plate.gameObject);
                Check(Vector3.Distance(plate.localScale,Vector3.one)<.0001f,"Plate keeps original scale "+row.theme+"/"+row.stage);
                Check(Vector3.Distance(initialPlateBounds.size,finalPlateBounds.size)<.0001f&&Vector3.Distance(initialPlateBounds.center,finalPlateBounds.center)<.0001f,"Authored plate silhouette and floor stay fixed "+row.theme+"/"+row.stage);
                Check(Vector3.Distance(initialRim,game.Container.transform.Find("VisibleRim_0").position)<.0001f,"Visible rim follows fixed plate "+row.theme+"/"+row.stage);
                Check(Quaternion.Angle(initialView,game.MainCamera.transform.rotation)<.01f,"Plate camera angle stays fixed "+row.theme+"/"+row.stage);
                Check(Mathf.Abs(row.radius-row.targetRadius)<.02f,"Boundary reaches target without jump "+row.theme);
                Check(game.Remaining.All(i=>SupportY(i)>=GooseCircularContainer.FloorY-.045f),"No below-floor pieces after shrink/shake "+row.theme);
                Check(game.Remaining.All(i=>new Vector2(i.Body.position.x,i.Body.position.z-GooseCircularContainer.CenterZ).magnitude<game.Container.Radius+.1f),"No escaped stock "+row.theme);
                Check(game.Remaining.All(i=>i.DepthVisible&&!i.DepthHeld&&!i.Body.isKinematic),"Sparse pile uses visible physical supports "+row.theme);
                Check(row.accessible>0,"Late pile has physically selectable objects "+row.theme);
                Capture(row.theme+"-stage"+row.stage+"-contracted.png");
                Snapshot(row.theme+"-stage"+row.stage+"-contracted-state.json");
                report.rounds.Add(row);Save();
                recording=false;yield return null;
                game.SetPaused(true);Check(!game.Shake.Request(Vector3.right),"Pause rejects shake "+row.theme);game.Resume();
                var remaining=game.Remaining.FirstOrDefault();if(remaining){remaining.SetDepthVisible(true);game.Pick(remaining);}
                game.GoHome();Check(game.Items.Count==0&&game.PendingMatches==0,"Home cancels in-flight transactions "+row.theme);
                Check(game.Hud.Background.sprite&&game.Hud.Background.sprite.name==game.Theme.id+"-v1","Theme home background restored "+row.theme);
            }
            Finish();
        }
        int Accessible()
        {
            int count=0;
            foreach(var item in game.Remaining)
            {
                if(!item.DepthVisible)continue;
                var b=item.VisualBounds;Vector3 c=game.MainCamera.WorldToScreenPoint(b.center);
                float dx=game.MainCamera.WorldToScreenPoint(b.center+Vector3.right*b.extents.x).x-c.x;
                float dy=Mathf.Abs(game.MainCamera.WorldToScreenPoint(b.center+Vector3.forward*b.extents.z).y-c.y);
                int hits=0;
                for(int y=-2;y<=2;y++)for(int x=-2;x<=2;x++)
                {
                    Vector2 p=new Vector2(c.x+dx*x*.35f,c.y+dy*y*.35f);
                    if(!game.MainCamera.pixelRect.Contains(p))continue;
                    if(Physics.Raycast(game.MainCamera.ScreenPointToRay(p),out var hit,100,~((1<<2)|(1<<27)|(1<<28)|(1<<29)|(1<<30)),QueryTriggerInteraction.Ignore)&&hit.collider.GetComponentInParent<GooseItem>()==item)hits++;
                }
                if(hits>=3)count++;
            }
            return count;
        }
        static float SupportY(GooseItem item)
        {
            // Rotated broadphase AABBs can extend below an actually supported
            // convex hull. Query the real convex support, not its box corners.
            return GooseColliderGeometry.MinY(item.SelectionCollider);
        }
        [Serializable]class ItemState
        {public string id,name,scene;public Vector3 position,scale,visualCenter,visualSize,colliderCenter,colliderSize,velocity;public bool held,visible,colliderEnabled,kinematic,sleeping,penetratingFloor;public int layer;public float support,penetrationDepth;}
        [Serializable]class PileState
        {public bool wallsIgnoreItems;public List<ItemState> items=new List<ItemState>();public List<string> otherRenderers=new List<string>(),cameras=new List<string>();}
        void Snapshot(string name)
        {
            var state=new PileState{wallsIgnoreItems=Physics.GetIgnoreLayerCollision(0,2)};
            foreach(var item in game.Remaining)
            {
                var v=item.VisualBounds;var b=item.SelectionCollider.bounds;
                var floor=game.Container.transform.Find("ContinuousFloor").GetComponent<BoxCollider>();
                bool penetrating=Physics.ComputePenetration(item.SelectionCollider,item.transform.position,item.transform.rotation,floor,floor.transform.position,floor.transform.rotation,out var direction,out float depth);
                state.items.Add(new ItemState{id=item.Id,name=item.name,scene=item.gameObject.scene.name,position=item.Body.position,scale=item.transform.lossyScale,visualCenter=v.center,visualSize=v.size,colliderCenter=b.center,colliderSize=b.size,velocity=item.Body.isKinematic?Vector3.zero:item.Body.velocity,held=item.DepthHeld,visible=item.DepthVisible,colliderEnabled=item.SelectionCollider.enabled,layer=item.gameObject.layer,support=SupportY(item),kinematic=item.Body.isKinematic,sleeping=item.Body.IsSleeping(),penetratingFloor=penetrating,penetrationDepth=depth});
            }
            foreach(var renderer in FindObjectsOfType<Renderer>())if(renderer.enabled&&!renderer.GetComponentInParent<GooseItem>())
                state.otherRenderers.Add(renderer.name+" layer="+renderer.gameObject.layer+" pos="+renderer.bounds.center+" size="+renderer.bounds.size);
            foreach(var camera in FindObjectsOfType<Camera>())state.cameras.Add(camera.name+" enabled="+camera.enabled+" mask="+camera.cullingMask+" rect="+camera.rect);
            File.WriteAllText(Path.Combine(output,Path.GetFileNameWithoutExtension(name)+caseSuffix+".json"),JsonUtility.ToJson(state,true));
        }
        void Capture(string name){GooseFrameCapture.Save(Path.Combine(output,Path.GetFileNameWithoutExtension(name)+caseSuffix+".png"));}
        IEnumerator RecordFrames(string directory)
        {
            Directory.CreateDirectory(directory);int frame=0;
            while(recording){GooseFrameCapture.Save(Path.Combine(directory,(frame++).ToString("D5")+".png"));yield return new WaitForSecondsRealtime(.125f);}
        }
        void Save(){report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"r4-acceptance.json"),JsonUtility.ToJson(report,true));}
        void Finish(){if(done)return;done=true;GooseSave.Sound=previousSound;Save();Debug.Log($"[R4QA] {report.checks.Count} checks; {report.errors.Count} errors");Application.Quit(report.passed?0:1);}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(watchdogSeconds);if(!done){report.errors.Add("R4 QA timeout");Finish();}}
    }
}
#endif
