using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace CatchGoose
{
    // Load only the current round, one asset integration per frame. The cache
    // avoids repeating path lookup, normalization scans and convex preparation.
    public sealed class GooseAssetCache
    {
        sealed class Model { public GameObject prefab; public Vector3 scale, offset; public readonly Dictionary<Renderer, Material[]> originals = new Dictionary<Renderer, Material[]>(); }
        readonly Dictionary<string, Model> models = new Dictionary<string, Model>();
        readonly Dictionary<string, Mesh> hulls = new Dictionary<string, Mesh>();
        readonly Dictionary<Material, Material> mobileMaterials = new Dictionary<Material, Material>();
        public int ModelCount => models.Count;
        public string GeometryKey(HashSet<string> requested=null)
        {
            var ids=new List<string>(models.Keys);if(requested!=null)ids.RemoveAll(id=>!requested.Contains(id));ids.Sort(StringComparer.Ordinal);var key=new System.Text.StringBuilder();
            foreach(var id in ids)
            {
                var m=models[id];key.Append(id).Append(JsonUtility.ToJson(m.scale)).Append(JsonUtility.ToJson(m.offset));
                if(hulls.TryGetValue(id,out var hull))foreach(var v in hull.vertices)key.Append(JsonUtility.ToJson(v));
            }
            return Hash128.Compute(key.ToString()).ToString();
        }
        public bool Retain(HashSet<string> ids)
        {
            var remove=new List<string>();foreach(var id in models.Keys)if(!ids.Contains(id))remove.Add(id);
            foreach(var id in remove){models.Remove(id);hulls.Remove(id);}return remove.Count>0;
        }
        public void Clear()
        {
            foreach(var model in models.Values) foreach(var entry in model.originals) if(entry.Key) entry.Key.sharedMaterials=entry.Value;
            foreach(var material in mobileMaterials.Values) if(material) UnityEngine.Object.Destroy(material);
            models.Clear();hulls.Clear();mobileMaterials.Clear();
        }
        void AddModel(string id, GameObject prefab, bool releaseRenderCpu = false)
        {
            if (!prefab) throw new InvalidOperationException("Missing model: " + id);
            var obj = UnityEngine.Object.Instantiate(prefab);obj.transform.localPosition=Vector3.zero;
            var bounds = GooseGame.BoundsOf(obj);float max = Mathf.Max(bounds.size.x, bounds.size.y, bounds.size.z);
            if(max < .00001f)throw new InvalidOperationException("Empty model: "+id);
            var entry = new Model { prefab = prefab, scale = obj.transform.localScale / max, offset = -bounds.center / max };
            models.Add(id,entry);obj.SetActive(false);UnityEngine.Object.Destroy(obj);
            // Cache effect geometry before mobile upload releases the CPU copy.
            GooseSelectionGeometry.Prepare(prefab);
            // Render meshes are independent from the offline collision proxies.
            if(releaseRenderCpu && GooseRuntimePerformance.Mobile && !Application.isEditor)
                foreach(var filter in prefab.GetComponentsInChildren<MeshFilter>(true))
                    if(filter.sharedMesh && filter.sharedMesh.isReadable)filter.sharedMesh.UploadMeshData(true);
        }
        void MobileMaterials(GameObject obj)
        {
            if(GooseRuntimePerformance.Mobile)
            {
                var shader=Resources.Load<Shader>("GooseItemMobile");
                if(!shader)throw new InvalidOperationException("Mobile item shader missing");
                foreach(var renderer in obj.GetComponentsInChildren<Renderer>(true))
                {
                    var materials=renderer.sharedMaterials;
                    for(int i=0;i<materials.Length;i++)
                    {
                        var original=materials[i];
                        if(original.shader.name.StartsWith("Goose/Reference")||original.shader.name=="Goose/DuckMobile")continue;
                        if(!mobileMaterials.TryGetValue(original,out var material))
                        {material=new Material(shader){name=original.name+"_Mobile",mainTexture=original.mainTexture,color=original.color,enableInstancing=true};mobileMaterials.Add(original,material);}
                        materials[i]=material;
                    }
                    renderer.sharedMaterials=materials;renderer.shadowCastingMode=UnityEngine.Rendering.ShadowCastingMode.Off;renderer.receiveShadows=false;
                    if(materials[0].shader.name=="Goose/ReferenceOpaque")
                    {renderer.shadowCastingMode=UnityEngine.Rendering.ShadowCastingMode.On;renderer.receiveShadows=true;}
                }
            }
        }
        public IEnumerator Prepare(string id, bool physics)
        {
            if(!models.ContainsKey(id))
            {
                var request=Resources.LoadAsync<GameObject>("Models/"+id+"/"+id);yield return request;
                AddModel(id,request.asset as GameObject,physics);yield return null;
            }
            if(physics && !hulls.ContainsKey(id))
            {
                var request=Resources.LoadAsync<Mesh>("Physics/"+id);yield return request;
                var mesh=request.asset as Mesh;
                if(!mesh)throw new InvalidOperationException("Missing baked collision mesh: "+id+"; run Goose/Prepare Project");
                hulls.Add(id,mesh);Physics.BakeMesh(mesh.GetInstanceID(),true);yield return null;
            }
        }
        public IEnumerator PrepareMany(string container,string[] ids)
        {
            // A small concurrent window removes per-asset idle frames while
            // Unity's low background-loading priority bounds main-thread integration.
            var all=new List<string>(ids);if(!all.Contains(container))all.Insert(0,container);
            var prefabs=new ResourceRequest[4];var proxies=new ResourceRequest[4];
            float frame=Time.realtimeSinceStartup;
            for(int begin=0;begin<all.Count;begin+=4)
            {
                int count=Mathf.Min(4,all.Count-begin);
                for(int i=0;i<count;i++)
                {
                    string id=all[begin+i];prefabs[i]=models.ContainsKey(id)?null:Resources.LoadAsync<GameObject>("Models/"+id+"/"+id);
                    proxies[i]=id==container||hulls.ContainsKey(id)?null:Resources.LoadAsync<Mesh>("Physics/"+id);
                }
                bool waiting=true;
                while(waiting)
                {
                    waiting=false;for(int i=0;i<count;i++)if((prefabs[i]!=null&&!prefabs[i].isDone)||(proxies[i]!=null&&!proxies[i].isDone))waiting=true;
                    if(waiting){yield return null;frame=Time.realtimeSinceStartup;}
                }
                for(int i=0;i<count;i++)
                {
                    string id=all[begin+i];if(prefabs[i]!=null)AddModel(id,prefabs[i].asset as GameObject,id!=container);
                    if(proxies[i]!=null)
                    {var mesh=proxies[i].asset as Mesh;if(!mesh)throw new InvalidOperationException("Missing collision proxy: "+id);hulls.Add(id,mesh);Physics.BakeMesh(mesh.GetInstanceID(),true);}
                    if(Time.realtimeSinceStartup-frame>.002f){yield return null;frame=Time.realtimeSinceStartup;}
                }
            }
        }
        public GameObject Instantiate(string id,Transform parent)
        {
            if(!models.TryGetValue(id,out var model)) {AddModel(id,Resources.Load<GameObject>("Models/"+id+"/"+id));model=models[id];}
            var obj=UnityEngine.Object.Instantiate(model.prefab,parent);obj.name=id+"_visual";obj.transform.localPosition=model.offset;obj.transform.localScale=model.scale;MobileMaterials(obj);return obj;
        }
        public Mesh Hull(string id)
        {
            if(!hulls.TryGetValue(id,out var mesh)){mesh=Resources.Load<Mesh>("Physics/"+id);if(mesh)hulls.Add(id,mesh);}
            return mesh;
        }
    }
}
