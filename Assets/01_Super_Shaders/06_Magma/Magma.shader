Shader "Custom/Magma"
{
    Properties
    {
        _RockTex ("Rock Texture", 2D) = "white" {}
        _MagmaTex ("Magma Texture", 2D) = "white" {}
        _DisTex ("Distortion Texture", 2D) = "white" {}
        [Header(DISTORTION PROPERTIES)]
        [Space(10)]
        _DisSpeed ("Speed", Range(-0.4, 0.4)) = 0.1
        _DisAmplitude ("Amplitude", Range(2, 10)) = 3
        [Header(WAVE PROPERTIES)]
        [Space(10)]
        _WaveSpeed ("Speed", Range(0, 5)) = 1
        _WaveFrequency ("Frequency", Range(0, 5)) = 1
        _WaveAmplitude ("Amplitude", Range(0, 1)) = 0.2
    }
    SubShader
    {
        //MAGMA PASS-----------------------------
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

            sampler2D _MagmaTex;
            sampler2D _DisTex;
            float4 _MagmaTex_ST; //Se encarga del tile y offset

            float _DisSpeed;
            float _DisAmplitude;

            float _WaveSpeed;
            float _WaveFrequency;
            float _WaveAmplitude;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //Calculos para el movimiento de los vertices
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex.y += sin((-worldPos.z + (_Time.y * _WaveSpeed)) * _WaveFrequency) * _WaveAmplitude;
                o.vertex.y += cos((-worldPos.x + (_Time.y * _WaveSpeed)) * _WaveFrequency) * _WaveAmplitude;
                
                o.uv = TRANSFORM_TEX(v.uv, _MagmaTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half distortion = tex2D(_DisTex, i.uv + (_Time * _DisSpeed)).r; //Guarda la distorcion, samplea la textura de distorcion a las UVs. Para generar movimiento en las UVs se les suma el resultado de tiempo * velocidad porque este es igual a movimiento, y como la variable es de una sola dimension, y la textura es gris, solo se usara el canal r de la operacion

                //Se pasa la distorsion a las uv y se divide entre _DisAmplitude para poder modificar la amplitud desde el inspector
                i.uv.x += distortion / _DisAmplitude;
                i.uv.y += distortion / _DisAmplitude;

                fixed4 col = tex2D(_MagmaTex, i.uv);
                return col;
            }
            ENDCG
        }

        //ROCK PASS-----------------------------
        Pass
        {
            //Este tag y blend hacen posible que se pueda ver la transparencia de la textura de roca, ademas de haber activado la opcion Alpha Is Transparency en las propiedades de la textura de roca en el inspector (no en la textura ya asignada en el shader, ahi no esta la opcion)
            Tags
            {
                "Queue"="Transparent"
            }
            Blend SrcAlpha OneMinusSrcAlpha

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

            sampler2D _RockTex;
            float4 _RockTex_ST;

            float _WaveSpeed;
            float _WaveFrequency;
            float _WaveAmplitude;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex.y += sin((-worldPos.z + (_Time.y * _WaveSpeed)) * _WaveFrequency) * _WaveAmplitude;
                o.vertex.y += cos((-worldPos.x + (_Time.y * _WaveSpeed)) * _WaveFrequency) * _WaveAmplitude;

                o.uv = TRANSFORM_TEX(v.uv, _RockTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_RockTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}