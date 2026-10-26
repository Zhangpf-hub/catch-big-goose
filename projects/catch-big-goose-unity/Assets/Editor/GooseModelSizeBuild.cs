using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;

namespace CatchGoose.Editor
{
    public static class GooseModelSizeBuild
    {
        public static void Release()
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            string output = Path.Combine(GooseWorkspace.Root, "work/model-size-20261026/release/catch-big-goose.exe");
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-sizeReleasePlayer");
            if(at>=0)output=Path.GetFullPath(args[at+1]);
            Directory.CreateDirectory(Path.GetDirectoryName(output));
            var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions { scenes = new[] { "Assets/Scenes/Main.unity" },
                locationPathName = output, target = BuildTarget.StandaloneWindows64, options = BuildOptions.None });
            if (report.summary.result != BuildResult.Succeeded) throw new Exception("Model size Windows build failed");
        }
    }
}
