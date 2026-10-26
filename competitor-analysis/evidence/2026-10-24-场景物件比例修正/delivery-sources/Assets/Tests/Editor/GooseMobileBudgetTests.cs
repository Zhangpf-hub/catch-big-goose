using System.Linq;
using NUnit.Framework;
using UnityEngine;
namespace CatchGoose.Tests
{
    public sealed class GooseMobileBudgetTests
    {
        [Test] public void EveryOriginalAndReferenceItemUsesOneRenderMeshAndMaterialWithinBudget()
        {
            var themes=JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
            var reference=JsonUtility.FromJson<ReferenceLabCatalog>(Resources.Load<TextAsset>("Data/reference-lab").text).theme;
            foreach(var id in themes.SelectMany(t=>t.items).Concat(reference.items).Distinct())
            {
                var prefab=Resources.Load<GameObject>("Models/"+id+"/"+id);Assert.IsNotNull(prefab,id);
                var renderers=prefab.GetComponentsInChildren<MeshRenderer>();Assert.AreEqual(1,renderers.Length,id);
                Assert.AreEqual(1,renderers[0].sharedMaterials.Length,id);
                var filters=prefab.GetComponentsInChildren<MeshFilter>();Assert.AreEqual(1,filters.Length,id);
                var mesh=filters[0].sharedMesh;Assert.AreEqual(1,mesh.subMeshCount,id);
                Assert.LessOrEqual(mesh.GetIndexCount(0)/3,4000,id);
            }
        }
        [Test] public void StaticContainerContactsUseIndependentLowPolygonMeshes()
        {
            var themes=JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
            foreach(var id in themes.Select(t=>t.container))
            {
                var mesh=Resources.Load<Mesh>("ContainerPhysics/"+id);Assert.IsNotNull(mesh,id);
                Assert.LessOrEqual(mesh.triangles.Length/3,450,id);Assert.Greater(mesh.triangles.Length,12,id);
                Assert.LessOrEqual(Mathf.Max(mesh.bounds.size.x,mesh.bounds.size.y,mesh.bounds.size.z),1.001f,id);
            }
        }
        [Test] public void RelativeSizesSeparateLargeSilhouettesFromSmallItems()
        {
            var sizes=JsonUtility.FromJson<ItemSizeCatalog>(Resources.Load<TextAsset>("Data/item-presentation").text);
            Assert.GreaterOrEqual(sizes.Get("watermelon")/sizes.Get("blueberry"),2);
            Assert.GreaterOrEqual(sizes.Get("radio")/sizes.Get("usbdisk"),2);
            Assert.GreaterOrEqual(sizes.items.Where(x=>x.id.StartsWith("ref_")).Max(x=>x.scale)/sizes.items.Where(x=>x.id.StartsWith("ref_")).Min(x=>x.scale),1.8f);
        }
    }
}
