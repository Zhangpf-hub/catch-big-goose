using System.Collections.Generic;
using UnityEngine;

namespace CatchGoose
{
    // The picked mesh remains a mesh. A small overlay camera avoids render textures
    // and lets it cross the world viewport edge into the camera-space HUD.
    public sealed class GooseTrayPresentation : MonoBehaviour
    {
        public const float SlideTime = .20f, MatchMoveTime = .15f, MatchZoomTime = .10f;
        sealed class Entry
        {
            public GooseItem item;
            public Vector3 originalScale, scaleFrom, scaleTo;
            public Quaternion rotationFrom, rotationTo;
            public Vector2 from, current, target;
            public float started, duration, lift;
            public int slot;
            public bool stored, combining;
        }
        readonly Dictionary<GooseItem, Entry> entries = new Dictionary<GooseItem, Entry>();
        GooseGame game;
        Camera cameraView;
        public Camera Camera => cameraView;
        public bool Moving { get; private set; }
        float PixelScale => cameraView.orthographicSize * 2 / Screen.height;
        public void Initialize(GooseGame owner)
        {
            game = owner;
            cameraView = new GameObject("TrayMeshCamera").AddComponent<Camera>();
            cameraView.depth = 3; cameraView.clearFlags = CameraClearFlags.Depth;
            cameraView.cullingMask = 1 << 30; cameraView.orthographic = true;
            cameraView.orthographicSize = 10; cameraView.transform.position = new Vector3(0,0,-100);
            cameraView.nearClipPlane = .05f; cameraView.farClipPlane = 20;
            cameraView.enabled = false;
        }
        public bool Contains(GooseItem item) => item && entries.ContainsKey(item);
        public Vector2 ScreenPosition(GooseItem item) => entries[item].current;
        static void Layer(Transform root, int layer)
        { root.gameObject.layer = layer; foreach (Transform child in root) Layer(child, layer); }
        public void Pick(GooseItem item, IList<GooseItem> visualOrder)
        {
            if (!entries.TryGetValue(item, out var entry))
            {
                Vector2 screen = game.MainCamera.WorldToScreenPoint(item.VisualBounds.center);
                entry = new Entry { item = item, originalScale = item.transform.localScale, current = screen };
                entries.Add(item, entry);
                cameraView.enabled = true;
                float conversion = PixelScale / (game.MainCamera.orthographicSize * 2 / game.MainCamera.pixelHeight);
                item.transform.SetParent(transform, true);
                item.transform.localScale *= conversion;
                item.transform.rotation = cameraView.transform.rotation * Quaternion.Inverse(game.MainCamera.transform.rotation) * item.transform.rotation;
                Layer(item.transform, 30); item.SetDepthVisible(true); item.gameObject.SetActive(true);
                Place(entry, screen);
            }
            entry.stored = false;
            Retarget(visualOrder, item);
        }
        public void Retarget(IList<GooseItem> order, GooseItem picked = null)
        {
            for (int i = 0; i < order.Count; i++)
                if (entries.TryGetValue(order[i], out var entry))
                {
                    entry.slot = i; entry.stored = false;
                    Begin(entry, game.Hud.TrayScreenPoint(i), order[i] == picked);
                }
        }
        public void Store(IList<GooseItem> stored)
        {
            for (int i = 0; i < stored.Count; i++) if (entries.TryGetValue(stored[i], out var entry))
            { entry.slot = i; entry.stored = true; Begin(entry, game.Hud.StoredScreenPoint(i), false); }
        }
        void Begin(Entry e, Vector2 target, bool picked)
        {
            e.from = e.current; e.target = target; e.started = Time.time;
            // Recovered GetDistance weights portrait UI Y/X by .028/.015.
            var delta = (target - e.current) * (88 / Mathf.Max(1, game.Hud.SlotScreenWidth));
            float distance = Mathf.Abs(delta.y) * .028f + Mathf.Abs(delta.x) * .015f;
            e.duration = picked ? Mathf.Clamp(.12f + distance * .01f, .26f, .35f) : SlideTime;
            e.lift = picked ? Mathf.Min(game.Hud.SlotScreenWidth * .65f, Vector2.Distance(e.current, target) * .22f) : 0;
            e.rotationFrom = e.item.transform.rotation; e.rotationTo = Quaternion.Euler(20, 155, 0);
            e.scaleFrom = e.item.transform.localScale;
            var rotation = e.item.transform.rotation;
            e.item.transform.rotation = e.rotationTo;
            var bounds = e.item.VisualBounds;
            float side = Mathf.Max(bounds.size.x, bounds.size.y);
            e.scaleTo = e.scaleFrom * (game.Hud.SlotScreenWidth * .76f * PixelScale / Mathf.Max(.001f, side));
            e.item.transform.rotation = rotation;
            Moving = true;
        }
        static float OutSine(float t) => Mathf.Sin(t * Mathf.PI * .5f);
        void LateUpdate()
        {
            if (game.Paused) return;
            Moving = false;
            foreach (var e in entries.Values)
            {
                if (!e.item || e.combining) continue;
                float t = Mathf.Clamp01((Time.time - e.started) / e.duration);
                float landing = Mathf.Clamp01((Time.time - e.started - e.duration) / .15f);
                var target = e.stored ? game.Hud.StoredScreenPoint(e.slot) : game.Hud.TrayScreenPoint(e.slot);
                float x = e.lift > 0 ? 1 - Mathf.Cos(t * Mathf.PI * .5f) : (t < .5f ? 2*t*t : 1-Mathf.Pow(-2*t+2,2)*.5f);
                float y = OutSine(t);
                e.current = new Vector2(Mathf.Lerp(e.from.x, target.x, x), Mathf.Lerp(e.from.y, target.y, y) + Mathf.Sin(t * Mathf.PI) * e.lift);
                e.current.y -= Mathf.Sin(landing * Mathf.PI) * game.Hud.SlotScreenWidth * .07f;
                e.item.transform.rotation = Quaternion.Slerp(e.rotationFrom, e.rotationTo, y);
                float pulse = 1 + (e.lift > 0 ? .30f : 0) * Mathf.Sin(t * Mathf.PI) + .04f * Mathf.Sin(landing * Mathf.PI);
                e.item.transform.localScale = Vector3.Lerp(e.scaleFrom, e.scaleTo, x) * pulse;
                Place(e, e.current);
                if (t < 1 || landing < 1) Moving = true;
            }
        }
        void Place(Entry e, Vector2 screen)
        {
            var world = cameraView.ScreenToWorldPoint(new Vector3(screen.x, screen.y, 5));
            e.item.transform.position += world - e.item.VisualBounds.center;
        }
        public void Combine(IList<GooseItem> matched, float progress)
        {
            Vector2 centre = Vector2.zero;
            foreach (var item in matched) centre += entries[item].target;
            centre /= matched.Count;
            foreach (var item in matched)
            {
                var e = entries[item]; e.started = Time.time - e.duration;
                e.combining = true;
                float move = Mathf.Clamp01(progress / .6f);
                e.from = e.target = Vector2.Lerp(e.target, centre, move);
                e.current = e.target;
                float scale = progress < .6f ? Mathf.Lerp(1,1.2f,progress/.6f) : Mathf.Lerp(1.2f,0,(progress-.6f)/.4f);
                item.transform.localScale = e.scaleTo * scale;
                Place(e, e.current);
            }
        }
        public void Release(GooseItem item)
        {
            if (!entries.TryGetValue(item, out var e)) return;
            item.transform.SetParent(null, true); item.transform.localScale = e.originalScale;
            Layer(item.transform, 0); entries.Remove(item);
            if(entries.Count==0)cameraView.enabled=false;
        }
        public void ResetRound()
        {
            foreach (var e in entries.Values)
                if (e.item) { e.item.transform.SetParent(null, true); e.item.transform.localScale = e.originalScale; Layer(e.item.transform,0); }
            entries.Clear(); Moving = false;
            cameraView.enabled=false;
        }
    }
}
