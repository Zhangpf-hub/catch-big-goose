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
        bool accelerometer;
        int preferredFps;
        readonly Dictionary<int, Vector2> touches = new Dictionary<int, Vector2>();
        readonly List<RaycastResult> uiHits = new List<RaycastResult>();
        public void Initialize(GooseGame owner)
        {
            game = owner;
            WX.InitSDK(code =>
            {
                if (!this) return;
                Debug.Log("[GooseWeChat] WXSDK initialized: " + code);
                var device=WX.GetSystemInfoSync();
                game.ShakeDiagnostics?.Environment(device.platform,device.model,device.version,device.SDKVersion);
                WX.SetDevicePixelRatio(2f);
                ApplyFrameRate();
                ApplySafeArea();
                WX.OnWindowResize(WindowResized);
                HandlesPointer = true;
                if (EventSystem.current && !EventSystem.current.GetComponent<WXTouchInputOverride>())
                    EventSystem.current.gameObject.AddComponent<WXTouchInputOverride>();
                WX.OnTouchStart(TouchStart); WX.OnTouchMove(TouchMove); WX.OnTouchEnd(TouchEnd); WX.OnTouchCancel(TouchCancel);
                WX.OnHide(Hidden);
                WX.OnShow(Shown);
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
                if (game.Playing) game.BeginPointer(position, t.identifier);
                else if (!game.Paused && game.HomeStage.CanInteract && !OverUi(position)) touches[t.identifier] = position;
            }
        }
        void TouchEnd(OnTouchStartListenerResult evt)
        {
            foreach (var t in evt.changedTouches)
            {
                var position = new Vector2(t.clientX, t.clientY);
                if (game.Playing) { game.EndPointer(position, t.identifier); touches.Remove(t.identifier); continue; }
                if (touches.TryGetValue(t.identifier, out var began) && Vector2.Distance(began, position) <= 40
                    && !OverUi(position))
                {
                    game.HomeStage.TryReactAtScreenPosition(position);
                }
                touches.Remove(t.identifier);
            }
        }
        void TouchMove(OnTouchStartListenerResult evt)
        { foreach (var t in evt.changedTouches) game.MovePointer(new Vector2(t.clientX, t.clientY), t.identifier); }
        void TouchCancel(OnTouchStartListenerResult evt)
        { foreach (var t in evt.changedTouches) game.CancelPointer(t.identifier); touches.Clear(); }
        void Shown(OnShowListenerResult evt) { game.SetAppVisible(true);game.Shake.ResetSensor();preferredFps=0;ApplyFrameRate(); }
        void ApplyFrameRate()
        {
            int fps=GooseRuntimePerformance.PreferredFrameRate;
            if(fps==preferredFps)return;
            WX.SetPreferredFramesPerSecond(fps);preferredFps=fps;
        }
        void Acceleration(OnAccelerometerChangeListenerResult evt)
        {
            if(!accelerometer)return;
            var sample=new Vector3((float)evt.x,(float)evt.y,(float)evt.z);
            game.ShakeDiagnostics?.Callback(sample);game.Shake.Sample(sample,Time.unscaledTime);
        }
        void Update()
        {
            if(!HandlesPointer||!game||!game.Shake)return;
            ApplyFrameRate();
            bool needed=game.Playing&&!game.Paused&&game.SpawnComplete;
            if(needed==accelerometer)return;
            accelerometer=needed;game.Shake.ResetSensor();
            if(needed)
            {
                WX.OnAccelerometerChange(Acceleration);
                int attempt=game.ShakeDiagnostics.Begin();
                WX.StartAccelerometer(new StartAccelerometerOption{interval="ui",
                    success=r=>{if(game.ShakeDiagnostics.StartResult(attempt,true,r.errMsg))game.Shake.SensorAvailable=true;},
                    fail=r=>{if(game.ShakeDiagnostics.StartResult(attempt,false,r.errMsg))game.Shake.SensorAvailable=false;Debug.LogWarning("[GooseShake] sensor unavailable: "+r.errMsg);}});
            }
            else{WX.OffAccelerometerChange(Acceleration);game.Shake.SensorAvailable=false;game.ShakeDiagnostics.Stop(game.Paused?"已暂停监听":"已退出关卡");WX.StopAccelerometer(new StopAccelerometerOption{success=r=>Debug.Log("[GooseShakeTest] stop_success "+r.errMsg),fail=r=>Debug.LogWarning("[GooseShakeTest] stop_failed "+r.errMsg)});}
        }
        void Hidden(GeneralCallbackResult evt)
        {
            game.SetAppVisible(false);
            game.CancelPointer(); touches.Clear(); PlayerPrefs.Save();
            game.Shake.ResetSensor();
            if(accelerometer){WX.OffAccelerometerChange(Acceleration);WX.StopAccelerometer(new StopAccelerometerOption{});accelerometer=false;game.Shake.SensorAvailable=false;game.ShakeDiagnostics.Stop("已切到后台");}
            if (game.Video.Active) game.Video.Close();
            if (game.Playing && !game.Paused) game.Pause();
        }
        void OnDestroy()
        {
            if (HandlesPointer)
            {
                game.CancelPointer();
                WX.OffTouchStart(TouchStart); WX.OffTouchMove(TouchMove); WX.OffTouchEnd(TouchEnd); WX.OffTouchCancel(TouchCancel);
                WX.OffHide(Hidden);
                WX.OffShow(Shown);WX.OffAccelerometerChange(Acceleration);
                if(accelerometer)WX.StopAccelerometer(new StopAccelerometerOption{});
                WX.OffWindowResize(WindowResized);
            }
            HandlesPointer = false;
        }
#else
        public void Initialize(GooseGame owner) { }
#endif
    }
}
