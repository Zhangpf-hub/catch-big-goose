using System.Linq;
using NUnit.Framework;
using UnityEngine;
namespace CatchGoose.Tests
{
    public sealed class GooseMobileBudgetTests
    {
        [Test] public void EveryFrozenSourceItemMatchesItsSourceMaterialAndGeometryBudget()
        {
            var catalog=JsonUtility.FromJson<ReferenceMaterialCatalog>(Resources.Load<TextAsset>("Data/reference-material-models").text);
            int total=0,glass=0,colorOnly=0;
            // Original geometry budgets belong to original models, even after
            // the story catalog replaces a goose with an authored B2 duck.
            foreach(var budget in catalog.models)
            {
                var id=budget.id;
                var prefab=Resources.Load<GameObject>("Models/"+id+"/"+id);Assert.IsNotNull(prefab,id);
                var renderers=prefab.GetComponentsInChildren<MeshRenderer>();Assert.AreEqual(budget.materials,renderers.Length,id);
                long triangles=0;int localGlass=0,localColor=0;
                foreach(var renderer in renderers)
                {
                    Assert.AreEqual(1,renderer.sharedMaterials.Length,id);var material=renderer.sharedMaterial;Assert.IsTrue(material.shader.name.StartsWith("Goose/Reference"),id);
                    if(material.shader.name=="Goose/ReferenceGlass")localGlass++;if(!material.mainTexture)localColor++;
                    triangles+=(long)renderer.GetComponent<MeshFilter>().sharedMesh.GetIndexCount(0)/3;
                }
                Assert.AreEqual(budget.triangles,triangles,id);Assert.LessOrEqual(triangles,4000,id);Assert.AreEqual(budget.glassMaterials,localGlass,id);Assert.AreEqual(budget.colorOnlyMaterials,localColor,id);
                total++;glass+=localGlass;colorOnly+=localColor;
            }
            Assert.AreEqual(catalog.models.Length,total);Assert.AreEqual(catalog.models.Sum(x=>x.glassMaterials),glass);Assert.AreEqual(catalog.models.Sum(x=>x.colorOnlyMaterials),colorOnly);
        }
        [Test] public void ActiveAuthoredDuckReplacementsHaveTheirOwnMaterialAndTriangleBudget()
        {
            var themes=JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
            foreach(var id in themes.SelectMany(t=>t.items).Where(id=>id.StartsWith("duck-")).Distinct())
            {
                var prefab=Resources.Load<GameObject>("Models/"+id+"/"+id);Assert.IsNotNull(prefab,id);
                var renderers=prefab.GetComponentsInChildren<MeshRenderer>();Assert.AreEqual(1,renderers.Length,id);
                Assert.AreEqual("Goose/DuckMobile",renderers[0].sharedMaterial.shader.name,id);
                Assert.IsNotNull(renderers[0].sharedMaterial.mainTexture,id);
                long triangles=(long)renderers[0].GetComponent<MeshFilter>().sharedMesh.GetIndexCount(0)/3;
                Assert.Greater(triangles,0,id);Assert.LessOrEqual(triangles,6000,id);
            }
        }
        [Test] public void ReferenceItemsRetainExactlySourceMaterialGroupsWithinGeometryBudget()
        {
            var reference=JsonUtility.FromJson<ReferenceLabCatalog>(Resources.Load<TextAsset>("Data/reference-lab").text).theme;
            int materialTotal=0,glassTotal=0,colorOnly=0;
            foreach(var id in reference.items)
            {
                int expected=id=="ref_gtplaydough"||id=="ref_gtwatergame"?3:id=="ref_gtkaleidoscope"||id=="ref_gtracecar"||id=="ref_gtringcandy"?2:1;
                var prefab=Resources.Load<GameObject>("Models/"+id+"/"+id);var renderers=prefab.GetComponentsInChildren<MeshRenderer>();
                Assert.AreEqual(expected,renderers.Length,id);long triangles=0;
                foreach(var renderer in renderers)
                {
                    Assert.AreEqual(1,renderer.sharedMaterials.Length,id);var m=renderer.sharedMaterial;
                    Assert.IsTrue(m.shader.name.StartsWith("Goose/Reference"),id);
                    // Some source glass shells use only tint and the shader's default white texture.
                    if(m.shader.name=="Goose/ReferenceOpaque")Assert.IsNotNull(m.mainTexture,id);
                    if(!m.mainTexture)
                    {colorOnly++;Assert.AreEqual("ref_gtplaydough",id);Assert.AreEqual("Goose/ReferenceGlass",m.shader.name);Assert.IsNotNull(m.GetTexture("_Matcap"));}
                    if(m.shader.name=="Goose/ReferenceGlass"){glassTotal++;Assert.Less(m.GetFloat("_Opacity"),.7f,id);}
                    triangles+=(long)renderer.GetComponent<MeshFilter>().sharedMesh.GetIndexCount(0)/3;materialTotal++;
                }
                Assert.LessOrEqual(triangles,4000,id);
            }
            Assert.AreEqual(28,materialTotal);Assert.AreEqual(4,glassTotal);Assert.AreEqual(1,colorOnly,"Source back-glass layer uses tint/MatCap without a base texture");
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
            // The active catalog now uses reference/authored IDs. Retired plain
            // watermelon/radio names both hit fallback=1 and cannot test scale span.
            Assert.Greater(sizes.items.Length, 0);
            Assert.IsTrue(sizes.items.All(x => float.IsFinite(x.scale) && x.scale > 0));
            Assert.GreaterOrEqual(sizes.items.Max(x=>x.scale)/sizes.items.Min(x=>x.scale),2);
            Assert.GreaterOrEqual(sizes.items.Where(x=>x.id.StartsWith("ref_")).Max(x=>x.scale)/sizes.items.Where(x=>x.id.StartsWith("ref_")).Min(x=>x.scale),1.8f);
            Assert.AreEqual(1f,sizes.Get("unknown-item-size-fixture"),.00001f);
        }
    }
}
