using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
namespace CatchGoose.Editor
{
    public static class GooseReferenceImportAudit
    {
        [Serializable] class Row {public string id,material,sourceShader,unityShader;public int meshCount;public long triangles;public List<string> textures=new List<string>();}
        [Serializable] class Report {public bool passed;public List<Row> rows=new List<Row>();public List<string> errors=new List<string>();}
        public static void Run()
        {
            var report=new Report();var reference=JsonUtility.FromJson<ReferenceMaterialCatalog>(Resources.Load<TextAsset>("Data/reference-material-models").text);
            foreach(var model in reference.models)
            {
                string id=model.id;
                string folder="Assets/Resources/Models/"+id;
                var input=JsonUtility.FromJson<MaterialList>(File.ReadAllText(folder+"/materials.json"));
                var prefab=AssetDatabase.LoadAssetAtPath<GameObject>(folder+"/"+id+".fbx");
                var filters=prefab.GetComponentsInChildren<MeshFilter>();long triangles=0;
                foreach(var f in filters)
                {
                    triangles+=(long)f.sharedMesh.GetIndexCount(0)/3;
                    if(f.sharedMesh.normals.Length!=f.sharedMesh.vertexCount||f.sharedMesh.uv.Length!=f.sharedMesh.vertexCount)report.errors.Add(id+" normals/UV missing");
                }
                foreach(var source in input.materials)
                {
                    var mat=AssetDatabase.LoadAssetAtPath<Material>(folder+"/"+source.name+".mat");
                    var row=new Row{id=id,material=source.name,sourceShader=source.sourceShader,unityShader=mat.shader.name,meshCount=filters.Length,triangles=triangles};
                    var slots=new[]{"_MainTex","_Matcap","_Matcap1","_Matcap2","_MatcapMask","_AOMap"};
                    var paths=new[]{source.texture,source.matcap,source.matcap1,source.matcap2,source.mask,source.aoMap};
                    for(int i=0;i<slots.Length;i++)if(!string.IsNullOrEmpty(paths[i]))
                    {
                        string expected="Assets/Resources/"+paths[i]+".png";
                        if(AssetDatabase.GetAssetPath(mat.GetTexture(slots[i]))!=expected)report.errors.Add(source.name+" texture link "+slots[i]);
                        var importer=(TextureImporter)AssetImporter.GetAtPath(expected);
                        bool data=Path.GetFileName(expected).StartsWith("d_");if(importer.sRGBTexture==data)report.errors.Add(source.name+" color/data import mismatch");
                        if(importer.maxTextureSize!=1024||!importer.mipmapEnabled)report.errors.Add(source.name+" texture resolution/mipmap mismatch");
                        row.textures.Add(expected);
                    }
                    if(Mathf.Abs(mat.GetFloat("_MatcapStrength")-source.matcapScale)>.00001f)report.errors.Add(source.name+" source strength mismatch");
                    foreach(var message in ShaderUtil.GetShaderMessages(mat.shader))if(message.severity.ToString()=="Error")report.errors.Add(source.name+": "+message.message);
                    report.rows.Add(row);
                }
            }
            report.passed=report.rows.Count==reference.models.Sum(x=>x.materials)&&report.errors.Count==0;
            string output=Path.GetFullPath("../../work/reference-look-20261025/import-audit.json");Directory.CreateDirectory(Path.GetDirectoryName(output));File.WriteAllText(output,JsonUtility.ToJson(report,true));
            if(!report.passed)throw new Exception("Reference import audit failed: "+string.Join(";",report.errors));
            Debug.Log("[GooseReference] Original UV/normals, "+report.rows.Count+" material links, texture color spaces and shader compilation passed.");
        }
    }
}
