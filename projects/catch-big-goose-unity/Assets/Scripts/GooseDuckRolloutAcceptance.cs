#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    // Uses the shipped story catalogs and production screen-ray picker.
    public sealed class GooseDuckRolloutAcceptance:MonoBehaviour
    {
        [Serializable]class Round{public string theme,target;public int stage,stock,ducks,removed;public bool cached;public float prepareMs,interactiveMs;}
        [Serializable]class Report{public bool passed,mobileProfile,requiredCache,forcedVisibility=false,automatedPickBypass=false;public List<Round> rounds=new List<Round>();public List<string> generatedDuckTypes=new List<string>(),matched=new List<string>(),checks=new List<string>(),errors=new List<string>();}
        readonly Report report=new Report();readonly List<GoosePreparedLayouts.Layout> layouts=new List<GoosePreparedLayouts.Layout>();GooseGame game;string output;bool done;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]static void Early(){if(!Environment.GetCommandLineArgs().Contains("-duckRolloutQa"))return;GooseSave.IsQa=true;GooseSave.Sound=false;GooseSave.Onboarded=true;}
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot(){if(Environment.GetCommandLineArgs().Contains("-duckRolloutQa"))new GameObject("DuckRolloutAcceptance").AddComponent<GooseDuckRolloutAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string message,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception||type==LogType.Assert)report.errors.Add(message);}
        void Check(bool ok,string text){(ok?report.checks:report.errors).Add(text);Debug.Log("[DuckRollout] "+ok+" "+text);}
        void Capture(string name){GooseFrameCapture.Save(Path.Combine(output,name+".png"));}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(360);if(!done){report.errors.Add("360 second deadline");Finish();}}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-duckOutput")+1];Directory.CreateDirectory(output);StartCoroutine(Watchdog());yield return null;
            game=GooseGame.Instance;report.mobileProfile=GooseRuntimePerformance.Mobile;report.requiredCache=args.Contains("-duckRequireCache");
            foreach(string theme in new[]{"breakfast","barbecue"})for(int stage=0;stage<2;stage++)
            {
                game.GoHome();game.SelectTheme(Array.FindIndex(game.Themes,t=>t.id==theme));game.SelectDifficulty(stage);game.Preparation.Cancel();
                var level=game.PrepareLevel();game.Preparation.Request(game.Theme,level);float deadline=Time.realtimeSinceStartup+60;
                while(game.Preparation.State==GooseRoundPreparation.Status.Preparing&&Time.realtimeSinceStartup<deadline)yield return null;
                Check(game.Preparation.State==GooseRoundPreparation.Status.Ready,theme+" stage "+stage+" preparation ready");if(game.Preparation.State!=GooseRoundPreparation.Status.Ready){Finish();yield break;}
                var row=new Round{theme=theme,stage=stage+1,target=level.targetItem,cached=game.Preparation.UsedBakedLayout,prepareMs=game.Preparation.PrepareMs};report.rounds.Add(row);
                if(report.requiredCache)Check(row.cached,theme+" stage "+stage+" uses new geometry cache");
                layouts.Add(new GoosePreparedLayouts.Layout{theme=theme,stage=stage,key=GoosePreparedLayouts.Key(game,game.Theme,level),itemScale=game.Preparation.ItemScale,
                    items=game.Preparation.Items.Select(i=>new GoosePreparedLayouts.Pose{id=i.Id,position=i.Body.position,rotation=i.Body.rotation,scale=i.transform.localScale}).ToArray()});
                File.WriteAllText(Path.Combine(output,"prepared-layouts.json"),JsonUtility.ToJson(new GoosePreparedLayouts{layouts=layouts.ToArray()}));
                game.BeginRound(false);deadline=Time.realtimeSinceStartup+30;while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
                Check(game.SpawnComplete,theme+" stage "+stage+" production spawn complete");if(!game.SpawnComplete){Finish();yield break;}
                yield return new WaitForSeconds(.8f);row.stock=game.Items.Count;row.interactiveMs=game.InteractiveMs;row.ducks=game.Items.Count(i=>i.Id.StartsWith("duck-"));
                Check(!game.DuckReviewActive&&!game.ReferenceTrial,theme+" is a formal story round");
                Check(row.stock==(stage==0?15:300)&&game.Level.seconds==(stage==0?0:600),theme+" original stock/time contract retained");
                Check(game.Items.All(i=>!i.Id.StartsWith("ref_goose_")),theme+" contains no replaced goose models");
                Check(game.Items.GroupBy(i=>i.Id).All(g=>g.Count()%3==0),theme+" inventory remains complete triples");
                var ducks=game.Items.Where(i=>i.Id.StartsWith("duck-")).ToArray();
                foreach(string id in ducks.Select(i=>i.Id).Distinct())if(!report.generatedDuckTypes.Contains(id))report.generatedDuckTypes.Add(id);
                Check(ducks.Length>0&&ducks.All(i=>i.RenderCount==1&&i.DrawSlots==1&&i.Renderers[0].sharedMaterial.shader.name=="Goose/DuckMobile"),theme+" actual duck geometry and atlas materials are present");
                if(stage==0)Check(row.target.StartsWith("duck-")&&ducks.Length==3,theme+" tutorial target is the corresponding duck");
                else Check(ducks.Select(i=>i.Id).Distinct().Count()==4,theme+" challenge generates all four duck types");
                Capture(theme+"-stage"+(stage+1));
                if(stage==0)
                {
                    float until=Time.realtimeSinceStartup+35;
                    while(game.Playing&&game.Remaining.Any()&&Time.realtimeSinceStartup<until)
                    {
                        GooseItem selected=null;Vector2 pixel=default;
                        foreach(var candidate in game.Remaining.OrderByDescending(i=>game.Tray.Entries.Any(t=>t.Id==i.Id)).ThenByDescending(i=>i.transform.position.y))
                            if(ScreenPoint(candidate,out pixel)){selected=candidate;break;}
                        if(!selected){yield return null;continue;}
                        game.PickAtScreenPosition(pixel);Check(selected.Picked,"Tutorial production screen tap "+selected.Id);yield return new WaitForSeconds(.4f);
                        if(selected.Id.StartsWith("duck-")&&game.Presentation.Contains(selected))Capture(selected.Id+"-tray");
                    }
                    float resolveEnd=Time.realtimeSinceStartup+3;while(game.PendingMatches>0&&Time.realtimeSinceStartup<resolveEnd)yield return null;
                    Check(game.Removed==15&&game.LastResult=="win",theme+" tutorial clears through real screen picks");
                    if(game.Removed==15)report.matched.Add(row.target);
                }
                else
                {
                    GooseItem selected=null;Vector2 pixel=default;
                    for(int attempt=0;attempt<4&&!selected;attempt++)
                    {
                        foreach(var candidate in game.Remaining.Where(i=>i.Id.StartsWith("duck-")).OrderByDescending(i=>i.transform.position.y))if(ScreenPoint(candidate,out pixel)){selected=candidate;break;}
                        if(!selected){game.Shake.Request(Vector3.right);yield return new WaitForSeconds(1.8f);}
                    }
                    Check(selected!=null,theme+" actual 300-item challenge exposes a duck screen target");
                    if(selected){game.PickAtScreenPosition(pixel);Check(selected.Picked,theme+" challenge duck picked through production screen ray");yield return new WaitForSeconds(.8f);Check(game.Presentation.Contains(selected),theme+" challenge duck enters actual tray");Capture(theme+"-challenge-duck-tray");}
                }
                row.removed=game.Removed;Capture(theme+"-played-stage"+(stage+1));
            }
            Check(report.generatedDuckTypes.Count==8,"All eight replacement models are generated by the formal challenge catalogs");
            Check(report.matched.Count==2,"Both duck tutorial targets complete real screen-input triples");game.GoHome();Finish();
        }
        IEnumerator Triple(string id)
        {
            int before=game.Removed;
            for(int n=0;n<3;n++)
            {
                GooseItem item=null;Vector2 point=default;
                for(int attempt=0;attempt<4&&!item;attempt++)
                {
                    float end=Time.realtimeSinceStartup+2;do{item=Visible(id,out point);if(!item)yield return null;}while(!item&&Time.realtimeSinceStartup<end);
                    if(!item&&game.Playing){game.Shake.Request(Vector3.right);yield return new WaitForSeconds(1.8f);}
                }
                Check(item!=null,id+" visible screen target "+n);if(!item){Finish();yield break;}
                game.PickAtScreenPosition(point);Check(item.Picked,id+" actual screen pickup "+n);if(!item.Picked){Finish();yield break;}
                yield return new WaitForSeconds(.55f);
                if(n==0){Check(game.Presentation.Contains(item),id+" reaches the production 3D tray");if(id.StartsWith("duck-"))Capture(id+"-tray");}
            }
            yield return new WaitForSeconds(.3f);Check(game.Removed==before+3&&game.Tray.Entries.Count==0,id+" commits three-item match");report.matched.Add(id);
        }
        GooseItem Visible(string id,out Vector2 point)
        {
            point=default;if(game.Busy)return null;
            foreach(var item in game.Remaining.Where(i=>i.Id==id&&i.DepthVisible&&!i.Frozen).OrderByDescending(i=>i.transform.position.y))
                if(ScreenPoint(item,out point))return item;
            return null;
        }
        bool ScreenPoint(GooseItem item,out Vector2 point)
        {
            point=default;if(game.Busy||!item.DepthVisible||item.Picked||item.Frozen)return false;const int mask=~((1<<2)|(1<<8)|(1<<27)|(1<<28)|(1<<29)|(1<<30));
            var b=item.VisualBounds;for(int k=0;k<27;k++){var p=b.center+Vector3.Scale(b.extents,new Vector3((k%3-1)*.7f,(k/3%3-1)*.7f,(k/9-1)*.7f));var s=game.MainCamera.WorldToScreenPoint(p);
                if(game.MainCamera.pixelRect.Contains(s)&&Physics.Raycast(game.MainCamera.ScreenPointToRay(s),out var hit,100,mask,QueryTriggerInteraction.Ignore)&&hit.collider.GetComponentInParent<GooseItem>()==item){point=s;return true;}}
            return false;
        }
        void Finish(){if(done)return;done=true;report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"acceptance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);}
    }
}
#endif
