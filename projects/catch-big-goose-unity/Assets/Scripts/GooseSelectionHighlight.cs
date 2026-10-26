using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace CatchGoose
{
    [Serializable] public sealed class GooseSelectionSettings
    {
        [Serializable] public sealed class GlowPass { public float offset = 1, alpha = 1; public Color color; }
        public string source;
        public float overlay, overlayAnimationSpeed, overlayMinIntensity, overlayBlending;
        public Color overlayColor, outlineColor, seeThroughTintColor;
        public float outline, outlineWidth, glow, glowWidth, glowAnimationSpeed, glowMagicNumber1, glowMagicNumber2;
        public int outlineQuality, glowQuality, constantWidth, glowDithering, glowBlendPasses, seeThrough;
        public float seeThroughIntensity, seeThroughTintAlpha, seeThroughNoise;
        public GlowPass[] glowPasses;
    }

    // Specialized migration of the serialized Medium Highlight Plus path. Source
    // GLSL, WASM branches and state tables are retained in competitor-analysis.
    // Other plugin features are not dependencies of gameplay selection.
    public sealed class GooseSelectionHighlight : MonoBehaviour
    {
        sealed class Part
        {
            public Renderer renderer;
            public Mesh mesh, baked;
            public SkinnedMeshRenderer skin;
            public GooseSelectionGeometry.Geometry geometry;
            public MaterialPropertyBlock[] properties;
            public readonly Matrix4x4[] matrices = new Matrix4x4[8];
            public readonly List<Vector3> normals = new List<Vector3>();
            public Vector3[] sums;
        }
        readonly List<Part> parts = new List<Part>(8);
        readonly Dictionary<GooseItem, List<Part>> bindings = new Dictionary<GooseItem, List<Part>>();
        static readonly Vector2[] offsets = { Vector2.up, Vector2.right, Vector2.down, Vector2.left,
            new Vector2(.70711f,.70711f), new Vector2(.70711f,-.70711f), new Vector2(-.70711f,.70711f), new Vector2(-.70711f,-.70711f) };
        static readonly int Direction = Shader.PropertyToID("_Direction");
        readonly Vector4[] directions = new Vector4[8];
        GooseGame game;
        Material effect;
        CommandBuffer commands;
        public GooseItem Target { get; private set; }
        public GooseSelectionSettings Settings { get; private set; }
        public int LastDraws { get; private set; }
        public int LastInstances { get; private set; }
        public float LastCpuMs { get; private set; }
        public int BindingCount => bindings.Count;

        public void Initialize(GooseGame owner)
        {
            game = owner;
            var data = Resources.Load<TextAsset>("Data/selection-highlight");
            if (!data) throw new InvalidOperationException("Missing selection-highlight source configuration");
            Settings = JsonUtility.FromJson<GooseSelectionSettings>(data.text);
            if (Settings.outlineQuality != 3 || Settings.glowQuality != 3)
                throw new InvalidOperationException("Selection profile requires the recovered Medium rendering path");
            var shader = Resources.Load<Shader>("GooseSelectionHighlight");
            if (!shader) throw new InvalidOperationException("Missing selection highlight shader");
            var template = Resources.Load<Material>("GooseSelectionMedium");
            if (!template) throw new InvalidOperationException("Missing selection material / instancing variant reference");
            effect = new Material(template) { name = "GooseSelection-Medium", hideFlags = HideFlags.HideAndDontSave, enableInstancing = true };
            effect.SetFloat("_OutlineWidth", Settings.outlineWidth / 100);
            effect.SetColor("_OutlineColor", new Color(Settings.outlineColor.r, Settings.outlineColor.g, Settings.outlineColor.b, Settings.outline));
            effect.SetFloat("_GlowWidth", Settings.glowWidth / 100);
            effect.SetFloat("_ConstantWidth", Settings.constantWidth);
            effect.SetVector("_OverlayData", new Vector4(Settings.overlayAnimationSpeed, Settings.overlayMinIntensity, Settings.overlayBlending, 1));
            var overlay = Settings.overlayColor; overlay.a = Settings.overlay;
            effect.SetColor("_OverlayColor", overlay);
            effect.SetFloat("_SeeThrough", Settings.seeThroughIntensity);
            var tint = Settings.seeThroughTintColor; tint.a = Settings.seeThroughTintAlpha;
            effect.SetColor("_SeeThroughTintColor", tint);
            effect.SetFloat("_SeeThroughNoise", Settings.seeThroughNoise);
            commands = new CommandBuffer { name = "Goose selection / reference Medium" };
            Debug.Log("[GooseSelection] SELECT1 / reference Medium / " + Settings.source);
        }

        public void SetTarget(GooseItem item)
        {
            if (ReferenceEquals(Target, item)) return;
            Target = item; parts.Clear(); LastDraws = LastInstances = 0; LastCpuMs = 0;
            if (commands != null) commands.Clear();
            if (!item) return;
            if (!bindings.TryGetValue(item, out var cached))
            {
                cached = new List<Part>();
                foreach (var renderer in item.Renderers)
                {
                    var skin = renderer as SkinnedMeshRenderer;
                    var filter = renderer.GetComponent<MeshFilter>();
                    var source = skin ? skin.sharedMesh : filter ? filter.sharedMesh : null;
                    if (!source) continue;
                    var geometry = GooseSelectionGeometry.Prepare(source);
                    if (geometry == null) continue;
                    var originals = renderer.sharedMaterials;
                    var part = new Part { renderer = renderer, mesh = geometry.mesh, skin = skin, geometry = geometry,
                        properties = new MaterialPropertyBlock[source.subMeshCount] };
                    if (skin)
                    {
                        part.baked = new Mesh { name = source.name + "_SelectedPose" }; part.baked.MarkDynamic();
                        part.normals.Capacity = source.vertexCount; part.sums = new Vector3[geometry.groupCount];
                    }
                    for (int sub = 0; sub < part.properties.Length; sub++)
                    {
                        var props = new MaterialPropertyBlock();
                        var original = originals.Length > 0 ? originals[Mathf.Min(sub, originals.Length - 1)] : null;
                        props.SetTexture("_MainTex", original && original.mainTexture ? original.mainTexture : Texture2D.whiteTexture);
                        props.SetColor("_OverlayBackColor", original && original.HasProperty("_Color") ? original.color : Color.white);
                        var scale = original ? original.mainTextureScale : Vector2.one;
                        var offset = original ? original.mainTextureOffset : Vector2.zero;
                        props.SetVector("_MainTex_ST", new Vector4(scale.x, scale.y, offset.x, offset.y));
                        part.properties[sub] = props;
                    }
                    cached.Add(part);
                }
                bindings.Add(item, cached);
            }
            parts.AddRange(cached);
        }

        public void Forget(GooseItem item)
        {
            if (Target == item) SetTarget(null);
            if (!bindings.TryGetValue(item, out var cached)) return;
            foreach (var part in cached) if (part.baked) Destroy(part.baked);
            bindings.Remove(item);
        }

        void Draw(Part part, int pass, Vector4 direction)
        {
            if (!part.renderer || !part.renderer.enabled || !part.renderer.gameObject.activeInHierarchy) return;
            for (int sub = 0; sub < part.properties.Length; sub++)
            {
                var props = part.properties[sub];
                // Do not change an instanced vector array into a scalar property.
                if (pass == 2 || pass == 3) props.SetVector(Direction, direction);
                commands.DrawMesh(part.skin ? part.baked : part.mesh, part.renderer.localToWorldMatrix, effect, sub, pass, props);
                LastDraws++;
                LastInstances++;
            }
        }

        void DrawOffsets(Part part, int pass)
        {
            if (!part.renderer || !part.renderer.enabled || !part.renderer.gameObject.activeInHierarchy) return;
            if (!SystemInfo.supportsInstancing)
            { foreach (var direction in directions) Draw(part, pass, direction); return; }
            var matrix = part.renderer.localToWorldMatrix;
            for (int i = 0; i < part.matrices.Length; i++) part.matrices[i] = matrix;
            for (int sub = 0; sub < part.properties.Length; sub++)
            {
                var props = part.properties[sub]; props.SetVectorArray(Direction, directions);
                commands.DrawMeshInstanced(part.skin ? part.baked : part.mesh, sub, effect, pass, part.matrices, 8, props);
                LastDraws++; LastInstances += 8;
            }
        }

        void OnRenderObject()
        {
            var camera = Camera.current;
            if (!game || camera != game.MainCamera || !Target || !effect) return;
            if (!game.CanSelectItems || Target.Picked || Target.Frozen || !Target.DepthVisible || !Target.gameObject.activeInHierarchy)
            { game.CancelPointer(); return; }
            long started = System.Diagnostics.Stopwatch.GetTimestamp();
            LastDraws = LastInstances = 0; commands.Clear();
            for (int i = 0; i < offsets.Length; i++) directions[i] = new Vector4(offsets[i].x, offsets[i].y * camera.aspect, 0, 0);
            commands.BeginSample("GooseSelectionHighlight");
            commands.DrawProcedural(Matrix4x4.identity, effect, 0, MeshTopology.Triangles, 3);
            foreach (var part in parts)
            {
                if (part.skin)
                {
                    part.skin.BakeMesh(part.baked);
                    part.baked.GetNormals(part.normals); Array.Clear(part.sums, 0, part.sums.Length);
                    for (int i = 0; i < part.normals.Count; i++) part.sums[part.geometry.groups[i]] += part.normals[i];
                    for (int i = 0; i < part.normals.Count; i++) part.normals[i] = part.sums[part.geometry.groups[i]].normalized;
                    part.baked.SetNormals(part.normals);
                }
                Draw(part, 1, Vector4.zero); // Full silhouette stencil, including occluded fragments.
            }
            // Medium uses eight offsets; Highest alone uses blur render textures.
            if (Settings.glow > 0) foreach (var glow in Settings.glowPasses)
            {
                commands.SetGlobalColor("_SelectionGlowColor", glow.color);
                commands.SetGlobalVector("_SelectionGlow", new Vector4(Settings.glow * glow.alpha, glow.offset * Settings.glowWidth / 100,
                    Settings.glowMagicNumber1, Settings.glowMagicNumber2));
                commands.SetGlobalVector("_SelectionGlow2", new Vector4(Settings.outlineWidth / 100, Settings.glowAnimationSpeed, Settings.glowDithering == 0 ? 1 : 0, 0));
                foreach (var part in parts) DrawOffsets(part, 2);
            }
            if (Settings.outline > 0) foreach (var part in parts) DrawOffsets(part, 3);
            if (Settings.overlay > 0) foreach (var part in parts) Draw(part, 4, Vector4.zero);
            // SeeThrough is WhenHighlighted in the frozen configuration. GPU depth
            // classification replaces the plugin's periodic CPU occluder broad phase.
            if (Settings.seeThrough != 2 && Settings.seeThroughIntensity > 0)
                foreach (var part in parts) Draw(part, 5, Vector4.zero);
            commands.DrawProcedural(Matrix4x4.identity, effect, 0, MeshTopology.Triangles, 3);
            commands.EndSample("GooseSelectionHighlight");
            Graphics.ExecuteCommandBuffer(commands);
            LastCpuMs = (float)((System.Diagnostics.Stopwatch.GetTimestamp() - started) * 1000d / System.Diagnostics.Stopwatch.Frequency);
        }

        void OnDestroy()
        {
            foreach (var cached in bindings.Values) foreach (var part in cached) if (part.baked) Destroy(part.baked);
            bindings.Clear(); commands?.Release(); if (effect) Destroy(effect);
        }
    }
}
