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
            if(GooseRuntimePerformance.Mobile)
            {
                var shader=Resources.Load<Shader>("GooseItemMobile");
                if(!shader)throw new InvalidOperationException("Mobile item shader missing");
                foreach(var renderer in prefab.GetComponentsInChildren<Renderer>(true))
                {
                    var materials=renderer.sharedMaterials;
                    entry.originals.Add(renderer,(Material[])materials.Clone());
                    for(int i=0;i<materials.Length;i++)
                    {
                        var original=materials[i];
                        if(!mobileMaterials.TryGetValue(original,out var material))
                        {material=new Material(shader){name=original.name+"_Mobile",mainTexture=original.mainTexture,color=original.color,enableInstancing=true};mobileMaterials.Add(original,material);}
                        materials[i]=material;
                    }
                    renderer.sharedMaterials=materials;renderer.shadowCastingMode=UnityEngine.Rendering.ShadowCastingMode.Off;renderer.receiveShadows=false;
                }
            }
            models.Add(id,entry);obj.SetActive(false);UnityEngine.Object.Destroy(obj);
            // Item collision uses independent baked proxies. Retaining readable
            // render vertices duplicates memory on the phone for no gameplay use.
            if(releaseRenderCpu && GooseRuntimePerformance.Mobile && !Application.isEditor)
                foreach(var filter in prefab.GetComponentsInChildren<MeshFilter>(true))
                    if(filter.sharedMesh && filter.sharedMesh.isReadable)filter.sharedMesh.UploadMeshData(true);
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
        public GameObject Instantiate(string id,Transform parent)
        {
            if(!models.TryGetValue(id,out var model)) {AddModel(id,Resources.Load<GameObject>("Models/"+id+"/"+id));model=models[id];}
            var obj=UnityEngine.Object.Instantiate(model.prefab,parent);obj.name=id+"_visual";obj.transform.localPosition=model.offset;obj.transform.localScale=model.scale;return obj;
        }
        public Mesh Hull(string id)
        {
            if(!hulls.TryGetValue(id,out var mesh)){mesh=Resources.Load<Mesh>("Physics/"+id);if(mesh)hulls.Add(id,mesh);}
            return mesh;
        }
    }
}
