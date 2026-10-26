Shader "Goose/DuckMobile" {
 Properties {
  _MainTex ("Color", 2D) = "white" {}
  _Color ("Tint", Color) = (1,1,1,1)
  _MetallicGlossMap ("Metal (R), Smoothness (A)", 2D) = "black" {}
 }
 SubShader {
  Tags { "RenderType"="Opaque" } LOD 150
  Pass {
   Tags { "LightMode"="ForwardBase" }
   CGPROGRAM
   #pragma vertex vert
   #pragma fragment frag
   #pragma multi_compile_instancing
   #include "UnityCG.cginc"
   #include "Lighting.cginc"
   sampler2D _MainTex, _MetallicGlossMap;
   float4 _MainTex_ST; fixed4 _Color;
   struct appdata { float4 vertex:POSITION; float3 normal:NORMAL; float2 uv:TEXCOORD0; UNITY_VERTEX_INPUT_INSTANCE_ID };
   struct v2f { float4 pos:SV_POSITION; float2 uv:TEXCOORD0; half3 normal:TEXCOORD1; float3 world:TEXCOORD2; UNITY_VERTEX_OUTPUT_STEREO };
   v2f vert(appdata v) {
    v2f o; UNITY_SETUP_INSTANCE_ID(v); UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    o.pos=UnityObjectToClipPos(v.vertex);o.uv=TRANSFORM_TEX(v.uv,_MainTex);
    o.normal=UnityObjectToWorldNormal(v.normal);o.world=mul(unity_ObjectToWorld,v.vertex).xyz;return o;
   }
   fixed4 frag(v2f i):SV_Target {
    half3 albedo=tex2D(_MainTex,i.uv).rgb*_Color.rgb;
    half4 surface=tex2D(_MetallicGlossMap,i.uv);
    half metal=surface.r,smooth=surface.a;
    half3 n=normalize(i.normal),l=normalize(_WorldSpaceLightPos0.xyz),v=normalize(_WorldSpaceCameraPos-i.world);
    half ndl=saturate(dot(n,l));half3 h=normalize(l+v);
    half3 daylight=.52h+saturate(_LightColor0.rgb)*(.38h*ndl)+.10h*saturate(n.y);
    half spec=pow(saturate(dot(n,h)),lerp(8.0h,100.0h,smooth))*ndl;
    half rim=pow(1-saturate(dot(n,v)),4);
    // A single-pass stylized approximation. Preserve authored metal/smoothness
    // channels without adding reflection probes or additional light passes.
    half3 diffuse=albedo*daylight*lerp(1,.78h,metal);
    half3 f0=lerp(.04h,albedo,metal);
    half3 color=diffuse+f0*(spec*lerp(.4h,1.2h,smooth)+rim*.25h)*saturate(_LightColor0.rgb);
    return fixed4(color,1);
   }
   ENDCG
  }
 }
 Fallback "Unlit/Texture"
}
