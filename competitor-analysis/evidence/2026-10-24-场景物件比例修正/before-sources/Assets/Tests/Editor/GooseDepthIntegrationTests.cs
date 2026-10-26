using NUnit.Framework;
using UnityEngine;

namespace CatchGoose.Tests
{
    public class GooseDepthIntegrationTests
    {
        [Test] public void HiddenHeldItemRetainsSupportAndCanWake()
        {
            var root = new GameObject("DepthLifecycle");
            var visual = GameObject.CreatePrimitive(PrimitiveType.Cube);
            visual.transform.SetParent(root.transform, false);
            var item = root.AddComponent<GooseItem>();
            item.Visual = visual.transform; item.Body = root.AddComponent<Rigidbody>();
            var collider = visual.GetComponent<Collider>(); var renderer = visual.GetComponent<Renderer>();
            try
            {
                item.SetDepthHeld(true); item.SetDepthVisible(false);
                Assert.IsTrue(item.Body.isKinematic);
                Assert.IsTrue(collider.enabled && item.Body.detectCollisions && root.activeSelf);
                Assert.IsFalse(renderer.enabled);
                item.ReleaseDepth(Time.time + 1, true);
                Assert.IsFalse(item.Body.isKinematic || item.DepthHeld);
                Assert.IsTrue(renderer.enabled && collider.enabled && item.DepthVisible);
                Assert.Greater(item.DepthProtectedUntil, Time.time);
            }
            finally { Object.DestroyImmediate(root); }
        }

        [Test] public void PickedItemIsNeverReactivatedByDepthPolicy()
        {
            var root = new GameObject("PickedDepth");
            var item = root.AddComponent<GooseItem>(); item.Body = root.AddComponent<Rigidbody>();
            try
            {
                item.Picked = true; item.Body.isKinematic = true;
                item.SetDepthHeld(false);
                Assert.IsTrue(item.Body.isKinematic);
            }
            finally { Object.DestroyImmediate(root); }
        }
    }
}
