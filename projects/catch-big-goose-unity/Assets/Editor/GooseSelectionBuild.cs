using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace CatchGoose.Editor
{
    public static class GooseSelectionBuild
    {
        public static void Qa()
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            var shader = Resources.Load<Shader>("GooseSelectionHighlight");
            if (!shader || ShaderUtil.ShaderHasError(shader)) throw new Exception("Selection shader import failed");
            string output = Path.GetFullPath(Path.Combine(Application.dataPath, "../../../work/selection-highlight-20261025/player/catch-big-goose.exe"));
            var args = Environment.GetCommandLineArgs(); int at = Array.IndexOf(args, "-selectionPlayer");
            if (at >= 0) output = args[at + 1];
            Directory.CreateDirectory(Path.GetDirectoryName(output));
            string company = PlayerSettings.companyName;
            try
            {
                PlayerSettings.companyName = "GooseSelectionQA"; PlayerSettings.runInBackground = true;
                var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions { scenes = new[] { "Assets/Scenes/Main.unity" },
                    locationPathName = output, target = BuildTarget.StandaloneWindows64, options = BuildOptions.Development });
                if (report.summary.result != BuildResult.Succeeded) throw new Exception("Selection QA build failed");
            }
            finally { PlayerSettings.companyName = company; }
        }
    }
}
