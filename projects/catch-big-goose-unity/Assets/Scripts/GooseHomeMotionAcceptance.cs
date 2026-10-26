#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace CatchGoose
{
    public sealed class GooseHomeMotionAcceptance : MonoBehaviour
    {
        [Serializable] public class Sample
        {
            public string phase;public int targetFps,frames,over25ms,over50ms,gc0;
            public float fps,p95ms,maxMs,stationaryPercent,maxCornerStep;
            public bool pixelPerfect;
        }
        [Serializable] class Report
        {
            public string scope="Windows native player with real home UI and rendering. Mobile profile simulates settings; these are not phone FPS measurements.";
            public bool passed,baseline,mobile;public List<Sample> samples=new List<Sample>();
            public List<string> checks=new List<string>(),errors=new List<string>();
        }
        readonly Report report=new Report();readonly List<float> frames=new List<float>(1200);
        GooseGame game;string output;bool done;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)] static void Early()
        {
            if(!Environment.GetCommandLineArgs().Contains("-homeMotionQa"))return;
            GooseSave.IsQa=true;GooseSave.Sound=false;GooseSave.Onboarded=true;
        }
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-homeMotionQa"))new GameObject("HomeMotionAcceptance").AddComponent<GooseHomeMotionAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string message,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception)report.errors.Add(message+stack);}
        void Check(bool ok,string message){(ok?report.checks:report.errors).Add(message);}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(120);if(!done){report.errors.Add("Home motion QA timed out");Finish();}}
        IEnumerator Ready()
        {
            float end=Time.realtimeSinceStartup+40;
            while(!game.HomeStage.Ready&&Time.realtimeSinceStartup<end)yield return null;
            Check(game.HomeStage.Ready,"Home 3D display is ready");yield return new WaitForSecondsRealtime(1);
        }
        IEnumerator SampleHome(string phase)
        {
            var motion=game.Hud.Home.transform.Find("StartChallenge").GetComponent<GooseCandyMotion>();
            var image=motion.Visual.GetComponentInChildren<Image>();
            var sample=new Sample{phase=phase,targetFps=Application.targetFrameRate,pixelPerfect=image.canvas.pixelPerfect};
            frames.Clear();int gc=GC.CollectionCount(0),stationary=0;float sum=0;
            Vector2 last=Corner(image);float end=Time.realtimeSinceStartup+6;
            while(Time.realtimeSinceStartup<end)
            {
                yield return new WaitForEndOfFrame();
                float ms=Time.unscaledDeltaTime*1000;frames.Add(ms);sum+=ms;
                Vector2 corner=Corner(image);float step=Vector2.Distance(corner,last);last=corner;
                if(step<.01f)stationary++;sample.maxCornerStep=Mathf.Max(sample.maxCornerStep,step);
                if(ms>25)sample.over25ms++;if(ms>50)sample.over50ms++;
            }
            sample.gc0=GC.CollectionCount(0)-gc;sample.frames=frames.Count;sample.fps=frames.Count*1000/Mathf.Max(1,sum);
            frames.Sort();sample.p95ms=frames[(frames.Count-1)*95/100];sample.maxMs=frames.Last();
            sample.stationaryPercent=100f*stationary/frames.Count;report.samples.Add(sample);
            if(!report.baseline)
            {
                Check(sample.targetFps==60,"Home requests 60 FPS: "+phase);
                Check(!sample.pixelPerfect,"Animated graphics use subpixel layout: "+phase);
                Check(sample.stationaryPercent<25,"CTA avoids repeated snapped positions: "+phase);
            }
        }
        Vector2 Corner(Image image)
        {
            var r=image.GetPixelAdjustedRect();
            return RectTransformUtility.WorldToScreenPoint(game.Hud.HudCamera,image.rectTransform.TransformPoint(new Vector3(r.xMin,r.yMin)));
        }
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-homeMotionOutput");
            output=at>=0?args[at+1]:Path.Combine(Application.persistentDataPath,"home-motion-qa");Directory.CreateDirectory(output);
            report.baseline=args.Contains("-homeMotionBaseline");report.mobile=GooseRuntimePerformance.Mobile;
            StartCoroutine(Watchdog());yield return null;game=GooseGame.Instance;yield return Ready();
            yield return SampleHome("home-idle");
            var button=game.Hud.Home.transform.Find("StartChallenge").GetComponent<Button>();
            var motion=button.GetComponent<GooseCandyMotion>();var hitScale=button.transform.localScale;var hitPosition=button.transform.localPosition;
            motion.OnPointerDown(new PointerEventData(EventSystem.current));yield return new WaitForSecondsRealtime(.18f);
            Check(motion.Visual.localScale.y<.98f,"Button visibly compresses while held");
            GooseFrameCapture.Save(Path.Combine(output,"pressed.png"));
            int emissions=game.Hud.Home.GetComponentInChildren<GooseStickerBurst>().Emissions;
            motion.OnPointerUp(new PointerEventData(EventSystem.current));yield return new WaitForSecondsRealtime(.8f);
            Check(button.transform.localScale==hitScale&&button.transform.localPosition==hitPosition,"Animated visual keeps hit target fixed");
            Check(game.Hud.Home.GetComponentInChildren<GooseStickerBurst>().Emissions==emissions+1,"Release emits one feedback burst");
            GooseFrameCapture.Save(Path.Combine(output,"home.png"));
            game.BeginDuckReview(2);float end=Time.realtimeSinceStartup+30;
            while(!game.SpawnComplete&&Time.realtimeSinceStartup<end)yield return null;
            Check(game.SpawnComplete,"Review round opens after home animation");
            Check(Application.targetFrameRate==(report.mobile?30:60),"Gameplay retains its frame budget");
            Check(Mathf.Abs(Time.fixedDeltaTime-(report.mobile?1f/30:1f/60))<.0001f,"Physics time step is preserved");
            game.GoHome();yield return Ready();yield return SampleHome("returned-home");Finish();
        }
        void Finish()
        {
            if(done)return;done=true;report.passed=report.errors.Count==0;
            File.WriteAllText(Path.Combine(output,"home-motion.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);
        }
    }
}
#endif
