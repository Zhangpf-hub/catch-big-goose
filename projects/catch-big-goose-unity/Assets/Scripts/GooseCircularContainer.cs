using UnityEngine;

namespace CatchGoose
{
    // The authored plate stays full size; only the invisible pile boundary contracts.
    public sealed class GooseCircularContainer : MonoBehaviour
    {
        public const float InitialRadius = 1.72f, CenterZ = .88f, FloorY = .025f;
        public float Radius { get; private set; } = InitialRadius;
        public float TargetRadius { get; private set; } = InitialRadius;
        public float MinimumRadius { get; private set; } = InitialRadius * .48f;
        public int ContainmentRecoveries { get; private set; }
        public float RimHeight => .305f;
        public Vector3 Center => new Vector3(0, FloorY, CenterZ);
        readonly Rigidbody[] walls = new Rigidbody[32];
        readonly Rigidbody[] rims = new Rigidbody[32];
        PhysicMaterial contactMaterial;
        Transform visual;
        GooseGame game;
        bool live;
        float lateRadius;

        public void Initialize(GameObject model, PhysicMaterial material)
        {
            contactMaterial=material;
            var modelTransform = model.transform;
            var b = GooseGame.BoundsOf(model);
            float factor = 4f / Mathf.Max(b.size.x, b.size.z);
            modelTransform.localScale *= factor; modelTransform.localPosition *= factor;
            b = GooseGame.BoundsOf(model);
            // Recovered source containers include full legs/stove bodies. Anchor
            // their top surface to the shared floor instead of raising the legs.
            bool sourceContainer=model.name.StartsWith("scene_");
            modelTransform.position += new Vector3(-b.center.x, sourceContainer?FloorY-.08f-b.max.y:-(b.min.y+.10f), CenterZ-b.center.z);
            // Imported FBX roots may rotate local Y/Z. An identity world-Y-up
            // pivot preserves the authored silhouette independently of the pile.
            visual = new GameObject("CircularVisual").transform;visual.SetParent(transform,false);
            visual.position=new Vector3(0,0,CenterZ);modelTransform.SetParent(visual,true);
            var bottom = new GameObject("ContinuousFloor"); bottom.transform.SetParent(transform,false);
            bottom.transform.position = new Vector3(0,FloorY-.5f,CenterZ);
            var floor = bottom.AddComponent<BoxCollider>(); floor.size = new Vector3(4.4f,1f,4.4f); floor.sharedMaterial=material;
            for (int i=0;i<walls.Length;i++)
            {
                var go = new GameObject("CircularBoundary_"+i);go.transform.SetParent(transform,false);
                float a=i*Mathf.PI*2/walls.Length;
                go.transform.SetPositionAndRotation(new Vector3(Mathf.Cos(a)*(Radius+.08f),32f,CenterZ+Mathf.Sin(a)*(Radius+.08f)),Quaternion.Euler(0,-a*Mathf.Rad2Deg,0));
                var box=go.AddComponent<BoxCollider>();box.size=new Vector3(.16f,64f,.39f);box.sharedMaterial=material;
                walls[i]=go.AddComponent<Rigidbody>();walls[i].isKinematic=true;walls[i].useGravity=false;
                walls[i].interpolation=RigidbodyInterpolation.Interpolate;
            }
        }
        public void Activate(GooseGame owner)
        {
            game=owner;live=true;
            foreach(var wall in walls){var box=wall.GetComponent<BoxCollider>();box.size=new Vector3(.16f,64f,.39f);var p=wall.position;p.y=32f;wall.position=p;}
            // A low, visible-height rim blocks picking through the basket side.
            // The tall invisible containment guards remain excluded from rays.
            for(int i=0;i<rims.Length;i++)
            {
                float a=i*Mathf.PI*2/rims.Length;var go=new GameObject("VisibleRim_"+i);go.transform.SetParent(transform,false);
                go.transform.SetPositionAndRotation(new Vector3(Mathf.Cos(a)*(Radius+.075f),RimHeight*.5f,CenterZ+Mathf.Sin(a)*(Radius+.075f)),Quaternion.Euler(0,-a*Mathf.Rad2Deg,0));
                var box=go.AddComponent<BoxCollider>();box.size=new Vector3(.15f,RimHeight,.39f);box.sharedMaterial=contactMaterial;
                rims[i]=go.AddComponent<Rigidbody>();rims[i].isKinematic=true;rims[i].useGravity=false;
            }
            float largest=0;
            var areas=new System.Collections.Generic.List<float>();
            foreach(var item in game.Items)
            {
                var bounds=item.SelectionCollider.bounds;
                largest=Mathf.Max(largest,SafeRadius(item));
                areas.Add(GooseColliderGeometry.ProjectedArea(item.SelectionCollider));
            }
            MinimumRadius=Mathf.Min(InitialRadius,Mathf.Max(InitialRadius*.32f,largest));
            areas.Sort();var profile=GooseInteractionProfile.Current;
            lateRadius=Mathf.Clamp(Mathf.Sqrt(areas[areas.Count/2]*profile.lateSurfaceCapacity/(Mathf.PI*profile.latePacking)),MinimumRadius,InitialRadius*.60f);
        }
        public static float RadiusRatio(float progress)
        {
            float[] p={0,.25f,.5f,.75f,.9f,1},r={1,.9f,.75f,.58f,.48f,.48f};
            progress=Mathf.Clamp01(progress);
            for(int i=1;i<p.Length;i++)if(progress<=p[i])return Mathf.Lerp(r[i-1],r[i],Mathf.SmoothStep(0,1,(progress-p[i-1])/(p[i]-p[i-1])));
            return .48f;
        }
        public void MatchCommitted(float progress)
        {
            var profile=GooseInteractionProfile.Current;
            int remaining=Mathf.Max(0,game.Total-game.Removed);float largest=0;
            foreach(var item in game.Items)if(item&&!item.Picked)largest=Mathf.Max(largest,SafeRadius(item));
            MinimumRadius=Mathf.Min(InitialRadius,Mathf.Max(InitialRadius*.32f,largest));
            lateRadius=Mathf.Max(MinimumRadius,Mathf.Min(lateRadius,InitialRadius*.60f));
            float late=Mathf.SmoothStep(0,1,Mathf.InverseLerp(profile.lateStartCount,profile.lateFullCount,remaining));
            float target=Mathf.Min(InitialRadius*RadiusRatio(progress),Mathf.Lerp(InitialRadius,lateRadius,late));
            TargetRadius=Mathf.Min(TargetRadius,Mathf.Max(MinimumRadius,target));
        }
        static float SafeRadius(GooseItem item)
        {
            var scale=item.transform.lossyScale;float s=Mathf.Max(scale.x,scale.y,scale.z);
            if(item.SelectionCollider is MeshCollider mesh)
            {
                // Long pieces may stand/tilt in a small bowl. Require enough room
                // for their smallest real cross-section, rather than an enclosing
                // sphere that prevented thin skewers from ever piling up.
                var e=mesh.sharedMesh.bounds.extents;
                return Mathf.Sqrt(Mathf.Min(e.x*e.x+e.y*e.y,Mathf.Min(e.x*e.x+e.z*e.z,e.y*e.y+e.z*e.z)))*s+.04f;
            }
            // Primitive profile fallbacks are not used by the recovered-model set.
            return item.SelectionCollider.bounds.extents.magnitude+.04f;
        }
        public Vector3 ClampFootprint(Vector3 desired, Vector3 offset, Vector3 extents, float clearance=.06f)
        {
            float limit=Mathf.Max(.02f,Radius-new Vector2(extents.x,extents.z).magnitude-clearance);
            var p=Vector2.ClampMagnitude(new Vector2(desired.x+offset.x,desired.z+offset.z-CenterZ),limit);
            desired.x=p.x-offset.x;desired.z=CenterZ+p.y-offset.z;return desired;
        }
        void FixedUpdate()
        {
            if(!live||!game||!game.Playing||game.Paused||!game.SpawnComplete)return;
            if(game.Depth&&game.Depth.AnimationInProgress)return;
            ConfineEscapedCenters();
            if(game.Shake&&game.Shake.Active)return;
            if(Radius<=TargetRadius+.0001f)return;
            float next=Mathf.MoveTowards(Radius,TargetRadius,GooseInteractionProfile.Current.shrinkSpeed*Time.fixedDeltaTime);
            foreach(var item in game.Items)
            {
                if(!item||item.Picked||item.SurfaceAnimating)continue;
                if(item.DepthHeld)
                {
                    // Buried supports follow the contracting bowl as kinematic
                    // geometry. They never acquire gravity or dynamic contacts.
                    var held=item.Body.position;float ratio=next/Mathf.Max(.01f,Radius);
                    held.x*=ratio;held.z=CenterZ+(held.z-CenterZ)*ratio;
                    item.Body.MovePosition(held);item.NextSurfaceCheck=0;item.NextOcclusionCheck=0;
                    continue;
                }
                var b=item.SelectionCollider.bounds;
                float radial=new Vector2(b.center.x,b.center.z-CenterZ).magnitude+new Vector2(b.extents.x,b.extents.z).magnitude;
                if(radial>next-.12f&&item.SurfaceActive)
                {item.DepthProtectedUntil=Mathf.Max(item.DepthProtectedUntil,Time.time+.4f);item.Body.WakeUp();}
            }
            Radius=next;
            for(int i=0;i<walls.Length;i++)
            {
                float a=i*Mathf.PI*2/walls.Length;
                walls[i].MovePosition(new Vector3(Mathf.Cos(a)*(Radius+.08f),3.2f,CenterZ+Mathf.Sin(a)*(Radius+.08f)));
            }
            // Visible rim colliders stay with the full-size plate. Moving those
            // inward would hide selectable pieces behind a rim that is not drawn.
        }
        void LateUpdate()
        {
            if(!live||!game||!game.Playing||game.Paused||!game.SpawnComplete)return;
            if(game.Depth&&game.Depth.AnimationInProgress)return;
            // Contacts restored after a toss can push a dynamic center out in
            // the simulation following FixedUpdate. Constrain that same pose
            // before rendering, using the existing active-body policy.
            if(ConfineEscapedCenters())Physics.SyncTransforms();
        }
        bool ConfineEscapedCenters()
        {
            // A thin convex fan can tunnel through a moving kinematic guard at
            // the 30 Hz mobile step. Catch it on the next step, before it can
            // settle on the now full-size outer plate. Preserve height, spin and
            // tangential motion; discard only velocity pointing out of bounds.
            bool corrected=false;
            foreach(var item in game.Items)
            {
                if(!item||item.Picked||item.SurfaceAnimating||item.DepthHeld||item.Body.isKinematic)continue;
                var position=item.Body.position;
                var offset=new Vector2(position.x,position.z-CenterZ);
                if(offset.sqrMagnitude<=(Radius+.02f)*(Radius+.02f))continue;
                var normal=offset.normalized;
                item.ReleaseDepth(Time.time+.4f,false);
                position.x=normal.x*(Radius-.02f);position.z=CenterZ+normal.y*(Radius-.02f);
                item.Body.position=position;
                item.transform.position=position;
                var outward=new Vector3(normal.x,0,normal.y);
                item.Body.velocity-=outward*Mathf.Max(0,Vector3.Dot(item.Body.velocity,outward));
                item.NextOcclusionCheck=0;ContainmentRecoveries++;
                corrected=true;
            }
            return corrected;
        }
    }
}
