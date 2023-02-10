Shader "Custom/Dissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DisTex ("Dissolve Texture", 2D) = "white" {}
        [Header(DISSOLVE PROPERTIES)]
        [Space(10)]
        _DisColor ("Color", Color) = (1, 1, 1, 1)
        _DisSmooth ("Smooth", Range(0.0, 0.2)) = 0
        _DisThreshold ("Threshold", Range(-0.2, 1.2)) = 1
        [IntRange]
        _Movement ("Movement", Range(0, 1)) = 0
        [IntRange]
        _ThreshdAnim ("Threshold Animation", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
        }

        Pass
        {
            Name "Color Pass"

            Blend SrcAlpha One //Blend aditivo, hace que el efecto se vea mas llamativo porque parece que estuviera iluminado

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
            sampler2D _DisTex;
            float4 _MainTex_ST;
            float4 _DisColor;
            float _DisSmooth;
            float _DisThreshold;
            float _Movement;
            float _ThreshdAnim;

            v2f vert (appdata v)
            {
                v2f o;

                //Da animacion en Y, debe ir en ambos pases
                if(_Movement)
                {
                    v.vertex.y += sin(_Time.y) / 7;
                }

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //NOTA: Estas lineas de codigo se repiten en el segundo pass pero sin el 0.1 en smoothstep(), esto para que los bordes con color y suavisado del efecto (este pass), y el efecto en si (segundo pass), coincidan y quede bien visualmente
                float dissolve = tex2D(_DisTex, i.uv).r; //Asigna la textura de distorsion al efecto. Generalmente las texturas de distorsion se guardan en un solo canal rgb (en este caso r), por eso la variable es de una sola dimension

                //Da animacion al Threshold, * 1.2 aumenta la velocidad, Threshold debe valer 0.8 para que la animacion funcione bien, debe ir en ambos pases
                if(_ThreshdAnim)
                {
                    _DisThreshold += sin(_Time.y * 1.2);
                }

                float smooth = smoothstep(_DisThreshold + 0.1, _DisThreshold - _DisSmooth, dissolve); //0.1 es para que el efecto tenga un desface entre este pass y el segundo y en ese desfase aplicar el color del efecto.
                //NOTA: Para mas informacion sobre smoothstep() ir a https://developer.download.nvidia.com/CgTutorial/cg_tutorial_appendix_e.html o p.166 del libro. Pero en resumen retorna una interpolacion entre dos valores (un min y un max, primeros dos parametros), y clamplea a x (el 3er parametro), entre ellos, asi que el suavisado es posible porque el primero suma un parametro y el segundo le resta otro, haciendo que se sobrepongan (suponinendo que ambos empiezan en un punto medio), y como el valor de x es la textura de distorsion, esta es la que ira apareciendo al activar el efecto, al menos esta es mi interpretacion
                fixed4 col = tex2D(_MainTex, i.uv);
                col.a *= smooth; //Agrega los bordes con color y suavisado del efecto al alpha de col

                return float4(_DisColor.rgb, col.a); //Se le agrega color a los bordes con color y suavisado del efecto y se retorna, el efecto sera visible cuando se modifique _DisThreshold en el inspector y la suavidad de los bordes con _DisSmooth
            }
            ENDCG
        }

        Pass
        {
            Name "Texture Pass"

            Blend SrcAlpha OneMinusSrcAlpha //Blend normal

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
            sampler2D _DisTex;
            float4 _MainTex_ST;
            float _DisSmooth;
            float _DisThreshold;
            float _Movement;
            float _ThreshdAnim;

            v2f vert (appdata v)
            {
                v2f o;

                //Da animacion en Y, debe ir en ambos pases
                if(_Movement)
                {
                    v.vertex.y += sin(_Time.y) / 7;
                }

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dissolve = tex2D(_DisTex, i.uv).r;

                //Da animacion al Threshold, * 1.2 aumenta la velocidad, Threshold debe valer 0.8 para que la animacion funcione bien, debe ir en ambos pases
                if(_ThreshdAnim)
                {
                    _DisThreshold += sin(_Time.y * 1.2);
                }

                float smooth = smoothstep(_DisThreshold, _DisThreshold - _DisSmooth, dissolve);
                fixed4 col = tex2D(_MainTex, i.uv);
                col.a *= smooth;

                return col;
            }
            ENDCG
        }
    }
}