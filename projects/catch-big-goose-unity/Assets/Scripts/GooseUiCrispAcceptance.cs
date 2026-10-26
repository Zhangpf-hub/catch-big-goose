#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;
namespace CatchGoose
{
    public sealed class GooseUiCrispAcceptance:MonoBehaviour
    {
        [Serializable] sealed class Report{public bool passed;public int requestedMsaa,supportedCaptureMsaa;public string graphics;public List<string> checks=new List<string>(),errors=new List<string>();}
        readonly Report report=new Report();GooseGame game;string output;bool finished,previousSound;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-uiQualityQa"))new GameObject("UiQualityProof").AddComponent<GooseUiCrispAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string s,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception)report.errors.Add(s);}
        void Check(bool ok,string text){(ok?report.checks:report.errors).Add(text);}
        void Capture(string name){Canvas.ForceUpdateCanvases();GooseFrameCapture.Save(Path.Combine(output,name+".png"));}
        void CheckUi(GameObject parent,string name)
        {
            Canvas.ForceUpdateCanvases();
            foreach(var text in parent.GetComponentsInChildren<Text>())
            {
                if(string.IsNullOrWhiteSpace(text.text))continue;
                Check(text.transform.localScale.x==.5f&&text.fontSize>=36,name+": oversampled text "+text.text);
                Check(text.fontStyle==FontStyle.Normal,name+": no synthetic bold "+text.text);
                Check(text.cachedTextGenerator.vertexCount>0,name+": glyphs rendered "+text.text);
                Check(text.cachedTextGenerator.characterCountVisible>=text.text.Count(c=>!char.IsWhiteSpace(c)),name+": text fits "+text.text);
            }
            foreach(var button in parent.GetComponentsInChildren<Button>())
            {
                var canvas=button.GetComponentInParent<Canvas>().rootCanvas;var camera=canvas.renderMode==RenderMode.ScreenSpaceOverlay?null:canvas.worldCamera;
                var corners=new Vector3[4];button.GetComponent<RectTransform>().GetWorldCorners(corners);var p=corners.Select(v=>RectTransformUtility.WorldToScreenPoint(camera,v)).ToArray();
                Check(p.All(v=>v.x>=-1&&v.x<=Screen.width+1&&v.y>=-1&&v.y<=Screen.height+1),name+": inside screen "+button.name);
                Check(p.Max(v=>v.x)-p.Min(v=>v.x)>=43&&p.Max(v=>v.y)-p.Min(v=>v.y)>=43,name+": >=44px touch "+button.name);
                var image=button.targetGraphic as Image;Check(image&&image.type==Image.Type.Sliced&&image.sprite.border.x>0,name+": sliced "+button.name);
            }
        }
        IEnumerator Spawn(){float until=Time.realtimeSinceStartup+120;while(game.Playing&&!game.SpawnComplete&&Time.realtimeSinceStartup<until)yield return null;Check(game.SpawnComplete,"Spawn ready");yield return new WaitForSeconds(.5f);}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(420);if(!finished){report.errors.Add("QA watchdog");Finish();}}
        IEnumerator Gallery()
        {
            Screen.SetResolution(390,844,false);yield return new WaitForSeconds(.5f);
            var go=new GameObject("NineSliceComparison",typeof(RectTransform),typeof(Canvas),typeof(CanvasScaler));var canvas=go.GetComponent<Canvas>();canvas.renderMode=RenderMode.ScreenSpaceOverlay;canvas.sortingOrder=99;canvas.pixelPerfect=true;
            var scaler=go.GetComponent<CanvasScaler>();scaler.uiScaleMode=CanvasScaler.ScaleMode.ScaleWithScreenSize;scaler.referenceResolution=new Vector2(720,1560);
            var root=game.Hud.Panel("Paper",go.transform,new Rect(0,0,720,1560),new Color(1,.97f,.88f));
            game.Hud.Label(root.transform,"OLD 100px / 4          NEW 64px / 2",new Rect(0,1480,720,60),24,new Color(.25f,.15f,.08f));
            Vector2[] sizes={new Vector2(88,88),new Vector2(130,145),new Vector2(290,93),new Vector2(290,130),new Vector2(290,400)};float y=1390;
            for(int i=0;i<sizes.Length;i++)
            {
                var size=sizes[i];string name=i==4?"ivory-panel":i==3?"blue-button":"yellow-button";
                game.Hud.Label(root.transform,size.x+" x "+size.y,new Rect(0,y,720,40),23,new Color(.25f,.15f,.08f));y-=size.y;
                for(int col=0;col<2;col++)
                {
                    var rect=new Rect(35+col*360+(290-size.x)*.5f,y,size.x,size.y);
                    var image=game.Hud.Panel("Surface",root.transform,rect,Color.white).GetComponent<Image>();
                    if(col==0){var texture=new Texture2D(2,2,TextureFormat.RGBA32,false);texture.LoadImage(File.ReadAllBytes(Path.GetFullPath("source-assets/ui/UiNineSliceBaseline-20261025/"+name+".png")));image.sprite=UnityEngine.Sprite.Create(texture,new Rect(0,0,texture.width,texture.height),new Vector2(.5f,.5f),100,0,SpriteMeshType.FullRect,new Vector4(100,100,100,100));image.type=Image.Type.Sliced;image.pixelsPerUnitMultiplier=4;}
                    else GooseUiSurface.Apply(image,Resources.Load<Sprite>("Textures/ui-candy-v2/"+name));
                }
                y-=76;
            }
            Capture("nine-slice-comparison");Destroy(go);yield return null;
        }
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-uiOutput")+1];Directory.CreateDirectory(output);GooseSave.IsQa=true;previousSound=GooseSave.Sound;GooseSave.Sound=true;StartCoroutine(Watchdog());yield return null;game=GooseGame.Instance;game.GoHome();
            report.requestedMsaa=QualitySettings.antiAliasing;report.graphics=SystemInfo.graphicsDeviceName;
            report.supportedCaptureMsaa=SystemInfo.GetRenderTextureSupportedMSAASampleCount(new RenderTextureDescriptor(390,844,RenderTextureFormat.ARGB32,24){msaaSamples=2});
            Check(report.requestedMsaa==2,"Mobile rendering requests 2x MSAA");yield return Gallery();
            var sizes=new[]{new Vector2Int(360,640),new Vector2Int(390,844),new Vector2Int(430,932),new Vector2Int(390,844),new Vector2Int(780,1688)};
            for(int i=0;i<sizes.Length;i++)
            {
                var size=sizes[i];game.GoHome();Screen.SetResolution(size.x,size.y,false);yield return new WaitForSeconds(.6f);
                FindObjectOfType<GoosePhoneLayout>().SetPlatformSafeArea(i==3?new Rect(0,.04f,1,.91f):new Rect(0,0,1,1));game.SelectTheme(Array.FindIndex(game.Themes,t=>t.id=="barbecue"));game.SelectDifficulty(0);yield return new WaitForSeconds(1);
                string name=i==3?"safe":size.x+"x"+size.y;CheckUi(game.Hud.Home,name+" home");Capture(name+"-home");
                Check(game.Hud.BoldFont&&game.Hud.BoldFont!=game.Hud.Font,name+": actual bold font loaded");
                Check(FindObjectsOfType<AudioSource>().Any(s=>s.loop&&s.clip&&s.clip.name=="bgm"&&s.isPlaying&&s.volume>.1f),name+": BGM playing in actual player");
                var shake=Resources.Load<AudioClip>("Audio/shake");Check(shake&&shake.length<.5f,name+": dedicated short shake clip loaded");
                game.BeginExperienceRound(104729);yield return Spawn();Check(game.Total==15,name+" tutorial stock");CheckUi(game.Hud.Play,name+" play");Capture(name+"-stage1");game.EndRound(true,"");CheckUi(game.Hud.Modal,name+" win");Capture(name+"-win");
                game.GoHome();game.SelectDifficulty(1);game.BeginExperienceRound(155451);yield return Spawn();Check(game.Total==300,name+" challenge stock");Capture(name+"-stage2");game.EndRound(false,"槽位已满");CheckUi(game.Hud.Modal,name+" retry");Capture(name+"-retry");
            }
            Finish();
        }
        void Finish(){finished=true;GooseSave.Sound=previousSound;report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"ui-quality.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);}
    }
}
#endif
