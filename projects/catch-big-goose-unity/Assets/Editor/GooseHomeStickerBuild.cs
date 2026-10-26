using System;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using UnityEditor;
using UnityEditor.Build.Reporting;
namespace CatchGoose.Editor
{
    public static class GooseHomeStickerBuild
    {
        public static void Deliver(){GooseUiQualityBuild.Prepare();Build("Builds/HomeStickerQA/CatchGoose.exe",true);Build("Builds/Windows/catch-big-goose.exe",false);}
        public static void Qa(){GooseUiQualityBuild.Prepare();Build("Builds/HomeStickerQA/CatchGoose.exe",true);}
        static string Snapshot()
        {
            var paths=Directory.GetFiles("Assets/Scripts","*.cs").Concat(Directory.GetFiles("Assets/Resources/Data","*.json"))
                .Concat(Directory.GetFiles("Assets/Resources/Textures/mobile-ui/themes","*"))
                .Concat(Directory.GetFiles("Assets/Resources/Textures/ui-candy-v2","*")).Concat(Directory.GetFiles("Assets/Resources/Textures/home-stickers-v2","*"));
            using(var sha=SHA256.Create())return Newtonsoft.Json.JsonConvert.SerializeObject(paths.OrderBy(x=>x).ToDictionary(x=>x,x=>BitConverter.ToString(sha.ComputeHash(File.ReadAllBytes(x))).Replace("-","").ToLowerInvariant()),Newtonsoft.Json.Formatting.Indented);
        }
        static void Build(string path,bool qa)
        {
            string before=Snapshot(),company=PlayerSettings.companyName;
            try
            {
                if(qa)PlayerSettings.companyName="GooseHomeStickerQA";
                var report=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName=path,target=BuildTarget.StandaloneWindows64,options=qa?BuildOptions.Development:BuildOptions.None});
                if(report.summary.result!=BuildResult.Succeeded)throw new Exception("Home art build failed");
                if(before!=Snapshot())throw new Exception("Sources changed during build");
                string output=Path.Combine(GooseWorkspace.Root,"work/home-stickers-20261025");Directory.CreateDirectory(output);File.WriteAllText(Path.Combine(output,qa?"qa-sources.json":"windows-sources.json"),before);
            }
            finally{PlayerSettings.companyName=company;}
        }
    }
}
