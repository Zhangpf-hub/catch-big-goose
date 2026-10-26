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
    // Development player only. Runs the actual imported models, physics, game rules and HUD.
    public sealed class GooseAcceptance : MonoBehaviour
    {
        [Serializable] class Report { public string unityVersion; public bool passed; public List<string> checks = new List<string>(); public List<string> errors = new List<string>(); }
        Report report = new Report();
        [Serializable] class PhysicsSnapshot { public string theme; public List<PieceState> pieces = new List<PieceState>(); }
        [Serializable] class PieceState { public string id; public Vector3 position, velocity, colliderCenter, colliderSize; public bool kinematic, visible; }
        GooseGame game;
        string output;
        bool finished;
        void OnEnable() { Application.logMessageReceived += Log; }
        void OnDisable() { Application.logMessageReceived -= Log; }
        void Log(string message, string stack, LogType type)
        { if (type == LogType.Error || type == LogType.Exception || type == LogType.Assert) report.errors.Add(message + "\n" + stack); }
        IEnumerator Start()
        {
            game = GooseGame.Instance; GooseSave.IsQa = true;
            // Historical video/reward regression fixtures use the legacy profiles.
            // Enabled core profiles have their own GooseAlgorithmAcceptance cases.
            game.CoreRounds.enabled = false;
            // Keep desktop input from changing an automated run while the user works.
            if (EventSystem.current && EventSystem.current.GetComponent<StandaloneInputModule>())
                EventSystem.current.GetComponent<StandaloneInputModule>().enabled = false;
            string[] args = Environment.GetCommandLineArgs(); int at = Array.IndexOf(args, "-gooseQaOutput");
            output = at >= 0 && at + 1 < args.Length ? args[at + 1] : Path.Combine(Application.persistentDataPath, "acceptance");
            Directory.CreateDirectory(output); report.unityVersion = Application.unityVersion;
            StartCoroutine(Watchdog());
            yield return null;
            Check(game.Themes.Length == 5, "Five themes loaded");
            for (int t = 0; t < game.Themes.Length; t++)
            {
                game.GoHome(); game.SelectTheme(t); game.SelectDifficulty(0); game.BeginRound(false);
                yield return WaitForPile();
                Check(game.SpawnComplete && game.Items.Count == 48, game.Theme.id + ": 48 real models spawned");
                SavePhysicsSnapshot();
                Check(game.Remaining.All(i => i.Body && float.IsFinite(i.transform.position.y) && i.transform.position.y > -.5f), game.Theme.id + ": physics retained all pieces");
                Check(game.Remaining.All(i => Mathf.Abs(i.transform.position.x) < game.Theme.halfX + .6f
                    && Mathf.Abs(i.transform.position.z - .88f) < game.Theme.halfZ + .6f && i.transform.position.y < 6.5f),
                    game.Theme.id + ": all pieces remain inside the drop boundary");
                Check(game.Remaining.All(i => i.Visual.GetComponentsInChildren<Renderer>().All(r => r.sharedMaterials.All(m => m && m.shader && m.shader.isSupported))), game.Theme.id + ": supported materials");
                Check(game.Hud.Background.sprite, game.Theme.id + ": background loaded");
                Check(game.Hud.PropLabels.All(label => label.sprite && label.isActiveAndEnabled && label.color.a > .99f), game.Theme.id + ": fixed prop label artwork present");
                ScreenCapture.CaptureScreenshot(Path.Combine(output, game.Theme.id + "-playing.png"));
                yield return new WaitForEndOfFrame();
                var visible = game.Remaining.First(i => !i.Golden && i.DepthVisible);
                var group = new List<GooseItem> { visible };
                group.AddRange(game.Remaining.Where(i => i != visible && i.Id == visible.Id).Take(2));
                var same = group[0].Id;
                game.Pick(group[0]); Check(game.Tray.Entries.Count == 1 && game.Hud.Slots[0].sprite, game.Theme.id + ": pick and tray icon");
                yield return null;
                game.UseProp(0); Check(game.Tray.Entries.Count == 0 && !group[0].Picked, game.Theme.id + ": remove returns original item");
                yield return new WaitForSeconds(.5f);
                foreach (var item in group) { game.Pick(item, true); yield return null; }
                Check(game.Removed == 3 && game.Tray.Entries.Count == 0, game.Theme.id + ": same three matched");
                var before = game.Remaining.GroupBy(i => i.Id).ToDictionary(g => g.Key, g => g.Count());
                game.UseProp(2); yield return new WaitForSeconds(2);
                Check(before.All(k => game.Remaining.Count(i => i.Id == k.Key) == k.Value), game.Theme.id + ": shuffle conserves quantities");
                Check(game.Remaining.All(i => i.transform.position.y > -.5f), game.Theme.id + ": shuffle retained all pieces");
                float timer = game.TimeLeft; game.Pause(); yield return new WaitForSecondsRealtime(.3f);
                Check(Mathf.Approximately(timer, game.TimeLeft), game.Theme.id + ": pause freezes countdown"); game.Resume();
                // Complete every remaining triple through the real scoring and result code.
                foreach (var g in game.Remaining.Where(i => !i.Golden).GroupBy(i => i.Id).ToList())
                    foreach (var item in g.ToList()) { game.Pick(item, true); yield return null; }
                Check(game.LastResult == "win" && game.Removed == 48, game.Theme.id + ": complete round won");
                yield return null;
            }
            game.GoHome(); game.SelectTheme(0); game.SelectDifficulty(1); game.BeginRound(false);
            yield return WaitForPile();
            Check(game.Items.Count == 55 && game.Remaining.Count(i => i.Golden) == 1 && game.Remaining.Count(i => i.Frozen) == 4, "Standard: 54 normal + golden + four frozen");
            var frozen = game.Remaining.First(i => i.Frozen);
            Check(!game.Pick(frozen, true) && !frozen.Picked, "Frozen item blocks picking");
            var golden = game.Remaining.First(i => i.Golden); float oldTime = game.TimeLeft;
            int oldProps = game.Props.Sum(); game.Pick(golden, true);
            Check(game.Tray.Entries.Count == 0 && game.TimeLeft > oldTime + 19 && game.Props.Sum() == oldProps + 1, "Golden reward does not occupy tray");
            var triple = game.Remaining.Where(i => !i.Frozen).GroupBy(i => i.Id).First(g => g.Count() >= 3).Take(3).ToList();
            foreach (var i in triple) { game.Pick(i, true); yield return null; }
            Check(game.Remaining.Count(i => i.Frozen) == 3, "A match thaws one item");
            var target = game.Remaining.Where(i => !i.Frozen).GroupBy(i => i.Id).First(g => g.Count() >= 3).First();
            game.Pick(target, true); int r = game.Removed; game.UseProp(1);
            float magnetDeadline = Time.realtimeSinceStartup + 10;
            while (game.Busy && Time.realtimeSinceStartup < magnetDeadline) yield return null;
            Check(game.Removed == r + 3 && !game.Busy, "Magnet completes one triple and unlocks input");
            // Cancellation cannot award a gift; use callback state, not a synthetic complete event.
            bool videoCallback = false, videoAwarded = true; float savedTime = game.TimeLeft;
            game.Video.Watch(ok => { videoCallback = true; videoAwarded = ok; }, 0);
            yield return new WaitForSecondsRealtime(.5f); game.Video.Close();
            Check(videoCallback && !videoAwarded && !game.Video.Active && Mathf.Abs(game.TimeLeft - savedTime) < .1f, "Early video close: no reward, countdown restored");
            // Both clips must complete naturally at normal speed through loopPointReached.
            for (int clip = 0; clip < 2; clip++)
            {
                bool ended = false, completed = false;
                int previousCompletions = game.Video.CompletedCount;
                game.Video.Watch(ok => { ended = true; completed = ok; }, clip);
                float deadline = Time.realtimeSinceStartup + 90;
                while (!ended && Time.realtimeSinceStartup < deadline) yield return null;
                Check(ended && completed && game.Video.CompletedCount == previousCompletions + 1, "Native video " + clip + " full playback completed");
                if (game.Video.Active) game.Video.Close();
            }
            game.GoHome(); game.SelectDifficulty(2); game.BeginRound(false); yield return WaitForPile();
            Check(game.Items.Count == 82 && game.Remaining.Count(i => i.Frozen) == 7, "Master: 81 normal + golden + seven frozen");
            game.QaSetTime(.01f); yield return new WaitForSecondsRealtime(.2f);
            Check(game.Paused && game.Hud.Modal, "Timeout offers revival before result");
            game.Resume(); game.EndRound(false, "时间到");
            game.GoHome(); game.SelectDifficulty(2); game.BeginRound(false); yield return WaitForPile();
            foreach (var item in game.Remaining.Where(i => i.Frozen).ToList()) item.SetFrozen(false);
            var distinct = game.Remaining.Where(i => !i.Golden).GroupBy(i => i.Id).Take(7).Select(g => g.First()).ToList();
            foreach (var item in distinct) { game.Pick(item, true); yield return null; }
            Check(game.Rewards.AwaitingRevive && game.Paused, "Seventh unmatched item offers video revival");
            game.EndFailedRound(); Check(!game.Playing && game.LastResult == "槽位已满", "Declining video commits terminal failure");
            game.GoHome();
            report.passed = report.errors.Count == 0; finished = true;
            File.WriteAllText(Path.Combine(output, "acceptance.json"), JsonUtility.ToJson(report, true));
            Debug.Log("[GooseQA] " + (report.passed ? "PASS " : "FAIL ") + report.checks.Count + " checks, " + report.errors.Count + " errors");
            yield return new WaitForSecondsRealtime(.5f);
            if (!Application.isEditor) Application.Quit(report.passed ? 0 : 1);
        }
        void Check(bool value, string name)
        { if (value) report.checks.Add(name); else { report.errors.Add(name); Debug.LogWarning("[GooseQA] FAIL: " + name); } }
        IEnumerator WaitForPile()
        {
            float deadline = Time.realtimeSinceStartup + 30;
            while (!game.SpawnComplete && Time.realtimeSinceStartup < deadline) yield return null;
            Check(game.SpawnComplete, game.Theme.id + ": spawning completed before deadline");
            yield return new WaitForSeconds(1.5f);
        }
        void SavePhysicsSnapshot()
        {
            var snapshot = new PhysicsSnapshot { theme = game.Theme.id };
            foreach (var item in game.Remaining)
            {
                var collider = item.GetComponent<Collider>();
                snapshot.pieces.Add(new PieceState { id = item.Id, position = item.transform.position,
                    velocity = item.Body.velocity, kinematic = item.Body.isKinematic, visible = item.DepthVisible,
                    colliderCenter = collider.bounds.center, colliderSize = collider.bounds.size });
            }
            File.WriteAllText(Path.Combine(output, game.Theme.id + "-physics.json"), JsonUtility.ToJson(snapshot, true));
        }
        IEnumerator Watchdog()
        {
            yield return new WaitForSecondsRealtime(240);
            if (finished) yield break;
            report.errors.Add("Acceptance timed out"); report.passed = false;
            File.WriteAllText(Path.Combine(output, "acceptance.json"), JsonUtility.ToJson(report, true));
            if (!Application.isEditor) Application.Quit(1);
        }
    }
}
#endif
