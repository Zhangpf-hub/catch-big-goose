using System;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace CatchGoose.Editor
{
    [Serializable] class MaterialList { public MaterialInfo[] materials; }
    [Serializable] class MaterialInfo
    {
        public string name, texture,sourceShader,matcap,matcap1,matcap2,mask,aoMap;
        public float[] color,matcapColor,matcapColor1,matcapColor2,lightColor;
        public float metallic,roughness,opacity=1,matcapScale,matcapScale1,matcapScale2,aoScale;
        public bool referenceMaterial,glass;
    }

    public class GooseAssetImporter : AssetPostprocessor
    {
        void OnPreprocessModel()
        {
            if (!assetPath.StartsWith("Assets/Resources/Models/") && !assetPath.StartsWith("Assets/MobileContact/")) return;
            var model = (ModelImporter)assetImporter;
            model.isReadable = true;
            model.importCameras = false; model.importLights = false; model.importAnimation = false;
            model.materialImportMode = ModelImporterMaterialImportMode.ImportStandard;
            model.materialLocation = ModelImporterMaterialLocation.InPrefab;
        }
        Material OnAssignMaterialModel(Material source, Renderer renderer)
        {
            if (!assetPath.StartsWith("Assets/Resources/Models/")) return null;
            string folder = Path.GetDirectoryName(assetPath).Replace('\\', '/');
            // Prepare Project creates materials outside import callbacks and remaps the FBX.
            // Reimports may reuse them, but must never create assets from a postprocessor.
            return AssetDatabase.LoadAssetAtPath<Material>(folder + "/" + source.name + ".mat");
        }
        void OnPreprocessTexture()
        {
            if (!assetPath.StartsWith("Assets/Resources/")) return;
            var texture = (TextureImporter)assetImporter;
            if(assetPath.StartsWith("Assets/Resources/ReferenceTextures/"))
            {
                texture.sRGBTexture=!Path.GetFileName(assetPath).StartsWith("d_");
                texture.mipmapEnabled=true;texture.wrapMode=TextureWrapMode.Repeat;texture.maxTextureSize=1024;
                return;
            }
            texture.mipmapEnabled = assetPath.Contains("/Models/");
            texture.wrapMode = TextureWrapMode.Clamp;
            texture.alphaIsTransparency = assetPath.EndsWith(".png", StringComparison.OrdinalIgnoreCase);
            if (assetPath.Contains("/Icons/") || assetPath.Contains("/Textures/"))
            { texture.textureType = TextureImporterType.Sprite; texture.spriteImportMode = SpriteImportMode.Single; }
            // Ordinary items follow the observed 128–512px reference range.
            // Backgrounds and UI retain their existing import resolution.
            texture.maxTextureSize = assetPath.Contains("/Models/") ? 512 : assetPath.Contains("/mobile-ui/") ? 1024 : 2048;
        }
    }
}
