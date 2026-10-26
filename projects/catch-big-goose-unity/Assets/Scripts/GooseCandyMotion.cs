using System;
using UnityEngine;
using UnityEngine.EventSystems;
namespace CatchGoose
{
    public sealed class GooseCandyMotion:MonoBehaviour,IPointerDownHandler,IPointerUpHandler,IPointerExitHandler
    {
        public float IdleAmplitude,Phase,RockDegrees=1.2f,HopHeight,EntranceDelay=-1;
        public bool Rock;public Action Released;
        Transform visual;Vector3 original=Vector3.one,position;Quaternion rotation;CanvasGroup fade;
        float spring,velocity,born;bool held,settled=true;
        public const float HopDuration=.95f;
        public Transform Visual=>visual?visual:transform;
        void Awake(){SetVisual(transform);}
        public void SetVisual(Transform target)
        {visual=target;original=visual.localScale;rotation=visual.localRotation;position=visual.localPosition;fade=visual.GetComponent<CanvasGroup>();born=Time.unscaledTime;}
        public void OnPointerDown(PointerEventData e){held=true;settled=false;velocity=-1.8f;}
        public void OnPointerUp(PointerEventData e){bool click=held;held=false;settled=false;velocity=2.5f;if(click)Released?.Invoke();}
        public void OnPointerExit(PointerEventData e){held=false;}
        void OnDisable(){if(Visual){Visual.localScale=original;Visual.localRotation=rotation;Visual.localPosition=position;}spring=velocity=0;held=false;}
        void Update()
        {
            float dt=Time.unscaledDeltaTime,t=Time.unscaledTime+Phase,age=Time.unscaledTime-born;
            bool entering=EntranceDelay>=0&&age<EntranceDelay+.55f;
            if(IdleAmplitude==0&&!Rock&&HopHeight==0&&!entering&&!held&&Mathf.Abs(spring)<.0001f&&Mathf.Abs(velocity)<.002f)
            {if(!settled){Visual.localScale=original;settled=true;}return;}
            AdvanceSpring(ref spring,ref velocity,held?-.095f:0,dt);
            float p=EntranceDelay<0?1:Mathf.Clamp01((age-EntranceDelay)/.55f),q=p-1;
            float enter=1+2.70158f*q*q*q+1.70158f*q*q;
            float idle=IdleAmplitude*Mathf.Sin(t*2.5f);
            var bounce=IdleHop(t,HopHeight);float hop=bounce.x,squash=bounce.y;
            Visual.localScale=Vector3.Scale(original,new Vector3((1+idle-spring*.45f-squash*.4f)*Mathf.Lerp(.7f,1,enter),(1+idle+spring+squash)*Mathf.Lerp(.7f,1,enter),1));
            Visual.localPosition=position+Vector3.up*(hop-(1-enter)*32);
            Visual.localRotation=rotation*Quaternion.Euler(0,0,(Rock?Mathf.Sin(t*2.2f)*RockDegrees:0)+(1-enter)*-8);
            if(fade)fade.alpha=Mathf.Clamp01(p*3);
        }
        public static void AdvanceSpring(ref float value,ref float speed,float target,float dt)
        {
            // Exact damped oscillator integration: the same response at 30/60/120 Hz
            // and after uneven frames, without Euler overshoot or time clipping.
            const float damping=8,stiffness=165;
            float omega=Mathf.Sqrt(stiffness-damping*damping),offset=value-target;
            float decay=Mathf.Exp(-damping*dt),sine=Mathf.Sin(omega*dt),cosine=Mathf.Cos(omega*dt);
            value=target+decay*(offset*cosine+(speed+damping*offset)/omega*sine);
            speed=decay*(speed*cosine-(damping*speed+stiffness*offset)/omega*sine);
        }
        public static Vector2 IdleHop(float time,float height)
        {
            if(height==0)return Vector2.zero;
            float cycle=Mathf.Repeat(time,4.2f);
            if(cycle>=HopDuration)return Vector2.zero;
            float p=cycle/HopDuration,envelope=.5f-.5f*Mathf.Cos(p*Mathf.PI*2);
            // Zero velocity at lift-off and landing, including the squash envelope.
            return new Vector2(envelope*height,Mathf.Sin(p*Mathf.PI*2)*envelope*.025f);
        }
    }
}
