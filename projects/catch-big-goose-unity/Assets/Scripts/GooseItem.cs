using System.Collections.Generic;
using UnityEngine;

namespace CatchGoose
{
    public sealed class GooseItem : MonoBehaviour
    {
        public string Id;
        public int GenerationLayer;
        public bool Picked, Frozen, Golden;
        public Rigidbody Body;
        public Transform Visual;
        public bool DepthVisible { get; private set; } = true;
        public bool DepthHeld { get; private set; }
        // Physical surface membership is distinct from a side-visible support.
        public bool SurfaceActive, SurfaceAnimating;
        public bool SurfaceKnown, SurfaceExposed, SurfaceProbeQueued;
        public float NextSurfaceCheck;
        public bool DepthReady;
        public float DepthProtectedUntil, DepthStillSince;
        public float NextOcclusionCheck;
        public bool CachedCovered, OcclusionKnown;
        // Classification provenance, independent of the renderer output.
        public int VisibilityEpoch, VisibilityClassifications, CommittedVisibilityEpoch;
        public struct VisualMaterialState { public int signature; public bool opaque; }
        public bool VisualOccluder {get;private set;}
        public int VisualMaterialRevision {get;private set;}
        bool visualMaterialKnown;
        int visualMaterialSignature;
        readonly List<Material> visualMaterials=new List<Material>(8);
        readonly Dictionary<Material,VisualMaterialState> localVisualMaterials=new Dictionary<Material,VisualMaterialState>();
        static readonly Dictionary<Shader,bool> knownOpaqueShaders=new Dictionary<Shader,bool>();
        public float CoveredSince=-1;
        public bool PhysicsRecoveryActive {get;private set;}
        public float PhysicsRecoveryStarted {get;private set;}
        public int FloorCorrections,VisibilityChanges,ProtectedHideViolations;
        public int RenderCount { get; private set; }
        public int DrawSlots { get; private set; }
        public int Triangles { get; private set; }
        Renderer[] depthRenderers;
        public Renderer[] Renderers {get{if(depthRenderers==null)depthRenderers=GetComponentsInChildren<Renderer>(true);return depthRenderers;}}
        public Collider SelectionCollider { get; private set; }
        public Collider[] Colliders { get; private set; }
        Vector3 visualScale;
        Bounds authoredVisualLocalBounds;
        // Cache before the opening animation sets Visual.scale to zero. Render
        // visibility must describe the authored mesh, not its reveal animation.
        public Bounds OcclusionVisualBounds => TransformVisualBounds(transform.localToWorldMatrix,authoredVisualLocalBounds);
        static Bounds TransformVisualBounds(Matrix4x4 matrix,Bounds source)
        {
            var e=source.extents;var x=matrix.MultiplyVector(new Vector3(e.x,0,0));
            var y=matrix.MultiplyVector(new Vector3(0,e.y,0));var z=matrix.MultiplyVector(new Vector3(0,0,e.z));
            return new Bounds(matrix.MultiplyPoint3x4(source.center),new Vector3(
                Mathf.Abs(x.x)+Mathf.Abs(y.x)+Mathf.Abs(z.x),Mathf.Abs(x.y)+Mathf.Abs(y.y)+Mathf.Abs(z.y),
                Mathf.Abs(x.z)+Mathf.Abs(y.z)+Mathf.Abs(z.z))*2);
        }
        void CacheAuthoredVisualBounds()
        {
            bool first=true;
            foreach(var renderer in depthRenderers)if(renderer)
            {
                var bounds=TransformVisualBounds(transform.worldToLocalMatrix*renderer.localToWorldMatrix,renderer.localBounds);
                if(first){authoredVisualLocalBounds=bounds;first=false;}else authoredVisualLocalBounds.Encapsulate(bounds);
            }
        }
        public Bounds VisualBounds
        {
            get
            {
                if (depthRenderers == null) depthRenderers = GetComponentsInChildren<Renderer>(true);
                var bounds = new Bounds(transform.position, Vector3.zero); bool first = true;
                foreach (var renderer in depthRenderers) if (renderer)
                { if (first) { bounds = renderer.bounds; first = false; } else bounds.Encapsulate(renderer.bounds); }
                return bounds;
            }
        }
        public void CacheParts()
        {
            depthRenderers = GetComponentsInChildren<Renderer>(true);
            Colliders = GetComponentsInChildren<Collider>(true); SelectionCollider = Colliders[0];
            visualScale = Visual.localScale;
            RenderCount=depthRenderers.Length;DrawSlots=Triangles=0;
            foreach(var renderer in depthRenderers)DrawSlots+=renderer.sharedMaterials.Length;
            foreach(var filter in GetComponentsInChildren<MeshFilter>(true))if(filter.sharedMesh)
                for(int i=0;i<filter.sharedMesh.subMeshCount;i++)Triangles+=(int)filter.sharedMesh.GetIndexCount(i)/3;
            CacheAuthoredVisualBounds();
            InvalidateVisualOcclusionCache();
        }
        public void InvalidateVisualOcclusionCache()
        {visualMaterialKnown=false;VisualOccluder=false;VisualMaterialRevision++;}
        public bool RefreshVisualOcclusionCache()
        {localVisualMaterials.Clear();return RefreshVisualOcclusionCache(localVisualMaterials);}
        // Depth shares this dictionary across the whole preparation refresh:
        // each independent material is inspected once, never once per ray.
        public bool RefreshVisualOcclusionCache(Dictionary<Material,VisualMaterialState> materialCache)
        {
            int signature=17,participating=0;bool opaque=true;
            foreach(var renderer in Renderers)
            {
                if(!renderer){opaque=false;signature=unchecked(signature*31);continue;}
                // enabled is depth's output and must not become a cache input.
                bool active=renderer.gameObject.activeInHierarchy&&!renderer.forceRenderingOff;
                signature=unchecked((signature*31+renderer.GetInstanceID())*31+(active?1:0));
                if(!active){opaque=false;continue;}
                participating++;visualMaterials.Clear();renderer.GetSharedMaterials(visualMaterials);
                if(visualMaterials.Count==0)opaque=false;
                foreach(var material in visualMaterials)
                {
                    if(!material){opaque=false;signature=unchecked(signature*31);continue;}
                    if(!materialCache.TryGetValue(material,out var state))
                    {state=InspectVisualMaterial(material);materialCache.Add(material,state);}
                    signature=unchecked(signature*31+state.signature);opaque&=state.opaque;
                }
            }
            opaque&=participating>0;
            bool changed=!visualMaterialKnown||signature!=visualMaterialSignature||opaque!=VisualOccluder;
            if(changed){visualMaterialSignature=signature;VisualOccluder=opaque;VisualMaterialRevision++;visualMaterialKnown=true;}
            return changed;
        }
        static VisualMaterialState InspectVisualMaterial(Material material)
        {
            var shader=material.shader;bool known=false;
            if(shader&&!knownOpaqueShaders.TryGetValue(shader,out known))
            {
                string name=shader.name;
                known=name=="Goose/ReferenceOpaque"||name=="Goose/ItemMobile"||name=="Goose/DuckMobile"||name=="Standard";
                knownOpaqueShaders.Add(shader,known);
            }
            int queue=material.renderQueue;if(queue<0&&shader)queue=shader.renderQueue;
            string renderType=material.GetTag("RenderType",false,"");
            bool test=material.IsKeywordEnabled("_ALPHATEST_ON"),blend=material.IsKeywordEnabled("_ALPHABLEND_ON"),
                premultiply=material.IsKeywordEnabled("_ALPHAPREMULTIPLY_ON");
            bool opaque=known&&renderType=="Opaque"&&queue>=0&&queue<2450&&!test&&!blend&&!premultiply;
            int signature=unchecked((material.GetInstanceID()*31+(shader?shader.GetInstanceID():0))*31+queue);
            signature=unchecked(signature*31+renderType.GetHashCode());
            signature=unchecked(signature*31+(test?1:0)+(blend?2:0)+(premultiply?4:0));
            InspectSwitch(material,"_Mode",0,ref signature,ref opaque);
            InspectSwitch(material,"_Surface",0,ref signature,ref opaque);
            InspectSwitch(material,"_AlphaClip",0,ref signature,ref opaque);
            InspectSwitch(material,"_ZWrite",1,ref signature,ref opaque);
            InspectSwitch(material,"_SrcBlend",1,ref signature,ref opaque);
            InspectSwitch(material,"_DstBlend",0,ref signature,ref opaque);
            return new VisualMaterialState{signature=signature,opaque=opaque};
        }
        static void InspectSwitch(Material material,string property,float opaqueValue,ref int signature,ref bool opaque)
        {
            if(!material.HasProperty(property))return;
            float value=material.GetFloat(property);signature=unchecked(signature*31+value.GetHashCode());
            if(Mathf.Abs(value-opaqueValue)>.001f)opaque=false;
        }
        public void ResetForReuse()
        {
            if (GooseGame.Instance) GooseGame.Instance.InvalidateSelection(this);
            Picked = false; GenerationLayer = 0; Golden = false; SetFrozen(false);
            DepthHeld = false; DepthReady = false; DepthProtectedUntil = DepthStillSince = Time.time;
            SurfaceActive=SurfaceAnimating=SurfaceKnown=SurfaceExposed=SurfaceProbeQueued=false;NextSurfaceCheck=0;
            transform.localScale = Vector3.one; transform.localRotation = Quaternion.identity;
            Visual.localScale = visualScale;
            Body.isKinematic = false; Body.useGravity=true; Body.velocity = Body.angularVelocity = Vector3.zero;
            NextOcclusionCheck = 0; CachedCovered = OcclusionKnown = false;
            VisibilityEpoch=VisibilityClassifications=CommittedVisibilityEpoch=0;
            visualMaterialKnown=false;VisualOccluder=false;VisualMaterialRevision=0;
            visualMaterials.Clear();localVisualMaterials.Clear();
            CoveredSince=-1;FloorCorrections=VisibilityChanges=ProtectedHideViolations=0;RestoreNormalPhysics();
            Body.collisionDetectionMode = GooseRuntimePerformance.DynamicCollision;
            Body.detectCollisions = true; foreach(var col in Colliders) col.enabled = true;
            SetDepthVisible(true); Body.WakeUp();
        }
        GameObject ice;
        static Material iceMaterial;
        public void SetFrozen(bool value)
        {
            if (Frozen == value && (!value || ice)) return;
            Frozen = value;
            if (ice) { ice.SetActive(false); Destroy(ice); }
            depthRenderers = null;
            InvalidateVisualOcclusionCache();
            if (!value) return;
            if (!iceMaterial)
            {
                iceMaterial = new Material(Shader.Find("Standard"));
                iceMaterial.color = new Color(.55f, .8f, 1, .22f);
                iceMaterial.SetFloat("_Mode", 3);
                iceMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                iceMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                iceMaterial.SetInt("_ZWrite", 0);
                iceMaterial.EnableKeyword("_ALPHABLEND_ON"); iceMaterial.renderQueue = 3000;
            }
            ice = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            ice.name = "IceShell"; ice.transform.SetParent(transform, false);
            ice.transform.localScale = Vector3.one * 1.25f;
            Destroy(ice.GetComponent<Collider>());
            ice.GetComponent<Renderer>().sharedMaterial = iceMaterial;
            ice.GetComponent<Renderer>().shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
            ice.GetComponent<Renderer>().enabled = DepthVisible;
        }
        public void SetDepthVisible(bool value)
        {
            if (!value && GooseGame.Instance) GooseGame.Instance.InvalidateSelection(this);
            if (DepthVisible == value && depthRenderers != null) return;
            if(DepthVisible!=value){VisibilityChanges++;if(!value&&DepthVisible&&Time.time<DepthProtectedUntil)ProtectedHideViolations++;}
            DepthVisible = value;
            if (depthRenderers == null) depthRenderers = GetComponentsInChildren<Renderer>(true);
            foreach (var renderer in depthRenderers) if (renderer) renderer.enabled = value;
        }
        public void SetDepthHeld(bool value)
        {
            if (!Body || Picked || SurfaceAnimating) return;
            Body.useGravity=!value;
            if (DepthHeld == value && Body.isKinematic == value) return;
            if (value)
            {
                Body.velocity = Vector3.zero; Body.angularVelocity = Vector3.zero;
                Body.collisionDetectionMode = CollisionDetectionMode.ContinuousSpeculative;
                Body.isKinematic = true;
                SurfaceActive=false;
            }
            else
            {
                Body.isKinematic = false;
                Body.collisionDetectionMode = PhysicsRecoveryActive?CollisionDetectionMode.ContinuousDynamic:GooseRuntimePerformance.DynamicCollision;
                Body.WakeUp();
            }
            DepthHeld = value;
            // Collider.enabled and detectCollisions are deliberately retained for support.
        }
        public void ReleaseDepth(float protectUntil, bool reveal)
        {
            if(GooseGame.Instance)GooseGame.Instance.Depth?.Invalidate();
            SetDepthHeld(false);
            DepthProtectedUntil = protectUntil; DepthStillSince = Time.time;
            if (reveal) SetDepthVisible(true);
        }
        public void BeginFloorRecovery()
        {
            if(!PhysicsRecoveryActive)PhysicsRecoveryStarted=Time.time;
            PhysicsRecoveryActive=true;FloorCorrections++;
            Body.solverIterations=24;Body.solverVelocityIterations=8;Body.sleepThreshold=.005f;Body.maxDepenetrationVelocity=3;
            Body.collisionDetectionMode=CollisionDetectionMode.ContinuousDynamic;
            // Discard an interpolated pose that is already below the support
            // plane. Otherwise that stale pose can re-trigger recovery forever.
            Body.interpolation=RigidbodyInterpolation.None;
        }
        public void RestoreNormalPhysics()
        {
            if(!Body)return;PhysicsRecoveryActive=false;
            Body.solverIterations=12;Body.solverVelocityIterations=4;Body.sleepThreshold=.02f;Body.maxDepenetrationVelocity=1;
            Body.collisionDetectionMode=Body.isKinematic?CollisionDetectionMode.ContinuousSpeculative:GooseRuntimePerformance.DynamicCollision;
            Body.interpolation=RigidbodyInterpolation.Interpolate;
        }
        void OnDisable() { if (GooseGame.Instance) GooseGame.Instance.InvalidateSelection(this); }
        void OnDestroy() { if (GooseGame.Instance) GooseGame.Instance.Forget(this); }
    }
}
