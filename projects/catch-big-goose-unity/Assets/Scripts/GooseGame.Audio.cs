using UnityEngine;
namespace CatchGoose
{
    public sealed partial class GooseGame
    {
        GooseShakeAudio shakeAudio;
        public GooseShakeAudio ShakeAudio => shakeAudio;
        void PlayShakeAudio()
        {
            if(!shakeAudio)
            {
                var audioRoot=new GameObject("MovingObjectAudio");audioRoot.transform.SetParent(transform,false);
                shakeAudio=audioRoot.AddComponent<GooseShakeAudio>();shakeAudio.Initialize(this,bgm);
            }
            shakeAudio.Play();
        }
    }
}
