#if UNITY_EDITOR || DEVELOPMENT_BUILD
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
            game = GooseGame.Instance; GooseSave.IsQa = true;
            string[] args = Environment.GetCommandLineArgs(); int at = Array.IndexOf(args, "-gooseAlgorithmOutput");
            output = at >= 0 && at + 1 < args.Length ? args[at + 1] : Path.Combine(Application.persistentDataPath, "algorithm-qa");
            Directory.CreateDirectory(output); report.unityVersion = Application.unityVersion;
            if (EventSystem.current && EventSystem.current.GetComponent<StandaloneInputModule>())
                EventSystem.current.GetComponent<StandaloneInputModule>().enabled = false;
            StartCoroutine(Watchdog());
            yield return null;
            Check(game.AlgorithmSettings.weightedGeneration && game.AlgorithmSettings.depthManagement, "Weighted generation and depth profile enabled");
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
            // Controlled real-physics-scene probe for a deep covered item and support removal.
            game.GoHome(); game.SelectTheme(0); game.SelectDifficulty(0); game.BeginRound(false);
            while (!game.SpawnComplete) yield return null;
            var lower = game.CreateItem("apple"); var upper = game.CreateItem("apple");
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
        IEnumerator Watchdog()
        {
            yield return new WaitForSecondsRealtime(180);
            if (!done) { report.errors.Add("Algorithm acceptance timeout"); Finish(); }
        }
    }
}
#endif
