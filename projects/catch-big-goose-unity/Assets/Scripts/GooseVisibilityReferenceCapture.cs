#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace CatchGoose
{
    // Offscreen QA oracle only. Gameplay visibility/physics/materials stay intact.
    public static class GooseVisibilityReferenceCapture
    {
        [Serializable] public sealed class LightInfo { public string name, type, shadows; public float intensity, shadowStrength; }
        [Serializable] public sealed class Result
        {
            public string scope = "Same-frame original-material camera images; hidden inventory renderers enabled only for offscreen reference, never gameplay or physics. Not an FPS measurement.";
            public int width, height, msaa, frame, inventory, productionRenderers, referenceRenderers, changedPixels, noisePixels;
            public string colorSpace, actualFile, referenceFile, noiseFile;
            public bool sRgb, sameFrame, passed, noisePassed, rendererStateRestored;
            public float changedFraction, meanRgbDifference, noiseFraction, noiseMeanRgbDifference;
            public float channelThreshold = 8f / 255f, maximumFraction = .0025f, maximumMean = .001f;
            public Rect viewport;
            public bool shadowControl, preserveProductionCasters, casterControlApplicable = true, casterStateRestored;
            public int addedColorRenderers;
            public List<int> productionCasters = new List<int>(), referenceCasters = new List<int>();
            public string originalShadowQuality, sampledShadowQuality, shadowResolution;
            public float shadowDistance;
            public List<LightInfo> lights = new List<LightInfo>();
        }
        struct SavedRenderer { public Renderer renderer; public bool enabled, forcedOff, hiddenByDepth; public UnityEngine.Rendering.ShadowCastingMode casting; }
        struct SavedLight { public Light light; public LightShadows shadows; }
        public static Result Capture(GooseGame game, string output, string label, bool disableShadows = false, bool preserveProductionCasters = false)
        {
            Directory.CreateDirectory(output);
            var camera = game.MainCamera; var originalTarget = camera.targetTexture; var originalActive = RenderTexture.active;
            int width = originalTarget ? originalTarget.width : Screen.width;
            int height = originalTarget ? originalTarget.height : Screen.height;
            var descriptor = new RenderTextureDescriptor(width, height, RenderTextureFormat.ARGB32, 24) { msaaSamples = Mathf.Max(1, QualitySettings.antiAliasing) };
            descriptor.msaaSamples = SystemInfo.GetRenderTextureSupportedMSAASampleCount(descriptor);
            var actualTarget = RenderTexture.GetTemporary(descriptor); var referenceTarget = RenderTexture.GetTemporary(descriptor);
            var resolve = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);
            var result = new Result { width = width, height = height, msaa = descriptor.msaaSamples, sRgb = descriptor.sRGB,
                colorSpace = QualitySettings.activeColorSpace.ToString(), frame = Time.frameCount, viewport = camera.rect,
                actualFile = label + "-actual.png", referenceFile = label + "-full-reference.png", noiseFile = label + "-self-reference.png" };
            result.preserveProductionCasters = preserveProductionCasters;
            if (preserveProductionCasters) result.scope = "Same-frame original-material color geometry with the production shadow-caster set retained. Newly enabled color renderers cast no new shadows; does not test full-scene restored shadow lighting. Not an FPS measurement.";
            var originalShadowQuality = QualitySettings.shadows;
            result.originalShadowQuality = originalShadowQuality.ToString(); result.shadowResolution = QualitySettings.shadowResolution.ToString();
            result.shadowDistance = QualitySettings.shadowDistance; result.shadowControl = disableShadows;
            var lights = new List<SavedLight>();
            foreach (var light in UnityEngine.Object.FindObjectsOfType<Light>())
            {
                if (!light.enabled || !light.gameObject.activeInHierarchy) continue;
                lights.Add(new SavedLight { light = light, shadows = light.shadows });
                result.lights.Add(new LightInfo { name = light.name, type = light.type.ToString(), shadows = light.shadows.ToString(),
                    intensity = light.intensity, shadowStrength = light.shadowStrength });
            }
            var saved = new List<SavedRenderer>(); var unique = new HashSet<Renderer>();
            Texture2D actual = null, noise = null, reference = null;
            try
            {
                if (disableShadows)
                {
                    QualitySettings.shadows = ShadowQuality.Disable;
                    foreach (var state in lights) if (state.light) state.light.shadows = LightShadows.None;
                }
                result.sampledShadowQuality = QualitySettings.shadows.ToString();
                foreach (var item in game.Items)
                {
                    if (!item || item.Picked || !item.gameObject.activeInHierarchy) continue;
                    result.inventory++;
                    foreach (var renderer in item.Renderers)
                    {
                        if (!renderer || !renderer.gameObject.activeInHierarchy || !unique.Add(renderer)) continue;
                        saved.Add(new SavedRenderer { renderer = renderer, enabled = renderer.enabled, forcedOff = renderer.forceRenderingOff,
                            hiddenByDepth = !item.DepthVisible, casting = renderer.shadowCastingMode });
                        if (renderer.enabled && !renderer.forceRenderingOff && renderer.shadowCastingMode != UnityEngine.Rendering.ShadowCastingMode.Off)
                            result.productionCasters.Add(renderer.GetInstanceID());
                        if (renderer.enabled && !renderer.forceRenderingOff) result.productionRenderers++;
                    }
                }
                actual = Render(camera, actualTarget, resolve, width, height);
                noise = Render(camera, referenceTarget, resolve, width, height);
                foreach (var state in saved)
                {
                    // A forced-off effect or a disabled renderer of a logically
                    // visible item is not claimed by this depth-culling oracle.
                    if (state.hiddenByDepth && !state.forcedOff && !state.enabled)
                    {
                        if (preserveProductionCasters)
                        {
                            if (state.casting == UnityEngine.Rendering.ShadowCastingMode.ShadowsOnly)
                                result.casterControlApplicable = false;
                            else state.renderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                        }
                        state.renderer.enabled = true; result.addedColorRenderers++;
                    }
                    if (state.renderer.enabled && !state.renderer.forceRenderingOff && state.renderer.shadowCastingMode != UnityEngine.Rendering.ShadowCastingMode.Off)
                        result.referenceCasters.Add(state.renderer.GetInstanceID());
                    if (state.renderer.enabled && !state.renderer.forceRenderingOff) result.referenceRenderers++;
                }
                result.productionCasters.Sort(); result.referenceCasters.Sort();
                if (preserveProductionCasters)
                {
                    result.casterControlApplicable &= result.productionCasters.Count == result.referenceCasters.Count;
                    for (int i = 0; i < Mathf.Min(result.productionCasters.Count, result.referenceCasters.Count); i++)
                        result.casterControlApplicable &= result.productionCasters[i] == result.referenceCasters[i];
                }
                reference = Render(camera, referenceTarget, resolve, width, height);
                File.WriteAllBytes(Path.Combine(output, result.actualFile), actual.EncodeToPNG());
                File.WriteAllBytes(Path.Combine(output, result.noiseFile), noise.EncodeToPNG());
                File.WriteAllBytes(Path.Combine(output, result.referenceFile), reference.EncodeToPNG());
                var actualPixels = actual.GetPixels32();
                Compare(actualPixels, reference.GetPixels32(), width, height, result.viewport, out result.changedPixels, out result.changedFraction, out result.meanRgbDifference);
                Compare(actualPixels, noise.GetPixels32(), width, height, result.viewport, out result.noisePixels, out result.noiseFraction, out result.noiseMeanRgbDifference);
                result.sameFrame = result.frame == Time.frameCount;
                result.noisePassed = result.noiseFraction <= result.maximumFraction && result.noiseMeanRgbDifference <= result.maximumMean;
                result.passed = result.casterControlApplicable && result.sameFrame && result.noisePassed && result.changedFraction <= result.maximumFraction && result.meanRgbDifference <= result.maximumMean;
            }
            finally
            {
                result.rendererStateRestored = true; result.casterStateRestored = true;
                foreach (var state in saved)
                {
                    if (!state.renderer) { result.rendererStateRestored = false; continue; }
                    state.renderer.enabled = state.enabled; state.renderer.forceRenderingOff = state.forcedOff; state.renderer.shadowCastingMode = state.casting;
                    result.casterStateRestored &= state.renderer.shadowCastingMode == state.casting;
                    result.rendererStateRestored &= state.renderer.enabled == state.enabled && state.renderer.forceRenderingOff == state.forcedOff;
                }
                camera.targetTexture = originalTarget; RenderTexture.active = originalActive;
                QualitySettings.shadows = originalShadowQuality;
                foreach (var state in lights) if (state.light) state.light.shadows = state.shadows;
                if (actual) UnityEngine.Object.Destroy(actual); if (noise) UnityEngine.Object.Destroy(noise); if (reference) UnityEngine.Object.Destroy(reference);
                RenderTexture.ReleaseTemporary(actualTarget); RenderTexture.ReleaseTemporary(referenceTarget); RenderTexture.ReleaseTemporary(resolve);
            }
            result.passed &= result.rendererStateRestored && result.casterStateRestored;
            File.WriteAllText(Path.Combine(output, label + "-reference.json"), JsonUtility.ToJson(result, true));
            return result;
        }
        [Serializable] sealed class Contributor
        {
            public string item; public int instanceId, renderers, changedPixels;
            public float changedFraction, meanRgbDifference;
        }
        [Serializable] sealed class Contributors
        {
            public string scope = "QA diagnostic: independently restore one depth-hidden item's original color geometry with no additional shadow casting, compare to same-frame production. Individual contributions are not additive and not an acceptance gate.";
            public bool restored; public List<Contributor> entries = new List<Contributor>();
        }
        public static void DiagnoseContributors(GooseGame game, string output)
        {
            var camera = game.MainCamera; var originalTarget = camera.targetTexture; var originalActive = RenderTexture.active;
            int width = originalTarget ? originalTarget.width : Screen.width, height = originalTarget ? originalTarget.height : Screen.height;
            var descriptor = new RenderTextureDescriptor(width, height, RenderTextureFormat.ARGB32, 24) { msaaSamples = Mathf.Max(1, QualitySettings.antiAliasing) };
            descriptor.msaaSamples = SystemInfo.GetRenderTextureSupportedMSAASampleCount(descriptor);
            var target = RenderTexture.GetTemporary(descriptor); var resolve = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);
            var report = new Contributors { restored = true }; Texture2D actual = null, candidate = null;
            var saved = new List<SavedRenderer>();
            try
            {
                actual = Render(camera, target, resolve, width, height); var originalPixels = actual.GetPixels32();
                foreach (var item in game.Items)
                {
                    if (!item || item.Picked || item.DepthVisible || !item.gameObject.activeInHierarchy) continue;
                    saved.Clear(); var entry = new Contributor { item = item.Id, instanceId = item.GetInstanceID() };
                    try
                    {
                        foreach (var renderer in item.Renderers)
                        {
                            if (!renderer || renderer.enabled || renderer.forceRenderingOff || !renderer.gameObject.activeInHierarchy ||
                                renderer.shadowCastingMode == UnityEngine.Rendering.ShadowCastingMode.ShadowsOnly) continue;
                            saved.Add(new SavedRenderer { renderer = renderer, enabled = renderer.enabled, forcedOff = renderer.forceRenderingOff, casting = renderer.shadowCastingMode });
                            renderer.enabled = true; renderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off; entry.renderers++;
                        }
                        if (entry.renderers == 0) continue;
                        candidate = Render(camera, target, resolve, width, height);
                        Compare(originalPixels, candidate.GetPixels32(), width, height, camera.rect,
                            out entry.changedPixels, out entry.changedFraction, out entry.meanRgbDifference);
                        report.entries.Add(entry);
                    }
                    finally
                    {
                        foreach (var state in saved) if (state.renderer)
                        {
                            state.renderer.enabled = state.enabled; state.renderer.forceRenderingOff = state.forcedOff; state.renderer.shadowCastingMode = state.casting;
                            report.restored &= state.renderer.enabled == state.enabled && state.renderer.forceRenderingOff == state.forcedOff && state.renderer.shadowCastingMode == state.casting;
                        }
                        else report.restored = false;
                        if (candidate) UnityEngine.Object.Destroy(candidate); candidate = null;
                    }
                }
            }
            finally
            {
                camera.targetTexture = originalTarget; RenderTexture.active = originalActive;
                if (actual) UnityEngine.Object.Destroy(actual); if (candidate) UnityEngine.Object.Destroy(candidate);
                RenderTexture.ReleaseTemporary(target); RenderTexture.ReleaseTemporary(resolve);
            }
            report.entries.Sort((a,b) => b.changedPixels.CompareTo(a.changedPixels));
            File.WriteAllText(Path.Combine(output, "hidden-color-contributors.json"), JsonUtility.ToJson(report, true));
        }
        static Texture2D Render(Camera camera, RenderTexture target, RenderTexture resolve, int width, int height)
        {
            camera.targetTexture = target; RenderTexture.active = target; GL.Clear(true, true, Color.clear);
            camera.Render(); Graphics.Blit(target, resolve); RenderTexture.active = resolve;
            var texture = new Texture2D(width, height, TextureFormat.RGBA32, false);
            texture.ReadPixels(new Rect(0, 0, width, height), 0, 0); texture.Apply(); return texture;
        }
        static void Compare(Color32[] actual, Color32[] expected, int width, int height, Rect viewport,
            out int changed, out float fraction, out float mean)
        {
            changed = 0; long total = 0; int count = 0;
            int x0 = Mathf.Clamp(Mathf.FloorToInt(viewport.xMin * width), 0, width), x1 = Mathf.Clamp(Mathf.CeilToInt(viewport.xMax * width), 0, width);
            int y0 = Mathf.Clamp(Mathf.FloorToInt(viewport.yMin * height), 0, height), y1 = Mathf.Clamp(Mathf.CeilToInt(viewport.yMax * height), 0, height);
            for (int y = y0; y < y1; y++) for (int x = x0; x < x1; x++)
            {
                int i = y * width + x; int r = Math.Abs(actual[i].r - expected[i].r), g = Math.Abs(actual[i].g - expected[i].g), b = Math.Abs(actual[i].b - expected[i].b);
                if (r > 8 || g > 8 || b > 8) changed++;
                total += r + g + b; count++;
            }
            fraction = count == 0 ? 1 : (float)changed / count; mean = count == 0 ? 1 : (float)((double)total / (count * 3.0 * 255));
        }
    }
}
#endif
