Shader "VFX/PortalVortice"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Intencity ("Intencity", Range(0, 1)) = 1
        _Speed ("Speed", Range(-1, 1)) = -0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent+2"
        }
        ZTest Greater //Renderiza el objeto solo cuando esta detras de otros, se complementa con "Queue"="Transparent+2"
        Blend SrcAlpha One //Blend aditivo
        Cull Front //Hace que solo se renderice la cara frontal
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
            float4 _Color;
            float _Intencity;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uvs = fixed2(i.uv.x, i.uv.y + (_Time.y * _Speed)); //Agrega movimiento a la coordenada V de las UVs
                fixed4 col = tex2D(_MainTex, uvs);
                return fixed4(col.rgb * _Color.rgb, col.a * i.uv.y * _Intencity);
            }
            ENDCG
        }
    }
}