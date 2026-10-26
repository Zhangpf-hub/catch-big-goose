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
    // Own visible-only policy. Uses the production screen ray and storage/tool
    // actions. Neither reads concealed stock for decisions nor calls Pick(true).
    public sealed class GooseExperienceAcceptance : MonoBehaviour
    {
        [Serializable] class Round
        {
            public string theme, result;
            public int difficulty, total, removed, clicks, storedClicks, peakTray, failedClicks, outOfBounds;
            public uint seed;
            public float gameSeconds, wallSeconds;
            public int[] tools = new int[3], layerCounts, layerKinds;
        }
        [Serializable] class Report
        {
            public bool passed;
            public string policy = "Visible screen-ray candidates and tray/storage only; .25 game seconds/action; no revive; own seeds. Scripted samples, not human win rate.";
            public List<Round> rounds = new List<Round>();
            public List<string> checks = new List<string>(), errors = new List<string>();
        }
        class Choice { public GooseItem item; public Vector2 screen; public int stored = -1; }
        readonly Report report = new Report();
        GooseGame game; string output; bool finished;
        void Check(bool ok, string label) { (ok ? report.checks : report.errors).Add(label); }
        void OnEnable() { Application.logMessageReceived += Log; }
        void OnDisable() { Application.logMessageReceived -= Log; }
        void Log(string message, string stack, LogType type)
        { if (type == LogType.Error || type == LogType.Exception || type == LogType.Assert) report.errors.Add(message + "\n" + stack); }
        IEnumerator Start()
        {
            game = GooseGame.Instance; GooseSave.IsQa = true;
            var args = Environment.GetCommandLineArgs(); int at = Array.IndexOf(args, "-gooseExperienceOutput");
            output = at >= 0 ? args[at + 1] : Path.Combine(Application.persistentDataPath, "experience-qa");
            Directory.CreateDirectory(output);
            if (EventSystem.current) foreach (var input in EventSystem.current.GetComponents<BaseInputModule>()) input.enabled = false;
            StartCoroutine(Watchdog()); yield return null;
            foreach (var theme in game.Themes)
            {
                Check(theme.items.Length >= 7 && theme.items.Distinct().Count() == theme.items.Length, theme.id + ": unique cached scene kinds");
                Check(theme.coreGroupWeights != null && theme.coreGroupWeights.Length == theme.items.Length && theme.coreGroupWeights.All(w => w > 0 && float.IsFinite(w)), theme.id + ": aligned finite positive quota weights");
                foreach (var id in theme.items)
                {
                    Check(Resources.Load<GameObject>("Models/" + id + "/" + id) && Resources.Load<Texture2D>("Icons/" + id), theme.id + "/" + id + ": model and icon loaded");
                    var item = game.CreateItem(id);
                    Check(item.Body && item.GetComponentsInChildren<Collider>().Any(c => c.enabled) && item.GetComponentsInChildren<Renderer>().Any(), id + ": real Unity collider and renderer");
                    item.gameObject.SetActive(false); game.Forget(item); Destroy(item.gameObject);
                }
            }
            bool reference=Array.IndexOf(args,"-gooseReferenceExperience")>=0;
            int sampleAt=Array.IndexOf(args,"-gooseExperienceSamples"),speedAt=Array.IndexOf(args,"-gooseExperienceSpeed");
            int samples=reference?2:sampleAt>=0?int.Parse(args[sampleAt+1]):20;
            float speed=speedAt>=0?float.Parse(args[speedAt+1],System.Globalization.CultureInfo.InvariantCulture):3;
            for (int sample = 0; sample < samples; sample++)
            {
                int difficulty = sample < 15 ? sample % 3 : 2;
                int theme = sample < 15 ? sample / 3 : sample - 15;
                game.GoHome(); game.SelectTheme(theme); game.SelectDifficulty(difficulty);
                uint seed = (uint)(new[] { 104729, 130363, 155921 }[difficulty] + (sample >= 15 ? 7919 : 0));
                UnityEngine.Random.InitState((int)seed);
                if(reference)game.BeginReferenceTrial(sample==0?126:300);else game.BeginExperienceRound(seed);
                Time.timeScale = speed;
                float wallStart = Time.realtimeSinceStartup, gameStart = Time.time;
                while (!game.SpawnComplete && Time.realtimeSinceStartup - wallStart < 45) yield return null;
                Check(game.SpawnComplete, game.Theme.id + "/" + difficulty + ": spawn complete");
                yield return new WaitForSeconds(2);
                var stock = game.Remaining.ToList();
                var row = new Round { theme = game.Theme.id, difficulty = difficulty, seed = seed, total = game.Total,
                    layerCounts = Enumerable.Range(0, game.Level.pileLayers.Length).Select(i => stock.Count(x => x.GenerationLayer == i)).ToArray(),
                    layerKinds = Enumerable.Range(0, game.Level.pileLayers.Length).Select(i => stock.Where(x => x.GenerationLayer == i && (game.Level.targetCount == 0 || x.Id != game.Level.targetItem)).Select(x => x.Id).Distinct().Count()).ToArray() };
                Check(stock.Count == row.total, row.theme + "/" + difficulty + ": exact inventory");
                if (difficulty == 2) Check(row.layerKinds[0] <= Math.Min(game.Theme.items.Length,game.Level.pileLayers[0].kinds),
                    row.theme + ": first-layer kinds respect profile and actual cached catalog");
                int idle = 0;
                while (game.Playing && !game.Paused && Time.realtimeSinceStartup - wallStart < 120)
                {
                    if (game.Busy) { yield return null; continue; }
                    var choices = VisibleChoices();
                    var tray = game.Tray.Entries.GroupBy(i => i.Id).ToDictionary(g => g.Key, g => g.Count());
                    var available = choices.GroupBy(c => c.item.Id).ToDictionary(g => g.Key, g => g.Count());
                    Func<Choice, int> score = c => {
                        int n = tray.TryGetValue(c.item.Id, out var count) ? count : 0;
                        int seen = available[c.item.Id];
                        return n == 2 ? 1000 : n == 1 && seen >= 2 ? 800 : n == 0 && seen >= 3 ? 600 : n == 1 ? 400 : seen >= 2 ? 200 : 0;
                    };
                    var best = choices.OrderByDescending(score).ThenByDescending(c => c.stored >= 0).FirstOrDefault();
                    bool risky = game.Tray.Entries.Count >= 5 && (best == null || score(best) < 600);
                    bool used = false;
                    if (risky || best == null)
                    {
                        foreach (int tool in new[] { 1, 0, 2 })
                            if (game.UseProp(tool)) { row.tools[tool]++; used = true; break; }
                    }
                    if (!used && best != null)
                    {
                        if (best.stored >= 0) { if (game.PickStored(best.stored)) row.storedClicks++; else row.failedClicks++; }
                        else { game.PickAtScreenPosition(best.screen); if (best.item.Picked) row.clicks++; else row.failedClicks++; }
                        idle = 0;
                    }
                    else if (!used && ++idle > 12) { row.result = "no-visible-action"; break; }
                    row.peakTray = Math.Max(row.peakTray, game.Tray.Entries.Count);
                    // A timeout pauses game time. Do not leave this acceptance
                    // coroutine stuck inside a scaled wait instead of reporting it.
                    float resumeAt=Time.time+.25f;
                    while(game.Playing&&!game.Paused&&Time.time<resumeAt)yield return null;
                }
                row.removed = game.Removed;
                if (string.IsNullOrEmpty(row.result)) row.result = game.LastResult.Length > 0 ? game.LastResult : game.Paused ? "timeout-dialog" : "sample-wall-limit";
                row.gameSeconds = Time.time - gameStart; row.wallSeconds = Time.realtimeSinceStartup - wallStart;
                row.outOfBounds = game.Remaining.Count(i => !float.IsFinite(i.transform.position.y) || i.transform.position.y < -.5f);
                Check(row.failedClicks == 0 && row.outOfBounds == 0, row.theme + "/" + difficulty + ": ray clicks accepted and pile retained");
                Check(row.result != "win" || row.removed == row.total, row.theme + "/" + difficulty + ": win consumes full inventory");
                report.rounds.Add(row); Save(); Debug.Log("[Experience] " + JsonUtility.ToJson(row));
                yield return null;
            }
            game.GoHome(); Finish();
        }
        List<Choice> VisibleChoices()
        {
            var choices = new Dictionary<GooseItem, Choice>();
            foreach (var item in game.Remaining.Where(i => i.DepthVisible && !i.Frozen))
            {
                var col = item.GetComponentsInChildren<Collider>().FirstOrDefault(c => c.enabled);
                if (!col) continue;
                var b = col.bounds;
                foreach (var offset in new[] { Vector3.zero, Vector3.right * .55f, Vector3.left * .55f, Vector3.forward * .55f, Vector3.back * .55f })
                {
                    var screen = game.MainCamera.WorldToScreenPoint(b.center + Vector3.Scale(b.extents, offset));
                    if (screen.x < 0 || screen.x >= Screen.width || screen.y < 0 || screen.y >= Screen.height) continue;
                    var ray = game.MainCamera.ScreenPointToRay(screen);
                    var hit = Physics.RaycastAll(ray, 100).OrderBy(h => h.distance).Select(h => h.collider.GetComponentInParent<GooseItem>()).FirstOrDefault(x => x && !x.Picked && x.DepthVisible);
                    if (hit == item) { choices[item] = new Choice { item = item, screen = screen }; break; }
                }
            }
            var list = choices.Values.ToList();
            for (int i = 0; i < game.Stored.Count; i++) list.Add(new Choice { item = game.Stored[i], stored = i });
            return list;
        }
        void Save() { report.passed = report.errors.Count == 0; File.WriteAllText(Path.Combine(output, "experience.json"), JsonUtility.ToJson(report, true)); }
        void Finish() { if (finished) return; finished = true; Save(); Application.Quit(report.passed ? 0 : 1); }
        IEnumerator Watchdog() { yield return new WaitForSecondsRealtime(1200); if (!finished) { report.errors.Add("Watchdog timeout"); Finish(); } }
    }
}
#endif
