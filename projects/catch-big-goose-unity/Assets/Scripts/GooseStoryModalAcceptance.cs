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
    public sealed class GooseStoryModalAcceptance:MonoBehaviour
    {
        [Serializable] sealed class Report{public bool passed;public List<string> checks=new List<string>(),errors=new List<string>();}
        readonly Report report=new Report();GooseGame game;string output;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-storyModalQa"))new GameObject("StoryModalQa").AddComponent<GooseStoryModalAcceptance>();}
        void Check(bool ok,string label){(ok?report.checks:report.errors).Add(label);}
        void Capture(string name)
        {
            Canvas.ForceUpdateCanvases();
            Rect safe=name.StartsWith("safe")?new Rect(0,Screen.height*.04f,Screen.width,Screen.height*.91f):new Rect(0,0,Screen.width,Screen.height);
            foreach(var button in game.Hud.Modal.GetComponentsInChildren<Button>())
            {
                var corners=new Vector3[4];button.GetComponent<RectTransform>().GetWorldCorners(corners);
                var canvas=button.GetComponentInParent<Canvas>().rootCanvas;
                var camera=canvas.renderMode==RenderMode.ScreenSpaceOverlay?null:canvas.worldCamera;
                var p=corners.Select(v=>RectTransformUtility.WorldToScreenPoint(camera,v)).ToArray();
                Check(p.All(v=>v.x>=safe.xMin-1&&v.x<=safe.xMax+1&&v.y>=safe.yMin-1&&v.y<=safe.yMax+1),name+": modal button within safe area "+button.name);
                Check(p.Max(v=>v.x)-p.Min(v=>v.x)>=43&&p.Max(v=>v.y)-p.Min(v=>v.y)>=43,name+": modal touch target >=44px "+button.name);
            }
            GooseFrameCapture.Save(Path.Combine(output,name+".png"),Screen.width,Screen.height);
        }
        IEnumerator Spawn(){float until=Time.realtimeSinceStartup+120;while(!game.SpawnComplete&&game.Playing&&Time.realtimeSinceStartup<until)yield return null;Check(game.SpawnComplete,"Spawn ready");yield return new WaitForSeconds(.5f);}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-storyOutput")+1];Directory.CreateDirectory(output);GooseSave.IsQa=true;yield return null;game=GooseGame.Instance;
            var sizes=new[]{new Vector2Int(360,640),new Vector2Int(390,844),new Vector2Int(430,932),new Vector2Int(390,844)};
            for(int n=0;n<sizes.Length;n++)
            {
                game.GoHome();Screen.SetResolution(sizes[n].x,sizes[n].y,false);yield return new WaitForSecondsRealtime(.5f);
                FindObjectOfType<GoosePhoneLayout>().SetPlatformSafeArea(n==3?new Rect(0,.04f,1,.91f):new Rect(0,0,1,1));
                game.SelectTheme(Array.FindIndex(game.Themes,t=>t.id=="barbecue"));game.SelectDifficulty(0);game.BeginExperienceRound(104729);yield return Spawn();
                game.InstantPicksForQa=true;foreach(var group in game.Remaining.GroupBy(i=>i.Id).ToList()){foreach(var item in group.ToList())game.Pick(item,true);yield return null;}
                Check(game.LastResult=="win","Tutorial win modal");Capture((n==3?"safe":sizes[n].x+"x"+sizes[n].y)+"-win");
                game.GoHome();game.SelectDifficulty(1);game.BeginExperienceRound(155451);yield return Spawn();game.EndRound(false,"槽位已满");
                Capture((n==3?"safe":sizes[n].x+"x"+sizes[n].y)+"-retry");
            }
            report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"modal-acceptance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);
        }
    }
}
#endif
