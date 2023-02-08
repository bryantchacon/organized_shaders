Shader "Custom/Queue"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent" //Valores en la p. 68, recordar que Queue no invierte el algoritmo de pintado convencional (de atras hacia adelante (esto para objetos semi transparentes), por eso este shader al tener el Queue en Transparent (3000) se renderizara sobre los de menor valor, como Geometry (2000) aunque este detras de ellos
            "IgnoreProjector"="False" //Valor por default, su funcion es activar/desactivar que la camara proyecte algo sobre los objetos, False proyectara, True no proyectara
        }
        ZWrite Off //Para que funcione y el objeto se renderice sobre los demas, esos y este deben tener el ZWrite en Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}