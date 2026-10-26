#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEngine.EventSystems;

namespace CatchGoose
{
    // Independent runtime acceptance for this change. No video, network or player save use.
    public sealed class GooseAlgorithmAcceptance : MonoBehaviour
    {
        [Serializable] class Snapshot { public string theme; public int total, hidden, held, dynamicBodies; public float visibleThreshold, rigidThreshold; }
        [Serializable] class Report
        {
            public bool passed;
            public string unityVersion;
            public List<string> checks = new List<string>(), errors = new List<string>();
            public List<Snapshot> snapshots = new List<Snapshot>();
        }
        readonly Report report = new Report();
        GooseGame game;
        string output;
        bool done;
        void OnEnable() { Application.logMessageReceived += Log; }
        void OnDisable() { Application.logMessageReceived -= Log; }
        void Log(string message, string stack, LogType type)
        { if (type == LogType.Error || type == LogType.Exception || type == LogType.Assert) report.errors.Add(message + "\n" + stack); }
        void Check(bool result, string label)
        { if (result) report.checks.Add(label); else report.errors.Add(label); }
        IEnumerator Start()
        {
            game = GooseGame.Instance; GooseSave.IsQa = true; game.InstantPicksForQa = true;
            string[] args = Environment.GetCommandLineArgs(); int at = Array.IndexOf(args, "-gooseAlgorithmOutput");
            output = at >= 0 && at + 1 < args.Length ? args[at + 1] : Path.Combine(Application.persistentDataPath, "algorithm-qa");
            Directory.CreateDirectory(output); report.unityVersion = Application.unityVersion;
            if (EventSystem.current && EventSystem.current.GetComponent<StandaloneInputModule>())
                EventSystem.current.GetComponent<StandaloneInputModule>().enabled = false;
            StartCoroutine(Watchdog());
            yield return null;
            if (Array.IndexOf(args, "-gooseCoreVisualQa") >= 0)
            { yield return CaptureCoreVisuals(); Finish(); yield break; }
            // Keep historical policy fixtures reproducible, then test the enabled
            // source-based profiles separately against their own expected stock.
            bool coreEnabled = game.CoreRounds.enabled;
            game.CoreRounds.enabled = false;
            // The historical 81+golden fixture requires nine distinct kinds.
            // Cached grocery currently has seven. Supplement this developer-only
            // fixture with real loaded IDs, then restore the scene family before
            // testing production core profiles. No JSON or live weights change.
            var originalFamilies=game.Themes.Select(t=>t.items).ToArray();
            var fixtureFamily=game.Themes.SelectMany(t=>t.items).Distinct().ToArray();
            foreach(var t in game.Themes)if(t.items.Length<9)t.items=t.items.Concat(fixtureFamily).Distinct().Take(9).ToArray();
            Check(game.AlgorithmSettings.weightedGeneration && game.AlgorithmSettings.depthManagement, "Weighted generation and depth profile enabled");
            Check(Mathf.Approximately(game.AlgorithmSettings.rigidDepthMultiplier, .5f)
                && Mathf.Approximately(game.AlgorithmSettings.visibleDepthMax, .5f)
                && Mathf.Approximately(game.AlgorithmSettings.referenceHeight, 2.1f)
                && Mathf.Approximately(game.AlgorithmSettings.frontierStep, .05f)
                && game.AlgorithmSettings.maxDynamicBodies == 70, "Serialized competitor scene profile reaches actual game settings");
            for (int theme = 0; theme < game.Themes.Length; theme++)
            {
                game.GoHome(); game.SelectTheme(theme); game.SelectDifficulty(2); game.BeginRound(false);
                float deadline = Time.realtimeSinceStartup + 30;
                while (!game.SpawnComplete && Time.realtimeSinceStartup < deadline) yield return null;
                Check(game.SpawnComplete, game.Theme.id + ": spawn deadline");
                yield return new WaitForSeconds(2);
                game.Depth.RefreshNow();
                var remaining = game.Remaining.ToList();
                Check(remaining.Count == 82 && remaining.Count(i => !i.Golden) == 81, game.Theme.id + ": finite stock, golden separate");
                Check(remaining.Where(i => !i.Golden).GroupBy(i => i.Id).All(g => g.Count() == 9), game.Theme.id + ": complete per-type triples");
                Check(remaining.Count(i => i.Frozen) == 7, game.Theme.id + ": frozen allocation preserved");
                Check(remaining.All(i => float.IsFinite(i.transform.position.y) && i.transform.position.y >= -.5f), game.Theme.id + ": actual pile retained above floor");
                Check(remaining.All(i => i.GetComponentsInChildren<Collider>().All(c => c.enabled) && i.Body.detectCollisions), game.Theme.id + ": support colliders retained");
                Check(remaining.Where(i => i.DepthHeld).All(i => i.Body.isKinematic), game.Theme.id + ": held state agrees with actual Rigidbody");
                Check(remaining.Where(i => !i.DepthVisible).All(i => i.gameObject.activeInHierarchy && i.GetComponentsInChildren<Renderer>().All(r => !r.enabled)), game.Theme.id + ": hiding retains logical inventory");
                report.snapshots.Add(new Snapshot { theme = game.Theme.id, total = remaining.Count, hidden = game.Depth.HiddenCount,
                    held = game.Depth.HeldCount, dynamicBodies = game.Depth.DynamicCount, visibleThreshold = game.Depth.VisibleThreshold, rigidThreshold = game.Depth.RigidThreshold });
                var hidden = remaining.FirstOrDefault(i => !i.DepthVisible && !i.Frozen);
                if (hidden)
                { int count = remaining.Count; Check(!game.Pick(hidden) && game.Remaining.Count() == count, game.Theme.id + ": hidden manual pick rejected"); }
                var stock = remaining.GroupBy(i => i.Id).ToDictionary(g => g.Key, g => g.Count());
                Check(game.UseProp(2), game.Theme.id + ": shuffle available");
                Check(game.Remaining.All(i => !i.DepthHeld && !i.Body.isKinematic), game.Theme.id + ": shuffle wakes held pile");
                Check(stock.All(g => game.Remaining.Count(i => i.Id == g.Key) == g.Value), game.Theme.id + ": shuffle creates no replacement stock");
                yield return new WaitForSeconds(1);
                // Automated selection exercises actual matching, inventory and score code;
                // it intentionally bypasses occlusion, which is separately checked above.
                foreach (var item in game.Remaining.Where(i => i.Frozen).ToList()) item.SetFrozen(false);
                foreach (var group in game.Remaining.Where(i => !i.Golden).GroupBy(i => i.Id).ToList())
                    foreach (var item in group.ToList()) { game.Pick(item, true); yield return null; }
                Check(game.LastResult == "win" && game.Removed == 81, game.Theme.id + ": weighted finite round clears without refill");
            }
            for(int i=0;i<game.Themes.Length;i++)game.Themes[i].items=originalFamilies[i];
            // Project-specific nonuniform fixture: tests quota wiring with our own
            // models; it does not assert a competitor-to-theme asset correspondence.
            game.GoHome(); game.SelectTheme(0); game.SelectDifficulty(0);
            var originalGroupWeights = game.Theme.groupWeights;
            game.Theme.groupWeights = new[] { 1f, 2, 3, 4 };
            game.BeginRound(false);
            while (!game.SpawnComplete) yield return null;
            game.Theme.groupWeights = originalGroupWeights;
            int[] quotaGroups = { 2, 3, 5, 6 };
            Check(game.Remaining.Count() == 48, "Nonuniform group quotas preserve round total");
            Check(Enumerable.Range(0, 4).All(i => game.Remaining.Count(item => item.Id == game.Theme.items[i]) == quotaGroups[i] * 3), "Nonuniform group quotas reach actual spawned models");
            foreach (var group in game.Remaining.GroupBy(i => i.Id).ToList())
                foreach (var item in group.ToList()) { game.Pick(item, true); yield return null; }
            Check(game.LastResult == "win" && game.Removed == 48, "Nonuniform quota round clears without refill");
            var originalOverrides = game.LevelTuning.overrides;
            game.LevelTuning.overrides = new[] { new LevelTuning {
                enabled = true, themeId = game.Theme.id, difficulty = 0, hotfixTypeCountOffset = "-2",
                abEnabled = true, manualBucket = 11, forkKeys = new[] { "base", "plus" },
                forkWeights = new[] { 10, 10 }, typeCountOffsetValues = "0,1" } };
            game.GoHome(); game.BeginRound(false);
            while (!game.SpawnComplete) yield return null;
            Check(game.Level.kinds == 3 && game.Total == 48 && game.Remaining.Count() == 48,
                "Hotfix and explicit AB bucket reach spawned level, preserving triple budget");
            Check(game.Remaining.Select(i => i.Id).Distinct().Count() == 3, "Tuned type count reaches actual models");
            foreach (var group in game.Remaining.GroupBy(i => i.Id).ToList())
                foreach (var item in group.ToList()) { game.Pick(item, true); yield return null; }
            Check(game.LastResult == "win" && game.Removed == 48, "Tuned fixed-stock round clears");
            game.LevelTuning.overrides = originalOverrides;
            game.CoreRounds.enabled = coreEnabled;
            for (int coreCase = 0; coreCase < 3 + game.Themes.Length - 1; coreCase++)
            {
                int difficulty = coreCase < 3 ? coreCase : 2;
                int themeIndex = coreCase < 3 ? 0 : coreCase - 2;
                game.GoHome(); game.SelectTheme(themeIndex); game.SelectDifficulty(difficulty); game.BeginRound(false);
                float start = Time.realtimeSinceStartup;
                while (!game.SpawnComplete && Time.realtimeSinceStartup - start < 35) yield return null;
                Check(game.SpawnComplete, "Core profile " + difficulty + ": spawn completes");
                yield return new WaitForSeconds(2);
                int expected = new[] { 15, 60, 300 }[difficulty];
                var stock = game.Remaining.ToList();
                report.snapshots.Add(new Snapshot { theme = game.Theme.id + "/core-" + difficulty, total = stock.Count,
                    hidden = game.Depth.HiddenCount, held = game.Depth.HeldCount, dynamicBodies = game.Depth.DynamicCount,
                    visibleThreshold = game.Depth.VisibleThreshold, rigidThreshold = game.Depth.RigidThreshold });
                Check(game.Level.competitorCore && game.Total == expected && stock.Count == expected,
                    "Core profile " + difficulty + ": complete source layer budget reaches scene");
                Check(stock.All(i => !i.Golden && !i.Frozen) && stock.GroupBy(i => i.Id).All(g => g.Count() % 3 == 0),
                    "Core profile " + difficulty + ": only complete triples, no single bonus goose or added ice");
                Check(stock.All(i => float.IsFinite(i.transform.position.y) && i.transform.position.y >= -.5f),
                    "Core profile " + difficulty + ": dense pile remains supported");
                Check(difficulty != 0 || (game.Level.seconds == 0 && stock.Count(i => i.Id == "goose") == 3 && !game.Paused),
                    "Core intro: three target geese, unlimited timer and no immediate timeout");
                if (difficulty == 1)
                {
                    foreach (var item in stock.GroupBy(i => i.Id).Take(3).Select(g => g.First())) game.Pick(item, true);
                    Check(game.Tray.Entries.Count == 3 && game.UseProp(0) && game.Stored.Count == 3 && game.Tray.Entries.Count == 0,
                        "Core remove: three picked items move to separate storage without respawning");
                    Check(!game.UseProp(0), "Core tool limit: second remove is rejected");
                    foreach (var stored in game.Stored) stored.SetDepthVisible(false);
                    int attempts = game.Stored.Count;
                    for (int i = 0; i < attempts; i++) Check(game.PickStored(0), "Core storage item returns through normal tray matching");
                }
                Check(Enumerable.Range(0, game.Level.pileLayers.Length).All(i => stock.Count(item => item.GenerationLayer == i) == game.Level.pileLayers[i].normalCount + (i == 0 ? game.Level.targetCount : 0)),
                    "Core profile " + difficulty + ": every source layer budget reaches physical items");
                foreach (var group in stock.GroupBy(i => i.Id).ToList())
                    foreach (var item in group.ToList()) { game.Pick(item, true); yield return null; }
                Check(game.LastResult == "win" && game.Removed == expected,
                    "Core profile " + difficulty + ": whole finite stock clears without replacement");
            }
            game.CoreRounds.enabled = false;
            // Controlled real-physics-scene probe for a deep covered item and support removal.
            game.GoHome(); game.SelectTheme(0); game.SelectDifficulty(0); game.BeginRound(false);
            while (!game.SpawnComplete) yield return null;
            var lower = game.CreateItem("ref_apple"); var upper = game.CreateItem("ref_apple");
            foreach (var item in new[] { lower, upper })
            { item.DepthReady = true; item.DepthStillSince = Time.time - 2; item.SetDepthHeld(true); }
            lower.transform.position = new Vector3(100, 0, 0);
            upper.transform.position = new Vector3(100, 2, 0);
            upper.transform.localScale = Vector3.one * 2;
            game.Depth.SpawnFinished();
            yield return new WaitForSeconds(game.AlgorithmSettings.spawnProtection + .15f);
            upper.transform.position = new Vector3(100, 2, 0);
            Physics.SyncTransforms(); game.Depth.RefreshNow();
            Check(lower.DepthHeld && !lower.DepthVisible && lower.Body.isKinematic, "Controlled probe: covered deep item is held and hidden");
            Check(lower.gameObject.activeInHierarchy && lower.GetComponentsInChildren<Collider>().All(c => c.enabled), "Controlled probe: hidden support retained");
            Check(!game.Pick(lower), "Controlled probe: hidden item cannot be manually picked");
            game.Pick(upper, true);
            Check(!lower.DepthHeld && !lower.Body.isKinematic, "Controlled probe: removing support wakes the pile immediately");
            Physics.SyncTransforms(); game.Depth.RefreshNow();
            Check(lower.DepthVisible, "Controlled probe: isolated deep item is revealed by occlusion guard");
            game.GoHome();
            Finish();
        }
        void Finish()
        {
            done = true; report.passed = report.errors.Count == 0;
            File.WriteAllText(Path.Combine(output, "algorithm-acceptance.json"), JsonUtility.ToJson(report, true));
            Debug.Log("[GooseAlgorithmQA] " + (report.passed ? "PASS" : "FAIL") + " " + report.checks.Count + " checks, " + report.errors.Count + " errors");
            if (!Application.isEditor) Application.Quit(report.passed ? 0 : 1);
        }
        IEnumerator CaptureCoreVisuals()
        {
            game.GoHome(); yield return new WaitForEndOfFrame();
            CaptureView(Path.Combine(output, "core-home.png")); yield return new WaitForEndOfFrame();
            for (int visualCase = 0; visualCase < 3 + game.Themes.Length - 1; visualCase++)
            {
                int difficulty = visualCase < 3 ? visualCase : 2;
                int theme = visualCase < 3 ? 0 : visualCase - 2;
                game.SelectTheme(theme); game.SelectDifficulty(difficulty); game.BeginRound(false);
                float deadline = Time.realtimeSinceStartup + 30;
                while (!game.SpawnComplete && Time.realtimeSinceStartup < deadline) yield return null;
                yield return new WaitForSeconds(3);
                Check(game.SpawnComplete && game.Remaining.Count() == new[] {15,60,300}[difficulty], "Rendered core stock " + difficulty);
                if (difficulty == 1)
                {
                    foreach (var item in game.Remaining.GroupBy(i => i.Id).Take(3).Select(g => g.First()).ToList()) game.Pick(item, true);
                    Check(game.UseProp(0) && game.Stored.Count == 3, "Rendered temporary storage");
                }
                yield return new WaitForEndOfFrame();
                string file = Path.Combine(output, (theme == 0 ? "core-" + difficulty : game.Theme.id + "-core-" + difficulty) + ".png");
                CaptureView(file); yield return new WaitForEndOfFrame();
                yield return new WaitForSeconds(.2f);
                Check(File.Exists(file), "Screenshot written " + difficulty);
                game.GoHome();
            }
        }
        void CaptureView(string file)
        {
            // A hidden desktop window can return a black swapchain screenshot.
            // Explicitly render actual scene cameras and the actual HUD to a target.
            var rt = RenderTexture.GetTemporary(450, 844, 24, RenderTextureFormat.ARGB32);
            var uiObject = new GameObject("VisualQaCamera"); var ui = uiObject.AddComponent<Camera>();
            ui.orthographic = true; ui.clearFlags = CameraClearFlags.Depth; ui.cullingMask = 1 << 31;
            ui.nearClipPlane = .01f; ui.farClipPlane = 100; ui.transform.position = new Vector3(0, 0, -10);
            ui.targetTexture = rt;
            var canvases = FindObjectsOfType<Canvas>().Where(c => c.renderMode == RenderMode.ScreenSpaceOverlay).ToList();
            var originalLayers = new Dictionary<GameObject, int>();
            foreach (var canvas in canvases)
            {
                foreach (var tr in canvas.GetComponentsInChildren<Transform>(true))
                { originalLayers[tr.gameObject] = tr.gameObject.layer; tr.gameObject.layer = 31; }
                canvas.renderMode = RenderMode.ScreenSpaceCamera; canvas.worldCamera = ui; canvas.planeDistance = 10;
            }
            Canvas.ForceUpdateCanvases();
            foreach (var camera in FindObjectsOfType<Camera>().Where(c => c != ui).OrderBy(c => c.depth))
            {
                int mask = camera.cullingMask; var previous = camera.targetTexture;
                camera.cullingMask &= ~(1 << 31); camera.targetTexture = rt; camera.Render();
                camera.targetTexture = previous; camera.cullingMask = mask;
            }
            ui.Render();
            var active = RenderTexture.active; RenderTexture.active = rt;
            var image = new Texture2D(450, 844, TextureFormat.RGBA32, false);
            image.ReadPixels(new Rect(0, 0, 450, 844), 0, 0); image.Apply();
            Check(image.GetPixels32().Select(p => (uint)p.r << 16 | (uint)p.g << 8 | p.b).Distinct().Take(32).Count() >= 32,
                "Offscreen frame contains scene and UI colors: " + Path.GetFileName(file));
            File.WriteAllBytes(file, image.EncodeToPNG());
            RenderTexture.active = active;
            foreach (var canvas in canvases) { canvas.renderMode = RenderMode.ScreenSpaceOverlay; canvas.worldCamera = null; }
            foreach (var entry in originalLayers) entry.Key.layer = entry.Value;
            Destroy(image); Destroy(uiObject); RenderTexture.ReleaseTemporary(rt);
        }
        IEnumerator Watchdog()
        {
            yield return new WaitForSecondsRealtime(300);
            if (!done) { report.errors.Add("Algorithm acceptance timeout"); Finish(); }
        }
    }
}
#endif
