#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    public sealed class DuckB2GameplayAcceptance:MonoBehaviour
    {
        [Serializable] public class ItemResult
        {public string id,shader;public int generated,triangles,screenPicks,matched;public float trayWidthRatio,trayHeightRatio,trayCenterError;public bool metallicTextureRetained;}
        [Serializable] public class Report
        {
            public bool passed,mobileProfile,realGeneratorUsed=true,forcedVisibility=false,automatedPickBypass=false,formalProjectModified=false;
            public string scope="Isolated Windows development player built from a snapshot of the real game. Real generator/input/tray/match; not WeChat-device performance or five-theme review completion.";
            public int generated,removed,roundTrips;
            public string unityVersion;public List<ItemResult> items=new List<ItemResult>();
            public List<string> checks=new List<string>(),errors=new List<string>();
        }
        static readonly string[] Ids={"duck-eggtart","duck-steelcup","duck-numberblock"};
        readonly Report report=new Report();string output;bool finished;
        GooseGame game;string themesBefore,roundsBefore,saveBefore;int originalTheme,originalDifficulty;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]static void Early()
        {
            if(!Environment.GetCommandLineArgs().Contains("-duckGameplayQa"))return;
            GooseSave.IsQa=true;GooseSave.Sound=false;GooseSave.Onboarded=true;
        }
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-duckGameplayQa"))new GameObject("DuckB2Acceptance").AddComponent<DuckB2GameplayAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string message,string stack,LogType type)
        {if(type==LogType.Error||type==LogType.Exception||type==LogType.Assert)report.errors.Add(message);}
        void Check(bool ok,string name){(ok?report.checks:report.errors).Add(name);Debug.Log("[DuckB2QA] "+ok+" "+name);}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(150);if(!finished){report.errors.Add("150 second deadline");Finish();}}
        string ThemesJson()=>string.Join("\n",game.Themes.Select(t=>JsonUtility.ToJson(t)));
        string Saves()=>string.Join("\n",game.Themes.SelectMany(t=>new[]{0,1}.Select(s=>JsonUtility.ToJson(GooseSave.StoryBest(t.id,s)))))+"|"+GooseSave.Daily;
        void Capture(string name){GooseFrameCapture.Save(Path.Combine(output,name+".png"),Screen.width,Screen.height);}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-duckOutput");
            output=at>=0?args[at+1]:Path.Combine(Application.persistentDataPath,"duck-qa");Directory.CreateDirectory(output);
            StartCoroutine(Watchdog());yield return null;game=GooseGame.Instance;
            report.unityVersion=Application.unityVersion;report.mobileProfile=GooseRuntimePerformance.Mobile;
            Check(game!=null,"Actual GooseGame started");if(!game){Finish();yield break;}
            originalTheme=game.ThemeIndex;originalDifficulty=game.Difficulty;
            themesBefore=ThemesJson();roundsBefore=JsonUtility.ToJson(game.ThemeRounds);saveBefore=Saves();
            game.GoHome();game.SelectTheme(0);game.SelectDifficulty(1);
            game.Theme.items=(string[])Ids.Clone();game.Theme.itemWeights=null;game.Theme.groupWeights=null;game.Theme.coreGroupWeights=null;
            foreach(var profile in game.ThemeRounds.profiles.Where(p=>p.themeId==game.Theme.id))
            {
                profile.targetCount=0;profile.targetItem="";profile.seconds=600;profile.layers=3;
                profile.pileLayers=new[]{new PileLayerDefinition{normalCount=45,kinds=3,sourceHeight=10,candidateItems=(string[])Ids.Clone(),candidateWeights=new[]{1f,1f,1f}}};
            }
            game.BeginExperienceRound(130363);
            float deadline=Time.realtimeSinceStartup+60;while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
            Check(game.SpawnComplete,"Real production generator completes 45-duck round");
            if(!game.SpawnComplete){Finish();yield break;}
            yield return new WaitForSeconds(8);report.generated=game.Items.Count;
            Check(report.generated==45&&game.Items.All(i=>Ids.Contains(i.Id)),"Exactly 45 requested candidate objects spawned");
            Check(game.Items.All(i=>i.RenderCount==1&&i.DrawSlots==1),"Real game instances retain one renderer/material slot");
            Check(game.Items.All(i=>i.transform.position.y>-.4f&&Mathf.Abs(i.transform.position.x)<2.4f&&Mathf.Abs(i.transform.position.z-.88f)<2.4f),"Actual prepared pile retains all candidate bodies in container");
            Capture("game-pile");
            foreach(string id in Ids)
            {
                var initial=game.Items.Where(i=>i.Id==id&&!i.Picked).ToArray();
                var row=new ItemResult{id=id,generated=initial.Length,triangles=initial.FirstOrDefault()?.Triangles??0};report.items.Add(row);
                Check(initial.Length>=3&&initial.Length%3==0,id+" generated as complete triples");
                if(initial.Length==0)continue;
                var mat=initial[0].Renderers[0].sharedMaterial;row.shader=mat.shader.name;
                row.metallicTextureRetained=mat.HasProperty("_MetallicGlossMap")&&mat.GetTexture("_MetallicGlossMap");
                Check(row.shader=="Goose/DuckMobile"&&row.metallicTextureRetained,id+" metal/smoothness atlas survives real material cache");
                int removedBefore=game.Removed;
                for(int pick=0;pick<3;pick++)
                {
                    GooseItem selected=null;Vector2 pixel=default;float findDeadline=Time.realtimeSinceStartup+8;
                    do{selected=FindVisible(id,out pixel);if(!selected)yield return null;}while(!selected&&Time.realtimeSinceStartup<findDeadline);
                    Check(selected!=null,id+" visible screen-ray target "+(pick+1));if(!selected)break;
                    game.PickAtScreenPosition(pixel);
                    Check(selected.Picked,id+" real screen pickup "+(pick+1));if(!selected.Picked)break;row.screenPicks++;
                    yield return new WaitForSeconds(.8f);
                    if(pick==0)
                    {
                        Check(game.Presentation.Contains(selected),id+" actual mesh enters presentation tray");
                        row.trayCenterError=Vector2.Distance(game.Presentation.ScreenPosition(selected),game.Hud.TrayScreenPoint(0));
                        Check(row.trayCenterError<2,id+" tray center within two screen pixels");
                        var bounds=selected.VisualBounds;var points=new List<Vector3>();
                        for(int c=0;c<8;c++)points.Add(game.Presentation.Camera.WorldToScreenPoint(bounds.center+Vector3.Scale(bounds.extents,new Vector3((c&1)==0?-1:1,(c&2)==0?-1:1,(c&4)==0?-1:1))));
                        row.trayWidthRatio=(points.Max(v=>v.x)-points.Min(v=>v.x))/game.Hud.SlotScreenWidth;
                        row.trayHeightRatio=(points.Max(v=>v.y)-points.Min(v=>v.y))/game.Hud.SlotScreenWidth;
                        Check(row.trayWidthRatio<.88f&&row.trayHeightRatio<.88f,id+" complete silhouette fits one tray slot");
                        Capture(id+"-tray");
                    }
                }
                yield return new WaitForSeconds(.5f);row.matched=game.Removed-removedBefore;
                Check(row.screenPicks==3&&row.matched==3&&game.Tray.Entries.Count==0,id+" three real screen picks complete match and empty tray");
                Capture(id+"-matched");
            }
            report.removed=game.Removed;Check(report.removed==9,"All three candidate types matched through production input");
            // A second actual entry catches stale presentation/collider pool state.
            game.GoHome();game.SelectDifficulty(1);game.BeginExperienceRound(130364);
            deadline=Time.realtimeSinceStartup+60;while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
            Check(game.SpawnComplete&&game.Items.Count==45&&game.Tray.Entries.Count==0,"Repeated entry creates full fresh round with empty tray");
            report.roundTrips=2;yield return new WaitForSeconds(2);Capture("repeated-entry");
            Finish();
        }
        GooseItem FindVisible(string id,out Vector2 pixel)
        {
            pixel=default;if(game.Busy)return null;
            const int mask=~((1<<2)|(1<<8)|(1<<27)|(1<<28)|(1<<29)|(1<<30));
            foreach(var item in game.Items.Where(i=>i.Id==id&&!i.Picked&&i.DepthVisible&&!i.Frozen).OrderByDescending(i=>i.transform.position.y))
            {
                var b=item.VisualBounds;
                for(int k=0;k<27;k++)
                {
                    var p=b.center+Vector3.Scale(b.extents,new Vector3((k%3-1)*.7f,(k/3%3-1)*.7f,(k/9-1)*.7f));
                    var s=game.MainCamera.WorldToScreenPoint(p);if(!game.MainCamera.pixelRect.Contains(s))continue;
                    if(Physics.Raycast(game.MainCamera.ScreenPointToRay(s),out var hit,100,mask,QueryTriggerInteraction.Ignore)&&hit.collider.GetComponentInParent<GooseItem>()==item)
                    {pixel=s;return item;}
                }
            }
            return null;
        }
        void Finish()
        {
            if(finished)return;finished=true;
            if(game&&themesBefore!=null)
            {
                game.GoHome();var values=themesBefore.Split('\n');for(int i=0;i<game.Themes.Length;i++)JsonUtility.FromJsonOverwrite(values[i],game.Themes[i]);
                JsonUtility.FromJsonOverwrite(roundsBefore,game.ThemeRounds);game.SelectTheme(originalTheme);game.SelectDifficulty(originalDifficulty);
                Check(ThemesJson()==themesBefore&&JsonUtility.ToJson(game.ThemeRounds)==roundsBefore,"All five in-memory catalogs restored on exit");
                Check(game.ThemeIndex==originalTheme&&game.Difficulty==originalDifficulty,"Selected theme and stage restored on exit");
                Check(Saves()==saveBefore,"Story scores and daily attempts unchanged during candidate QA");
            }
            report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"acceptance.json"),JsonUtility.ToJson(report,true));
            Application.Quit(report.passed?0:1);
        }
    }
}
#endif
