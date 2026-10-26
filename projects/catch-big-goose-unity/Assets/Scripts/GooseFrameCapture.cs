#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    public static class GooseFrameCapture
    {
        public static void Save(string file,int width=0,int height=0)
        {
            // Preserve the current screen aspect: changing target width alone
            // rescales camera canvases while safe-area transforms stay unchanged.
            if(width<=0)width=Screen.width;if(height<=0)height=Screen.height;
            var descriptor=new RenderTextureDescriptor(width,height,RenderTextureFormat.ARGB32,24){msaaSamples=Mathf.Max(1,QualitySettings.antiAliasing)};
            descriptor.msaaSamples=SystemInfo.GetRenderTextureSupportedMSAASampleCount(descriptor);
            var rt=RenderTexture.GetTemporary(descriptor);
            var go=new GameObject("CaptureCamera");var camera=go.AddComponent<Camera>();
            camera.orthographic=true;camera.clearFlags=CameraClearFlags.Depth;camera.cullingMask=1<<31;
            camera.transform.position=new Vector3(0,0,-10);camera.targetTexture=rt;
            var overlays=Object.FindObjectsOfType<Canvas>().Where(c=>c.renderMode==RenderMode.ScreenSpaceOverlay).ToList();
            var layers=new Dictionary<GameObject,int>();
            foreach(var canvas in overlays)
            {
                foreach(var tr in canvas.GetComponentsInChildren<Transform>(true)){layers[tr.gameObject]=tr.gameObject.layer;tr.gameObject.layer=31;}
                canvas.renderMode=RenderMode.ScreenSpaceCamera;canvas.worldCamera=camera;canvas.planeDistance=10;
            }
            Canvas.ForceUpdateCanvases();
            foreach(var view in Object.FindObjectsOfType<Camera>().Where(c=>c!=camera&&c.enabled).OrderBy(c=>c.depth))
            {
                int mask=view.cullingMask;var target=view.targetTexture;view.cullingMask&=~(1<<31);
                view.targetTexture=rt;view.Render();view.targetTexture=target;view.cullingMask=mask;
            }
            camera.Render();var resolved=RenderTexture.GetTemporary(width,height,0,RenderTextureFormat.ARGB32);
            Graphics.Blit(rt,resolved);var active=RenderTexture.active;RenderTexture.active=resolved;
            var image=new Texture2D(width,height,TextureFormat.RGBA32,false);image.ReadPixels(new Rect(0,0,width,height),0,0);image.Apply();
            File.WriteAllBytes(file,image.EncodeToPNG());RenderTexture.active=active;
            foreach(var canvas in overlays){canvas.renderMode=RenderMode.ScreenSpaceOverlay;canvas.worldCamera=null;}
            foreach(var pair in layers)pair.Key.layer=pair.Value;
            Object.Destroy(image);Object.Destroy(go);RenderTexture.ReleaseTemporary(rt);RenderTexture.ReleaseTemporary(resolved);
        }
    }
}
#endif
