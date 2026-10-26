using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
namespace CatchGoose.Editor
{
    public static class GoosePileViewBuild
    {
        public static void Qa()=>Build(true);
        public static void Release()=>Build(false);
        static void Build(bool qa)
        {
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-gooseViewBuildOutput");
            if(at<0)throw new Exception("Missing -gooseViewBuildOutput");
            string path=args[at+1];Directory.CreateDirectory(Path.GetDirectoryName(path));
            PlayerSettings.runInBackground=true;
            var result=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName=path,
                target=BuildTarget.StandaloneWindows64,options=qa?BuildOptions.Development:BuildOptions.None});
            if(result.summary.result!=BuildResult.Succeeded)throw new Exception("Pile view build failed");
        }
    }
}
