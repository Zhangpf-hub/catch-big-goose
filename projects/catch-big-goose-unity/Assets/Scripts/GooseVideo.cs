using System;
using System.Collections;
using System.IO;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
using System.Runtime.InteropServices;
#endif

namespace CatchGoose
{
    public sealed partial class GooseVideo : MonoBehaviour
    {
        public bool Active { get; private set; }
        public string LastOutcome { get; private set; }
        public int CompletedCount { get; private set; }
        public int CancelledCount { get; private set; }
        public int CurrentClip { get; private set; }
        public float PositionSeconds
        {
            get
            {
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
                return nativePosition;
#else
                return player && player.isPrepared ? (float)player.time : 0;
#endif
            }
        }
        GooseGame game;
        VideoPlayer player;
        RenderTexture texture;
        GameObject overlay;
        Text status;
        Action<bool> callback;
        bool wasPaused;
        float opened;
        string currentFile;
        readonly List<Camera> suspendedViews=new List<Camera>();
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
        [DllImport("__Internal")] static extern void GoosePrepareWechatVideo(int index, int requestId, string receiver);
        [Serializable] class WeChatVideoPath { public int requestId; public string path, error; }
        int mediaRequest;
#endif
        public void Initialize(GooseGame owner) { game = owner; }
        public void Watch(Action<bool> finished, int clipIndex = -1)
        {
            if (Active) return;
            Active = true; wasPaused = game.Paused; callback = finished;
            LastOutcome = "playing"; opened = Time.realtimeSinceStartup;
            game.SetPaused(true); game.Hud.CloseModal();
            suspendedViews.Clear();
            foreach(var view in FindObjectsOfType<Camera>())
                if(view.enabled&&view!=game.Hud.HudCamera&&view.name!="BackgroundCamera")
                {suspendedViews.Add(view);view.enabled=false;}
            overlay = game.Hud.Panel("VideoPlayer", game.Hud.Frame, new Rect(0, 0, 720, 1280), Color.black);
            GooseHud.Stretch(overlay.GetComponent<RectTransform>());
            status = game.Hud.Label(overlay.transform, "正在加载短片…", new Rect(30, 100, 660, 70), 27, Color.white);
            game.Hud.Button(overlay.transform, "关闭 · 不领取奖励", new Rect(180, 25, 360, 65), Close, new Color(.8f, .76f, .65f));
            string[] files = { "Darkchaser-Battletide.mp4", "Skycore-Reboot.f5800.mp4" };
            int selected = clipIndex >= 0 && clipIndex < files.Length ? clipIndex : UnityEngine.Random.Range(0, files.Length);
            CurrentClip = selected;
            currentFile = files[selected];
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
            nativeStarted=false;nativePaused=false;nativePosition=nativeDuration=0;
            // Native WeChat video stays outside Unity's decoder/texture path.
            GoosePrepareWechatVideo(selected, ++mediaRequest, gameObject.name);
#else
            var raw = new GameObject("Video", typeof(RectTransform), typeof(RawImage));
            GooseHud.Place(raw, overlay.transform, new Rect(0, 210, 720, 900));raw.transform.SetAsFirstSibling();
            var fit = raw.AddComponent<AspectRatioFitter>(); fit.aspectMode = AspectRatioFitter.AspectMode.FitInParent; fit.aspectRatio = 16f / 9;
            texture = new RenderTexture(854,480,0,RenderTextureFormat.ARGB32){name="GooseRewardVideo",useMipMap=false,autoGenerateMips=false,antiAliasing=1};
            raw.GetComponent<RawImage>().texture=texture;
            player = gameObject.AddComponent<VideoPlayer>(); player.playOnAwake = false;
            player.source = VideoSource.Url; player.renderMode = VideoRenderMode.RenderTexture; player.targetTexture = texture;
            player.waitForFirstFrame = true; player.isLooping = false; player.audioOutputMode = VideoAudioOutputMode.Direct;
            player.timeUpdateMode = VideoTimeUpdateMode.UnscaledGameTime;
            player.prepareCompleted += Prepared;
            player.loopPointReached += Completed;
            player.errorReceived += Failed;
            player.url = Path.Combine(Application.streamingAssetsPath, "Video", files[selected]).Replace('\\', '/');
            player.Prepare();
#endif
        }
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
        [UnityEngine.Scripting.Preserve]
        public void OnWeChatVideoPath(string json)
        {
            var result = JsonUtility.FromJson<WeChatVideoPath>(json);
            if (!Active || result.requestId != mediaRequest) return;
            if (!string.IsNullOrEmpty(result.error)) { NativeFailed(result.error); return; }
            GoosePlayWechatVideo(result.path,mediaRequest,gameObject.name,GooseSave.Sound?0:1);
        }
#endif
        void Prepared(VideoPlayer source)
        {
            if (!Active || source != player) return;
            if (player.audioTrackCount > 0) player.SetDirectAudioMute(0, !GooseSave.Sound);
            player.Play();
        }
        void Completed(VideoPlayer source)
        {
            if (!Active || source != player) return;
            CompletedCount++; Finish(true, "complete");
        }
        void Failed(VideoPlayer source, string error)
        { if (Active&&source==player) { Debug.LogWarning("[GooseVideo] " + error); Finish(false, "failed"); game.Hud.Toast("短片播放失败，未发放奖励"); } }
        void Update()
        {
            if (!Active) return;
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
            TickNativeVideo();
#else
            if(!player)return;
            if (!player.isPrepared && Time.realtimeSinceStartup - opened >
                15
                ) { Finish(false, "timeout"); return; }
            if (player.isPrepared && status)
                status.text = $"完整观看后领取奖励  {Mathf.CeilToInt((float)player.time)}/{Mathf.CeilToInt((float)player.length)} 秒";
#endif
        }
        void Finish(bool completed, string outcome,bool restore=true)
        {
            if (!Active) return;
            Active = false; LastOutcome = outcome;
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
            int retired=mediaRequest++;GooseStopWechatVideo(retired);
#endif
            Debug.Log($"[GooseVideo] {currentFile}: {outcome}, completed={CompletedCount}, cancelled={CancelledCount}");
            if (player)
            {
                player.prepareCompleted -= Prepared; player.loopPointReached -= Completed; player.errorReceived -= Failed;
                player.targetTexture=null;player.Stop(); Destroy(player); player = null;
            }
            if (overlay) { overlay.SetActive(false); Destroy(overlay);overlay=null; }
            // Destroy is deferred to the end of the frame. Do not release a
            // decoder's RenderTexture synchronously from its own ended callback.
            if (texture) { Destroy(texture); texture = null; }
            if(restore&&game)
            {foreach(var view in suspendedViews)if(view)view.enabled=true;game.SetPaused(wasPaused);}
            suspendedViews.Clear();
            var done = callback; callback = null; done?.Invoke(completed);
        }
        public void Close()
        { if (Active) { CancelledCount++; Finish(false, "cancelled"); } }
        void OnDestroy() { callback = null; if (Active) Finish(false, "disposed",false); }
    }

    public sealed class VideoBgm : MonoBehaviour
    {
        AudioSource source;
        bool requested;
        float duckUntil,duckGain=1;
        public void Duck(float gain,float seconds){duckGain=Mathf.Clamp01(gain);duckUntil=Time.unscaledTime+seconds;}
        public void SetState(bool playing)
        {
            if (!source)
            {
                source = gameObject.AddComponent<AudioSource>(); source.loop = true; source.volume = 0;
                source.spatialBlend=0;source.priority=128;
                source.playOnAwake = false; source.clip = Resources.Load<AudioClip>("Audio/bgm");
            }
            requested=playing;
            if (playing && source.clip) { if (!source.isPlaying) { if (source.time > 0) source.UnPause(); else source.Play(); } }
        }
        void Update()
        {
            if(!source)return;
            float gain=Time.unscaledTime<duckUntil?duckGain:1;
            source.volume=Mathf.MoveTowards(source.volume,requested?.28f*gain:0,Time.unscaledDeltaTime*2.8f);
            if(!requested&&source.isPlaying&&source.volume<=.001f)source.Pause();
        }
    }
}
