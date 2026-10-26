using System;
using System.Collections.Generic;
using UnityEngine;
namespace CatchGoose
{
    [Serializable] public sealed class GoosePreparedLayouts
    {
        [Serializable] public sealed class Pose { public string id;public Vector3 position,scale;public Quaternion rotation; }
        [Serializable] public sealed class Layout { public string theme,key;public int stage;public float itemScale;public Pose[] items; }
        public int version=1;public Layout[] layouts;
        // Includes inventory/seed, normalized visual dimensions and actual hull
        // vertices. A changed model or tuning falls back to live preparation.
        public static string Key(GooseGame game,ThemeDefinition theme,LevelDefinition level)
        {
            var p=GooseInteractionProfile.Current;
            var ids=new HashSet<string>(level.MakeQueue(theme,new DeterministicRandom(level.seed),game.AlgorithmSettings.weightedGeneration));ids.Add(theme.container);
            return Hash128.Compute("layout-v1|"+theme.id+"|"+theme.container+"|"+JsonUtility.ToJson(level)+"|"+
                p.gravity+"|"+p.staticFriction+"|"+p.dynamicFriction+"|"+game.PreparedGeometryKey(ids)).ToString();
        }
    }
}
