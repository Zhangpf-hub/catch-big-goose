using UnityEngine;
using UnityEngine.UI;
namespace CatchGoose
{
    // Resolution independent decorations, separate from the nine-slice sprite.
    // Vertices use the final button rect, so paw/flower shapes are never stretched.
    public sealed class GooseCandyPattern:MaskableGraphic
    {
        public bool Shine;public int Style;public float Phase;
        void Update(){if(Shine)SetVerticesDirty();}
        void Disc(VertexHelper vh,Vector2 p,float x,float y,Color c)
        {
            int start=vh.currentVertCount;vh.AddVert(p,c,Vector2.zero);
            for(int i=0;i<=12;i++){float a=i*Mathf.PI/6;vh.AddVert(p+new Vector2(Mathf.Cos(a)*x,Mathf.Sin(a)*y),c,Vector2.zero);if(i>0)vh.AddTriangle(start,start+i,start+i+1);}
        }
        void Star(VertexHelper vh,Vector2 p,float r,Color c)
        {
            int start=vh.currentVertCount;vh.AddVert(p,c,Vector2.zero);
            for(int i=0;i<=8;i++){float a=i*Mathf.PI/4;vh.AddVert(p+new Vector2(Mathf.Cos(a),Mathf.Sin(a))*(i%2==0?r:r*.28f),c,Vector2.zero);if(i>0)vh.AddTriangle(start,start+i,start+i+1);}
        }
        protected override void OnPopulateMesh(VertexHelper vh)
        {
            vh.Clear();var r=rectTransform.rect;float size=Mathf.Min(r.width,r.height)*.08f;
            var tint=new Color(1,1,.92f,.25f);
            for(int i=0;i<4;i++)
            {
                var p=new Vector2(Mathf.Lerp(r.xMin,r.xMax,i%2==0?.15f:.85f),Mathf.Lerp(r.yMin,r.yMax,i<2?.32f:.70f));
                if(Style==1){for(int k=0;k<5;k++){float a=k*Mathf.PI*2/5;Disc(vh,p+new Vector2(Mathf.Cos(a),Mathf.Sin(a))*size*.7f,size*.55f,size*.55f,tint);}Disc(vh,p,size*.4f,size*.4f,new Color(1,.8f,.2f,.4f));}
                else if(Style==2)Star(vh,p,size*1.3f,tint);
                else{Disc(vh,p,size,size*.7f,tint);for(int k=0;k<3;k++)Disc(vh,p+new Vector2((k-1)*size*.8f,size),size*.36f,size*.45f,tint);}
            }
            if(!Shine)return;
            // Sweep stays inside the inner face, away from rounded corners/rim.
            float progress=Mathf.Repeat((Time.unscaledTime+Phase)/4.8f,1);
            if(progress>.24f)return;
            float x=Mathf.Lerp(r.xMin+32,r.xMax-32,progress/.24f),w=12;
            int n=vh.currentVertCount;var c=new Color(1,1,1,.19f);
            vh.AddVert(new Vector2(x-w,r.yMin+26),c,Vector2.zero);vh.AddVert(new Vector2(x+w,r.yMin+26),c,Vector2.zero);
            vh.AddVert(new Vector2(Mathf.Min(x+w+24,r.xMax-22),r.yMax-22),c,Vector2.zero);vh.AddVert(new Vector2(Mathf.Min(x-w+24,r.xMax-22),r.yMax-22),c,Vector2.zero);
            vh.AddTriangle(n,n+1,n+2);vh.AddTriangle(n,n+2,n+3);
        }
    }
}
