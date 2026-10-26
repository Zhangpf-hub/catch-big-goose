#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    public sealed class GiraffeModelAcceptance:MonoBehaviour
    {
        [Serializable] sealed class Report{public bool passed;public int sleepers;public float maxSettledSpeed;public List<string> checks=new List<string>(),errors=new List<string>();}
        readonly Report report=new Report();string output;bool finished;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-giraffeQa"))new GameObject("GiraffeAcceptance").AddComponent<GiraffeModelAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string message,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception||type==LogType.Assert)report.errors.Add(message);}
        void Check(bool ok,string message){(ok?report.checks:report.errors).Add(message);}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(120);if(!finished){report.errors.Add("120 second deadline");Finish();}}
        void Capture(string name){GooseFrameCapture.Save(Path.Combine(output,name+".png"),Screen.width,Screen.height);}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-giraffeOutput");output=args[at+1];Directory.CreateDirectory(output);StartCoroutine(Watchdog());
            GooseSave.IsQa=true;yield return null;var game=GooseGame.Instance;game.GoHome();
            var cache=new GooseAssetCache();yield return cache.Prepare("giraffe",true);
            var arena=new GameObject("GiraffePhysicsArena");var bodies=new List<Rigidbody>();
            foreach(var pair in new[]{new[]{new Vector3(20,-.2f,0),new Vector3(5,.4f,5)},new[]{new Vector3(17.4f,2,0),new Vector3(.4f,4,5.6f)},new[]{new Vector3(22.6f,2,0),new Vector3(.4f,4,5.6f)},new[]{new Vector3(20,2,-2.6f),new Vector3(5.6f,4,.4f)},new[]{new Vector3(20,2,2.6f),new Vector3(5.6f,4,.4f)}})
            {var wall=new GameObject("ArenaWall");wall.transform.SetParent(arena.transform);wall.transform.position=pair[0];wall.AddComponent<BoxCollider>().size=pair[1];}
            UnityEngine.Random.InitState(1024);
            for(int i=0;i<45;i++)
            {
                var root=new GameObject("GiraffeTest"+i);root.transform.SetParent(arena.transform);cache.Instantiate("giraffe",root.transform);
                root.transform.position=new Vector3(18.45f+(i%5)*.77f,1.0f+(i/15)*1.1f,-.9f+(i/5%3)*.9f);root.transform.rotation=UnityEngine.Random.rotationUniform;root.transform.localScale=Vector3.one*.64f;
                var col=root.AddComponent<MeshCollider>();col.sharedMesh=cache.Hull("giraffe");col.convex=true;
                var body=root.AddComponent<Rigidbody>();body.collisionDetectionMode=GooseRuntimePerformance.DynamicCollision;body.angularDrag=.3f;bodies.Add(body);
            }
            yield return new WaitForSeconds(15);
            report.sleepers=bodies.Count(b=>b.IsSleeping());report.maxSettledSpeed=bodies.Max(b=>b.velocity.magnitude);
            Check(bodies.All(b=>b.position.y>-.2f&&b.position.y<5&&Mathf.Abs(b.position.x-20)<2.5f&&Mathf.Abs(b.position.z)<2.5f),"45 dynamic giraffes remain inside arena");
            Check(report.sleepers>=40,"At least 40/45 bodies naturally sleep after 15 seconds");Check(report.maxSettledSpeed<.15f,"Settled speed below 0.15 m/s");
            var rayTarget=bodies.OrderByDescending(b=>b.position.y).First();var oldPos=rayTarget.position;
            Check(Physics.Raycast(new Ray(oldPos+Vector3.up*5,Vector3.down),out var hit,10)&&hit.rigidbody!=null,"Dense pile ray hits an actual body");
            Destroy(rayTarget.gameObject);yield return new WaitForSeconds(5);
            Check(bodies.Where(b=>b).All(b=>b.position.y>-.2f),"Removing a support does not leak remaining bodies through floor");Destroy(arena);cache.Clear();yield return null;
            game.SelectTheme(0);game.SelectDifficulty(1);
            // A development-only catalog exercises the real production generator,
            // including its support placement and full-size collider settling.
            game.Theme.items=new[]{"giraffe","ref_apple","ref_orange"};game.Theme.itemWeights=null;game.Theme.groupWeights=null;game.Theme.coreGroupWeights=null;
            game.BeginExperienceRound(130363);
            float deadline=Time.realtimeSinceStartup+60;while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
            Check(game.SpawnComplete,"Real round spawned");
            var giraffes=game.Items.Where(i=>i.Id=="giraffe").ToList();
            Check(giraffes.Count>=3,"Production generator supplies complete giraffe triples");
            yield return new WaitForSeconds(8);Capture("in-game-pile");
            Check(giraffes.All(i=>i.transform.position.y>-.4f&&Mathf.Abs(i.transform.position.x)<2.4f&&Mathf.Abs(i.transform.position.z-.88f)<2.4f&&i.RenderCount==1&&i.DrawSlots==1),"Generated giraffes use one renderer/material and remain in real container");
            GooseItem selected=null;Vector2 pixel=Vector2.zero;
            foreach(var item in giraffes)
            {
                foreach(var filter in item.Visual.GetComponentsInChildren<MeshFilter>())
                {
                    // Rendering CPU copies may be released on mobile; sample the actual visible bounds instead.
                    var b=item.VisualBounds;
                    for(int k=0;k<27;k++)
                    {
                        var p=b.center+Vector3.Scale(b.extents,new Vector3((k%3-1)*.7f,(k/3%3-1)*.7f,(k/9-1)*.7f));var s=game.MainCamera.WorldToScreenPoint(p);
                        if(!game.MainCamera.pixelRect.Contains(s))continue;
                        var h=Physics.RaycastAll(game.MainCamera.ScreenPointToRay(s),100).OrderBy(v=>v.distance).FirstOrDefault(v=>v.collider.GetComponentInParent<GooseItem>());
                        if(h.collider&&h.collider.GetComponentInParent<GooseItem>()==item){selected=item;pixel=s;break;}
                    }
                    if(selected)break;
                }
                if(selected)break;
            }
            Check(selected!=null,"Giraffe can be found through a screen ray among actual props");
            if(selected)
            {
                selected.SetDepthVisible(true);game.PickAtScreenPosition(pixel);Check(selected.Picked,"Screen tap picks giraffe through production input");
                yield return new WaitForSeconds(.65f);Capture("in-game-tray");
                Check(game.Presentation.Contains(selected)&&Vector2.Distance(game.Presentation.ScreenPosition(selected),game.Hud.TrayScreenPoint(0))<2,"Actual giraffe mesh arrives at seven-slot tray");
                var bounds=selected.VisualBounds;float pixels=Mathf.Max(bounds.size.x,bounds.size.y)/(game.Presentation.Camera.orthographicSize*2/Screen.height);
                Check(pixels<game.Hud.SlotScreenWidth*.82f,"Long neck fits inside one tray slot");
                var others=giraffes.Where(i=>i!=selected).Take(2).ToArray();int removed=game.Removed;
                foreach(var item in others){Check(game.Pick(item,true),"Matching giraffe pickup accepted");yield return new WaitForSeconds(.7f);}
                yield return new WaitForSeconds(.4f);Check(game.Removed==removed+3,"Three actual giraffes complete production match");Capture("in-game-matched");
            }
            Finish();
        }
        void Finish(){finished=true;report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"acceptance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);}
    }
}
#endif
