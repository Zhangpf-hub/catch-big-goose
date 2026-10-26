using System;

namespace CatchGoose
{
    public enum GooseRewardEntry { None, ToolSale, Revive }
    public enum GooseFailureReason { None, TrayFull, Timeout }
    public enum GooseRewardPhase { Ready, WatchingSale, AwaitingRevive, WatchingRevive, Finished }

    [Serializable]
    public sealed class GooseRewardPolicy
    {
        public int version;
        public int[] saleSeconds;
        public float[] saleProbabilities;
        public float driveSeconds, stopSeconds;
        public int rewardPerProp, reviveSeconds;

        public void Validate()
        {
            if (saleSeconds == null || saleProbabilities == null || saleSeconds.Length != saleProbabilities.Length
                || driveSeconds <= 0 || stopSeconds < 0 || rewardPerProp <= 0 || reviveSeconds <= 0)
                throw new InvalidOperationException("Invalid video reward policy");
            for (int i = 0; i < saleSeconds.Length; i++)
                if (saleSeconds[i] <= 0 || (i > 0 && saleSeconds[i] <= saleSeconds[i - 1])
                    || float.IsNaN(saleProbabilities[i]) || saleProbabilities[i] < 0 || saleProbabilities[i] > 1)
                    throw new InvalidOperationException("Invalid sale checkpoint");
        }
    }

    // A request belongs to one round object and one playback. Retired callbacks
    // cannot mutate a new round, and a completed ticket cannot be replayed.
    public sealed class GooseRewardTicket
    {
        internal GooseRewardRound Owner;
        public int Round { get; internal set; }
        public int Request { get; internal set; }
        public int Clip { get; internal set; }
        public GooseRewardEntry Entry { get; internal set; }
    }

    public sealed class GooseRewardRound
    {
        readonly GooseRewardPolicy policy;
        readonly int round;
        readonly bool[] checkedPoints;
        int request, offerSequence;
        GooseRewardTicket active;
        public GooseRewardPhase Phase { get; private set; } = GooseRewardPhase.Ready;
        public GooseFailureReason Failure { get; private set; }
        public bool Revived { get; private set; }
        public float Elapsed { get; private set; }
        public int Offer { get; private set; }
        public int CheckCount { get; private set; }
        public int ClaimedSales { get; private set; }
        public bool AwaitingRevive => Phase == GooseRewardPhase.AwaitingRevive || Phase == GooseRewardPhase.WatchingRevive;

        public GooseRewardRound(GooseRewardPolicy rules, int serial)
        { rules.Validate(); policy = rules; round = serial; checkedPoints = new bool[rules.saleSeconds.Length]; }

        public bool Tick(float delta, bool saleEnabled, bool canPresent, Func<double> roll)
        {
            if (Phase != GooseRewardPhase.Ready) return false;
            Elapsed += Math.Max(0, delta);
            if (!saleEnabled || !canPresent) return false;
            bool offered = false;
            for (int i = 0; i < checkedPoints.Length; i++)
            {
                if (checkedPoints[i] || Elapsed < policy.saleSeconds[i]) continue;
                checkedPoints[i] = true; CheckCount++;
                // Even on a long frame each checkpoint is consumed once. Never
                // stack trucks or create an extra offer behind an existing one.
                double chance = roll();
                if (Offer == 0 && chance < policy.saleProbabilities[i])
                { Offer = ++offerSequence; offered = true; }
            }
            return offered;
        }

        public void ExpireOffer() { if (Phase == GooseRewardPhase.Ready) Offer = 0; }

        public bool Fail(GooseFailureReason reason)
        {
            if (reason == GooseFailureReason.None || Phase != GooseRewardPhase.Ready) return false;
            Offer = 0; Failure = reason;
            if (Revived) return false;
            Phase = GooseRewardPhase.AwaitingRevive; return true;
        }

        public GooseRewardTicket Begin(GooseRewardEntry entry, int clip)
        {
            bool allowed = entry == GooseRewardEntry.ToolSale ? Phase == GooseRewardPhase.Ready && Offer > 0
                : entry == GooseRewardEntry.Revive && Phase == GooseRewardPhase.AwaitingRevive && !Revived;
            if (!allowed) return null;
            active = new GooseRewardTicket { Owner = this, Round = round, Request = ++request, Entry = entry, Clip = clip };
            Phase = entry == GooseRewardEntry.ToolSale ? GooseRewardPhase.WatchingSale : GooseRewardPhase.WatchingRevive;
            return active;
        }

        public bool Complete(GooseRewardTicket ticket, bool watched)
        {
            if (ticket == null || ticket.Owner != this || active != ticket || Phase == GooseRewardPhase.Finished) return false;
            active = null;
            Phase = ticket.Entry == GooseRewardEntry.ToolSale ? GooseRewardPhase.Ready : GooseRewardPhase.AwaitingRevive;
            if (!watched) return false;
            if (ticket.Entry == GooseRewardEntry.ToolSale) { Offer = 0; ClaimedSales++; }
            else { Revived = true; Phase = GooseRewardPhase.Ready; }
            return true;
        }

        public void Finish() { active = null; Offer = 0; Phase = GooseRewardPhase.Finished; }
    }
}
