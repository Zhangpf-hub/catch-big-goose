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

        GameObject Cover(string name, Vector3 position, Vector3 size)
        {
            var cover = GameObject.CreatePrimitive(PrimitiveType.Cube); roots.Add(cover);
            cover.name = name; cover.transform.position = position; cover.transform.localScale = size;
            return cover;
        }

        [Test] public void GenuineInnerOpeningRemainsExposedWhenCenterAndOuterEdgesAreCovered()
        {
            var item = Box("inner-opening-top", new Vector3(100, 10, 100), new Vector3(2, .2f, 2));
            // A central cap and an outer frame leave four genuine interior
            // openings. Center-only or edge-only sampling misses every opening.
            Cover("central-cap", new Vector3(100, 11, 100), new Vector3(.4f, .1f, .4f));
            Cover("frame-left", new Vector3(99.25f, 11, 100), new Vector3(.5f, .1f, 2));
            Cover("frame-right", new Vector3(100.75f, 11, 100), new Vector3(.5f, .1f, 2));
            Cover("frame-front", new Vector3(100, 11, 99.25f), new Vector3(2, .1f, .5f));
            Cover("frame-back", new Vector3(100, 11, 100.75f), new Vector3(2, .1f, .5f));
            Physics.SyncTransforms();
            Assert.IsTrue(Physics.Raycast(new Vector3(100.33f, 12, 100.37f), Vector3.down, out var opening, 3, ~0));
            Assert.AreSame(item.SelectionCollider, opening.collider, "an independently authored interior ray reaches the actual target first");
            Assert.IsTrue(Physics.Raycast(new Vector3(100, 12, 100), Vector3.down, out var center, 3, ~0));
            Assert.AreNotSame(item.SelectionCollider, center.collider, "the center really is covered");
            Assert.IsTrue(Physics.Raycast(new Vector3(100.72f, 12, 100.72f), Vector3.down, out var edge, 3, ~0));
            Assert.AreNotSame(item.SelectionCollider, edge.collider, "the outer frame really is covered");
            Assert.IsTrue(GoosePileDepth.ProbeSurface(item, 12, ~0), "a real interior opening must retain surface eligibility");
        }

        [Test] public void FullyCoveredSurfaceUsesBoundedQueriesAndLeavesVisualClassificationBudget()
        {
            var item = Box("fully-covered-top", new Vector3(100, 10, 100), new Vector3(2, .2f, 2));
            Cover("full-cap", new Vector3(100, 11, 100), new Vector3(2.2f, .1f, 2.2f));
            Physics.SyncTransforms();
            Assert.IsFalse(GoosePileDepth.ProbeSurface(item, 12, ~0, out int actualQueries));
            Assert.AreEqual(34, actualQueries, "all covered samples require both own-hull and first-hit queries");
            Assert.AreEqual(GoosePileDepth.MaxSurfaceProbeQueries, actualQueries);
            // Reserve is a gameplay budget requirement, independent of the
            // implementation's cursor: a worst-case last surface check must
            // still leave enough slots for a complete conservative visual check.
            int used = GoosePileDepth.MaxProbeCount - 64 - GoosePileDepth.MaxSurfaceProbeQueries;
            used += actualQueries;
            Assert.LessOrEqual(used, GoosePileDepth.MaxProbeCount - 64);
            int visualChecks = 0;
            while (used <= GoosePileDepth.MaxProbeCount - GoosePileDepth.MaxVisualProbeQueries)
            { used += GoosePileDepth.MaxVisualProbeQueries; visualChecks++; }
            Assert.GreaterOrEqual(visualChecks, 1, "visual classification retains useful work after a full surface slice");
            Assert.LessOrEqual(used, GoosePileDepth.MaxProbeCount);
        }

        [Test] public void SurfaceFlagAloneCannotMakeHiddenPickedOrKinematicPieceShakeable()
        {
            var item = Box("invalid-surface", new Vector3(100, 10, 100), Vector3.one * .3f);
            item.SurfaceActive = true; item.SetDepthVisible(false); Assert.IsFalse(GooseShakeController.CanShake(item));
            item.SetDepthVisible(true); item.Picked = true; Assert.IsFalse(GooseShakeController.CanShake(item));
            item.Picked = false; item.Body.isKinematic = true; Assert.IsFalse(GooseShakeController.CanShake(item));
            item.Body.isKinematic = false; item.gameObject.SetActive(false); Assert.IsFalse(GooseShakeController.CanShake(item));
        }

        [Test] public void ExistingFastFallCannotCreateUnbudgetedUpwardImpulseDuringSpeedLimiting()
        {
            var before = new Vector3(4, -5, 0);
            var after = GooseShakeController.BoundVelocity(before, new Vector3(1, 0, 0), 4.5f, 0);
            Assert.LessOrEqual(after.y - before.y, .00001f, "speed limiting must not turn a downward fall into a free upward impulse");
            Assert.LessOrEqual(after.magnitude, before.magnitude + .00001f, "no budgetless acceleration of an already-fast body");
        }

        [Test] public void LargeLiftRequestCannotExceedSmallRemainingUpwardBudget()
        {
            var before = new Vector3(0, -8, 0);
            var after = GooseShakeController.BoundVelocity(before, Vector3.up * 10, 4.5f, .1f);
            Assert.LessOrEqual(after.y - before.y, .10001f);
            Assert.LessOrEqual(after.magnitude, before.magnitude + .00001f);
        }

        [Test] public void OrdinaryLiftRetainsItsResponseInsideSpeedAndUpwardBudgets()
        {
            var after = GooseShakeController.BoundVelocity(Vector3.zero, new Vector3(2, 3, 0), 4.5f, 2.8f);
            Assert.Greater(after.x, 0); Assert.Greater(after.y, 0);
            Assert.LessOrEqual(after.magnitude, 4.50001f);
            Assert.LessOrEqual(after.y, 2.80001f);
        }
    }
}
