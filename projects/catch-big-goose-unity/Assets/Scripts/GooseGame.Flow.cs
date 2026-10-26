using System.Collections;
using UnityEngine;

namespace CatchGoose
{
    public sealed partial class GooseGame
    {
        public const string FlowAudioVersion="20261025-UI4";
        bool storySequenceActive;
        public bool TransitioningToChallenge { get; private set; }

        void StartThemeSequence()
        {
            ReferenceTrial=false;Difficulty=0;storySequenceActive=true;
            TransitioningToChallenge=false;BeginRound();
        }

        IEnumerator ContinueThemeSequence(int token)
        {
            TransitioningToChallenge=true;
            Hud.Toast("热身完成，继续挑战！");
            // Give the final match a short beat, then adopt the challenge that
            // has been preparing while the warmup was being played.
            yield return new WaitForSecondsRealtime(.7f);
            if(token!=generation||!storySequenceActive)yield break;
            Difficulty=1;GooseSave.SelectStoryStage(Theme.id,1);
            TransitioningToChallenge=false;BeginRound();
        }
    }
}
