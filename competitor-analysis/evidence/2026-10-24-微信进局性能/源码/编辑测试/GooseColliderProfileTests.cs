using NUnit.Framework;
using UnityEngine;

namespace CatchGoose.Tests
{
    public class GooseColliderProfileTests
    {
        [TestCase("corn", true)]
        [TestCase("phone", false)]
        public void ProfileEnclosesTransformedVisualBounds(string id, bool capsule)
        {
            var owner = new GameObject("ProfileTest");
            var visual = GameObject.CreatePrimitive(PrimitiveType.Cube);
            visual.transform.SetParent(owner.transform, false);
            visual.transform.localPosition = new Vector3(.1f, .2f, -.05f);
            visual.transform.localScale = new Vector3(.2f, 1, .3f);
            owner.transform.position = new Vector3(3, 4, 5);
            owner.transform.rotation = Quaternion.Euler(20, 30, 10);
            owner.transform.localScale = Vector3.one * .46f;
            try
            {
                Assert.IsTrue(GooseColliderProfile.TryBuild(owner, id, visual, null));
                var collider = owner.GetComponent<Collider>();
                Assert.IsNotNull(collider);
                if (capsule)
                {
                    var c = owner.GetComponent<CapsuleCollider>();
                    Assert.AreEqual(1, c.direction);
                    Assert.AreEqual(1, c.height, .00001f);
                    Assert.AreEqual(.15f, c.radius, .00001f);
                    Assert.Less(Vector3.Distance(visual.transform.localPosition, c.center), .00001f);
                }
                else
                {
                    var c = owner.GetComponent<BoxCollider>();
                    Assert.Less(Vector3.Distance(visual.transform.localScale, c.size), .00001f);
                    Assert.Less(Vector3.Distance(visual.transform.localPosition, c.center), .00001f);
                }
            }
            finally { Object.DestroyImmediate(owner); }
        }

        [Test] public void ComplexModelsKeepConvexFallback()
        {
            var owner = new GameObject("FallbackTest");
            try
            {
                Assert.IsFalse(GooseColliderProfile.TryBuild(owner, "headphones", owner, null));
                Assert.IsNull(owner.GetComponent<Collider>());
            }
            finally { Object.DestroyImmediate(owner); }
        }
    }
}
