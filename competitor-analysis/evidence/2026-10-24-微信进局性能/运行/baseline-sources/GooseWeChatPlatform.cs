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
                HandlesPointer = true;
                if (EventSystem.current && !EventSystem.current.GetComponent<WXTouchInputOverride>())
                    EventSystem.current.gameObject.AddComponent<WXTouchInputOverride>();
                WX.OnTouchStart(TouchStart); WX.OnTouchEnd(TouchEnd); WX.OnTouchCancel(TouchCancel);
                WX.OnHide(Hidden);
                StartCoroutine(ReportReady());
            });
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
            }
            HandlesPointer = false;
        }
#else
        public void Initialize(GooseGame owner) { }
#endif
    }
}
