using System;
using UnityEngine;

namespace CatchGoose
{
    public sealed partial class GooseGame
    {
        public GooseRewardPolicy RewardPolicy { get; private set; }
        public GooseRewardRound Rewards { get; private set; }
        public GooseSaleTruck SaleTruck { get; private set; }
        public bool AppVisible { get; private set; } = true;
        public int NextRewardClip { get; private set; }
        System.Random rewardRandom;

        void InitializeRewards()
        {
            var json = Resources.Load<TextAsset>("Data/video-rewards");
            if (!json) throw new InvalidOperationException("Missing video reward policy");
            RewardPolicy = JsonUtility.FromJson<GooseRewardPolicy>(json.text); RewardPolicy.Validate();
            SaleTruck = gameObject.AddComponent<GooseSaleTruck>(); SaleTruck.Initialize(this);
        }

        void ResetRewards()
        {
            Rewards = new GooseRewardRound(RewardPolicy, generation);
            // Local entropy is isolated from both the deterministic pile and
            // UnityEngine.Random used by presentation/physics.
            rewardRandom = new System.Random(Guid.NewGuid().GetHashCode());
            SaleTruck.Hide();
        }

        void TickRewards(float delta)
        {
            bool enabled = Level.strictCatalog && Difficulty == 1 && Level.seconds > 0 && !ReferenceTrial && !DuckReviewActive;
            bool safe = !Busy && !resolving && !Presentation.Moving && !Hud.Modal;
            if (Rewards.Tick(delta, enabled, safe, RollSale))
            {
                SaleTruck.Show(Rewards.Offer);
                Debug.Log($"[GooseReward] sale offer={Rewards.Offer} elapsed={Rewards.Elapsed:F2}");
            }
        }

        double RollSale()
        {
#if UNITY_EDITOR || DEVELOPMENT_BUILD
            if (qaSaleRoll.HasValue) return qaSaleRoll.Value;
#endif
            return rewardRandom.NextDouble();
        }

        public void ExpireSale(int offer)
        { if (Rewards != null && Rewards.Offer == offer) Rewards.ExpireOffer(); }

        public void WatchSale()
        {
            if (!Playing || Paused || !AppVisible || Video.Active || Rewards == null || !SaleTruck.Visible
                || Busy || resolving || Presentation.Moving || (Level.seconds > 0 && TimeLeft <= 0)) return;
            WatchRoundReward(GooseRewardEntry.ToolSale);
        }

        public void RequestFailure(GooseFailureReason reason)
        {
            if (!Playing || Rewards == null || Rewards.AwaitingRevive || Video.Active) return;
            if (Rewards.Fail(reason))
            { SaleTruck.Hide(); SetPaused(true); ShowReviveDialog(); }
            else EndRound(false, FailureText(reason));
        }

        static string FailureText(GooseFailureReason reason) => reason == GooseFailureReason.Timeout ? "时间到" : "槽位已满";

        void ShowReviveDialog()
        {
            if (!Playing || Rewards == null || !Rewards.AwaitingRevive || Video.Active) return;
            SetPaused(true);
            bool full = Rewards.Failure == GooseFailureReason.TrayFull;
            string reward = Level.seconds > 0 ? "增加 " + RewardPolicy.reviveSeconds / 60 + " 分钟" : "保留不限时玩法";
            string message = "完整观看一段视频，" + (full ? "退回槽内前三件，" : "保留当前物品，") + reward + "。\n满槽与超时共享一次复活机会。";
            var panel = Hud.OpenModal(full ? "槽位已满" : "时间到了", message);
            Hud.Button(panel, "看视频复活", new Rect(70, 120, 420, 75), WatchRevive, new Color(1, .78f, .2f));
            Hud.Button(panel, "结束本局", new Rect(70, 30, 420, 70), EndFailedRound, new Color(.8f, .74f, .61f));
        }

        public void WatchRevive()
        {
            if (!Playing || !AppVisible || Video.Active || Rewards == null || !Rewards.AwaitingRevive) return;
            WatchRoundReward(GooseRewardEntry.Revive);
        }

        public void EndFailedRound()
        { if (Playing && Rewards != null && Rewards.AwaitingRevive && !Video.Active) EndRound(false, FailureText(Rewards.Failure)); }

        void WatchRoundReward(GooseRewardEntry entry)
        {
            var round = Rewards;
            var ticket = round.Begin(entry, NextRewardClip);
            if (ticket == null) return;
            Video.Watch(watched =>
            {
                // Cleanup retires a round before closing its video. Never let
                // its cancellation or late completion open a dialog on a new one.
                if (Rewards != round || ticket.Round != generation || !Playing || round.Phase == GooseRewardPhase.Finished) return;
                bool granted = round.Complete(ticket, watched);
                if (granted)
                {
                    NextRewardClip = (ticket.Clip + 1) % 2;
                    if (entry == GooseRewardEntry.ToolSale)
                    {
                        for (int i = 0; i < Props.Length; i++) Props[i] += RewardPolicy.rewardPerProp;
                        SaleTruck.Claim(); Hud.AnimateSaleReward(RewardPolicy.rewardPerProp);
                        Hud.Toast("已领取：移出、凑齐、打乱各一个"); PlaySound("prop");
                    }
                    else
                    {
                        if (round.Failure == GooseFailureReason.TrayFull)
                        {
                            var back = Tray.TakeFront(3);
                            for (int i = 0; i < back.Count; i++) ReturnItem(back[i], i);
                            Presentation.Retarget(Tray.Entries);
                        }
                        if (Level.seconds > 0) TimeLeft = round.Failure == GooseFailureReason.Timeout ? RewardPolicy.reviveSeconds
                            : Mathf.Max(0, TimeLeft) + RewardPolicy.reviveSeconds;
                        fullTrayPending = false; Busy = false; LastResult = "";
                        Resume(); Hud.Toast(Level.seconds > 0 ? "复活成功 · 增加 5 分钟" : "复活成功 · 继续抓鸭");
                    }
                    Debug.Log($"[GooseReward] granted entry={entry} clip={ticket.Clip} request={ticket.Request} round={ticket.Round}");
                }
                else if (entry == GooseRewardEntry.Revive) ShowReviveDialog();
                Hud.Refresh();
            }, ticket.Clip);
        }

        public void SetAppVisible(bool visible)
        {
            if (!visible) CancelPointer();
            AppVisible = visible;
            if (visible) return;
            if (Video && Video.Active) Video.Close();
            if (Playing && !Paused) Pause();
        }
        void OnApplicationPause(bool paused) { SetAppVisible(!paused); }

#if UNITY_EDITOR || DEVELOPMENT_BUILD
        double? qaSaleRoll;
        public void QaSetSaleRoll(double? value) { qaSaleRoll = value; }
        public void QaAdvanceRewardTime(float delta)
        { if (Playing && !Paused && SpawnComplete && AppVisible && (Level.seconds == 0 || TimeLeft > 0)) TickRewards(delta); }
#endif
    }
}
