using System;
using UnityEngine;
using UnityEngine.UI;
namespace CatchGoose
{
    // Low-frequency structural counters and a bounded frame ring. Device figures
    // originate on the phone; this is intentionally not a desktop FPS estimate.
    public sealed class GooseDeviceMonitor : MonoBehaviour
    {
        [Serializable] public class Sample
        {
            public string build=GooseRuntimePerformance.BuildId,platform,scene;public int width,height,total,visible,renderers,materialSlots,triangles,dynamicBodies,awakeBodies;
            public float fps,p95ms,physicsStep;
        }
        readonly float[] frames=new float[120],sorted=new float[120];int cursor,count;
        GooseGame game;Text label;float next;bool requested;
        public Sample Latest {get;private set;}
        public void Initialize(GooseGame owner)
        {
            game=owner;
            label=game.Hud.Label(game.Hud.TimeText.transform.parent,"",new Rect(16,1084,688,32),18,new Color(.2f,.13f,.06f));
            label.gameObject.SetActive(false);
        }
        public void Toggle(){requested=!requested;next=0;game.Hud.Toast(requested?"已开启性能数据，继续游戏后显示":"已关闭性能数据");}
        void Update()
        {
            bool enabled=requested||game.ReferenceTrial;
            label.gameObject.SetActive(enabled&&game.Playing);
            if(!enabled||!game.Playing||game.Paused||game.Preparing||!game.SpawnComplete)return;
            frames[cursor]=Time.unscaledDeltaTime*1000;cursor=(cursor+1)%frames.Length;count=Mathf.Min(count+1,frames.Length);
            if(Time.unscaledTime<next)return;next=Time.unscaledTime+1;
            var sample=new Sample{platform=Application.platform.ToString(),scene=game.Theme.id,width=Screen.width,height=Screen.height,
                total=game.Total,physicsStep=Time.fixedDeltaTime};
            float sum=0;for(int i=0;i<count;i++){sum+=frames[i];sorted[i]=frames[i];}
            Array.Sort(sorted,0,count);sample.fps=count*1000/Mathf.Max(1,sum);sample.p95ms=sorted[(int)((count-1)*.95f)];
            foreach(var item in game.Items)if(item&&!item.Picked&&item.gameObject.activeInHierarchy)
            {
                if(!item.Body.isKinematic){sample.dynamicBodies++;if(!item.Body.IsSleeping())sample.awakeBodies++;}
                if(item.DepthVisible){sample.visible++;sample.renderers+=item.RenderCount;sample.materialSlots+=item.DrawSlots;sample.triangles+=item.Triangles;}
            }
            Latest=sample;label.text=$"R3 FPS {sample.fps:0}  ·  可见 {sample.visible}  ·  动态 {sample.dynamicBodies} / 活动 {sample.awakeBodies}  ·  {sample.triangles/1000f:0}k 面";
            Debug.Log("[GooseDevice] "+JsonUtility.ToJson(sample));
        }
    }
}
