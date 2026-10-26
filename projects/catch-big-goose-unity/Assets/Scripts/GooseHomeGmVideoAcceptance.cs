#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;
namespace CatchGoose
{
    public sealed class GooseHomeGmVideoAcceptance:MonoBehaviour
    {
        [Serializable]sealed class Report{public string version=GooseRuntimePerformance.BuildId;public bool passed;public int completedVideos,cancelledVideos;public List<string> checks=new List<string>(),errors=new List<string>();}
        readonly Report report=new Report();GooseGame game;string output;bool done,oldGm,oldSound;int oldDaily;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-gooseHomeGmVideoQa"))new GameObject("HomeGmVideoQA").AddComponent<GooseHomeGmVideoAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string message,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception)report.errors.Add(message+"\n"+stack);}
        void Check(bool ok,string label){(ok?report.checks:report.errors).Add(label);if(!ok)Debug.LogWarning("[HomeGmVideoQA] "+label);}
        void Capture(string name){Canvas.ForceUpdateCanvases();GooseFrameCapture.Save(Path.Combine(output,name+".png"));}
        IEnumerator Spawn(int stage)
        {float deadline=Time.realtimeSinceStartup+100;while((!game.Playing||game.Difficulty!=stage||!game.SpawnComplete)&&Time.realtimeSinceStartup<deadline)yield return null;Check(game.Playing&&game.Difficulty==stage&&game.SpawnComplete,"Round ready "+stage);}
        Button Setting()=>game.Hud.Home.GetComponentsInChildren<Button>().Single(b=>b.name=="设置");
        IEnumerator CompleteWarmup()
        {
            game.InstantPicksForQa=true;
            foreach(var item in game.Remaining.ToArray())game.Pick(item,true);
            game.InstantPicksForQa=false;yield return Spawn(1);
        }
        IEnumerator ResourcesReleased(string label)
        {
            yield return null;yield return null;
            Check(game.GetComponents<VideoPlayer>().Length==0,label+": video decoder released");
            Check(!Resources.FindObjectsOfTypeAll<RenderTexture>().Any(t=>t.name=="GooseRewardVideo"),label+": render texture released");
        }
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-homeGmVideoOutput")+1];Directory.CreateDirectory(output);GooseSave.IsQa=true;
            oldGm=GooseSave.GmUnlimited;oldDaily=GooseSave.Daily;oldSound=GooseSave.Sound;GooseSave.GmUnlimited=false;GooseSave.Sound=false;StartCoroutine(Watchdog());yield return null;game=GooseGame.Instance;
            foreach(var size in new[]{new Vector2Int(360,640),new Vector2Int(390,844),new Vector2Int(430,932)})
            {
                game.GoHome();Screen.SetResolution(size.x,size.y,false);yield return new WaitForSeconds(.4f);
                var texts=game.Hud.Home.GetComponentsInChildren<Text>().Select(t=>t.text).ToArray();
                Check(!texts.Any(t=>t.Contains("三个")||t.Contains("凑齐")||t.Contains("消除")||t.Contains("三消")),"Home has no match instructions "+size);
                Check(game.Hud.Home.GetComponentsInChildren<Button>().Count(b=>b.name=="StartChallenge")==1,"Single start entry "+size);Check(!game.Hud.Home.transform.Find("HomeHint"),"No empty hint strip "+size);Capture("home-"+size.x+"x"+size.y);
            }
            GooseSave.Onboarded=false;game.Hud.ShowOnboarding();Check(game.Hud.Home.activeSelf&&!game.Hud.Modal,"Fresh session opens home without a forced rules popup");
            GooseSave.Daily=0;game.StartFromHome();Check(!game.Playing&&game.Hud.Modal,"Normal zero-attempt session is gated");
            var watch=game.Hud.Modal.GetComponentsInChildren<Button>().Single(b=>b.GetComponentsInChildren<Text>().Any(t=>t.text=="观看短片"));watch.onClick.Invoke();
            Check(game.Video.Active&&game.Paused,"Actual extra-attempt entry opens video safely");yield return new WaitForSecondsRealtime(.25f);game.Video.Close();yield return ResourcesReleased("Quota-entry cancel");
            Check(GooseSave.Daily==0&&!game.Playing&&game.Hud.Home.activeSelf,"Early close grants no attempt and returns to home");
            Setting().onClick.Invoke();yield return new WaitForSecondsRealtime(.2f);var gm=game.Hud.Modal.GetComponentsInChildren<Button>().Single(b=>b.name=="GmUnlimited");gm.onClick.Invoke();
            Check(!game.Hud.Modal.GetComponentsInChildren<Text>().Any(t=>t.text.Contains("对照")),"Settings comparison entry removed");
            Check(game.Hud.Modal.GetComponentsInChildren<Button>().Length==3,"Settings contains only audio, GM and return controls");
            Check(GooseSave.GmUnlimited,"Settings toggle persists GM mode");Check(game.Hud.Modal.GetComponentsInChildren<Text>().Any(t=>t.text=="GM 无限次数：开启"),"Settings reflects enabled GM state");Capture("settings-gm");game.Hud.CloseModal();
            for(int n=0;n<3;n++)
            {
                game.GoHome();game.StartFromHome();yield return Spawn(0);Check(game.Total==15,"GM permits zero-count warmup "+n);yield return CompleteWarmup();
                Check(game.Total==300&&GooseSave.Daily==0,"GM permits challenge without consuming or faking attempts "+n);
            }
            game.GoHome();Setting().onClick.Invoke();yield return new WaitForSecondsRealtime(.2f);game.Hud.Modal.GetComponentsInChildren<Button>().Single(b=>b.name=="GmUnlimited").onClick.Invoke();game.Hud.CloseModal();
            Check(!GooseSave.GmUnlimited&&GooseSave.Daily==0,"Disabling GM preserves the original real count");game.StartFromHome();Check(!game.Playing&&game.Hud.Modal,"Normal limit applies again after GM is disabled");game.Hud.CloseModal();
            int callbackCount=0,rewards=0;
            for(int n=0;n<6;n++)
            {
                game.Video.Watch(ok=>{callbackCount++;if(ok)rewards++;},n%2);if(n>0)yield return new WaitForSecondsRealtime(.12f);game.Video.Close();game.Video.Close();
                yield return ResourcesReleased("Rapid open/close "+n);Check(callbackCount==n+1&&rewards==0,"Cancelled playback resolves once without a reward "+n);
            }
            for(int clip=0;clip<2;clip++)
            {
                int callbacksBefore=callbackCount,completedBefore=game.Video.CompletedCount;float progressBefore=game.Preparation.Progress;
                game.Video.Watch(ok=>{callbackCount++;if(ok)rewards++;},clip);float deadline=Time.realtimeSinceStartup+160;bool captured=false;
                while(game.Video.Active&&Time.realtimeSinceStartup<deadline)
                {
                    var player=game.GetComponent<VideoPlayer>();
                    if(!captured&&player&&player.isPlaying&&player.time>.4){Check(Mathf.Approximately(progressBefore,game.Preparation.Progress),"Home model preloading is suspended during playback");Check(!game.HomeStage.KeyLight.enabled,"Home light suspended during video");Capture("video-playing-"+clip);captured=true;}
                    yield return null;
                }
                Check(!game.Video.Active&&game.Video.LastOutcome=="complete"&&captured,"Full real video finishes normally "+clip);
                Check(game.Video.CompletedCount==completedBefore+1&&callbackCount==callbacksBefore+1&&rewards==clip+1,"Natural end grants one reward "+clip);
                game.Video.Close();yield return ResourcesReleased("Completed video "+clip);Check(!game.Paused,"Playback restores pause state "+clip);
                Check(game.HomeStage.KeyLight.enabled,"Home light restored after video "+clip);
            }
            report.completedVideos=game.Video.CompletedCount;report.cancelledVideos=game.Video.CancelledCount;Finish();
        }
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(600);if(!done){report.errors.Add("QA watchdog");Finish();}}
        void Finish(){if(done)return;done=true;GooseSave.GmUnlimited=oldGm;GooseSave.Daily=oldDaily;GooseSave.Sound=oldSound;report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"home-gm-video-acceptance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);}
    }
}
#endif
