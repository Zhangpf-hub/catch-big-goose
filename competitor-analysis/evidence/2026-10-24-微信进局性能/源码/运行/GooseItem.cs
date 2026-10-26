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
        public bool DepthReady;
        public float DepthProtectedUntil, DepthStillSince;
        Renderer[] depthRenderers;
        public Collider SelectionCollider { get; private set; }
        public Collider[] Colliders { get; private set; }
        Vector3 visualScale;
        public void CacheParts()
        {
            depthRenderers = GetComponentsInChildren<Renderer>(true);
            Colliders = GetComponentsInChildren<Collider>(true); SelectionCollider = Colliders[0];
            visualScale = Visual.localScale;
        }
        public void ResetForReuse()
        {
            Picked = false; GenerationLayer = 0; Golden = false; SetFrozen(false);
            DepthHeld = false; DepthReady = false; DepthProtectedUntil = DepthStillSince = Time.time;
            transform.localScale = Vector3.one; transform.localRotation = Quaternion.identity;
            Visual.localScale = visualScale;
            Body.isKinematic = false; Body.velocity = Body.angularVelocity = Vector3.zero;
            Body.collisionDetectionMode = CollisionDetectionMode.ContinuousDynamic;
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
            if (DepthVisible == value && depthRenderers != null) return;
            DepthVisible = value;
            if (depthRenderers == null) depthRenderers = GetComponentsInChildren<Renderer>(true);
            foreach (var renderer in depthRenderers) if (renderer) renderer.enabled = value;
        }
        public void SetDepthHeld(bool value)
        {
            if (!Body || Picked || DepthHeld == value) return;
            if (value)
            {
                Body.velocity = Vector3.zero; Body.angularVelocity = Vector3.zero;
                Body.collisionDetectionMode = CollisionDetectionMode.ContinuousSpeculative;
                Body.isKinematic = true;
            }
            else
            {
                Body.isKinematic = false;
                Body.collisionDetectionMode = CollisionDetectionMode.ContinuousDynamic;
                Body.WakeUp();
            }
            DepthHeld = value;
            // Collider.enabled and detectCollisions are deliberately retained for support.
        }
        public void ReleaseDepth(float protectUntil, bool reveal)
        {
            SetDepthHeld(false);
            DepthProtectedUntil = protectUntil; DepthStillSince = Time.time;
            if (reveal) SetDepthVisible(true);
        }
        void OnDestroy() { if (GooseGame.Instance) GooseGame.Instance.Forget(this); }
    }
}
