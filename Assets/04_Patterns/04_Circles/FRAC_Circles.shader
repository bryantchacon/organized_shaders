Shader "USB/FRAC_Circles"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Header(CIRCLES PROPERTIES)]
        [Space(10)]
        _Color ("Color", Color) = (1,1,1,1)
        [IntRange]_Quantity ("Quantity", Range(1, 5)) = 3 //[IntRange] al inicio hace que el slider sea en enteros
        _Radius ("Radius", Range(0.0, 0.5)) = 0.3
        _Center ("Center", Range(0, 1)) = 0.5
        _Smooth ("Smooth", Range(0.0, 0.5)) = 0.01
        [Toggle]_Invert ("Invert", Float) = 0
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

            #include "UnityCG.cginc"
            //LocalFunctionsCG.cginc incluye la funcion circle() que se usa en el fragment shader
            #include "Assets/CGFiles/LocalFunctionsCG.cginc"            

            //Pragma del toggle _Invert
            #pragma shader_feature _INVERT_ON

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
            float _Quantity;
            float _Radius;
            float _Center;
            float _Smooth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv *= _Quantity; //Define las repeticiones que tendra la textura
                float2 fuv = frac(i.uv); //frac() devuelve los decimales de un numero; lo que hace aqui es definir que cada repeticion de la textura sea del tamaño que le corresponde en las UV, segun la cantidad de repeticiones que se indiquen, por ejemplo, si son 3 repeticiones seria; 1 / 3 = 0.33, cada repeticion tendria un tamaño de 0.33 en ambas coordenadas
                float cir = circle(fuv, _Center, _Radius, _Smooth);

                //CG if para usar el Toggle _Invert
                #if _INVERT_ON
                    cir = abs(1 - cir); //Invierte la cuadricula
                    return cir * _Color;
                #else
                    return cir * _Color;
                #endif

                return float4(cir.xxx, 1);
            }
            ENDCG
        }
    }
}