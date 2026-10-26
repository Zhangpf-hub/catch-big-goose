using System.Collections;
using UnityEngine;

namespace CatchGoose
{
    // A dedicated UI-space source keeps small object impacts audible above music.
    public sealed class GooseShakeAudio : MonoBehaviour
    {
        GooseGame game;VideoBgm music;AudioSource source;AudioClip clip;Coroutine sequence;
        public int BurstsPlayed { get; private set; }
        public AudioSource Source => source;
        public void Initialize(GooseGame owner,VideoBgm bgm)
        {
            game=owner;music=bgm;clip=Resources.Load<AudioClip>("Audio/shake");
            source=gameObject.AddComponent<AudioSource>();source.playOnAwake=false;
            source.spatialBlend=0;source.priority=32;source.volume=1;
        }
        public void Play()
        {
            if(!clip||!GooseSave.Sound)return;
            if(sequence!=null)StopCoroutine(sequence);
            source.Stop();music?.Duck(.4f,1.05f);sequence=StartCoroutine(Rattle());
        }
        IEnumerator Rattle()
        {
            float[] delays={0,.16f,.20f,.22f};float[] gains={.90f,.76f,.64f,.48f};
            for(int i=0;i<gains.Length;i++)
            {
                if(delays[i]>0)yield return new WaitForSeconds(delays[i]);
                if(!game.Playing||game.Paused||!GooseSave.Sound)break;
                source.pitch=i%2==0?1.02f:.94f;source.PlayOneShot(clip,gains[i]);BurstsPlayed++;
            }
            sequence=null;
        }
        void Update()
        {
            if(game&&(!game.Playing||game.Paused||!GooseSave.Sound))
            {if(sequence!=null){StopCoroutine(sequence);sequence=null;}if(source.isPlaying)source.Stop();}
        }
    }
}
