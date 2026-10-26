#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    public sealed class CompetitorReplacementAcceptance:MonoBehaviour
    {
        [Serializable] sealed class Report {public bool passed;public int rounds;public List<string> checks=new List<string>(),errors=new List<string>();}
        readonly Report report=new Report();string output;bool finished;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-competitorReplacementQa"))new GameObject("CompetitorReplacementQa").AddComponent<CompetitorReplacementAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string msg,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception||type==LogType.Assert)report.errors.Add(msg);}
        void Check(bool ok,string label){(ok?report.checks:report.errors).Add(label);}
        void Capture(string name){GooseFrameCapture.Save(Path.Combine(output,name+".png"),Screen.width,Screen.height);}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(360);if(!finished){report.errors.Add("360 second deadline");Finish();}}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-replacementOutput")+1];Directory.CreateDirectory(output);
            GooseSave.IsQa=true;StartCoroutine(Watchdog());yield return null;var game=GooseGame.Instance;game.GoHome();Capture("home");
            Check(game.Themes.Length==5,"Five scene entries installed");
            Check(game.Themes.SelectMany(t=>t.items).Distinct().Count()==80,"80 distinct source models in playable catalogs");
            for(int ti=0;ti<game.Themes.Length;ti++)
            {
                var theme=game.Themes[ti];Check(theme.items.All(id=>id.StartsWith("ref_")),theme.id+": no generated ordinary props in catalog");
                foreach(var id in theme.items)
                    Check(Resources.Load<GameObject>("Models/"+id+"/"+id)&&Resources.Load<Sprite>("Icons/"+id)&&Resources.Load<Mesh>("Physics/"+id),id+": model, icon and offline collider load");
                for(int difficulty=0;difficulty<3;difficulty++)
                {
                    game.GoHome();game.SelectTheme(ti);game.SelectDifficulty(difficulty);game.InstantPicksForQa=false;game.BeginExperienceRound((uint)(130363+ti*31+difficulty));
                    float deadline=Time.realtimeSinceStartup+60;while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
                    Check(game.SpawnComplete,theme.id+"/"+difficulty+": production spawn completes");
                    yield return new WaitForSeconds(2);var stock=game.Remaining.ToList();int expected=new[]{15,60,300}[difficulty];
                    Check(stock.Count==expected&&stock.GroupBy(i=>i.Id).All(g=>g.Count()%3==0),theme.id+"/"+difficulty+": stock and complete triples");
                    Check(stock.All(i=>float.IsFinite(i.transform.position.y)&&i.transform.position.y>-.5f&&Mathf.Abs(i.transform.position.x)<2.4f&&Mathf.Abs(i.transform.position.z-.88f)<2.4f),theme.id+"/"+difficulty+": all props contained");
                    Check(stock.All(i=>{int count=i.Id=="ref_gtplaydough"||i.Id=="ref_gtwatergame"?3:i.Id=="ref_gtkaleidoscope"||i.Id=="ref_gtracecar"||i.Id=="ref_gtringcandy"?2:1;return i.RenderCount==count&&i.DrawSlots==count;}),theme.id+"/"+difficulty+": source material groups within 1-3 draws per item");
                    if(difficulty==1)
                    {
                        Capture(theme.id+"-pile");GooseItem selected=null;Vector2 pixel=Vector2.zero;
                        foreach(var item in stock.Where(i=>i.DepthVisible))
                        {
                            var b=item.VisualBounds;
                            for(int k=0;k<27;k++)
                            {
                                var p=b.center+Vector3.Scale(b.extents,new Vector3((k%3-1)*.7f,(k/3%3-1)*.7f,(k/9-1)*.7f));var s=game.MainCamera.WorldToScreenPoint(p);
                                if(!game.MainCamera.pixelRect.Contains(s))continue;
                                var hit=Physics.RaycastAll(game.MainCamera.ScreenPointToRay(s),100).OrderBy(h=>h.distance).FirstOrDefault(h=>h.collider.GetComponentInParent<GooseItem>());
                                if(hit.collider&&hit.collider.GetComponentInParent<GooseItem>()==item){selected=item;pixel=s;break;}
                            }
                            if(selected)break;
                        }
                        Check(selected!=null,theme.id+": source prop found by actual screen ray");
                        if(selected)
                        {
                            game.PickAtScreenPosition(pixel);yield return new WaitForSeconds(.65f);
                            Check(selected.Picked&&game.Presentation.Contains(selected),theme.id+": real tap and animated tray arrival");
                            var b=selected.VisualBounds;float pixels=Mathf.Max(b.size.x,b.size.y)/(game.Presentation.Camera.orthographicSize*2/Screen.height);
                            Check(pixels<game.Hud.SlotScreenWidth*.82f,theme.id+": imported model fits tray slot");Capture(theme.id+"-tray");
                            foreach(var other in stock.Where(i=>i!=selected&&i.Id==selected.Id).Take(2)){Check(game.Pick(other,true),theme.id+": match pickup");yield return new WaitForSeconds(.7f);}
                            yield return new WaitForSeconds(.4f);Check(game.Removed==3,theme.id+": actual animated triple removed");
                        }
                    }
                    if(difficulty==2)Capture(theme.id+"-deep");
                    // Scripted full inventory traversal; screen taps and flight above use real animations.
                    game.InstantPicksForQa=true;
                    foreach(var group in game.Remaining.GroupBy(i=>i.Id).ToList())
                    {foreach(var item in group.ToList())game.Pick(item,true);yield return null;}
                    Check(game.Removed==expected&&game.LastResult=="win",theme.id+"/"+difficulty+": whole round clears");report.rounds++;
                    File.WriteAllText(Path.Combine(output,"acceptance.json"),JsonUtility.ToJson(report,true));
                }
            }
            game.InstantPicksForQa=false;game.GoHome();Finish();
        }
        void Finish(){finished=true;report.passed=report.rounds==15&&report.errors.Count==0;File.WriteAllText(Path.Combine(output,"acceptance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);}
    }
}
#endif
