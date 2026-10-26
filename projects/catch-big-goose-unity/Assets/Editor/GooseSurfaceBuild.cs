using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace CatchGoose.Editor
{
    public static class GooseSurfaceBuild
    {
        public static void Qa()=>Build(true);
        public static void Release()=>Build(false);
        static void Build(bool qa)
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            string output=qa?"../../../work/mobile-surface-performance-20261026/player/catch-big-goose.exe":"../Builds/Windows/catch-big-goose.exe";
            output=Path.GetFullPath(Path.Combine(Application.dataPath,output));
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-surfacePlayer");
            if(at>=0)output=args[at+1];
            Directory.CreateDirectory(Path.GetDirectoryName(output));
            string company=PlayerSettings.companyName;
            try
            {
                if(qa)PlayerSettings.companyName="GooseSurfaceQA";
                var result=BuildPipeline.BuildPlayer(new BuildPlayerOptions { scenes=new[]{"Assets/Scenes/Main.unity"},
                    locationPathName=output,target=BuildTarget.StandaloneWindows64,options=qa?BuildOptions.Development:BuildOptions.None });
                if(result.summary.result!=BuildResult.Succeeded)throw new Exception("Surface performance build failed");
            }
            finally {PlayerSettings.companyName=company;}
        }
    }
}
