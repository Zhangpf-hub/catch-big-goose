using UnityEngine;
using UnityEngine.UI;
namespace CatchGoose
{
    // Bounded UI particles, without spawning GameObjects or materials.
    public sealed class GooseStickerBurst:MaskableGraphic
    {
        struct Particle{public Vector2 position,velocity;public float born,life,size;}
        readonly Particle[] particles=new Particle[36];int cursor;float nextIdle;Vector2 anchor;bool hadParticles;
        public int Emissions{get;private set;}
        public void SetIdleAnchor(Vector2 value){anchor=value;nextIdle=Time.unscaledTime+1;}
        public void EmitAt(Vector2 point)
        {
            Emissions++;
            for(int i=0;i<8;i++){float a=(i*45+18)*Mathf.Deg2Rad;particles[cursor++%particles.Length]=new Particle{position=point,velocity=new Vector2(Mathf.Cos(a)*110,Mathf.Sin(a)*100+30),born=Time.unscaledTime,life=.7f+i*.03f,size=8+i%3*3};}
            SetVerticesDirty();
        }
        void Update()
        {
            if(Time.unscaledTime>=nextIdle)
            {
                nextIdle=Time.unscaledTime+2.6f;
                for(int i=0;i<3;i++)particles[cursor++%particles.Length]=new Particle{position=anchor+new Vector2(i==0?-275:i==1?260:220,55+i*14),velocity=new Vector2((i-1)*8,22),born=Time.unscaledTime,life=1.1f,size=8+i*2};
            }
            bool active=false;for(int i=0;i<particles.Length;i++)if(particles[i].life>0&&Time.unscaledTime-particles[i].born<particles[i].life){active=true;break;}
            if(active||hadParticles)SetVerticesDirty();hadParticles=active;
        }
        static void Star(VertexHelper vh,Vector2 point,float radius,Color color)
        {
            int start=vh.currentVertCount;vh.AddVert(point,color,Vector2.zero);
            for(int k=0;k<=8;k++){float a=k*Mathf.PI/4;vh.AddVert(point+new Vector2(Mathf.Cos(a),Mathf.Sin(a))*(k%2==0?radius:radius*.27f),color,Vector2.zero);if(k>0)vh.AddTriangle(start,start+k,start+k+1);}
        }
        protected override void OnPopulateMesh(VertexHelper vh)
        {
            vh.Clear();foreach(var p in particles)
            {
                float age=Time.unscaledTime-p.born;if(p.life<=0||age<0||age>=p.life)continue;
                float t=age/p.life,alpha=Mathf.Sin(t*Mathf.PI);var point=p.position+p.velocity*age+Vector2.down*(age*age*40);
                Star(vh,point,p.size*(1+t*.5f),new Color(1,1,1,alpha));Star(vh,point,p.size*.66f*(1+t*.5f),new Color(1,.80f,.1f,alpha));
            }
        }
    }
}
