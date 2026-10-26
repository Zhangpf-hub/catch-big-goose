using System;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;
namespace CatchGoose.Editor
{
    public static class GooseUiQualityBuild
    {
        public static void Prepare()
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            foreach(string name in new[]{"Chinese","Chinese-Bold"})
            {
                var font=(TrueTypeFontImporter)AssetImporter.GetAtPath("Assets/Resources/Fonts/"+name+".otf");
                string family=name=="Chinese"?"Goose UI CJK":"Goose UI CJK Bold";
                if(!font.fontNames.SequenceEqual(new[]{family})||font.fontRenderingMode!=FontRenderingMode.Smooth)
                {font.fontNames=new[]{family};font.fontRenderingMode=FontRenderingMode.Smooth;font.SaveAndReimport();}
            }
            foreach(string folder in new[]{"ui-candy-v2","story-ui","control-labels"})
                foreach(string file in Directory.GetFiles("Assets/Resources/Textures/"+folder,"*.png"))AssetDatabase.ImportAsset(file,ImportAssetOptions.ForceUpdate);
            foreach(string file in Directory.GetFiles("Assets/Resources/Icons","*.png"))AssetDatabase.ImportAsset(file,ImportAssetOptions.ForceUpdate);
            AssetDatabase.SaveAssets();
        }
        public static void Qa(){Prepare();Build("Builds/UIQualityQA/CatchGoose.exe",BuildOptions.Development);}
        public static void Release(){Prepare();Build("Builds/Windows/catch-big-goose.exe",BuildOptions.None);}
        public static void Deliver(){Qa();Release();}
        static string Snapshot()
        {
            var files=Directory.GetFiles("Assets/Scripts","*.cs").Concat(Directory.GetFiles("Assets/Resources/Data","*.json"))
                .Concat(Directory.GetFiles("Assets/Resources/Textures/ui-candy-v2","*"))
                .Concat(new[]{"ProjectSettings/QualitySettings.asset","Assets/Editor/GooseAssetImporter.cs","Assets/Editor/GooseWeChatBuild.cs"});
            using(var sha=SHA256.Create())return Newtonsoft.Json.JsonConvert.SerializeObject(files.OrderBy(p=>p).ToDictionary(p=>p,p=>BitConverter.ToString(sha.ComputeHash(File.ReadAllBytes(p))).Replace("-","").ToLowerInvariant()),Newtonsoft.Json.Formatting.Indented);
        }
        static void Build(string path,BuildOptions options)
        {
            string source=Snapshot(),company=PlayerSettings.companyName;
            try
            {
                if(options.HasFlag(BuildOptions.Development))PlayerSettings.companyName="GooseUiQualityQA";
                var report=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName=path,target=BuildTarget.StandaloneWindows64,options=options});
                if(report.summary.result!=BuildResult.Succeeded)throw new Exception("UI quality build failed");
                if(source!=Snapshot())throw new Exception("Sources changed during UI quality build");
                Directory.CreateDirectory("../../work/detail-polish-20261025");File.WriteAllText("../../work/detail-polish-20261025/"+new DirectoryInfo(Path.GetDirectoryName(path)).Name+"-sources.json",source);
            }
            finally{PlayerSettings.companyName=company;}
        }
    }
}
