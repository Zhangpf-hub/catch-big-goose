#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;

namespace CatchGoose
{
    public sealed class GooseRewardAcceptance : MonoBehaviour
    {
        [Serializable] sealed class Report
        {
            public bool passed;
            public string scope = "Windows real Unity playback and gameplay; accelerated checkpoint wait only; no physical WeChat device claim";
            public int completedVideos, cancelledVideos;
            public List<string> checks = new List<string>(), errors = new List<string>();
        }
        [Serializable] sealed class Stamp { public string file; public float time; }
        [Serializable] sealed class Recording { public string name; public List<Stamp> frames = new List<Stamp>(); }
        readonly Report report = new Report();
        GooseGame game;
        string output;
        bool done, expectedVideoError;
        Recording recording;
        float recordedAt, nextFrame;
        bool oldSound, oldGm;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        {
            if (Environment.GetCommandLineArgs().Contains("-gooseRewardQa"))
                new GameObject("VideoRewardQA").AddComponent<GooseRewardAcceptance>();
        }
        void OnEnable() { Application.logMessageReceived += Log; }
        void OnDisable() { Application.logMessageReceived -= Log; }
        void Log(string message, string stack, LogType type)
        { if (!expectedVideoError && (type == LogType.Error || type == LogType.Exception)) report.errors.Add(message + "\n" + stack); }
        void Check(bool value, string label)
        { (value ? report.checks : report.errors).Add(label); if (!value) Debug.LogWarning("[GooseRewardQA] " + label); }
        IEnumerator Until(Func<bool> condition, float seconds, string label)
        {
            float end = Time.realtimeSinceStartup + seconds;
            while (!condition() && Time.realtimeSinceStartup < end) yield return null;
            Check(condition(), label);
        }
        IEnumerator NewRound(int stage = 1, string theme = "barbecue")
        {
            game.GoHome(); game.SelectTheme(Array.FindIndex(game.Themes, t => t.id == theme));
            game.SelectDifficulty(stage); game.BeginRound(false);
            yield return Until(() => game.SpawnComplete && !game.Preparing, 100, "Round prepared: " + theme + "/" + stage);
            game.QaSetSaleRoll(0); yield return new WaitForSecondsRealtime(.4f);
        }
        IEnumerator Settled()
        { yield return Until(() => !game.Busy && game.PendingMatches == 0 && !game.Presentation.Moving, 12, "Tray animations settled"); }
        void Capture(string file)
        { Canvas.ForceUpdateCanvases(); GooseFrameCapture.Save(Path.Combine(output, file + ".png")); }
        void StartRecording(string name)
        {
            recording = new Recording { name = name }; recordedAt = nextFrame = Time.realtimeSinceStartup;
            Directory.CreateDirectory(Path.Combine(output, name));
        }
        void StopRecording()
        {
            if (recording == null) return;
            File.WriteAllText(Path.Combine(output, recording.name + "-frames.json"), JsonUtility.ToJson(recording, true));
            recording = null;
        }
        IEnumerator Recorder()
        {
            while (!done)
            {
                yield return new WaitForEndOfFrame();
                if (recording == null || Time.realtimeSinceStartup < nextFrame) continue;
                string file = recording.name + "/frame-" + recording.frames.Count.ToString("D5") + ".png";
                float stamp = Time.realtimeSinceStartup - recordedAt;
                GooseFrameCapture.Save(Path.Combine(output, file));
                recording.frames.Add(new Stamp { file = file, time = stamp });
                nextFrame = Time.realtimeSinceStartup + .10f;
            }
        }
        void OfferSale()
        { game.QaAdvanceRewardTime(Mathf.Max(0, 120.05f - game.Rewards.Elapsed)); }
        IEnumerator WatchComplete(GooseRewardEntry entry, int expectedClip, string shot)
        {
            int before = game.Video.CompletedCount;
            if (entry == GooseRewardEntry.ToolSale) game.SaleTruck.TruckRect.GetComponent<Button>().onClick.Invoke();
            else game.Hud.Modal.GetComponentsInChildren<Button>().Single(b => b.name == "看视频复活").onClick.Invoke();
            Check(game.Video.Active && game.Video.CurrentClip == expectedClip, "Shared rotation selects clip " + expectedClip + " at " + entry);
            yield return Until(() => game.Video.PositionSeconds > 1 || !game.Video.Active, 20, "Actual video frames begin");
            Capture(shot);
            yield return Until(() => !game.Video.Active, 100, "Natural video playback ends: " + entry);
            Check(game.Video.CompletedCount == before + 1 && game.Video.LastOutcome == "complete", "Full playback completes once: " + entry);
            yield return null; yield return null;
            Check(game.GetComponents<VideoPlayer>().Length == 0, "Decoder released: " + entry);
            Check(!Resources.FindObjectsOfTypeAll<RenderTexture>().Any(t => t.name == "GooseRewardVideo"), "Video texture released: " + entry);
        }
        IEnumerator FillDistinct(int count)
        {
            var pieces = game.Remaining.GroupBy(i => i.Id).Take(count).Select(g => g.First()).ToArray();
            Check(pieces.Length == count, "Distinct pieces available: " + count);
            foreach (var item in pieces) { Check(game.Pick(item, true), "Normal animated pick " + item.Id); yield return new WaitForSecondsRealtime(.12f); }
        }
        IEnumerator ConsumeTools()
        {
            yield return FillDistinct(3); yield return Settled();
            Check(game.UseProp(0), "Remove spends inventory"); yield return Settled();
            int stored = game.Stored.Count, inventory = game.Props[0];
            game.QaGrant(0, 1); Check(!game.UseProp(0) && game.Stored.Count == stored, "Occupied storage refuses a second remove without overflow");
            Check(game.Props[0] == inventory + 1, "Refused storage action does not consume inventory"); game.QaGrant(0, -1);
            // Return all storage through the production storage selection API.
            while (game.Stored.Count > 0) { game.PickStored(0); yield return Settled(); }
            Check(game.UseProp(1), "Match spends inventory"); yield return Settled();
            Check(game.UseProp(2), "Shuffle spends inventory"); yield return new WaitForSecondsRealtime(.8f);
        }
        IEnumerator LayoutOnly()
        {
            for (int index = 0; index < 4; index++)
            {
                var size = index == 0 ? new Vector2Int(360, 640) : index == 2 ? new Vector2Int(430, 932) : new Vector2Int(390, 844);
                Screen.SetResolution(size.x, size.y, false); yield return new WaitForSecondsRealtime(.3f);
                var phone = game.Hud.GetComponent<GoosePhoneLayout>();
                phone.SetPlatformSafeArea(index == 3 ? new Rect(0, 34f / 844, 1, (844f - 88 - 34) / 844) : new Rect(0, 0, 1, 1));
                yield return NewRound();
                if(index == 1) StartRecording("truck-upper-lane-demo");
                OfferSale(); yield return Until(() => game.SaleTruck.Age >= 2.15f, 10, "Upper lane first stop");
                Canvas.ForceUpdateCanvases();
                var corners = new Vector3[4]; game.SaleTruck.TruckRect.GetWorldCorners(corners);
                var points = corners.Select(p => RectTransformUtility.WorldToScreenPoint(game.Hud.HudCamera, p)).ToArray();
                Check(points.Min(p => p.y) > game.MainCamera.pixelRect.yMax, "Truck touch area entirely above 3D play area: " + index);
                var timer = game.Hud.StatusRoot.Find("TimerCard") as RectTransform; timer.GetWorldCorners(corners);
                Check(points.Max(p => p.y) < corners.Select(p => RectTransformUtility.WorldToScreenPoint(game.Hud.HudCamera,p)).Min(p => p.y), "Truck stays below timer: " + index);
                var labels = game.SaleTruck.TruckRect.GetComponentsInChildren<Text>();
                Check(labels.Length == 1 && labels[0].text == "道具甩卖" && labels[0].fontSize == 96, "Only enlarged sale title: " + index);
                Check(!game.Hud.Frame.GetComponentsInChildren<Text>().Any(t => t.text.Contains("演示：") || t.text.Contains("跳过等待")), "No recording/debug caption: " + index);
                string shot = index == 3 ? "truck-upper-safe-area" : "truck-upper-" + size.x + "x" + size.y;
                Capture(shot);
                Vector2 selection = Vector2.zero; bool found = false;
                foreach(var item in game.Remaining)
                {
                    if(!item.DepthVisible) continue;
                    var p = (Vector2)game.MainCamera.WorldToScreenPoint(item.SelectionCollider.bounds.center);
                    if(game.FindSelectableAtScreenPosition(p)) { selection = p; found = true; break; }
                }
                Check(found && game.BeginPointer(selection) && game.EndPointer(selection), "Player can pick through production pointer flow while truck is visible: " + index);
                yield return Settled();
                Check(game.SaleTruck.Visible && game.Playing && !game.Paused && game.Tray.Entries.Count == 1, "Match play continues without closing truck: " + index);
                if(index == 1)
                {
                    yield return Until(() => !game.SaleTruck.Visible, 20, "Upper lane full pass completes");
                    StopRecording();
                }
            }
        }

        IEnumerator Start()
        {
            var args = Environment.GetCommandLineArgs(); output = args[Array.IndexOf(args, "-rewardOutput") + 1];
            Directory.CreateDirectory(output); GooseSave.IsQa = true; yield return null; game = GooseGame.Instance;
            oldSound = GooseSave.Sound; oldGm = GooseSave.GmUnlimited; GooseSave.Sound = false; GooseSave.GmUnlimited = true;
            StartCoroutine(Watchdog()); StartCoroutine(Recorder());
            if(args.Contains("-rewardLayoutOnly")) { yield return LayoutOnly(); Finish(); yield break; }
            yield return NewRound(0); game.QaAdvanceRewardTime(600);
            Check(game.Level.seconds == 0 && game.Rewards.CheckCount == 0 && !game.SaleTruck.Visible, "Untimed warmup has no truck");
            yield return NewRound(); yield return ConsumeTools();
            Check(game.Props.All(p => p == 0), "All initial tool copies consumed");
            // All layout screenshots use a real active offer and never a mock image.
            foreach (var size in new[] { new Vector2Int(360, 640), new Vector2Int(390, 844), new Vector2Int(430, 932) })
            {
                Screen.SetResolution(size.x, size.y, false); yield return new WaitForSecondsRealtime(.3f);
                game.QaSetSaleRoll(0); if (!game.SaleTruck.Visible) OfferSale();
                yield return new WaitForSecondsRealtime(2.1f);
                Capture("truck-" + size.x + "x" + size.y);
                Check(game.SaleTruck.Visible, "Truck visible at " + size);
            }
            Screen.SetResolution(390, 844, false); yield return new WaitForSecondsRealtime(.3f);
            yield return NewRound();
            var phone = game.Hud.GetComponent<GoosePhoneLayout>();
            phone.SetPlatformSafeArea(new Rect(0, 34f / 844, 1, (844f - 88 - 34) / 844));
            OfferSale(); yield return Until(() => game.SaleTruck.Age >= 2.15f, 10, "Truck enters simulated notched safe area");
            yield return null; Capture("truck-safe-area");
            var corners = new Vector3[4]; game.SaleTruck.TruckRect.GetWorldCorners(corners);
            var screenCorners = corners.Select(p => RectTransformUtility.WorldToScreenPoint(game.Hud.HudCamera, p)).ToArray();
            Check(screenCorners.All(p => p.x >= 0 && p.x <= 390 && p.y >= 34 && p.y <= 844 - 88), "Truck touch bounds stay inside notched safe area");
            phone.SetPlatformSafeArea(new Rect(0, 0, 1, 1));
            yield return NewRound();
            StartRecording("truck-pass-demo"); OfferSale();
            yield return Until(() => game.SaleTruck.Age >= 2.15f, 10, "Truck reaches first parking point");
            Check(!game.SaleTruck.WheelsMoving, "First parking interval stops wheel rotation");
            yield return Until(() => game.SaleTruck.Age >= 6.65f, 12, "Truck reaches second parking point");
            Check(!game.SaleTruck.WheelsMoving, "Second parking interval stops wheel rotation"); Capture("truck-second-stop");
            yield return Until(() => !game.SaleTruck.Visible, 15, "Unclicked truck exits to the left");
            Check(game.Rewards.Offer == 0 && game.Props.All(p => p == 1), "Missed truck expires without an automatic video or reward");
            StopRecording();
            // Start a fresh offer for a full actual animation in the demo.
            yield return NewRound(); yield return ConsumeTools();
            StartRecording("sale-demo"); OfferSale();
            yield return Until(() => game.SaleTruck.Age >= 2.15f, 10, "Vehicle reaches first stop using active play time");
            Check(!game.SaleTruck.WheelsMoving, "Wheels stop during the first parking interval");
            int[] original = (int[])game.Props.Clone(); float age = game.SaleTruck.Age;
            game.WatchSale(); yield return new WaitForSecondsRealtime(.4f);
            Check(game.Paused && Mathf.Abs(game.SaleTruck.Age - age) < .1f, "Video freezes gameplay and vehicle time");
            game.Video.Close(); yield return null;
            Check(!game.Paused && game.Props.SequenceEqual(original) && game.NextRewardClip == 0, "Early close awards nothing and preserves clip rotation");
            game.SetAppVisible(false); float elapsed = game.Rewards.Elapsed;
            game.QaAdvanceRewardTime(100); yield return new WaitForSecondsRealtime(.2f);
            Check(Mathf.Approximately(elapsed, game.Rewards.Elapsed), "Background does not accumulate active play time");
            game.SetAppVisible(true); game.Resume();
            yield return WatchComplete(GooseRewardEntry.ToolSale, 0, "darkchaser-playing");
            Check(game.Props.All(p => p == 1) && game.Rewards.ClaimedSales == 1, "Natural sale playback grants exactly one of all three tools");
            game.WatchSale(); Check(!game.Video.Active, "Claimed truck cannot award twice");
            Capture("sale-reward-counts"); yield return new WaitForSecondsRealtime(2); StopRecording();
            yield return ConsumeTools(); Check(game.Props.All(p => p == 0), "Refilled tools can all be used again in the same round");
            // Full tray: first failure waits without writing a result, cancellation retries.
            yield return NewRound(); var beforeBest = JsonUtility.ToJson(GooseSave.StoryBest(game.Theme.id, 1));
            StartRecording("tray-revive-demo"); yield return FillDistinct(7);
            yield return Until(() => game.Rewards.AwaitingRevive, 10, "Full tray offers first video revival");
            float remaining = game.TimeLeft; int total = game.Items.Count; int removed = game.Removed;
            Check(game.Playing && game.Paused && game.LastResult == "", "First failure is pending rather than terminal");
            Check(beforeBest == JsonUtility.ToJson(GooseSave.StoryBest(game.Theme.id, 1)), "Pending failure does not write a final score");
            Capture("full-tray-offer"); game.WatchRevive(); yield return new WaitForSecondsRealtime(.3f); game.Video.Close(); yield return null;
            Check(game.Rewards.AwaitingRevive && !game.Rewards.Revived && game.Paused && game.Hud.Modal, "Cancelled revival returns to the same paused offer");
            yield return WatchComplete(GooseRewardEntry.Revive, 1, "skycore-playing");
            Check(game.Playing && !game.Paused && game.Tray.Entries.Count == 4, "Full-tray revival returns exactly three pieces");
            Check(game.Items.Count == total && game.Removed == removed && game.Stored.Count == 0 && game.Props.All(p => p == 1), "Revival preserves stock and does not spend tools");
            Check(Mathf.Abs(game.TimeLeft - remaining - 300) < 1, "Full-tray revival adds five minutes to remaining time");
            Capture("full-tray-revived"); yield return new WaitForSecondsRealtime(2);
            game.QaSetTime(.01f); yield return Until(() => !game.Playing, 10, "A second failure after full-tray revival is terminal");
            Check(game.LastResult == "时间到" && !game.Hud.Modal.GetComponentsInChildren<Button>().Any(b => b.name == "看视频复活"), "No second revival button and no free rescue"); StopRecording();
            // Timeout uses the same entry and wraps the common clip sequence.
            yield return NewRound(); StartRecording("timeout-revive-demo"); game.QaSetTime(.01f);
            yield return Until(() => game.Rewards.AwaitingRevive, 10, "First timeout offers revival"); Capture("timeout-offer");
            yield return WatchComplete(GooseRewardEntry.Revive, 0, "timeout-darkchaser-playing");
            Check(game.Rewards.Revived && !game.Paused && Mathf.Abs(game.TimeLeft - 300) < 1, "Timeout revival restores five minutes");
            Capture("timeout-revived"); yield return new WaitForSecondsRealtime(2); StopRecording();
            game.QaSetTime(.01f); yield return Until(() => !game.Playing, 10, "Second timeout ends round");
            // A failed decoder and a round change cannot grant or advance clips.
            yield return NewRound(); OfferSale(); yield return new WaitForSecondsRealtime(2.1f);
            int clipBefore = game.NextRewardClip; game.WatchSale(); expectedVideoError = true;
            var player = game.GetComponent<VideoPlayer>(); player.Stop(); player.url = Path.Combine(output, "missing-video.mp4"); player.Prepare();
            yield return Until(() => !game.Video.Active, 20, "Decoder failure returns to game"); expectedVideoError = false;
            Check(game.Props.All(p => p == 1) && game.NextRewardClip == clipBefore, "Decoder error gives no reward and no clip advancement");
            game.WatchSale(); if (game.Video.Active) game.BeginRound(false);
            yield return Until(() => game.SpawnComplete && !game.Preparing, 100, "Round replacement while watching completes");
            Check(!game.Video.Active && game.Props.All(p => p == 1), "Round replacement rejects retired reward callbacks");
            // Exactly eight minutes must finish before a simultaneous 480-second truck.
            yield return NewRound(1, "toys"); game.QaAdvanceRewardTime(479.95f); game.SaleTruck.Hide(); game.Rewards.ExpireOffer();
            game.QaSetTime(.001f); yield return Until(() => game.Rewards.AwaitingRevive, 10, "Toy timeout wins the 480-second collision");
            Check(!game.SaleTruck.Visible, "No truck appears over a toy timeout dialog"); game.EndFailedRound();
            Check(!game.Playing, "Declining first revival commits failure");
            // Pending last match must complete as a victory, even when time hits zero.
            yield return NewRound(); game.InstantPicksForQa = true;
            var last = game.Remaining.GroupBy(i => i.Id).Last().Take(3).ToArray(); var keep = new HashSet<GooseItem>(last);
            foreach (var group in game.Remaining.Where(i => !keep.Contains(i)).GroupBy(i => i.Id).ToArray())
                foreach (var item in group.ToArray()) game.Pick(item, true);
            game.InstantPicksForQa = false;
            foreach (var item in last) game.Pick(item, true);
            game.QaSetTime(.001f); yield return Until(() => !game.Playing, 12, "Final committed triple settles at timeout");
            Check(game.LastResult == "win", "Final triple victory has priority over timeout");
            report.completedVideos = game.Video.CompletedCount; report.cancelledVideos = game.Video.CancelledCount;
            Finish();
        }
        IEnumerator Watchdog() { yield return new WaitForSecondsRealtime(900); if (!done) { report.errors.Add("QA watchdog expired"); Finish(); } }
        void Finish()
        {
            if (done) return; StopRecording(); done = true;
            game.GoHome(); GooseSave.Sound = oldSound; GooseSave.GmUnlimited = oldGm;
            report.passed = report.errors.Count == 0;
            File.WriteAllText(Path.Combine(output, "acceptance.json"), JsonUtility.ToJson(report, true));
            Debug.Log("[GooseRewardQA] " + (report.passed ? "PASS " : "FAIL ") + report.checks.Count + " checks; errors=" + report.errors.Count);
            Application.Quit(report.passed ? 0 : 1);
        }
    }
}
#endif
