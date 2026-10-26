using NUnit.Framework;
using UnityEngine;

namespace CatchGoose.Tests
{
    public class GooseCandyMotionTests
    {
        [Test] public void PressSpringHasTheSameResponseAcrossFrameRatesAndUnevenFrames()
        {
            foreach(float target in new[]{0,-.095f})
            {
                float expected=.03f,expectedSpeed=-1.8f;
                GooseCandyMotion.AdvanceSpring(ref expected,ref expectedSpeed,target,1);
                foreach(int fps in new[]{30,60,120})
                {
                    float value=.03f,speed=-1.8f;
                    for(int i=0;i<fps;i++)GooseCandyMotion.AdvanceSpring(ref value,ref speed,target,1f/fps);
                    Assert.AreEqual(expected,value,.00001f,"position at "+fps);
                    Assert.AreEqual(expectedSpeed,speed,.00001f,"velocity at "+fps);
                }
                float uneven=.03f,unevenSpeed=-1.8f;
                foreach(float dt in new[]{.01f,.19f,.03f,.27f,.5f})GooseCandyMotion.AdvanceSpring(ref uneven,ref unevenSpeed,target,dt);
                Assert.AreEqual(expected,uneven,.00001f);
                Assert.AreEqual(expectedSpeed,unevenSpeed,.00001f);
            }
        }
        [Test] public void IdleHopStartsAndLandsWithoutVelocityOrSquashJumps()
        {
            const float dt=.0001f;
            Assert.AreEqual(Vector2.zero,GooseCandyMotion.IdleHop(0,9));
            Assert.AreEqual(Vector2.zero,GooseCandyMotion.IdleHop(GooseCandyMotion.HopDuration,9));
            Assert.Less(GooseCandyMotion.IdleHop(dt,9).magnitude/dt,.03f);
            Assert.Less(GooseCandyMotion.IdleHop(GooseCandyMotion.HopDuration-dt,9).magnitude/dt,.03f);
            Assert.AreEqual(9,GooseCandyMotion.IdleHop(GooseCandyMotion.HopDuration*.5f,9).x,.0001f);
            Assert.AreEqual(Vector2.zero,GooseCandyMotion.IdleHop(.3f,0),"No hop also means no periodic squash");
            Assert.AreEqual(Vector2.zero,GooseCandyMotion.IdleHop(4.2f,9));
        }
    }
}
