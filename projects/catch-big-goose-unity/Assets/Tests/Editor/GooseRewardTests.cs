using NUnit.Framework;
using UnityEngine;

namespace CatchGoose.Tests
{
    public sealed class GooseRewardTests
    {
        GooseRewardPolicy Policy => JsonUtility.FromJson<GooseRewardPolicy>(Resources.Load<TextAsset>("Data/video-rewards").text);
        [Test] public void FrozenCompetitorTimingAndOwnRewardAmountsAreExplicit()
        {
            var p = Policy; p.Validate();
            CollectionAssert.AreEqual(new[] { 120, 300, 480 }, p.saleSeconds);
            CollectionAssert.AreEqual(new[] { .8f, .5f, .5f }, p.saleProbabilities);
            Assert.AreEqual(300, p.reviveSeconds); Assert.AreEqual(1, p.rewardPerProp);
            Assert.AreEqual(6, p.driveSeconds); Assert.AreEqual(2.5, p.stopSeconds);
        }
        [Test] public void CheckpointIsDrawnOnlyOnceAndRefillDoesNotAlterLaterChecks()
        {
            var r = new GooseRewardRound(Policy, 7); int draws = 0;
            System.Func<double> roll = () => { draws++; return .1; };
            Assert.IsFalse(r.Tick(119.99f, true, true, roll)); Assert.AreEqual(0, draws);
            Assert.IsTrue(r.Tick(.02f, true, true, roll)); Assert.AreEqual(1, draws);
            var t = r.Begin(GooseRewardEntry.ToolSale, 0);
            Assert.IsTrue(r.Complete(t, true));
            Assert.IsFalse(r.Tick(0, true, true, roll)); Assert.AreEqual(1, draws);
            Assert.IsTrue(r.Tick(180, true, true, roll)); Assert.AreEqual(2, draws);
            r.ExpireOffer(); Assert.IsTrue(r.Tick(180, true, true, roll)); Assert.AreEqual(3, draws);
        }
        [TestCase(.79, true)] [TestCase(.81, false)]
        public void MissedProbabilityDoesNotRetryOnFollowingFrames(double chance, bool expected)
        {
            var r = new GooseRewardRound(Policy, 1);
            Assert.AreEqual(expected, r.Tick(120, true, true, () => chance)); r.ExpireOffer();
            Assert.IsFalse(r.Tick(1, true, true, () => 0)); Assert.AreEqual(1, r.CheckCount);
        }
        [Test] public void BusyCanDeferPresentationAndWarmupNeverOffers()
        {
            var r = new GooseRewardRound(Policy, 1);
            Assert.IsFalse(r.Tick(120, true, false, () => 0)); Assert.AreEqual(0, r.CheckCount);
            Assert.IsTrue(r.Tick(0, true, true, () => 0));
            var warmup = new GooseRewardRound(Policy, 2);
            Assert.IsFalse(warmup.Tick(600, false, true, () => 0)); Assert.AreEqual(0, warmup.CheckCount);
        }
        [Test] public void CancelAndDuplicateCallbacksNeverGrantAndCannotSkipTheRetry()
        {
            var r = new GooseRewardRound(Policy, 1); r.Tick(120, true, true, () => 0);
            var cancelled = r.Begin(GooseRewardEntry.ToolSale, 0);
            Assert.IsNull(r.Begin(GooseRewardEntry.ToolSale, 0));
            Assert.IsFalse(r.Complete(cancelled, false)); Assert.Greater(r.Offer, 0);
            var retry = r.Begin(GooseRewardEntry.ToolSale, 0);
            Assert.IsFalse(r.Complete(cancelled, true)); Assert.IsTrue(r.Complete(retry, true));
            Assert.IsFalse(r.Complete(retry, true)); Assert.AreEqual(1, r.ClaimedSales);
        }
        [TestCase(GooseFailureReason.TrayFull)] [TestCase(GooseFailureReason.Timeout)]
        public void FailuresShareOneRevivalAndCancellationPreservesIt(GooseFailureReason first)
        {
            var r = new GooseRewardRound(Policy, 2); r.Tick(120, true, true, () => 0);
            Assert.IsTrue(r.Fail(first)); Assert.AreEqual(0, r.Offer);
            var t = r.Begin(GooseRewardEntry.Revive, 0); Assert.IsFalse(r.Complete(t, false)); Assert.IsFalse(r.Revived);
            t = r.Begin(GooseRewardEntry.Revive, 0); Assert.IsTrue(r.Complete(t, true)); Assert.IsTrue(r.Revived);
            Assert.IsFalse(r.Fail(first == GooseFailureReason.TrayFull ? GooseFailureReason.Timeout : GooseFailureReason.TrayFull));
            Assert.IsNull(r.Begin(GooseRewardEntry.Revive, 1));
        }
        [Test] public void VideoAndFailureWaitDoNotAdvanceActiveTimeAndRevivalDoesNotResetCheckpoints()
        {
            var r = new GooseRewardRound(Policy, 3); r.Tick(120, true, true, () => 0);
            var sale = r.Begin(GooseRewardEntry.ToolSale, 0);
            Assert.IsFalse(r.Tick(90, true, true, () => 0)); Assert.AreEqual(120, r.Elapsed);
            r.Complete(sale, true); r.Fail(GooseFailureReason.Timeout);
            Assert.IsFalse(r.Tick(90, true, true, () => 0)); Assert.AreEqual(120, r.Elapsed);
            r.Complete(r.Begin(GooseRewardEntry.Revive, 1), true);
            Assert.IsFalse(r.Tick(0, true, true, () => 0)); Assert.AreEqual(1, r.CheckCount);
            Assert.IsTrue(r.Tick(180, true, true, () => 0));
        }
        [Test] public void CleanupAndForeignRoundCallbacksCannotAward()
        {
            var a = new GooseRewardRound(Policy, 1); a.Tick(120, true, true, () => 0);
            var ticket = a.Begin(GooseRewardEntry.ToolSale, 0); a.Finish();
            var b = new GooseRewardRound(Policy, 2); b.Tick(120, true, true, () => 0);
            var current = b.Begin(GooseRewardEntry.ToolSale, 0);
            Assert.IsFalse(a.Complete(ticket, true)); Assert.IsFalse(b.Complete(ticket, true));
            Assert.IsTrue(b.Complete(current, true)); Assert.IsFalse(a.Tick(600, true, true, () => 0));
        }
        [Test] public void TruckTravelsRightToLeftAndParksTwice()
        {
            Assert.AreEqual(930, GooseSaleTruck.PositionAt(0, 6, 2.5f));
            Assert.AreEqual(480, GooseSaleTruck.PositionAt(2, 6, 2.5f));
            Assert.AreEqual(480, GooseSaleTruck.PositionAt(4.4f, 6, 2.5f));
            Assert.AreEqual(240, GooseSaleTruck.PositionAt(6.5f, 6, 2.5f));
            Assert.AreEqual(240, GooseSaleTruck.PositionAt(8.9f, 6, 2.5f));
            Assert.AreEqual(-210, GooseSaleTruck.PositionAt(11, 6, 2.5f));
        }
    }
}
