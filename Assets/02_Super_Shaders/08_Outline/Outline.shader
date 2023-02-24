Shader "Custom/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Space(10)]
        _OutColor ("Outline Color", Color) = (1, 1, 1, 1)
        _OutSize ("Outline Size", Range(0.0, 0.2)) = 0.1
    }
    SubShader
    {
        Pass
        {
            Name "Outline Pass"

            Tags
            {
                "Queue"="Transparent" //Activa la transparencia en el shader (Pero tambien hay que configurarlo como tal desde la opcion Render Queue en el inspector para que el outile no se merga con el de otros objetos con el mismo shader al estar en frente de ellos)
            }
            Blend SrcAlpha OneMinusSrcAlpha //Activa la transparencia por defecto
            ZWrite Off //Desactiva el ZBuffer para evitar errores graficos
            //NOTA: El ZWrite se desactiva cuando se usan transparencias y para que estas funcionen se usan las opciones de blending, asi que estos 3 dependen entre si para que funcionen:
            /*
            1. Tags{"Queue"="Transparent"}: Activa las transparencias
            2. Blend SrcAlpha OneMinusSrcAlpha: Hace que funcionen
            3. ZWrite Off: Evita errores graficos
            */

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
            float4 _OutColor;
            float _OutSize;

            //Funcion que calcula el outline
            float4 Outline(float4 vertexPos, float outSize)
            {
                float4x4 scale = float4x4
                (
                    //El valor de outSize se suma al tamaño de la matriz de los vertices (esta matriz lo sera porque en el return multiplicara por la posicion de los vertices), para que se renderice en todo el contorno del objeto
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
                return float4(_OutColor.rgb, col.a); //... se usara su canal alpha para que el outline tenga la forma del objeto y se pueda renderizar a su alrededor
            }
            ENDCG
        }

        Pass
        {
            Name "Texture Pass"

            Tags
            {
                "Queue"="Transparent+1" //Tiene +1 para que se renderize sobre el pase anterior y la textura quede sobre el outline
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

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
                return col;
            }
            ENDCG
        }
    }
}