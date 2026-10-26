// Isolated editor audit. This is intentionally not installed into the live game.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

public static class DuckB2UnityAudit
{
    [Serializable] public sealed class ModelResult
    {
        public string id, shader, visualHash, collisionHash;
        public int triangles, renderers, subMeshes, materials, collisionTriangles;
        public Vector3 size, center;
        public float hullVertexDistance;
        public bool baseColorSrgb, metallicLinear, metallicEnabled, convexRaycast;
    }
    [Serializable] public sealed class ClipResult
    {
        public string name;
        public float seconds, maximumVertexMotion, returnToRestError;
        public int movingVertices;
    }
    [Serializable] public sealed class Report
    {
        public string unityVersion, scope="Isolated Unity editor: imported FBX/materials, baked skin vertices and manual PhysX simulation. Not production game/tray/match or homepage acceptance.";
        public bool passed, productionGameVerified=false, homepageReplaced=false;
        public int bodyCount, sleepingAfter15Seconds, sleepingAfterRemoval;
        public float maximumSpeedAfter15Seconds, maxSpeedAfterRemoval;
        public List<ModelResult> models=new List<ModelResult>();
        public List<ClipResult> clips=new List<ClipResult>();
        public List<string> checks=new List<string>(), errors=new List<string>();
    }
    static readonly string[] Ids={"duck-eggtart","duck-steelcup","duck-numberblock"};
    static readonly Dictionary<string,Mesh> Hulls=new Dictionary<string,Mesh>();
    static readonly Dictionary<string,GameObject> Models=new Dictionary<string,GameObject>();
    static Report report;
    static string output;
    static Camera camera;
    static void Check(bool condition,string text)
    { (condition?report.checks:report.errors).Add(text); if(!condition)Debug.LogWarning("[DuckB2] "+text); }
    static string Hash(string path)
    { using(var h=System.Security.Cryptography.SHA256.Create())return BitConverter.ToString(h.ComputeHash(File.ReadAllBytes(path))).Replace("-","").ToLowerInvariant(); }
    static void Logs(string text,string stack,LogType type)
    { if(type==LogType.Error || type==LogType.Exception || type==LogType.Assert)report.errors.Add(text); }
    public static void Run()
    {
        output=Path.GetFullPath("audit-output");Directory.CreateDirectory(output);
        report=new Report{unityVersion=Application.unityVersion};Application.logMessageReceived+=Logs;
        try
        {
            Check(Application.unityVersion=="2022.3.62f3","Required Unity editor version");
            EditorSceneManager.NewScene(NewSceneSetup.EmptyScene,NewSceneMode.Single);
            PlayerSettings.colorSpace=ColorSpace.Linear;
            QualitySettings.antiAliasing=4;QualitySettings.shadows=ShadowQuality.All;
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            Studio();
            foreach(string id in Ids)ImportStatic(id);
            AuditAnimation();
            AuditPhysics();
            AssetDatabase.SaveAssets();
        }
        catch(Exception e){report.errors.Add(e.ToString());}
        finally
        {
            Application.logMessageReceived-=Logs;Physics.autoSimulation=true;
            report.passed=report.errors.Count==0;
            File.WriteAllText(Path.Combine(output,"unity-audit.json"),JsonUtility.ToJson(report,true));
            Debug.Log("DUCK_B2_UNITY_AUDIT "+report.passed);
        }
        EditorApplication.Exit(report.passed?0:1);
    }
    static void Texture(string path,bool srgb)
    {
        var imp=(TextureImporter)AssetImporter.GetAtPath(path);
        imp.textureType=TextureImporterType.Default;imp.sRGBTexture=srgb;
        imp.mipmapEnabled=false;imp.textureCompression=TextureImporterCompression.Uncompressed;
        imp.filterMode=FilterMode.Point;imp.wrapMode=TextureWrapMode.Clamp;imp.maxTextureSize=256;
        imp.alphaSource=TextureImporterAlphaSource.FromInput;imp.isReadable=true;imp.SaveAndReimport();
    }
    static Material MaterialAt(string folder,bool metallic)
    {
        Texture(folder+"/albedo.png",true);
        if(metallic)Texture(folder+"/unity-metallic.png",false);
        string path=folder+"/duck.mat";
        var mat=AssetDatabase.LoadAssetAtPath<Material>(path);
        if(!mat){mat=new Material(Shader.Find("Standard"));AssetDatabase.CreateAsset(mat,path);}
        mat.mainTexture=AssetDatabase.LoadAssetAtPath<Texture2D>(folder+"/albedo.png");
        mat.color=Color.white;mat.enableInstancing=true;mat.SetFloat("_Glossiness",.4f);
        if(metallic)
        {
            mat.SetTexture("_MetallicGlossMap",AssetDatabase.LoadAssetAtPath<Texture2D>(folder+"/unity-metallic.png"));
            mat.SetFloat("_GlossMapScale",1);mat.SetFloat("_SmoothnessTextureChannel",0);mat.EnableKeyword("_METALLICGLOSSMAP");
        }
        EditorUtility.SetDirty(mat);return mat;
    }
    static GameObject Imported(string path,Material mat,bool animation)
    {
        var imp=(ModelImporter)AssetImporter.GetAtPath(path);
        imp.importCameras=false;imp.importLights=false;imp.isReadable=true;
        imp.meshCompression=ModelImporterMeshCompression.Off;imp.importAnimation=animation;
        imp.animationType=animation?ModelImporterAnimationType.Legacy:ModelImporterAnimationType.None;
        imp.animationCompression=ModelImporterAnimationCompression.Off;
        imp.SaveAndReimport();
        if(mat)
        {
            var asset=AssetDatabase.LoadAssetAtPath<GameObject>(path);
            var names=asset.GetComponentsInChildren<Renderer>().SelectMany(r=>r.sharedMaterials).Where(m=>m).Select(m=>m.name).Distinct().ToArray();
            foreach(string name in names)imp.AddRemap(new AssetImporter.SourceAssetIdentifier(typeof(Material),name),mat);
            imp.SaveAndReimport();
        }
        return Object.Instantiate(AssetDatabase.LoadAssetAtPath<GameObject>(path));
    }
    static Bounds BoundsOf(GameObject obj)
    { var rs=obj.GetComponentsInChildren<Renderer>();var b=rs[0].bounds;foreach(var r in rs.Skip(1))b.Encapsulate(r.bounds);return b; }
    static Mesh WorldMesh(GameObject obj)
    {
        var mesh=new Mesh{name=obj.name+"-world"};
        mesh.CombineMeshes(obj.GetComponentsInChildren<MeshFilter>().Select(f=>new CombineInstance{mesh=f.sharedMesh,transform=f.transform.localToWorldMatrix}).ToArray(),true,true);
        mesh.RecalculateBounds();return mesh;
    }
    static void ImportStatic(string id)
    {
        string folder="Assets/candidates/"+id,path=folder+"/"+id+".fbx";
        var mat=MaterialAt(folder,true);var visual=Imported(path,mat,false);
        // FBX's axis/unit conversion lives on its imported root. Keep the
        // already-transformed hull on a separate identity root, as the game does.
        var obj=new GameObject(id);visual.transform.SetParent(obj.transform,true);
        var rs=obj.GetComponentsInChildren<Renderer>();var fs=obj.GetComponentsInChildren<MeshFilter>();
        var bounds=BoundsOf(obj);var world=WorldMesh(obj);
        var hullObj=Imported(folder+"/collision.fbx",null,false);var hull=WorldMesh(hullObj);
        Object.DestroyImmediate(hullObj);Hulls[id]=hull;
        float match=hull.vertices.Max(v=>world.vertices.Min(p=>Vector3.Distance(p,v)));
        var result=new ModelResult{id=id,triangles=fs.Sum(f=>f.sharedMesh.triangles.Length/3),renderers=rs.Length,
            subMeshes=fs.Sum(f=>f.sharedMesh.subMeshCount),materials=rs.Sum(r=>r.sharedMaterials.Length),
            size=bounds.size,center=bounds.center,shader=rs[0].sharedMaterial.shader.name,
            collisionTriangles=hull.triangles.Length/3,hullVertexDistance=match,
            baseColorSrgb=((TextureImporter)AssetImporter.GetAtPath(folder+"/albedo.png")).sRGBTexture,
            metallicLinear=!((TextureImporter)AssetImporter.GetAtPath(folder+"/unity-metallic.png")).sRGBTexture,
            metallicEnabled=mat.IsKeywordEnabled("_METALLICGLOSSMAP"),visualHash=Hash(path),collisionHash=Hash(folder+"/collision.fbx")};
        Check(result.triangles<=4000&&result.triangles>=2000,id+" imported triangle budget");
        int expectedTriangles=id=="duck-eggtart"?3752:id=="duck-steelcup"?3940:3820;
        Check(result.triangles==expectedTriangles,id+" FBX triangle count matches validated GLB");
        Check(result.renderers==1&&result.subMeshes==1&&result.materials==1,id+" one mesh renderer/submesh/material");
        Check(Mathf.Abs(Mathf.Max(bounds.size.x,bounds.size.y,bounds.size.z)-1)<.0001f&&bounds.center.magnitude<.0001f,id+" unit extent and centered import");
        Check(result.baseColorSrgb&&result.metallicLinear&&result.metallicEnabled&&rs.All(r=>r.sharedMaterial==mat),id+" actual texture color spaces and material remap");
        Check(match<.0001f&&result.collisionTriangles<255,id+" collision hull aligned with actual imported geometry");
        var collider=obj.AddComponent<MeshCollider>();collider.sharedMesh=hull;collider.convex=true;Physics.SyncTransforms();
        result.convexRaycast=collider.Raycast(new Ray(bounds.center+Vector3.up*2,Vector3.down),out var hit,4);
        Check(result.convexRaycast,id+" PhysX convex cooking and direct raycast");Object.DestroyImmediate(collider);
        Capture(id+"-hero",new Vector3(-2.3f,1.5f,4),Vector3.zero,.74f);
        Capture(id+"-gameplay",new Vector3(-1.8f,4,3),Vector3.zero,.74f);
        obj.SetActive(false);Models[id]=obj;report.models.Add(result);Object.DestroyImmediate(world);
    }
    static void AuditAnimation()
    {
        string folder="Assets/candidates/duck-b2-home",path=folder+"/duck-b2-home.fbx";
        var obj=Imported(path,MaterialAt(folder,false),true);var skin=obj.GetComponentInChildren<SkinnedMeshRenderer>();
        Check(skin!=null,"Mother imports an actual skinned mesh");if(!skin){Object.DestroyImmediate(obj);return;}
        var clips=AssetDatabase.LoadAllAssetsAtPath(path).OfType<AnimationClip>().Where(c=>!c.name.StartsWith("__preview__")).ToArray();
        Check(clips.Length==3&&new[]{"duck_idle","duck_greet","duck_click"}.All(n=>clips.Any(c=>c.name.EndsWith(n))),"All three original actions imported");
        foreach(var clip in clips)
        {
            var baked=new Mesh();clip.SampleAnimation(obj,0);skin.BakeMesh(baked);var first=baked.vertices;
            var row=new ClipResult{name=clip.name,seconds=clip.length};
            for(int frame=1;frame<=30;frame++)
            {
                clip.SampleAnimation(obj,clip.length*frame/30);skin.BakeMesh(baked);var vs=baked.vertices;
                float max=0;int moving=0;for(int i=0;i<vs.Length;i++){float d=Vector3.Distance(first[i],vs[i]);max=Mathf.Max(max,d);if(d>.00001f)moving++;}
                row.maximumVertexMotion=Mathf.Max(row.maximumVertexMotion,max);row.movingVertices=Mathf.Max(row.movingVertices,moving);
                if(frame==30)row.returnToRestError=max;
            }
            Check(row.maximumVertexMotion>.003f,clip.name+" changes actual Unity baked mesh vertices");
            Check(row.returnToRestError<.0001f,clip.name+" returns to rest");
            clip.SampleAnimation(obj,clip.length*.25f);Capture(clip.name.Replace('|','-')+"-pose",new Vector3(-2.3f,1.1f,4),Vector3.zero,.68f);
            report.clips.Add(row);Object.DestroyImmediate(baked);
        }
        Object.DestroyImmediate(obj);
    }
    static void AuditPhysics()
    {
        Physics.autoSimulation=false;Physics.gravity=new Vector3(0,-9.81f,0);
        var arena=new GameObject("PhysX arena");
        var walls=new[]{new[]{new Vector3(0,-.2f,0),new Vector3(4.4f,.4f,4.4f)},
            new[]{new Vector3(-2.3f,2,0),new Vector3(.2f,4,4.8f)},new[]{new Vector3(2.3f,2,0),new Vector3(.2f,4,4.8f)},
            new[]{new Vector3(0,2,-2.3f),new Vector3(4.8f,4,.2f)},new[]{new Vector3(0,2,2.3f),new Vector3(4.8f,4,.2f)}};
        foreach(var w in walls){var o=new GameObject("wall");o.transform.SetParent(arena.transform);o.transform.position=w[0];o.AddComponent<BoxCollider>().size=w[1];}
        var bodies=new List<Rigidbody>();UnityEngine.Random.InitState(1025);
        for(int i=0;i<45;i++)
        {
            string id=Ids[i%3];var root=Object.Instantiate(Models[id],arena.transform);root.SetActive(true);root.name=id+"-"+i;
            root.transform.position=new Vector3(-1.45f+i%5*.72f,1+i/15*1.1f,-.75f+i/5%3*.75f);
            root.transform.rotation=UnityEngine.Random.rotationUniform;root.transform.localScale=Vector3.one*.64f;
            var col=root.AddComponent<MeshCollider>();col.sharedMesh=Hulls[id];col.convex=true;
            var rb=root.AddComponent<Rigidbody>();rb.angularDrag=.3f;rb.collisionDetectionMode=CollisionDetectionMode.ContinuousDynamic;
            bodies.Add(rb);
        }
        Physics.SyncTransforms();for(int i=0;i<900;i++)Physics.Simulate(1f/60);
        report.bodyCount=bodies.Count;report.sleepingAfter15Seconds=bodies.Count(b=>b.IsSleeping());
        report.maximumSpeedAfter15Seconds=bodies.Max(b=>b.velocity.magnitude);
        Check(bodies.All(b=>b.position.y>-.2f&&b.position.y<4&&Mathf.Abs(b.position.x)<2.2f&&Mathf.Abs(b.position.z)<2.2f),"All 45 mixed props remain in arena after 15 seconds");
        Check(report.sleepingAfter15Seconds>=40&&report.maximumSpeedAfter15Seconds<.15f,"At least 40/45 props naturally sleep after 15 seconds; maximum speed below .15 m/s");
        Capture("physx-mixed-pile",new Vector3(5,7,-9),new Vector3(0,.4f,0),3.1f);
        var target=bodies.OrderByDescending(b=>b.position.y).First();
        Check(Physics.Raycast(target.position+Vector3.up*5,Vector3.down,out var hit,10)&&hit.rigidbody,"Dense pile ray reaches an actual rigidbody");
        // Remove a low body to test a genuine support removal, not just a topmost object.
        var support=bodies.OrderBy(b=>b.position.y).First();bodies.Remove(support);Object.DestroyImmediate(support.gameObject);
        for(int i=0;i<300;i++)Physics.Simulate(1f/60);
        report.sleepingAfterRemoval=bodies.Count(b=>b.IsSleeping());report.maxSpeedAfterRemoval=bodies.Max(b=>b.velocity.magnitude);
        Check(bodies.All(b=>b.position.y>-.2f&&Mathf.Abs(b.position.x)<2.2f&&Mathf.Abs(b.position.z)<2.2f),"Support removal leaves all remaining props inside arena");
        Check(report.sleepingAfterRemoval>=39&&report.maxSpeedAfterRemoval<.15f,"Remaining props naturally settle after support removal");
        Object.DestroyImmediate(arena);
    }
    static void Studio()
    {
        RenderSettings.ambientMode=AmbientMode.Trilight;RenderSettings.ambientSkyColor=new Color(.32f,.34f,.37f);
        RenderSettings.ambientEquatorColor=new Color(.18f,.19f,.2f);RenderSettings.ambientGroundColor=new Color(.10f,.10f,.11f);
        var key=new GameObject("key").AddComponent<Light>();key.type=LightType.Directional;key.intensity=.8f;key.transform.rotation=Quaternion.Euler(35,155,0);
        var fill=new GameObject("fill").AddComponent<Light>();fill.type=LightType.Directional;fill.intensity=.25f;fill.transform.rotation=Quaternion.Euler(20,-35,0);
        camera=new GameObject("audit-camera").AddComponent<Camera>();camera.orthographic=true;camera.clearFlags=CameraClearFlags.SolidColor;
        camera.backgroundColor=new Color(.93f,.94f,.92f);camera.nearClipPlane=.01f;camera.farClipPlane=100;
        camera.allowHDR=false;camera.allowMSAA=true;
    }
    static void Capture(string name,Vector3 location,Vector3 target,float ortho)
    {
        camera.transform.position=location;camera.transform.LookAt(target);camera.orthographicSize=ortho;
        var rt=new RenderTexture(512,512,24,RenderTextureFormat.ARGB32){antiAliasing=4};rt.Create();
        camera.targetTexture=rt;camera.Render();var previous=RenderTexture.active;RenderTexture.active=rt;
        var tex=new Texture2D(512,512,TextureFormat.RGB24,false);tex.ReadPixels(new Rect(0,0,512,512),0,0);tex.Apply();
        File.WriteAllBytes(Path.Combine(output,name+".png"),tex.EncodeToPNG());
        RenderTexture.active=previous;camera.targetTexture=null;rt.Release();Object.DestroyImmediate(rt);Object.DestroyImmediate(tex);
    }
}
