using System.Linq;
using NUnit.Framework;
using UnityEngine;

namespace CatchGoose.Tests
{
    public sealed class GooseCoreRoundTests
    {
        ThemeDefinition Theme => new ThemeDefinition { id = "fixture", items = new[] { "a", "b", "c", "d", "e", "f", "g", "h", "goose" } };
        CoreRoundCatalog Catalog => JsonUtility.FromJson<CoreRoundCatalog>(Resources.Load<TextAsset>("Data/core-rounds").text);
        [Test] public void SourceBasedProfilesConserveEveryLayerAndTargetTriple()
        {
            int[] totals = { 15, 60, 300 };
            for (int difficulty = 0; difficulty < 3; difficulty++)
            {
                var level = Catalog.Create(difficulty);
                var queue = level.MakeQueue(Theme, new DeterministicRandom(level.seed));
                Assert.AreEqual(totals[difficulty], queue.Count);
                Assert.AreEqual(queue.Count, level.Total);
                Assert.IsFalse(level.golden); Assert.AreEqual(0, level.frozen);
                Assert.IsTrue(queue.GroupBy(x => x).All(g => g.Count() % 3 == 0));
                int cursor = level.targetCount;
                foreach (var layer in level.pileLayers)
                {
                    var stock = queue.Skip(cursor).Take(layer.normalCount).ToList();
                    Assert.AreEqual(layer.normalCount, stock.Count);
                    Assert.LessOrEqual(stock.Distinct().Count(), layer.kinds);
                    Assert.IsTrue(stock.GroupBy(x => x).All(g => g.Count() % 3 == 0));
                    cursor += layer.normalCount;
                }
                if (difficulty == 0) Assert.AreEqual(3, queue.Count(x => x == "goose"));
            }
        }
        [Test] public void SpawnCadenceUsesNormalBranchSceneValues()
        {
            var level = Catalog.Create(2);
            Assert.AreEqual(.02f, level.SpawnWait(300), 1e-6);
            Assert.AreEqual(.03f, level.SpawnWait(60), 1e-6);
            Assert.AreEqual(3, level.spawnBatch);
        }
        [Test] public void LayerBoundariesAreExplicitAndStockIsNotRefilled()
        {
            var level = Catalog.Create(2);
            CollectionAssert.AreEqual(new[] {0,0,1,1,2,2,3,3}, new[] {0,149,150,209,210,254,255,299}.Select(level.LayerAt));
            var a = level.MakeQueue(Theme, new DeterministicRandom(123));
            var b = level.MakeQueue(Theme, new DeterministicRandom(123));
            CollectionAssert.AreEqual(a, b);
            Assert.AreEqual(300, a.Count);
        }
        [Test] public void AbUncoveredBucketsDoNotNormalizeIntoAnExperiment()
        {
            var keys = new[] {"Easy70", "Easy80", "Easy90"}; var weights = new[] {8,8,8};
            Assert.AreEqual(0, LevelConfigPolicy.SelectFork(true, keys, weights, 8));
            Assert.AreEqual(1, LevelConfigPolicy.SelectFork(true, keys, weights, 9));
            Assert.AreEqual(2, LevelConfigPolicy.SelectFork(true, keys, weights, 24));
            Assert.AreEqual(-1, LevelConfigPolicy.SelectFork(true, keys, weights, 25));
            Assert.AreEqual(-1, LevelConfigPolicy.SelectFork(false, keys, weights, 1));
        }
        [Test] public void ExpandedThemeQuotasConserveAllSourceLayerBudgets()
        {
            var themes = JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
            foreach (var theme in themes)
            {
                Assert.GreaterOrEqual(theme.items.Length, 7, theme.id); Assert.AreEqual(theme.items.Length, theme.items.Distinct().Count());
                Assert.AreEqual(theme.items.Length, theme.coreGroupWeights.Length);
                Assert.IsTrue(theme.coreGroupWeights.All(w=>w>0 && float.IsFinite(w)),theme.id);
                for (uint seed = 1; seed <= 80; seed++)
                {
                    var level = Catalog.Create(2); var queue = level.MakeQueue(theme, new DeterministicRandom(seed));
                    Assert.AreEqual(300, queue.Count);
                    int cursor = 0;
                    foreach (var layer in level.pileLayers)
                    {
                        var stock = queue.Skip(cursor).Take(layer.normalCount).ToList();
                        Assert.IsTrue(stock.GroupBy(x => x).All(g => g.Count() % 3 == 0));
                        Assert.LessOrEqual(stock.Distinct().Count(), layer.kinds);
                        Assert.IsTrue(stock.All(theme.items.Contains)); cursor += layer.normalCount;
                    }
                }
            }
        }
    }
}
