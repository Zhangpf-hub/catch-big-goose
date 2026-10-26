using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;
namespace CatchGoose.Editor
{
    public static class GooseDuckRolloutBuild
    {
        public static readonly string Output=Path.GetFullPath("../../work/duck-live-two-themes");
        public static void Qa()=>Build(true);
        public static void Release()=>Build(false);
        public static void Deliver(){Build(true);Build(false);}
        static void Build(bool qa)
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);GooseProjectSetup.Audit();
            var themes=JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
            foreach(var theme in themes.Where(t=>t.id=="breakfast"||t.id=="barbecue"))
            {
                if(theme.items.Count(id=>id.StartsWith("duck-"))!=4||theme.items.Any(id=>id.StartsWith("ref_goose_")))throw new Exception("Incomplete duck rollout: "+theme.id);
                foreach(var id in theme.items.Where(id=>id.StartsWith("duck-")))
                    if(!Resources.Load<Mesh>("Physics/"+id))throw new Exception("Missing duck collision mesh "+id);
            }
            Directory.CreateDirectory(Output);
            string company=PlayerSettings.companyName,product=PlayerSettings.productName;
            var backend=PlayerSettings.GetScriptingBackend(BuildTargetGroup.Standalone);int w=PlayerSettings.defaultScreenWidth,h=PlayerSettings.defaultScreenHeight;var mode=PlayerSettings.fullScreenMode;
            try
            {
                if(qa){PlayerSettings.companyName="DuckTwoThemesQA";PlayerSettings.productName="DuckTwoThemesQA";}
                PlayerSettings.SetScriptingBackend(BuildTargetGroup.Standalone,ScriptingImplementation.Mono2x);
                PlayerSettings.defaultScreenWidth=450;PlayerSettings.defaultScreenHeight=844;PlayerSettings.fullScreenMode=FullScreenMode.Windowed;PlayerSettings.runInBackground=true;
                string path=Path.Combine(Output,qa?"qa-player/DuckTwoThemesQA.exe":"release/catch-big-goose.exe");
                var result=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName=path,target=BuildTarget.StandaloneWindows64,options=qa?BuildOptions.Development:BuildOptions.None});
                if(result.summary.result!=BuildResult.Succeeded)throw new Exception("Duck two-theme build failed");
                File.WriteAllText(Path.Combine(Output,qa?"qa-build.json":"release-build.json"),JsonUtility.ToJson(new Result{passed=true,unityVersion=Application.unityVersion,bytes=(long)result.summary.totalSize,seconds=(float)result.summary.totalTime.TotalSeconds},true));
            }
            finally{PlayerSettings.companyName=company;PlayerSettings.productName=product;PlayerSettings.SetScriptingBackend(BuildTargetGroup.Standalone,backend);PlayerSettings.defaultScreenWidth=w;PlayerSettings.defaultScreenHeight=h;PlayerSettings.fullScreenMode=mode;AssetDatabase.SaveAssets();}
        }
        [Serializable]class Result{public bool passed;public string unityVersion;public long bytes;public float seconds;}
    }
}
