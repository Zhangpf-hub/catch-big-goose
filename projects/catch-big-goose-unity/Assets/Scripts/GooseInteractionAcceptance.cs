#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;

namespace CatchGoose
{
    public sealed class GooseInteractionAcceptance : MonoBehaviour
    {
        [Serializable] sealed class Report
        {
            public bool passed;
            public List<string> checks = new List<string>(), errors = new List<string>();
            public List<float> revealHeights = new List<float>();
            public Vector2 flightStart, flightMiddle, flightEnd, slot;
        }
        readonly Report report = new Report();
        GooseGame game; string output; bool done;
        void OnEnable() { Application.logMessageReceived += Log; }
        void OnDisable() { Application.logMessageReceived -= Log; }
        void Log(string message, string stack, LogType type)
        { if(type == LogType.Error || type == LogType.Exception || type == LogType.Assert) report.errors.Add(message + "\n" + stack); }
        void Check(bool ok, string name) { if(ok) report.checks.Add(name); else report.errors.Add(name); }
        IEnumerator Start()
        {
            game = GooseGame.Instance; GooseSave.IsQa = true;
            var args = Environment.GetCommandLineArgs(); int at = Array.IndexOf(args,"-gooseInteractionOutput");
            output = at >= 0 ? args[at+1] : Path.Combine(Application.persistentDataPath,"interaction-qa");
            Directory.CreateDirectory(output); StartCoroutine(Watchdog()); yield return null;
            game.GoHome(); game.SelectTheme(0); game.SelectDifficulty(0); game.BeginRound(false);
            var revealed = new HashSet<GooseItem>(); float last = float.NegativeInfinity;
            float deadline = Time.realtimeSinceStartup + 40;
            bool early = false, middle = false;
            while (!game.SpawnComplete && Time.realtimeSinceStartup < deadline)
            {
                var fresh = game.Items.Where(i=>i.DepthVisible && !revealed.Contains(i)).OrderBy(i=>i.transform.position.y).ToList();
                foreach(var item in fresh)
                {
                    Check(item.transform.position.y + .001f >= last, "Opening reveals in ascending height: " + revealed.Count);
                    last = item.transform.position.y; report.revealHeights.Add(last); revealed.Add(item);
                    Check(item.Body.isKinematic, "Opening has stationary collision support: " + revealed.Count);
                }
                if(!early && revealed.Count>0 && revealed.Count<game.Total) { Capture("opening-bottom.png"); early=true; }
                if(!middle && revealed.Count>=game.Total/2 && revealed.Count<game.Total) { Capture("opening-middle.png"); middle=true; }
                yield return null;
            }
            Check(game.SpawnComplete && revealed.Count==game.Total,"Opening reveals exact stock before enabling play");
            var openingPositions = game.Items.ToDictionary(i=>i,i=>i.transform.position);
            yield return new WaitForSeconds(.6f); Capture("opening-complete.png");
            Check(game.Items.All(i=>Vector3.Distance(i.transform.position,openingPositions[i])<.35f),"Grown-in pile stays at its supports instead of falling from above");
            var group = game.Remaining.Where(i=>!i.Frozen).GroupBy(i=>i.Id).First(g=>g.Count()>=3).Take(3).ToArray();
            var item0=group[0]; item0.SetDepthVisible(true);
            report.flightStart=game.MainCamera.WorldToScreenPoint(item0.VisualBounds.center);
            Check(game.Pick(item0),"Normal pick accepted");
            Check(item0.gameObject.activeSelf && game.Presentation.Contains(item0),"Picked object remains an active 3D mesh");
            Check(Vector2.Distance(game.Presentation.ScreenPosition(item0),report.flightStart)<2,"Camera transfer preserves starting screen position");
            Check(item0.Colliders.All(c=>!c.enabled) && item0.Body.isKinematic,"Flying object stops participating in pile physics");
            Check(!game.Hud.Slots[0].enabled,"Slot does not display a duplicate icon before arrival");
            yield return new WaitForSeconds(.14f); report.flightMiddle=game.Presentation.ScreenPosition(item0); Capture("pick-middle.png");
            report.slot=game.Hud.TrayScreenPoint(0);
            Check(Vector2.Distance(report.flightMiddle,report.flightStart)>5 && Vector2.Distance(report.flightMiddle,report.slot)>5,"Flight has a visible intermediate position");
            game.SetPaused(true); var paused=game.Presentation.ScreenPosition(item0);
            yield return new WaitForSecondsRealtime(.2f);
            Check(Vector2.Distance(paused,game.Presentation.ScreenPosition(item0))<1,"Pause freezes in-flight movement"); game.SetPaused(false);
            yield return new WaitForSeconds(.6f); report.flightEnd=game.Presentation.ScreenPosition(item0); Capture("pick-arrived.png");
            Check(Vector2.Distance(report.flightEnd,report.slot)<2,"Mesh arrives at actual HUD slot centre");
            Check(game.Pick(group[1],true),"Second matching pick uses production animation"); yield return new WaitForSeconds(.6f);
            int removed=game.Removed; Check(game.Pick(group[2],true),"Third matching pick accepted");
            Check(game.Removed==removed && game.Playing && game.PendingMatches==1 && !game.Busy,"Match waits for its own arrival without locking input");
            yield return new WaitForSeconds(.15f); Capture("triple-in-flight.png");
            yield return new WaitForSeconds(.8f);
            Check(game.Removed==removed+3 && group.All(i=>!i.gameObject.activeSelf),"Arrived triple animates then returns to pool");
            Check(group.All(i=>!game.Presentation.Contains(i)),"Matched meshes leave the presentation table");
            yield return Round(2);
            Capture("master-opening-complete.png");
            var groups=game.Remaining.GroupBy(i=>i.Id).Where(g=>g.Count()>=3).Take(6).Select(g=>g.Take(3).ToArray()).ToArray();
            game.Pick(groups[0][0],true); game.Pick(groups[1][0],true);
            yield return new WaitForSeconds(.6f);
            var before=game.Presentation.ScreenPosition(groups[1][0]); game.Pick(groups[0][1],true);
            Check(Vector2.Distance(before,game.Presentation.ScreenPosition(groups[1][0]))<1,"Inserting same kind starts reflow without teleporting neighbour");
            yield return new WaitForSeconds(.6f);
            Check(Vector2.Distance(game.Presentation.ScreenPosition(groups[1][0]),game.Hud.TrayScreenPoint(2))<2,"Neighbour slides to reordered slot"); Capture("tray-reordered.png");
            for(int i=2;i<5;i++) game.Pick(groups[i][0],true);
            yield return new WaitForSeconds(.6f);
            Check(game.Tray.Entries.Count==6,"Six-slot fixture contains a matching pair");
            game.Pick(groups[0][2],true);
            Check(game.Playing && game.PendingMatches==1 && !game.Busy,"Seventh item completing a triple releases input capacity");
            Check(game.Pick(groups[5][0],true),"Another pick is accepted during pending triple");
            yield return new WaitForSeconds(1);
            Check(game.Playing && game.Tray.Entries.Count==5 && game.Removed==3,"Seventh-slot triple and concurrent pick finish with five survivors");
            yield return new WaitForSeconds(.3f);
            Check(game.UseProp(0),"Remove prop accepted after tray settles"); yield return new WaitForSeconds(.6f); Capture("stored-models.png");
            Check(game.Stored.Count==3 && game.Stored.All(i=>game.Presentation.Contains(i)),"Storage retains three animated 3D objects");
            var stored=game.Stored[0]; Check(game.PickStored(0),"Stored model flies back to tray");
            yield return new WaitForSeconds(.6f); Check(game.Tray.Entries.Contains(stored),"Stored pick reserves and reaches tray");
            var next=game.Remaining.First(); game.Pick(next,true); game.GoHome();
            Check(game.Items.Count==0 && !game.Presentation.Contains(next) && !game.Presentation.Moving,"Return home cancels flight and clears presentation");
            yield return Round(2);
            var singles=game.Remaining.GroupBy(i=>i.Id).Take(7).Select(g=>g.First()).ToArray();
            foreach(var item in singles) game.Pick(item,true);
            Check(game.Playing && game.Busy,"Full tray waits for final arrival before showing loss");
            // The current reward policy pauses on the revive dialog. A scaled
            // wait would deadlock this historical harness at timeScale=0.
            yield return new WaitForSecondsRealtime(1.2f);
            if(game.Rewards.AwaitingRevive)
            {
                Check(game.Playing && game.Paused && !game.CurrentSelectedItem,"Full tray opens revive only after arrival and clears preview");
                game.EndFailedRound();
            }
            Check(!game.Playing && game.LastResult=="槽位已满","Full-tray loss is committed after animation"); Capture("full-tray-result.png");
            game.GoHome(); Finish();
        }
        IEnumerator Round(int difficulty)
        {
            game.GoHome(); game.SelectDifficulty(difficulty); game.BeginRound(false);
            float end=Time.realtimeSinceStartup+40;
            while(!game.SpawnComplete && Time.realtimeSinceStartup<end) yield return null;
            Check(game.SpawnComplete,"Round creation deadline"); yield return new WaitForSeconds(.6f);
        }
        void Capture(string name)
        {
            var rt=RenderTexture.GetTemporary(450,844,24,RenderTextureFormat.ARGB32);
            var go=new GameObject("CaptureCamera"); var camera=go.AddComponent<Camera>();
            camera.orthographic=true; camera.clearFlags=CameraClearFlags.Depth; camera.cullingMask=1<<31;
            camera.transform.position=new Vector3(0,0,-10); camera.targetTexture=rt;
            var overlays=FindObjectsOfType<Canvas>().Where(c=>c.renderMode==RenderMode.ScreenSpaceOverlay).ToList();
            var layers=new Dictionary<GameObject,int>();
            foreach(var canvas in overlays)
            {
                foreach(var tr in canvas.GetComponentsInChildren<Transform>(true)) { layers[tr.gameObject]=tr.gameObject.layer; tr.gameObject.layer=31; }
                canvas.renderMode=RenderMode.ScreenSpaceCamera; canvas.worldCamera=camera; canvas.planeDistance=10;
            }
            Canvas.ForceUpdateCanvases();
            foreach(var view in FindObjectsOfType<Camera>().Where(c=>c!=camera && c.enabled).OrderBy(c=>c.depth))
            {
                int mask=view.cullingMask; var target=view.targetTexture;
                view.cullingMask &= ~(1<<31); view.targetTexture=rt; view.Render(); view.targetTexture=target; view.cullingMask=mask;
            }
            camera.Render(); var active=RenderTexture.active; RenderTexture.active=rt;
            var image=new Texture2D(450,844,TextureFormat.RGBA32,false); image.ReadPixels(new Rect(0,0,450,844),0,0); image.Apply();
            File.WriteAllBytes(Path.Combine(output,name),image.EncodeToPNG()); RenderTexture.active=active;
            foreach(var canvas in overlays) { canvas.renderMode=RenderMode.ScreenSpaceOverlay; canvas.worldCamera=null; }
            foreach(var pair in layers) pair.Key.layer=pair.Value;
            Destroy(image); Destroy(go); RenderTexture.ReleaseTemporary(rt);
        }
        void Finish()
        {
            if(done)return; done=true; report.passed=report.errors.Count==0;
            File.WriteAllText(Path.Combine(output,"interaction.json"),JsonUtility.ToJson(report,true));
            Application.Quit(report.passed?0:1);
        }
        IEnumerator Watchdog() { yield return new WaitForSecondsRealtime(180); if(!done) { report.errors.Add("Interaction QA timeout"); Finish(); } }
    }
}
#endif
