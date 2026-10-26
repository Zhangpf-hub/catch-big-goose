using System.Collections.Generic;
using NUnit.Framework;
using UnityEngine;

namespace CatchGoose.Tests
{
    public sealed class GooseVisualOpacityTests
    {
        readonly List<Object> created=new List<Object>();
        Material Material(string shader,Color color)
        {
            var asset=Shader.Find(shader);Assert.IsNotNull(asset,shader);
            var material=new Material(asset);material.color=color;created.Add(material);return material;
        }
        GooseItem Box(string name,Vector3 position,Vector3 scale,Material material)
        {
            var root=GameObject.CreatePrimitive(PrimitiveType.Cube);created.Add(root);
            root.name=name;root.layer=25;root.transform.position=position;root.transform.localScale=scale;
            root.GetComponent<Renderer>().sharedMaterial=material;
            var item=root.AddComponent<GooseItem>();item.Id=name;item.Visual=root.transform;
            item.Body=root.AddComponent<Rigidbody>();item.Body.isKinematic=true;item.Body.useGravity=false;
            item.CacheParts();item.RefreshVisualOcclusionCache();return item;
        }
        Camera Camera()
        {
            var root=new GameObject("OpacityFixtureCamera");created.Add(root);
            root.transform.position=new Vector3(100,105,100);root.transform.rotation=Quaternion.Euler(90,0,0);
            var camera=root.AddComponent<Camera>();camera.enabled=false;camera.orthographic=true;camera.orthographicSize=.75f;
            camera.clearFlags=CameraClearFlags.SolidColor;camera.backgroundColor=Color.black;camera.cullingMask=1<<25;
            camera.nearClipPlane=.1f;camera.farClipPlane=10;return camera;
        }
        Color Center(Camera camera)
        {
            var target=RenderTexture.GetTemporary(32,32,24);var active=RenderTexture.active;var prior=camera.targetTexture;
            var image=new Texture2D(32,32,TextureFormat.RGBA32,false);
            try
            {
                camera.targetTexture=target;camera.Render();RenderTexture.active=target;
                image.ReadPixels(new Rect(0,0,32,32),0,0);image.Apply();return image.GetPixel(16,16);
            }
            finally
            {camera.targetTexture=prior;RenderTexture.active=active;Object.DestroyImmediate(image);RenderTexture.ReleaseTemporary(target);}
        }
        [TearDown] public void Cleanup()
        {for(int i=created.Count-1;i>=0;i--)if(created[i])Object.DestroyImmediate(created[i]);created.Clear();}

        [Test] public void ActualGlassFrameShowsOpaqueTargetAndCannotBecomeAnOpaqueProxyCover()
        {
            var opaque=Material("Goose/ItemMobile",Color.red);
            var glass=Material("Goose/ReferenceGlass",Color.white);glass.SetFloat("_Opacity",.1f);
            var target=Box("opaque-target",new Vector3(100,100,100),new Vector3(.8f,.1f,.8f),opaque);
            var cover=Box("transparent-cover",new Vector3(100,100.3f,100),new Vector3(1.4f,.1f,1.4f),glass);
            var camera=Camera();Physics.SyncTransforms();
            Assert.IsTrue(Physics.Raycast(camera.transform.position,Vector3.down,out var first,10,1<<25));
            Assert.AreSame(cover.SelectionCollider,first.collider,"the unchanged physics proxy really blocks the center ray");
            var withTarget=Center(camera);target.Renderers[0].enabled=false;var withoutTarget=Center(camera);target.Renderers[0].enabled=true;
            Assert.Greater(Mathf.Abs(withTarget.r-withoutTarget.r),.15f,"original shaders prove the red mesh remains visible through the glass");
            var hits=new RaycastHit[48];
            Assert.IsFalse(GoosePileDepth.ProbeVisualCoverage(target,camera,item=>item==cover,hits,out int glassQueries));
            Assert.LessOrEqual(glassQueries,64);Assert.IsFalse(cover.VisualOccluder);
            cover.Renderers[0].sharedMaterial=opaque;Assert.IsTrue(cover.RefreshVisualOcclusionCache());
            Assert.IsTrue(GoosePileDepth.ProbeVisualCoverage(target,camera,item=>item==cover,hits,out int opaqueQueries),
                "the same geometry is a valid cover once every material is truly opaque");
            Assert.LessOrEqual(opaqueQueries,64);
        }

        [Test] public void MaterialChangesInvalidateButDepthRendererPublicationDoesNot()
        {
            var opaque=Material("Goose/ItemMobile",Color.white);var glass=Material("Goose/ReferenceGlass",Color.white);
            var item=Box("cache",new Vector3(100,100,100),Vector3.one,opaque);int version=item.VisualMaterialRevision;
            Assert.IsTrue(item.VisualOccluder);item.SetDepthVisible(false);
            Assert.IsFalse(item.RefreshVisualOcclusionCache());Assert.AreEqual(version,item.VisualMaterialRevision);
            Assert.IsTrue(item.VisualOccluder,"depth output cannot invalidate its own occluder input");
            item.Renderers[0].sharedMaterial=glass;Assert.IsTrue(item.RefreshVisualOcclusionCache());Assert.IsFalse(item.VisualOccluder);
            item.Renderers[0].sharedMaterial=opaque;Assert.IsTrue(item.RefreshVisualOcclusionCache());Assert.IsTrue(item.VisualOccluder);
            item.Renderers[0].forceRenderingOff=true;Assert.IsTrue(item.RefreshVisualOcclusionCache());Assert.IsFalse(item.VisualOccluder);
            item.Renderers[0].forceRenderingOff=false;item.RefreshVisualOcclusionCache();
            item.gameObject.SetActive(false);Assert.IsTrue(item.RefreshVisualOcclusionCache());Assert.IsFalse(item.VisualOccluder);
            item.gameObject.SetActive(true);item.RefreshVisualOcclusionCache();item.ResetForReuse();
            Assert.IsFalse(item.VisualOccluder);Assert.AreEqual(0,item.VisualMaterialRevision);
        }

        [Test] public void MixedCutoutAndUnknownMaterialsAreConservativeNonOccluders()
        {
            var opaque=Material("Goose/ItemMobile",Color.white);var glass=Material("Goose/ReferenceGlass",Color.white);
            var item=Box("mixed",new Vector3(100,100,100),Vector3.one,opaque);
            item.Renderers[0].sharedMaterials=new[]{opaque,glass};item.RefreshVisualOcclusionCache();Assert.IsFalse(item.VisualOccluder);
            var cutout=Material("Standard",Color.white);cutout.SetFloat("_Mode",1);cutout.EnableKeyword("_ALPHATEST_ON");
            cutout.SetOverrideTag("RenderType","TransparentCutout");cutout.renderQueue=2450;
            item.Renderers[0].sharedMaterial=cutout;item.RefreshVisualOcclusionCache();Assert.IsFalse(item.VisualOccluder);
            var unknown=Material("Unlit/Color",Color.white);item.Renderers[0].sharedMaterial=unknown;
            item.RefreshVisualOcclusionCache();Assert.IsFalse(item.VisualOccluder,"an arbitrary opaque-looking shader is not certified by its tag alone");
        }

        [Test] public void AuthoredBoundsSurviveOpeningScaleAndThinProxyCannotHideVisibleRim()
        {
            var material=Material("Goose/ItemMobile",Color.white);
            var root=new GameObject("target");created.Add(root);root.layer=25;root.transform.position=new Vector3(100,100,100);
            var visual=GameObject.CreatePrimitive(PrimitiveType.Cube);visual.transform.SetParent(root.transform,false);
            visual.transform.localScale=new Vector3(.8f,.1f,.8f);visual.GetComponent<Renderer>().sharedMaterial=material;
            Object.DestroyImmediate(visual.GetComponent<BoxCollider>());
            root.AddComponent<BoxCollider>().size=new Vector3(.8f,.1f,.8f);
            var target=root.AddComponent<GooseItem>();target.Id="target";target.Visual=visual.transform;
            target.Body=root.AddComponent<Rigidbody>();target.Body.isKinematic=true;target.Body.useGravity=false;target.CacheParts();
            var authored=target.OcclusionVisualBounds;Assert.Greater(authored.size.sqrMagnitude,.5f);
            visual.transform.localScale=Vector3.zero;
            Assert.AreEqual(authored,target.OcclusionVisualBounds);
            var cover=Box("small-cover",new Vector3(100,100.3f,100),new Vector3(.6f,.1f,.6f),material);
            Physics.SyncTransforms();
            Assert.IsFalse(GoosePileDepth.ProbeVisualCoverage(target,Camera(),item=>item==cover,new RaycastHit[48],out _));
        }

        [Test] public void AccelerometerStreamSurvivesAutomaticTransitionButStopsOnPauseAndHome()
        {
            Assert.IsTrue(GooseWeChatPlatform.KeepAccelerometer(true,false,false,true));
            Assert.IsTrue(GooseWeChatPlatform.KeepAccelerometer(false,true,false,true));
            Assert.IsTrue(GooseWeChatPlatform.KeepAccelerometer(true,false,false,true),"challenge preparation keeps the existing stream");
            Assert.IsFalse(GooseWeChatPlatform.KeepAccelerometer(false,false,false,true));
            Assert.IsFalse(GooseWeChatPlatform.KeepAccelerometer(true,true,true,true));
            Assert.IsFalse(GooseWeChatPlatform.KeepAccelerometer(true,true,false,false));
        }
    }
}
