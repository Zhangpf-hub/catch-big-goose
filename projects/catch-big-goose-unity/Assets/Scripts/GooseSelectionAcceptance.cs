#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEngine.Profiling;
using UnityEngine.UI;

namespace CatchGoose
{
    public sealed class GooseSelectionAcceptance : MonoBehaviour
    {
        [Serializable] sealed class Sample
        {
            public string theme, mode; public float meanMs, p95Ms, selectionCpuMs;
            public int draws, frames, gcCollections, materials, bindings; public long managedBytes, unityBytes;
        }
        [Serializable] sealed class Report
        {
            public bool passed; public string scope = "Native mobile profile with production pointer APIs and real offscreen camera rendering in a hidden QA window. Native 30 FPS pacing and RTX CPU submission costs are not phone FPS/GPU measurements.";
            public List<string> checks = new List<string>(), errors = new List<string>();
            public List<Sample> samples = new List<Sample>(); public float selectedPixelDifference;
            public int skinnedModels, transparentModels, multiMaterialModels;
        }
        readonly Report report = new Report();
        GooseGame game; string output; bool done; RenderTexture performanceTarget;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        { if (Array.IndexOf(Environment.GetCommandLineArgs(), "-gooseSelectionQa") >= 0) new GameObject("SelectionAcceptance").AddComponent<GooseSelectionAcceptance>(); }
        void OnEnable() { Application.logMessageReceived += Log; }
        void OnDisable() { Application.logMessageReceived -= Log; }
        void Log(string message, string stack, LogType type)
        { if (type == LogType.Error || type == LogType.Exception || type == LogType.Assert) report.errors.Add(message + "\n" + stack); }
        void Check(bool ok, string text) { (ok ? report.checks : report.errors).Add(text); Save(); }
        IEnumerator Watchdog() { yield return new WaitForSecondsRealtime(700); if (!done) { report.errors.Add("watchdog"); Finish(); } }
        IEnumerator Spawn(int theme)
        {
            game.Depth.enabled = true;
            game.GoHome(); game.SelectTheme(theme); game.SelectDifficulty(1); game.BeginExperienceRound(20261025);
            float until = Time.realtimeSinceStartup + 100;
            while (!game.SpawnComplete && Time.realtimeSinceStartup < until) yield return null;
            Check(game.SpawnComplete && game.Total == 300, "300 item production opening " + theme);
            yield return new WaitForSeconds(1);
        }
        Dictionary<GooseItem, Vector2> Points()
        {
            var points = new Dictionary<GooseItem, Vector2>(); var rect = game.MainCamera.pixelRect;
            for (float y = rect.yMin + 18; y < rect.yMax - 18; y += 12)
                for (float x = rect.xMin + 18; x < rect.xMax - 18; x += 12)
                {
                    var p = new Vector2(x, y); var item = game.FindSelectableAtScreenPosition(p);
                    if (item && !points.ContainsKey(item))
                    {
                        bool began = game.BeginPointer(p, -999);
                        bool actual = began && game.CurrentSelectedItem == item;
                        game.CancelPointer(-999);
                        if (actual) points.Add(item, p);
                    }
                }
            return points;
        }
        Vector2 Blank()
        {
            var rect = game.MainCamera.pixelRect;
            for (float y = rect.yMin + 8; y < rect.yMax; y += 15)
                for (float x = rect.xMin + 8; x < rect.xMax; x += 15)
                { var p = new Vector2(x, y); if (!game.FindSelectableAtScreenPosition(p)) return p; }
            throw new Exception("No blank fixture point");
        }
        void Shot(string name) { GooseFrameCapture.Save(Path.Combine(output, name + ".png")); }
        IEnumerator Start()
        {
            var args = Environment.GetCommandLineArgs(); int at = Array.IndexOf(args, "-selectionOutput");
            output = at >= 0 ? args[at + 1] : Path.Combine(Application.persistentDataPath, "selection-qa");
            Directory.CreateDirectory(output); GooseSave.IsQa = true; yield return null;
            game = GooseGame.Instance; StartCoroutine(Watchdog());
            Check(Resources.Load<Shader>("GooseSelectionHighlight").isSupported, "selection shader supported on " + SystemInfo.graphicsDeviceType);
            yield return Spawn(0);
            var points = Points(); Check(points.Count >= 2, "two exposed selectable targets");
            var a = points.First(); var b = points.First(p => p.Key != a.Key && Vector2.Distance(p.Value, a.Value) > 40);
            Vector2 blank = Blank(); int tray = game.Tray.Entries.Count;
            Shot("before");
            Check(game.BeginPointer(a.Value, 10) && game.CurrentSelectedItem == a.Key && !a.Key.Picked && game.Tray.Entries.Count == tray, "down previews without picking");
            Check(!game.BeginPointer(b.Value, 11), "second finger cannot take ownership");
            game.MovePointer(b.Value, 11); Check(game.CurrentSelectedItem == a.Key, "second finger move ignored");
            Check(!game.EndPointer(b.Value, 11) && game.PointerActive, "second finger release ignored");
            game.CancelPointer(11); Check(game.CurrentSelectedItem == a.Key, "second finger cancel ignored");
            yield return new WaitForEndOfFrame(); Shot("held");
            Check(game.SelectionHighlight.LastDraws > 0, "selected object submits real effect passes");
            report.selectedPixelDifference = Difference(Path.Combine(output, "before.png"), Path.Combine(output, "held.png"));
            Check(report.selectedPixelDifference > .00001f, "actual selected pixels differ from unselected frame");
            game.MovePointer(b.Value, 10); Check(game.CurrentSelectedItem == b.Key && !a.Key.Picked, "drag beyond old 40 pixel threshold switches target");
            Shot("switched");
            game.MovePointer(blank, 10); Check(!game.CurrentSelectedItem && game.PointerActive, "blank clears preview but retains gesture");
            game.MovePointer(a.Value, 10); Check(game.CurrentSelectedItem == a.Key, "slide back reacquires target");
            game.MovePointer(b.Value, 10);
            Check(game.EndPointer(b.Value, 10) && b.Key.Picked && !a.Key.Picked && !game.PointerActive && !game.CurrentSelectedItem, "release picks exactly the previewed target");
            Check(!game.EndPointer(b.Value, 10), "duplicate end never picks twice");
            yield return new WaitForSeconds(.8f); Check(game.Presentation.Contains(b.Key), "picked mesh uses existing tray presentation");
            points = Points(); a = points.First(); blank = Blank();
            game.BeginPointer(a.Value, 20); game.MovePointer(blank, 20); Check(!game.EndPointer(blank, 20) && !a.Key.Picked, "empty release cancels");
            game.BeginPointer(a.Value, 21); game.CancelPointer(21); Check(!game.PointerActive && !game.CurrentSelectedItem && !a.Key.Picked, "touch cancel does not pick");
            points = Points(); var alternate = points.First(p => p.Key != a.Key);
            game.BeginPointer(a.Value, 210); Check(!game.EndPointer(alternate.Value, 210) && !a.Key.Picked && !alternate.Key.Picked, "unpreviewed end position cancels instead of picking another item");
            game.BeginPointer(a.Value, 22); game.MovePointer(new Vector2(-10, -10), 22); Check(!game.PointerActive && !a.Key.Picked, "viewport exit cancels gesture");
            game.BeginPointer(a.Value, 23); game.SetPaused(true); Check(!game.CurrentSelectedItem && !game.PointerActive, "pause immediately clears selection");
            Check(!game.BeginPointer(a.Value, 24), "pause rejects pointer input"); game.SetPaused(false);
            game.BeginPointer(a.Value, 25); game.SetAppVisible(false); Check(!game.CurrentSelectedItem && !game.PointerActive, "background clears selection");
            game.SetAppVisible(true); game.Resume();
            var pause = game.Hud.Play.GetComponentsInChildren<Button>().First(x => x.GetComponentInChildren<Text>() && x.GetComponentInChildren<Text>().text == "Ⅱ");
            Vector2 ui = RectTransformUtility.WorldToScreenPoint(game.Hud.HudCamera, pause.transform.position);
            Check(!game.BeginPointer(ui, 26), "UI down cannot select pile");
            game.BeginPointer(a.Value, 27); game.MovePointer(ui, 27); Check(!game.PointerActive && !game.CurrentSelectedItem, "sliding onto UI cancels");
            game.BeginPointer(a.Value, 28); a.Key.SetDepthVisible(false); Check(!game.PointerActive && !game.CurrentSelectedItem, "depth hide clears immediately"); a.Key.SetDepthVisible(true);
            game.BeginPointer(a.Value, 29); a.Key.gameObject.SetActive(false); Check(!game.CurrentSelectedItem, "disabled target cannot retain highlighter"); a.Key.gameObject.SetActive(true);
            game.BeginPointer(a.Value, 30); game.Pick(a.Key, true); Check(!game.PointerActive && !game.CurrentSelectedItem, "programmatic pickup clears preview");
            yield return new WaitForSeconds(.8f);
            for (int theme = 0; theme < game.Themes.Length; theme++)
            {
                yield return Spawn(theme);
                // Hold the settled pile constant across the three rendering samples.
                // Interaction tests above retain production physics and depth updates.
                game.Depth.enabled = false;
                foreach (var item in game.Remaining) { item.Body.collisionDetectionMode = CollisionDetectionMode.ContinuousSpeculative; item.Body.isKinematic = true; }
                points = Points(); a = points.First();
                Shot(game.Theme.id + "-plain");
                game.BeginPointer(a.Value, 40); yield return new WaitForEndOfFrame(); Shot(game.Theme.id + "-selected");
                Check(game.CurrentSelectedItem == a.Key && game.SelectionHighlight.LastDraws > 0, "selected render in theme " + game.Theme.id);
                var special = game.Remaining.FirstOrDefault(x => x.Renderers.Any(r => r is SkinnedMeshRenderer));
                if (special) { report.skinnedModels++; yield return Special(special, "skinned"); }
                special = game.Remaining.FirstOrDefault(x => x.Renderers.Any(r => r.sharedMaterials.Any(m => m && m.renderQueue >= 3000)));
                if (special) { report.transparentModels++; yield return Special(special, "transparent"); }
                special = game.Remaining.FirstOrDefault(x => x.DrawSlots > 1);
                if (special) { report.multiMaterialModels++; yield return Special(special, "multi-material"); }
                game.CancelPointer();
                points = Points(); a = points.First();
                yield return Measure("idle", points);
                game.BeginPointer(a.Value, 41); yield return Measure("hold", points); game.CancelPointer();
                yield return Measure("switch", points); game.CancelPointer();
                int materials = Resources.FindObjectsOfTypeAll<Material>().Length;
                var list = points.Take(12).ToArray();
                for (int i = 0; i < 120; i++) { game.BeginPointer(list[i % list.Length].Value, 42); game.CancelPointer(); }
                Check(Resources.FindObjectsOfTypeAll<Material>().Length == materials, "switching does not clone materials " + game.Theme.id);
                game.BeginPointer(a.Value, 43); game.GoHome(); Check(!game.PointerActive && !game.CurrentSelectedItem && game.SelectionHighlight.LastDraws == 0, "home/recycle clears selection " + theme);
            }
            // Current themed FBXs can be baked static meshes. Exercise the real
            // SkinnedMeshRenderer path with a weighted, deforming cube as well.
            yield return Spawn(0); game.Depth.enabled = false;
            var fixture = SkinFixture(); yield return Special(fixture, "weighted-skin"); report.skinnedModels++;
            game.Forget(fixture); Destroy(fixture.gameObject); yield return null; game.GoHome();
            Check(report.skinnedModels > 0, "animated skinned renderer fixture coverage");
            Check(report.transparentModels > 0, "real transparent item coverage");
            Check(report.multiMaterialModels > 0, "real multi-material item coverage");
            Finish();
        }
        IEnumerator Special(GooseItem item, string label)
        {
            game.CancelPointer(); var position = item.transform.position; bool visible = item.DepthVisible;
            var originals = item.Renderers.Select(r => r.sharedMaterials).ToArray(); var scale = item.transform.localScale;
            item.transform.position = game.MainCamera.ScreenPointToRay(game.MainCamera.pixelRect.center).GetPoint(1.4f); item.Body.position = item.transform.position;
            item.SetDepthVisible(true); Physics.SyncTransforms();
            var points = Points(); bool found = points.TryGetValue(item, out Vector2 point);
            Check(found, label + " has a visible collider sample");
            Check(game.FindSelectableAtScreenPosition(point) == item, label + " isolated actual model ray");
            game.BeginPointer(point, 70); yield return new WaitForEndOfFrame(); Shot(game.Theme.id + "-" + label);
            Check(game.CurrentSelectedItem == item && game.SelectionHighlight.LastInstances >= item.DrawSlots * 19, label + " all submeshes rendered");
            Check(item.transform.localScale == scale && item.Renderers.Select((r, i) => r.sharedMaterials.SequenceEqual(originals[i])).All(x => x), label + " original scale/materials unchanged");
            game.CancelPointer(); item.transform.position = position; item.Body.position = position; item.SetDepthVisible(visible); Physics.SyncTransforms();
        }
        GooseItem SkinFixture()
        {
            var primitive = GameObject.CreatePrimitive(PrimitiveType.Cube);
            var mesh = Instantiate(primitive.GetComponent<MeshFilter>().sharedMesh); Destroy(primitive);
            mesh.name = "SelectionWeightedSkinFixture";
            mesh.boneWeights = Enumerable.Repeat(new BoneWeight { boneIndex0 = 0, weight0 = 1 }, mesh.vertexCount).ToArray();
            mesh.bindposes = new[] { Matrix4x4.identity };
            var root = new GameObject("SelectionWeightedSkinFixture"); var item = root.AddComponent<GooseItem>(); item.Id = "qa-weighted-skin";
            item.Body = root.AddComponent<Rigidbody>(); item.Body.isKinematic = true; root.AddComponent<BoxCollider>();
            var visual = new GameObject("Visual"); visual.transform.SetParent(root.transform, false); item.Visual = visual.transform;
            var bone = new GameObject("Bone"); bone.transform.SetParent(visual.transform, false);
            var renderer = visual.AddComponent<SkinnedMeshRenderer>(); renderer.sharedMesh = mesh;
            renderer.bones = new[] { bone.transform }; renderer.rootBone = bone.transform; renderer.localBounds = mesh.bounds;
            renderer.updateWhenOffscreen = true; renderer.sharedMaterial = game.Remaining.First().Renderers[0].sharedMaterial;
            bone.transform.localRotation = Quaternion.Euler(18, 25, 10); item.CacheParts(); game.Items.Add(item); return item;
        }
        IEnumerator Measure(string mode, Dictionary<GooseItem, Vector2> points)
        {
            var list = points.Take(12).ToArray();
            // Warm binding caches before recording hold/switch allocations.
            if (mode == "switch") { foreach (var p in list) { game.BeginPointer(p.Value, 50); game.CancelPointer(); } game.BeginPointer(list[0].Value, 50); }
            Check(mode == "idle" || game.PointerActive && game.CurrentSelectedItem, mode + " measurement starts with a valid preview " + game.Theme.id);
            yield return new WaitForSeconds(.3f);
            var frames = new List<float>(90); int gc = GC.CollectionCount(0);
            int draws = 0; float cpu = 0;
            if (!performanceTarget)
            {
                performanceTarget = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);
                performanceTarget.antiAliasing = Mathf.Max(1, QualitySettings.antiAliasing); performanceTarget.Create();
            }
            for (int i = 0; i < 90; i++)
            {
                if (mode == "switch") game.MovePointer(list[i % list.Length].Value, 50);
                // Windows suspends automatic rendering for a hidden/minimized player.
                // Force the actual production camera into a reused MSAA target so
                // the measured effect is submitted on every sample, not only shots.
                var old = game.MainCamera.targetTexture; var active = RenderTexture.active;
                game.MainCamera.targetTexture = performanceTarget; game.MainCamera.Render();
                game.MainCamera.targetTexture = old; RenderTexture.active = active;
                yield return new WaitForEndOfFrame(); frames.Add(Time.unscaledDeltaTime * 1000); draws = Mathf.Max(draws, game.SelectionHighlight.LastDraws); cpu += game.SelectionHighlight.LastCpuMs;
            }
            frames.Sort(); report.samples.Add(new Sample { theme = game.Theme.id, mode = mode, frames = frames.Count,
                meanMs = frames.Average(), p95Ms = frames[(int)((frames.Count - 1) * .95f)], draws = draws, selectionCpuMs = cpu / frames.Count,
                gcCollections = GC.CollectionCount(0) - gc, managedBytes = GC.GetTotalMemory(false), unityBytes = Profiler.GetTotalAllocatedMemoryLong(),
                materials = Resources.FindObjectsOfTypeAll<Material>().Length, bindings = game.SelectionHighlight.BindingCount });
            Check(mode == "idle" ? draws == 0 : draws > 0, mode + " sample actually renders expected selection state " + game.Theme.id); Save();
        }
        static float Difference(string first, string second)
        {
            var a = new Texture2D(2, 2); var b = new Texture2D(2, 2); a.LoadImage(File.ReadAllBytes(first)); b.LoadImage(File.ReadAllBytes(second));
            var aa = a.GetPixels32(); var bb = b.GetPixels32(); double sum = 0;
            for (int i = 0; i < aa.Length; i++) sum += Math.Abs(aa[i].r - bb[i].r) + Math.Abs(aa[i].g - bb[i].g) + Math.Abs(aa[i].b - bb[i].b);
            Destroy(a); Destroy(b); return (float)(sum / (aa.Length * 3 * 255.0));
        }
        void Save() { if (output == null) return; report.passed = report.errors.Count == 0; File.WriteAllText(Path.Combine(output, "acceptance.json"), JsonUtility.ToJson(report, true)); }
        void Finish() { done = true; game.CancelPointer(); if(performanceTarget){performanceTarget.Release();Destroy(performanceTarget);} Save(); Application.Quit(report.passed ? 0 : 1); }
    }
}
#endif
