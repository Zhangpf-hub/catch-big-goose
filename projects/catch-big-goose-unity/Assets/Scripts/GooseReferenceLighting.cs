using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
namespace CatchGoose
{
    [Serializable] public sealed class ReferenceLookSettings
    {public float sunIntensity=.8f,shadowStrength=.45f,shadowDistance=32;public bool shadows=true;}
    // Project look adaptation. Source MatCaps and material parameters are retained;
    // lighting/shadow choices are separately bounded and never claimed as original.
    public sealed class GooseReferenceLighting:MonoBehaviour
    {
        GooseGame game;Light sun;float intensity,strength;Color color;LightShadows originalShadows;
        ShadowQuality originalQuality;ShadowResolution originalResolution;int originalCascades;float originalDistance,originalBias,originalNormalBias;
        readonly List<Material> containerMaterials=new List<Material>();
        readonly Dictionary<Renderer,Material[]> comparisonOriginals=new Dictionary<Renderer,Material[]>();
        readonly Dictionary<Material,Material> comparisonMaterials=new Dictionary<Material,Material>();
        public bool SimpleComparison {get;private set;}
        public float PixelRatio {get;private set;}=2f;
        public ReferenceLookSettings Settings {get;private set;}
        Light homeKey;bool homeActive;ShadowQuality homeQuality;ShadowResolution homeResolution;int homeCascades;float homeDistance;
        public void Initialize(GooseGame owner,Light light)
        {
            game=owner;sun=light;intensity=sun.intensity;strength=sun.shadowStrength;color=sun.color;originalShadows=sun.shadows;
            originalQuality=QualitySettings.shadows;originalResolution=QualitySettings.shadowResolution;originalCascades=QualitySettings.shadowCascades;
            originalDistance=QualitySettings.shadowDistance;originalBias=sun.shadowBias;originalNormalBias=sun.shadowNormalBias;
            var file=Resources.Load<TextAsset>("Data/reference-look");Settings=file?JsonUtility.FromJson<ReferenceLookSettings>(file.text):new ReferenceLookSettings();
            sun.cullingMask&=~(1<<28);
        }
        public void Home(Light key,bool enabled)
        {
            if(enabled)
            {
                if(!homeActive){homeQuality=QualitySettings.shadows;homeResolution=QualitySettings.shadowResolution;homeCascades=QualitySettings.shadowCascades;homeDistance=QualitySettings.shadowDistance;}
                homeKey=key;homeActive=true;sun.enabled=false;key.enabled=true;
                // Built-in "No Cascades" uses one unsplit map. The home light
                // explicitly requests 1024 rather than a viewport-sized map.
                QualitySettings.shadows=ShadowQuality.All;QualitySettings.shadowResolution=ShadowResolution.Medium;QualitySettings.shadowCascades=0;QualitySettings.shadowDistance=12;
            }
            else if(homeActive)
            {
                if(homeKey)homeKey.enabled=false;homeActive=false;sun.enabled=true;
                QualitySettings.shadows=homeQuality;QualitySettings.shadowResolution=homeResolution;QualitySettings.shadowCascades=homeCascades;QualitySettings.shadowDistance=homeDistance;
            }
        }
        public void Apply(bool enabled)
        {
            Home(homeKey,false);
            Comparison(false);
            foreach(var material in containerMaterials)if(material)Destroy(material);containerMaterials.Clear();
            sun.intensity=enabled?Settings.sunIntensity:intensity;sun.color=enabled?Color.white:color;
            sun.shadowStrength=enabled?Settings.shadowStrength:strength;
            sun.shadows=enabled&&Settings.shadows?LightShadows.Hard:enabled?LightShadows.None:originalShadows;
            QualitySettings.shadows=enabled?(Settings.shadows?ShadowQuality.HardOnly:ShadowQuality.Disable):originalQuality;
            QualitySettings.shadowResolution=enabled?ShadowResolution.Medium:originalResolution;QualitySettings.shadowCascades=enabled?1:originalCascades;
            // Keep the same floor coverage when the orthographic camera is raised.
            QualitySettings.shadowDistance=(enabled?Settings.shadowDistance:originalDistance)+GoosePhoneLayout.CameraHeight-20f;
            sun.shadowBias=enabled?.035f:originalBias;sun.shadowNormalBias=enabled?.12f:originalNormalBias;
            if(!enabled&&PixelRatio!=2f){game.GetComponent<GooseWeChatPlatform>().SetReferencePixelRatio(2f);PixelRatio=2f;}
        }
        public void ToggleShadows()
        {
            Settings.shadows=!Settings.shadows;
            QualitySettings.shadows=Settings.shadows?ShadowQuality.HardOnly:ShadowQuality.Disable;
            sun.shadows=Settings.shadows&&!SimpleComparison?LightShadows.Hard:LightShadows.None;
        }
        public void ToggleResolution()
        {
            float target=PixelRatio<2?2:1.5f;
            if(game.GetComponent<GooseWeChatPlatform>().SetReferencePixelRatio(target))PixelRatio=target;
            else game.Hud.Toast("清晰度切换在微信运行时生效");
        }
        public void Comparison(bool enabled)
        {
            if(!enabled)
            {
                foreach(var pair in comparisonOriginals)if(pair.Key)
                {pair.Key.sharedMaterials=pair.Value;pair.Key.receiveShadows=true;Cast(pair.Key.transform,pair.Key.gameObject.layer!=30);}
                comparisonOriginals.Clear();foreach(var material in comparisonMaterials.Values)if(material)Destroy(material);comparisonMaterials.Clear();
            }
            else if(!SimpleComparison)
            {
                foreach(var renderer in FindObjectsOfType<Renderer>())
                {
                    var materials=renderer.sharedMaterials;
                    if(materials.Length==0||!materials[0].shader.name.StartsWith("Goose/Reference"))continue;
                    comparisonOriginals.Add(renderer,(Material[])materials.Clone());
                    for(int i=0;i<materials.Length;i++)
                    {
                        var source=materials[i];
                        if(!comparisonMaterials.TryGetValue(source,out var flat))
                        {flat=new Material(Resources.Load<Shader>("GooseItemMobile")){mainTexture=source.mainTexture,color=source.color,enableInstancing=true};comparisonMaterials.Add(source,flat);}
                        materials[i]=flat;
                    }
                    renderer.sharedMaterials=materials;renderer.shadowCastingMode=ShadowCastingMode.Off;renderer.receiveShadows=false;
                }
            }
            SimpleComparison=enabled;
            sun.shadows=!enabled&&Settings!=null&&Settings.shadows&&game.ReferenceScene?LightShadows.Hard:LightShadows.None;
        }
        public void Container(GameObject visual)
        {
            if(!game.ReferenceScene)return;
            foreach(var renderer in visual.GetComponentsInChildren<Renderer>())
            {
                var materials=renderer.sharedMaterials;
                for(int i=0;i<materials.Length;i++)
                {
                    var source=materials[i];var material=source.shader.name=="Goose/ReferenceOpaque"?new Material(source):new Material(Resources.Load<Shader>("GooseReferenceOpaque")){mainTexture=source.mainTexture,color=source.color};material.enableInstancing=true;
                    materials[i]=material;containerMaterials.Add(material);
                }
                renderer.sharedMaterials=materials;renderer.receiveShadows=true;renderer.shadowCastingMode=ShadowCastingMode.On;
            }
        }
        public static void Cast(Transform root,bool enabled)
        {
            var renderers=root.TryGetComponent<GooseItem>(out var item)?item.Renderers:root.GetComponentsInChildren<Renderer>();
            foreach(var renderer in renderers)
                if(renderer.sharedMaterial&&renderer.sharedMaterial.shader.name.StartsWith("Goose/Reference"))
                    renderer.shadowCastingMode=enabled&&renderer.sharedMaterial.shader.name=="Goose/ReferenceOpaque"?ShadowCastingMode.On:ShadowCastingMode.Off;
        }
    }
}
