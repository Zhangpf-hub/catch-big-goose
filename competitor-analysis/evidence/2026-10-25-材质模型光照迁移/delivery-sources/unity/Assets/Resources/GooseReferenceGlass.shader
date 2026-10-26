Shader "Goose/ReferenceGlass" {
 Properties {
  _MainTex("Base Color",2D)="white"{} _Color("Tint",Color)=(1,1,1,1) _Opacity("Source Alpha Adaptation",Range(0,1))=.1
  _SourceLightTint("Source Base Light Control",Vector)=(.27,.27,.27,0)
  _Matcap("MatCap",2D)="black"{} _MatcapStrength("MatCap Scale",Float)=0
  _MatcapTint("Source MatCap Tint",Vector)=(.277,.277,.277,0)
 }
 SubShader { Tags {"RenderType"="Transparent" "Queue"="Transparent"}
  Blend SrcAlpha OneMinusSrcAlpha ZWrite Off Cull Back
  Pass { Tags {"LightMode"="ForwardBase"}
   CGPROGRAM
   #pragma vertex vert
   #pragma fragment frag
   #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
   #pragma multi_compile_instancing
   #define REFERENCE_GLASS
   #include "GooseReferenceLighting.cginc"
   ENDCG
  }
 }
 Fallback Off
}
