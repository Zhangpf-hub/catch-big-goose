using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace CatchGoose
{
    [Serializable] public class ThemeCatalog { public ThemeDefinition[] themes; }
    [Serializable] public class ThemeDefinition
    {
        public string id, name, background, container;
        public string[] items;
        /** Own per-theme tuning; null means equal nominal weights, not recovered competitor values. */
        public float[] itemWeights;
        /** Optional group-count quotas, separate from the draw-order weights above.
         * Null retains equal stock; source names must be matched before copying values. */
        public float[] groupWeights;
        public bool circular;
        public float halfX, halfZ;
    }
    [Serializable] public class LevelDefinition
    {
        public int kinds, groups, seconds, frozen;
        public float layers;
        public uint seed;
        public bool golden;
        public static LevelDefinition At(int index)
        {
            switch (index)
            {
                case 0: return new LevelDefinition { kinds = 4, groups = 4, seconds = 255, layers = 3.1f, seed = 104729 };
                case 1: return new LevelDefinition { kinds = 6, groups = 3, seconds = 210, layers = 3.4f, seed = 130363, frozen = 4, golden = true };
                default: return new LevelDefinition { kinds = 9, groups = 3, seconds = 165, layers = 3.9f, seed = 155921, frozen = 7, golden = true };
            }
        }
        public int Total => kinds * groups * 3;
        public List<string> MakeQueue(ThemeDefinition theme, DeterministicRandom random, bool weighted = true)
        {
            if (weighted)
            {
                var queue = FinitePileGenerator.Build(theme.items, kinds, groups, theme.itemWeights, random.Next, theme.groupWeights);
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
        public static string Theme { get => PlayerPrefs.GetString(Key("theme"), "fruit"); set { PlayerPrefs.SetString(Key("theme"), value); PlayerPrefs.Save(); } }
        public static bool Onboarded { get => PlayerPrefs.GetInt(Key("onboarded"), 0) == 1; set { PlayerPrefs.SetInt(Key("onboarded"), value ? 1 : 0); PlayerPrefs.Save(); } }
        public static bool Sound { get => PlayerPrefs.GetInt(Key("sound"), 0) == 1; set { PlayerPrefs.SetInt(Key("sound"), value ? 1 : 0); PlayerPrefs.Save(); } }
        static string Today => DateTime.Now.ToString("yyyy-MM-dd");
        public static int Daily
        {
            get => PlayerPrefs.GetString(Key("day"), "") == Today ? Mathf.Max(0, PlayerPrefs.GetInt(Key("daily"), 3)) : 3;
            set { PlayerPrefs.SetString(Key("day"), Today); PlayerPrefs.SetInt(Key("daily"), Mathf.Max(0, value)); PlayerPrefs.Save(); }
        }
        public static int Difficulty { get => Mathf.Clamp(PlayerPrefs.GetInt(Key("difficulty"), 0), 0, 2); set { PlayerPrefs.SetInt(Key("difficulty"), Mathf.Clamp(value, 0, 2)); PlayerPrefs.Save(); } }
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
