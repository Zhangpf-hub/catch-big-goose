using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
namespace CatchGoose.Editor
{
    public static class GooseDuckAudioBuild
    {
        public static void Qa()=>Build(true);
        public static void Release()=>Build(false);
        static void Build(bool qa)
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-duckAudioBuildOutput");
            if(at<0)throw new Exception("Missing -duckAudioBuildOutput");
            string path=args[at+1];Directory.CreateDirectory(Path.GetDirectoryName(path));
            string company=PlayerSettings.companyName;var backend=PlayerSettings.GetScriptingBackend(BuildTargetGroup.Standalone);
            try
            {
                if(qa)PlayerSettings.companyName="GooseDuckAudioQA";
                PlayerSettings.SetScriptingBackend(BuildTargetGroup.Standalone,ScriptingImplementation.Mono2x);PlayerSettings.runInBackground=true;
                var result=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName=path,
                    target=BuildTarget.StandaloneWindows64,options=qa?BuildOptions.Development:BuildOptions.None});
                if(result.summary.result!=BuildResult.Succeeded)throw new Exception("Duck audio build failed");
            }
            finally{PlayerSettings.companyName=company;PlayerSettings.SetScriptingBackend(BuildTargetGroup.Standalone,backend);}
        }
    }
}
