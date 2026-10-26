using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Profiling;

namespace CatchGoose.Editor
{
    public static class GooseDeviceAudit
    {
        [Serializable] public class Model
        {
            public string id, path;
            public int renderers, materials, drawSlots, vertices, triangles, readableMeshes;
            public long textureBytes, meshBytes;
            public Vector3 dimensions;
        }
        [Serializable] class Round { public string theme; public int count, triangles, drawSlots; }
        [Serializable] class Report
        {
            public string scope = "Imported Unity meshes and source quotas; drawSlots are unculled renderer/submesh submissions, not measured GPU draw calls";
            public List<Model> models = new List<Model>(); public List<Round> rounds = new List<Round>();
        }
        public static Model Measure(string id, string path, GameObject prefab)
        {
            var m = new Model { id=id,path=path };
            var obj=UnityEngine.Object.Instantiate(prefab);
            try
            {
                m.dimensions=GooseGame.BoundsOf(obj).size;
                var materials=new HashSet<Material>(); var textures=new HashSet<Texture>(); var meshes=new HashSet<Mesh>();
                foreach(var r in obj.GetComponentsInChildren<Renderer>())
                {
                    m.renderers++; m.drawSlots+=r.sharedMaterials.Length;
                    foreach(var material in r.sharedMaterials) if(material) { materials.Add(material); if(material.mainTexture)textures.Add(material.mainTexture); }
                }
                foreach(var f in obj.GetComponentsInChildren<MeshFilter>()) if(f.sharedMesh)
                {
                    var mesh=f.sharedMesh; meshes.Add(mesh); m.vertices+=mesh.vertexCount;
                    for(int i=0;i<mesh.subMeshCount;i++)m.triangles+=(int)mesh.GetIndexCount(i)/3;
                    if(mesh.isReadable)m.readableMeshes++;
                }
                m.materials=materials.Count;
                foreach(var t in textures)m.textureBytes+=Profiler.GetRuntimeMemorySizeLong(t);
                foreach(var mesh in meshes)m.meshBytes+=Profiler.GetRuntimeMemorySizeLong(mesh);
            }
            finally { UnityEngine.Object.DestroyImmediate(obj); }
            return m;
        }
        public static void Export()
        {
            var report=new Report();
            var themes=JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
            foreach(var id in themes.SelectMany(t=>t.items.Concat(new[]{t.container})).Distinct())
            {
                var prefab=Resources.Load<GameObject>("Models/"+id+"/"+id);
                report.models.Add(Measure(id,AssetDatabase.GetAssetPath(prefab),prefab));
            }
            var core=JsonUtility.FromJson<CoreRoundCatalog>(Resources.Load<TextAsset>("Data/core-rounds").text);
            var settings=JsonUtility.FromJson<PileAlgorithmSettings>(Resources.Load<TextAsset>("Data/pile-algorithms").text);
            foreach(var theme in themes)
            {
                var level=core.Create(2); var queue=level.MakeQueue(theme,new DeterministicRandom(level.seed),settings.weightedGeneration);
                var row=new Round{theme=theme.id,count=queue.Count};
                foreach(var id in queue) { var m=report.models.First(x=>x.id==id); row.triangles+=m.triangles;row.drawSlots+=m.drawSlots; }
                report.rounds.Add(row);
            }
            string path=Path.GetFullPath("../../work/device-profile-20261024/asset-audit.json");
            Directory.CreateDirectory(Path.GetDirectoryName(path));File.WriteAllText(path,JsonUtility.ToJson(report,true));
            Debug.Log("[DeviceAudit] "+path);
        }
    }
}
