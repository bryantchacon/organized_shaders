Shader "VFX/Pupil"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Intencity ("Intencity", Range(0, 1)) = 1
        [Header(OUTLINE PROPERTIES)]
        [Space(10)]
        _OutColor ("Color", Color) = (1, 1, 1, 1)
        _OutSize ("Size", Range(0.0, 0.2)) = 0.1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent+3"
        }
        ZWrite Off //Desactiva el zbuffer
        ZTest Greater //Renderiza el objeto solo cuando esta detras de otros, se complementa con "Queue"="Transparent+3"
        Blend SrcAlpha One //Blend aditivo
        Cull Back
        LOD 100
        //NOTA: El ZWrite se desactiva cuando se usan transparencias y para que estas funcionen se usan las opciones de blending, asi que estos 3 dependen entre si para que funcionen:
        /*
        1. Tags{"Queue"="Transparent"}: Activa las transparencias
        2. Blend SrcAlpha OneMinusSrcAlpha: Hace que funcionen
        3. ZWrite Off: Evita errores graficos
        */

        Pass
        {
            Name "Outline Pass"

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
            float _Intencity;
            float4 _OutColor;
            float _OutSize;

            //Funcion para calcular el outline
            float4 Outline(float4 vertexPos, float outSize)
            {
                float4x4 scale = float4x4
                (
                    //El valor de outSize se suma al tamaño de la matriz de los vertices (la matriz es 4x4 porque en el return se multiplica por la posicion de los vertices que son float4), para que se renderice en todo el contorno del objeto
                    1 + outSize, 0, 0, 0,
                    0, 1 + outSize, 0, 0,
                    0, 0, 1 + outSize, 0,
                    0, 0, 0, 1 + outSize
                );

                return mul(scale, vertexPos); //Retorna la multiplicacion de la matriz scale por la posicion de los vertices para que el outline pueda renderizarse
            }

            v2f vert (appdata v)
            {
                v2f o;
                
                float4 vertexPos = Outline(v.vertex, _OutSize);

                o.vertex = UnityObjectToClipPos(vertexPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv); //La asignacion de la textura no se elimina porque...
                return float4(_OutColor.rgb, col.a * i.uv.y * _Intencity); //... se usara su canal alpha para que el outline tenga la forma del objeto y se pueda renderizar a su alrededor
            }
            ENDCG
        }

        Pass
        {
            Name "Texture Pass"

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
            float _Intencity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return fixed4(col.rgb * _Color.rgb, col.a * i.uv.y * _Intencity);
            }
            ENDCG
        }
    }
}