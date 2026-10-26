using System;
using UnityEditor;
using UnityEditor.Build.Reporting;
namespace CatchGoose.Editor
{
    public static class GooseHomeShakeBuild
    {
        public static void Qa()=>Build(true);
        public static void VideoQa()=>Build(true,"Builds/home-lighting-video-qa/catch-big-goose.exe");
        public static void Release()=>Build(false);
        public static void Deliver(){Build(true);Build(false);}
        static void Build(bool qa,string output=null)
        {
            GooseUiQualityBuild.Prepare();GooseProjectSetup.RepairMaterials();AssetDatabase.SaveAssets();
            string company=PlayerSettings.companyName;
            try
            {
                if(qa)PlayerSettings.companyName="GooseHomeShakeQA";
                var report=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},target=BuildTarget.StandaloneWindows64,
                    locationPathName=output??(qa?"Builds/home-lighting-shake-qa/catch-big-goose.exe":"Builds/Windows/catch-big-goose.exe"),options=qa?BuildOptions.Development:BuildOptions.None});
                if(report.summary.result!=BuildResult.Succeeded)throw new Exception("Home lighting/shake build failed");
            }finally{PlayerSettings.companyName=company;}
        }
    }
}
