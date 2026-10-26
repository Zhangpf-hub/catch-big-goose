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
        void OnPreprocessAudio()
        {
            if(assetPath!="Assets/Resources/Audio/bgm.ogg"&&assetPath!="Assets/Resources/Audio/shake.wav"&&assetPath!="Assets/Resources/Audio/shuffle.wav"&&!assetPath.StartsWith("Assets/Resources/Audio/duck-quack-"))return;
            var audio=(AudioImporter)assetImporter;
            var settings=audio.defaultSampleSettings;
            settings.loadType=AudioClipLoadType.DecompressOnLoad;
            settings.compressionFormat=assetPath.EndsWith(".ogg")?AudioCompressionFormat.Vorbis:AudioCompressionFormat.PCM;
            settings.quality=.65f;settings.sampleRateSetting=AudioSampleRateSetting.PreserveSampleRate;
            audio.defaultSampleSettings=settings;audio.forceToMono=false;audio.loadInBackground=false;
        }
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
            if(assetPath.StartsWith("Assets/Resources/Textures/reward-truck/"))
            {
                texture.mipmapEnabled=true;texture.filterMode=FilterMode.Trilinear;
                texture.npotScale=TextureImporterNPOTScale.None;texture.maxTextureSize=2048;
                texture.textureCompression=TextureImporterCompression.Uncompressed;
                texture.SetPlatformTextureSettings(new TextureImporterPlatformSettings{name="WebGL",overridden=true,
                    maxTextureSize=assetPath.EndsWith("wheel.png")?256:512,format=TextureImporterFormat.RGBA32,
                    textureCompression=TextureImporterCompression.Uncompressed});
                return;
            }
            if(assetPath=="Assets/Resources/Textures/hud-numbers/golden-digits-v1.png")
            {
                // Tight source rectangles retain transparent outline padding. The source
                // atlas stays intact; all twelve glyphs share one mobile texture.
                var rects=new[]{new Rect(73,710,280,316),new Rect(443,709,243,317),
                    new Rect(757,710,279,315),new Rect(1115,705,267,320),
                    new Rect(65,365,294,315),new Rect(428,363,268,317),
                    new Rect(761,363,275,319),new Rect(1123,366,263,312),
                    new Rect(68,40,281,314),new Rect(427,40,269,312),
                    new Rect(817,71,154,264),new Rect(1049,79,373,218)};
                var sprites=new SpriteMetaData[rects.Length];
                for(int i=0;i<sprites.Length;i++)sprites[i]=new SpriteMetaData{
                    name="glyph-"+(i<10?i.ToString():i==10?"colon":"infinity"),rect=rects[i],
                    alignment=(int)SpriteAlignment.Center,pivot=Vector2.one*.5f};
                texture.spriteImportMode=SpriteImportMode.Multiple;texture.spritesheet=sprites;
                texture.spritePixelsPerUnit=100;texture.npotScale=TextureImporterNPOTScale.None;
                texture.mipmapEnabled=true;texture.filterMode=FilterMode.Trilinear;
                texture.textureCompression=TextureImporterCompression.Uncompressed;texture.maxTextureSize=2048;
                // At DPR 2 the timer glyphs display at about 74 px high; a 512 px
                // atlas retains ~112 px glyphs without bundling the desktop atlas.
                texture.SetPlatformTextureSettings(new TextureImporterPlatformSettings{name="WebGL",overridden=true,
                    maxTextureSize=512,format=TextureImporterFormat.RGBA32,
                    textureCompression=TextureImporterCompression.Uncompressed});
                return;
            }
            if(assetPath.Contains("/ui-candy-v2/"))
            {
                float border=assetPath.Contains("panel")?48:64;
                texture.spriteBorder=new Vector4(border,border,border,border);texture.spritePixelsPerUnit=100;
                var settings=new TextureImporterSettings();texture.ReadTextureSettings(settings);settings.spriteMeshType=SpriteMeshType.FullRect;texture.SetTextureSettings(settings);
                texture.mipmapEnabled=true;texture.filterMode=FilterMode.Trilinear;
                texture.textureCompression=TextureImporterCompression.Uncompressed;texture.maxTextureSize=256;
                foreach(string platform in new[]{"Standalone","WebGL","Android","iPhone"})
                    texture.SetPlatformTextureSettings(new TextureImporterPlatformSettings{name=platform,overridden=true,maxTextureSize=256,format=TextureImporterFormat.RGBA32,textureCompression=TextureImporterCompression.Uncompressed});
                return;
            }
            if(assetPath.Contains("/story-ui/")||assetPath.Contains("/control-labels/"))
            {texture.mipmapEnabled=true;texture.filterMode=FilterMode.Trilinear;texture.textureCompression=TextureImporterCompression.Uncompressed;texture.maxTextureSize=assetPath.Contains("/control-labels/")?512:256;return;}
            if(assetPath.Contains("/Icons/"))
            {
                var themes=JsonUtility.FromJson<ThemeCatalog>(File.ReadAllText("Assets/Resources/Data/themes.json")).themes;
                bool home=Array.Exists(themes,t=>t.icon==Path.GetFileNameWithoutExtension(assetPath));
                texture.mipmapEnabled=home;texture.filterMode=home?FilterMode.Trilinear:FilterMode.Bilinear;
            }
            // Ordinary items follow the observed 128–512px reference range.
            // Backgrounds and UI retain their existing import resolution.
            texture.maxTextureSize = assetPath.Contains("/Models/") ? 512 : assetPath.Contains("/mobile-ui/") ? 1024 : 2048;
        }
    }
}
