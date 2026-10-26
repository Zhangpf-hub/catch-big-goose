#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
sampler2D _MainTex,_Matcap,_Matcap1,_Matcap2,_MatcapMask,_AOMap;
float4 _MainTex_ST,_Color,_MatcapTint,_MatcapTint1,_MatcapTint2,_SourceLightTint;
half _MatcapStrength,_MatcapStrength1,_MatcapStrength2,_Opacity,_AOStrength;
half _FillStrength,_DirectStrength;
struct appdata {float4 vertex:POSITION;float3 normal:NORMAL;float2 uv:TEXCOORD0;UNITY_VERTEX_INPUT_INSTANCE_ID};
struct v2f {float4 pos:SV_POSITION;float2 uv:TEXCOORD0;half3 normal:TEXCOORD1;float3 worldPos:TEXCOORD2;SHADOW_COORDS(3) UNITY_VERTEX_OUTPUT_STEREO};
v2f vert(appdata v)
{
    v2f o;UNITY_SETUP_INSTANCE_ID(v);UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    o.pos=UnityObjectToClipPos(v.vertex);o.uv=TRANSFORM_TEX(v.uv,_MainTex);
    o.normal=UnityObjectToWorldNormal(v.normal);o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;TRANSFER_SHADOW(o);return o;
}
fixed4 frag(v2f i):SV_Target
{
    half3 n=normalize(i.normal);half ndl=dot(n,normalize(_WorldSpaceLightPos0.xyz));
    half diffuse=smoothstep(-.15h,.85h,ndl);
    UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
    half3 base=tex2D(_MainTex,i.uv).rgb*_Color.rgb;
    half3 rgb=base*(_FillStrength+_DirectStrength*diffuse*_LightColor0.rgb*lerp(.35h,1.h,atten))*saturate(_SourceLightTint.rgb/.27h);
    #if defined(REFERENCE_AO)
        rgb*=lerp(1.h,tex2D(_AOMap,i.uv).r,saturate(_AOStrength));
    #endif
    // Source MatCap textures/weights/tints are retained. The combination and
    // view-space mapping are our bounded mobile approximation, not recovered HLSL.
    half3 viewNormal=normalize(mul((half3x3)UNITY_MATRIX_V,n));half2 uv=viewNormal.xy*.5h+.5h;
    half3 cap=tex2D(_Matcap,uv).rgb*_MatcapStrength*_MatcapTint.rgb;
    #if defined(REFERENCE_DUAL_MATCAP)
        half2 split=saturate(tex2D(_MatcapMask,i.uv).rg);
        cap*=saturate(1.h-split.x-split.y);
        cap+=tex2D(_Matcap1,uv).rgb*_MatcapStrength1*_MatcapTint1.rgb*split.x;
        cap+=tex2D(_Matcap2,uv).rgb*_MatcapStrength2*_MatcapTint2.rgb*split.y;
    #endif
    rgb+=cap*2.h;
    #if defined(REFERENCE_GLASS)
        half facing=1.h-saturate(abs(viewNormal.z));
        half edge=facing*facing;
        // Separate, front-face transparent layer. No grab-pass/refraction or
        // dynamic cubemap; source alpha is an input, not an exact optical match.
        return fixed4(rgb+edge*.12h,saturate(_Opacity+edge*.18h));
    #else
        return fixed4(rgb,1);
    #endif
}
