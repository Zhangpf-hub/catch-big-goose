using System;
using UnityEngine;
namespace CatchGoose
{
    // Short UI-space calls share the MUSIC2 palette. A fixed voice pool keeps
    // fast selections responsive without an unbounded pile of OneShot voices.
    public sealed class GooseDuckAudio : MonoBehaviour
    {
        public const int VoiceLimit=3;
        readonly AudioClip[] clips=new AudioClip[3];
        readonly AudioSource[] voices=new AudioSource[VoiceLimit];
        GooseGame game;int nextClip,nextVoice;
        public int PlayedCount {get;private set;}
        public string LastClipName {get;private set;}
        public int ActiveVoices {get {int count=0;foreach(var voice in voices)if(voice&&voice.isPlaying)count++;return count;}}
        public static bool IsDuckItem(string id)=>id=="duck"||id=="goose"||
            (id!=null&&(id.StartsWith("duck-",StringComparison.Ordinal)||id.StartsWith("ref_goose_",StringComparison.Ordinal)));
        public void Initialize(GooseGame owner)
        {
            game=owner;
            for(int i=0;i<clips.Length;i++)
            {
                clips[i]=Resources.Load<AudioClip>("Audio/duck-quack-"+(i+1));
                if(!clips[i])throw new InvalidOperationException("Missing duck quack "+(i+1));
                clips[i].LoadAudioData();
            }
            for(int i=0;i<voices.Length;i++)
            {
                var voice=gameObject.AddComponent<AudioSource>();voices[i]=voice;
                voice.playOnAwake=false;voice.loop=false;voice.spatialBlend=0;voice.dopplerLevel=0;
                voice.priority=56;voice.volume=.5f;
            }
        }
        public bool Play()
        {
            if(!game||!GooseSave.Sound||game.Paused||(game.Video&&game.Video.Active))return false;
            var clip=clips[nextClip];nextClip=(nextClip+1)%clips.Length;
            var voice=voices[nextVoice];nextVoice=(nextVoice+1)%voices.Length;
            voice.Stop();voice.clip=clip;voice.Play();PlayedCount++;LastClipName=clip.name;return true;
        }
        public void Stop(){foreach(var voice in voices)if(voice)voice.Stop();}
        void Update(){if(!GooseSave.Sound||(game&&(game.Paused||(game.Video&&game.Video.Active))))Stop();}
        void OnDisable(){Stop();}
        void OnApplicationPause(bool paused){if(paused)Stop();}
    }
}
