using System;
using UnityEditor;
using UnityEditor.Build.Reporting;
namespace CatchGoose.Editor
{
    public static class CompetitorReplacementBuild
    {
        public static void Prepare()
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            GooseProjectSetup.RepairMaterials();
            GoosePhysicsBake.Build();
            GooseProjectSetup.Audit();
            AssetDatabase.SaveAssets();
        }
        public static void Qa() { Prepare(); Build("Builds/CompetitorQA/CatchGoose.exe",BuildOptions.Development); }
        public static void Release() { Prepare(); Build("Builds/Windows/CatchGoose.exe",BuildOptions.None); }
        static void Build(string path,BuildOptions options)
        {
            var report=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName=path,target=BuildTarget.StandaloneWindows64,options=options});
            if(report.summary.result!=BuildResult.Succeeded)throw new Exception("Competitor replacement build failed");
        }
    }
}
