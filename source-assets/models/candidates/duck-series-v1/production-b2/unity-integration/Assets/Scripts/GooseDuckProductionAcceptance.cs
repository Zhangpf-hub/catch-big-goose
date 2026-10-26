#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using UnityEngine;
using UnityEngine.UI;
namespace CatchGoose
{
    public sealed class GooseDuckProductionAcceptance:MonoBehaviour
    {
        [Serializable] public class ItemResult
        {public string id,shader;public int generated,triangles,screenPicks,matched;public float trayWidthRatio,trayHeightRatio,trayCenterError;public bool metallicTextureRetained;}
        [Serializable] public class MotionResult{public string action;public float maxVertexMotion;public int vertices;}
        [Serializable] public class Report
        {
            public bool passed,mobileProfile,realGeneratorUsed=true,forcedVisibility=false,automatedPickBypass=false;
            public string scope="Production-source Windows player: actual five-theme review menu, generation, screen-ray input, tray and matches; actual homepage bone animation and save isolation. Not WeChat device performance.";
            public string unityVersion;public int generated,removed,roundTrips,continuousHomeClicks;
            public List<ItemResult> items=new List<ItemResult>();public List<MotionResult> motions=new List<MotionResult>();
            public List<string> checks=new List<string>(),errors=new List<string>();
        }
        readonly Report report=new Report();string output;bool finished;GooseGame game;
        string themesBefore,roundsBefore,saveBefore;int originalTheme,originalDifficulty;int[] propsBefore,bonusesBefore;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]static void Early()
        {
            if(!Environment.GetCommandLineArgs().Contains("-duckSeriesQa"))return;
            GooseSave.IsQa=true;GooseSave.Sound=false;GooseSave.Onboarded=true;
        }
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-duckSeriesQa"))new GameObject("DuckSeriesAcceptance").AddComponent<GooseDuckProductionAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string message,string stack,LogType type)
        {if(type==LogType.Error||type==LogType.Exception||type==LogType.Assert)report.errors.Add(message);}
        void Check(bool ok,string name){(ok?report.checks:report.errors).Add(name);Debug.Log("[DuckSeriesQA] "+ok+" "+name);}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(420);if(!finished){report.errors.Add("420 second deadline");Finish();}}
        string ThemesJson()=>string.Join("\n",game.Themes.Select(t=>JsonUtility.ToJson(t)));
        int[] Bonuses()=>(int[])typeof(GooseGame).GetField("nextBonus",BindingFlags.Instance|BindingFlags.NonPublic).GetValue(game);
        string Saves()=>string.Join("\n",game.Themes.Select(t=>t.id+":"+GooseSave.StoryStage(t.id)+":"+GooseSave.TutorialComplete(t.id)+":"+GooseSave.ChallengeComplete(t.id)+":"+string.Join("|",new[]{0,1}.Select(s=>JsonUtility.ToJson(GooseSave.StoryBest(t.id,s))))))+"|"+GooseSave.Daily+"|"+GooseSave.Theme;
        void Capture(string name){GooseFrameCapture.Save(Path.Combine(output,name+".png"),Screen.width,Screen.height);}
        IEnumerator WaitHome()
        {float end=Time.realtimeSinceStartup+40;while((!game.HomeStage.Ready||!game.HomeStage.DuckMascot)&&Time.realtimeSinceStartup<end)yield return null;Check(game.HomeStage.Ready&&game.HomeStage.DuckMascot,"Homepage finishes loading actual B2 prefab");}
        IEnumerator Motion(string action,Action trigger,float seconds)
        {
            var mascot=game.HomeStage.DuckMascot;trigger();yield return null;var mesh=new Mesh();mascot.Skin.BakeMesh(mesh);var first=mesh.vertices;
            var row=new MotionResult{action=action,vertices=first.Length};float end=Time.realtimeSinceStartup+seconds;
            while(Time.realtimeSinceStartup<end)
            {
                yield return null;mascot.Skin.BakeMesh(mesh);var vs=mesh.vertices;
                for(int i=0;i<vs.Length;i++)row.maxVertexMotion=Mathf.Max(row.maxVertexMotion,Vector3.Distance(vs[i],first[i]));
            }
            report.motions.Add(row);Debug.Log("[DuckMotion] "+JsonUtility.ToJson(row));Check(row.maxVertexMotion>.002f,action+" moves actual skinned mesh vertices at runtime");Destroy(mesh);
        }
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-duckOutput");output=at>=0?args[at+1]:Path.Combine(Application.persistentDataPath,"duck-series-qa");Directory.CreateDirectory(output);
            StartCoroutine(Watchdog());yield return null;game=GooseGame.Instance;report.unityVersion=Application.unityVersion;report.mobileProfile=GooseRuntimePerformance.Mobile;
            Check(game!=null,"Production GooseGame started");if(!game){Finish();yield break;}
            game.GoHome();yield return WaitHome();if(!game.HomeStage.DuckMascot){Finish();yield break;}
            if(args.Contains("-duckReviewUiOnly")){yield return ReviewUiOnly();Finish();yield break;}
            var mascot=game.HomeStage.DuckMascot;Check(mascot.Skin.bones.Length>=9,"Homepage uses the approved B2 skeleton");
            Check(!GameObject.Find("ShibaMascotAnchor"),"Homepage display is replaced by B2 duck");
            yield return Motion("duck_greet",mascot.Greet,1.4f);Capture("home-greet-end");
            yield return Motion("duck_idle",()=>{},1.0f);Capture("home-idle");
            yield return Motion("duck_click",game.HomeStage.React,.65f);
            int initialClicks=mascot.ClickCount;
            for(int i=0;i<12;i++){game.HomeStage.React();yield return new WaitForSecondsRealtime(.045f);}
            Capture("home-continuous-click");yield return new WaitForSecondsRealtime(.9f);
            report.continuousHomeClicks=mascot.ClickCount-initialClicks;
            Check(report.continuousHomeClicks==12&&mascot.CurrentAction=="duck_idle","Twelve rapid clicks restart reaction and return to idle");
            int mascotInstance=mascot.GetInstanceID();game.SelectTheme(1);yield return WaitHome();
            Check(game.HomeStage.DuckMascot.GetInstanceID()==mascotInstance,"Theme change retains the same animated duck instance");Capture("home-theme-change");
            game.SelectTheme(2);game.SelectDifficulty(1);yield return WaitHome();
            originalTheme=game.ThemeIndex;originalDifficulty=game.Difficulty;themesBefore=ThemesJson();roundsBefore=JsonUtility.ToJson(game.ThemeRounds);
            propsBefore=(int[])game.Props.Clone();bonusesBefore=(int[])Bonuses().Clone();saveBefore=Saves();
            game.Hud.SendMessage("ShowStorySettings");yield return null;
            var entry=FindObjectsOfType<Button>().FirstOrDefault(b=>b.name=="DuckModelReview");Check(entry,"Settings exposes duck model review entry");
            if(!entry){Finish();yield break;}entry.onClick.Invoke();yield return null;Capture("review-menu");
            Check(FindObjectsOfType<Button>().Count(b=>b.name.StartsWith("DuckReviewTheme"))==5,"Review menu exposes all five themes");
            for(int themeIndex=0;themeIndex<5;themeIndex++)
            {
                if(themeIndex>0){game.Hud.ShowDuckReviewMenu();yield return null;}
                var button=FindObjectsOfType<Button>().Single(b=>b.name=="DuckReviewTheme"+themeIndex);button.onClick.Invoke();report.roundTrips++;
                float deadline=Time.realtimeSinceStartup+60;while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
                Check(game.SpawnComplete,"Review theme "+themeIndex+" generation completes");if(!game.SpawnComplete){Finish();yield break;}
                yield return new WaitForSeconds(4);var ids=game.Theme.items;report.generated+=game.Items.Count;
                Check(game.DuckReviewActive&&game.Items.Count==48&&game.Items.All(i=>ids.Contains(i.Id)),"Review theme "+themeIndex+" has exactly 48 ducks from its isolated catalog");
                Check(game.Items.All(i=>i.RenderCount==1&&i.DrawSlots==1),"Review theme "+themeIndex+" preserves one renderer and material per item");
                Capture("theme-"+themeIndex+"-pile");
                foreach(string id in ids)
                {
                    var initial=game.Items.Where(i=>i.Id==id&&!i.Picked).ToArray();var row=new ItemResult{id=id,generated=initial.Length,triangles=initial.FirstOrDefault()?.Triangles??0};report.items.Add(row);
                    Check(initial.Length==12,id+" has twelve generated instances");if(initial.Length==0)continue;
                    var mat=initial[0].Renderers[0].sharedMaterial;row.shader=mat.shader.name;row.metallicTextureRetained=mat.HasProperty("_MetallicGlossMap")&&mat.GetTexture("_MetallicGlossMap");
                    Check(row.triangles>=2000&&row.triangles<=4000&&row.shader=="Goose/DuckMobile"&&row.metallicTextureRetained,id+" runtime mesh budget and atlas material retained");
                    int removedBefore=game.Removed;
                    for(int pick=0;pick<3;pick++)
                    {
                        GooseItem selected=null;Vector2 pixel=default;float findDeadline=Time.realtimeSinceStartup+8;
                        do{selected=FindVisible(id,out pixel);if(!selected)yield return null;}while(!selected&&Time.realtimeSinceStartup<findDeadline);
                        Check(selected!=null,id+" visible screen target "+(pick+1));if(!selected)break;
                        game.PickAtScreenPosition(pixel);Check(selected.Picked,id+" actual screen pickup "+(pick+1));if(!selected.Picked)break;row.screenPicks++;
                        yield return new WaitForSeconds(.75f);
                        if(pick==0)
                        {
                            Check(game.Presentation.Contains(selected),id+" enters actual 3D tray");
                            row.trayCenterError=Vector2.Distance(game.Presentation.ScreenPosition(selected),game.Hud.TrayScreenPoint(0));
                            var b=selected.VisualBounds;var points=new List<Vector3>();
                            for(int c=0;c<8;c++)points.Add(game.Presentation.Camera.WorldToScreenPoint(b.center+Vector3.Scale(b.extents,new Vector3((c&1)==0?-1:1,(c&2)==0?-1:1,(c&4)==0?-1:1))));
                            row.trayWidthRatio=(points.Max(v=>v.x)-points.Min(v=>v.x))/game.Hud.SlotScreenWidth;row.trayHeightRatio=(points.Max(v=>v.y)-points.Min(v=>v.y))/game.Hud.SlotScreenWidth;
                            Check(row.trayCenterError<2&&row.trayWidthRatio<.88f&&row.trayHeightRatio<.88f,id+" fits one tray slot and its center");Capture(id+"-tray");
                        }
                    }
                    yield return new WaitForSeconds(.4f);row.matched=game.Removed-removedBefore;
                    Check(row.screenPicks==3&&row.matched==3&&game.Tray.Entries.Count==0,id+" three screen picks complete a match");
                }
                report.removed+=game.Removed;Capture("theme-"+themeIndex+"-matched");
                // Deliberate win/loss end probes verify persistence without claiming a full 48-item solve.
                game.EndRound(themeIndex%2==0,"QA persistence probe");
                Check(Saves()==saveBefore,"Review win/loss never changes official scores, attempts or stage progress");
                Check(ids.All(id=>!PlayerPrefs.HasKey("goose_unity_qa_story1_best_"+id+"_1")),"No item identifiers become story record keys");
                game.GoHome();yield return WaitHome();
                Check(!game.DuckReviewActive&&game.ThemeIndex==originalTheme&&game.Difficulty==originalDifficulty,"Review exit restores original theme and selected stage");
                Check(game.Props.SequenceEqual(propsBefore)&&Bonuses().SequenceEqual(bonusesBefore),"Review exit restores pending tools and reward state");
                Check(game.HomeStage.DuckMascot.GetInstanceID()==mascotInstance,"Review reentry retains homepage skeleton");
            }
            game.BeginDuckReview(0);report.roundTrips++;float repeatEnd=Time.realtimeSinceStartup+60;while(!game.SpawnComplete&&Time.realtimeSinceStartup<repeatEnd)yield return null;
            Check(game.SpawnComplete&&game.Items.Count==48&&game.Tray.Entries.Count==0,"Repeated review entry has a fresh pile and empty tray");
            game.GoHome();yield return WaitHome();yield return new WaitForSecondsRealtime(1.5f);Capture("home-restored");
            Check(game.HomeStage.DuckMascot.CurrentAction=="duck_idle","Returning home greets then resumes idle");
            Check(report.items.Count==20&&report.removed==60,"All twenty models complete real pickup/tray/match acceptance");Finish();
        }
        GooseItem FindVisible(string id,out Vector2 pixel)
        {
            pixel=default;if(game.Busy)return null;const int mask=~((1<<2)|(1<<8)|(1<<27)|(1<<28)|(1<<29)|(1<<30));
            foreach(var item in game.Items.Where(i=>i.Id==id&&!i.Picked&&i.DepthVisible&&!i.Frozen).OrderByDescending(i=>i.transform.position.y))
            {
                var b=item.VisualBounds;for(int k=0;k<27;k++)
                {
                    var p=b.center+Vector3.Scale(b.extents,new Vector3((k%3-1)*.7f,(k/3%3-1)*.7f,(k/9-1)*.7f));var s=game.MainCamera.WorldToScreenPoint(p);
                    if(!game.MainCamera.pixelRect.Contains(s))continue;
                    if(Physics.Raycast(game.MainCamera.ScreenPointToRay(s),out var hit,100,mask,QueryTriggerInteraction.Ignore)&&hit.collider.GetComponentInParent<GooseItem>()==item){pixel=s;return item;}
                }
            }
            return null;
        }
        IEnumerator ReviewUiOnly()
        {
            game.Hud.SendMessage("ShowStorySettings");yield return null;
            var entry=FindObjectsOfType<Button>().Single(b=>b.name=="DuckModelReview");entry.onClick.Invoke();yield return null;Capture("review-menu");
            FindObjectsOfType<Button>().Single(b=>b.name=="DuckReviewTheme2").onClick.Invoke();
            float end=Time.realtimeSinceStartup+60;while(!game.SpawnComplete&&Time.realtimeSinceStartup<end)yield return null;
            yield return new WaitForSeconds(2);
            Check(game.Hud.StageText.text=="评审·乡村小院","Review HUD shows the complete longest theme title");
            Check(game.Hud.StageText.preferredWidth<=game.Hud.StageText.rectTransform.rect.width,"Review HUD title fits without clipping");
            Capture("review-title");game.GoHome();
        }
        void Finish()
        {
            if(finished)return;finished=true;
            if(game&&themesBefore!=null)
            {
                if(game.DuckReviewActive)game.GoHome();
                Check(ThemesJson()==themesBefore&&JsonUtility.ToJson(game.ThemeRounds)==roundsBefore,"All five official catalogs remain unchanged");
                Check(Saves()==saveBefore,"Official theme selection, scores, stages and daily attempts preserved");
            }
            report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"acceptance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);
        }
    }
}
#endif
