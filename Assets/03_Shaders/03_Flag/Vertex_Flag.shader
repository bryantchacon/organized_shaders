Shader "Custom/Vertex_Flag"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", Range(1, 5)) = 1
        _Frequency ("Frequency", Range(1, 5)) = 1
        _Amplitude ("Amplitude", Range(1, 5)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        Cull Off

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
            float _Speed;
            float _Frequency;
            float _Amplitude;

            //Funcion para el movimiento de la bandera
            float4 flagMovement(float4 vertexPosition, float2 uv)
            {
                vertexPosition.y += sin((uv.x - (_Time.y * _Speed)) * _Frequency) * (uv.x * _Amplitude);
                /*
                • Es vertexPosition.y es para aplicar el movimiento ondulatorio de enfrente hacia atras sobre el eje Y de los vertices de la bandera ya que se giro hacia enfrente
                • Se usa sin() porque este inicia en 0, para que asi el movimiento inicie desde el asta de la bandera
                • uv.x es para que el movimiento ondulatorio funcione sobre el eje X de las UVs
                • _Time es una variable propia de shaderlab, y .y es el valor de tiempo a velocidad normal
                • _Speed es para manipular la velocidad del efecto desde el inspector
                • _Frequency manipula la frecuencia de las ondas desde el inspector
                • uv.x va aqui otra vez para que no se mueva la base de la bandera al multiplicarse por la amplitud porque sin() al inicio vale 0, y si, la base es el extremo derecho, si se quiere que la base sea el extremo izquierdo basta con restarle 1 a uv.x aqui
                • _Amplitude manipula la amplitud de la ondulacion desde el inspector
                */

                return vertexPosition;
            }

            v2f vert (appdata v)
            {
                v2f o;
                float4 fm = flagMovement(v.vertex, v.uv);
                o.vertex = UnityObjectToClipPos(fm); //Se pasa fm porque en si el valor que regresa flagMovement() son las posiciones de los vertices, incluidos los del eje Y que se recalculan en la funcion
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