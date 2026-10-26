using System;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    // Separate catalog and transient selection. Never mutate the five story themes.
    public sealed partial class GooseGame
    {
        public bool DuckReviewActive {get;private set;}
        public int DuckReviewIndex {get;private set;}
        public ThemeDefinition[] DuckReviewThemes {get;private set;}
        ThemeDefinition duckReviewTheme;
        int duckReturnTheme,duckReturnDifficulty;
        int[] duckReturnBonuses,duckReturnProps;
        public void LoadDuckReviewCatalog()
        {
            if(DuckReviewThemes!=null)return;
            var data=Resources.Load<TextAsset>("Data/duck-review");
            if(!data)throw new InvalidOperationException("Duck review catalog is missing");
            DuckReviewThemes=JsonUtility.FromJson<ThemeCatalog>(data.text).themes;
            if(DuckReviewThemes.Length!=5||DuckReviewThemes.Any(t=>t.items.Length!=4))
                throw new InvalidOperationException("Duck review needs five themes with four models each");
        }
        public void BeginDuckReview(int index)
        {
            LoadDuckReviewCatalog();
            if(index<0||index>=DuckReviewThemes.Length)throw new ArgumentOutOfRangeException(nameof(index));
            if(!DuckReviewActive)
            {
                duckReturnTheme=ThemeIndex;duckReturnDifficulty=Difficulty;
                duckReturnBonuses=(int[])nextBonus.Clone();duckReturnProps=(int[])Props.Clone();
            }
            ReferenceTrial=false;DuckReviewActive=true;DuckReviewIndex=index;
            duckReviewTheme=DuckReviewThemes[index];Difficulty=1;storySequenceActive=false;
            BeginRound(false);
        }
        LevelDefinition DuckReviewLevel()
        {
            var ids=duckReviewTheme.items;
            return new LevelDefinition{competitorCore=true,strictCatalog=true,kinds=4,seconds=600,layers=3,
                seed=(uint)(620251+DuckReviewIndex*104729),targetCount=0,golden=false,frozen=0,
                spawnInterval=.03f,spawnDuration=2,spawnBatch=3,
                pileLayers=new[]{new PileLayerDefinition{normalCount=48,kinds=4,sourceHeight=10,
                    candidateItems=(string[])ids.Clone(),candidateWeights=new[]{1f,1f,1f,1f}}}};
        }
        void RestoreDuckReviewSelection()
        {
            if(!DuckReviewActive)return;
            DuckReviewActive=false;duckReviewTheme=null;ThemeIndex=duckReturnTheme;Difficulty=duckReturnDifficulty;
            Array.Copy(duckReturnBonuses,nextBonus,3);Array.Copy(duckReturnProps,Props,3);
        }
    }
}
