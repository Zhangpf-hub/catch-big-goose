using System;
using System.Collections;
using System.IO;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
using System.Runtime.InteropServices;
#endif

namespace CatchGoose
{
    public sealed class GooseVideo : MonoBehaviour
    {
        public bool Active { get; private set; }
        public string LastOutcome { get; private set; }
        public int CompletedCount { get; private set; }
        public int CancelledCount { get; private set; }
        GooseGame game;
        VideoPlayer player;
        RenderTexture texture;
        GameObject overlay;
        Text status;
        Action<bool> callback;
        bool wasPaused;
        float opened;
        string currentFile;
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
        [DllImport("__Internal")] static extern void GoosePrepareWechatVideo(int index, int requestId, string receiver);
        [Serializable] class WeChatVideoPath { public int requestId; public string path, error; }
        int mediaRequest;
        bool sawPlayback;
#endif
        public void Initialize(GooseGame owner) { game = owner; }
        public void Watch(Action<bool> finished, int clipIndex = -1)
        {
            if (Active) return;
            Active = true; wasPaused = game.Paused; callback = finished;
            LastOutcome = "playing"; opened = Time.realtimeSinceStartup;
            game.SetPaused(true); game.Hud.CloseModal();
            overlay = game.Hud.Panel("VideoPlayer", game.Hud.Frame, new Rect(0, 0, 720, 1280), Color.black);
            GooseHud.Stretch(overlay.GetComponent<RectTransform>());
            var raw = new GameObject("Video", typeof(RectTransform), typeof(RawImage));
            GooseHud.Place(raw, overlay.transform, new Rect(0, 210, 720, 900));
            var fit = raw.AddComponent<AspectRatioFitter>(); fit.aspectMode = AspectRatioFitter.AspectMode.FitInParent; fit.aspectRatio = 16f / 9;
            texture = new RenderTexture(1280, 720, 0); raw.GetComponent<RawImage>().texture = texture;
            status = game.Hud.Label(overlay.transform, "正在加载短片…", new Rect(30, 100, 660, 70), 27, Color.white);
            game.Hud.Button(overlay.transform, "关闭 · 不领取奖励", new Rect(180, 25, 360, 65), Close, new Color(.8f, .76f, .65f));
            player = gameObject.AddComponent<VideoPlayer>(); player.playOnAwake = false;
            player.source = VideoSource.Url; player.renderMode = VideoRenderMode.RenderTexture; player.targetTexture = texture;
            string[] files = { "Darkchaser-Battletide.mp4", "Skycore-Reboot.f5800.mp4" };
            int selected = clipIndex >= 0 && clipIndex < files.Length ? clipIndex : UnityEngine.Random.Range(0, files.Length);
            currentFile = files[selected];
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
            sawPlayback = false;
#endif
            player.waitForFirstFrame = true; player.isLooping = false; player.audioOutputMode = VideoAudioOutputMode.Direct;
            player.timeUpdateMode = VideoTimeUpdateMode.UnscaledGameTime;
            player.prepareCompleted += Prepared;
            player.loopPointReached += Completed;
            player.errorReceived += Failed;
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
            // The media subpackage is copied to the app's cache before decoding; no public CDN required.
            GoosePrepareWechatVideo(selected, ++mediaRequest, gameObject.name);
#else
            player.url = Path.Combine(Application.streamingAssetsPath, "Video", files[selected]).Replace('\\', '/');
            player.Prepare();
#endif
        }
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
        public void OnWeChatVideoPath(string json)
        {
            var result = JsonUtility.FromJson<WeChatVideoPath>(json);
            if (!Active || !player || result.requestId != mediaRequest) return;
            if (!string.IsNullOrEmpty(result.error)) { Failed(player, result.error); return; }
            player.url = result.path; player.Prepare();
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
        { if (Active) { Debug.LogWarning("[GooseVideo] " + error); Finish(false, "failed"); game.Hud.Toast("短片播放失败，未发放奖励"); } }
        void Update()
        {
            if (!Active || !player) return;
            if (!player.isPrepared && Time.realtimeSinceStartup - opened >
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
                45
#else
                15
#endif
                ) { Finish(false, "timeout"); return; }
            if (player.isPrepared && status)
                status.text = $"完整观看后领取奖励  {Mathf.CeilToInt((float)player.time)}/{Mathf.CeilToInt((float)player.length)} 秒";
#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
            // Some WeChat web-video instances omit loopPointReached when a cached clip is replayed.
            // Require actual playback followed by a stopped decoder at the final media frame.
            if (player.isPrepared)
            {
                sawPlayback |= player.isPlaying && player.time > 0;
                double lastFrame = player.frameRate > 0 ? 1.0 / player.frameRate : 1.0 / 30;
                if (sawPlayback && !player.isPlaying && player.length > 0
                    && player.time >= player.length - lastFrame - .001)
                {
                    Debug.Log("[GooseVideo] Decoder reached media end without ended callback: " + currentFile);
                    Completed(player);
                }
            }
#endif
        }
        void Finish(bool completed, string outcome)
        {
            if (!Active) return;
            Active = false; LastOutcome = outcome;
            Debug.Log($"[GooseVideo] {currentFile}: {outcome}, completed={CompletedCount}, cancelled={CancelledCount}");
            if (player)
            {
                player.prepareCompleted -= Prepared; player.loopPointReached -= Completed; player.errorReceived -= Failed;
                player.Stop(); Destroy(player); player = null;
            }
            if (overlay) { overlay.SetActive(false); Destroy(overlay); }
            if (texture) { texture.Release(); Destroy(texture); texture = null; }
            game.SetPaused(wasPaused);
            var done = callback; callback = null; done?.Invoke(completed);
        }
        public void Close()
        { if (Active) { CancelledCount++; Finish(false, "cancelled"); } }
        void OnDestroy() { callback = null; if (Active) Finish(false, "disposed"); }
    }

    public sealed class VideoBgm : MonoBehaviour
    {
        AudioSource source;
        public void SetState(bool playing)
        {
            if (!source)
            {
                source = gameObject.AddComponent<AudioSource>(); source.loop = true; source.volume = .3f;
                source.playOnAwake = false; source.clip = Resources.Load<AudioClip>("Audio/bgm");
            }
            if (playing && source.clip) { if (!source.isPlaying) { if (source.time > 0) source.UnPause(); else source.Play(); } }
            else source.Pause();
        }
    }
}
