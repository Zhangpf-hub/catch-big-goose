using UnityEditor;
using UnityEngine;
using System.IO;
namespace CatchGoose.Editor
{
    static class GooseReferenceMaterialImport
    {
        public static void EnsureTextureImports()
        {
            const string folder="Assets/Resources/ReferenceTextures";
            if(!Directory.Exists(folder))return;
            foreach(var path in Directory.GetFiles(folder,"*.png"))
            {
                var importer=(TextureImporter)AssetImporter.GetAtPath(path.Replace('\\','/'));
                bool srgb=!Path.GetFileName(path).StartsWith("d_");
                if(importer.maxTextureSize==1024&&importer.mipmapEnabled&&importer.sRGBTexture==srgb&&importer.wrapMode==TextureWrapMode.Repeat)continue;
                importer.maxTextureSize=1024;importer.mipmapEnabled=true;importer.sRGBTexture=srgb;importer.wrapMode=TextureWrapMode.Repeat;importer.SaveAndReimport();
            }
        }
        static Texture2D Texture(string path)=>string.IsNullOrEmpty(path)?null:AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Resources/"+path+".png");
        static Vector4 Tint(float[] color)=>color!=null&&color.Length>=3?new Vector4(color[0],color[1],color[2],0):new Vector4(.277f,.277f,.277f,0);
        public static void Apply(Material material,MaterialInfo data)
        {
            material.shader=Resources.Load<Shader>(data.glass?"GooseReferenceGlass":"GooseReferenceOpaque");
            material.mainTexture=Texture(data.texture);
            material.color=new Color(data.color[0],data.color[1],data.color[2],1);
            material.SetTexture("_Matcap",Texture(data.matcap));material.SetFloat("_MatcapStrength",data.matcapScale);
            material.SetVector("_MatcapTint",Tint(data.matcapColor));
            material.SetVector("_SourceLightTint",data.lightColor!=null?new Vector4(data.lightColor[0],data.lightColor[1],data.lightColor[2],0):new Vector4(.27f,.27f,.27f,0));
            if(data.glass)material.SetFloat("_Opacity",data.opacity);
            else
            {
                material.SetTexture("_Matcap1",Texture(data.matcap1));material.SetTexture("_Matcap2",Texture(data.matcap2));material.SetTexture("_MatcapMask",Texture(data.mask));
                material.SetFloat("_MatcapStrength1",data.matcapScale1);material.SetFloat("_MatcapStrength2",data.matcapScale2);
                material.SetVector("_MatcapTint1",Tint(data.matcapColor1));material.SetVector("_MatcapTint2",Tint(data.matcapColor2));
                if(!string.IsNullOrEmpty(data.mask))material.EnableKeyword("REFERENCE_DUAL_MATCAP");else material.DisableKeyword("REFERENCE_DUAL_MATCAP");
                material.SetTexture("_AOMap",Texture(data.aoMap));material.SetFloat("_AOStrength",data.aoScale);
                if(!string.IsNullOrEmpty(data.aoMap))material.EnableKeyword("REFERENCE_AO");else material.DisableKeyword("REFERENCE_AO");
            }
            material.enableInstancing=true;
        }
    }
}
