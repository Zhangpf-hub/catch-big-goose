#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

namespace CatchGoose
{
    public sealed class GooseUiAcceptance : MonoBehaviour
    {
        [Serializable] class Report { public bool passed; public List<string> checks = new List<string>(), errors = new List<string>(); }
        readonly Report report = new Report();
        string output;
        void Check(bool ok, string message) { (ok ? report.checks : report.errors).Add(message); }
        void Log(string message, string stack, LogType type)
        { if (type == LogType.Error || type == LogType.Exception) report.errors.Add(message + stack); }
        IEnumerator Start()
        {
            Application.logMessageReceived += Log;
            var args = Environment.GetCommandLineArgs(); int at = Array.IndexOf(args, "-gooseUiOutput");
            output = at >= 0 ? args[at+1] : Path.Combine(Application.persistentDataPath,"ui-qa");
            Directory.CreateDirectory(output);
            var game = GooseGame.Instance; GooseSave.IsQa = true;
            int[,] sizes = { {360,640}, {390,844}, {430,932}, {768,1024}, {1024,768}, {390,844} };
            for (int i=0; i<sizes.GetLength(0); i++)
            {
                Screen.SetResolution(sizes[i,0], sizes[i,1], false);
                yield return new WaitForSecondsRealtime(1);
                if (i==5) game.Hud.GetComponent<GoosePhoneLayout>().SetPlatformSafeArea(new Rect(0,34f/844,1, (844-34-88f)/844));
                game.GoHome(); GooseSave.Daily=3; game.Hud.BuildHome();
                int themeIndex=i % game.Themes.Length;
                game.Hud.Home.transform.Find("Theme_"+game.Themes[themeIndex].id).GetComponent<Button>().onClick.Invoke();
                Check(game.ThemeIndex==themeIndex,"theme card selects "+game.Theme.id);
                yield return null; Canvas.ForceUpdateCanvases();
                string name = Screen.width+"x"+Screen.height+(i==5 ? "-safe" : "");
                CheckButtons(game.Hud.Home, name+" home");
                yield return new WaitForEndOfFrame(); ScreenCapture.CaptureScreenshot(Path.Combine(output,name+"-home.png"));
                foreach (string entry in new[] {"玩法","成绩"})
                {
                    var entryButton=game.Hud.Home.transform.Find(entry).GetComponent<Button>();
                    entryButton.onClick.Invoke();
                    Check(game.Hud.Modal, name+" opens "+entry);
                    CheckButtons(game.Hud.Modal,name+" "+entry);
                    game.Hud.CloseModal();
                }
                game.SelectDifficulty(1);
                game.Hud.Home.transform.Find("StartChallenge").GetComponent<Button>().onClick.Invoke();
                Check(game.Playing,"start button begins a round");
                float until = Time.realtimeSinceStartup+45;
                while (!game.SpawnComplete && Time.realtimeSinceStartup<until) yield return null;
                yield return new WaitForSecondsRealtime(2);
                Check(game.SpawnComplete, name+" actual round prepared");
                CheckButtons(game.Hud.Play, name+" play");
                var viewport = game.MainCamera.pixelRect;
                var tray = game.Hud.Play.transform.Find("Tray").GetComponent<RectTransform>();
                Vector3[] corners = new Vector3[4]; tray.GetWorldCorners(corners);
                Check(viewport.yMin >= RectTransformUtility.WorldToScreenPoint(EventCamera(tray),corners[1]).y, name+" world above tray");
                Check(viewport.width > 0 && viewport.height > 0, name+" positive viewport");
                bool picked = false;
                foreach (var item in game.Remaining)
                {
                    if (!item.DepthVisible) continue;
                    var p = game.MainCamera.WorldToScreenPoint(item.SelectionCollider.bounds.center);
                    if (!viewport.Contains(p)) continue;
                    game.PickAtScreenPosition(p);
                    if (game.Tray.Entries.Count > 0) { picked = true; break; }
                }
                Check(picked, name+" screen ray selects an actual item");
                yield return new WaitForSecondsRealtime(.5f);
                var button = game.Hud.Play.GetComponentInChildren<Button>();
                var hits = new List<RaycastResult>();
                var pauseScreen=RectTransformUtility.WorldToScreenPoint(EventCamera(button),button.transform.position);
                EventSystem.current.RaycastAll(new PointerEventData(EventSystem.current) {position = pauseScreen}, hits);
                Check(hits.Exists(hit => hit.gameObject.GetComponentInParent<Button>() == button), name+" pause receives UI raycast");
                button.onClick.Invoke(); Check(game.Paused && game.Hud.Modal, name+" pause opens modal");
                CheckButtons(game.Hud.Modal, name+" pause");
                yield return new WaitForEndOfFrame(); ScreenCapture.CaptureScreenshot(Path.Combine(output,name+"-pause.png"));
                game.Hud.CloseModal(); game.SetPaused(false);
                yield return new WaitForEndOfFrame(); ScreenCapture.CaptureScreenshot(Path.Combine(output,name+"-play.png"));
                game.GoHome();
            }
            report.passed = report.errors.Count==0;
            File.WriteAllText(Path.Combine(output,"ui-acceptance.json"),JsonUtility.ToJson(report,true));
            Application.Quit(report.passed ? 0 : 1);
        }
        static Camera EventCamera(Component component)
        {
            var canvas=component.GetComponentInParent<Canvas>();
            return canvas.renderMode==RenderMode.ScreenSpaceOverlay ? null : canvas.worldCamera;
        }
        void CheckButtons(GameObject root, string label)
        {
            foreach (var text in root.GetComponentsInChildren<Text>())
                if (!string.IsNullOrEmpty(text.text)) Check(text.preferredHeight <= text.rectTransform.rect.height+1, label+" text fits: "+text.text.Replace("\n"," / "));
            foreach(var b in root.GetComponentsInChildren<Button>())
            {
                Vector3[] c = new Vector3[4]; b.GetComponent<RectTransform>().GetWorldCorners(c);
                for(int i=0;i<c.Length;i++) c[i]=RectTransformUtility.WorldToScreenPoint(EventCamera(b),c[i]);
                bool inside=c[0].x>=-1 && c[0].y>=-1 && c[2].x<=Screen.width+1 && c[2].y<=Screen.height+1;
                bool sized=c[2].x-c[0].x>=43 && c[2].y-c[0].y>=43;
                var canvas=b.GetComponentInParent<Canvas>();
                string detail=inside && sized ? "" : " corners="+c[0]+".."+c[2]+" scale="+b.transform.lossyScale+" canvas="+canvas.renderMode+"/"+canvas.scaleFactor;
                if ((!inside || !sized) && (b.name.StartsWith("声") || b.name=="Ⅱ")) Debug.Log("[UiBounds] "+label+"/"+b.name+detail);
                Check(inside, label+" button "+b.name+" on screen"+detail);
                Check(sized, label+" button "+b.name+" touch size"+detail);
            }
        }
    }
}
#endif
