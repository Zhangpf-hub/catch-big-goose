using System;
using System.Collections.Generic;

namespace CatchGoose
{
    // Confirmed core: cumulative weights + observed-frequency compensation (KFakeRandom).
    // Adaptations: finite input checks, normalization and deterministic caller-provided RNG.
    public sealed class FairWeightedSelector
    {
        readonly float[] initial, probability, frequency;
        readonly int[] hits;
        int rolls;
        readonly bool stabilize;
        public int Count => initial.Length;
        public float Probability(int index) => probability[index];
        public float Frequency(int index) => frequency[index];
        public int Hits(int index) => hits[index];

        public FairWeightedSelector(IList<float> weights, bool stabilize = true)
        {
            this.stabilize = stabilize;
            if (weights == null || weights.Count == 0) throw new ArgumentException("No weighted candidates");
            initial = new float[weights.Count]; probability = new float[weights.Count];
            frequency = new float[weights.Count]; hits = new int[weights.Count];
            double sum = 0;
            foreach (float w in weights)
            { if (!AlgorithmMath.Finite(w) || w < 0) throw new ArgumentException("Weights must be finite and nonnegative"); sum += w; }
            if (sum <= 0) throw new ArgumentException("At least one weight must be positive");
            for (int i = 0; i < weights.Count; i++) initial[i] = probability[i] = (float)(weights[i] / sum);
        }

        public int Draw(Func<float> next)
        {
            float sum = 0;
            for (int i = 0; i < Count; i++) sum += probability[i];
            // Numerical recovery is our defensive extension, not a recovered competitor branch.
            if (!(sum > 0) || !AlgorithmMath.Finite(sum))
            { Array.Copy(initial, probability, Count); sum = 0; foreach (float p in probability) sum += p; }
            float value = AlgorithmMath.Unit(next()) * sum, cumulative = 0;
            int index = Count - 1;
            for (int i = 0; i < Count; i++)
            { cumulative += probability[i]; if (cumulative > value) { index = i; break; } }
            rolls++;
            hits[index]++;
            frequency[index] = hits[index] / (float)rolls;
            float difference = frequency[index] - initial[index], transfer = 0;
            if (difference > 0) transfer = Math.Min(difference, probability[index]);
            else if (difference < 0) transfer = Math.Max(difference, probability[index] - 1);
            probability[index] -= transfer;
            if (transfer != 0)
            {
                float otherInitial = 0;
                for (int i = 0; i < Count; i++) if (i != index) otherInitial += initial[i];
                if (otherInitial > 0)
                    for (int i = 0; i < Count; i++) if (i != index)
                    {
                        probability[i] += (transfer / otherInitial) * initial[i];
                        frequency[i] = hits[i] / (float)rolls;
                    }
            }
            // Project safeguard: repeated draws in our finite reservoir have a different
            // lifecycle from competitor Roll/Check/RemoveItem. Keep its CDF monotonic.
            // Unstabilized mode is used only for original-WASM conformance tests.
            if (stabilize)
            {
                float boundedSum = 0;
                for (int i = 0; i < Count; i++) { probability[i] = Math.Max(0, Math.Min(1, probability[i])); boundedSum += probability[i]; }
                if (boundedSum > 0) for (int i = 0; i < Count; i++) probability[i] /= boundedSum;
            }
            return index;
        }
    }

    public static class FinitePileGenerator
    {
        // Own adaptation: the reservoir is fixed in complete triples. Depleted types are
        // removed and the remaining selector is rebuilt; the competitor removal policy differs.
        public static List<string> Build(string[] family, int kinds, int groups, float[] weights, Func<float> next)
        {
            if (family == null || kinds < 1 || kinds > family.Length || groups < 1 || groups > 1000)
                throw new ArgumentException("Invalid finite level inventory");
            var unique = new HashSet<string>();
            var remaining = new int[kinds];
            var ids = new List<int>();
            for (int i = 0; i < kinds; i++)
            {
                if (string.IsNullOrEmpty(family[i]) || !unique.Add(family[i])) throw new ArgumentException("Duplicate or empty item id");
                if (weights != null && (weights.Length < kinds || !AlgorithmMath.Finite(weights[i]) || weights[i] < 0))
                    throw new ArgumentException("Invalid level item weights");
                remaining[i] = groups * 3; ids.Add(i);
            }
            FairWeightedSelector selector = Rebuild(ids, weights);
            var queue = new List<string>(checked(kinds * groups * 3));
            while (ids.Count > 0)
            {
                int slot = selector.Draw(next), id = ids[slot];
                queue.Add(family[id]);
                if (--remaining[id] == 0)
                { ids.RemoveAt(slot); if (ids.Count > 0) selector = Rebuild(ids, weights); }
            }
            return queue;
        }

        static FairWeightedSelector Rebuild(List<int> ids, float[] weights)
        {
            var active = new List<float>(); float sum = 0;
            foreach (int id in ids) { float w = weights == null ? 1 : weights[id]; active.Add(w); sum += w; }
            // Zero-weight stock still has to be cleared when it is all that remains.
            if (sum == 0) for (int i = 0; i < active.Count; i++) active[i] = 1;
            return new FairWeightedSelector(active);
        }
    }

    public static class WeightedPosition
    {
        // Increasing-density domain is algebraically equivalent to the recovered method.
        // Stable form also supports decreasing/zero endpoint densities (our extension).
        public static float Linear(float min, float max, float leftWeight, float rightWeight, float unit)
        {
            if (!AlgorithmMath.Finite(min) || !AlgorithmMath.Finite(max) || max < min
                || !AlgorithmMath.Finite(leftWeight) || !AlgorithmMath.Finite(rightWeight) || leftWeight < 0 || rightWeight < 0)
                throw new ArgumentException("Invalid weighted interval");
            double u = AlgorithmMath.Unit(unit), a = leftWeight, b = rightWeight;
            if (a + b == 0 || Math.Abs(a - b) <= 1e-6 * Math.Max(a, b)) return min + (max - min) * (float)u;
            double area = u * (a + b) * .5;
            double denominator = a + Math.Sqrt(Math.Max(0, a * a + 2 * (b - a) * area));
            double t = denominator == 0 ? 0 : 2 * area / denominator;
            return min + (max - min) * (float)Math.Max(0, Math.Min(1, t));
        }

        public static float Centered(float unit, float segmentUnit, float edgeWeight)
        {
            // Two intervals: weight = (left + right) * width, as in GetWeightMultiPart.
            // Their masses are equal for this symmetric, project-specific profile.
            return segmentUnit < .5f ? Linear(0, .5f, edgeWeight, 1, unit) : Linear(.5f, 1, 1, edgeWeight, unit);
        }
    }

    public static class AlgorithmMath
    {
        public static bool Finite(float value) => !float.IsNaN(value) && !float.IsInfinity(value);
        public static float Unit(float value)
        { if (!Finite(value)) throw new ArgumentException("Random source returned a non-finite value"); return Math.Max(0, Math.Min(1, value)); }
    }
}
