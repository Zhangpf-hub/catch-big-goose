using System;

namespace CatchGoose
{
    [Serializable]
    public sealed class PileAlgorithmSettings
    {
        public int schemaVersion = 1;
        public bool weightedGeneration = true, depthManagement = true;
        // Project tuning. Competitor constructor defaults are 4/6/20 and 0.75,
        // but serialized overrides and cross-project world scale are not confirmed.
        public float visibleDepthMin = .4f, visibleDepthMax = .6f, referenceHeight = 2;
        public float rigidDepthMultiplier = .75f, frontierStep = .1f, refreshInterval = .1f;
        public float speedGuard = .2f, angularSpeedGuard = .6f, settledDuration = .35f;
        public float hysteresis = .06f, spawnProtection = .8f, disturbanceProtection = .8f;
        public float positionEdgeWeight = .4f;
        public int maxDynamicBodies = 80;
        public void Validate()
        {
            foreach (float f in new[] { visibleDepthMin, visibleDepthMax, referenceHeight, rigidDepthMultiplier, frontierStep,
                refreshInterval, speedGuard, angularSpeedGuard, settledDuration, hysteresis, spawnProtection, disturbanceProtection, positionEdgeWeight })
                if (!AlgorithmMath.Finite(f) || f < 0) throw new ArgumentException("Invalid pile algorithm setting");
            if (schemaVersion != 1 || referenceHeight <= 0 || visibleDepthMax < visibleDepthMin || refreshInterval <= 0
                || rigidDepthMultiplier > 1 || maxDynamicBodies < 1 || frontierStep <= 0 || positionEdgeWeight > 1)
                throw new ArgumentException("Invalid pile algorithm profile");
        }
    }

    public static class PileDepthPolicy
    {
        // Confirmed formula, with a safe zero-height extension for our normalized scene.
        public static float Threshold(float frontier, float referenceHeight, float depthMin, float depthMax, float multiplier)
        {
            float ratio = referenceHeight <= 1e-6f ? 0 : (referenceHeight - frontier) / referenceHeight;
            ratio = Math.Max(0, Math.Min(1, ratio));
            return frontier - (depthMin + (depthMax - depthMin) * ratio) * Math.Min(multiplier, 1);
        }

        // Confirmed SetMinTouchHeight: descend by at most _maxOnceTouchHeight per pass.
        public static float Descend(float previous, float highestRemaining, float step)
            => highestRemaining < previous ? Math.Max(previous - step, highestRemaining) : previous;

        public static bool ShouldFreeze(float y, float threshold, bool currentlyFrozen, bool protectedState,
            float speed, float angularSpeed, float stillFor, PileAlgorithmSettings settings)
        {
            if (protectedState) return false;
            if (currentlyFrozen) return y < threshold + settings.hysteresis;
            return y < threshold - settings.hysteresis && speed <= settings.speedGuard
                && angularSpeed <= settings.angularSpeedGuard && stillFor >= settings.settledDuration;
        }
    }
}
