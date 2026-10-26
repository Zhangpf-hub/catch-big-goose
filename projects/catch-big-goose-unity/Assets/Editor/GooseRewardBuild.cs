using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;

namespace CatchGoose.Editor
{
    public static class GooseRewardBuild
    {
        public static void Qa() { Build(true); }
        public static void Release() { Build(false); }
        static void Build(bool qa)
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            string company = PlayerSettings.companyName;
            try
            {
                if (qa) PlayerSettings.companyName = "GooseVideoRewardsQA";
                PlayerSettings.runInBackground = true;
                string path = qa ? "Builds/VideoRewardsQA/catch-big-goose.exe" : "Builds/Windows/catch-big-goose.exe";
                var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions {
                    scenes = new[] { "Assets/Scenes/Main.unity" }, locationPathName = path,
                    target = BuildTarget.StandaloneWindows64, options = qa ? BuildOptions.Development : BuildOptions.None });
                if (report.summary.result != BuildResult.Succeeded) throw new Exception("Video reward build failed");
            }
            finally { PlayerSettings.companyName = company; }
        }
    }
}
