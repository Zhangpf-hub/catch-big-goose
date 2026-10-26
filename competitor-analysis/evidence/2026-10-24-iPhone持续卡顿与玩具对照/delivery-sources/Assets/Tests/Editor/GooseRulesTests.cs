using System.Linq;
using NUnit.Framework;

namespace CatchGoose.Tests
{
    public class GooseRulesTests
    {
        ThemeDefinition Theme => new ThemeDefinition { items = new[] { "a", "b", "c", "d", "e", "f", "g", "h", "i" } };
        [Test] public void LevelCountsAndCompleteTriples()
        {
            int[] totals = { 48, 54, 81 };
            for (int i = 0; i < 3; i++)
            {
                var level = LevelDefinition.At(i); var queue = level.MakeQueue(Theme, new DeterministicRandom(level.seed));
                Assert.AreEqual(totals[i], level.Total);
                if (level.golden) { Assert.AreEqual("goose", queue[0]); queue.RemoveAt(0); }
                Assert.AreEqual(totals[i], queue.Count);
                Assert.IsTrue(queue.GroupBy(x => x).All(g => g.Count() % 3 == 0));
            }
        }
        [Test] public void SeededQueuesReproduceAcrossRetries()
        {
            var level = LevelDefinition.At(2);
            CollectionAssert.AreEqual(level.MakeQueue(Theme, new DeterministicRandom(level.seed)), level.MakeQueue(Theme, new DeterministicRandom(level.seed)));
            CollectionAssert.AreNotEqual(level.MakeQueue(Theme, new DeterministicRandom(level.seed)), level.MakeQueue(Theme, new DeterministicRandom(level.seed + 1)));
        }
        [Test] public void MatchingSeventhItemFreesSpaceBeforeFailure()
        {
            var tray = new TrayRules<string>(x => x);
            foreach (var id in new[] { "a", "b", "c", "d", "e", "a" }) tray.Add(id);
            var match = tray.Add("a"); Assert.AreEqual(3, match.Count); Assert.AreEqual(4, tray.Entries.Count);
        }
        [Test] public void SameIdsStayAdjacentAndRemoveConservesItems()
        {
            var tray = new TrayRules<string>(x => x);
            foreach (var id in new[] { "a", "b", "c", "a" }) tray.Add(id);
            CollectionAssert.AreEqual(new[] { "a", "a", "b", "c" }, tray.Entries);
            CollectionAssert.AreEqual(new[] { "a", "a", "b" }, tray.TakeFront(3));
            CollectionAssert.AreEqual(new[] { "c" }, tray.Entries);
        }
        [Test] public void FullTrayRejectsAnEighthEntry()
        {
            var tray = new TrayRules<string>(x => x);
            foreach (var id in new[] { "a", "b", "c", "d", "e", "f", "g" }) tray.Add(id);
            Assert.Throws<System.InvalidOperationException>(() => tray.Add("h"));
        }
    }
}
