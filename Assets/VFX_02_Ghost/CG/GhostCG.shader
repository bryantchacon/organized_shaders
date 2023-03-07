Shader "VFX/GhostCG"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _UVDist ("UVDist", 2D) = "white" {}
        _Speed ("Speed", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off
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
                float2 uvdist : TEXCOORD1;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uvdist : TEXCOORD1;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _UVDist;
            float4 _MainTex_ST;
            float4 _UVDist_ST;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvdist = TRANSFORM_TEX(v.uvdist, _UVDist);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 disset = float2(i.uvdist.x, i.uvdist.y + (_Time.y * _Speed));
                fixed4 distortion = tex2D(_UVDist, disset);

                fixed2 colset = float2(distortion.x, i.uv.y);
                fixed4 col = tex2D(_MainTex, colset);
                return col * i.color; //Multiplicando el input de color aqui hace posible poder cambiarlo desde el particle system
            }
            ENDCG
        }
    }
}