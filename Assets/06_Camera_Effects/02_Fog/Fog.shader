//Configuracion del fog:
/*
1. Main Camera > Camera > Rendering Path > Forward
2. Window > Rendering > Lighting > Enviroment > Other Settings > Fog > Activarlo
3. Se puede manipular el color, modo e intensidad
NOTA: Nada mas activarlo no se notara porque Density viene en 0.01, al subirlo ya se notara
*/

Shader "Custom/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //fog 1/4 (Pragma)
            #pragma multi_compile_fog

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
                UNITY_FOG_COORDS(1) //fog 2/4 (Macro)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex); //fog 3/4 (Macro)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                UNITY_APPLY_FOG(i.fogCoord, col); //fog 4/4 (Macro)
                return col;
            }
            ENDCG
        }
    }
}