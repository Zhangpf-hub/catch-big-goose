#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using UnityEngine;
using UnityEngine.UI;

namespace CatchGoose
{
    public sealed class GooseFlowAudioAcceptance : MonoBehaviour
    {
        [Serializable] class Report
        {
            public string version=GooseGame.FlowAudioVersion;
            public bool passed;public int capturedSamples;public float capturedRms,capturedPeak;
            public List<string> checks=new List<string>(),errors=new List<string>();
        }
        readonly Report report=new Report();GooseGame game;string output;bool finished,oldSound;int oldDaily;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-gooseFlowAudioQa"))new GameObject("FlowAudioAcceptance").AddComponent<GooseFlowAudioAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string text,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception)report.errors.Add(text+"\n"+stack);}
        void Check(bool ok,string message){(ok?report.checks:report.errors).Add(message);if(!ok)Debug.LogWarning("[FlowAudioQA] "+message);}
        void Capture(string name){Canvas.ForceUpdateCanvases();GooseFrameCapture.Save(Path.Combine(output,name+".png"));}
        IEnumerator Spawn(int difficulty)
        {
            float until=Time.realtimeSinceStartup+120;
            while((!game.Playing||game.Difficulty!=difficulty||!game.SpawnComplete)&&Time.realtimeSinceStartup<until)yield return null;
            Check(game.Playing&&game.Difficulty==difficulty&&game.SpawnComplete,"Actual round ready "+difficulty);yield return new WaitForSeconds(.25f);
        }
        void CheckVisibleText(GameObject root,string name)
        {
            Canvas.ForceUpdateCanvases();
            foreach(var text in root.GetComponentsInChildren<Text>())
            {
                Check(!text.text.Contains("第一关")&&!text.text.Contains("第二关")&&!text.text.Contains("第 1 关")&&!text.text.Contains("第 2 关"),name+": no stage-number label "+text.text);
                if(!string.IsNullOrWhiteSpace(text.text))Check(text.cachedTextGenerator.vertexCount>0,name+": rendered text "+text.text);
            }
        }
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-flowAudioOutput")+1];Directory.CreateDirectory(output);
            GooseSave.IsQa=true;oldSound=GooseSave.Sound;oldDaily=GooseSave.Daily;GooseSave.Sound=true;StartCoroutine(Watchdog());yield return null;game=GooseGame.Instance;
            foreach(var size in new[]{new Vector2Int(360,640),new Vector2Int(390,844),new Vector2Int(430,932),new Vector2Int(780,1688)})
            {
                game.GoHome();Screen.SetResolution(size.x,size.y,false);yield return new WaitForSeconds(.4f);CheckVisibleText(game.Hud.Home,"Home "+size);Capture("home-"+size.x+"x"+size.y);
                Check(!game.Hud.Home.GetComponentsInChildren<Button>().Any(b=>b.name.Contains("第一关")||b.name.Contains("第二关")),"No stage selector "+size);
                Check(game.Hud.Home.GetComponentsInChildren<Text>().Count(t=>t.text=="开始关卡")==1,"Single theme start label "+size);
            }
            Screen.SetResolution(390,844,false);yield return new WaitForSeconds(.4f);
            for(int theme=0;theme<game.Themes.Length;theme++)
            {
                game.GoHome();GooseSave.Daily=3;game.SelectTheme(theme);
                // Previously completed themes must still start with the warmup.
                GooseSave.CompleteStoryStage(game.Theme.id,0);GooseSave.SelectStoryStage(game.Theme.id,1);
                game.Hud.Home.GetComponentsInChildren<Button>().Single(b=>b.name=="StartChallenge").onClick.Invoke();yield return Spawn(0);
                string id=game.Theme.id;Check(game.Total==15&&game.Level.seconds==0,id+": entry starts easy untimed stock");Check(GooseSave.Daily==3,id+": warmup costs no attempt");CheckVisibleText(game.Hud.Play,id+" warmup");Capture(id+"-warmup");
                while(game.Playing&&game.Remaining.Any())
                {
                    var triple=game.Remaining.GroupBy(i=>i.Id).First(g=>g.Count()>=3).Take(3).ToArray();
                    foreach(var item in triple)Check(game.Pick(item,true),id+": real warmup match");
                    float until=Time.realtimeSinceStartup+6;while(game.PendingMatches>0&&Time.realtimeSinceStartup<until)yield return null;
                    yield return null;
                }
                Check(game.TransitioningToChallenge&&!game.Hud.Modal,id+": win transitions without next button");yield return Spawn(1);
                Check(game.Theme.id==id&&game.Total==300,id+": automatically enters same-theme hard stock");Check(GooseSave.Daily==2,id+": challenge consumes one attempt");CheckVisibleText(game.Hud.Play,id+" challenge");Capture(id+"-challenge");
                if(theme==0)
                {
                    Check(game.Shake.Request(Vector3.right),"Shake request accepted");yield return new WaitForSeconds(.04f);
                    var audio=game.ShakeAudio;Check(audio&&audio.Source.isPlaying&&audio.BurstsPlayed>=1,"Dedicated shake source is actually playing");
                    var probe=audio.gameObject.AddComponent<GooseAudioOutputProbe>();probe.Begin();int before=audio.BurstsPlayed;
                    yield return new WaitForSeconds(.22f);
                    Check(game.GetComponents<AudioSource>().Any(s=>s.loop&&s.isPlaying&&s.volume<.16f),"Music ducks while objects rattle");
                    yield return new WaitForSeconds(.85f);
                    probe.End(Path.Combine(output,"actual-shake-output.wav"));report.capturedSamples=probe.Samples;report.capturedRms=probe.Rms;report.capturedPeak=probe.Peak;
                    Check(audio.BurstsPlayed>=before+3,"Movement produces successive audible impacts");
                    Check(probe.Samples>1000&&probe.Rms>.005f,"Audio DSP output contains non-silent shake sound");
                    yield return new WaitForSeconds(.4f);
                    Check(game.GetComponents<AudioSource>().Any(s=>s.loop&&s.isPlaying&&s.volume>.24f),"Music level recovers after shaking");
                    game.ToggleSound();yield return new WaitForSeconds(.3f);int count=audio.BurstsPlayed;
                    Check(game.Shake.Request(Vector3.right),"Muted physical shake accepted");yield return new WaitForSeconds(.75f);
                    Check(audio.BurstsPlayed==count&&!audio.Source.isPlaying,"Saved sound switch also mutes shake");game.ToggleSound();
                }
                game.EndRound(false,"槽位已满");CheckVisibleText(game.Hud.Modal,id+" result");
                game.Hud.Modal.GetComponentsInChildren<Button>().Single(b=>b.GetComponentsInChildren<Text>().Any(t=>t.text=="重试本关")).onClick.Invoke();yield return Spawn(1);
                Check(game.Total==300&&GooseSave.Daily==2,id+": retry retains hard round without duplicate charge");
            }
            game.GoHome();GooseSave.Daily=3;game.StartFromHome();yield return Spawn(0);game.EndRound(true,"");game.GoHome();yield return new WaitForSeconds(1);
            Check(!game.Playing&&!game.TransitioningToChallenge&&game.Hud.Home.activeSelf,"Returning home cancels pending automatic advance");
            game.StartFromHome();yield return Spawn(0);Check(game.Total==15,"New start always begins with warmup");game.GoHome();Finish();
        }
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(600);if(!finished){report.errors.Add("QA timeout");Finish();}}
        void Finish(){if(finished)return;finished=true;GooseSave.Sound=oldSound;GooseSave.Daily=oldDaily;report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"flow-audio-acceptance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);}
    }

    public sealed class GooseAudioOutputProbe : MonoBehaviour
    {
        float[] samples;int written,channels,rate;volatile bool recording;
        public int Samples {get;private set;}public float Rms {get;private set;}public float Peak {get;private set;}
        public void Begin(){rate=AudioSettings.outputSampleRate;samples=new float[rate*4*2];written=0;recording=true;}
        void OnAudioFilterRead(float[] data,int channelCount)
        {
            if(!recording||samples==null)return;channels=channelCount;
            int start=written,count=Math.Min(data.Length,samples.Length-start);if(count<=0)return;
            Array.Copy(data,0,samples,start,count);Interlocked.Exchange(ref written,start+count);
        }
        public void End(string path)
        {
            recording=false;Samples=Volatile.Read(ref written);double sum=0;
            for(int i=0;i<Samples;i++){sum+=samples[i]*samples[i];Peak=Mathf.Max(Peak,Mathf.Abs(samples[i]));}Rms=Samples>0?(float)Math.Sqrt(sum/Samples):0;
            using(var file=new BinaryWriter(File.Create(path)))
            {
                int c=Math.Max(1,channels),bytes=Samples*2;file.Write(System.Text.Encoding.ASCII.GetBytes("RIFF"));file.Write(36+bytes);file.Write(System.Text.Encoding.ASCII.GetBytes("WAVEfmt "));file.Write(16);file.Write((short)1);file.Write((short)c);file.Write(rate);file.Write(rate*c*2);file.Write((short)(c*2));file.Write((short)16);file.Write(System.Text.Encoding.ASCII.GetBytes("data"));file.Write(bytes);
                for(int i=0;i<Samples;i++)file.Write((short)Mathf.Clamp(Mathf.RoundToInt(samples[i]*32767),-32768,32767));
            }
        }
    }
}
#endif
