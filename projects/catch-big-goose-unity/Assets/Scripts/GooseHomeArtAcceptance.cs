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
    public sealed class GooseHomeArtAcceptance:MonoBehaviour
    {
        [Serializable]sealed class Report{public bool passed;public string build,uiVersion;public List<string> checks=new List<string>(),errors=new List<string>();}
        readonly Report report=new Report();GooseGame game;string output;bool done;int duckInstance;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot(){if(Environment.GetCommandLineArgs().Contains("-homeArtQa"))new GameObject("HomeArtAcceptance").AddComponent<GooseHomeArtAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string s,string stack,LogType kind){if(kind==LogType.Exception||kind==LogType.Error)report.errors.Add(s);}
        void Check(bool ok,string s){(ok?report.checks:report.errors).Add(s);}
        void Shot(string name){Canvas.ForceUpdateCanvases();GooseFrameCapture.Save(Path.Combine(output,name+".png"));}
        void Ui(GameObject root,string label)
        {
            Canvas.ForceUpdateCanvases();
            foreach(var button in root.GetComponentsInChildren<Button>())
            {
                var rect=button.GetComponent<RectTransform>();var corners=new Vector3[4];rect.GetWorldCorners(corners);
                var p=corners.Select(x=>RectTransformUtility.WorldToScreenPoint(game.Hud.HudCamera,x)).ToArray();
                Check(p.All(x=>x.x>=-1&&x.y>=-1&&x.x<=Screen.width+1&&x.y<=Screen.height+1),label+" button bounds "+button.name);
                Check(p.Max(x=>x.x)-p.Min(x=>x.x)>=43&&p.Max(x=>x.y)-p.Min(x=>x.y)>=43,label+" touch >=44 "+button.name);
                var image=button.targetGraphic as Image;Check(image&&image.type==Image.Type.Sliced&&image.sprite.border.x>0,label+" nine slice "+button.name);
                var hits=new List<RaycastResult>();EventSystem.current.RaycastAll(new PointerEventData(EventSystem.current){position=RectTransformUtility.WorldToScreenPoint(game.Hud.HudCamera,button.transform.position)},hits);
                Check(hits.Any(hit=>hit.gameObject==button.gameObject),label+" transparent stable hit area receives actual UI raycast "+button.name);
            }
            foreach(var g in root.GetComponentsInChildren<GooseCandyPattern>())Check(!g.raycastTarget,label+" decorative input pass-through");
            foreach(var image in root.GetComponentsInChildren<Image>().Where(x=>x.name=="GeneratedIllustration"))
            {
                Check(image.preserveAspect&&image.type==Image.Type.Simple,label+" generated art keeps aspect ratio");
                Check(!image.raycastTarget&&image.sprite&&image.sprite.texture.mipmapCount>1&&!image.sprite.texture.isReadable,label+" generated art smooth, non-readable, touch passes through");
            }
            foreach(var t in root.GetComponentsInChildren<Text>())if(!string.IsNullOrWhiteSpace(t.text))Check(t.cachedTextGenerator.vertexCount>0,label+" glyphs "+t.text);
        }
        IEnumerator WaitHome(){float limit=Time.realtimeSinceStartup+45;while(game.HomeStage&&!game.HomeStage.Ready&&Time.realtimeSinceStartup<limit)yield return null;Check(game.HomeStage&&game.HomeStage.Ready,"Live 3D display ready");yield return new WaitForSecondsRealtime(.4f);}
        IEnumerator Duck()
        {
            var actor=game.HomeStage.DuckMascot;Check(actor&&actor.Skin&&actor.idle&&actor.greet&&actor.click,"B2 skinned duck and all three real clips loaded");
            if(!actor||!actor.Skin)yield break;
            if(duckInstance==0)duckInstance=actor.GetInstanceID();Check(duckInstance==actor.GetInstanceID(),"Same duck reused across themes and round returns");
            Check(actor.Skin.bones.Length==9,"Approved nine-bone B2 rig");
            foreach(var id in new[]{"title","cta","settings"})Check(game.Hud.Home.GetComponentsInChildren<Image>().Any(x=>x.sprite&&x.sprite.texture.name=="Textures/duck-stickers-v3/"+id),"Duck UI active: "+id);
            actor.Greet();yield return new WaitForSecondsRealtime(.2f);
            var a=new Mesh();var b=new Mesh();actor.Skin.BakeMesh(a);yield return new WaitForSecondsRealtime(.3f);actor.Skin.BakeMesh(b);
            var av=a.vertices;var bv=b.vertices;float movement=0;for(int i=0;i<av.Length;i++)movement=Mathf.Max(movement,Vector3.Distance(av[i],bv[i]));
            Check(movement>.0001f,"Greeting changes actual skinned vertices");Destroy(a);Destroy(b);
        }
        IEnumerator Spawn(){float limit=Time.realtimeSinceStartup+80;while(!game.SpawnComplete&&Time.realtimeSinceStartup<limit)yield return null;Check(game.SpawnComplete,"Round ready");yield return new WaitForSecondsRealtime(.5f);}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(420);if(!done){report.errors.Add("QA timed out");Finish();}}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-homeArtOutput")+1];Directory.CreateDirectory(output);report.build=GooseRuntimePerformance.BuildId;report.uiVersion=GooseHud.HomeUiVersion;
            GooseSave.IsQa=true;yield return null;game=GooseGame.Instance;StartCoroutine(Watchdog());game.GoHome();Screen.SetResolution(390,844,false);yield return new WaitForSecondsRealtime(.6f);
            foreach(var theme in game.Themes)
            {
                game.GoHome();yield return null;
                var pick=game.Hud.Home.GetComponentsInChildren<Button>().First(x=>x.name=="Theme_"+theme.id);pick.onClick.Invoke();yield return new WaitForSecondsRealtime(.18f);yield return WaitHome();
                Check(game.Theme.id==theme.id,"Theme button switches "+theme.id);Check(game.Hud.Background.sprite&&game.Hud.Background.sprite.name==theme.id+"-v1","Themed home background "+theme.id);
                if(GooseHud.HomeUiVersion.Contains("DUCK"))yield return Duck();
                var bg=game.Hud.Background.sprite.texture;Check(bg.mipmapCount>1&&!bg.isReadable&&bg.filterMode==FilterMode.Trilinear,"Decoded JPEG has mipmaps, trilinear and no CPU pixel copy "+theme.id);
                var buttons=game.Hud.Home.GetComponentsInChildren<Button>();Check(!buttons.Any(x=>x.name=="成绩"||x.name=="玩法"),"Removed records/help "+theme.id);Check(buttons.Length==7,"Five themes, settings, start "+theme.id);
                Ui(game.Hud.Home,theme.id);Shot(theme.id+"-home");
                game.SelectDifficulty(0);game.BeginExperienceRound(104729);yield return Spawn();Check(game.Total==15,"Tutorial15 "+theme.id);Check(game.Hud.Background.sprite.name==theme.id+"-v1","Themed play background "+theme.id);Shot(theme.id+"-stage1");
                game.GoHome();game.SelectDifficulty(1);game.BeginExperienceRound(155451);yield return Spawn();Check(game.Total==300,"Challenge300 "+theme.id);Shot(theme.id+"-stage2");
            }
            game.GoHome();game.SelectTheme(Array.FindIndex(game.Themes,x=>x.id=="barbecue"));yield return WaitHome();
            foreach(var size in new[]{new Vector2Int(360,640),new Vector2Int(430,932),new Vector2Int(390,844)})
            {
                Screen.SetResolution(size.x,size.y,false);yield return new WaitForSecondsRealtime(.6f);
                FindObjectOfType<GoosePhoneLayout>().SetPlatformSafeArea(size.x==390?new Rect(0,.04f,1,.91f):new Rect(0,0,1,1));yield return WaitHome();
                Ui(game.Hud.Home,"layout"+size);Shot("layout-"+size.x+"x"+size.y+"-home");
            }
            var start=game.Hud.Home.GetComponentsInChildren<Button>().First(x=>x.name=="StartChallenge");var motion=start.GetComponent<GooseCandyMotion>();var scale=motion.Visual.localScale;
            yield return new WaitForSecondsRealtime(.4f);Check(scale!=motion.Visual.localScale,"CTA idle animation changes rendered scale");
            var hitScale=start.transform.localScale;motion.OnPointerDown(new PointerEventData(EventSystem.current));yield return new WaitForSecondsRealtime(.15f);Shot("button-pressed");
            Check(motion.Visual.localScale.y<.96f,"Visible button squash when held");Check(start.transform.localScale==hitScale,"Touch bounds stay fixed during animation");
            int before=game.Hud.Home.GetComponentInChildren<GooseStickerBurst>().Emissions;motion.OnPointerUp(new PointerEventData(EventSystem.current));yield return new WaitForSecondsRealtime(.12f);Shot("button-released");
            Check(game.Hud.Home.GetComponentInChildren<GooseStickerBurst>().Emissions==before+1,"Pointer release triggers star burst");
            if(game.HomeStage.DuckMascot)
            {
                int clicks=game.HomeStage.DuckMascot.ClickCount;
                for(int i=0;i<5;i++){game.HomeStage.React();yield return new WaitForSecondsRealtime(.05f);}
                Check(game.HomeStage.DuckMascot.ClickCount==clicks+5&&game.HomeStage.DuckMascot.CurrentAction=="duck_click","Rapid clicks restart the approved duck click clip");
                yield return new WaitForSecondsRealtime(1.5f);Check(game.HomeStage.DuckMascot.CurrentAction=="duck_idle","Duck click returns to real idle clip");
            }
            Directory.CreateDirectory(Path.Combine(output,"motion"));for(int i=0;i<50;i++){if(i==15)game.HomeStage.React();Shot("motion/"+i.ToString("D3"));yield return new WaitForSecondsRealtime(.08f);}
            Finish();
        }
        void Finish(){done=true;report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"acceptance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);}
    }
}
#endif
