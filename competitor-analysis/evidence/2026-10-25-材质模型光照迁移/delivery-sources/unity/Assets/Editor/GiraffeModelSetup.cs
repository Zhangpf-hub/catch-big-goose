using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
namespace CatchGoose.Editor
{
    public static class GiraffeModelSetup
    {
        public static void Prepare()
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            const string folder="Assets/Resources/Models/giraffe";
            var texture=AssetDatabase.LoadAssetAtPath<Texture2D>(folder+"/albedo.png");
            if(!texture)throw new Exception("Giraffe atlas missing");
            var mat=AssetDatabase.LoadAssetAtPath<Material>(folder+"/giraffe_mobile.mat");
            if(!mat){mat=new Material(Shader.Find("Standard"));AssetDatabase.CreateAsset(mat,folder+"/giraffe_mobile.mat");}
            mat.mainTexture=texture;mat.color=Color.white;mat.SetFloat("_Glossiness",.48f);mat.enableInstancing=true;EditorUtility.SetDirty(mat);
            var importer=(ModelImporter)AssetImporter.GetAtPath(folder+"/giraffe.fbx");
            importer.AddRemap(new AssetImporter.SourceAssetIdentifier(typeof(Material),"giraffe_mobile"),mat);importer.SaveAndReimport();
            var prefab=AssetDatabase.LoadAssetAtPath<GameObject>(folder+"/giraffe.fbx");
            var wrapper=new GameObject("GiraffeBake");var obj=UnityEngine.Object.Instantiate(prefab,wrapper.transform);
            var bounds=GooseGame.BoundsOf(obj);float scale=Mathf.Max(bounds.size.x,bounds.size.y,bounds.size.z);
            obj.transform.localScale/=scale;obj.transform.localPosition-=bounds.center/scale;
            var points=obj.GetComponentsInChildren<MeshFilter>().SelectMany(f=>f.sharedMesh.vertices.Select(v=>wrapper.transform.InverseTransformPoint(f.transform.TransformPoint(v)))).ToArray();
            // Directional support points form a small closed convex proxy after PhysX cooking.
            var hullPoints=new System.Collections.Generic.List<Vector3>();
            for(int a=0;a<12;a++)for(int b=0;b<7;b++)
            {
                float az=a*Mathf.PI/6,el=-Mathf.PI/2+b*Mathf.PI/6;
                var dir=new Vector3(Mathf.Cos(el)*Mathf.Cos(az),Mathf.Sin(el),Mathf.Cos(el)*Mathf.Sin(az));
                var v=points.OrderByDescending(p=>Vector3.Dot(p,dir)).First();if(!hullPoints.Contains(v))hullPoints.Add(v);
            }
            var mesh=new Mesh{name="giraffe_Physics"};mesh.vertices=hullPoints.ToArray();
            var indices=new System.Collections.Generic.List<int>();for(int i=1;i+1<hullPoints.Count;i++){indices.Add(0);indices.Add(i);indices.Add(i+1);}mesh.triangles=indices.ToArray();mesh.RecalculateBounds();
            const string physicsPath="Assets/Resources/Physics/giraffe.asset";var old=AssetDatabase.LoadAssetAtPath<Mesh>(physicsPath);
            if(old){EditorUtility.CopySerialized(mesh,old);UnityEngine.Object.DestroyImmediate(mesh);}else AssetDatabase.CreateAsset(mesh,physicsPath);
            UnityEngine.Object.DestroyImmediate(wrapper);
            const string homePath="Assets/Mascots/Giraffe/giraffe-home.fbx";
            var homeImporter=(ModelImporter)AssetImporter.GetAtPath(homePath);homeImporter.importAnimation=true;homeImporter.animationType=ModelImporterAnimationType.Legacy;homeImporter.importCameras=false;homeImporter.importLights=false;
            homeImporter.AddRemap(new AssetImporter.SourceAssetIdentifier(typeof(Material),"giraffe_mobile"),mat);homeImporter.SaveAndReimport();
            var home=UnityEngine.Object.Instantiate(AssetDatabase.LoadAssetAtPath<GameObject>(homePath));home.name="GiraffeHome";
            var animation=home.GetComponent<Animation>()??home.AddComponent<Animation>();
            var clips=AssetDatabase.LoadAllAssetsAtPath(homePath).OfType<AnimationClip>().Where(c=>!c.name.StartsWith("__preview__")).ToArray();
            foreach(var clip in clips){clip.wrapMode=clip.name.Contains("Idle")?WrapMode.Loop:WrapMode.Once;animation.AddClip(clip,clip.name);if(clip.name.Contains("Idle"))animation.clip=clip;}
            animation.playAutomatically=true;animation.wrapMode=WrapMode.Loop;
            if(clips.Length<3)throw new Exception("Expected Idle/Peek/Bounce, found "+string.Join(",",clips.Select(c=>c.name)));
            var skin=home.GetComponentInChildren<SkinnedMeshRenderer>();if(!skin)throw new Exception("Animated giraffe has no skinned mesh");
            foreach(var clip in clips)
            {
                var baked=new Mesh();clip.SampleAnimation(home,0);skin.BakeMesh(baked);var rest=baked.vertices;
                clip.SampleAnimation(home,clip.length*.32f);skin.BakeMesh(baked);var moved=baked.vertices;
                float motion=rest.Select((v,i)=>Vector3.Distance(v,moved[i])).Max();UnityEngine.Object.DestroyImmediate(baked);
                if(motion<.0001f)throw new Exception("Imported clip does not deform actual vertices: "+clip.name);
                Debug.Log("[GiraffeAnimation] "+clip.name+" vertex motion "+motion);
            }
            animation.clip.SampleAnimation(home,0);
            PrefabUtility.SaveAsPrefabAsset(home,"Assets/Mascots/Giraffe/GiraffeHome.prefab");UnityEngine.Object.DestroyImmediate(home);AssetDatabase.SaveAssets();
            string output="../assets-3d/candidates/giraffe-b-20261024-v1/qa/unity-import.json";
            File.WriteAllText(output,"{\"passed\":true,\"animationVertexDeformationVerified\":true,\"materials\":1,\"triangles\":"+prefab.GetComponentsInChildren<MeshFilter>().Sum(f=>f.sharedMesh.triangles.Length/3)+",\"physicsSupportPoints\":"+hullPoints.Count+",\"clips\":["+string.Join(",",clips.Select(c=>"\""+c.name+"\""))+"]}");
            Debug.Log("[Giraffe] Model, texture, collision proxy and animated prefab imported");
        }
        public static void BuildReview()
        {
            Prepare();
            var report=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName="Builds/GiraffeReview/GiraffeReview.exe",target=BuildTarget.StandaloneWindows64,options=BuildOptions.Development});
            if(report.summary.result!=UnityEditor.Build.Reporting.BuildResult.Succeeded)throw new Exception("Giraffe review build failed");
        }
    }
}
