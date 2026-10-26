Shader "Goose/ItemMobile" {
 Properties { _MainTex ("Color", 2D) = "white" {} _Color ("Tint", Color) = (1,1,1,1) }
 SubShader { Tags { "RenderType"="Opaque" } LOD 100
 Pass {
  Tags { "LightMode"="ForwardBase" }
  CGPROGRAM
  #pragma vertex vert
  #pragma fragment frag
  #pragma multi_compile_instancing
  #include "UnityCG.cginc"
  #include "Lighting.cginc"
  sampler2D _MainTex; float4 _MainTex_ST; fixed4 _Color;
  struct appdata { float4 vertex:POSITION; float3 normal:NORMAL; float2 uv:TEXCOORD0; UNITY_VERTEX_INPUT_INSTANCE_ID };
  struct v2f { float4 pos:SV_POSITION; float2 uv:TEXCOORD0; fixed3 light:COLOR0; UNITY_VERTEX_OUTPUT_STEREO };
  v2f vert(appdata v) { v2f o; UNITY_SETUP_INSTANCE_ID(v); UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
   o.pos=UnityObjectToClipPos(v.vertex);o.uv=TRANSFORM_TEX(v.uv,_MainTex);
   half3 n=UnityObjectToWorldNormal(v.normal);half d=saturate(dot(n,_WorldSpaceLightPos0.xyz));
   o.light=.32h + saturate(_LightColor0.rgb)*(.62h*d);return o; }
  fixed4 frag(v2f i):SV_Target { fixed4 c=tex2D(_MainTex,i.uv)*_Color; return fixed4(c.rgb*i.light,1); }
  ENDCG
 } } Fallback "Unlit/Texture"
}
