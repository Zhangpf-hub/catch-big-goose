using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
using WeChatWASM;
#endif

namespace CatchGoose
{
    public sealed class GooseWeChatPlatform : MonoBehaviour
    {
        public static bool HandlesPointer { get; private set; }
        public bool SetReferencePixelRatio(float ratio)
        {
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
            if(!HandlesPointer)return false;WX.SetDevicePixelRatio(ratio);return true;
#else
            return false;
#endif
        }
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
        GooseGame game;
        readonly Dictionary<int, Vector2> touches = new Dictionary<int, Vector2>();
        readonly List<RaycastResult> uiHits = new List<RaycastResult>();
        public void Initialize(GooseGame owner)
        {
            game = owner;
            WX.InitSDK(code =>
            {
                if (!this) return;
                Debug.Log("[GooseWeChat] WXSDK initialized: " + code);
                WX.SetPreferredFramesPerSecond(30);
                ApplySafeArea();
                WX.OnWindowResize(WindowResized);
                HandlesPointer = true;
                if (EventSystem.current && !EventSystem.current.GetComponent<WXTouchInputOverride>())
                    EventSystem.current.gameObject.AddComponent<WXTouchInputOverride>();
                WX.OnTouchStart(TouchStart); WX.OnTouchEnd(TouchEnd); WX.OnTouchCancel(TouchCancel);
                WX.OnHide(Hidden);
                StartCoroutine(ReportReady());
            });
        }
        void WindowResized(OnWindowResizeListenerResult evt) { ApplySafeArea(); }
        void ApplySafeArea()
        {
            var info = WX.GetSystemInfoSync();
            var menu = WX.GetMenuButtonBoundingClientRect();
            float w = (float)info.windowWidth, h = (float)info.windowHeight;
            if (w <= 0 || h <= 0) return;
            float left = 0, right = w, top = 0, bottom = h;
            if (info.safeArea != null)
            {
                left = (float)info.safeArea.left; right = (float)info.safeArea.right;
                top = (float)info.safeArea.top; bottom = (float)info.safeArea.bottom;
            }
            // The WeChat capsule is inside the OS safe area: reserve it explicitly.
            if (menu != null && menu.height > 0) top = Mathf.Max(top, (float)menu.bottom + 8);
            if (right > left && bottom > top)
                game.Hud.GetComponent<GoosePhoneLayout>().SetPlatformSafeArea(new Rect(left/w,(h-bottom)/h,(right-left)/w,(bottom-top)/h));
        }
        IEnumerator ReportReady()
        {
            yield return new WaitForEndOfFrame();
            WX.ReportGameStart();
            Debug.Log("[GooseWeChat] First interactive frame reported");
        }
        bool OverUi(Vector2 position)
        {
            if (!EventSystem.current) return false;
            uiHits.Clear();
            EventSystem.current.RaycastAll(new PointerEventData(EventSystem.current) { position = position }, uiHits);
            return uiHits.Count != 0;
        }
        void TouchStart(OnTouchStartListenerResult evt)
        {
            foreach (var t in evt.changedTouches)
            {
                var position = new Vector2(t.clientX, t.clientY);
                // The SDK already converts CSS coordinates to Unity screen pixels and flips Y.
                if (game.Playing && !game.Paused && !OverUi(position)) touches[t.identifier] = position;
            }
        }
        void TouchEnd(OnTouchStartListenerResult evt)
        {
            foreach (var t in evt.changedTouches)
            {
                var position = new Vector2(t.clientX, t.clientY);
                if (touches.TryGetValue(t.identifier, out var began) && Vector2.Distance(began, position) <= 40
                    && !OverUi(position)) game.PickAtScreenPosition(position);
                touches.Remove(t.identifier);
            }
        }
        void TouchCancel(OnTouchStartListenerResult evt) { touches.Clear(); }
        void Hidden(GeneralCallbackResult evt)
        {
            touches.Clear(); PlayerPrefs.Save();
            if (game.Video.Active) game.Video.Close();
            if (game.Playing && !game.Paused) game.Pause();
        }
        void OnDestroy()
        {
            if (HandlesPointer)
            {
                WX.OffTouchStart(TouchStart); WX.OffTouchEnd(TouchEnd); WX.OffTouchCancel(TouchCancel);
                WX.OffHide(Hidden);
                WX.OffWindowResize(WindowResized);
            }
            HandlesPointer = false;
        }
#else
        public void Initialize(GooseGame owner) { }
#endif
    }
}
