using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace CatchGoose
{
    [Serializable] public class ThemeCatalog { public ThemeDefinition[] themes; }
    [Serializable] public class ThemeDefinition
    {
        public string id, name, background, container, icon;
        public string[] items;
        /** Own per-theme tuning; null means equal nominal weights, not recovered competitor values. */
        public float[] itemWeights;
        /** Optional group-count quotas, separate from the draw-order weights above.
         * Null retains equal stock; source names must be matched before copying values. */
        public float[] groupWeights;
        // Frozen competitor table values with explicitly documented own-model mappings.
        // Separate from legacy regression stock and from type-inclusion probability.
        public float[] coreGroupWeights;
        public string coreWeightEvidence;
        public bool circular;
        public float halfX, halfZ;
    }
    [Serializable] public class LevelDefinition
    {
        public int kinds, groups, seconds, frozen;
        // Explicit stock is independent of TypeCount when local tuning is enabled.
        public int totalGroups;
        public float layers;
        public uint seed;
        public bool golden;
        public bool competitorCore;
        public bool strictCatalog;
        public int targetCount;
        public string targetItem = "goose";
        public float spawnInterval = .06f;
        public float spawnDuration = 2;
        public int spawnBatch = 1;
        public PileLayerDefinition[] pileLayers;
        public static LevelDefinition At(int index)
        {
            switch (index)
            {
                case 0: return new LevelDefinition { kinds = 4, groups = 4, seconds = 255, layers = 3.1f, seed = 104729 };
                case 1: return new LevelDefinition { kinds = 6, groups = 3, seconds = 210, layers = 3.4f, seed = 130363, frozen = 4, golden = true };
                default: return new LevelDefinition { kinds = 9, groups = 3, seconds = 165, layers = 3.9f, seed = 155921, frozen = 7, golden = true };
            }
        }
        public int TotalGroups => pileLayers != null && pileLayers.Length > 0 ? pileLayers.Sum(l => l.normalCount / 3) : totalGroups > 0 ? totalGroups : kinds * groups;
        public int Total => TotalGroups * 3 + targetCount;
        public float SpawnWait(int count) => competitorCore ? Math.Min(spawnInterval, spawnDuration * spawnBatch / Math.Max(1, count)) : spawnInterval;
        public int LayerAt(int index)
        {
            if (pileLayers == null || pileLayers.Length == 0) return 0;
            int cursor = Math.Max(0, index - targetCount);
            for (int i = 0; i < pileLayers.Length; i++)
            { if (cursor < pileLayers[i].normalCount) return i; cursor -= pileLayers[i].normalCount; }
            return pileLayers.Length - 1;
        }
        public List<string> MakeQueue(ThemeDefinition theme, DeterministicRandom random, bool weighted = true)
        {
            if (pileLayers != null && pileLayers.Length > 0)
            {
                var layered = new List<string>(Total);
                for (int i = 0; i < targetCount; i++) layered.Add(targetItem);
                foreach (var layer in pileLayers)
                {
                    if(layer.candidateItems!=null&&layer.candidateItems.Length>0)
                    {
                        var selected=Enumerable.Range(0,layer.candidateItems.Length).ToList();random.Shuffle(selected);
                        if(selected.Count<layer.kinds)throw new ArgumentException("Source candidate pool is incomplete");
                        var chosen=selected.Take(layer.kinds).ToArray();
                        layered.AddRange(FinitePileGenerator.Build(chosen.Select(i=>layer.candidateItems[i]).ToArray(),layer.kinds,1,null,random.Next,
                            chosen.Select(i=>layer.candidateWeights[i]).ToArray(),layer.normalCount/3));
                        continue;
                    }
                    // Equal-weight type inclusion without replacement precedes quotas.
                    var candidates = Enumerable.Range(0, theme.items.Length)
                        .Where(i => targetCount == 0 || theme.items[i] != targetItem).ToList();
                    random.Shuffle(candidates);
                    int count = Math.Min(layer.kinds, Math.Min(candidates.Count, layer.normalCount / 3));
                    if (count < 1 || layer.normalCount < 3 || layer.normalCount % 3 != 0)
                        throw new ArgumentException("Invalid layer stock");
                    var ids = candidates.Take(count).ToArray();
                    float[] order = weighted && theme.itemWeights != null ? ids.Select(i => theme.itemWeights[i]).ToArray() : null;
                    var quotaWeights = theme.coreGroupWeights ?? theme.groupWeights;
                    float[] quota = quotaWeights == null ? null : ids.Select(i => quotaWeights[i]).ToArray();
                    layered.AddRange(FinitePileGenerator.Build(ids.Select(i => theme.items[i]).ToArray(), count, 1,
                        order, random.Next, quota, layer.normalCount / 3));
                }
                return layered;
            }
            if (weighted || totalGroups > 0)
            {
                var queue = FinitePileGenerator.Build(theme.items, kinds, groups, weighted ? theme.itemWeights : null, random.Next, theme.groupWeights, totalGroups);
                if (golden) queue.Insert(0, "goose");
                return queue;
            }
            var result = new List<string>();
            foreach (var id in theme.items.Take(kinds))
                for (int i = 0; i < groups * 3; i++) result.Add(id);
            random.Shuffle(result);
            if (golden) result.Insert(0, "goose");
            return result;
        }
    }

    [Serializable] public sealed class PileLayerDefinition
    {
        public int normalCount, kinds;
        public float sourceHeight;
        public string[] candidateItems;
        public float[] candidateWeights;
    }

    [Serializable] public sealed class CoreRoundProfile
    {
        public string id, source;
        public int seconds, targetCount;
        public float layers;
        public PileLayerDefinition[] pileLayers;
    }

    [Serializable] public sealed class CoreRoundCatalog
    {
        public bool enabled;
        public float spawnInterval = .03f;
        public float spawnDuration = 2;
        public int spawnBatch = 3;
        public CoreRoundProfile[] profiles;
        public LevelDefinition Create(int difficulty)
        {
            var level = LevelDefinition.At(difficulty);
            if (!enabled || profiles == null || difficulty < 0 || difficulty >= profiles.Length) return level;
            var profile = profiles[difficulty];
            level.competitorCore = true; level.golden = false; level.frozen = 0;
            level.seconds = profile.seconds; level.targetCount = profile.targetCount;
            level.layers = profile.layers; level.spawnInterval = spawnInterval; level.spawnBatch = spawnBatch; level.spawnDuration = spawnDuration;
            level.pileLayers = profile.pileLayers.Select(l => new PileLayerDefinition {
                kinds = l.kinds, normalCount = l.normalCount, sourceHeight = l.sourceHeight }).ToArray();
            level.kinds = level.pileLayers.Max(l => l.kinds);
            return level;
        }
    }

    public sealed class DeterministicRandom
    {
        uint state;
        public DeterministicRandom(uint seed) { state = seed == 0 ? 1 : seed; }
        public float Next()
        {
            uint x = state;
            x ^= x << 13; x ^= x >> 17; x ^= x << 5; state = x;
            return (float)(state / 4294967296.0);
        }
        public void Shuffle<T>(IList<T> items)
        {
            for (int i = items.Count - 1; i > 0; i--)
            {
                int j = Math.Min(i, (int)(Next() * (i + 1)));
                T temp = items[i]; items[i] = items[j]; items[j] = temp;
            }
        }
    }

    public sealed class TrayRules<T>
    {
        public const int Capacity = 7;
        public readonly List<T> Entries = new List<T>();
        readonly Func<T, string> id;
        public TrayRules(Func<T, string> getId) { id = getId; }
        public List<T> Add(T item)
        {
            if (Entries.Count >= Capacity) throw new InvalidOperationException("Tray is already full");
            int index = Entries.FindLastIndex(x => id(x) == id(item));
            Entries.Insert(index < 0 ? Entries.Count : index + 1, item);
            var same = Entries.Where(x => id(x) == id(item)).Take(3).ToList();
            if (same.Count != 3) return null;
            foreach (var entry in same) Entries.Remove(entry);
            return same;
        }
        public List<T> TakeFront(int count)
        {
            var list = Entries.Take(count).ToList();
            Entries.RemoveRange(0, list.Count); return list;
        }
    }

    [Serializable] public class BestRecord { public int stars, score; public float progress; }
    public static class GooseSave
    {
        // QA uses its own namespace and never consumes the player's daily attempts or records.
        public static bool IsQa;
        static string Key(string name) => (IsQa ? "goose_unity_qa_" : "goose_unity_v1_") + name;
        public static float ModelSize { get => GooseGame.ClampModelSize(PlayerPrefs.GetFloat(Key("model_size_v1"), GooseGame.DefaultModelSize)); set { PlayerPrefs.SetFloat(Key("model_size_v1"), GooseGame.ClampModelSize(value)); PlayerPrefs.Save(); } }
        public static string Theme { get => PlayerPrefs.GetString(Key("theme"), "fruit"); set { PlayerPrefs.SetString(Key("theme"), value); PlayerPrefs.Save(); } }
        public static bool Onboarded { get => PlayerPrefs.GetInt(Key("onboarded"), 0) == 1; set { PlayerPrefs.SetInt(Key("onboarded"), value ? 1 : 0); PlayerPrefs.Save(); } }
        public static bool Sound { get => PlayerPrefs.GetInt(Key("sound"), 1) == 1; set { PlayerPrefs.SetInt(Key("sound"), value ? 1 : 0); PlayerPrefs.Save(); } }
        public static bool GmUnlimited { get => PlayerPrefs.GetInt(Key("gm_unlimited"),0)==1; set {PlayerPrefs.SetInt(Key("gm_unlimited"),value?1:0);PlayerPrefs.Save();} }
        static string Today => DateTime.Now.ToString("yyyy-MM-dd");
        public static int Daily
        {
            get => PlayerPrefs.GetString(Key("day"), "") == Today ? Mathf.Max(0, PlayerPrefs.GetInt(Key("daily"), 3)) : 3;
            set { PlayerPrefs.SetString(Key("day"), Today); PlayerPrefs.SetInt(Key("daily"), Mathf.Max(0, value)); PlayerPrefs.Save(); }
        }
        public static int Difficulty { get => Mathf.Clamp(PlayerPrefs.GetInt(Key("difficulty"), 0), 0, 2); set { PlayerPrefs.SetInt(Key("difficulty"), Mathf.Clamp(value, 0, 2)); PlayerPrefs.Save(); } }
        public static int StoryStage(string theme)=>Mathf.Clamp(PlayerPrefs.GetInt(Key("story1_stage_"+theme),0),0,1);
        public static bool TutorialComplete(string theme)=>PlayerPrefs.GetInt(Key("story1_intro_"+theme),0)==1;
        public static bool ChallengeComplete(string theme)=>PlayerPrefs.GetInt(Key("story1_challenge_"+theme),0)==1;
        public static void SelectStoryStage(string theme,int stage){PlayerPrefs.SetInt(Key("story1_stage_"+theme),Mathf.Clamp(stage,0,1));PlayerPrefs.Save();}
        public static void CompleteStoryStage(string theme,int stage)
        {PlayerPrefs.SetInt(Key((stage==0?"story1_intro_":"story1_challenge_")+theme),1);SelectStoryStage(theme,1);}
        public static BestRecord StoryBest(string theme,int stage)
        {try{return JsonUtility.FromJson<BestRecord>(PlayerPrefs.GetString(Key($"story1_best_{theme}_{stage}"),"{}"))??new BestRecord();}catch{return new BestRecord();}}
        public static void RecordStory(string theme,int stage,BestRecord next)
        {var old=StoryBest(theme,stage);if(next.progress>old.progress||(Mathf.Approximately(next.progress,old.progress)&&next.score>old.score)){PlayerPrefs.SetString(Key($"story1_best_{theme}_{stage}"),JsonUtility.ToJson(next));PlayerPrefs.Save();}}
        public static BestRecord Best(string theme, int difficulty)
        {
            try { return JsonUtility.FromJson<BestRecord>(PlayerPrefs.GetString(Key($"best_{theme}_{difficulty}"), "{}")) ?? new BestRecord(); }
            catch { return new BestRecord(); }
        }
        public static void Record(string theme, int difficulty, BestRecord next)
        {
            var old = Best(theme, difficulty);
            if (next.progress > old.progress || (Mathf.Approximately(next.progress, old.progress) && next.score > old.score))
            { PlayerPrefs.SetString(Key($"best_{theme}_{difficulty}"), JsonUtility.ToJson(next)); PlayerPrefs.Save(); }
        }
    }
}
