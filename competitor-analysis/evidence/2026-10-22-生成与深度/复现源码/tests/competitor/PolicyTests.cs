using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using CatchGoose;

// Runs actual production classes under .NET without Unity native engine calls.
public static class PolicyTests
{
    static int checks;
    static readonly CultureInfo Culture = CultureInfo.InvariantCulture;
    static void Check(bool result, string message) { checks++; if (!result) throw new Exception(message); }
    static float Number(string value) => float.Parse(value, Culture);
    static void Near(float actual, float expected, string message)
        => Check(Math.Abs(actual - expected) <= 2e-5f, message + ": " + actual + " / " + expected);
    static void Reject(Action action, string label)
    { bool rejected = false; try { action(); } catch (ArgumentException) { rejected = true; } Check(rejected, label); }

    public static int Main(string[] args)
    {
        try
        {
            int numeric = 0, tracedDraws = 0;
            foreach (string line in File.ReadLines(Path.Combine(args[0], "original-cases.csv")))
            {
                string[] cells = line.Split(','); float a = Number(cells[1]), b = Number(cells[2]), u = Number(cells[3]), expected = Number(cells[4]);
                float actual = cells[0] == "linear" ? WeightedPosition.Linear(-2, 3, a, b, u) : PileDepthPolicy.Threshold(a, 2, .4f, .6f, b);
                Near(actual, expected, "Original WASM " + line); numeric++;
            }
            FairWeightedSelector raw = null; string previous = null;
            foreach (string line in File.ReadLines(Path.Combine(args[0], "original-weight-traces.csv")))
            {
                string[] cells = line.Split(',');
                if (cells[0] != previous) { raw = new FairWeightedSelector(cells[0].Split(';').Select(Number).ToArray(), false); previous = cells[0]; }
                int selected = raw.Draw(() => Number(cells[1]));
                Check(selected == int.Parse(cells[2]), "Original selector choice at draw " + tracedDraws);
                float[] probabilities = cells[3].Split(';').Select(Number).ToArray();
                int[] hits = cells[4].Split(';').Select(int.Parse).ToArray();
                for (int i = 0; i < raw.Count; i++) { Near(raw.Probability(i), probabilities[i], "Original probability " + tracedDraws); Check(raw.Hits(i) == hits[i], "Original hit count"); }
                tracedDraws++;
            }
            var family = new[] { "a", "b", "c", "d", "e", "f", "g", "h", "i" };
            var theme = new ThemeDefinition { items = family };
            for (int seed = 1; seed <= 100; seed++) for (int difficulty = 0; difficulty < 3; difficulty++)
            {
                var level = LevelDefinition.At(difficulty); level.seed = (uint)seed * 2654435761u;
                var queue = level.MakeQueue(theme, new DeterministicRandom(level.seed));
                Check(queue.SequenceEqual(level.MakeQueue(theme, new DeterministicRandom(level.seed))), "Repeat seed");
                if (level.golden) { Check(queue[0] == "goose", "Golden prefix"); queue.RemoveAt(0); }
                Check(queue.Count == level.Total, "Fixed total");
                Check(queue.GroupBy(x => x).Count() == level.kinds, "All configured kinds survive");
                Check(queue.GroupBy(x => x).All(g => g.Count() == level.groups * 3), "Per-type stock conserved");
                Check(queue.All(id => family.Take(level.kinds).Contains(id)), "Theme isolation");
            }
            int biasedFirst = 0;
            for (int seed = 1; seed <= 300; seed++)
            {
                var rng = new DeterministicRandom((uint)seed * 2654435761u);
                var queue = FinitePileGenerator.Build(family, 4, 3, new[] { 20f, 1, 0, 1 }, rng.Next);
                if (queue[0] == "a") biasedFirst++;
                Check(queue.GroupBy(x => x).All(g => g.Count() == 9), "Skew/zero weight still conserves stock");
            }
            Check(biasedFirst > 240, "Weights affect selection before inventory depletion");
            var random = new Random(89173); var stable = new FairWeightedSelector(new[] { .25f, .5f, .25f });
            for (int n = 0; n < 20000; n++)
            {
                stable.Draw(() => (float)random.NextDouble());
                float sum = 0;
                for (int i = 0; i < stable.Count; i++) { float p = stable.Probability(i); Check(AlgorithmMath.Finite(p) && p >= 0 && p <= 1, "Production CDF stays valid"); sum += p; }
                Near(sum, 1, "Production probability mass");
            }
            Check(Math.Abs(stable.Hits(0) / 20000f - .25f) < .03f, "Long-run nominal frequency");
            foreach (var endpoints in new[] { new[] { 1f, 0 }, new[] { 0f, 1 }, new[] { 0f, 0 }, new[] { 2f, .1f } })
                for (int n = 0; n <= 1000; n++)
                { float value = WeightedPosition.Linear(0, 1, endpoints[0], endpoints[1], n / 1000f); Check(AlgorithmMath.Finite(value) && value >= 0 && value <= 1, "Extended density domain"); }
            Reject(() => new FairWeightedSelector(new[] { float.NaN, 1 }), "Reject NaN weights");
            Reject(() => new FairWeightedSelector(new[] { -1f, 1 }), "Reject negative weights");
            Reject(() => FinitePileGenerator.Build(new[] { "a", "a" }, 2, 2, null, () => .5f), "Reject duplicate IDs");
            Reject(() => FinitePileGenerator.Build(family, 4, 1, new[] { 1f }, () => .5f), "Reject truncated weights");
            var settings = new PileAlgorithmSettings(); settings.Validate();
            Near(PileDepthPolicy.Descend(2, .5f, .1f), 1.9f, "Bounded frontier descent");
            Near(PileDepthPolicy.Descend(1, 2, .1f), 1, "Frontier never rises without explicit reset");
            Check(!PileDepthPolicy.ShouldFreeze(0, 1, false, false, 1, 0, 2, settings), "Moving body protected");
            Check(!PileDepthPolicy.ShouldFreeze(0, 1, false, true, 0, 0, 2, settings), "Disturbed body protected");
            Check(!PileDepthPolicy.ShouldFreeze(0, 1, false, false, 0, 0, .1f, settings), "Unsettled body protected");
            Check(PileDepthPolicy.ShouldFreeze(0, 1, false, false, 0, 0, 2, settings), "Settled deep body held");
            Check(!PileDepthPolicy.ShouldFreeze(2, 1, true, false, 0, 0, 2, settings), "Revealed body released");
            settings.referenceHeight = 0; Reject(settings.Validate, "Reject zero reference height");
            File.WriteAllText(Path.Combine(args[0], "policy-tests.json"), "{\"passed\":true,\"checks\":" + checks + ",\"originalNumericCases\":" + numeric + ",\"originalWeightedDraws\":" + tracedDraws + ",\"scope\":\"Actual production C# policies, without Unity native physics\"}");
            Console.WriteLine("PASS " + checks + " checks; original WASM parity: " + numeric + " numeric cases and " + tracedDraws + " weighted draws");
            return 0;
        }
        catch (Exception error) { Console.Error.WriteLine(error); return 1; }
    }
}
