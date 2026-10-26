using System;
using System.Collections;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    [RequireComponent(typeof(Animation))]
    public sealed class GooseDuckMascot:MonoBehaviour
    {
        public AnimationClip idle,greet,click;
        Animation player;Coroutine reaction;bool frozen;
        public string CurrentAction {get;private set;}="duck_idle";
        public int ClickCount {get;private set;}
        public SkinnedMeshRenderer Skin {get;private set;}
        void Awake()
        {
            player=GetComponent<Animation>();Skin=GetComponentInChildren<SkinnedMeshRenderer>();
            if(!idle||!greet||!click||!Skin)throw new InvalidOperationException("Duck mascot needs a skin and all three approved clips");
            foreach(var clip in new[]{idle,greet,click})player.AddClip(clip,clip.name);
            player[idle.name].wrapMode=WrapMode.Loop;player[greet.name].wrapMode=player[click.name].wrapMode=WrapMode.Once;
            player.playAutomatically=false;player.cullingType=AnimationCullingType.AlwaysAnimate;Skin.updateWhenOffscreen=true;
        }
        void OnEnable(){Greet();}
        void OnDisable(){if(reaction!=null)StopCoroutine(reaction);reaction=null;if(player)player.Stop();}
        public void Greet(){PlayReaction(greet,"duck_greet");}
        public void React(){ClickCount++;PlayReaction(click,"duck_click");}
        void PlayReaction(AnimationClip clip,string label)
        {
            if(!player||!isActiveAndEnabled)return;
            if(reaction!=null)StopCoroutine(reaction);
            player.Stop();player[clip.name].time=0;player[clip.name].speed=frozen?0:1;
            player.Play(clip.name);player.Sample();CurrentAction=label;
            reaction=StartCoroutine(ReturnToIdle(clip.length));
        }
        IEnumerator ReturnToIdle(float length)
        {
            float elapsed=0;
            while(elapsed<length){if(!frozen)elapsed+=Time.deltaTime;yield return null;}
            player.Stop();player[idle.name].time=0;player[idle.name].speed=frozen?0:1;player.Play(idle.name);
            CurrentAction="duck_idle";reaction=null;
        }
        public void Freeze(bool value)
        {
            if(frozen==value)return;frozen=value;
            foreach(AnimationState state in player)state.speed=value?0:1;
        }
    }
}
