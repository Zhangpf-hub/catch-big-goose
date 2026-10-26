#if UNITY_WEBGL && GOOSE_WECHAT && !UNITY_EDITOR
using System;
using System.Runtime.InteropServices;
using UnityEngine;
namespace CatchGoose
{
    public sealed partial class GooseVideo
    {
        [DllImport("__Internal")]static extern void GoosePlayWechatVideo(string path,int requestId,string receiver,int muted);
        [DllImport("__Internal")]static extern void GooseStopWechatVideo(int requestId);
        [Serializable]sealed class NativeVideoEvent{public int requestId;public string type,error;public float position,duration;}
        bool nativeStarted,nativePaused;
        float nativePosition,nativeDuration,lastNativeProgress;
        [UnityEngine.Scripting.Preserve]
        public void OnWeChatVideoEvent(string json)
        {
            if(!Active)return;
            NativeVideoEvent evt;
            try{evt=JsonUtility.FromJson<NativeVideoEvent>(json);}catch(Exception e){NativeFailed("Invalid native video reply: "+e.Message);return;}
            if(evt==null||evt.requestId!=mediaRequest)return;
            if(evt.type=="error"){NativeFailed(evt.error);return;}
            if(evt.type=="play"){nativeStarted=true;nativePaused=false;lastNativeProgress=Time.realtimeSinceStartup;}
            else if(evt.type=="pause")nativePaused=true;
            else if(evt.type=="time")
            {
                if(evt.position>nativePosition+.01f)lastNativeProgress=Time.realtimeSinceStartup;
                nativePosition=Mathf.Max(nativePosition,evt.position);nativeDuration=evt.duration;
            }
            else if(evt.type=="ended")
            {
                nativePosition=Mathf.Max(nativePosition,evt.position);if(evt.duration>0)nativeDuration=evt.duration;
                if(!nativeStarted||nativeDuration<=0||nativePosition<nativeDuration-1)
                {NativeFailed("Native video ended without complete playback");return;}
                CompletedCount++;Finish(true,"complete");
            }
        }
        void NativeFailed(string error)
        {if(!Active)return;Debug.LogWarning("[GooseVideo] native video: "+error);Finish(false,"failed");game.Hud.Toast("短片暂时无法播放，请重试");}
        void TickNativeVideo()
        {
            if(!nativeStarted&&Time.realtimeSinceStartup-opened>45){NativeFailed("Native video loading timed out");return;}
            if(nativeStarted&&!nativePaused&&Time.realtimeSinceStartup-lastNativeProgress>30){NativeFailed("Native video stopped responding");return;}
            if(status&&nativeDuration>0)status.text=$"完整观看后领取奖励  {Mathf.CeilToInt(nativePosition)}/{Mathf.CeilToInt(nativeDuration)} 秒";
        }
    }
}
#endif
