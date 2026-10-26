using UnityEngine;

namespace CatchGoose
{
    // One coordinate system for safe UI and the 3D viewport. Width is always 720.
    public sealed class GoosePhoneLayout : MonoBehaviour
    {
        // A full stock is physically deep. Look along its depth axis so height
        // does not move the upper layers towards the status bar.
        public const float GameplayPitch = 90f;
        // Dedicated HUD band for the sale truck, above every selectable world
        // pixel. Compact screens fit the plate below this band from the start.
        public const float GameplayTopInset = 360f;
        // Orthographic altitude does not change screen proportions. Larger real
        // models need clearance above a full 300-piece stock at the slider maximum.
        public const float CameraHeight = 40f, MaximumPileHeight = 34f;
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
            float lower = 296, upper = Height - GameplayTopInset;
            var viewport = new Rect(safe.x / Screen.width,
                (safe.y + lower / Height * safe.height) / Screen.height,
                safe.width / Screen.width, (upper - lower) / Height * safe.height / Screen.height);
            WorldCamera.rect = viewport;
            float aspect = viewport.width * Screen.width / (viewport.height * Screen.height);
            // Fit the four-unit container to the screen width, then anchor its
            // near rim above the tray. The old minimum size and fixed aim left
            // increasing gaps on tall phones. Orthographic height changes do not
            // change item-to-container proportions.
            // Short fallback windows must still contain the far rim. This guard
            // does not affect the screenshot or tall-phone aspect ratios.
            WorldCamera.orthographicSize = Mathf.Max(2.10f,3.90f / (2*aspect));
            const float cameraHeight=CameraHeight, nearRimZ=.88f-2, floorY=-.08f;
            Vector3 up=WorldCamera.transform.up;
            float cameraZ=nearRimZ+((floorY-cameraHeight)*up.y+WorldCamera.orthographicSize-.04f)/up.z;
            WorldCamera.transform.position = new Vector3(0,cameraHeight,cameraZ);
        }
        void LateUpdate()
        {
            // Keep the plate's screen silhouette stable while the pile contracts.
            Refresh();
        }
    }
}
