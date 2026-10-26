#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    public sealed class GooseStoryAcceptance:MonoBehaviour
    {
        [Serializable] class Observation{public string theme;public int stage,total,types,picks,maxTray,tools,visible,insideViewport;public float spawnMs,normalPlaySeconds,minY,maxY;}
        [Serializable] class ItemState{public string id;public Vector3 position,size;public bool visible;public int layer;}
        [Serializable] class PileState{public Vector3 cameraPosition,cameraAngles;public float visibleThreshold;public ItemState[] items;}
        [Serializable] class LayerStock{public string theme;public int stage,layer;public string[] ids;public int[] counts;}
        [Serializable] class Report{public bool passed;public int rounds;public List<string> errors=new List<string>(),checks=new List<string>();public List<Observation> observations=new List<Observation>();public List<LayerStock> stocks=new List<LayerStock>();}
        readonly Report report=new Report();GooseGame game;string output;bool finished,shotsOnly,toysOnly,tutorialsOnly;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-storyQa"))new GameObject("StoryAcceptance").AddComponent<GooseStoryAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string msg,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception||type==LogType.Assert)report.errors.Add(msg);}
        void Check(bool ok,string label){(ok?report.checks:report.errors).Add(label);}
        void CheckUi(string label)
        {
            Canvas.ForceUpdateCanvases();var corners=new Vector3[4];
            foreach(var button in game.Hud.Frame.GetComponentsInChildren<UnityEngine.UI.Button>())
            {
                var rect=button.GetComponent<RectTransform>();rect.GetWorldCorners(corners);
                var points=corners.Select(p=>RectTransformUtility.WorldToScreenPoint(game.Hud.HudCamera,p)).ToArray();
                Check(points.All(p=>p.x>=-1&&p.x<=Screen.width+1&&p.y>=-1&&p.y<=Screen.height+1),label+": button inside safe screen "+button.name);
                Check(points.Max(p=>p.x)-points.Min(p=>p.x)>=43&&points.Max(p=>p.y)-points.Min(p=>p.y)>=43,label+": 44px touch target "+button.name);
            }
        }
        void Capture(string name){string file=Path.Combine(output,name+".png");Directory.CreateDirectory(Path.GetDirectoryName(file));GooseFrameCapture.Save(file,Screen.width,Screen.height);}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(900);if(!finished){report.errors.Add("900 second watchdog");Finish();}}
        bool ScreenPoint(GooseItem item,out Vector2 pixel)
        {
            var b=item.VisualBounds;pixel=default;if(!item.DepthVisible)return false;
            for(int i=0;i<27;i++)
            {
                var p=b.center+Vector3.Scale(b.extents,new Vector3((i%3-1)*.65f,(i/3%3-1)*.65f,(i/9-1)*.65f));var s=game.MainCamera.WorldToScreenPoint(p);
                if(s.z<=0||!game.MainCamera.pixelRect.Contains(s))continue;
                var hit=Physics.RaycastAll(game.MainCamera.ScreenPointToRay(s),100,~((1<<2)|(1<<8)|(1<<27)|(1<<28)|(1<<29)|(1<<30)),QueryTriggerInteraction.Ignore).OrderBy(h=>h.distance).FirstOrDefault();
                if(hit.collider&&hit.collider.GetComponentInParent<GooseItem>()==item){pixel=s;return true;}
            }
            return false;
        }
        IEnumerator WaitSpawn(){float until=Time.realtimeSinceStartup+120;while(!game.SpawnComplete&&game.Playing&&Time.realtimeSinceStartup<until)yield return null;Check(game.SpawnComplete,"Spawn completes");yield return new WaitForSeconds(.8f);}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-storyOutput")+1];shotsOnly=args.Contains("-storyShotsOnly");toysOnly=args.Contains("-storyToysOnly");tutorialsOnly=args.Contains("-storyTutorialsOnly");Directory.CreateDirectory(output);
            GooseSave.IsQa=true;StartCoroutine(Watchdog());yield return null;game=GooseGame.Instance;game.GoHome();
            if(args.Contains("-storySafeArea"))FindObjectOfType<GoosePhoneLayout>().SetPlatformSafeArea(new Rect(0,.04f,1,.91f));
            Check(game.Themes.Length==5,"Five two-stage themes");Check(game.Themes.Sum(t=>t.items.Length)==116,"116 source types");
            int barbecue=Array.FindIndex(game.Themes,t=>t.id=="barbecue");game.SelectTheme(barbecue);game.SelectDifficulty(0);yield return new WaitForSeconds(5);CheckUi("Home");Capture("barbecue-home");
            Check(game.HomeStage&&game.HomeStage.Camera.enabled,"Live 3D home camera active");game.HomeStage.React();
            if(!shotsOnly)for(int f=0;f<20;f++){Capture("animation/home-"+f.ToString("000"));yield return new WaitForSeconds(.1f);}
            var ids=new[]{barbecue}.Concat(Enumerable.Range(0,game.Themes.Length).Where(i=>i!=barbecue)).ToArray();
            if(toysOnly)ids=new[]{Array.FindIndex(game.Themes,t=>t.id=="toys")};
            foreach(int ti in ids)for(int stage=0;stage<2;stage++)
            {
                if(tutorialsOnly&&stage==1)continue;
                game.GoHome();game.SelectTheme(ti);game.SelectDifficulty(stage);var theme=game.Theme;int before=GooseSave.Daily;
                var level=game.SelectedLevel();var queue=level.MakeQueue(theme,new DeterministicRandom((uint)(104729+stage*50719+ti)));
                int cursor=level.targetCount;
                for(int l=0;l<level.pileLayers.Length;l++){var stock=queue.Skip(cursor).Take(level.pileLayers[l].normalCount).GroupBy(x=>x).ToArray();report.stocks.Add(new LayerStock{theme=theme.id,stage=stage+1,layer=l,ids=stock.Select(x=>x.Key).ToArray(),counts=stock.Select(x=>x.Count()).ToArray()});cursor+=level.pileLayers[l].normalCount;}
                game.InstantPicksForQa=false;game.BeginExperienceRound((uint)(104729+stage*50719+ti));yield return WaitSpawn();
                var items=game.Remaining.ToList();int expected=stage==0?15:300;
                Check(items.Count==expected,theme.id+"/"+(stage+1)+": expected stock");Check(items.GroupBy(i=>i.Id).All(g=>g.Count()%3==0),theme.id+": complete triples");
                Check(items.All(i=>float.IsFinite(i.transform.position.y)&&i.transform.position.y>-.5f),theme.id+": no floor escape");
                Check(GooseSave.Daily==before,theme.id+": QA does not consume player attempts");CheckUi(theme.id);Capture(theme.id+"-stage"+(stage+1));
                var obs=new Observation{theme=theme.id,stage=stage+1,total=items.Count,types=items.Select(i=>i.Id).Distinct().Count(),spawnMs=game.InteractiveMs,visible=items.Count(i=>i.DepthVisible),insideViewport=items.Count(i=>game.MainCamera.pixelRect.Contains(game.MainCamera.WorldToScreenPoint(i.VisualBounds.center))),minY=items.Min(i=>i.transform.position.y),maxY=items.Max(i=>i.transform.position.y)};report.observations.Add(obs);
                Check(items.Any(i=>i.DepthVisible&&game.MainCamera.pixelRect.Contains(game.MainCamera.WorldToScreenPoint(i.VisualBounds.center))),theme.id+": visible gameplay surfaces remain inside camera");
                var state=new PileState{cameraPosition=game.MainCamera.transform.position,cameraAngles=game.MainCamera.transform.eulerAngles,visibleThreshold=game.Depth.VisibleThreshold,items=items.Select(i=>new ItemState{id=i.Id,position=i.transform.position,size=i.VisualBounds.size,visible=i.DepthVisible,layer=i.Visual.gameObject.layer}).ToArray()};
                File.WriteAllText(Path.Combine(output,theme.id+"-stage"+(stage+1)+"-state.json"),JsonUtility.ToJson(state,true));Write();
                if(shotsOnly){report.rounds++;Write();continue;}
                float began=Time.realtimeSinceStartup;float playUntil=began+(stage==0?25:20);
                while(game.Playing&&Time.realtimeSinceStartup<playUntil&&game.Remaining.Any())
                {
                    GooseItem selected=null;Vector2 point=default;
                    var candidates=game.Remaining.OrderByDescending(i=>game.Tray.Entries.Any(t=>t.Id==i.Id)).ThenByDescending(i=>i.transform.position.y).ToArray();
                    foreach(var item in candidates)if(ScreenPoint(item,out point)){selected=item;break;}
                    if(!selected){yield return new WaitForSeconds(.3f);continue;}
                    game.PickAtScreenPosition(point);
                    if(ti==barbecue&&stage==0&&obs.picks<6)
                        for(int f=0;f<3;f++){Capture("animation/play-"+(obs.picks*3+f).ToString("000"));yield return new WaitForSeconds(.12f);}
                    else yield return new WaitForSeconds(.35f);
                    if(selected.Picked)obs.picks++;obs.maxTray=Mathf.Max(obs.maxTray,game.Tray.Entries.Count);
                    if(obs.picks==1&&selected.Picked)
                    {
                        float landingDeadline=Time.realtimeSinceStartup+1;
                        while(!game.Presentation.Arrived(new[]{selected})&&Time.realtimeSinceStartup<landingDeadline)yield return null;
                        Check(game.Presentation.Contains(selected),theme.id+": actual mesh arrives in tray");
                        Check(Vector2.Distance(game.Presentation.ScreenPosition(selected),game.Hud.TrayScreenPoint(0))<game.Hud.SlotScreenWidth*.12f,theme.id+": landing is centered in slot");
                        var b=selected.VisualBounds;float pixels=Mathf.Max(b.size.x,b.size.y)/(game.Presentation.Camera.orthographicSize*2/Screen.height);
                        Check(pixels<game.Hud.SlotScreenWidth*.86f,theme.id+": source item fits tray");Capture(theme.id+"-tray");
                    }
                    if(obs.maxTray>=6&&game.Tray.Entries.Count>=6&&game.Props[0]>0){game.UseProp(0);obs.tools++;yield return new WaitForSeconds(.5f);}
                }
                obs.normalPlaySeconds=Time.realtimeSinceStartup-began;Check(obs.picks>0,theme.id+": production screen taps at normal speed");if(stage==0)Check(obs.picks==expected,theme.id+": tutorial clears through production screen taps");Capture(theme.id+"-played-stage"+(stage+1));
                if(game.Playing){game.Pause();Capture(theme.id+"-pause");game.Resume();}
                // Restart to isolate complete-inventory traversal from the normal-speed pressure sample.
                game.BeginExperienceRound((uint)(104729+stage*50719+ti));yield return WaitSpawn();game.InstantPicksForQa=true;
                foreach(var group in game.Remaining.GroupBy(i=>i.Id).ToList())
                {foreach(var item in group.ToList())game.Pick(item,true);yield return null;}
                float finishUntil=Time.realtimeSinceStartup+8;while(game.Playing&&Time.realtimeSinceStartup<finishUntil)yield return null;
                Check(game.Removed==expected&&game.LastResult=="win",theme.id+"/"+(stage+1)+": full inventory clears");
                Check(stage==0?GooseSave.TutorialComplete(theme.id):GooseSave.ChallengeComplete(theme.id),theme.id+": per-theme progression saved");
                Capture(theme.id+"-result-stage"+(stage+1));report.rounds++;Write();
            }
            game.InstantPicksForQa=false;game.GoHome();Finish();
        }
        void Write(){File.WriteAllText(Path.Combine(output,"story-acceptance.json"),JsonUtility.ToJson(report,true));}
        void Finish(){finished=true;report.passed=report.rounds==(tutorialsOnly?5:toysOnly?2:10)&&report.errors.Count==0;Write();Application.Quit(report.passed?0:1);}
    }
}
#endif
