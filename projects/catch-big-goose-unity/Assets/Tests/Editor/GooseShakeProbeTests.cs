using NUnit.Framework;
using UnityEngine;
namespace CatchGoose.Tests
{
    public sealed class GooseShakeProbeTests
    {
        [Test] public void LateStartResultCannotOverrideNewListener()
        {
            var probe=new GooseShakeProbeState();int first=probe.Begin(0);probe.Stop("paused");
            int second=probe.Begin(2);
            Assert.IsFalse(probe.Result(first,true,"old result"));
            Assert.IsFalse(probe.Started);Assert.IsTrue(probe.Result(second,false,"privacy failure"));
            Assert.AreEqual("privacy failure",probe.Error);
        }
        [Test] public void PauseIgnoresLateResultsAndSamples()
        {
            var probe=new GooseShakeProbeState();int id=probe.Begin(0);probe.Stop("paused");
            Assert.IsFalse(probe.Result(id,true,""));Assert.IsFalse(probe.Callback(Vector3.one,1));
            Assert.AreEqual(0,probe.TotalCallbacks);Assert.AreEqual("paused",probe.Status);
        }
        [Test] public void NewListenerResetsStreamButKeepsSessionCounters()
        {
            var probe=new GooseShakeProbeState();int id=probe.Begin(0);probe.Result(id,true,"");
            probe.Callback(new Vector3(.2f,.3f,.9f),1);probe.MotionPeak=2;
            probe.SensorAccepted=1;probe.ManualAccepted=2;probe.Applied=3;
            probe.Stop("paused");probe.Begin(2);
            Assert.AreEqual(0,probe.StreamCallbacks);Assert.AreEqual(1,probe.TotalCallbacks);
            Assert.AreEqual(0,probe.MotionPeak);Assert.AreEqual(-1,probe.LastCallbackTime);
            Assert.AreEqual(1,probe.SensorAccepted);Assert.AreEqual(2,probe.ManualAccepted);Assert.AreEqual(3,probe.Applied);
        }
    }
}
