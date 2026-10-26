using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;
using Object=UnityEngine.Object;
namespace CatchGoose.Editor
{
    public static class GooseDuckProduction
    {
        public static readonly string Output=Path.GetFullPath("../../work/duck-series-unity-qa");
        public static string[] Ids=>JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/duck-review").text).themes.SelectMany(t=>t.items).ToArray();
        static void Texture(string path,bool srgb)
        {
            var t=(TextureImporter)AssetImporter.GetAtPath(path);t.sRGBTexture=srgb;t.maxTextureSize=256;
            t.textureCompression=TextureImporterCompression.Uncompressed;t.mipmapEnabled=false;t.filterMode=FilterMode.Point;
            t.wrapMode=TextureWrapMode.Clamp;t.alphaSource=TextureImporterAlphaSource.FromInput;t.SaveAndReimport();
        }
        static void Import(string path,Material mat,bool animated)
        {
            var imp=(ModelImporter)AssetImporter.GetAtPath(path);imp.importCameras=false;imp.importLights=false;imp.isReadable=true;
            imp.meshCompression=ModelImporterMeshCompression.Off;imp.importAnimation=animated;
            imp.animationType=animated?ModelImporterAnimationType.Legacy:ModelImporterAnimationType.None;
            imp.animationCompression=ModelImporterAnimationCompression.Off;imp.SaveAndReimport();
            if(!mat)return;
            var obj=AssetDatabase.LoadAssetAtPath<GameObject>(path);
            foreach(string name in obj.GetComponentsInChildren<Renderer>().SelectMany(r=>r.sharedMaterials).Where(m=>m).Select(m=>m.name).Distinct())
                imp.AddRemap(new AssetImporter.SourceAssetIdentifier(typeof(Material),name),mat);
            imp.SaveAndReimport();
        }
        [MenuItem("Goose/Prepare B2 Duck Production")]
        public static void Prepare()
        {
            if(Application.unityVersion!="2022.3.62f3")throw new Exception("Unexpected Unity version");
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);Directory.CreateDirectory(Output);
            var shader=Resources.Load<Shader>("GooseDuckMobile");if(!shader||!shader.isSupported)throw new Exception("Duck shader unavailable");
            foreach(string id in Ids)
            {
                string folder="Assets/Resources/Models/"+id;Texture(folder+"/albedo.png",true);Texture(folder+"/unity-metallic.png",false);
                string mp=folder+"/duck-mobile.mat";var mat=AssetDatabase.LoadAssetAtPath<Material>(mp);
                if(!mat){mat=new Material(shader);AssetDatabase.CreateAsset(mat,mp);}mat.shader=shader;mat.color=Color.white;
                mat.mainTexture=AssetDatabase.LoadAssetAtPath<Texture2D>(folder+"/albedo.png");
                mat.SetTexture("_MetallicGlossMap",AssetDatabase.LoadAssetAtPath<Texture2D>(folder+"/unity-metallic.png"));mat.enableInstancing=true;EditorUtility.SetDirty(mat);
                Import(folder+"/"+id+".fbx",mat,false);
                string hp="Assets/duck-collision-inputs/"+id+"-collision.fbx";Import(hp,null,false);
                var hull=Object.Instantiate(AssetDatabase.LoadAssetAtPath<GameObject>(hp));
                var mesh=new Mesh{name=id+"_Physics"};mesh.CombineMeshes(hull.GetComponentsInChildren<MeshFilter>().Select(f=>new CombineInstance{mesh=f.sharedMesh,transform=f.transform.localToWorldMatrix}).ToArray(),true,true);
                mesh.RecalculateBounds();Object.DestroyImmediate(hull);
                string dest="Assets/Resources/Physics/"+id+".asset";var old=AssetDatabase.LoadAssetAtPath<Mesh>(dest);
                if(old){EditorUtility.CopySerialized(mesh,old);Object.DestroyImmediate(mesh);}else AssetDatabase.CreateAsset(mesh,dest);
                var icon=(TextureImporter)AssetImporter.GetAtPath("Assets/Resources/Icons/"+id+".png");
                icon.textureType=TextureImporterType.Sprite;icon.alphaIsTransparency=true;icon.mipmapEnabled=false;icon.maxTextureSize=256;icon.SaveAndReimport();
            }
            string home="Assets/duck-mascot-inputs",fbx=home+"/duck-home.fbx",mpath=home+"/duck-home.mat";
            Texture(home+"/albedo.png",true);var homeMat=AssetDatabase.LoadAssetAtPath<Material>(mpath);
            if(!homeMat){homeMat=new Material(Resources.Load<Shader>("GooseReferenceOpaque"));AssetDatabase.CreateAsset(homeMat,mpath);}
            homeMat.mainTexture=AssetDatabase.LoadAssetAtPath<Texture2D>(home+"/albedo.png");homeMat.color=Color.white;EditorUtility.SetDirty(homeMat);
            Import(fbx,homeMat,true);var instance=Object.Instantiate(AssetDatabase.LoadAssetAtPath<GameObject>(fbx));instance.name="DuckHome";
            var clips=AssetDatabase.LoadAllAssetsAtPath(fbx).OfType<AnimationClip>().Where(c=>!c.name.StartsWith("__preview__")).ToArray();
            if(clips.Length!=3)throw new Exception("B2 home must have exactly three clips");
            var player=instance.GetComponent<Animation>();if(!player)player=instance.AddComponent<Animation>();player.playAutomatically=false;
            var control=instance.AddComponent<GooseDuckMascot>();control.idle=clips.Single(c=>c.name.EndsWith("duck_idle"));
            control.greet=clips.Single(c=>c.name.EndsWith("duck_greet"));control.click=clips.Single(c=>c.name.EndsWith("duck_click"));
            player.clip=control.idle;foreach(var clip in clips)player.AddClip(clip,clip.name);
            instance.GetComponentInChildren<SkinnedMeshRenderer>().updateWhenOffscreen=true;
            PrefabUtility.SaveAsPrefabAsset(instance,"Assets/Resources/Mascots/DuckHome.prefab");Object.DestroyImmediate(instance);AssetDatabase.SaveAssets();
        }
        public static void BuildQa()
        {
            Prepare();if(!DuckSeriesUnityAudit.Run())throw new Exception("Duck editor audit failed");
            RebuildQa();
        }
        public static void RebuildQa()
        {
            string company=PlayerSettings.companyName,product=PlayerSettings.productName;
            var backend=PlayerSettings.GetScriptingBackend(BuildTargetGroup.Standalone);int w=PlayerSettings.defaultScreenWidth,h=PlayerSettings.defaultScreenHeight;
            var mode=PlayerSettings.fullScreenMode;bool background=PlayerSettings.runInBackground;
            try
            {
                PlayerSettings.companyName="DuckSeriesIsolatedQA";PlayerSettings.productName="DuckSeriesQA";
                PlayerSettings.SetScriptingBackend(BuildTargetGroup.Standalone,ScriptingImplementation.Mono2x);
                PlayerSettings.defaultScreenWidth=540;PlayerSettings.defaultScreenHeight=960;PlayerSettings.fullScreenMode=FullScreenMode.Windowed;PlayerSettings.runInBackground=true;
                var result=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName=Path.Combine(Output,"player/DuckSeriesQA.exe"),target=BuildTarget.StandaloneWindows64,options=BuildOptions.Development});
                if(result.summary.result!=BuildResult.Succeeded)throw new Exception("Duck development build failed");
                File.WriteAllText(Path.Combine(Output,"build-result.json"),JsonUtility.ToJson(new BuildInfo{passed=true,bytes=(long)result.summary.totalSize,seconds=(float)result.summary.totalTime.TotalSeconds,unityVersion=Application.unityVersion},true));
            }
            finally
            {
                PlayerSettings.companyName=company;PlayerSettings.productName=product;PlayerSettings.SetScriptingBackend(BuildTargetGroup.Standalone,backend);
                PlayerSettings.defaultScreenWidth=w;PlayerSettings.defaultScreenHeight=h;PlayerSettings.fullScreenMode=mode;PlayerSettings.runInBackground=background;AssetDatabase.SaveAssets();
            }
        }
        public static void DeliverWindows()
        {
            RebuildQa();GooseProjectSetup.BuildWindows();
            File.WriteAllText(Path.Combine(Output,"windows-release.json"),JsonUtility.ToJson(new BuildInfo{passed=true,bytes=new FileInfo("Builds/Windows/catch-big-goose.exe").Length,unityVersion=Application.unityVersion},true));
        }
        [Serializable] class BuildInfo{public bool passed;public long bytes;public float seconds;public string unityVersion;}
    }
}
