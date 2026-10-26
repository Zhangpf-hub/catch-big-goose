using System;
using UnityEditor;
using UnityEditor.Build.Reporting;
namespace CatchGoose.Editor
{
    public static class GooseDeviceBuild
    {
        public static void Baseline(){Build("Builds/DeviceBaseline/CatchGoose.exe");}
        public static void Optimized(){Build("Builds/DeviceOptimized/CatchGoose.exe");}
        static void Build(string path)
        {
            GooseProjectSetup.Prepare();
            var report=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName=path,
                target=BuildTarget.StandaloneWindows64,options=BuildOptions.Development});
            if(report.summary.result!=BuildResult.Succeeded)throw new Exception("Device benchmark build failed");
        }
    }
}
