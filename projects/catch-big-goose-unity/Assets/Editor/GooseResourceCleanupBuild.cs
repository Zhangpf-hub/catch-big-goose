using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
namespace CatchGoose.Editor
{
    public static class GooseResourceCleanupBuild
    {
        [Serializable] sealed class Policy { public string[] retiredModelIds,retiredPaths; }
        public static void CheckRetired()
        {
            const string file="Assets/Editor/retired-resources.json";
            if(!File.Exists(file))return;
            var policy=JsonUtility.FromJson<Policy>(File.ReadAllText(file));
            foreach(string path in policy.retiredModelIds.Select(id=>"Assets/Resources/Models/"+id).Concat(policy.retiredPaths))
                if(File.Exists(path)||Directory.Exists(path))throw new Exception("Retired resource was recreated: "+path);
        }
        public static void Qa()
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);CheckRetired();
            var themes=JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes
                .Concat(JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/duck-review").text).themes)
                .Concat(new[]{JsonUtility.FromJson<ReferenceLabCatalog>(Resources.Load<TextAsset>("Data/reference-lab").text).theme}).ToArray();
            var items=new HashSet<string>(themes.SelectMany(t=>t.items).Concat(new[]{"goose"}));
            foreach(string id in items)
            {
                if(!Resources.Load<GameObject>("Models/"+id+"/"+id)||!Resources.Load<Mesh>("Physics/"+id)||!Resources.Load<Sprite>("Icons/"+id))
                    throw new Exception("Live item resource missing: "+id);
            }
            var staticModels=themes.Select(t=>t.container).Concat(new[]{"home-table","scene_breakfast","scene_toys","scene_grocery"}).Distinct();
            foreach(string id in staticModels)if(!Resources.Load<GameObject>("Models/"+id+"/"+id))throw new Exception("Live scene resource missing: "+id);
            int textureChecks=0;
            foreach(string file in Directory.GetFiles("Assets/Resources/Models","materials.json",SearchOption.AllDirectories))
            {
                var materials=JsonUtility.FromJson<MaterialList>(File.ReadAllText(file));
                foreach(var material in materials.materials)
                foreach(string path in new[]{material.texture,material.matcap,material.matcap1,material.matcap2,material.mask,material.aoMap})
                {
                    if(string.IsNullOrEmpty(path)||!path.StartsWith("ReferenceTextures/"))continue;
                    textureChecks++;if(!AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Resources/"+path+".png"))throw new Exception("Live material texture missing: "+path);
                }
            }
            if(!Resources.Load<GameObject>("Mascots/DuckHome"))throw new Exception("Duck home mascot missing");
            foreach(string id in new[]{"bgm","pick","match","duck-quack-1","duck-quack-2","duck-quack-3"})
                if(!Resources.Load<AudioClip>("Audio/"+id))throw new Exception("Live sound missing: "+id);
            string output=Path.Combine(GooseWorkspace.Root,"work/resource-cleanup-20261026");Directory.CreateDirectory(output);
            File.WriteAllText(Path.Combine(output,"resource-audit.json"),Newtonsoft.Json.JsonConvert.SerializeObject(new{passed=true,themes=themes.Length,liveItems=items.Count,textureChecks,retiredResourcesAbsent=true},Newtonsoft.Json.Formatting.Indented));
            GooseDuckAudioBuild.Qa();
        }
    }
}
