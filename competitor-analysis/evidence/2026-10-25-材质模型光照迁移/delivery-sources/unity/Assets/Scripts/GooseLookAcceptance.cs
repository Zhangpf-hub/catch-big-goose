#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    public sealed class GooseLookAcceptance:MonoBehaviour
    {
        [Serializable] class Report
        {
            public string build=GooseRuntimePerformance.BuildId,scope="Actual native mobile-profile shader rendering; no connected phone FPS or exact source shader equivalence claimed.";
            public bool passed;public int models,fourViews,icons,sourceMaterials,glassMaterials,colorOnlyMaterials;
            public float materialDifference,shadowDifference;public List<string> errors=new List<string>();
        }
        readonly Report report=new Report();string output;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot()
        {if(Array.IndexOf(Environment.GetCommandLineArgs(),"-gooseLookQa")>=0)new GameObject("LookAcceptance").AddComponent<GooseLookAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string message,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception||type==LogType.Assert)report.errors.Add(message+"\n"+stack);}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-gooseLookOutput")+1];Directory.CreateDirectory(output);
            GooseSave.IsQa=true;yield return null;var game=GooseGame.Instance;game.GoHome();
            game.ReferenceLighting.ToggleShadows();game.ReferenceLighting.Apply(true);game.ReferenceLighting.ToggleShadows();
            if(QualitySettings.shadows!=UnityEngine.ShadowQuality.HardOnly)report.errors.Add("Shadow switch did not recover after scene reset");
            game.BeginReferenceTrial(126);
            float deadline=Time.realtimeSinceStartup+60;
            while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
            if(!game.SpawnComplete){report.errors.Add("Spawn deadline");Finish();yield break;}
            yield return new WaitForSeconds(2);game.SetPaused(true);
            game.ReferenceLighting.Comparison(true);yield return null;
            var flat=Path.Combine(output,"same-pile-flat.png");GooseFrameCapture.Save(flat,Screen.width,Screen.height);
            game.ReferenceLighting.Comparison(false);game.ReferenceLighting.ToggleShadows();yield return null;
            var unshadowed=Path.Combine(output,"same-pile-matcap.png");GooseFrameCapture.Save(unshadowed,Screen.width,Screen.height);
            game.ReferenceLighting.ToggleShadows();yield return null;
            var migrated=Path.Combine(output,"same-pile-migrated.png");GooseFrameCapture.Save(migrated,Screen.width,Screen.height);
            report.materialDifference=Difference(flat,unshadowed);report.shadowDifference=Difference(unshadowed,migrated);
            if(report.materialDifference<.005f)report.errors.Add("Material comparison produced insufficient pixel difference");
            if(report.shadowDifference<.0001f)report.errors.Add("Shadow comparison produced insufficient pixel difference");
            game.SetPaused(false);game.GoHome();game.ReferenceLighting.Apply(true);
            var camera=new GameObject("MaterialTurntableCamera").AddComponent<Camera>();camera.enabled=false;camera.orthographic=true;camera.orthographicSize=.72f;
            camera.clearFlags=CameraClearFlags.SolidColor;camera.backgroundColor=Color.clear;camera.cullingMask=1<<27;
            var reference=JsonUtility.FromJson<ReferenceMaterialCatalog>(Resources.Load<TextAsset>("Data/reference-material-models").text);
            var angles=new[]{new Vector3(0,1.6f,2.5f),new Vector3(2.5f,1.6f,0),new Vector3(0,1.6f,-2.5f),new Vector3(2,1.6f,2)};
            var names=new[]{"front","side","back","three-quarter"};
            foreach(var model in reference.models)
            {
                string id=model.id;int noTexture=0;
                var root=new GameObject("TurntableItem");var visual=game.LoadVisual(id,root.transform);Layer(root.transform,27);
                foreach(var renderer in visual.GetComponentsInChildren<Renderer>())foreach(var material in renderer.sharedMaterials)
                {
                    report.sourceMaterials++;if(material.shader.name=="Goose/ReferenceGlass")report.glassMaterials++;
                    if(!material.shader.isSupported||!material.shader.name.StartsWith("Goose/Reference"))report.errors.Add(id+" shader unsupported or replaced");
                    if(!material.mainTexture)
                    {report.colorOnlyMaterials++;noTexture++;}
                }
                if(noTexture!=model.colorOnlyMaterials)report.errors.Add(id+" source color-only material count differs");
                string folder=Path.Combine(output,"models",id);Directory.CreateDirectory(folder);
                for(int i=0;i<4;i++)
                {camera.transform.position=angles[i];camera.transform.LookAt(Vector3.zero);Capture(camera,Path.Combine(folder,names[i]+".png"),256);report.fourViews++;yield return null;}
                // Source model forward axes differ. Keep the runtime pose intact;
                // select a readable face for these generated tray icons only.
                if(id=="ref_gtcrocodile"||id=="ref_gtdinosaur"||id=="ref_gtplaydough")
                {camera.transform.position=angles[2];camera.transform.LookAt(Vector3.zero);}
                Capture(camera,Path.Combine(folder,"icon-192.png"),192);Capture(camera,Path.Combine(folder,"icon-64.png"),64);report.icons+=2;
                root.SetActive(false);Destroy(root);report.models++;yield return null;
            }
            Destroy(camera.gameObject);game.ReferenceLighting.Apply(false);
            if(report.models!=reference.models.Length||report.sourceMaterials!=reference.models.Sum(x=>x.materials)||report.glassMaterials!=reference.models.Sum(x=>x.glassMaterials)||report.colorOnlyMaterials!=reference.models.Sum(x=>x.colorOnlyMaterials))report.errors.Add("Source material/preview totals disagree");
            Finish();
        }
        static void Layer(Transform root,int layer){root.gameObject.layer=layer;foreach(Transform child in root)Layer(child,layer);}
        static void Capture(Camera camera,string path,int size)
        {
            var rt=RenderTexture.GetTemporary(size,size,24,RenderTextureFormat.ARGB32);camera.targetTexture=rt;camera.Render();var old=RenderTexture.active;RenderTexture.active=rt;
            var texture=new Texture2D(size,size,TextureFormat.RGBA32,false);texture.ReadPixels(new Rect(0,0,size,size),0,0);texture.Apply();File.WriteAllBytes(path,texture.EncodeToPNG());
            RenderTexture.active=old;camera.targetTexture=null;RenderTexture.ReleaseTemporary(rt);Destroy(texture);
        }
        static float Difference(string first,string second)
        {
            var a=new Texture2D(2,2);var b=new Texture2D(2,2);a.LoadImage(File.ReadAllBytes(first));b.LoadImage(File.ReadAllBytes(second));
            var aa=a.GetPixels32();var bb=b.GetPixels32();double sum=0;for(int i=0;i<aa.Length;i++)sum+=Math.Abs(aa[i].r-bb[i].r)+Math.Abs(aa[i].g-bb[i].g)+Math.Abs(aa[i].b-bb[i].b);
            Destroy(a);Destroy(b);return(float)(sum/(aa.Length*3*255.0));
        }
        void Finish(){report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"look-acceptance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);}
    }
}
#endif
