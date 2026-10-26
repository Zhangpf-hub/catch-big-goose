using System;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace CatchGoose.Editor
{
    public static class GooseR4Build
    {
        public static void Import()
        {
            AssetDatabase.Refresh();
            string folder="Assets/Resources/Textures/mobile-ui/themes";
            foreach(var path in Directory.GetFiles(folder,"*.png"))
            {
                var importer=(TextureImporter)AssetImporter.GetAtPath(path);
                importer.textureType=TextureImporterType.Sprite;importer.spriteImportMode=SpriteImportMode.Single;
                importer.mipmapEnabled=false;importer.sRGBTexture=true;importer.maxTextureSize=2048;
                importer.alphaIsTransparency=false;importer.wrapMode=TextureWrapMode.Clamp;importer.isReadable=false;
                importer.alphaSource=TextureImporterAlphaSource.None;importer.textureCompression=TextureImporterCompression.Compressed;
                importer.crunchedCompression=true;importer.compressionQuality=80;
                importer.SaveAndReimport();
            }
            foreach(string theme in new[]{"breakfast","barbecue","countryside","toys","grocery"})
            {
                string id="round_"+theme+"_r4",path="Assets/Resources/Models/"+id+"/"+id+".fbx";
                var importer=(ModelImporter)AssetImporter.GetAtPath(path);
                importer.isReadable=true;importer.importAnimation=false;importer.materialImportMode=ModelImporterMaterialImportMode.ImportStandard;
                importer.materialLocation=ModelImporterMaterialLocation.External;importer.SaveAndReimport();
                var model=AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if(!model)throw new Exception("Container import failed: "+id);
                foreach(var renderer in model.GetComponentsInChildren<Renderer>())foreach(var material in renderer.sharedMaterials)
                {if(!material)throw new Exception("Missing container material "+id);material.shader=Resources.Load<Shader>("GooseReferenceOpaque");EditorUtility.SetDirty(material);}
            }
            AssetDatabase.SaveAssets();Debug.Log("[GooseR4] backgrounds and five circular containers imported");
        }
        public static void BuildQa()
        {
            Import();
            PlayerSettings.runInBackground=true;
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-gooseQaOutput");
            string output=at>=0?args[at+1]:"Builds/R4QA/CatchGooseR4QA.exe";
            var r=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName=output,target=BuildTarget.StandaloneWindows64,options=BuildOptions.Development});
            if(r.summary.result!=UnityEditor.Build.Reporting.BuildResult.Succeeded)throw new Exception("R4 QA build failed");
        }
        public static void BuildWindows()
        {
            Import();
            var r=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName="Builds/Windows/catch-big-goose.exe",target=BuildTarget.StandaloneWindows64,options=BuildOptions.None});
            if(r.summary.result!=UnityEditor.Build.Reporting.BuildResult.Succeeded)throw new Exception("R4 Windows build failed");
        }
    }
}
