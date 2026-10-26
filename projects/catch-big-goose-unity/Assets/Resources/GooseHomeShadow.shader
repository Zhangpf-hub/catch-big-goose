Shader "Goose/HomeShadow" {
 Properties { _ShadowColor("Shadow tint",Color)=(.16,.10,.05,.28) _ContactStrength("Contact projection",Float)=1 _TableCenter("Table XZ and top",Vector)=(100,0,-.1,2.3) _HomeLightDir("Light direction",Vector)=(-.37,.77,-.52,0) }
 SubShader { Tags {"Queue"="Transparent-10" "RenderType"="Transparent"}
  Blend SrcAlpha OneMinusSrcAlpha ZWrite Off Cull Off
  Pass {Tags {"LightMode"="ForwardBase"}
   CGPROGRAM
   #pragma vertex vert
   #pragma fragment frag
   #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
   #include "UnityCG.cginc"
   #include "AutoLight.cginc"
   fixed4 _ShadowColor;
   float _ContactStrength;float4 _TableCenter,_HomeLightDir;
   struct appdata {float4 vertex:POSITION;};
   struct v2f {float4 pos:SV_POSITION;float3 worldPos:TEXCOORD0;SHADOW_COORDS(1)};
   v2f vert(appdata v){v2f o;o.pos=UnityObjectToClipPos(v.vertex);o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;TRANSFER_SHADOW(o);return o;}
   fixed4 frag(v2f i):SV_Target {
    UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
    // The circular tabletop's soft planar projection also works when a
    // transparent receiver has no opaque depth. Project adaptation, not SSAO.
    float2 center=_TableCenter.xy-_HomeLightDir.xz*(_TableCenter.z-i.worldPos.y)/max(.1,_HomeLightDir.y);
    half contact=(1-smoothstep(_TableCenter.w-.08,_TableCenter.w+.22,length(i.worldPos.xz-center)))*.12h;
    [unroll] for(int j=0;j<4;j++) {
      float2 foot=_TableCenter.xy+float2((j&1)? .99:-.99,(j&2)? .99:-.99);
      contact=max(contact,(1-smoothstep(.06,.21,length(i.worldPos.xz-foot)))*.22h);
    }
    return fixed4(_ShadowColor.rgb,max((1-atten)*_ShadowColor.a,contact*_ContactStrength));
   }
   ENDCG
  }
 }Fallback Off
}
