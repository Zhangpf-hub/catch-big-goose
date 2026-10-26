using System.Collections.Generic;
using NUnit.Framework;
using UnityEngine;

namespace CatchGoose.Tests
{
    public sealed class GooseSurfacePerformanceTests
    {
        readonly List<GameObject> roots = new List<GameObject>();
        GooseItem Box(string name, Vector3 position, Vector3 size)
        {
            var root = GameObject.CreatePrimitive(PrimitiveType.Cube); roots.Add(root);
            root.name = name; root.transform.position = position; root.transform.localScale = size;
            var item = root.AddComponent<GooseItem>(); item.Id = name; item.Visual = root.transform;
            item.Body = root.AddComponent<Rigidbody>(); item.Body.useGravity = false;
            item.CacheParts(); item.DepthReady = true; return item;
        }
        [TearDown] public void Cleanup()
        { foreach (var root in roots) if (root) Object.DestroyImmediate(root); roots.Clear(); }

        [Test] public void TwelveIndependentlyExposedTopsAreFoundAndTheirSupportsAreExcluded()
        {
            // At a remote coordinate, independently of any loaded game scene.
            // The oracle is the authored geometry, not the depth manager's own candidate list.
            var tops = new List<GooseItem>(); var supports = new List<GooseItem>();
            for (int z = 0; z < 3; z++) for (int x = 0; x < 4; x++)
            {
                var center = new Vector3(100 + x * .7f, 10, 100 + z * .7f);
                supports.Add(Box("covered-" + x + "-" + z, center, new Vector3(.48f, .6f, .48f)));
                tops.Add(Box("exposed-" + x + "-" + z, center + Vector3.up * .45f, new Vector3(.48f, .3f, .48f)));
            }
            Physics.SyncTransforms();
            foreach (var top in tops)
                Assert.IsTrue(GoosePileDepth.ProbeSurface(top, 12, ~0), top.Id + " must be an independently exposed top");
            foreach (var support in supports)
                Assert.IsFalse(GoosePileDepth.ProbeSurface(support, 12, ~0), support.Id + " is covered, so cannot enter the surface");
        }

        [Test] public void SleepingActivatedSurfaceIsEligibleButAnimationAndBuriedSupportsAreNot()
        {
            var item = Box("sleeping-surface", new Vector3(100, 10, 100), Vector3.one * .3f);
            item.SurfaceActive = true; item.Body.Sleep();
            Assert.IsTrue(GooseShakeController.CanShake(item), "sleep is an optimisation, not loss of surface eligibility");
            item.SurfaceAnimating = true; Assert.IsFalse(GooseShakeController.CanShake(item));
            item.SurfaceAnimating = false; item.SurfaceActive = false; Assert.IsFalse(GooseShakeController.CanShake(item));
            item.SurfaceActive = true; item.SetDepthHeld(true); Assert.IsFalse(GooseShakeController.CanShake(item));
            Assert.IsTrue(item.Body.isKinematic); Assert.IsFalse(item.Body.useGravity);
            Assert.IsTrue(item.SelectionCollider.enabled && item.Body.detectCollisions, "inactive lower pieces retain collision support");
        }

        [Test] public void NarrowRotatedHullHasAnActualSurfaceProbeInsteadOfOnlyAabbCornerMisses()
        {
            var item = Box("thin-top", new Vector3(100, 10, 100), new Vector3(.7f, .15f, .05f));
            item.transform.rotation = Quaternion.Euler(17, 43, 8); Physics.SyncTransforms();
            Assert.IsTrue(GoosePileDepth.ProbeSurface(item, 12, ~0), "an isolated thin diagonal hull must not disappear from surface eligibility");
        }

        [Test] public void SurfaceFlagAloneCannotMakeHiddenPickedOrKinematicPieceShakeable()
        {
            var item = Box("invalid-surface", new Vector3(100, 10, 100), Vector3.one * .3f);
            item.SurfaceActive = true; item.SetDepthVisible(false); Assert.IsFalse(GooseShakeController.CanShake(item));
            item.SetDepthVisible(true); item.Picked = true; Assert.IsFalse(GooseShakeController.CanShake(item));
            item.Picked = false; item.Body.isKinematic = true; Assert.IsFalse(GooseShakeController.CanShake(item));
            item.Body.isKinematic = false; item.gameObject.SetActive(false); Assert.IsFalse(GooseShakeController.CanShake(item));
        }
    }
}
