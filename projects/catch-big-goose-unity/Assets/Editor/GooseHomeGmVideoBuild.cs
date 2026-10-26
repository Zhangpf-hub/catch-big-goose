using System;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using UnityEditor;
using UnityEditor.Build.Reporting;
namespace CatchGoose.Editor
{
    public static class GooseHomeGmVideoBuild
    {
        static string Snapshot()
        {
            var files=Directory.GetFiles("Assets/Scripts","*.cs").Concat(Directory.GetFiles("Assets/Resources/Data","*.json"))
                .Concat(Directory.GetFiles("Assets/Plugins/WebGL","*.jslib"));
            using(var sha=SHA256.Create())return Newtonsoft.Json.JsonConvert.SerializeObject(files.OrderBy(p=>p).ToDictionary(p=>p,p=>BitConverter.ToString(sha.ComputeHash(File.ReadAllBytes(p))).Replace("-","").ToLowerInvariant()),Newtonsoft.Json.Formatting.Indented);
        }
        public static void Qa(){GooseUiQualityBuild.Prepare();Build("Builds/HomeGmVideoQA/CatchGoose.exe",BuildOptions.Development);}
        public static void Release(){GooseUiQualityBuild.Prepare();Build("Builds/Windows/catch-big-goose.exe",BuildOptions.None);}
        public static void Deliver(){Qa();Release();}
        static void Build(string path,BuildOptions options)
        {
            string before=Snapshot(),company=PlayerSettings.companyName;
            try
            {
                if(options.HasFlag(BuildOptions.Development))PlayerSettings.companyName="GooseHomeGmVideoQA";
                PlayerSettings.runInBackground=true;
                var result=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName=path,target=BuildTarget.StandaloneWindows64,options=options});
                if(result.summary.result!=BuildResult.Succeeded)throw new Exception("Home/GM/video build failed");
                if(before!=Snapshot())throw new Exception("Source changed during home/GM/video build");
                string output=Path.Combine(GooseWorkspace.Root,"work/home-gm-video-20261025");Directory.CreateDirectory(output);File.WriteAllText(Path.Combine(output,new DirectoryInfo(Path.GetDirectoryName(path)).Name+"-sources.json"),before);
            }
            finally{PlayerSettings.companyName=company;}
        }
    }
}
