using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;
namespace CatchGoose.Editor
{
    public static class GooseStoryBuild
    {
        public static void Prepare()
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);GooseProjectSetup.RepairMaterials();
            var themes=JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
            foreach(var theme in themes)
            {
                foreach(var id in theme.items.Concat(new[]{theme.container}))
                    if(!Resources.Load<GameObject>("Models/"+id+"/"+id))throw new Exception("Incomplete source assets: "+id);
                BakeContact(theme);
            }
            GoosePhysicsBake.Build();AssetDatabase.SaveAssets();
        }
        static void Box(List<Vector3> vertices,List<int> triangles,Vector3 center,Vector3 size,Quaternion rotation)
        {
            int start=vertices.Count;for(int i=0;i<8;i++)vertices.Add(center+rotation*Vector3.Scale(size,new Vector3((i&1)==0?-.5f:.5f,(i&2)==0?-.5f:.5f,(i&4)==0?-.5f:.5f)));
            foreach(int i in new[]{0,2,3,0,3,1,4,5,7,4,7,6,0,1,5,0,5,4,2,6,7,2,7,3,0,4,6,0,6,2,1,3,7,1,7,5})triangles.Add(start+i);
        }
        static void BakeContact(ThemeDefinition theme)
        {
            var v=new List<Vector3>();var t=new List<int>();Box(v,t,new Vector3(0,-.015f,0),new Vector3(1,.03f,1),Quaternion.identity);
            int n=theme.circular?24:4;
            for(int i=0;i<n;i++)
            {
                float a=i*360f/n;var q=Quaternion.Euler(0,a,0);
                Box(v,t,q*new Vector3(0,.025f,.48f),new Vector3(theme.circular?.13f:1,.08f,.04f),q);
            }
            var mesh=new Mesh{name=theme.container+"_Contact"};mesh.SetVertices(v);mesh.SetTriangles(t,0);mesh.RecalculateBounds();float scale=1/Mathf.Max(mesh.bounds.size.x,mesh.bounds.size.z);
            mesh.vertices=v.Select(x=>x*scale).ToArray();mesh.RecalculateBounds();
            Directory.CreateDirectory("Assets/Resources/ContainerPhysics");string path="Assets/Resources/ContainerPhysics/"+theme.container+".asset";
            var old=AssetDatabase.LoadAssetAtPath<Mesh>(path);if(old){EditorUtility.CopySerialized(mesh,old);UnityEngine.Object.DestroyImmediate(mesh);}else AssetDatabase.CreateAsset(mesh,path);
        }
        static void BuildProof(string path)
        {
            Prepare();string company=PlayerSettings.companyName;
            try{PlayerSettings.companyName="GooseStoryQA_"+new DirectoryInfo(Path.GetDirectoryName(path)).Name;Build(path,BuildOptions.Development);}
            finally{PlayerSettings.companyName=company;}
        }
        public static void Preview(){BuildProof("Builds/StoryPreview/CatchGoose.exe");}
        public static void Validation(){BuildProof("Builds/StoryFinalQA/CatchGoose.exe");}
        public static void FinalPackages(){Prepare();GooseProjectSetup.Audit();Build("Builds/StoryFinalQA/CatchGoose.exe",BuildOptions.Development);Build("Builds/Windows/catch-big-goose.exe",BuildOptions.None);}
        public static void Release(){Prepare();GooseProjectSetup.Audit();Build("Builds/Windows/catch-big-goose.exe",BuildOptions.None);}
        static void Build(string path,BuildOptions options)
        {
            string before=SourceSnapshot();
            var r=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName=path,target=BuildTarget.StandaloneWindows64,options=options});
            if(r.summary.result!=BuildResult.Succeeded)throw new Exception("Story build failed");
            string after=SourceSnapshot();if(before!=after)throw new Exception("Source changed during build; rebuild the current saved version.");
            Directory.CreateDirectory("../../work/two-stage-20261025");
            File.WriteAllText("../../work/two-stage-20261025/"+new DirectoryInfo(Path.GetDirectoryName(path)).Name+"-sources.json",before);
        }
        static string SourceSnapshot()
        {
            var files=Directory.GetFiles("Assets/Scripts","*.cs",SearchOption.AllDirectories).Concat(Directory.GetFiles("Assets/Resources/Data","*.json")).OrderBy(p=>p);
            var result=new SortedDictionary<string,string>();using(var sha=SHA256.Create())foreach(var file in files)result[file]=BitConverter.ToString(sha.ComputeHash(File.ReadAllBytes(file))).Replace("-","").ToLowerInvariant();
            return Newtonsoft.Json.JsonConvert.SerializeObject(result,Newtonsoft.Json.Formatting.Indented);
        }
    }
}
