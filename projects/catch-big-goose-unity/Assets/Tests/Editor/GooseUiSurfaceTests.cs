using System;
using System.Linq;
using System.Reflection;
using NUnit.Framework;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
namespace CatchGoose.Tests
{
    public class GooseUiSurfaceTests
    {
        [Test] public void NineSliceCornersKeepTheSameSizeAcrossAllButtonAndPanelRatios()
        {
            foreach(string name in new[]{"yellow-button","blue-button","ivory-panel"})
            {
                string path="Assets/Resources/Textures/ui-candy-v2/"+name+".png";
                var sprite=AssetDatabase.LoadAssetAtPath<Sprite>(path);Assert.IsNotNull(sprite);
                float border=name=="ivory-panel"?48:64;Assert.AreEqual(new Vector4(border,border,border,border),sprite.border);
                foreach(var size in new[]{new Vector2(88,88),new Vector2(130,145),new Vector2(290,93),new Vector2(488,130),new Vector2(560,620)})
                {
                    var go=new GameObject("NineSliceProbe",typeof(RectTransform),typeof(Image));
                    try
                    {
                        var image=go.GetComponent<Image>();image.rectTransform.sizeDelta=size;GooseUiSurface.Apply(image,sprite);
                        using(var mesh=new VertexHelper())
                        {
                            typeof(Image).GetMethod("OnPopulateMesh",BindingFlags.Instance|BindingFlags.NonPublic,null,new[]{typeof(VertexHelper)},null).Invoke(image,new object[]{mesh});
                            var vertices=new System.Collections.Generic.List<UIVertex>();mesh.GetUIVertexStream(vertices);
                            var x=vertices.Select(v=>v.position.x).Distinct().OrderBy(v=>v).ToArray();
                            Assert.AreEqual(4,x.Length,name);Assert.AreEqual(border/2,x[1]-x[0],.02f,name+size);
                        }
                    }
                    finally{UnityEngine.Object.DestroyImmediate(go);}
                }
                var importer=(TextureImporter)AssetImporter.GetAtPath(path);
                Assert.IsTrue(importer.mipmapEnabled);Assert.AreEqual(FilterMode.Trilinear,importer.filterMode);
                Assert.AreEqual(TextureImporterCompression.Uncompressed,importer.textureCompression);
                Assert.AreEqual(TextureImporterFormat.RGBA32,importer.GetPlatformTextureSettings("WebGL").format);
            }
        }
        [Test] public void DownscaledToolIllustrationsHaveMipmapsAndLosslessAlpha()
        {
            foreach(string name in new[]{"remove","match","shuffle"})
            {
                var sprite=Resources.Load<Sprite>("Textures/story-ui/"+name);Assert.IsNotNull(sprite);
                Assert.Greater(sprite.texture.mipmapCount,1,name);Assert.AreEqual(FilterMode.Trilinear,sprite.texture.filterMode);
                Assert.AreEqual(TextureFormat.RGBA32,sprite.texture.format,name);
                Assert.LessOrEqual(Mathf.Max(sprite.texture.width,sprite.texture.height),512);
            }
        }
        [Test] public void SpriteNumeralsCoverTimerAndToolCountsWithoutFontOrInputTargets()
        {
            var sprites=Resources.LoadAll<Sprite>("Textures/hud-numbers/golden-digits-v1");
            Assert.AreEqual(12,sprites.Length);Assert.AreEqual(1,sprites.Select(s=>s.texture).Distinct().Count());
            var root=new GameObject("NumberProbe",typeof(RectTransform),typeof(GooseSpriteNumber));
            try
            {
                var bounds=root.GetComponent<RectTransform>();bounds.sizeDelta=new Vector2(50,42);
                var number=root.GetComponent<GooseSpriteNumber>();number.Initialize(5);
                foreach(string value in new[]{"0","1","2","3","5","12","99","9:31","10:00","∞"})
                {
                    number.Show(value);
                    var enabled=root.GetComponentsInChildren<Image>().Where(i=>i.enabled).ToArray();
                    Assert.AreEqual(value.Length,enabled.Length,value);
                    foreach(var image in enabled)
                    {
                        Assert.IsFalse(image.raycastTarget);Assert.IsNotNull(image.sprite);
                        var rect=image.rectTransform;
                        Assert.LessOrEqual(Mathf.Abs(rect.anchoredPosition.x)+rect.sizeDelta.x*.5f,25.01f,value);
                        Assert.LessOrEqual(rect.sizeDelta.y,42.01f,value);
                    }
                }
                Assert.IsEmpty(root.GetComponentsInChildren<Text>());
                number.Show("0:15",true);Assert.IsTrue(number.Warning);
                number.Show("1");Assert.IsFalse(number.Warning);
                Assert.AreEqual(1,root.GetComponentsInChildren<Image>().Count(i=>i.enabled));
            }
            finally{UnityEngine.Object.DestroyImmediate(root);}
        }
    }
}
