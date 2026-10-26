#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    public static class GooseFrameCapture
    {
        public static void Save(string file,int width=450,int height=844)
        {
            var rt=RenderTexture.GetTemporary(width,height,24,RenderTextureFormat.ARGB32);
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
            camera.Render();var active=RenderTexture.active;RenderTexture.active=rt;
            var image=new Texture2D(width,height,TextureFormat.RGBA32,false);image.ReadPixels(new Rect(0,0,width,height),0,0);image.Apply();
            File.WriteAllBytes(file,image.EncodeToPNG());RenderTexture.active=active;
            foreach(var canvas in overlays){canvas.renderMode=RenderMode.ScreenSpaceOverlay;canvas.worldCamera=null;}
            foreach(var pair in layers)pair.Key.layer=pair.Value;
            Object.Destroy(image);Object.Destroy(go);RenderTexture.ReleaseTemporary(rt);
        }
    }
}
#endif
