using System.Linq;
using NUnit.Framework;
using UnityEngine;
namespace CatchGoose.Tests
{
    public sealed class GoosePerformanceTests
    {
        [Test] public void EveryPlayableKindHasASmallFiniteOfflineCollisionMesh()
        {
            var themes=JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
            foreach(var id in themes.SelectMany(t=>t.items).Distinct())
            {
                var mesh=Resources.Load<Mesh>("Physics/"+id);
                Assert.IsNotNull(mesh,id);Assert.GreaterOrEqual(mesh.vertexCount,4,id);Assert.LessOrEqual(mesh.vertexCount,100,id);
                Assert.IsTrue(mesh.vertices.All(v=>float.IsFinite(v.x)&&float.IsFinite(v.y)&&float.IsFinite(v.z)),id);
                Assert.LessOrEqual(Mathf.Max(mesh.bounds.size.x,mesh.bounds.size.y,mesh.bounds.size.z),1.001f,id);
            }
        }
        [Test] public void ReusedItemRestoresVisibleDynamicSelectableStateAndVisualScale()
        {
            var root=new GameObject("PoolReset");var child=GameObject.CreatePrimitive(PrimitiveType.Cube);child.transform.SetParent(root.transform,false);child.transform.localScale=Vector3.one*.7f;
            var item=root.AddComponent<GooseItem>();item.Visual=child.transform;item.Body=root.AddComponent<Rigidbody>();item.CacheParts();
            try
            {
                item.SetDepthHeld(true);item.SetDepthVisible(false);item.Picked=true;item.DepthReady=true;
                item.SelectionCollider.enabled=false;item.Visual.localScale=Vector3.one*.1f;root.transform.localScale=Vector3.one*3;
                item.ResetForReuse();
                Assert.IsFalse(item.Picked||item.DepthReady||item.DepthHeld||item.Body.isKinematic);
                Assert.IsTrue(item.DepthVisible&&item.SelectionCollider.enabled&&child.GetComponent<Renderer>().enabled);
                Assert.AreEqual(Vector3.one,root.transform.localScale);Assert.AreEqual(Vector3.one*.7f,item.Visual.localScale);
            }
            finally{Object.DestroyImmediate(root);}
        }
        [Test] public void MobileItemShaderIsIncludedAsAResource()
        {Assert.IsNotNull(Resources.Load<Shader>("GooseItemMobile"));}
    }
}
