using System.Collections.Generic;
using UnityEngine;
namespace CatchGoose
{
    public static class GooseColliderGeometry
    {
        // Offline hulls have <=100 vertices and retain CPU data. This cache never
        // reads the much larger render meshes released on mobile.
        static readonly Dictionary<Mesh,Vector3[]> points=new Dictionary<Mesh,Vector3[]>();
        static Vector3[] Points(Mesh mesh)
        {if(!points.TryGetValue(mesh,out var vertices)){vertices=mesh.vertices;points[mesh]=vertices;}return vertices;}
        public static float MinY(Collider collider)
        {return MinY(collider,collider.transform.localToWorldMatrix);}
        public static Matrix4x4 BodyMatrix(Collider collider,Rigidbody body)
        {
            // Rigidbody pose is one simulation step ahead of an interpolated
            // Transform. Keep support calculations in the same pose space.
            return Matrix4x4.TRS(body.position,body.rotation,Vector3.one)*
                Matrix4x4.TRS(body.transform.position,body.transform.rotation,Vector3.one).inverse*collider.transform.localToWorldMatrix;
        }
        public static float BoundsMinY(Collider collider)
        {
            if(!(collider is MeshCollider mesh)||!mesh.sharedMesh)return collider.bounds.min.y;
            var b=mesh.sharedMesh.bounds;var m=collider.transform.localToWorldMatrix;
            return m.MultiplyPoint3x4(b.center).y-(Mathf.Abs(m.m10)*b.extents.x+Mathf.Abs(m.m11)*b.extents.y+Mathf.Abs(m.m12)*b.extents.z);
        }
        public static float MinY(Collider collider,Matrix4x4 matrix)
        {
            if(collider is MeshCollider mesh&&mesh.sharedMesh)
            {
                var vertices=Points(mesh.sharedMesh);
                float min=float.PositiveInfinity;
                foreach(var v in vertices)min=Mathf.Min(min,matrix.MultiplyPoint3x4(v).y);
                return min;
            }
            return collider.bounds.min.y;
        }
        public static float ProjectedArea(Collider collider)
        {
            if(!(collider is MeshCollider mesh)||!mesh.sharedMesh){var b=collider.bounds;return b.size.x*b.size.z;}
            var p=new List<Vector2>();var matrix=collider.transform.localToWorldMatrix;
            foreach(var v in Points(mesh.sharedMesh)){var w=matrix.MultiplyPoint3x4(v);p.Add(new Vector2(w.x,w.z));}
            p.Sort((a,b)=>a.x==b.x?a.y.CompareTo(b.y):a.x.CompareTo(b.x));
            var hull=new Vector2[p.Count*2];int k=0;
            for(int i=0;i<p.Count;i++){while(k>=2&&Cross(hull[k-1]-hull[k-2],p[i]-hull[k-1])<=0)k--;hull[k++]=p[i];}
            int low=k+1;
            for(int i=p.Count-2;i>=0;i--){while(k>=low&&Cross(hull[k-1]-hull[k-2],p[i]-hull[k-1])<=0)k--;hull[k++]=p[i];}
            float area=0;for(int i=1;i<k;i++)area+=Cross(hull[i-1],hull[i]);
            return Mathf.Max(.001f,Mathf.Abs(area)*.5f);
        }
        static float Cross(Vector2 a,Vector2 b)=>a.x*b.y-a.y*b.x;
    }
}
