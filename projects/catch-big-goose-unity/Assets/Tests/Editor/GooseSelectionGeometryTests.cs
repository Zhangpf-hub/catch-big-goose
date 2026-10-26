using NUnit.Framework;
using UnityEngine;

namespace CatchGoose.Tests
{
    public class GooseSelectionGeometryTests
    {
        [Test] public void SmoothEffectGeometrySurvivesMobileCpuReleaseWithoutChangingBaseNormals()
        {
            var source = new Mesh { name = "SelectionSeamFixture" };
            source.vertices = new[] { Vector3.zero, Vector3.right, Vector3.up, Vector3.zero, Vector3.up, Vector3.forward };
            source.normals = new[] { Vector3.forward, Vector3.forward, Vector3.forward, Vector3.right, Vector3.right, Vector3.right };
            source.triangles = new[] { 0, 1, 2, 3, 4, 5 };
            var data = GooseSelectionGeometry.Prepare(source);
            Assert.AreNotSame(source, data.mesh);
            Assert.AreEqual(data.groups[0], data.groups[3]);
            Assert.AreEqual(data.groups[2], data.groups[4]);
            Assert.AreEqual(Vector3.forward, source.normals[0]);
            Assert.AreEqual(Vector3.right, source.normals[3]);
            Assert.AreEqual(source.subMeshCount, data.mesh.subMeshCount);
            source.UploadMeshData(true);
            Assert.AreSame(data, GooseSelectionGeometry.Prepare(source));
            Assert.IsFalse(data.mesh.isReadable);
            Object.DestroyImmediate(source);
        }

        [Test] public void SourceSettingsRetainMediumQualityAndOriginalWidths()
        {
            var cfg = JsonUtility.FromJson<GooseSelectionSettings>(Resources.Load<TextAsset>("Data/selection-highlight").text);
            Assert.AreEqual(3, cfg.outlineQuality); Assert.AreEqual(3, cfg.glowQuality);
            Assert.AreEqual(.2f, cfg.outlineWidth, .00001f); Assert.AreEqual(.25f, cfg.glowWidth, .00001f);
            Assert.AreEqual(1.86f, cfg.glow, .00001f); Assert.AreEqual(.5f, cfg.overlay, .00001f);
            Assert.AreEqual(0, cfg.seeThrough); Assert.AreEqual(1, cfg.glowPasses.Length);
        }
    }
}
