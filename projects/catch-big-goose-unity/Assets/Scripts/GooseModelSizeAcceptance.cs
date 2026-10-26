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
    public sealed class GooseModelSizeAcceptance : MonoBehaviour
    {
        [Serializable] sealed class Row { public string theme; public int stock, visible; public float medianScreenEdge, worldWidth; }
        [Serializable] sealed class Report { public string build = GooseRuntimePerformance.BuildId; public bool passed; public List<Row> rows = new List<Row>(); public List<string> checks = new List<string>(), errors = new List<string>(); }
        readonly Report report = new Report(); readonly List<GoosePreparedLayouts.Layout> layouts = new List<GoosePreparedLayouts.Layout>();
        GooseGame game; string output; bool finished;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)] static void Early()
        { if (Environment.GetCommandLineArgs().Contains("-gooseModelSizeQa")) { GooseSave.IsQa = true; GooseSave.Onboarded = true; GooseSave.ModelSize = GooseGame.DefaultModelSize; } }
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        { if (Environment.GetCommandLineArgs().Contains("-gooseModelSizeQa")) new GameObject("ModelSizeAcceptance").AddComponent<GooseModelSizeAcceptance>(); }
        void OnEnable() { Application.logMessageReceived += Log; }
        void OnDisable() { Application.logMessageReceived -= Log; }
        void Log(string message, string stack, LogType type) { if (type == LogType.Error || type == LogType.Exception || type == LogType.Assert) report.errors.Add(message); }
        void Check(bool ok, string text) { (ok ? report.checks : report.errors).Add(text); Debug.Log("[SizeQa] " + ok + " " + text); }
        void Capture(string name) { GooseFrameCapture.Save(Path.Combine(output, name + ".png"), Screen.width, Screen.height); }
        IEnumerator Watchdog() { yield return new WaitForSecondsRealtime(540); if (!finished) { report.errors.Add("540s deadline"); Finish(); } }
        IEnumerator Start()
        {
            var args = Environment.GetCommandLineArgs(); output = args[Array.IndexOf(args, "-gooseSizeOutput") + 1]; Directory.CreateDirectory(output);
            StartCoroutine(Watchdog()); yield return null; game = GooseGame.Instance;
            game.Hud.ShowModelSizeSettings(); yield return null; Capture("home-settings"); game.Hud.CloseModal();
            for (int theme = 0; theme < game.Themes.Length; theme++) for (int stage = 0; stage < 2; stage++)
            {
                game.GoHome(); game.SelectTheme(theme); game.SelectDifficulty(stage); var level = game.PrepareLevel();
                game.Preparation.Request(game.Theme, level, true); float deadline = Time.realtimeSinceStartup + 100;
                while (game.Preparation.State == GooseRoundPreparation.Status.Preparing && Time.realtimeSinceStartup < deadline) yield return null;
                Check(game.Preparation.State == GooseRoundPreparation.Status.Ready, game.Theme.id + "/" + stage + " prepared at 130%");
                if (game.Preparation.State != GooseRoundPreparation.Status.Ready) { Finish(); yield break; }
                layouts.Add(new GoosePreparedLayouts.Layout { theme = game.Theme.id, stage = stage, key = GoosePreparedLayouts.Key(game, game.Theme, level), itemScale = game.Preparation.ItemScale,
                    items = game.Preparation.Items.Select(i => new GoosePreparedLayouts.Pose { id = i.Id, position = i.Body.position, rotation = i.Body.rotation, scale = i.transform.localScale }).ToArray() });
                File.WriteAllText(Path.Combine(output, "prepared-layouts.json"), JsonUtility.ToJson(new GoosePreparedLayouts { layouts = layouts.ToArray() }));
                game.BeginRound(false); deadline = Time.realtimeSinceStartup + 30;
                while (!game.SpawnComplete && Time.realtimeSinceStartup < deadline) yield return null;
                Check(game.SpawnComplete && game.Items.Count == (stage == 0 ? 15 : 300), game.Theme.id + "/" + stage + " inventory retained");
                if (!game.SpawnComplete) { Finish(); yield break; }
                yield return new WaitForSeconds(1);
                if (stage == 0)
                {
                    if (theme == 0)
                    {
                        game.Pause(); game.Hud.ShowModelSizeSettings();
                        foreach (float size in new[] { GooseGame.MaximumModelSize, GooseGame.MinimumModelSize, GooseGame.DefaultModelSize })
                        { game.PreviewModelSize(size); game.CommitModelSize(); Check(Mathf.Abs(game.ModelSize - size) < .001f, "tutorial commits size endpoint " + size); }
                        game.Resume();
                    }
                    continue;
                }
                var camera = game.MainCamera; var sizes = new List<float>();
                foreach (var item in game.Remaining.Where(i => i.DepthVisible))
                {
                    var b = item.VisualBounds; var lo = new Vector2(float.PositiveInfinity, float.PositiveInfinity); var hi = new Vector2(float.NegativeInfinity, float.NegativeInfinity);
                    for (int c = 0; c < 8; c++) { Vector2 p = camera.WorldToScreenPoint(new Vector3((c & 1) == 0 ? b.min.x : b.max.x, (c & 2) == 0 ? b.min.y : b.max.y, (c & 4) == 0 ? b.min.z : b.max.z)); lo = Vector2.Min(lo, p); hi = Vector2.Max(hi, p); }
                    sizes.Add(Mathf.Max(hi.x - lo.x, hi.y - lo.y) / camera.pixelWidth);
                }
                sizes.Sort(); float median = sizes.Count > 0 ? sizes[sizes.Count / 2] : 0;
                report.rows.Add(new Row { theme = game.Theme.id, stock = game.Total, visible = sizes.Count, medianScreenEdge = median, worldWidth = camera.orthographicSize * 2 * camera.aspect });
                Check(median >= .18f && median <= .55f, game.Theme.id + " projected AABB median " + median);
                Check(game.Remaining.All(i => GooseColliderGeometry.MinY(i.SelectionCollider) >= GooseCircularContainer.FloorY - .03f), game.Theme.id + " no items below floor");
                Capture(game.Theme.id + "-130");
                if (theme != 0) continue;
                var instanceIds = game.Items.Select(i => i.GetInstanceID()).ToArray(); var sample = game.Remaining.First(); var scale = sample.transform.localScale;
                game.Pause(); game.Hud.ShowModelSizeSettings(); yield return null;
                var slider = game.Hud.Modal.GetComponentInChildren<Slider>();
                // Drive the real uGUI pointer/drag path, including the paused event system.
                var area = (RectTransform)slider.handleRect.parent; Vector2 end = RectTransformUtility.WorldToScreenPoint(null, area.TransformPoint(new Vector3(area.rect.xMin + area.rect.width * (150 - slider.minValue) / (slider.maxValue - slider.minValue), 0, 0)));
                var pointer = new PointerEventData(EventSystem.current) { position = end, button = PointerEventData.InputButton.Left };
                slider.OnPointerDown(pointer); slider.OnDrag(pointer); slider.OnPointerUp(pointer); yield return null;
                Check(Mathf.Abs(game.ModelSize - 1.50f) < .011f, "pointer drag at pause changes live size to 150%");
                Check((sample.transform.localScale - scale * (game.ModelSize / 1.30f)).sqrMagnitude < .000001f, "live mesh and collision root scale change together"); Capture("live-slider-150");
                game.Hud.CloseModal(); Check(Mathf.Abs(game.ModelSize - 1.50f) < .011f, "150% commits with actual convex shapes");
                game.Hud.ShowModelSizeSettings(); game.PreviewModelSize(1); yield return null; Capture("breakfast-before-100");
                game.PreviewModelSize(GooseGame.DefaultModelSize); game.Hud.CloseModal();
                Check(game.Items.Select(i => i.GetInstanceID()).SequenceEqual(instanceIds) && game.Removed == 0, "size adjustment preserves the round and every item identity");
                Check(Mathf.Abs(GooseSave.ModelSize - 1.30f) < .001f, "size saved exactly");
                game.Resume(); yield return new WaitForSeconds(1);
                Check(game.Remaining.All(i => GooseColliderGeometry.MinY(i.SelectionCollider) >= GooseCircularContainer.FloorY - .04f), "resized stock remains above floor after resume");
            }
            game.GoHome(); game.SelectTheme(0); game.SelectDifficulty(1);
            foreach (float endpoint in new[] { GooseGame.MaximumModelSize, GooseGame.MinimumModelSize })
            {
                game.PreviewModelSize(endpoint); game.CommitModelSize(); var level = game.PrepareLevel();
                game.Preparation.Request(game.Theme, level, true); float deadline = Time.realtimeSinceStartup + 100;
                while (game.Preparation.State == GooseRoundPreparation.Status.Preparing && Time.realtimeSinceStartup < deadline) yield return null;
                Check(game.Preparation.State == GooseRoundPreparation.Status.Ready && game.Preparation.Items.Count == 300, "300-piece fresh preparation at size endpoint " + endpoint);
            }
            game.PreviewModelSize(GooseGame.DefaultModelSize); game.CommitModelSize(); game.GoHome(); Finish();
        }
        void Finish() { if (finished) return; finished = true; report.passed = report.errors.Count == 0 && report.rows.Count == 5; File.WriteAllText(Path.Combine(output, "acceptance.json"), JsonUtility.ToJson(report, true)); Application.Quit(report.passed ? 0 : 1); }
    }
}
#endif
