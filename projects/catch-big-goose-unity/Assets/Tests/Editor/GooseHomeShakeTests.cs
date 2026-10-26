using System.Linq;
using NUnit.Framework;
using UnityEngine;
namespace CatchGoose.Tests
{
    public class GooseHomeShakeTests
    {
        [Test] public void ShakeEligibilityDoesNotReleaseHiddenOrKinematicSupports()
        {
            var root=GameObject.CreatePrimitive(PrimitiveType.Cube);var item=root.AddComponent<GooseItem>();item.Body=root.AddComponent<Rigidbody>();item.Visual=root.transform;item.SurfaceActive=true;
            try
            {
                Assert.IsTrue(GooseShakeController.CanShake(item));item.SetDepthHeld(true);Assert.IsFalse(GooseShakeController.CanShake(item));
                Assert.IsTrue(item.Body.isKinematic);item.SetDepthHeld(false);item.SetDepthVisible(false);Assert.IsFalse(GooseShakeController.CanShake(item));Assert.IsFalse(item.DepthVisible);
                item.SetDepthVisible(true);item.Picked=true;Assert.IsFalse(GooseShakeController.CanShake(item));
            }finally{Object.DestroyImmediate(root);}
        }
        [Test] public void FloorRecoveryRestoresAllNormalPhysicsFields()
        {
            var root=new GameObject("Recovery");var item=root.AddComponent<GooseItem>();item.Body=root.AddComponent<Rigidbody>();
            try
            {
                item.BeginFloorRecovery();Assert.IsTrue(item.PhysicsRecoveryActive);Assert.AreEqual(.005f,item.Body.sleepThreshold,.00001f);
                item.RestoreNormalPhysics();Assert.IsFalse(item.PhysicsRecoveryActive);Assert.AreEqual(12,item.Body.solverIterations);Assert.AreEqual(4,item.Body.solverVelocityIterations);
                Assert.AreEqual(.02f,item.Body.sleepThreshold,.00001f);Assert.AreEqual(1,item.Body.maxDepenetrationVelocity);Assert.AreEqual(GooseRuntimePerformance.DynamicCollision,item.Body.collisionDetectionMode);
                Assert.AreEqual(RigidbodyInterpolation.Interpolate,item.Body.interpolation);
            }finally{Object.DestroyImmediate(root);}
        }
        [Test] public void HomeFurnitureImportsWithinItsAuthoredBudget()
        {
            var prefab=Resources.Load<GameObject>("Models/home-table/home-table");Assert.IsNotNull(prefab);
            long triangles=0;foreach(var f in prefab.GetComponentsInChildren<MeshFilter>())
            {var mesh=f.sharedMesh;Assert.AreEqual(mesh.vertexCount,mesh.uv.Length);Assert.AreEqual(mesh.vertexCount,mesh.normals.Length);for(int i=0;i<mesh.subMeshCount;i++)triangles+=(long)mesh.GetIndexCount(i)/3;}
            Assert.LessOrEqual(triangles,4000);Assert.AreEqual(2,prefab.GetComponentsInChildren<Renderer>().Sum(r=>r.sharedMaterials.Length));
        }
    }
}
