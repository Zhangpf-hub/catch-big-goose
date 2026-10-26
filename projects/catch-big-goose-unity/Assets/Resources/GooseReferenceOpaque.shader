Shader "Goose/ReferenceOpaque" {
 Properties {
  _FillStrength("Fill",Float)=.38 _DirectStrength("Direct",Float)=.62
  _MainTex("Base Color",2D)="white"{} _Color("Tint",Color)=(1,1,1,1)
  _SourceLightTint("Source Base Light Control",Vector)=(.27,.27,.27,0)
  _AOMap("Source AO",2D)="white"{} _AOStrength("Source AO Strength",Range(0,1))=0
  _Matcap("MatCap",2D)="black"{} _MatcapStrength("MatCap Scale",Float)=0
  _MatcapTint("Source MatCap Tint",Vector)=(.277,.277,.277,0)
  _Matcap1("MatCap 1",2D)="black"{} _MatcapStrength1("MatCap 1 Scale",Float)=0
  _MatcapTint1("Source MatCap 1 Tint",Vector)=(.277,.277,.277,0)
  _Matcap2("MatCap 2",2D)="black"{} _MatcapStrength2("MatCap 2 Scale",Float)=0
  _MatcapTint2("Source MatCap 2 Tint",Vector)=(.277,.277,.277,0)
  _MatcapMask("Material Split",2D)="black"{}
 }
 SubShader { Tags {"RenderType"="Opaque" "Queue"="Geometry"}
  Pass { Tags {"LightMode"="ForwardBase"}
   CGPROGRAM
   #pragma vertex vert
   #pragma fragment frag
   #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
   #pragma multi_compile_instancing
   #pragma shader_feature_local REFERENCE_DUAL_MATCAP
   #pragma shader_feature_local REFERENCE_AO
   #include "GooseReferenceLighting.cginc"
   ENDCG
  }
  UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
 }
 Fallback "Diffuse"
}
