using System.Collections;
using System.Linq;
using UnityEngine;

namespace CatchGoose
{
    // Attach to the reusable home mascot prefab. A UI button or scene input can
    // call ReactToTap / Greet without knowing the imported FBX clip names.
    [RequireComponent(typeof(Animation))]
    public sealed class ShibaMascot : MonoBehaviour
    {
        Animation player;
        Coroutine reaction;
        string idle, happy, bounce;

        void Awake()
        {
            player = GetComponent<Animation>();
            idle = FindClip("Idle"); happy = FindClip("Happy"); bounce = FindClip("Bounce");
            if (idle != null) player[idle].wrapMode = WrapMode.Loop;
            if (happy != null) player[happy].wrapMode = WrapMode.Once;
            if (bounce != null) player[bounce].wrapMode = WrapMode.Once;
        }

        string FindClip(string suffix) => player.Cast<AnimationState>()
            .FirstOrDefault(s => s.name == suffix || s.name.EndsWith("|" + suffix))?.name;

        void OnEnable() { if (idle != null) player.Play(idle); }
        void OnDisable() { if (reaction != null) StopCoroutine(reaction); reaction = null; }
        public void ReactToTap() => React(bounce);
        public void Greet() => React(happy);

        void React(string clip)
        {
            if (!isActiveAndEnabled || clip == null) return;
            if (reaction != null) StopCoroutine(reaction);
            reaction = StartCoroutine(PlayReaction(clip));
        }

        IEnumerator PlayReaction(string clip)
        {
            player[clip].time = 0;
            player.CrossFade(clip, .09f);
            yield return new WaitForSeconds(Mathf.Max(.1f, player[clip].length - .09f));
            if (idle != null) player.CrossFade(idle, .12f);
            reaction = null;
        }
    }
}
