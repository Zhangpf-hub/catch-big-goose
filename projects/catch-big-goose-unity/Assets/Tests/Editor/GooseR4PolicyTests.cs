using System.Linq;
using NUnit.Framework;
using UnityEngine;
namespace CatchGoose.Tests
{
    public sealed class GooseR4PolicyTests
    {
        [Test] public void ShrinkIsMonotonicAndHasExpectedKeyframes()
        {
            float last=1;
            for(int i=0;i<=100;i++){float r=GooseCircularContainer.RadiusRatio(i/100f);Assert.LessOrEqual(r,last+.00001f);last=r;}
            Assert.AreEqual(.75f,GooseCircularContainer.RadiusRatio(.5f),.0001f);
            Assert.AreEqual(.48f,GooseCircularContainer.RadiusRatio(.9f),.0001f);
        }
        [Test] public void FiveThemesHaveDistinctBackgroundsAndCircularContainers()
        {
            var themes=JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
            Assert.AreEqual(5,themes.Select(t=>t.background).Distinct().Count());
            foreach(var t in themes)
            {
                Assert.IsTrue(t.circular,t.id);Assert.AreEqual(1.72f,t.halfX,.001f);
                var jpeg=Resources.Load<TextAsset>("Textures/"+t.background);Assert.IsNotNull(jpeg,t.background);
                var decoded=new Texture2D(2,2,TextureFormat.RGB24,true);
                try
                {
                    Assert.IsTrue(decoded.LoadImage(jpeg.bytes,true),"Valid JPEG "+t.id);
                    Assert.AreEqual(768,decoded.width);Assert.AreEqual(1152,decoded.height);
                    Assert.Greater(decoded.mipmapCount,1);Assert.IsFalse(decoded.isReadable,"No retained CPU pixels "+t.id);
                }
                finally{UnityEngine.Object.DestroyImmediate(decoded);}
                Assert.IsNotNull(Resources.Load<GameObject>("Models/"+t.container+"/"+t.container),t.container);
            }
        }
        [Test] public void SeventhSlotTripleReleasesCapacityForAnotherPick()
        {
            var tray=new TrayRules<string>(x=>x);
            foreach(var id in new[]{"a","a","b","c","d","e"})tray.Add(id);
            CollectionAssert.AreEqual(new[]{"a","a","a"},tray.Add("a"));
            Assert.AreEqual(4,tray.Entries.Count);Assert.IsNull(tray.Add("f"));Assert.AreEqual(5,tray.Entries.Count);
        }
        [Test] public void HullAreaDoesNotGrowJustBecauseALongPieceTurnsDiagonally()
        {
            var cube=GameObject.CreatePrimitive(PrimitiveType.Cube);
            try
            {
                var mesh=cube.GetComponent<MeshFilter>().sharedMesh;
                Object.DestroyImmediate(cube.GetComponent<BoxCollider>());
                var collider=cube.AddComponent<MeshCollider>();collider.sharedMesh=mesh;collider.convex=true;
                cube.transform.position=Vector3.up;cube.transform.localScale=new Vector3(.7f,.35f,.14f);
                float area=GooseColliderGeometry.ProjectedArea(collider);
                Assert.AreEqual(.098f,area,.0001f);
                cube.transform.rotation=Quaternion.Euler(0,45,0);
                Assert.AreEqual(area,GooseColliderGeometry.ProjectedArea(collider),.0001f);
                Assert.AreEqual(.825f,GooseColliderGeometry.MinY(collider),.0001f);
            }
            finally{Object.DestroyImmediate(cube);}
        }
    }
}
