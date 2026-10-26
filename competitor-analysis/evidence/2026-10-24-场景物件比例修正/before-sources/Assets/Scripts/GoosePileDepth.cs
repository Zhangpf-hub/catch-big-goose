using System.Collections.Generic;
using UnityEngine;

namespace CatchGoose
{
    /// <summary>Confirmed depth threshold and kinematic transition, with project-specific
    /// settling, occlusion guards and disturbance recovery. See 竞品分析/05-Unity接入.md.</summary>
    public sealed class GoosePileDepth : MonoBehaviour
    {
        GooseGame game;
        PileAlgorithmSettings settings;
        float nextRefresh, settleUntil, frontier;
        bool initialized;
        readonly List<GooseItem> scratch = new List<GooseItem>(320);
        readonly List<GooseItem> heightOrder = new List<GooseItem>(320);
        public int HeldCount { get; private set; }
        public int HiddenCount { get; private set; }
        public int DynamicCount { get; private set; }
        public bool OverDynamicBudget => DynamicCount > settings.maxDynamicBodies;
        public float VisibleThreshold { get; private set; }
        public float RigidThreshold { get; private set; }

        public void Initialize(GooseGame owner, PileAlgorithmSettings profile)
        { game = owner; settings = profile; }
        public void ResetRound()
        { initialized = false; nextRefresh = 0; settleUntil = float.PositiveInfinity; HeldCount = HiddenCount = DynamicCount = 0; }
        public void SpawnFinished(bool preSettled = false)
        { initialized = false; settleUntil = preSettled ? Time.time : Time.time + settings.spawnProtection; nextRefresh = 0; }
        public void NotifyRemoval(Vector3 position, float radius)
        {
            // Re-evaluate the support column and its neighbours. Waking an entire
            // 300-body pile for each tap defeated the recovered depth optimisation.
            foreach (var item in game.Remaining)
            {
                var delta = item.transform.position-position;delta.y=0;
                if (delta.sqrMagnitude > radius*radius) continue;
                item.NextOcclusionCheck=0;
                item.ReleaseDepth(Time.time + Mathf.Min(.25f, settings.disturbanceProtection), false);
            }
            nextRefresh = 0;
        }
        public void DisturbAll()
        {
            foreach (var item in game.Remaining) item.ReleaseDepth(Time.time + settings.disturbanceProtection, true);
            initialized = false; settleUntil = Time.time + settings.disturbanceProtection; nextRefresh = 0;
        }
        void FixedUpdate()
        {
            if (!game || !game.Playing || game.Paused || !game.SpawnComplete || Time.time < nextRefresh) return;
            nextRefresh = Time.time + settings.refreshInterval;
            RefreshNow();
        }
        public void RefreshNow()
        {
            if (!game || !game.Playing || game.Paused || !game.SpawnComplete) return;
            var items = scratch; items.Clear();
            foreach (var item in game.Items) if (item && !item.Picked && item.gameObject.activeInHierarchy) items.Add(item);
            HeldCount = HiddenCount = DynamicCount = 0;
            if (items.Count == 0) return;
            if (!settings.depthManagement)
            { foreach (var i in items) i.ReleaseDepth(Time.time, true); DynamicCount = items.Count; return; }
            float top = float.NegativeInfinity;
            foreach(var item in items) top = Mathf.Max(top,item.transform.position.y);
            if (Time.time < settleUntil) { DynamicCount = items.Count; return; }
            frontier = initialized ? PileDepthPolicy.Descend(frontier, top, settings.frontierStep) : top;
            initialized = true;
            VisibleThreshold = PileDepthPolicy.Threshold(frontier, settings.referenceHeight,
                settings.visibleDepthMin, settings.visibleDepthMax, 1);
            RigidThreshold = PileDepthPolicy.Threshold(frontier, settings.referenceHeight,
                settings.visibleDepthMin, settings.visibleDepthMax, settings.rigidDepthMultiplier);
            // A soft budget influences the height frontier. Moving/protected
            // objects still pass the safety guards; they are never forcibly frozen.
            if (items.Count > settings.maxDynamicBodies)
            {
                heightOrder.Clear();heightOrder.AddRange(items);
                heightOrder.Sort((a,b)=>b.transform.position.y.CompareTo(a.transform.position.y));
                RigidThreshold=Mathf.Max(RigidThreshold,heightOrder[settings.maxDynamicBodies-1].transform.position.y);
            }
            bool sleeping=true;
            foreach (var item in items)
            {
                float y = item.transform.position.y;
                float speed = item.Body.isKinematic ? 0 : item.Body.velocity.magnitude;
                float angular = item.Body.isKinematic ? 0 : item.Body.angularVelocity.magnitude;
                if (speed > settings.speedGuard || angular > settings.angularSpeedGuard) item.DepthStillSince = Time.time;
                bool held = PileDepthPolicy.ShouldFreeze(y, RigidThreshold, item.DepthHeld,
                    !item.DepthReady || Time.time < item.DepthProtectedUntil, speed, angular,
                    Time.time - item.DepthStillSince, settings);
                item.SetDepthHeld(held);
                // Source SetVisible also affects selection colliders. Our colliders must
                // retain support, so manual picking is gated independently in GooseGame.
                bool above = y >= VisibleThreshold + (item.DepthVisible ? -settings.hysteresis : settings.hysteresis);
                bool visible = !item.DepthReady || above || !CoveredFromAbove(item, top);
                item.SetDepthVisible(visible);
                if (held) HeldCount++; else DynamicCount++;
                if(!held&&!item.Body.IsSleeping())sleeping=false;
                if (!visible) HiddenCount++;
            }
            if(sleeping)nextRefresh=Time.time+Mathf.Max(settings.refreshInterval,.30f);
        }
        bool CoveredFromAbove(GooseItem item, float top)
        {
            if(Time.time<item.NextOcclusionCheck)return item.CachedCovered;
            item.NextOcclusionCheck=Time.time+.20f;
            item.CachedCovered=ProbeCovered(item,top);return item.CachedCovered;
        }
        bool ProbeCovered(GooseItem item, float top)
        {
            // Own sparse-pile guard: five support-proxy rays must all hit another item
            // before this item may disappear. A deep isolated item remains visible.
            Bounds bounds = item.SelectionCollider ? item.SelectionCollider.bounds : GooseGame.BoundsOf(item.Visual.gameObject);
            float x = bounds.extents.x * .45f, z = bounds.extents.z * .45f;
            for (int probe = 0; probe < 3; probe++)
            {
                Vector3 offset = probe == 1 ? new Vector3(x,0,z) : probe == 2 ? new Vector3(-x,0,-z) : Vector3.zero;
                Vector3 origin = bounds.center + offset; origin.y = top + 3;
                if (!Physics.Raycast(origin, Vector3.down, out var hit, top + 5, ~0, QueryTriggerInteraction.Ignore)) return false;
                var cover = hit.collider.GetComponentInParent<GooseItem>();
                if (!cover || cover == item || cover.Picked || cover.transform.position.y <= item.transform.position.y) return false;
            }
            return true;
        }
    }
}
