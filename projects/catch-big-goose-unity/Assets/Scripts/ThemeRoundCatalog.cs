using System;
using System.Linq;
namespace CatchGoose
{
    [Serializable] public sealed class ThemeRoundProfile
    {
        public string themeId,sourceMode,targetItem,sourceScene;
        public int stage,sourceIndex,sourceLevel,seconds,targetCount;
        public bool custom;
        public float layers,sourceSceneSize,sourceLimitHeight;
        public PileLayerDefinition[] pileLayers;
    }
    [Serializable] public sealed class ThemeRoundCatalog
    {
        public int version;
        public ThemeRoundProfile[] profiles;
        public LevelDefinition Create(ThemeDefinition theme,int stageIndex)
        {
            if(stageIndex<0||stageIndex>1)throw new ArgumentOutOfRangeException(nameof(stageIndex));
            var p=profiles.Single(x=>x.themeId==theme.id&&x.stage==stageIndex+1);
            foreach(var layer in p.pileLayers)
            {
                if(layer.candidateItems.Length<layer.kinds||layer.candidateWeights.Length!=layer.candidateItems.Length||layer.candidateItems.Distinct().Count()!=layer.candidateItems.Length)
                    throw new InvalidOperationException("Incomplete source candidate pool: "+theme.id);
                if(layer.candidateItems.Any(id=>!theme.items.Contains(id)))throw new InvalidOperationException("Source model missing from theme: "+theme.id);
            }
            if(p.targetCount>0&&!theme.items.Contains(p.targetItem))throw new InvalidOperationException("Missing theme target: "+p.targetItem);
            return new LevelDefinition{competitorCore=true,strictCatalog=true,kinds=p.pileLayers.Max(l=>l.kinds),seconds=p.seconds,targetCount=p.targetCount,targetItem=p.targetItem,
                layers=p.layers,seed=(uint)(104729+stageIndex*50719+p.sourceIndex),spawnInterval=.03f,spawnDuration=2,spawnBatch=3,
                pileLayers=p.pileLayers.Select(l=>new PileLayerDefinition{normalCount=l.normalCount,kinds=l.kinds,sourceHeight=l.sourceHeight,candidateItems=(string[])l.candidateItems.Clone(),candidateWeights=(float[])l.candidateWeights.Clone()}).ToArray()};
        }
    }
}
