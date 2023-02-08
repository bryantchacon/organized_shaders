Shader "Custom/Matrix"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Header(VALUES)]
        [Space(10)]
        _xValue ("X", Range(-1, 1)) = 0
        _yValue ("Y", Range(-1, 1)) = 0
        _zValue ("Z", Range(-1, 1)) = 0
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
            float _xValue;
            float _yValue;
            float _zValue;

            //Funcion para manipular la matriz del objeto
            fixed4 matrixPos(fixed4 vertexPos)
            {
                fixed4x4 _matrix = fixed4x4 //Si todos los 1 se sustituyen por _Value, el efecto sera de encoger y agrandar al manipular el _Value desde el inspector
                (
                    1, _xValue, 0, 0,
                    _yValue, 1, 0, 0,
                    0, _zValue, 1, 0,
                    0, 0, 0, 0
                ); //Los primeros 3x3 valores donde estan los 1 permiten escalar o rotar los vertices, los 1 en si se refieren a la escala del objeto, y la ultima columna modificar su posicion (pero solo los primeros 3x3)

                return mul(_matrix, vertexPos);
            }

            v2f vert (appdata v)
            {
                v2f o;

                fixed4 _newVertexPos = matrixPos(v.vertex);

                o.vertex = UnityObjectToClipPos(_newVertexPos);
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