Shader "Custom/NormalMovement"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", Range(1, 5)) = 1
        _Amplitude ("Amplitude", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float4 normal : NORMAL; //Con esto ya se pueden usar las normales del objeto
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            float _Amplitude;

            //Funcion para mover los vertices por medio de las normales
            float4 Direction (float4 vertexPos, float4 normalPos)
            {
                vertexPos += ((cos(_Time.y * _Speed) + 1) * _Amplitude) * normalPos; //El nuevo calculo de la posicion de los vertices se multiplica por normalPos(posicion de las normales) para afectarlas y que el movimiento de las caras se lleve acabo; seguir la direccion de las normales, y para obtener un resultado diferente y que sea un efecto de escalado y contraccion del objeto basta con cambiar normalPos por vertexPos, asi, el efecto que se logra seria como el de un latido de corazon
                float4 vertex = UnityObjectToClipPos(vertexPos);
                return vertex;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = Direction(v.vertex, v.normal);
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