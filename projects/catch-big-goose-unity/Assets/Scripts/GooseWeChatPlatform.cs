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
        bool accelerometerWanted;
        bool accelerometerStopping;
        int accelerometerGeneration, accelerometerAttempts, accelerometerStopGeneration;
        float nextAccelerometerRetry;
        System.Action<OnAccelerometerChangeListenerResult> accelerometerHandler;
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
            if(!NeedsAccelerometer())
            {
                if(accelerometerWanted||accelerometer||accelerometerHandler!=null)
                    StopAccelerometerListener(game.Paused?"已暂停监听":"已退出关卡");
                return;
            }
            if(!accelerometerWanted)
            {accelerometerWanted=true;accelerometerAttempts=0;nextAccelerometerRetry=0;}
            // A delayed stop completion must finish before a new listener starts.
            if(accelerometer||accelerometerStopping||accelerometerAttempts>=3||Time.unscaledTime<nextAccelerometerRetry)return;
            StartAccelerometerAttempt();
        }
        bool NeedsAccelerometer()=>HandlesPointer&&game&&game.Shake&&
            KeepAccelerometer(game.Playing,game.TransitioningToChallenge,game.Paused,game.AppVisible);
        bool CurrentAccelerometerAttempt(int generation)=>this&&accelerometer&&accelerometerWanted&&
            generation==accelerometerGeneration&&NeedsAccelerometer();
        void StartAccelerometerAttempt()
        {
            int generation=++accelerometerGeneration;accelerometer=true;accelerometerAttempts++;
            game.Shake.ResetSensor();game.Shake.SensorAvailable=false;
            int attempt=game.ShakeDiagnostics.Begin();
            // Keep the exact delegate registered by this attempt. Generation and
            // lifecycle checks also reject callbacks already queued before Off.
            accelerometerHandler=evt=>
            {if(CurrentAccelerometerAttempt(generation))Acceleration(evt);};
            WX.OnAccelerometerChange(accelerometerHandler);
            WX.StartAccelerometer(new StartAccelerometerOption{interval="ui",
                success=r=>
                {
                    if(!CurrentAccelerometerAttempt(generation))return;
                    if(game.ShakeDiagnostics.StartResult(attempt,true,r.errMsg))game.Shake.SensorAvailable=true;
                },
                fail=r=>
                {
                    if(!CurrentAccelerometerAttempt(generation))return;
                    game.ShakeDiagnostics.StartResult(attempt,false,r.errMsg);
                    ReleaseAccelerometerAttempt();
                    nextAccelerometerRetry=Time.unscaledTime+(accelerometerAttempts==1?.5f:1f);
                    game.ShakeDiagnostics.Stop(accelerometerAttempts<3?"启动失败，等待重试":"启动失败，暂停后可重试");
                    Debug.LogWarning("[GooseShake] sensor unavailable ("+accelerometerAttempts+"/3): "+r.errMsg);
                    // Start failed: remove its listener, but do not queue an old
                    // asynchronous Stop which could stop the next retry.
                }});
        }
        void ReleaseAccelerometerAttempt()
        {
            accelerometerGeneration++;
            if(accelerometerHandler!=null)WX.OffAccelerometerChange(accelerometerHandler);
            accelerometerHandler=null;accelerometer=false;
            if(game&&game.Shake){game.Shake.SensorAvailable=false;game.Shake.ResetSensor();}
        }
        void StopAccelerometerListener(string reason)
        {
            bool hadAttempt=accelerometerWanted||accelerometer||accelerometerHandler!=null;
            // Invalidate callbacks and retries before requesting the platform stop.
            ReleaseAccelerometerAttempt();accelerometerWanted=false;accelerometerAttempts=0;nextAccelerometerRetry=0;
            if(game&&game.ShakeDiagnostics)game.ShakeDiagnostics.Stop(reason);
            if(hadAttempt&&!accelerometerStopping)
            {
                int stopGeneration=++accelerometerStopGeneration;
                accelerometerStopping=true;
                WX.StopAccelerometer(new StopAccelerometerOption{
                    success=r=>Debug.Log("[GooseShakeTest] stop_success "+r.errMsg),
                    fail=r=>Debug.LogWarning("[GooseShakeTest] stop_failed "+r.errMsg),
                    complete=r=>{if(stopGeneration==accelerometerStopGeneration)accelerometerStopping=false;}});
            }
        }
        void Hidden(GeneralCallbackResult evt)
        {
            game.SetAppVisible(false);
            game.CancelPointer(); touches.Clear(); PlayerPrefs.Save();
            game.Shake.ResetSensor();
            StopAccelerometerListener("已切到后台");
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
                WX.OffShow(Shown);StopAccelerometerListener("监听已销毁");
                WX.OffWindowResize(WindowResized);
            }
            HandlesPointer = false;
        }
#else
        public void Initialize(GooseGame owner) { }
#endif
        // Keep one stream across the tutorial win and challenge preparation.
        // Sample() separately rejects input until the new pile is interactive.
        public static bool KeepAccelerometer(bool playing,bool transitioning,bool paused,bool appVisible)
            =>(playing||transitioning)&&!paused&&appVisible;
    }
}
