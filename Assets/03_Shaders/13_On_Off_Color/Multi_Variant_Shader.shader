Shader "Custom/Multi_Variant_Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)

        //KeywordEnum puede alamacenar hasta 9 valores
        [KeywordEnum(On, Off)] _UseColor ("Use Color", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#pragma multi_compile es un Multi Variant Shader que compila todas las opciones que tenga la variable se utilicen o no, por eso es multi, en cambio #pragma shader_feature solo compila la opcion que se selecciona desde el inspector
            #pragma shader_feature _USECOLOR_ON _USECOLOR_OFF

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = 0;

                //if en CG
                #if _USECOLOR_OFF //Si _UseColor esta en Off...
                col = tex2D(_MainTex, i.uv); //... renderiza la textura
                #else //Si no...
                col = _Color; //... renderiza en color
                #endif //Fin del if

                return col;
            }
            ENDCG
        }
    }
}