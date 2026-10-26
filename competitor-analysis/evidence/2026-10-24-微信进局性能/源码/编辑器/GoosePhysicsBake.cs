using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
namespace CatchGoose.Editor
{
    public static class GoosePhysicsBake
    {
        // Same directional proxy as the former runtime path, now authored once.
        public static void Build()
        {
            Directory.CreateDirectory("Assets/Resources/Physics");
            const string mobileMaterialPath = "Assets/Resources/GooseMobileTemplate.mat";
            if (!AssetDatabase.LoadAssetAtPath<Material>(mobileMaterialPath))
            {
                var template = new Material(Resources.Load<Shader>("GooseItemMobile")) { enableInstancing = true };
                AssetDatabase.CreateAsset(template, mobileMaterialPath);
            }
            var themes=JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
            foreach(var id in themes.SelectMany(t=>t.items).Concat(new[]{"goose"}).Distinct())
            {
                string source="Assets/Resources/Models/"+id+"/"+id+".fbx",path="Assets/Resources/Physics/"+id+".asset";
                string hash=AssetDatabase.GetAssetDependencyHash(source).ToString();
                var existing=AssetDatabase.LoadAssetAtPath<Mesh>(path);
                if(existing && AssetImporter.GetAtPath(path).userData=="directional-v1:"+hash)continue;
                var prefab=AssetDatabase.LoadAssetAtPath<GameObject>(source);var wrapper=new GameObject("PhysicsBake");
                try
                {
                    var obj=UnityEngine.Object.Instantiate(prefab,wrapper.transform);obj.transform.localPosition=Vector3.zero;
                    var bounds=GooseGame.BoundsOf(obj);float max=Mathf.Max(bounds.size.x,bounds.size.y,bounds.size.z);
                    obj.transform.localScale/=max;obj.transform.localPosition-=bounds.center/max;
                    var mesh=new Mesh{name=id+"_Physics",indexFormat=UnityEngine.Rendering.IndexFormat.UInt32};
                    mesh.CombineMeshes(obj.GetComponentsInChildren<MeshFilter>().Select(f=>new CombineInstance{mesh=f.sharedMesh,transform=wrapper.transform.worldToLocalMatrix*f.transform.localToWorldMatrix}).ToArray(),true,true);
                    var buckets=new Dictionary<int,Vector3>();
                    foreach(var v in mesh.vertices)
                    {
                        if(v.magnitude<.00001f)continue;
                        int a=Mathf.Clamp((int)((Mathf.Atan2(v.z,v.x)+Mathf.PI)/(2*Mathf.PI)*10),0,9);
                        int b=Mathf.Clamp((int)(Mathf.Acos(Mathf.Clamp(v.y/v.magnitude,-1,1))/Mathf.PI*10),0,9),key=a*10+b;
                        if(!buckets.TryGetValue(key,out var old)||v.sqrMagnitude>old.sqrMagnitude)buckets[key]=v;
                    }
                    var vertices=buckets.Values.ToArray();if(vertices.Length<4)throw new Exception("Invalid hull "+id);
                    mesh.Clear();mesh.vertices=vertices;var tris=new List<int>();for(int i=1;i+1<vertices.Length;i++){tris.Add(0);tris.Add(i);tris.Add(i+1);}mesh.triangles=tris.ToArray();mesh.RecalculateBounds();
                    if(existing){EditorUtility.CopySerialized(mesh,existing);UnityEngine.Object.DestroyImmediate(mesh);}else AssetDatabase.CreateAsset(mesh,path);
                    AssetDatabase.SaveAssets();var importer=AssetImporter.GetAtPath(path);importer.userData="directional-v1:"+hash;importer.SaveAndReimport();
                }
                finally{UnityEngine.Object.DestroyImmediate(wrapper);}
            }
            AssetDatabase.SaveAssets();Debug.Log("[GoosePhysicsBake] Normalized small hull assets ready; render meshes are never read by gameplay");
        }
    }
}
