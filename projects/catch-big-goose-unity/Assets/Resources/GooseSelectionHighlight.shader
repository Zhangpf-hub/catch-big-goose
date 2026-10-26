Shader "Goose/SelectionHighlight" {
 Properties {
  _MainTex("Source texture",2D)="white"{}
  _OverlayBackColor("Source tint",Color)=(1,1,1,1)
  _OverlayColor("Selection overlay",Color)=(1,.9215686,.0156863,.5)
  _OverlayData("Speed, minimum, blending",Vector)=(1,.5,1,1)
  _OutlineColor("Outline",Color)=(0,0,0,1)
  _OutlineWidth("Source width / 100",Float)=.002
  _GlowWidth("Source glow width / 100",Float)=.0025
  _ConstantWidth("Constant width",Float)=1
  _SeeThrough("Occluded intensity",Float)=2.62
  _SeeThroughTintColor("Occluded tint",Color)=(1,.8169587,0,1)
  _SeeThroughNoise("Occluded scan noise",Float)=.47
 }
 SubShader {
  Tags {"Queue"="Transparent+121" "RenderType"="Transparent" "DisableBatching"="True"}
  CGINCLUDE
  #include "UnityCG.cginc"
  sampler2D _MainTex;
  float4 _MainTex_ST,_OverlayBackColor,_OverlayColor,_OverlayData,_OutlineColor;
  float4 _SelectionGlow,_SelectionGlow2,_SelectionGlowColor,_SeeThroughTintColor;
  UNITY_INSTANCING_BUFFER_START(Selection)
   UNITY_DEFINE_INSTANCED_PROP(float4,_Direction)
  UNITY_INSTANCING_BUFFER_END(Selection)
  float _OutlineWidth,_GlowWidth,_ConstantWidth,_SeeThrough,_SeeThroughNoise;
  struct appdata {float4 vertex:POSITION;float3 normal:NORMAL;float2 uv:TEXCOORD0;UNITY_VERTEX_INPUT_INSTANCE_ID};
  struct v2f {float4 pos:SV_POSITION;float2 uv:TEXCOORD0;};
  float2 ScreenNormal(float3 normal) {
   float3 world=UnityObjectToWorldNormal(normal);
   float2 n=mul((float3x3)UNITY_MATRIX_V,world).xy;
   n*=rsqrt(max(dot(n,n),1e-12));
   return mul((float2x2)UNITY_MATRIX_P,n);
  }
  float WidthFactor(float4 clip) {
   // Recovered GL: lerp(2, lerp(clip.z,2,P[3][3]),constantWidth).
   // Convert platform clip depth to the recovered OpenGL [-w,w] convention.
   float glZ=clip.z;
   #if defined(UNITY_REVERSED_Z)
    glZ=clip.w-2*clip.z;
   #else
    glZ=lerp(2*clip.z-clip.w,clip.z,-UNITY_NEAR_CLIP_VALUE);
   #endif
   return lerp(2,lerp(glZ,2,unity_OrthoParams.w),_ConstantWidth);
  }
  v2f vert(appdata v) {
   UNITY_SETUP_INSTANCE_ID(v);
   v2f o;o.pos=UnityObjectToClipPos(v.vertex);o.uv=TRANSFORM_TEX(v.uv,_MainTex);return o;
  }
  v2f vertOverlay(appdata v) {
   v2f o=vert(v);
   #if defined(UNITY_REVERSED_Z)
    o.pos.z+=.0001;
   #else
    o.pos.z-=.0001;
   #endif
   return o;
  }
  v2f vertOutline(appdata v) {
   v2f o=vert(v);
   float4 direction=UNITY_ACCESS_INSTANCED_PROP(Selection,_Direction);
   o.pos.xy+=WidthFactor(o.pos)*(ScreenNormal(v.normal)*_OutlineWidth+direction.xy*_OutlineWidth);
   return o;
  }
  v2f vertGlow(appdata v) {
   v2f o=vert(v);
   float width=_SelectionGlow.y*(1+.25*sin(_Time.w*_SelectionGlow2.y))+_SelectionGlow2.x;
   float4 direction=UNITY_ACCESS_INSTANCED_PROP(Selection,_Direction);
   o.pos.xy+=WidthFactor(o.pos)*(ScreenNormal(v.normal)+direction.xy)*width;
   return o;
  }
  fixed4 zero(v2f i):SV_Target {return 0;}
  fixed4 outline(v2f i):SV_Target {return _OutlineColor;}
  half4 glow(v2f i):SV_Target {
   float d=saturate(frac(dot(floor(i.pos.xy*_SelectionGlow.z),_SelectionGlow.ww))+_SelectionGlow2.z);
   return half4(_SelectionGlowColor.rgb,d*_SelectionGlow.x);
  }
  half4 overlay(v2f i):SV_Target {
   half4 source=tex2D(_MainTex,i.uv)*_OverlayBackColor;
   half4 color=lerp(_OverlayColor,source*_OverlayColor,_OverlayData.z);
   float phase=frac(fmod(_Time.y,1000)*_OverlayData.x);
   color.a*=2*(1-_OverlayData.y)*abs(.5-phase)+_OverlayData.y;
   return color;
  }
  half4 seeThrough(v2f i):SV_Target {
   half3 color=lerp(tex2D(_MainTex,i.uv).rgb,_SeeThroughTintColor.rgb,_SeeThroughTintColor.a);
   color+=_SeeThroughNoise*frac(frac(_Time.w)*i.pos.y)*.1;
   float alpha=_SeeThrough*(1+_SeeThroughNoise*(2*frac(i.pos.y*.5)-2));
   return half4(color,alpha);
  }
  v2f clearVertex(uint id:SV_VertexID) {
   v2f o;o.pos=float4(float2((id<<1)&2,id&2)*2-1,0,1);o.uv=0;return o;
  }
  ENDCG
  // Clear only the two effect bits; preserve UI/other camera stencil ownership.
  Pass { Name "Clear" Cull Off ZTest Always ZWrite Off ColorMask 0
   Stencil {Ref 0 ReadMask 3 WriteMask 3 Comp Always Pass Zero}
   CGPROGRAM
   #pragma target 3.0
   #pragma vertex clearVertex
   #pragma fragment zero
   ENDCG
  }
  Pass { Name "Mask" Cull Back ZTest Always ZWrite Off ColorMask 0
   Stencil {Ref 2 ReadMask 2 WriteMask 2 Comp Always Pass Replace}
   CGPROGRAM
   #pragma vertex vert
   #pragma fragment zero
   ENDCG
  }
  Pass { Name "Glow" Cull Back ZTest Always ZWrite Off Blend SrcAlpha OneMinusSrcAlpha
   Stencil {Ref 2 ReadMask 2 WriteMask 2 Comp NotEqual Pass Keep}
   CGPROGRAM
   #pragma vertex vertGlow
   #pragma fragment glow
   #pragma multi_compile_instancing
   ENDCG
  }
  Pass { Name "Outline" Cull Back ZTest LEqual ZWrite On Blend SrcAlpha OneMinusSrcAlpha
   Stencil {Ref 2 ReadMask 2 WriteMask 2 Comp NotEqual Pass Replace}
   CGPROGRAM
   #pragma vertex vertOutline
   #pragma fragment outline
   #pragma multi_compile_instancing
   ENDCG
  }
  Pass { Name "Overlay" Cull Back ZTest LEqual ZWrite Off Blend SrcAlpha OneMinusSrcAlpha
   CGPROGRAM
   #pragma vertex vertOverlay
   #pragma fragment overlay
   ENDCG
  }
  Pass { Name "SeeThrough" Cull Back ZTest Greater ZWrite Off Blend SrcAlpha OneMinusSrcAlpha
   Stencil {Ref 1 ReadMask 1 WriteMask 1 Comp NotEqual Pass Replace}
   CGPROGRAM
   #pragma vertex vert
   #pragma fragment seeThrough
   ENDCG
  }
 }
 Fallback Off
}
