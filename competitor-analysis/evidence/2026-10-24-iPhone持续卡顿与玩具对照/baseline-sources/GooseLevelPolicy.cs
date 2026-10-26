using System;
using System.Globalization;

namespace CatchGoose
{
    public static class LevelConfigPolicy
    {
        // Confirmed GetFeatureType: 1..100 buckets, positive integer weights,
        // inclusive cumulative boundary, uncovered buckets return no assignment.
        // The caller supplies a bucket: the competitor's account hash is unknown.
        public static int SelectFork(bool enabled, string[] keys, int[] weights, int bucket)
        {
            if (!enabled || keys == null || weights == null || keys.Length != weights.Length) return -1;
            if (bucket < 1 || bucket > 100) return -1; // Project guard, not original hash overflow behavior.
            long cumulative = 0;
            for (int i = 0; i < weights.Length; i++)
            {
                if (weights[i] < 1) continue;
                cumulative += weights[i];
                if (bucket <= cumulative) return i;
            }
            return -1;
        }

        // Confirmed GetABListIntVar: parse failure keeps the caller's fallback.
        public static int ReadListInt(string values, int index, int fallback)
        {
            if (string.IsNullOrEmpty(values) || index < 0) return fallback;
            string[] parts = values.Split(',');
            return index < parts.Length && int.TryParse(parts[index], NumberStyles.Integer,
                CultureInfo.InvariantCulture, out int value) ? value : fallback;
        }

        // Confirmed GetHotFixInt: missing/empty keeps default; malformed nonempty
        // TryParse writes zero. This differs from ReadListInt above.
        public static int ReadHotfixInt(string value, int fallback)
        {
            if (string.IsNullOrEmpty(value)) return fallback;
            int.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out int result);
            return result;
        }
    }

    [Serializable] public sealed class LevelTuning
    {
        public bool enabled;
        public string themeId;
        public int difficulty;
        public string hotfixTypeCountOffset;
        public bool abEnabled;
        public int manualBucket;
        public string[] forkKeys;
        public int[] forkWeights;
        public string typeCountOffsetValues;
    }

    [Serializable] public sealed class LevelTuningCatalog
    {
        public LevelTuning[] overrides = new LevelTuning[0];

        public string Apply(LevelDefinition level, ThemeDefinition theme, int difficulty)
        {
            if (overrides == null) return "baseline";
            foreach (var entry in overrides)
            {
                if (entry == null || !entry.enabled || entry.themeId != theme.id || entry.difficulty != difficulty) continue;
                int fork = LevelConfigPolicy.SelectFork(entry.abEnabled, entry.forkKeys, entry.forkWeights, entry.manualBucket);
                int hotfix = LevelConfigPolicy.ReadHotfixInt(entry.hotfixTypeCountOffset, 0);
                int ab = LevelConfigPolicy.ReadListInt(entry.typeCountOffsetValues, fork, 0);
                // Source CreateLevel changes TypeCount separately from SumCount.
                // Own adapter: preserve total triple groups while changing kinds.
                // Asset bounds and overflow protection are project safeguards.
                int totalGroups = level.TotalGroups;
                long requested = (long)level.kinds + hotfix + ab;
                level.kinds = (int)Math.Max(1, Math.Min(theme.items.Length, requested));
                if (level.pileLayers != null)
                    foreach (var layer in level.pileLayers)
                        layer.kinds = (int)Math.Max(1, Math.Min(theme.items.Length, (long)layer.kinds + hotfix + ab));
                level.totalGroups = totalGroups;
                return "local tuning: fork=" + fork + ", hotfix=" + hotfix + ", ab=" + ab + ", kinds=" + level.kinds;
            }
            return "baseline";
        }
    }
}
