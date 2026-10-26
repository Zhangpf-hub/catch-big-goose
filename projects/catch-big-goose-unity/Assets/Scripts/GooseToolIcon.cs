using UnityEngine;
using UnityEngine.UI;

namespace CatchGoose
{
    // Small UI-native pictograms stay crisp at every phone scale.
    public sealed class GooseToolIcon : Graphic
    {
        public int Kind;
        void Line(VertexHelper vh, Vector2 a, Vector2 b, float width, Color tint)
        {
            var normal = new Vector2(-(b-a).y,(b-a).x).normalized * width*.5f;
            int start = vh.currentVertCount;
            vh.AddVert(a-normal,tint,Vector2.zero); vh.AddVert(a+normal,tint,Vector2.zero);
            vh.AddVert(b+normal,tint,Vector2.zero); vh.AddVert(b-normal,tint,Vector2.zero);
            vh.AddTriangle(start,start+1,start+2); vh.AddTriangle(start,start+2,start+3);
        }
        void Stroke(VertexHelper vh, Vector2 a, Vector2 b, Color tint)
        { Line(vh,a,b,13,new Color(.13f,.23f,.29f)); Line(vh,a,b,8,tint); }
        void Arrow(VertexHelper vh, Vector2 a, Vector2 b, Color tint)
        {
            Stroke(vh,a,b,tint); var d=(b-a).normalized;
            var p=new Vector2(-d.y,d.x); Stroke(vh,b,b-d*16+p*12,tint); Stroke(vh,b,b-d*16-p*12,tint);
        }
        protected override void OnPopulateMesh(VertexHelper vh)
        {
            vh.Clear();
            var green=new Color(.26f,.85f,.36f); var pink=new Color(.96f,.40f,.65f); var blue=new Color(.28f,.69f,.98f);
            if(Kind==0)
            { Stroke(vh,new Vector2(20,-18),new Vector2(20,10),green); Arrow(vh,new Vector2(20,10),new Vector2(-22,10),green); }
            else if(Kind==1)
            {
                Stroke(vh,new Vector2(-18,20),new Vector2(-18,-12),pink);
                Stroke(vh,new Vector2(-18,-12),new Vector2(0,-23),pink);
                Stroke(vh,new Vector2(0,-23),new Vector2(18,-12),blue);
                Stroke(vh,new Vector2(18,-12),new Vector2(18,20),blue);
                Stroke(vh,new Vector2(-18,17),new Vector2(-18,27),Color.white);
                Stroke(vh,new Vector2(18,17),new Vector2(18,27),Color.white);
            }
            else
            { Arrow(vh,new Vector2(-26,-21),new Vector2(26,21),pink); Arrow(vh,new Vector2(-26,21),new Vector2(26,-21),blue); }
        }
    }
}
