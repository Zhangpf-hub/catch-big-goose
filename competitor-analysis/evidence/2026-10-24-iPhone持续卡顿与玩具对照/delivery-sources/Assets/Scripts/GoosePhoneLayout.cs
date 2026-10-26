using UnityEngine;

namespace CatchGoose
{
    // One coordinate system for safe UI and the 3D viewport. Width is always 720.
    public sealed class GoosePhoneLayout : MonoBehaviour
    {
        public RectTransform Frame, Top, Bottom;
        public Camera WorldCamera;
        public float Height { get; private set; } = 1280;
        Rect lastSafe;
        int lastWidth, lastHeight;
        float lastScale;
        Rect? platformSafe;
        public void SetPlatformSafeArea(Rect normalized)
        { platformSafe = normalized; Refresh(true); }

        public void Refresh(bool force = false)
        {
            if (!Frame || !WorldCamera) return;
            Rect safe = Screen.safeArea;
            if (platformSafe.HasValue)
            {
                var n = platformSafe.Value;
                safe = new Rect(n.x*Screen.width,n.y*Screen.height,n.width*Screen.width,n.height*Screen.height);
            }
            if (safe.width <= 0 || safe.height <= 0) safe = new Rect(0, 0, Screen.width, Screen.height);
            // On tablets/desktop keep a portrait play area; phones use all safe height.
            float width = Mathf.Min(safe.width, safe.height * .625f);
            safe.x += (safe.width - width) * .5f; safe.width = width;
            float scale = Frame.GetComponentInParent<Canvas>().scaleFactor;
            if (!force && lastWidth == Screen.width && lastHeight == Screen.height && safe == lastSafe && Mathf.Approximately(lastScale, scale)) return;
            lastScale = scale;
            lastWidth = Screen.width; lastHeight = Screen.height; lastSafe = safe;
            Height = 720 * safe.height / safe.width;
            Frame.anchorMin = Frame.anchorMax = Vector2.zero;
            Frame.pivot = new Vector2(.5f, .5f);
            Frame.anchoredPosition = safe.center / scale;
            Frame.sizeDelta = new Vector2(720, Height);
            Frame.localScale = Vector3.one * (safe.width / (720 * scale));
            if (Top) Top.anchoredPosition = new Vector2(0, Height - 1280);
            // Reserve distinct bands for status, playable world and tray/tools.
            float lower = 320, upper = Height - 170;
            var viewport = new Rect(safe.x / Screen.width,
                (safe.y + lower / Height * safe.height) / Screen.height,
                safe.width / Screen.width, (upper - lower) / Height * safe.height / Screen.height);
            WorldCamera.rect = viewport;
            float aspect = viewport.width * Screen.width / (viewport.height * Screen.height);
            WorldCamera.orthographicSize = Mathf.Max(2.30f, 2.15f / aspect);
            // Aim at the centre of the container, independent of phone height.
            WorldCamera.transform.position = new Vector3(0, 8.2f, .50f);
        }
        void LateUpdate() { Refresh(); }
    }
}
