using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;
using Object=UnityEngine.Object;
namespace CatchGoose.Editor
{
    public static class DuckB2GameplayBuild
    {
        static readonly string[] Ids={"duck-eggtart","duck-steelcup","duck-numberblock"};
        public static void Build()
        {
            if(Application.unityVersion!="2022.3.62f3")throw new Exception("Unexpected Unity version");
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            var shader=Resources.Load<Shader>("GooseDuckMobile");
            if(!shader||!shader.isSupported)throw new Exception("Duck shader unavailable");
            foreach(string id in Ids)
            {
                string folder="Assets/Resources/Models/"+id;
                foreach(string name in new[]{"albedo.png","unity-metallic.png"})
                {
                    var t=(TextureImporter)AssetImporter.GetAtPath(folder+"/"+name);
                    t.sRGBTexture=name=="albedo.png";t.maxTextureSize=256;t.textureCompression=TextureImporterCompression.Uncompressed;
                    t.mipmapEnabled=false;t.filterMode=FilterMode.Point;t.wrapMode=TextureWrapMode.Clamp;t.alphaSource=TextureImporterAlphaSource.FromInput;t.SaveAndReimport();
                }
                var mat=AssetDatabase.LoadAssetAtPath<Material>(folder+"/duck-mobile.mat");
                if(!mat){mat=new Material(shader);AssetDatabase.CreateAsset(mat,folder+"/duck-mobile.mat");}
                mat.shader=shader;mat.mainTexture=AssetDatabase.LoadAssetAtPath<Texture2D>(folder+"/albedo.png");mat.color=Color.white;
                mat.SetTexture("_MetallicGlossMap",AssetDatabase.LoadAssetAtPath<Texture2D>(folder+"/unity-metallic.png"));mat.enableInstancing=true;EditorUtility.SetDirty(mat);
                string fbx=folder+"/"+id+".fbx";var importer=(ModelImporter)AssetImporter.GetAtPath(fbx);
                importer.importAnimation=false;importer.isReadable=true;importer.importCameras=false;importer.importLights=false;importer.meshCompression=ModelImporterMeshCompression.Off;importer.SaveAndReimport();
                var prefab=AssetDatabase.LoadAssetAtPath<GameObject>(fbx);
                foreach(string name in prefab.GetComponentsInChildren<Renderer>().SelectMany(r=>r.sharedMaterials).Select(m=>m.name).Distinct())
                    importer.AddRemap(new AssetImporter.SourceAssetIdentifier(typeof(Material),name),mat);
                importer.SaveAndReimport();
                string hullPath="Assets/duck-collision-inputs/"+id+"-collision.fbx";
                var hullImporter=(ModelImporter)AssetImporter.GetAtPath(hullPath);hullImporter.isReadable=true;hullImporter.importAnimation=false;hullImporter.SaveAndReimport();
                var hull=Object.Instantiate(AssetDatabase.LoadAssetAtPath<GameObject>(hullPath));
                var mesh=new Mesh{name=id+"_Physics"};mesh.CombineMeshes(hull.GetComponentsInChildren<MeshFilter>().Select(f=>new CombineInstance{mesh=f.sharedMesh,transform=f.transform.localToWorldMatrix}).ToArray(),true,true);
                mesh.RecalculateBounds();Object.DestroyImmediate(hull);
                string dest="Assets/Resources/Physics/"+id+".asset";var existing=AssetDatabase.LoadAssetAtPath<Mesh>(dest);
                if(existing){EditorUtility.CopySerialized(mesh,existing);Object.DestroyImmediate(mesh);}else AssetDatabase.CreateAsset(mesh,dest);
            }
            PlayerSettings.companyName="DuckB2IsolatedQA";PlayerSettings.productName="DuckB2Review";
            PlayerSettings.SetScriptingBackend(BuildTargetGroup.Standalone,ScriptingImplementation.Mono2x);
            PlayerSettings.defaultScreenWidth=540;PlayerSettings.defaultScreenHeight=960;PlayerSettings.fullScreenMode=FullScreenMode.Windowed;
            PlayerSettings.runInBackground=true;AssetDatabase.SaveAssets();
            var result=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName="Builds/DuckB2QA.exe",target=BuildTarget.StandaloneWindows64,options=BuildOptions.Development});
            if(result.summary.result!=BuildResult.Succeeded)throw new Exception("Duck game QA build failed");
            File.WriteAllText("build-result.json",JsonUtility.ToJson(new BuildResultInfo{passed=true,bytes=(long)result.summary.totalSize,seconds=(float)result.summary.totalTime.TotalSeconds,unityVersion=Application.unityVersion},true));
        }
        [Serializable] class BuildResultInfo{public bool passed;public long bytes;public float seconds;public string unityVersion;}
    }
}
