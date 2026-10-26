using System;
using System.Linq;
using NUnit.Framework;
using UnityEngine;
namespace CatchGoose.Tests
{
    public sealed class ThemeRoundTests
    {
        ThemeDefinition[] Themes=>JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
        ThemeRoundCatalog Catalog=>JsonUtility.FromJson<ThemeRoundCatalog>(Resources.Load<TextAsset>("Data/theme-rounds").text);
        [Test] public void EverySourceThemeContainsItsCompleteDistinctModelPool()
        {
            foreach(var t in Themes)
            {
                int expected=t.id=="toys"?30:t.id=="breakfast"||t.id=="barbecue"?21:22;
                Assert.AreEqual(expected,t.items.Length,t.id);Assert.AreEqual(expected,t.items.Distinct().Count(),t.id);
                foreach(var id in t.items){Assert.IsNotNull(Resources.Load<GameObject>("Models/"+id+"/"+id),id);Assert.IsNotNull(Resources.Load<Mesh>("Physics/"+id),id);}
            }
        }
        [Test] public void OneHundredSeedsPerThemeAndStagePreserveSourceBudgetsAndDeterminism()
        {
            foreach(var t in Themes)for(int stage=0;stage<2;stage++)for(uint seed=1;seed<=100;seed++)
            {
                var l=Catalog.Create(t,stage);var a=l.MakeQueue(t,new DeterministicRandom(seed));var b=l.MakeQueue(t,new DeterministicRandom(seed));
                CollectionAssert.AreEqual(a,b,t.id);Assert.AreEqual(stage==0?15:300,a.Count,t.id);Assert.IsTrue(a.All(t.items.Contains));
                Assert.IsTrue(a.GroupBy(id=>id).All(g=>g.Count()%3==0));int cursor=l.targetCount;
                foreach(var layer in l.pileLayers)
                {
                    var stock=a.Skip(cursor).Take(layer.normalCount).ToArray();Assert.AreEqual(layer.normalCount,stock.Length);
                    Assert.IsTrue(stock.All(layer.candidateItems.Contains));Assert.IsTrue(stock.GroupBy(id=>id).All(g=>g.Count()%3==0));Assert.LessOrEqual(stock.Distinct().Count(),layer.kinds);cursor+=layer.normalCount;
                }
                if(stage==0){Assert.AreEqual(0,l.seconds);Assert.AreEqual(3,a.Distinct().Count());Assert.AreEqual(3,a.Count(id=>id==l.targetItem));CollectionAssert.AreEquivalent(new[]{6,6},a.Where(id=>id!=l.targetItem).GroupBy(id=>id).Select(g=>g.Count()).ToArray());}
                else{Assert.AreEqual(t.id=="toys"?480:600,l.seconds);CollectionAssert.AreEqual(t.id=="toys"?new[]{240,30,30}:new[]{150,60,45,45},l.pileLayers.Select(x=>x.normalCount));}
            }
        }
        [Test] public void SourceTypeCountsAndHeightsAreThemeSpecific()
        {
            foreach(var t in Themes)
            {
                var p=Catalog.Create(t,1);
                var kinds=t.id=="toys"?new[]{30,7,5}:new[]{t.id=="breakfast"?20:t.id=="barbecue"?21:22,10,8,7};
                CollectionAssert.AreEqual(kinds,p.pileLayers.Select(x=>x.kinds));
                var heights=t.id=="toys"?new[]{17f,19,23}:t.id=="breakfast"?new[]{14f,18,21,24}:new[]{14f,18,20,22};
                CollectionAssert.AreEqual(heights,p.pileLayers.Select(x=>x.sourceHeight));
            }
        }
        [Test] public void RareZeroAndRemainderQuotasKeepCompleteTriples()
        {
            CollectionAssert.AreEqual(new[]{2,3},WeightedGroupAllocation.Allocate(5,new[]{1f,1f}));
            CollectionAssert.AreEqual(new[]{4,3},WeightedGroupAllocation.Allocate(7,new[]{1f,1f}));
            CollectionAssert.AreEqual(new[]{0,0,1},WeightedGroupAllocation.Allocate(1,new[]{1f,1f,1f}));
            CollectionAssert.AreEqual(new[]{0,25,25},WeightedGroupAllocation.Allocate(50,new[]{.0001f,1f,1f}));
            CollectionAssert.AreEqual(new[]{2,2,1},WeightedGroupAllocation.Allocate(5,new[]{1f,1f,0f}));
            var random=new DeterministicRandom(19);
            var queue=FinitePileGenerator.Build(new[]{"rare","normal","remainder"},3,1,null,random.Next,new[]{.0001f,1f,1f},50);
            Assert.AreEqual(150,queue.Count);Assert.IsFalse(queue.Contains("rare"));
            CollectionAssert.AreEquivalent(new[]{75,75},queue.GroupBy(id=>id).Select(g=>g.Count()));
        }
        [Test] public void IncompletePoolAndThirdProductionStageAreRejected()
        {
            var t=Themes.First(x=>x.id=="grocery");Assert.Throws<ArgumentOutOfRangeException>(()=>Catalog.Create(t,2));t.items=t.items.Skip(1).ToArray();Assert.Throws<InvalidOperationException>(()=>Catalog.Create(t,1));
            var missing=Assert.Throws<InvalidOperationException>(()=>new GooseAssetCache().Instantiate("__required_source_model_missing__",null));
            StringAssert.Contains("Missing model",missing.Message);
        }
        [Test] public void NewStoryProgressIsIndependentPerThemeAndFromLegacyDifficulty()
        {
            bool old=GooseSave.IsQa;GooseSave.IsQa=true;
            try{string a="test_story_"+Guid.NewGuid(),b="test_story_"+Guid.NewGuid();GooseSave.Difficulty=2;Assert.AreEqual(0,GooseSave.StoryStage(a));GooseSave.CompleteStoryStage(a,0);Assert.IsTrue(GooseSave.TutorialComplete(a));Assert.IsFalse(GooseSave.TutorialComplete(b));Assert.AreEqual(0,GooseSave.StoryStage(b));Assert.IsFalse(GooseSave.ChallengeComplete(a));}
            finally{GooseSave.IsQa=old;}
        }
    }
}
